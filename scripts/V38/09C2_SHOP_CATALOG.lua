-- 09C2_SHOP_CATALOG
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V38 - catálogo compacto: uma linha de categorias, submenu flutuante, cards limpos e preço confiável.

local Avatar=game:GetService("AvatarEditorService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local Cart=require(Rep:WaitForChild("09C4_OUTFIT_LIBRARY"))
local M={}

function M.Init(ctx)
 local U,A,S,pl=ctx.U,ctx.A,ctx.S,ctx.pl
 local toast,playEmote=ctx.toast,ctx.playEmote
 local pages,selected,currentSub,currentFilter=nil,nil,nil,nil
 local groupIndex,subIndex,sortIndex=1,2,2
 local limitedMode,formatMode,creatorType="All","All","All"
 local includeOffSale,loading,pendingFull=false,false,false
 local totalShown,lastSearchText=0,""
 local emoteMode=false;local oldDateCache={}
 local function clear(p)for _,c in ipairs(p:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end end
 local function resize()
  local w=U.Grid.AbsoluteSize.X;local cols=w>=930 and 6 or w>=720 and 5 or w>=500 and 4 or 3;local gap=8
  local cw=math.floor((w-gap*(cols-1)-10)/cols);cw=math.clamp(cw,112,176)
  U.GridLayout.CellSize=UDim2.fromOffset(cw,math.floor(cw*1.05)+42);U.GridLayout.CellPadding=UDim2.fromOffset(gap,gap)
 end
 local function isEmote(item)local raw=item and item.AssetType;return(typeof(raw)=="EnumItem"and raw==Enum.AvatarAssetType.EmoteAnimation)or tonumber(type(raw)=="table"and(raw.Id or raw.Value)or raw)==Enum.AvatarAssetType.EmoteAnimation.Value end
 local function isBundle(item)return A.ItemType(item)=="Bundle"end
 local function rawPrice(item)
  for _,k in ipairs({"Price","LowestPrice","UnitPrice","BestPrice","FinalPrice","LowestResalePrice"})do local v=item and item[k];local n=tonumber(v);if n then return n end end
  if item and(item.IsFree==true or tostring(item.PriceStatus or""):lower()=="free")then return 0 end;return nil
 end
 local function priceText(item)local p=rawPrice(item);if p==nil then return"VER PREÇO"end;return p<=0 and"GRÁTIS"or tostring(math.floor(p)).." R$"end
 local function assetTypeName(item)local raw=item and item.AssetType;if typeof(raw)=="EnumItem"then return raw.Name end;if type(raw)=="table"then raw=raw.Name or raw.Id end;if tonumber(raw)==Enum.AvatarAssetType.EmoteAnimation.Value then return"EmoteAnimation"end;return tostring(raw or""):match("([%w_]+)$")or""end
 local function updateMode()local g=A.Groups[groupIndex];local sub=g and g.subs[subIndex];emoteMode=g and g.name=="ANIMAÇÕES"and sub and sub[1]=="EMOTES"or false end
 local function pass(item)if emoteMode then return assetTypeName(item)=="EmoteAnimation"end;return A.PostFilter(item,currentSub,currentFilter)end
 local function oldEnough(item,sub)if not sub or not sub.oldBefore then return true end;local id=tonumber(item and item.Id);if not id then return false end;if oldDateCache[id]~=nil then return oldDateCache[id]end;local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end);local y=ok and info and tonumber(tostring(info.Created or info.CreatedAt or""):match("^(%d%d%d%d)"));local yes=y~=nil and y<=tonumber(sub.oldBefore);oldDateCache[id]=yes;return yes end
 local function normalize(v)local s=string.lower(tostring(v or"")):gsub("[%p_]"," "):gsub("%s+"," ");return s:match("^%s*(.-)%s*$")or""end
 local function ranked(items)
  local q=normalize(U.Query.Text);if q==""then return items or{}end;local scored={}
  for _,it in ipairs(items or{})do local n=normalize(it.Name);local sc=n==q and 10000 or n:find(q,1,true)and 8500 or 0;if sc==0 then local hit,total=0,0;for w in q:gmatch("%S+")do if #w>=2 then total=total+1;if n:find(w,1,true)then hit=hit+1 end end end;if total>0 and hit==total then sc=7000+hit elseif total>=3 and hit>=math.ceil(total*.75)then sc=4000+hit end end;if sc>0 then table.insert(scored,{item=it,score=sc})end end
  table.sort(scored,function(a,b)if a.score~=b.score then return a.score>b.score end;return tostring(a.item.Name or"")<tostring(b.item.Name or"")end);local out={};for _,v in ipairs(scored)do table.insert(out,v.item)end;return out
 end
 local function paidFirst(items)if currentFilter and currentFilter.freeCategory then return items end;local paid,unknown,free={},{},{};for _,it in ipairs(items or{})do local p=rawPrice(it);if p==nil then table.insert(unknown,it)elseif p<=0 then table.insert(free,it)else table.insert(paid,it)end end;for _,it in ipairs(unknown)do table.insert(paid,it)end;for _,it in ipairs(free)do table.insert(paid,it)end;return paid end
 local function wear(item,ref)
  if isEmote(item)then if not playEmote then toast("Prévia de emote indisponível.");return end;local ok,e=playEmote(tonumber(item.Id));toast(ok and"Emote tocando na prévia."or e);return end
  local old=ref and ref.Text;if ref then ref.Text=isBundle(item)and"CARREGANDO..."or"VESTINDO..."end;local ok,e=S.Try(item)
  if ok then toast(isBundle(item)and"Skin 3D carregada na prévia."or"Item vestido na prévia.")else toast(e)end;if ref and ref.Parent then ref.Text=old or"EXPERIMENTAR"end
 end
 local function choose(item)
  selected=item;U.Detail.Visible=true;U.DetailImage.Image=A.Thumbnail(item,420);U.DetailName.Text=tostring(item.Name or"Item");U.DetailPrice.Text=priceText(item)
  U.Try.Text=isEmote(item)and"TESTAR EMOTE"or isBundle(item)and"USAR SKIN 3D"or"EXPERIMENTAR";U.Buy.Text="+ CARRINHO"
 end
 local function addCard(item,checked)
  if not pass(item)or(not checked and not oldEnough(item,currentSub))then return 0 end;totalShown=totalShown+1
  local c=U.Button(U.Grid,"",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(34,35,39),AutoButtonColor=false});c.Text="";U.Round(c,10);U.New("UIStroke",{Color=Color3.fromRGB(72,74,79),Transparency=.67,Thickness=1},c)
  local im=U.New("ImageLabel",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-42),BackgroundColor3=Color3.fromRGB(49,50,55),BorderSizePixel=0,Image=A.Thumbnail(item,420),ScaleType=Enum.ScaleType.Fit},c);U.Round(im,8)
  U.Text(c,tostring(item.Name or"Item"),{Position=UDim2.new(0,8,1,-34),Size=UDim2.new(1,-16,0,17),Font=Enum.Font.GothamBold,TextSize=7,TextColor3=U.Colors.white,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  local dot=U.New("Frame",{Position=UDim2.new(0,8,1,-14),Size=UDim2.fromOffset(6,6),BackgroundColor3=U.Colors.green,BorderSizePixel=0},c);U.Round(dot,99)
  U.Text(c,priceText(item),{Position=UDim2.new(0,18,1,-19),Size=UDim2.new(1,-26,0,15),TextColor3=Color3.fromRGB(221,225,230),Font=Enum.Font.GothamBold,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
  c.Activated:Connect(function()choose(item)end);return 1
 end
 local function draw(items,append)
  if not append then clear(U.Grid);U.Grid.CanvasPosition=Vector2.zero;totalShown=0 end;local list=paidFirst(ranked(items or{}));local n=0
  if currentSub and currentSub.oldBefore then local passOld={};local waiting=0;for i,it in ipairs(list)do waiting=waiting+1;task.spawn(function()passOld[i]=oldEnough(it,currentSub);waiting=waiting-1 end)end;while waiting>0 do task.wait()end;for i,it in ipairs(list)do if emoteMode and n>=12 then break end;if passOld[i]then n=n+addCard(it,true)end end else for _,it in ipairs(list)do if emoteMode and n>=12 then break end;n=n+addCard(it,true)end end;resize();return n
 end
 local function status()local q=normalize(U.Query.Text);if q~=""then U.Status.Text=totalShown==0 and"Nenhum resultado relacionado."or(totalShown.." resultado(s) relacionados")elseif totalShown==0 then U.Status.Text=emoteMode and"Nenhum emote encontrado."or"Nenhum item encontrado."elseif emoteMode then U.Status.Text=totalShown.." emotes • toque em um card para testar"else U.Status.Text=totalShown.." itens • toque para abrir detalhes"end end
 local function fill(target,maxPages)local tries=0;while pages and totalShown<target and not pages.IsFinished and tries<(maxPages or 3)do tries=tries+1;local ok=pcall(function()pages:AdvanceToNextPageAsync()end);if not ok then break end;draw(pages:GetCurrentPage(),true)end end
 local function search(append)
  if loading then if not append then pendingFull=true end;return end;loading=true;U.Status.Text="Carregando..."
  if append and pages then if pages.IsFinished then status();loading=false;return end;local ok=pcall(function()pages:AdvanceToNextPageAsync()end);if ok then draw(pages:GetCurrentPage(),true);fill(totalShown+10,2);status()else toast("Não consegui carregar mais itens.")end;loading=false;return end
  local typed=normalize(U.Query.Text);if typed~=""and typed~=lastSearchText then sortIndex=1;U.Sort.Text="RELEVÂNCIA"end;lastSearchText=typed
  local ok,res=pcall(function()updateMode();local gi,si=groupIndex,subIndex;if typed~=""then gi,si=1,1 end;local p,sub,f=A.BuildParams(gi,si,U.Query.Text,sortIndex,U.Min.Text,U.Max.Text,U.Creator.Text,creatorType,"All",limitedMode,formatMode,includeOffSale);if typed~=""then p.SearchKeyword=typed:sub(1,100)end;if f and not f.freeCategory and normalize(U.Min.Text)==""then p.MinPrice=1 end;if emoteMode then local lo=tonumber(U.Min.Text);local hi=tonumber(U.Max.Text);p.MinPrice=math.max(1,math.floor(lo or 1));p.MaxPrice=math.max(p.MinPrice,math.floor(hi or 2147483647));p.AssetTypes={Enum.AvatarAssetType.EmoteAnimation}end;currentSub,currentFilter=sub,f;pages=Avatar:SearchCatalogAsync(p);return pages:GetCurrentPage()end)
  if ok then draw(res,false);U.More.Visible=not emoteMode;if not emoteMode then fill(typed~=""and 12 or 18,typed~=""and 6 or 4)end;status()else clear(U.Grid);U.Status.Text="Busca indisponível.";toast("O catálogo não respondeu.")end;loading=false;if pendingFull then pendingFull=false;task.defer(function()search(false)end)end
 end

 local groupLabels={TODOS="TUDO",ROUPAS="ROUPAS",["ACESSÓRIOS"]="ACESSÓRIOS",["CABEÇA E ROSTO"]="CABEÇA",CORPO="CORPO",["ANIMAÇÕES"]="EMOTES",LIMITEDS="LIMITED",["GRÁTIS"]="GRÁTIS",GEAR="GEAR",EXTRAS="BUNDLES"}
 local subLabels={['MARKETPLACE INTEIRO']='EXPLORAR',['DESTAQUES']='EM ALTA',['RECOMENDADOS']='PARA VOCÊ',['COMUNIDADE']='CRIADORES',['TEMPO LIMITADO']='LIMITADOS'}
 local groups,subs
 groups=function()
  clear(U.Groups)
  for i,g in ipairs(A.Groups)do local s=groupLabels[g.name]or g.name;local b=U.Button(U.Groups,s,{Size=UDim2.fromOffset(math.clamp(#s*5+18,48,104),26),BackgroundColor3=i==groupIndex and Color3.fromRGB(67,70,77)or Color3.fromRGB(38,40,44),TextSize=7,TextWrapped=false});b.Activated:Connect(function()groupIndex=i;subIndex=i==1 and math.min(2,#g.subs)or 1;updateMode();groups();subs();search(false);if U.SubsPopup then U.SubsPopup.Visible=#g.subs>1 end end)end
 end
 subs=function()
  clear(U.Subs);local g=A.Groups[groupIndex];if not g then return end
  local current=g.subs[subIndex];local currentName=current and(subLabels[current[1]]or current[1])or"CATEGORIA";if U.SubToggle then U.SubToggle.Text=currentName end
  for i,v in ipairs(g.subs)do local s=subLabels[v[1]]or v[1];local b=U.Button(U.Subs,s,{BackgroundColor3=i==subIndex and Color3.fromRGB(68,71,78)or Color3.fromRGB(40,42,47),TextSize=6,TextWrapped=true});b.Activated:Connect(function()subIndex=i;updateMode();subs();if U.SubsPopup then U.SubsPopup.Visible=false end;search(false)end)end
 end
 if U.SubToggle then U.SubToggle.Activated:Connect(function()if U.SubsPopup then U.SubsPopup.Visible=not U.SubsPopup.Visible end end)end

 local function paint(arr,on)for _,b in ipairs(arr)do b.BackgroundColor3=U.Colors.card end;on.BackgroundColor3=U.Colors.soft end
 local lim={U.LimAll,U.LimOnly,U.LimNo};local form={U.FormAll,U.FormClassic,U.Form2D,U.Form3D}
 U.Filter.Activated:Connect(function()U.FilterPanel.Visible=not U.FilterPanel.Visible;if U.SubsPopup then U.SubsPopup.Visible=false end end);U.CloseFilter.Activated:Connect(function()U.FilterPanel.Visible=false end)
 U.CreatorType.Activated:Connect(function()local a={"All","User","Group"};creatorType=a[(table.find(a,creatorType)or 1)%3+1];U.CreatorType.Text=creatorType=="All"and"Todos criadores"or creatorType=="User"and"Usuários"or"Grupos"end)
 U.LimAll.Activated:Connect(function()limitedMode="All";paint(lim,U.LimAll)end);U.LimOnly.Activated:Connect(function()limitedMode="Only";paint(lim,U.LimOnly)end);U.LimNo.Activated:Connect(function()limitedMode="Exclude";paint(lim,U.LimNo)end)
 U.FormAll.Activated:Connect(function()formatMode="All";paint(form,U.FormAll)end);U.FormClassic.Activated:Connect(function()formatMode="Classic";paint(form,U.FormClassic)end);U.Form2D.Activated:Connect(function()formatMode="2D";paint(form,U.Form2D)end);U.Form3D.Activated:Connect(function()formatMode="3D";paint(form,U.Form3D)end)
 U.OffSale.Activated:Connect(function()includeOffSale=not includeOffSale;U.OffSale.Text="Fora de venda: "..(includeOffSale and"SIM"or"NÃO")end);U.ApplyFilter.Activated:Connect(function()U.FilterPanel.Visible=false;search(false)end);U.ClearFilter.Activated:Connect(function()U.Min.Text="";U.Max.Text="";U.Creator.Text="";creatorType="All";limitedMode="All";formatMode="All";includeOffSale=false;U.CreatorType.Text="Todos criadores";U.OffSale.Text="Fora de venda: NÃO";paint(lim,U.LimAll);paint(form,U.FormAll);search(false)end)
 U.DetailClose.Activated:Connect(function()U.Detail.Visible=false;selected=nil end);U.Try.Activated:Connect(function()if selected then wear(selected,U.Try)end end);U.Buy.Activated:Connect(function()if selected then Cart.Add(selected)end end);U.Favorite.Activated:Connect(function()if selected then pcall(function()Avatar:PromptSetFavorite(tonumber(selected.Id),A.ItemEnum(selected),true)end)end end)
 U.Query.FocusLost:Connect(function(enter)if enter then search(false)end end);U.More.Activated:Connect(function()if not emoteMode then search(true)end end);U.Sort.Activated:Connect(function()sortIndex=sortIndex%#A.Sorts+1;local names={"RELEVÂNCIA","POPULAR","RECENTE","FAVORITOS","MENOR PREÇO","MAIOR PREÇO"};U.Sort.Text=names[sortIndex];search(false)end)
 U.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);U.Grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()if loading or not pages or pages.IsFinished then return end;local y=U.Grid.CanvasPosition.Y+U.Grid.AbsoluteWindowSize.Y;if y>U.Grid.AbsoluteCanvasSize.Y-280 then task.defer(function()search(true)end)end end)
 local function preset(kind)groupIndex=1;subIndex=2;U.Query.Text="";if kind=="Emotes"then for gi,g in ipairs(A.Groups)do if g.name=="ANIMAÇÕES"then groupIndex=gi;for si,v in ipairs(g.subs)do if v[1]=="EMOTES"then subIndex=si break end end break end end;sortIndex=2 elseif kind=="Popular"then sortIndex=2 elseif kind=="New"then sortIndex=3 elseif kind=="Trending"then subIndex=4;sortIndex=2 end;updateMode();groups();subs();if U.SubsPopup then U.SubsPopup.Visible=false end;search(false)end
 updateMode();groups();subs();resize()
 return{Search=function()search(false)end,Resize=resize,Preset=preset,ShowItem=choose,OpenCart=Cart.Open}
end
return M
