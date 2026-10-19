-- 09C2_SHOP_CATALOG | ModuleScript | ReplicatedStorage | V70 (SUBSTITUIR)
-- AVATAR PLAZA V51: 5 colunas e 2 linhas visiveis, miniaturas e Robux legiveis.
local Avatar=game:GetService("AvatarEditorService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local Cart=require(Rep:WaitForChild("09C4_OUTFIT_LIBRARY"))
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local M={Version='V69'}
function M.Init(ctx)
 local U,A,S=ctx.U,ctx.A,ctx.S
 local toast=ctx.toast
 local FilterUI=require(Rep:WaitForChild('09C3_CATALOG_FILTERS')).Build(U);local oldLayout=U.Layout
 U.Layout=function(...)if oldLayout then oldLayout(...)end;FilterUI.Layout()end
 local groupIndex,subIndex,sortIndex=1,2,2
 local limitedMode,formatMode,creatorType="All","All","All"
 local includeOffSale=false
 local pages,selected=nil,nil
 local sourceSub,sourceFilter,sourceEmotes=nil,nil,false;local sourceParams;local freeLater=false;local freePhase=false
 local revision,shown=0,0
 local loading=false
 local seen,oldDates={},{}
 local rows,pool={},{};local cols,cw,ch=5,100,130;local updateGrid
 U.GridLayout.Parent=nil;U.Grid.AutomaticCanvasSize=Enum.AutomaticSize.None
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
  local gap=4;local landscape=U.Root.AbsoluteSize.X>=U.Root.AbsoluteSize.Y
  cols=(landscape and w>=440 or w>=640)and 5 or w>=440 and 4 or math.clamp(math.floor((w+gap)/108),2,4)
  cw=math.floor((w-4-gap*(cols-1))/cols)
  local h=U.Grid.AbsoluteSize.Y;local rows=h>=150 and 2 or 1
  ch=math.max(40,math.floor((h-gap*(rows-1)-4)/rows))
  U.GridLayout.CellSize=UDim2.fromOffset(cw,ch)
  U.GridLayout.CellPadding=UDim2.fromOffset(gap,gap)
  U.GridLayout.FillDirectionMaxCells=cols;U.GridLayout.SortOrder=Enum.SortOrder.LayoutOrder
  if updateGrid then updateGrid()end
  if U.SubsLayout then
   local sw=U.Subs.AbsoluteSize.X;local sc=math.max(1,math.floor(sw/144))
   U.SubsLayout.CellSize=UDim2.fromOffset(math.max(90,math.floor((sw-8-(sc-1)*6)/sc)),36)
   U.SubsLayout.FillDirectionMaxCells=sc
  end
 end
 local function status()
  U.Status.Text=shown==0 and"Nenhum item. Ajuste a busca ou os filtros."or(shown.." itens • "..(freePhase and"gratuitos"or"pagos primeiro").." • toque para detalhes")
  U.More.Visible=U.Grid.Visible and pages~=nil and(not pages.IsFinished or freeLater)
  U.More.Text=loading and"..."or pages and pages.IsFinished and freeLater and"VER ITENS GRÁTIS"or"MAIS"
 end
 local function choose(item,anchor)
  if U.OnCatalogBrowse then U.OnCatalogBrowse()end
  selected=item;U.FilterPanel.Visible=false;U.SubsPopup.Visible=false;U.Detail.Visible=true
  if anchor then local origin=U.Root.AbsolutePosition;U.Detail:SetAttribute("AnchorX",anchor.AbsolutePosition.X-origin.X);U.Detail:SetAttribute("AnchorY",anchor.AbsolutePosition.Y+anchor.AbsoluteSize.Y-origin.Y)end
  if U.Layout then U.Layout()end;U.DetailName.Size=UDim2.new(1,-188,0,46)
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
 local bookmark=D.Button(U.Detail,'♡',{Name='BookmarkCatalogItem',Size=UDim2.fromOffset(44,44),TextSize=23,ZIndex=95});local marked={}
 local oldChoose=choose;choose=function(item,anchor)oldChoose(item,anchor);local key=A.ItemType(item)..':'..item.Id;if item.CatalogFavorite==true then marked[key]=true end;bookmark.Text=marked[key]and'♥'or'♡';if updateGrid then updateGrid()end end
 local busyFavorite=false;bookmark.Activated:Connect(function()
  if not selected or busyFavorite then return end;local item=selected;local key=A.ItemType(item)..':'..item.Id;busyFavorite=true
  task.spawn(function()local r,e=ctx.call('CatalogFavorite',{id=item.Id,kind=A.ItemType(item),value=not marked[key]});busyFavorite=false;if r then marked[key]=r.value;item.CatalogFavorite=r.value;if updateGrid then updateGrid()end;if selected==item then bookmark.Text=r.value and'♥'or'♡'end;toast(r.value and'Peça guardada nos seus favoritos.'or'Peça removida dos favoritos.')else toast(e)end end)
 end)
 local oldDetailLayout=U.Layout;U.Layout=function(...)oldDetailLayout(...);bookmark.Position=UDim2.fromOffset(math.max(8,U.Detail.AbsoluteSize.X-102),2)end
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
  if ok then U.Detail.Visible=false;if updateGrid then updateGrid()end end
  toast(ok and(isEmote(item)and"Emote tocando."or"Carregando item na prévia e no personagem...")or err)
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
 updateGrid=function()
  local equipped={};if S.Current then for _,v in ipairs(A.Entries(S.Current))do equipped[v.Id]=true end end
  local step=ch+4;local count=math.ceil(#rows/cols);local height=math.max(0,count*step-4)
  U.Grid.CanvasSize=UDim2.fromOffset(0,height)
  local first=math.max(0,math.floor(U.Grid.CanvasPosition.Y/step)-1)*cols+1
  local needed=math.min(40,(math.ceil(U.Grid.AbsoluteSize.Y/step)+3)*cols)
  for i=1,needed do
   local slot=pool[i]
   if not slot then
    local c=U.Button(U.Grid,"",{Name="CatalogSlot"..i,BackgroundColor3=U.Colors.card})
    Fx.Surface(c,Color3.fromRGB(48,55,71),Color3.fromRGB(35,43,55),D.Colors.blue);Fx.Button(c,D.Colors.orange)
    local pad=c:FindFirstChildOfClass("UIPadding");if pad then pad:Destroy()end
    local im=U.New("ImageLabel",{Name="ItemImage",BackgroundColor3=Color3.fromRGB(72,83,96),BorderSizePixel=0,ScaleType=Enum.ScaleType.Fit},c);U.Round(im,8)
    local p=U.Text(c,"",{Name="ItemPrice",Font=Enum.Font.GothamBold,TextColor3=U.Colors.green,TextWrapped=false})
    local tag=U.Text(c,'Emote • testar',{Name='EmoteTag',TextSize=10,TextColor3=D.Colors.bg,BackgroundColor3=Color3.fromRGB(105,79,151),BackgroundTransparency=.06,ZIndex=4,Visible=false});U.Round(tag,6)
    local state=D.Text(c,'',{Name='CatalogItemState',TextSize=12,Font=Enum.Font.GothamBold,TextColor3=D.Colors.bg,BackgroundColor3=D.Colors.green,BackgroundTransparency=.02,ZIndex=5});D.Round(state,5)
    slot={root=c,image=im,price=p,tag=tag,state=state};pool[i]=slot
    c.Activated:Connect(function()if slot.item then choose(slot.item,c)end end)
   end
   local index=first+i-1;local item=rows[index];slot.root.Visible=item~=nil;slot.item=item
   if item then
    slot.root.BackgroundColor3=A.Groups[groupIndex].name=='HALLOWEEN'and Color3.fromRGB(249,234,214)or U.Colors.card;slot.root.LayoutOrder=index;slot.root:SetAttribute("ItemId",item.Id);slot.root:SetAttribute("RobuxCaption",priceText(item))
    slot.root.Position=UDim2.fromOffset((index-1)%cols*(cw+4),math.floor((index-1)/cols)*step);slot.root.Size=UDim2.fromOffset(cw,ch)
    slot.image.Position=UDim2.fromOffset(2,2);slot.image.Size=UDim2.fromOffset(cw-4,math.max(16,ch-22))
    slot.tag.Visible=isEmote(item);slot.tag.Position=UDim2.fromOffset(5,5);slot.tag.Size=UDim2.fromOffset(math.min(cw-10,100),20)
    local key=A.ItemType(item)..':'..item.Id;local picked=selected and selected.Id==item.Id
    slot.state.Text=equipped[tonumber(item.Id)]and'Usando'or marked[key]and'♥ Salvo'or picked and'Selecionado'or''
    slot.state.Visible=slot.state.Text~='';slot.state.Position=UDim2.fromOffset(5,5);slot.state.Size=UDim2.fromOffset(cw-10,20);if slot.state.Visible then slot.tag.Visible=false end
    local edge=slot.root:FindFirstChildOfClass('UIStroke');if edge then edge.Color=picked and D.Colors.green or D.Colors.line;edge.Transparency=picked and .05 or .65;edge.Thickness=picked and 2 or 1 end
    slot.image.Image=A.Thumbnail(item,420);slot.price.Text=priceText(item);slot.price.TextSize=math.clamp(math.floor((cw-6)/math.max(1,#slot.price.Text*.68)),10,13)
    slot.price.Position=UDim2.fromOffset(3,ch-20);slot.price.Size=UDim2.fromOffset(cw-6,18);slot.price.TextColor3=price(item)==0 and D.Colors.green or D.Colors.gold
   end
  end
  for i=needed+1,#pool do pool[i].root.Visible=false;pool[i].item=nil end
 end
 local function addCard(item,mine,sub,filter,onlyEmotes)
  if type(item)~="table"or not tonumber(item.Id)then return end
  local k=A.ItemType(item)..":"..item.Id
  if seen[k]or not A.PostFilter(item,sub,filter)or(onlyEmotes and not isEmote(item))then return end
  if not oldEnough(item,sub)or mine~=revision then return end
  seen[k]=true;shown=shown+1;rows[#rows+1]=item
 end
 search=function(append)
  if U.OnCatalogBrowse then U.OnCatalogBrowse()end
  if append and(loading or not pages or pages.IsFinished and not freeLater)then return end
  local mine,source,sub,filter,onlyEmotes,params
  if append then mine=revision;source=pages;sub=sourceSub;filter=sourceFilter;onlyEmotes=sourceEmotes
   if source.IsFinished and freeLater then source=nil;params=sourceParams;params.MinPrice=0;params.MaxPrice=0;filter.item='Free';freeLater=false;freePhase=true end
  else
   local valid,why=FilterUI.Validate();if not valid then toast(why);U.FilterPanel.Visible=true;return end
   local lo,hi=trim(U.Min.Text),trim(U.Max.Text)
   if(lo~=""and not tonumber(lo))or(hi~=""and not tonumber(hi))then toast("Use números nos filtros de preço.");return end
   if tonumber(lo)and tonumber(hi)and tonumber(lo)>tonumber(hi)then toast("O preço máximo deve ser maior que o mínimo.");return end
   revision=revision+1;mine=revision;freeLater=false;freePhase=false;pages=nil;selected=nil;seen={};shown=0
   U.Detail.Visible=false;rows={};shown=0;updateGrid();U.Grid.CanvasPosition=Vector2.zero
   local ok,p,s,f=pcall(A.BuildParams,groupIndex,subIndex,trim(U.Query.Text),sortIndex,
    lo,hi,U.Creator.Text,creatorType,"All",limitedMode,formatMode,includeOffSale)
   if not ok then loading=false;U.Status.Text="Não foi possível aplicar estes filtros.";return end
   params,sub,filter=p,s,f;onlyEmotes=emoteMode()
   local count=(lo~=''and 1 or 0)+(hi~=''and 1 or 0)+(trim(U.Creator.Text)~=''and 1 or 0)+(limitedMode~='All'and 1 or 0)+(formatMode~='All'and 1 or 0)+(includeOffSale and 1 or 0);U.Filter.Text=count>0 and('Filtros • '..count)or'Filtros'
   if not filter.freeCategory and(lo==''or tonumber(lo)==0)and(hi==''or tonumber(hi)>=1)then params.MinPrice=1;filter.item='Paid';freeLater=true end
   sourceParams=params
   if onlyEmotes then params.AssetTypes={Enum.AvatarAssetType.EmoteAnimation};params.BundleTypes={}end
  end
  loading=true;U.Status.Text="Buscando itens...";U.More.Text="..."
  task.spawn(function()
   local ok,res=pcall(function()
    if append and source then source:AdvanceToNextPageAsync()else source=Avatar:SearchCatalogAsync(params)end
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
    BackgroundColor3=g.name=="HALLOWEEN"and(i==groupIndex and Color3.fromRGB(246,212,164)or Color3.fromRGB(249,234,214))or i==groupIndex and U.Colors.soft or U.Colors.card,TextColor3=g.name=="HALLOWEEN"and(i==groupIndex and Color3.fromRGB(30,22,24)or D.Colors.orange)or U.Colors.white,TextWrapped=false})
   b.Activated:Connect(function()
    groupIndex=i;subIndex=i==1 and math.min(2,#g.subs)or 1
    if g.name=="CORPO"then U.Min.Text="";U.Max.Text="";formatMode="All";for _,o in ipairs({U.FormAll,U.FormClassic,U.Form2D,U.Form3D})do o.BackgroundColor3=o==U.FormAll and U.Colors.soft or U.Colors.card end end
    U.SubsPopup.Visible=false;groups();subs();search(false)
   end)
  end
 end
 subs=function()
  clear(U.Subs);local g=A.Groups[groupIndex];if not g then return end
  U.SubToggle.Text="SUB: "..(g.subs[subIndex]or g.subs[1])[1];U.SubToggle.TextColor3=g.name=="HALLOWEEN"and D.Colors.orange or U.Colors.green;U.SubToggle.BackgroundColor3=g.name=="HALLOWEEN"and Color3.fromRGB(249,234,214)or U.Colors.soft;U.SubToggle.Font=Enum.Font.GothamBold;U.SubToggle.TextSize=12
  U.SubToggle.TextTruncate=Enum.TextTruncate.AtEnd
  for i,v in ipairs(g.subs)do
   local b=U.Button(U.Subs,v[1],{LayoutOrder=i,BackgroundColor3=g.name=="HALLOWEEN"and(i==subIndex and Color3.fromRGB(246,212,164)or Color3.fromRGB(249,234,214))or i==subIndex and U.Colors.soft or U.Colors.card,ZIndex=60})
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
 U.ApplyFilter.Activated:Connect(function()local ok,e=FilterUI.Validate();if not ok then toast(e);return end;U.FilterPanel.Visible=false;search(false)end)
 U.ClearFilter.Activated:Connect(function()resetFilters();search(false)end)
 U.DetailClose.Activated:Connect(function()U.Detail.Visible=false;selected=nil end)
 U.Try.Activated:Connect(wear)
 U.Buy.Activated:Connect(function()if selected then local r,e=ctx.call("PurchaseItem",{id=tonumber(selected.Id),kind=A.ItemType(selected)});if not r then toast(e)end end end)
 U.Favorite.Activated:Connect(function()if selected then Cart.Add(selected)end end)
 U.Query.FocusLost:Connect(function(enter)if enter then search(false)end end)
 if U.SearchGo then U.SearchGo.Activated:Connect(function()search(false)end)end
 U.More.Activated:Connect(function()search(pages~=nil)end)
 U.Sort.Activated:Connect(function()sortIndex=sortIndex%#A.Sorts+1;U.Sort.Text=sortNames[sortIndex];search(false)end)
 U.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 U.Subs:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 U.Grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
  updateGrid()
  if loading or not U.Root.Visible or not U.Grid.Visible or not pages or pages.IsFinished then return end
  if U.Grid.CanvasPosition.Y+U.Grid.AbsoluteWindowSize.Y>U.Grid.AbsoluteCanvasSize.Y-160 then search(true)end
 end)
 U.Grid:GetPropertyChangedSignal("Visible"):Connect(function()if not U.Grid.Visible then revision=revision+1;loading=false end end)
 local function preset(kind)
  groupIndex=1;subIndex=2;sortIndex=2;U.Query.Text=""
  local target=({Hair='ACESSÓRIOS',Clothing='ROUPAS',Body='CORPO',Featured='TODOS'})[kind]
  if target then resetFilters();for gi,g in ipairs(A.Groups)do if g.name==target then groupIndex=gi;subIndex=target=='TODOS'and 2 or 1;if kind=='Hair'then for si,v in ipairs(g.subs)do if v[1]=='CABELOS'then subIndex=si;break end end end;break end end end
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
 return{Search=function()search(false)end,Resize=resize,Preset=preset,ShowItem=choose,OpenCart=Cart.Open,GetRows=function()return rows end,Pool=pool}
end
return M
