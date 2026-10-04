-- 09C2_SHOP_CATALOG | ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V48: 5 colunas e 2 linhas visiveis, miniaturas e Robux legiveis.
local Avatar=game:GetService("AvatarEditorService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local Cart=require(Rep:WaitForChild("09C4_OUTFIT_LIBRARY"))
local M={}
function M.Init(ctx)
 local U,A,S=ctx.U,ctx.A,ctx.S
 local toast=ctx.toast
 local groupIndex,subIndex,sortIndex=1,2,2
 local limitedMode,formatMode,creatorType="All","All","All"
 local includeOffSale=false
 local pages,selected=nil,nil
 local sourceSub,sourceFilter,sourceEmotes=nil,nil,false
 local revision,shown=0,0
 local loading=false
 local seen,oldDates={},{}
 local search,groups,subs
 local sortNames={"RELEVÂNCIA","POPULAR","RECENTES","FAVORITOS","MENOR PREÇO","MAIOR PREÇO"}
 local labels={TODOS="TUDO",["CABEÇA E ROSTO"]="CABEÇA",["ANIMAÇÕES"]="EMOTES",LIMITEDS="LIMITED",EXTRAS="EXTRAS"}
 local function trim(v)return tostring(v or""):match("^%s*(.-)%s*$")end
 local function clear(p)
  for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end
 end
 local function isEmote(item)
  local v=item and item.AssetType
  if typeof(v)=="EnumItem"then return v==Enum.AvatarAssetType.EmoteAnimation end
  if type(v)=="table"then v=v.Name or v.Id or v.Value end
  return v=="EmoteAnimation"or tonumber(v)==Enum.AvatarAssetType.EmoteAnimation.Value
 end
 local function emoteMode()
  local g=A.Groups[groupIndex];local sub=g and g.subs[subIndex]
  return g and g.name=="ANIMAÇÕES"and sub and sub[1]=="EMOTES"
 end
 local function price(item)
  local p=A.Price(item);if p~=nil then return p end
  for _,k in ipairs({"PriceInRobux","UnitPrice","BestPrice","FinalPrice"})do
   local n=tonumber(item[k]);if n then return n end
  end
 end
 local function priceText(item)
  local p=price(item);if p==nil then return"Consultar Robux"end
  local amount=string.format("%.0f",p):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")
  return p==0 and"GRÁTIS"or amount.." Robux"
 end
 local function resize()
  local w=U.Grid.AbsoluteSize.X;if w<1 then return end
  local gap=4;local cols=w>=640 and 5 or w>=440 and 4 or math.clamp(math.floor((w+gap)/108),2,4)
  local cw=math.floor((w-4-gap*(cols-1))/cols)
  local h=U.Grid.AbsoluteSize.Y;local rows=h>=150 and 2 or 1
  local ch=math.max(40,math.floor((h-gap*(rows-1)-4)/rows))
  U.GridLayout.CellSize=UDim2.fromOffset(cw,ch)
  U.GridLayout.CellPadding=UDim2.fromOffset(gap,gap)
  U.GridLayout.FillDirectionMaxCells=cols;U.GridLayout.SortOrder=Enum.SortOrder.LayoutOrder
  for _,c in ipairs(U.Grid:GetChildren())do if c:IsA("GuiButton")then
   local im=c:FindFirstChild("ItemImage");local name=c:FindFirstChild("ItemName");local price=c:FindFirstChild("ItemPrice")
   local labels=ch>=78;local compact=ch<82;local footer=labels and 38 or 22
   local iw=math.floor(math.min(ch-6,cw*.48));local caption=tostring(c:GetAttribute("RobuxCaption")or"")
   if im then im.Position=compact and UDim2.fromOffset(3,(ch-iw)/2)or UDim2.fromOffset(1,1);im.Size=compact and UDim2.fromOffset(iw,iw)or UDim2.new(1,-2,1,-footer-2)end
   if name then name.TextSize=cw<120 and 12 or 14;name.Visible=labels;name.Position=UDim2.new(0,4,1,-38);name.Size=UDim2.new(1,-8,0,16)end
   if price then
    price.Position=compact and UDim2.fromOffset(iw+5,2)or UDim2.new(0,3,1,-22)
    price.Size=compact and UDim2.fromOffset(cw-iw-8,ch-4)or UDim2.new(1,-6,0,20)
    price.Text=compact and(caption=="Consultar Robux"and"Ver\npreço"or caption:gsub(" Robux$","\nRobux"))or caption
    price.TextSize=compact and 11 or cw<110 and 12 or 14
   end
  end end
  if U.SubsLayout then
   local sw=U.Subs.AbsoluteSize.X;local sc=math.max(1,math.floor(sw/144))
   U.SubsLayout.CellSize=UDim2.fromOffset(math.max(90,math.floor((sw-8-(sc-1)*6)/sc)),36)
   U.SubsLayout.FillDirectionMaxCells=sc
  end
 end
 local function status()
  U.Status.Text=shown==0 and"Nenhum item. Ajuste a busca ou os filtros."or(shown.." itens • toque para ver detalhes")
  U.More.Visible=U.Grid.Visible and pages~=nil and not pages.IsFinished
  U.More.Text=loading and"CARREGANDO..."or"MAIS ITENS"
 end
 local function choose(item,anchor)
  selected=item;U.FilterPanel.Visible=false;U.SubsPopup.Visible=false;U.Detail.Visible=true
  if anchor then U.Detail:SetAttribute("AnchorX",anchor.AbsolutePosition.X);U.Detail:SetAttribute("AnchorY",anchor.AbsolutePosition.Y+anchor.AbsoluteSize.Y)end
  if U.Layout then U.Layout()end
  U.DetailImage.Image=A.Thumbnail(item,420);U.DetailName.Text=tostring(item.Name or"Item")
  U.DetailPrice.Text=priceText(item);U.Try.Text=isEmote(item)and"TESTAR EMOTE"or"EXPERIMENTAR"
  U.Buy.Text="COMPRAR";U.DetailCreator.Text="";U.DetailDescription.Text=tostring(item.Description or"Consultando descrição...")
  task.spawn(function()
   local ok,d=pcall(function()if A.ItemType(item)=="Bundle"then return Avatar:GetItemDetailsAsync(tonumber(item.Id),Enum.AvatarItemType.Bundle)end;return Market:GetProductInfoAsync(tonumber(item.Id),Enum.InfoType.Asset)end)
   if selected~=item or not U.Detail.Visible then return end
   if ok and d then local text=tostring(d.Description or"");U.DetailDescription.Text=text~=""and text or"O criador não adicionou uma descrição.";U.DetailCreator.Text="Criado por "..tostring(d.Creator and d.Creator.Name or d.CreatorName or"criador do item")
   else U.DetailDescription.Text=tostring(item.Description or"Descrição indisponível. Confira o item no Roblox.")end
  end)
 end
 local wearing=false
 local function wear()
  if not selected or wearing then return end
  local item=selected;wearing=true;local old=U.Try.Text;U.Try.Text="CARREGANDO..."
  if ctx.preview then ctx.preview()end
  local ok,err
  if isEmote(item)then
   if ctx.playEmote then ok,err=ctx.playEmote(tonumber(item.Id))else err="Prévia indisponível."end
  else ok,err=S.Try(item)end
  if U.Try.Parent then U.Try.Text=old end;wearing=false
  if ok then U.Detail.Visible=false end
  toast(ok and(isEmote(item)and"Emote tocando."or"Item experimentado · aplicando no personagem.")or err)
 end
 local function oldEnough(item,sub)
  if not sub or not sub.oldBefore then return true end
  local id=tonumber(item.Id);if not id then return false end
  if oldDates[id]==nil then
   local ok,r=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
   oldDates[id]=ok and r and tonumber(tostring(r.Created or""):match("^(%d%d%d%d)"))or false
  end
  return oldDates[id]~=false and oldDates[id]<=tonumber(sub.oldBefore)
 end
 local function addCard(item,mine,sub,filter,onlyEmotes)
  if type(item)~="table"or not tonumber(item.Id)then return end
  local k=A.ItemType(item)..":"..item.Id
  if seen[k]or not A.PostFilter(item,sub,filter)or(onlyEmotes and not isEmote(item))then return end
  if not oldEnough(item,sub)or mine~=revision then return end
  seen[k]=true;shown=shown+1
  local c=U.Button(U.Grid,"",{BackgroundColor3=U.Colors.card,LayoutOrder=shown})
  c:SetAttribute("RobuxCaption",priceText(item))
  local padding=c:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
  local im=U.New("ImageLabel",{Name="ItemImage",Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-64),
   BackgroundColor3=Color3.fromRGB(72,78,89),BorderSizePixel=0,Image=A.Thumbnail(item,420),ScaleType=Enum.ScaleType.Fit},c)
  U.Round(im,8)
  U.Text(c,tostring(item.Name or"Item"),{Name="ItemName",Position=UDim2.new(0,8,1,-54),Size=UDim2.new(1,-16,0,20),
   Font=Enum.Font.GothamMedium,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
  U.Text(c,priceText(item),{Name="ItemPrice",Position=UDim2.new(0,8,1,-32),Size=UDim2.new(1,-16,0,28),
   Font=Enum.Font.GothamBold,TextSize=15,TextColor3=U.Colors.green,TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=false})
  c.Activated:Connect(function()choose(item,c)end)
 end
 search=function(append)
  if append and(loading or not pages or pages.IsFinished)then return end
  local mine,source,sub,filter,onlyEmotes,params
  if append then mine=revision;source=pages;sub=sourceSub;filter=sourceFilter;onlyEmotes=sourceEmotes
  else
   local lo,hi=trim(U.Min.Text),trim(U.Max.Text)
   if(lo~=""and not tonumber(lo))or(hi~=""and not tonumber(hi))then toast("Use números nos filtros de preço.");return end
   if tonumber(lo)and tonumber(hi)and tonumber(lo)>tonumber(hi)then toast("O preço máximo deve ser maior que o mínimo.");return end
   revision=revision+1;mine=revision;pages=nil;selected=nil;seen={};shown=0
   U.Detail.Visible=false;clear(U.Grid);U.Grid.CanvasPosition=Vector2.zero
   local ok,p,s,f=pcall(A.BuildParams,groupIndex,subIndex,trim(U.Query.Text),sortIndex,
    lo,hi,U.Creator.Text,creatorType,"All",limitedMode,formatMode,includeOffSale)
   if not ok then loading=false;U.Status.Text="Não foi possível aplicar estes filtros.";return end
   params,sub,filter=p,s,f;onlyEmotes=emoteMode()
   if not filter.freeCategory and lo==""and(hi==""or tonumber(hi)>=1)then params.MinPrice=1;filter.item="Paid"end
   if onlyEmotes then params.AssetTypes={Enum.AvatarAssetType.EmoteAnimation};params.BundleTypes={}end
  end
  loading=true;U.Status.Text="Buscando itens...";U.More.Text="CARREGANDO..."
  task.spawn(function()
   local ok,res=pcall(function()
    if append then source:AdvanceToNextPageAsync()else source=Avatar:SearchCatalogAsync(params)end
    return source:GetCurrentPage()
   end)
   if mine~=revision then return end
   if ok then
    pages=source;sourceSub=sub;sourceFilter=filter;sourceEmotes=onlyEmotes
    local success=pcall(function()for _,item in ipairs(res or{})do addCard(item,mine,sub,filter,onlyEmotes)end end)
    if mine~=revision then return end
    loading=false;resize();status()
    if not success then U.Status.Text="Alguns itens não puderam ser exibidos."end
   else
    loading=false;U.More.Text="TENTAR NOVAMENTE";U.Status.Text="O catálogo não respondeu. Tente novamente."
    if append then U.More.Visible=true end
   end
  end)
 end
 groups=function()
  clear(U.Groups)
  local l=U.Groups:FindFirstChildOfClass("UIListLayout");if l then l.SortOrder=Enum.SortOrder.LayoutOrder end
  for i,g in ipairs(A.Groups)do
   local cap=labels[g.name]or g.name
   local b=U.Button(U.Groups,cap,{Size=UDim2.fromOffset(math.clamp(#cap*7+20,68,148),34),LayoutOrder=i,
    BackgroundColor3=i==groupIndex and U.Colors.soft or U.Colors.card,TextWrapped=false})
   b.Activated:Connect(function()
    groupIndex=i;subIndex=i==1 and math.min(2,#g.subs)or 1
    if g.name=="CORPO"then U.Min.Text="";U.Max.Text="";formatMode="All";for _,o in ipairs({U.FormAll,U.FormClassic,U.Form2D,U.Form3D})do o.BackgroundColor3=o==U.FormAll and U.Colors.soft or U.Colors.card end end
    U.SubsPopup.Visible=false;groups();subs();search(false)
   end)
  end
 end
 subs=function()
  clear(U.Subs);local g=A.Groups[groupIndex];if not g then return end
  U.SubToggle.Text="SUB: "..(g.subs[subIndex]or g.subs[1])[1];U.SubToggle.TextColor3=U.Colors.green;U.SubToggle.BackgroundColor3=U.Colors.soft;U.SubToggle.Font=Enum.Font.GothamBold;U.SubToggle.TextSize=12
  U.SubToggle.TextTruncate=Enum.TextTruncate.AtEnd
  for i,v in ipairs(g.subs)do
   local b=U.Button(U.Subs,v[1],{LayoutOrder=i,BackgroundColor3=i==subIndex and U.Colors.soft or U.Colors.card,ZIndex=60})
   b.Activated:Connect(function()subIndex=i;U.SubsPopup.Visible=false;subs();search(false)end)
  end
  resize()
 end
 local function paint(buttons,on)
  for _,b in ipairs(buttons)do b.BackgroundColor3=b==on and U.Colors.soft or U.Colors.card end
 end
 local lim={U.LimAll,U.LimOnly,U.LimNo};local forms={U.FormAll,U.FormClassic,U.Form2D,U.Form3D}
 local function resetFilters()
  U.Min.Text="";U.Max.Text="";U.Creator.Text=""
  creatorType="All";limitedMode="All";formatMode="All";includeOffSale=false
  U.CreatorType.Text="Todos criadores";U.OffSale.Text="Fora de venda: NÃO"
  paint(lim,U.LimAll);paint(forms,U.FormAll)
 end
 for i,b in ipairs(lim)do b.Activated:Connect(function()limitedMode=({"All","Only","Exclude"})[i];paint(lim,b)end)end
 for i,b in ipairs(forms)do b.Activated:Connect(function()formatMode=({"All","Classic","2D","3D"})[i];paint(forms,b)end)end
 U.SubToggle.Activated:Connect(function()U.SubsPopup.Visible=not U.SubsPopup.Visible;U.FilterPanel.Visible=false end)
 U.Filter.Activated:Connect(function()U.FilterPanel.Visible=not U.FilterPanel.Visible;U.SubsPopup.Visible=false end)
 U.CloseFilter.Activated:Connect(function()U.FilterPanel.Visible=false end)
 U.CreatorType.Activated:Connect(function()
  local opts={"All","User","Group"};creatorType=opts[(table.find(opts,creatorType)or 1)%3+1]
  U.CreatorType.Text=creatorType=="All"and"Todos criadores"or creatorType=="User"and"Usuários"or"Grupos"
 end)
 U.OffSale.Activated:Connect(function()includeOffSale=not includeOffSale;U.OffSale.Text="Fora de venda: "..(includeOffSale and"SIM"or"NÃO")end)
 U.ApplyFilter.Activated:Connect(function()U.FilterPanel.Visible=false;search(false)end)
 U.ClearFilter.Activated:Connect(function()resetFilters();search(false)end)
 U.DetailClose.Activated:Connect(function()U.Detail.Visible=false;selected=nil end)
 U.Try.Activated:Connect(wear)
 U.Buy.Activated:Connect(function()if selected then local r,e=ctx.call("PurchaseItem",{id=tonumber(selected.Id),kind=A.ItemType(selected)});if not r then toast(e)end end end)
 U.Favorite.Activated:Connect(function()
  if selected then pcall(function()Avatar:PromptSetFavorite(tonumber(selected.Id),A.ItemEnum(selected),true)end)end
 end)
 U.Query.FocusLost:Connect(function(enter)if enter then search(false)end end)
 if U.SearchGo then U.SearchGo.Activated:Connect(function()search(false)end)end
 U.More.Activated:Connect(function()search(pages~=nil)end)
 U.Sort.Activated:Connect(function()sortIndex=sortIndex%#A.Sorts+1;U.Sort.Text=sortNames[sortIndex];search(false)end)
 U.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 U.Subs:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 U.Grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
  if loading or not U.Root.Visible or not U.Grid.Visible or not pages or pages.IsFinished then return end
  if U.Grid.CanvasPosition.Y+U.Grid.AbsoluteWindowSize.Y>U.Grid.AbsoluteCanvasSize.Y-160 then search(true)end
 end)
 U.Grid:GetPropertyChangedSignal("Visible"):Connect(function()if not U.Grid.Visible then revision=revision+1;loading=false end end)
 local function preset(kind)
  groupIndex=1;subIndex=2;sortIndex=2;U.Query.Text=""
  if kind=="Emotes"then
   resetFilters()
   for gi,g in ipairs(A.Groups)do
    if g.name=="ANIMAÇÕES"then
     groupIndex=gi;for si,v in ipairs(g.subs)do if v[1]=="EMOTES"then subIndex=si;break end end;break
    end
   end
  elseif kind=="New"then sortIndex=3 elseif kind=="Trending"then subIndex=4 end
  U.Sort.Text=sortNames[sortIndex];U.SubsPopup.Visible=false;groups();subs();search(false)
 end
 groups();subs();resize()
 return{Search=function()search(false)end,Resize=resize,Preset=preset,ShowItem=choose,OpenCart=Cart.Open}
end
return M
