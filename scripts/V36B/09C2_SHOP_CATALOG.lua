-- 09C2_SHOP_CATALOG
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V36A - galeria com cards maiores, até 5 colunas e ações no painel de detalhe.
local Avatar=game:GetService("AvatarEditorService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local M={}

function M.Init(ctx)
 local U,A,S,pl=ctx.U,ctx.A,ctx.S,ctx.pl
 local toast=ctx.toast
 local call=ctx.call
 local pages,selected,currentSub,currentFilter
 local groupIndex,subIndex,sortIndex=1,2,2
 local limitedMode,formatMode,creatorType="All","All","All"
 local includeOffSale=false
 local loading=false
 local pendingFull=false
 local totalShown=0
 local subs
 local oldDateCache={}
 local emoteMode=false
 local playEmote=ctx.playEmote
 local lastSearchText=""

 local function clear(p)
  for _,c in ipairs(p:GetChildren())do
   if c:IsA("GuiObject")then c:Destroy()end
  end
 end

 local function resize()
  local w=U.Grid.AbsoluteSize.X
  local cols=w>=850 and 5 or w>=520 and 4 or 3
  local gap=7
  local cw=math.floor((w-gap*(cols-1)-8)/cols)
  cw=math.clamp(cw,118,188)
  U.GridLayout.CellSize=UDim2.fromOffset(cw,math.floor(cw*1.04)+44)
  U.GridLayout.CellPadding=UDim2.fromOffset(gap,8)
 end

 local progressEvent=nil
 local kit=Rep:FindFirstChild("PracaKit");local rr=kit and kit:FindFirstChild("Remotes");progressEvent=rr and rr:FindFirstChild("PlazaProgress")
 local function isEmoteItem(item)
  local raw=item and item.AssetType
  return(typeof(raw)=="EnumItem"and raw==Enum.AvatarAssetType.EmoteAnimation)or tonumber(type(raw)=="table"and(raw.Id or raw.Value)or raw)==Enum.AvatarAssetType.EmoteAnimation.Value
 end
 local function isBundleItem(item)
  return A.ItemType(item)=="Bundle"
 end
 local function wearNow(item,buttonRef)
  if not item then return end
  if isEmoteItem(item)then
   if not playEmote then toast("Prévia de emote indisponível.");return end
   local ok,e=playEmote(tonumber(item.Id));toast(ok and"Emote tocando na prévia."or e);return
  end
  local bundle=isBundleItem(item);local oldText=buttonRef and buttonRef.Text
  if buttonRef and buttonRef.Parent then buttonRef.Text=bundle and"CARREGANDO SKIN..."or"VESTINDO..."end
  local ok,e=S.Try(item)
  if ok then
   toast(bundle and"✓ SKIN 3D COMPLETA CARREGADA • veja corpo, proporções e acessórios na prévia"or"✓ VESTIDO NA PRÉVIA • olhe seu avatar à esquerda")
   if buttonRef and buttonRef.Parent then buttonRef.Text=bundle and"SKIN 3D ✓"or"VESTIDO ✓";task.delay(1.5,function()if buttonRef.Parent then buttonRef.Text=oldText or(bundle and"USAR SKIN 3D"or"VESTIR +")end end)end
   if not progressEvent then local k=Rep:FindFirstChild("PracaKit");local r=k and k:FindFirstChild("Remotes");progressEvent=r and r:FindFirstChild("PlazaProgress")end
   if progressEvent and progressEvent:IsA("RemoteEvent")then progressEvent:FireServer("tryItem",tonumber(item.Id))end
  else
   if buttonRef and buttonRef.Parent then buttonRef.Text=oldText or"VESTIR +"end
   toast(e)
  end
 end

 local function choose(item)
  selected=item
  U.Detail.Visible=true
  U.DetailImage.Image=A.Thumbnail(item,420)
  U.DetailName.Text=tostring(item.Name or"Item")
  U.DetailPrice.Text=A.PriceText(item)
  local isEmote=isEmoteItem(item);U.Try.Text=isEmote and"TESTAR EMOTE"or(isBundleItem(item)and"USAR SKIN 3D"or"VESTIR AGORA")
 end

 local function oldEnough(item,sub)
  if not sub or not sub.oldBefore then return true end
  local id=tonumber(item and item.Id);if not id then return false end
  if oldDateCache[id]~=nil then return oldDateCache[id]end
  local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
  local created=ok and info and tostring(info.Created or info.CreatedAt or"")or""
  local year=tonumber(created:match("^(%d%d%d%d)"));local pass=year~=nil and year<=tonumber(sub.oldBefore)
  oldDateCache[id]=pass;return pass
 end

 local function assetTypeName(item)
  local raw=item and item.AssetType
  if typeof(raw)=="EnumItem"then return raw.Name end
  if type(raw)=="table"then raw=raw.Name or raw.Id end
  if tonumber(raw)==Enum.AvatarAssetType.EmoteAnimation.Value then return "EmoteAnimation" end
  return tostring(raw or""):match("([%w_]+)$")or""
 end
 local function passItem(item)
  if emoteMode then return assetTypeName(item)=="EmoteAnimation" end
  return A.PostFilter(item,currentSub,currentFilter)
 end
 local function updateMode()
  local g=A.Groups[groupIndex];local sub=g and g.subs[subIndex]
  emoteMode=g and g.name=="ANIMAÇÕES"and sub and sub[1]=="EMOTES"or false
 end

 local function normalizeSearch(value)
  local s=string.lower(tostring(value or""))
  s=s:gsub("[%p_]"," "):gsub("%s+"," ")
  return s:match("^%s*(.-)%s*$")or""
 end
 local function relevance(item,q)
  if q==""then return 1 end
  local name=normalizeSearch(item and item.Name)
  if name==q then return 10000 end
  if name:find(q,1,true)then return 8500 end
  local hits,total=0,0
  for token in q:gmatch("%S+")do
   if #token>=2 then total=total+1;if name:find(token,1,true)then hits=hits+1 end end
  end
  if total==0 then return 0 end
  if hits==total then return 7000+hits end
  if total==1 and hits==1 then return 5500 end
  if total>=3 and hits>=math.ceil(total*.75)then return 4000+hits end
  return 0
 end
 local function ranked(items)
  local q=normalizeSearch(U.Query.Text);if q==""then return items or{} end
  local scored={}
  for _,item in ipairs(items or{})do
   local score=relevance(item,q);if score>0 then table.insert(scored,{item=item,score=score})end
  end
  if sortIndex==1 then table.sort(scored,function(a,b)if a.score~=b.score then return a.score>b.score end;return tostring(a.item.Name or"")<tostring(b.item.Name or"")end)end
  local out={};for _,v in ipairs(scored)do table.insert(out,v.item)end;return out
 end

 local function paidFirst(items)
  if currentFilter and(currentFilter.freeCategory==true or currentFilter.item=="Free")then return items end
  local paid,free={},{};for _,item in ipairs(items or{})do if A.Price(item)==0 then free[#free+1]=item else paid[#paid+1]=item end end
  for _,item in ipairs(free)do paid[#paid+1]=item end;return paid
 end
 local function addCard(item,oldChecked)
  if not passItem(item)then return 0 end
  if not oldChecked and not oldEnough(item,currentSub)then return 0 end
  totalShown=totalShown+1
  local c=U.Button(U.Grid,"",{Size=UDim2.fromScale(1,1),BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(35,37,42),AutoButtonColor=false})
  c.Text="";U.Round(c,11);U.New("UIStroke",{Color=Color3.fromRGB(83,89,100),Transparency=.62,Thickness=1},c)
  local im=U.New("ImageLabel",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-43),BackgroundColor3=Color3.fromRGB(49,51,57),BorderSizePixel=0,Image=A.Thumbnail(item,420),ScaleType=Enum.ScaleType.Fit},c)
  U.Round(im,9)
  U.Text(c,tostring(item.Name or"Item"),{Position=UDim2.new(0,8,1,-36),Size=UDim2.new(1,-16,0,18),Font=Enum.Font.GothamBold,TextSize=8,TextColor3=U.Colors.white,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  U.Text(c,A.PriceText(item),{Position=UDim2.new(0,8,1,-18),Size=UDim2.new(1,-16,0,14),TextColor3=A.Price(item)==0 and U.Colors.green or Color3.fromRGB(211,216,224),Font=Enum.Font.GothamBold,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left})
  c.Activated:Connect(function()choose(item)end)
  return 1
 end


 local function draw(items,append)
  if not append then clear(U.Grid);U.Grid.CanvasPosition=Vector2.zero;totalShown=0 end
  local list=paidFirst(ranked(items or{}));local n=0
  if currentSub and currentSub.oldBefore then
   local results={};local waiting=0;local activeSub=currentSub
   for i,item in ipairs(list)do
    if passItem(item)then
     local idx=i;local candidate=item;waiting=waiting+1
     task.spawn(function()results[idx]=oldEnough(candidate,activeSub);waiting=waiting-1 end)
    end
   end
   while waiting>0 do task.wait()end
   for i,item in ipairs(list)do if emoteMode and n>=10 then break end;if results[i]then n=n+addCard(item,true)end end
  else
   for _,item in ipairs(list)do
    if emoteMode and n>=10 then break end
    n=n+addCard(item,true)
   end
  end
  resize();return n
 end

 local function fillMore(target,maxPages)
  local tries=0
  while pages and totalShown<target and not pages.IsFinished and tries<(maxPages or 3)do
   tries=tries+1
   local ok=pcall(function()pages:AdvanceToNextPageAsync()end)
   if not ok then break end
   draw(pages:GetCurrentPage(),true)
  end
 end

 local function status()
  local q=normalizeSearch(U.Query.Text)
  if q~=""then
   if totalShown==0 then U.Status.Text="Nenhum resultado realmente relacionado. Tente menos palavras."
   else U.Status.Text=totalShown.." resultados relacionados à pesquisa" end
  elseif totalShown==0 then U.Status.Text=emoteMode and"Nenhum emote encontrado."or"Nenhum item encontrado."
  elseif emoteMode then U.Status.Text=totalShown.." emotes • toque em TESTAR"
  elseif pages and pages.IsFinished then U.Status.Text=totalShown.." opções • toque em VESTIR + e combine do seu jeito"
  else U.Status.Text=totalShown.." opções • toque no card para vestir ou comprar" end
 end

 local function search(append)
  if loading then
   if not append then pendingFull=true end
   return
  end
  loading=true
  U.Status.Text="Carregando..."

  if append and pages then
   if pages.IsFinished then
    status();loading=false
    if pendingFull then pendingFull=false;task.defer(function()search(false)end)end
    return
   end
   local ok=pcall(function()pages:AdvanceToNextPageAsync()end)
   if ok then
    draw(pages:GetCurrentPage(),true)
    fillMore(totalShown+10,2)
    status()
   else
    toast("Não consegui carregar mais itens.")
   end
   loading=false
   if pendingFull then pendingFull=false;task.defer(function()search(false)end)end
   return
  end

  local typed=normalizeSearch(U.Query.Text)
  if typed~=""and typed~=lastSearchText then
   sortIndex=1;U.Sort.Text="Relevância ▼"
  end
  lastSearchText=typed
  local ok,res=pcall(function()
   updateMode()
   local buildGroup,buildSub=groupIndex,subIndex
   if typed~=""then buildGroup,buildSub=1,1 end
   local p,sub,f=A.BuildParams(buildGroup,buildSub,U.Query.Text,sortIndex,U.Min.Text,U.Max.Text,U.Creator.Text,creatorType,"All",limitedMode,formatMode,includeOffSale)
   if typed~=""then
    p.SearchKeyword=typed:sub(1,100)
    if normalizeSearch(U.Min.Text)==""then p.MinPrice=0 end
   end
   if emoteMode then
    local lo=tonumber(U.Min.Text);local hi=tonumber(U.Max.Text)
    p.MinPrice=math.max(0,math.floor(lo or 0));p.MaxPrice=math.max(p.MinPrice,math.floor(hi or 2147483647));p.AssetTypes={Enum.AvatarAssetType.EmoteAnimation}
   end
   currentSub,currentFilter=sub,f
   pages=Avatar:SearchCatalogAsync(p)
   return pages:GetCurrentPage()
  end)

  if ok then
   draw(res,false)
   U.More.Visible=not emoteMode
   if not emoteMode then fillMore(typed~=""and 12 or 16,typed~=""and 7 or 4)end
   status()
  else
   clear(U.Grid)
   U.Status.Text="Busca indisponível."
   toast("O Marketplace não respondeu.")
  end
  loading=false
  if pendingFull then pendingFull=false;task.defer(function()search(false)end)end
 end


 local labels={
  TODOS="Tudo",ROUPAS="Roupas",["ACESSÓRIOS"]="Acessórios",
  ["CABEÇA E ROSTO"]="Cabeça",CORPO="Corpo",
  ["ANIMAÇÕES"]="Animações",["ROBLOX OLD"]="Roblox Old",LIMITEDS="Limiteds",
  ["GRÁTIS"]="Grátis",GEAR="Gear",EXTRAS="Extras"
 }

 local function groups()
  clear(U.Groups)
  for i,g in ipairs(A.Groups)do
   local s=labels[g.name]or g.name
   local b=U.Button(U.Groups,s,{
    Size=UDim2.fromOffset(math.clamp(#s*5+18,48,108),20),
    BackgroundTransparency=i==groupIndex and .04 or .34,
    BackgroundColor3=i==groupIndex and Color3.fromRGB(31,159,230) or Color3.fromRGB(31,92,139),
    TextColor3=Color3.fromRGB(255,255,255),TextSize=8,TextStrokeTransparency=.28,TextStrokeColor3=Color3.fromRGB(7,18,31)
   })
   b.Activated:Connect(function()
    groupIndex=i;subIndex=i==1 and 2 or 1;updateMode();groups();subs();search(false)
   end)
  end
 end

 subs=function()
  clear(U.Subs)
  local g=A.Groups[groupIndex]
  local pretty={['MARKETPLACE INTEIRO']='EXPLORAR',['DESTAQUES']='EM ALTA',['RECOMENDADOS']='INSPIRAÇÃO',['COMUNIDADE']='CRIADORES',['TEMPO LIMITADO']='LIMITADOS'}
  for i,v in ipairs(g.subs)do
   local s=pretty[v[1]]or v[1]
   local b=U.Button(U.Subs,s,{
    Size=UDim2.fromOffset(math.clamp(#s*4+14,42,126),18),
    BackgroundTransparency=i==subIndex and .08 or .38,
    BackgroundColor3=i==subIndex and Color3.fromRGB(173,67,239) or Color3.fromRGB(103,53,151),
    TextColor3=Color3.fromRGB(255,255,255),TextSize=8,TextStrokeTransparency=.24,TextStrokeColor3=Color3.fromRGB(7,18,31)
   })
   b.Activated:Connect(function()
    subIndex=i;updateMode();subs();search(false)
   end)
  end
 end

 local function paint(list,on)
  for _,b in ipairs(list)do b.BackgroundColor3=U.Colors.blue:Lerp(U.Colors.card,.62) end
  on.BackgroundColor3=U.Colors.blue
 end
 local lim={U.LimAll,U.LimOnly,U.LimNo}
 local form={U.FormAll,U.FormClassic,U.Form2D,U.Form3D}

 U.Filter.Activated:Connect(function()
  U.FilterPanel.Visible=not U.FilterPanel.Visible
 end)
 U.CloseFilter.Activated:Connect(function()U.FilterPanel.Visible=false end)
 U.CreatorType.Activated:Connect(function()
  local a={"All","User","Group"}
  creatorType=a[(table.find(a,creatorType)or 1)%3+1]
  U.CreatorType.Text=creatorType=="All"and"Todos os criadores"
   or creatorType=="User"and"Somente usuários"or"Somente grupos"
 end)
 U.LimAll.Activated:Connect(function()limitedMode="All";paint(lim,U.LimAll)end)
 U.LimOnly.Activated:Connect(function()limitedMode="Only";paint(lim,U.LimOnly)end)
 U.LimNo.Activated:Connect(function()limitedMode="Exclude";paint(lim,U.LimNo)end)
 U.FormAll.Activated:Connect(function()formatMode="All";paint(form,U.FormAll)end)
 U.FormClassic.Activated:Connect(function()formatMode="Classic";paint(form,U.FormClassic)end)
 U.Form2D.Activated:Connect(function()formatMode="2D";paint(form,U.Form2D)end)
 U.Form3D.Activated:Connect(function()formatMode="3D";paint(form,U.Form3D)end)
 U.OffSale.Activated:Connect(function()
  includeOffSale=not includeOffSale
  U.OffSale.Text="Fora de venda: "..(includeOffSale and"SIM"or"NÃO")
 end)
 U.ApplyFilter.Activated:Connect(function()U.FilterPanel.Visible=false;search(false)end)
 U.ClearFilter.Activated:Connect(function()
  U.Min.Text="";U.Max.Text="";U.Creator.Text=""
  creatorType="All";limitedMode="All";formatMode="All";includeOffSale=false
  U.CreatorType.Text="Todos os criadores";U.OffSale.Text="Fora de venda: NÃO"
  paint(lim,U.LimAll);paint(form,U.FormAll);search(false)
 end)


 U.DetailClose.Activated:Connect(function()U.Detail.Visible=false;selected=nil end)
 U.Try.Activated:Connect(function()if selected then wearNow(selected,U.Try)end end)
 U.Buy.Activated:Connect(function()
  if not selected then return end
  local _,e=call("PurchaseItem",{
   id=tonumber(selected.Id),kind=A.ItemType(selected)
  })
  if e then toast(e)end
 end)
 U.Favorite.Activated:Connect(function()
  if selected then
   pcall(function()
    Avatar:PromptSetFavorite(tonumber(selected.Id),A.ItemEnum(selected),true)
   end)
  end
 end)
 U.Query.FocusLost:Connect(function(enter)
  if enter then search(false)end
 end)
 U.More.Activated:Connect(function()if not emoteMode then search(true)end end)
 U.Sort.Activated:Connect(function()
  sortIndex=sortIndex%#A.Sorts+1
  local names={"Relevância","Popular","Recente","Favoritos","Menor preço","Maior preço"}
  U.Sort.Text=names[sortIndex]
  search(false)
 end)
 U.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 U.Grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
  if loading or not pages or pages.IsFinished then return end
  local y=U.Grid.CanvasPosition.Y+U.Grid.AbsoluteWindowSize.Y
  if y>U.Grid.AbsoluteCanvasSize.Y-280 then task.defer(function()search(true)end)end
 end)

 local function preset(kind)
  groupIndex=1;subIndex=2;U.Query.Text=""
  if kind=="Emotes"then
   limitedMode="All";formatMode="All";creatorType="All";includeOffSale=false;U.Min.Text="";U.Max.Text="";U.Creator.Text="";U.CreatorType.Text="Todos os criadores";U.OffSale.Text="Fora de venda: NÃO"
   for gi,g in ipairs(A.Groups)do if g.name=="ANIMAÇÕES"then groupIndex=gi;for si,v in ipairs(g.subs)do if v[1]=="EMOTES"then subIndex=si break end end break end end;sortIndex=2
  elseif kind=="Popular"then subIndex=2;sortIndex=2 elseif kind=="New"then subIndex=2;sortIndex=3 elseif kind=="Trending"then subIndex=4;sortIndex=2 elseif kind=="Summer"then U.Query.Text="summer";sortIndex=2 end
  updateMode();U.More.Visible=not emoteMode;local names={"Relevância","Popular","Recente","Favoritos","Menor preço","Maior preço"};U.Sort.Text=names[sortIndex]
  groups();subs();search(false)
 end

 updateMode();groups();subs()
 return{Search=function()search(false)end,Resize=resize,Preset=preset,ShowItem=choose}
end
return M
