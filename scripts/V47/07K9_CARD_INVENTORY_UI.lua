-- 07K9_CARD_INVENTORY_UI | ModuleScript | ReplicatedStorage | V47
-- Páginas fixas, compras ao lado da prévia e Ateliê sem rolagem.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Catalog=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local UIS=game:GetService("UserInputService")
local Market=game:GetService("MarketplaceService")
local Content=game:GetService("ContentProvider")
local M={}
local function imageID(text)
 text=tostring(text or""):sub(1,240);local id=tonumber(text)or tonumber(text:match("rbxassetid://(%d+)")or text:match("[?&]id=(%d+)")or text:match("/library/(%d+)")or text:match("/catalog/(%d+)")or text:match("/assets?/(%d+)"))
 return id and id>0 and id<math.huge and id%1==0 and id or 0
end
function M.Build(gui,call,toast)
 local U={Tab="Loja",Data=nil,Store=nil,Style="Classic",Back=false,Page=1,Capacity=6,Selected=nil}
 local safe=Bounds.Bind(gui);local storeToken=0;local priceCache={};local entries={};local slots={};local tabs={}
 local function clear(p)for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end end
 local function nativePrice(id,kind)
  if type(id)~="number"or id<=0 then return{sale=false}end
  local key=kind..id;local old=priceCache[key];if old and os.clock()-old.time<30 then return old.data end
  local ok,d=pcall(function()return Market:GetProductInfoAsync(id,kind=="pass"and Enum.InfoType.GamePass or Enum.InfoType.Product)end)
  local price=ok and type(d)=="table"and d.PriceInRobux
  local valid=type(price)=="number"and price==price and price>=0 and price<math.huge
  local p={sale=valid and d.IsForSale==true or false,price=valid and price or nil}
  if ok then priceCache[key]={time=os.clock(),data=p}end;return p
 end
 U.Root=D.New("Frame",{Name="CardInventory",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false},gui)
 U.Title=D.Text(U.Root,"Cartas",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,"CloseInventory","close","Fechar inventário",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 U.Coins=D.Text(U.Root,"",{TextColor3=C.yellow,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,TextWrapped=false})
 U.Tabs=D.New("Frame",{BackgroundTransparency=1},U.Root)
 for i,key in ipairs({"Loja","Visuais","Caixas","Ateliê"})do local b=D.Button(U.Tabs,({Loja="Loja",Visuais="Meus visuais",Caixas="Minhas caixas",["Ateliê"]="Ateliê"})[key],{TextSize=12});b:SetAttribute("TabKey",key);tabs[i]=b
  b.Activated:Connect(function()if U.Tab~=key then U.Tab=key;U.Page=1;U.Selected=nil;U.Render()end end)
 end
 U.Preview=D.Frame(U.Root,{BackgroundColor3=C.panel})
 U.PreviewName=D.Text(U.Preview,"Clássico",{Font=Enum.Font.GothamBold,TextSize=18,AutoLocalize=false})
 U.CardHost=D.New("Frame",{BackgroundTransparency=1},U.Preview)
 U.Flip=D.Button(U.Preview,"Ver verso",{TextSize=13})
 U.Note=D.Text(U.Preview,"",{TextColor3=C.muted,TextSize=13})
 U.CoinBuy=D.Button(U.Preview,"",{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=13})
 U.RobuxBuy=D.Button(U.Preview,"",{TextSize=13,AutoLocalize=false})
 U.List=D.New("Frame",{Name="InventoryItems",BackgroundTransparency=1,ClipsDescendants=true},U.Root)
 U.Pager=D.New("Frame",{BackgroundTransparency=1},U.Root)
 U.Previous=D.Button(U.Pager,"‹",{TextSize=26});U.Next=D.Button(U.Pager,"›",{TextSize=26})
 U.PageLabel=D.Text(U.Pager,"",{TextColor3=C.muted,TextSize=13})
 U.Empty=D.Text(U.List,"",{Size=UDim2.fromScale(1,1),TextColor3=C.muted})
 U.Atelier=D.Frame(U.Root,{Name="AtelierEditor",BackgroundColor3=C.panel,Visible=false})
 U.CustomID=D.Box(U.Atelier,"ID ou link da imagem/decal",{Name="CustomImageID",TextSize=14})
 U.LoadImage=D.Button(U.Atelier,"Carregar",{Name="LoadCardImage",TextSize=12,BackgroundColor3=C.blue})
 U.ReloadImage=D.Button(U.Atelier,"Recarregar",{Name="ReloadCardImage",TextSize=12})
 U.ImageStatus=D.Text(U.Atelier,"",{TextColor3=C.muted,TextSize=13})
 U.CustomPreview=D.New("Frame",{Name="CustomCardPreview",BackgroundTransparency=1,Active=true},U.Atelier)
 U.Minus=D.Button(U.Atelier,"− zoom",{TextSize=13});U.Plus=D.Button(U.Atelier,"+ zoom",{TextSize=13})
 U.Center=D.Button(U.Atelier,"Centralizar",{TextSize=13});U.CustomFlip=D.Button(U.Atelier,"Ver verso",{TextSize=13})
 U.SaveCustom=D.Button(U.Atelier,"Salvar e equipar",{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=14})
 U.Editor={image=0,zoom=1,x=0,y=0};local editorOwner;local imageConnection;local imageToken=0;local artwork
 U.Dialog=D.Frame(U.Root,{Name="OpenBox",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Visible=false,ZIndex=60})
 U.DialogTitle=D.Text(U.Dialog,"",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-74,0,48),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=61,AutoLocalize=false})
 U.DialogClose=D.IconButton(U.Dialog,"CloseBox","close","Fechar caixa",{Position=UDim2.new(1,-56,0,4),Size=UDim2.fromOffset(48,48),ZIndex=70})
 U.Choices=D.New("Frame",{Position=UDim2.fromOffset(10,60),Size=UDim2.new(1,-20,1,-124),BackgroundTransparency=1,ZIndex=61},U.Dialog)
 U.Open=D.Button(U.Dialog,"Escolha seus visuais",{Position=UDim2.new(0,10,1,-54),Size=UDim2.new(1,-20,0,44),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=62})
 U.DialogClose.Activated:Connect(function()U.Dialog.Visible=false;U.Skip=true end)
 function U.SetPreview(style,custom,box)
  U.Style=style;U.PreviewCustom=custom;U.BoxPreview=box;clear(U.CardHost)
  if box then Cards.RenderBox(U.CardHost,box,{Size=UDim2.fromScale(1,1)})
  else Cards.Render(U.CardHost,not U.Back and{rank="A",suit="S"}or nil,style,{Size=UDim2.fromScale(1,1)},custom or U.Data and U.Data.custom)end
  U.Flip.Visible=box==nil
  U.PreviewName.Text=Catalog.Name(style);U.Flip.Text=U.Back and"Ver frente"or"Ver verso"
 end
 U.Flip.Activated:Connect(function()U.Back=not U.Back;U.SetPreview(U.Style,U.PreviewCustom)end)
 local function refresh()local d,e=call("inventory");if d then U.Data=d;U.Render()elseif e then toast(e)end end
 local function buy(kind,key)local d,e=call("buycoins",{kind=kind,key=key,quantity=1});toast(d and"Compra adicionada ao inventário."or e);if d then refresh()end end
 local function prompt(kind,key)local d,e=call("prompt",{kind=kind,key=key});if not d then toast(e)end end
 local function storeEntry(e)
  local id=not e.box and Catalog.PassFor(e.key)
  return id and U.Store and U.Store.passes[tostring(id)]or U.Store and U.Store.products[e.key],id
 end
 local function details(e)
  U.Selected=e;U.SetPreview(e.style or e.key,nil,e.box and e.key or nil);U.CoinBuy.Visible=e~=nil;U.RobuxBuy.Visible=U.Tab=="Loja"
  if e.box then U.PreviewName.Text="Caixa "..e.key end
  if U.Tab=="Caixas"then U.Note.Text=(U.Data.boxes[e.key]or 0).." caixa(s) • escolha garantida";U.CoinBuy.Text="Escolher e abrir";D.SetEnabled(U.CoinBuy,(U.Data.boxes[e.key]or 0)>0)
  elseif U.Tab=="Visuais"then U.Note.Text="Frente e verso • cosmético permanente";U.CoinBuy.Text=U.Data.equipped==e.key and"Equipado"or"Equipar";D.SetEnabled(U.CoinBuy,U.Data.equipped~=e.key)
  else
   local covered=not e.box and Catalog.Covered(U.Data,e.key);local owned=not e.box and U.Data.owned[e.key]
   local remaining=0;if e.box then for _,s in ipairs(e.skins)do if not U.Data.owned[s]then remaining=remaining+1 end end;covered=remaining<=(U.Data.boxes[e.key]or 0)end
   U.Note.Text=e.box and"1 caixa = 1 visual à escolha. Abra em Minhas caixas."or"Compra permanente · frente e verso da carta. Equipe em Meus visuais."
   U.CoinBuy.Text=owned and"Já possui"or covered and"Abra em Minhas caixas"or("Comprar · "..e.coins.." moedas")
   D.SetEnabled(U.CoinBuy,not owned and not covered and U.Data.coins>=e.coins)
   local p=storeEntry(e);U.RobuxBuy.Text=p and p.sale and("Comprar · "..p.price.." Robux")or p and p.pending and"Consultando Robux"or"Robux indisponível"
   D.SetEnabled(U.RobuxBuy,p and p.sale and not owned and not covered)
  end
 end
 function U.OpenBox(box)
  U.Dialog.Visible=true;U.DialogTitle.Text=box.id.." • escolha garantida";clear(U.Choices);U.Skip=false
  local selected={};local buttons={}
  local function paint()
   local n=0;for _,style in ipairs(box.skins)do local own=U.Data.owned[style];local on=selected[style]
    buttons[style].Text=Catalog.Name(style)..(own and" ✓"or on and" ✓"or"");buttons[style].BackgroundColor3=on and C.green or C.card;if on then n=n+1 end
   end
   U.Open.Text=n==0 and"Selecione os visuais"or"Abrir "..n.." caixa(s) • "..n.." visual(is)";D.SetEnabled(U.Open,n>0 and n<=(U.Data.boxes[box.id]or 0))
  end
  for i,style in ipairs(box.skins)do
   Cards.Render(U.Choices,{rank="A",suit="S"},style,{Position=UDim2.new((i-1)/3,4,0,0),Size=UDim2.new(1/3,-8,1,-46),ZIndex=62})
   local b=D.Button(U.Choices,Catalog.Name(style),{Position=UDim2.new((i-1)/3,4,1,-44),Size=UDim2.new(1/3,-8,0,44),ZIndex=65,AutoLocalize=false,TextSize=13});buttons[style]=b
   D.SetEnabled(b,not U.Data.owned[style]);b.Activated:Connect(function()selected[style]=not selected[style];U.SetPreview(style);paint()end)
  end
  if U.OpenConnection then U.OpenConnection:Disconnect()end;if U.SkipConnection then U.SkipConnection:Disconnect();U.SkipConnection=nil end
  U.OpenConnection=U.Open.Activated:Connect(function()
   local styles={};for _,style in ipairs(box.skins)do if selected[style]then table.insert(styles,style)end end
   D.SetEnabled(U.Open,false);local result,e=call("openbox",{key=box.id,styles=styles});if not result then toast(e);paint();return end
   U.OpenConnection:Disconnect();U.OpenConnection=nil;clear(U.Choices);U.DialogTitle.Text="Seus visuais";U.Open.Text="Pular animação";U.Skip=false
   U.SkipConnection=U.Open.Activated:Connect(function()U.Skip=true end);D.SetEnabled(U.Open,true)
   for _,style in ipairs(result.styles)do if not U.Skip and U.Dialog.Visible then
    local name=D.Text(U.Choices,Catalog.Name(style),{Size=UDim2.fromScale(1,1),TextSize=28,Font=Enum.Font.GothamBold,ZIndex=66,AutoLocalize=false})
    for _=1,12 do if U.Skip or not U.Dialog.Visible then break end;task.wait(.04)end;name:Destroy()
   end end
   clear(U.Choices);for i,style in ipairs(result.styles)do Cards.Render(U.Choices,{rank="A",suit="S"},style,{Position=UDim2.new((i-1)/#result.styles,4,0,0),Size=UDim2.new(1/#result.styles,-8,1,0),ZIndex=62})end
   U.SkipConnection:Disconnect();U.SkipConnection=nil;U.Open.Text="Adicionados ao inventário";D.SetEnabled(U.Open,false);refresh()
  end);paint();U.Layout()
 end
 U.CoinBuy.Activated:Connect(function()
  local e=U.Selected;if not e then return end
  if U.Tab=="Caixas"then U.OpenBox(Catalog.Collection(e.key))elseif U.Tab=="Visuais"then
   if e.key=="Custom"and(tonumber(U.Data.custom.image)or 0)<1 then U.Tab="Ateliê";U.Render();return end
   local d,err=call("equip",{style=e.key});if d then refresh()else toast(err)end
  elseif U.Tab=="Loja"then buy(e.box and"box"or"style",e.key)end
 end)
 U.RobuxBuy.Activated:Connect(function()local e=U.Selected;if not e then return end;local _,id=storeEntry(e);prompt(id and"pass"or"product",id or e.key)end)
 local artworkRoot;local activeImage=-1;local validatedImage=0;local imageReady=false
 local function editorPaint(force)
  local e=U.Editor;local id=imageID(U.CustomID.Text)
  if id~=activeImage then e.thumb=false;e.texture=0;force=true end
  e.image=id;local limit=(e.zoom-1)/2;e.x=math.clamp(e.x,-limit,limit);e.y=math.clamp(e.y,-limit,limit)
  U.CustomFlip.Text=U.Back and"Ver frente"or"Ver verso"
  if not force and id==activeImage then
   if artwork then artwork.Position=UDim2.fromScale(.5+e.x,.5+e.y);artwork.Size=UDim2.fromScale(e.zoom,e.zoom)end;return
  end
  activeImage=id;imageToken=imageToken+1;local token=imageToken;validatedImage=0;imageReady=false
  if imageConnection then imageConnection:Disconnect();imageConnection=nil end
  clear(U.CustomPreview);artwork=nil;artworkRoot=nil;if U.Data.ateliers then D.SetEnabled(U.SaveCustom,false)end
  if id<1 then U.ImageStatus.Text="Cole o ID da imagem publicada e pressione Carregar.";return end
  U.ImageStatus.Text="Verificando o ID no Roblox…";local expired=false
  task.delay(12,function()if token==imageToken and validatedImage==0 then expired=true;U.ImageStatus.Text="O Roblox demorou. Pressione Recarregar."end end)
  task.spawn(function()
   local meta,err=call("image",{image=id})
   if token~=imageToken or expired or not U.Root.Visible then return end
   if not meta or meta.image~=id or(meta.assetType~=1 and meta.assetType~=13)then U.ImageStatus.Text=err or"Use um ID de imagem ou decal, e pressione Recarregar.";return end
   validatedImage=id;e.texture=meta.texture or 0
   artworkRoot=Cards.Render(U.CustomPreview,not U.Back and{rank="A",suit="S"}or nil,"Custom",{Size=UDim2.fromScale(1,1)},e)
   artwork=artworkRoot:FindFirstChild("CustomArtwork");if not artwork then return end
   local picture=artwork;local complete=false;U.ImageStatus.Text="Carregando sua imagem na carta…"
   local function check()
    if token~=imageToken or picture~=artwork or not picture.Parent then return end
    if picture.IsLoaded then complete=true;imageReady=true;U.ImageStatus.Text="Imagem aplicada · ajuste e pressione Salvar e equipar";if U.Data.ateliers then D.SetEnabled(U.SaveCustom,true)end end
   end
   imageConnection=picture:GetPropertyChangedSignal("IsLoaded"):Connect(check)
   local function preload()task.spawn(function()pcall(function()Content:PreloadAsync({picture})end);check()end)end
   preload();check()
   task.delay(8,function()
    if token~=imageToken or complete then return end
    e.thumb=true;picture.Image="rbxthumb://type=Asset&id="..id.."&w=420&h=420";U.ImageStatus.Text="Carregando a imagem alternativa do Roblox…";preload();check()
    task.delay(8,function()if token==imageToken and not complete then imageReady=false;U.ImageStatus.Text="A imagem não carregou. Confira a publicação e pressione Recarregar.";if U.Data.ateliers then D.SetEnabled(U.SaveCustom,false)end end end)
   end)
  end)
 end
 U.LoadImage.Activated:Connect(function()editorPaint(true)end)
 U.ReloadImage.Activated:Connect(function()editorPaint(true)end)
 U.CustomID.FocusLost:Connect(function(enter)if enter then editorPaint(true)end end)
 U.Minus.Activated:Connect(function()U.Editor.zoom=math.max(1,U.Editor.zoom-.1);editorPaint()end)
 U.Plus.Activated:Connect(function()U.Editor.zoom=math.min(2,U.Editor.zoom+.1);editorPaint()end)
 U.Center.Activated:Connect(function()U.Editor.x=0;U.Editor.y=0;editorPaint()end)
 U.CustomFlip.Activated:Connect(function()U.Back=not U.Back;editorPaint(true)end)
 local drag,origin,startX,startY
 U.CustomPreview.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=i;origin=i.Position;startX,startY=U.Editor.x,U.Editor.y end end)
 local moving=UIS.InputChanged:Connect(function(i)if drag and(i==drag or i.UserInputType==Enum.UserInputType.MouseMovement)then
  local delta=i.Position-origin;U.Editor.x=startX+delta.X/math.max(1,U.CustomPreview.AbsoluteSize.X);U.Editor.y=startY+delta.Y/math.max(1,U.CustomPreview.AbsoluteSize.Y);editorPaint()
 end end)
 local ending=UIS.InputEnded:Connect(function(i)if i==drag or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end end)
 U.SaveCustom.Activated:Connect(function()
  if not U.Data.ateliers then prompt("pass",Catalog.CustomPass);return end
  if validatedImage~=imageID(U.CustomID.Text)or not imageReady or not artwork or not artwork.IsLoaded then toast("Pressione Carregar e espere sua imagem aparecer na carta.");return end
  local d,e=call("custom",U.Editor);toast(d and"Visual salvo e equipado nas suas cartas."or e);if d then editorOwner=nil;refresh()end
 end)
 local function collect()
  entries={}
  if U.Tab=="Caixas"or U.Tab=="Loja"then for _,b in ipairs(Catalog.Collections)do table.insert(entries,{key=b.id,style=b.skins[1],box=true,coins=b.coins,skins=b.skins})end end
  if U.Tab=="Visuais"or U.Tab=="Loja"then local keys={};for key in pairs(Catalog.Styles)do if U.Tab=="Visuais"and U.Data.owned[key]or U.Tab=="Loja"and key~="Classic"then table.insert(keys,key)end end;table.sort(keys)
   if U.Tab=="Visuais"and U.Data.ateliers then table.insert(keys,"Custom")end
   for _,key in ipairs(keys)do table.insert(entries,{key=key,coins=Catalog.Styles[key]and Catalog.Styles[key].coins or 0})end
  end
 end
 function U.PaintPage()
  U.Layout()
  clear(U.List);slots={};local pages=math.max(1,math.ceil(#entries/U.Capacity));U.Page=math.clamp(U.Page,1,pages)
  U.PageLabel.Text=U.Page.." / "..pages;D.SetEnabled(U.Previous,U.Page>1);D.SetEnabled(U.Next,U.Page<pages)
  U.Empty=D.Text(U.List,#entries==0 and"Seus visuais aparecerão aqui."or"",{Size=UDim2.fromScale(1,1),Visible=#entries==0,TextColor3=C.muted})
  for i=(U.Page-1)*U.Capacity+1,math.min(#entries,U.Page*U.Capacity)do local e=entries[i]
   local b=D.Button(U.List,"",{Name=e.key,BackgroundColor3=U.Selected and U.Selected.key==e.key and C.soft or C.panel});local padding=b:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
   local host=D.New("Frame",{Name="StyleThumbnail",BackgroundTransparency=1,Active=false},b)
   if e.box then Cards.RenderBox(host,e.key,{Size=UDim2.fromScale(1,1)})else Cards.Render(host,{rank="A",suit="H"},e.key,{Size=UDim2.fromScale(1,1)},U.Data.custom)end
   local label=D.Text(b,e.box and("Caixa "..e.key)or Catalog.Name(e.key),{TextSize=13,Font=Enum.Font.GothamBold,AutoLocalize=false,Active=false,TextWrapped=false})
   slots[#slots+1]={root=b,host=host,label=label,box=e.box};b.Activated:Connect(function()details(e);U.PaintPage()end)
  end
  U.Layout()
 end
 U.Previous.Activated:Connect(function()U.Page=U.Page-1;U.PaintPage()end);U.Next.Activated:Connect(function()U.Page=U.Page+1;U.PaintPage()end)
 function U.Render()
  if not U.Data then return end;U.Coins.Text=U.Data.coins.." moedas"
  for _,b in ipairs(tabs)do b.BackgroundColor3=b:GetAttribute("TabKey")==U.Tab and C.soft or C.card end
  local edit=U.Tab=="Ateliê";U.Atelier.Visible=edit;U.List.Visible=not edit;U.Pager.Visible=not edit;U.Preview.Visible=not edit
  if edit then
   if editorOwner~=U.Data.custom then editorOwner=U.Data.custom;U.Editor={image=U.Data.custom.image or 0,texture=U.Data.custom.texture or 0,zoom=U.Data.custom.zoom or 1,x=U.Data.custom.x or 0,y=U.Data.custom.y or 0,thumb=U.Data.custom.thumb==true};activeImage=U.Editor.image;U.CustomID.Text=U.Editor.image>0 and tostring(U.Editor.image)or"";editorPaint(true)end
   editorPaint();U.SaveCustom.Text="Salvar e equipar"
   if not U.Data.ateliers then local p=U.Store and U.Store.passes[tostring(Catalog.CustomPass)];U.SaveCustom.Text=p and p.sale and("Ateliê • "..p.price.." Robux")or"Ateliê indisponível";D.SetEnabled(U.SaveCustom,p and p.sale)end
  else
   collect();local keep=U.Selected and U.Selected.key;local pick=entries[1]
   for _,e in ipairs(entries)do if e.key==keep then pick=e;break end end
   if pick then details(pick)else U.Selected=nil;U.CoinBuy.Visible=false;U.RobuxBuy.Visible=false end;U.PaintPage()
  end
  U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local y=safe.Heading(U.Title,U.Close);local aw=w-il-ir
  Bounds.Rect(U.Title,il+8,it+4,math.min(132,aw-130),48);Bounds.Rect(U.Coins,il+142,it+4,aw-206,48)
  Bounds.Rect(U.Tabs,il+8,y,aw-16,44);for i,b in ipairs(tabs)do Bounds.Rect(b,(i-1)*(aw-12)/4,0,(aw-28)/4,44)end
  local top=y+52;local ah=h-ib-top-8;local wide=aw>=620;local pw=wide and math.min(330,aw*.36)or aw-16
  local lh=wide and ah-50 or math.floor(ah*.48);local lx=wide and il+pw+16 or il+8;local lw=wide and aw-pw-24 or aw-16
  Bounds.Rect(U.List,lx,top,lw,lh);Bounds.Rect(U.Pager,lx,top+lh+6,lw,44)
  Bounds.Rect(U.Previous,0,0,48,44);Bounds.Rect(U.Next,lw-48,0,48,44);Bounds.Rect(U.PageLabel,54,0,lw-108,44)
  local ph=wide and ah or ah-lh-56;Bounds.Rect(U.Preview,il+8,wide and top or top+lh+56,pw,ph)
  if wide and ph>=260 then
   Bounds.Rect(U.PreviewName,8,6,pw-16,28);local cardH=math.max(50,ph-184);local cardW=math.min(pw-24,cardH*(U.BoxPreview and 1.1 or .70))
   Bounds.Rect(U.CardHost,(pw-cardW)/2,40,cardW,cardH);Bounds.Rect(U.Flip,8,ph-136,pw-16,40);Bounds.Rect(U.Note,8,ph-94,pw-16,38)
   Bounds.Rect(U.CoinBuy,8,ph-52,(pw-22)/2,44);Bounds.Rect(U.RobuxBuy,pw/2+3,ph-52,(pw-22)/2,44)
   if not U.RobuxBuy.Visible then Bounds.Rect(U.CoinBuy,8,ph-52,pw-16,44)end
  else
   local cw=math.min(wide and 130 or 94,math.max(44,(ph-12)*(U.BoxPreview and 1.1 or .70)));Bounds.Rect(U.CardHost,6,6,cw,math.max(50,ph-12))
   local tx=cw+14;local tw=pw-tx-8;Bounds.Rect(U.PreviewName,tx,2,tw,24);Bounds.Rect(U.Flip,tx+tw-80,28,80,36);Bounds.Rect(U.Note,tx,28,tw-84,36)
   if wide then Bounds.Rect(U.Note,tx,28,tw,28);Bounds.Rect(U.Flip,tx,62,tw,44)end
   Bounds.Rect(U.CoinBuy,tx,ph-50,U.RobuxBuy.Visible and(tw-6)/2 or tw,44);Bounds.Rect(U.RobuxBuy,tx+(tw+6)/2,ph-50,(tw-6)/2,44)
  end
  local cols=wide and 3 or 2;local gap=6;local cw=(lw-gap*(cols-1))/cols;local ch=(lh-gap)/2
  U.Capacity=cols*2;for i,s in ipairs(slots)do
   Bounds.Rect(s.root,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(ch+gap),cw,ch)
   local sh=math.max(30,ch-30);local sw=math.min(cw-12,sh*(s.box and 1.1 or .70));Bounds.Rect(s.host,(cw-sw)/2,4,sw,sh);Bounds.Rect(s.label,3,ch-24,cw-6,22)
   if ch<82 then local sh=ch-10;local sw=sh*.70;Bounds.Rect(s.host,6,5,sw,sh);Bounds.Rect(s.label,sw+12,4,cw-sw-18,ch-8);s.label.TextWrapped=true end
  end
  Bounds.Rect(U.Atelier,il+8,top,aw-16,ah);local ew=aw-16
  Bounds.Rect(U.CustomID,10,8,ew-192,44);Bounds.Rect(U.LoadImage,ew-176,8,78,44);Bounds.Rect(U.ReloadImage,ew-92,8,82,44);Bounds.Rect(U.ImageStatus,10,56,ew-20,36)
  local eh=math.max(50,ah-202);local ecw=math.min(ew*.48,eh*.70);Bounds.Rect(U.CustomPreview,12,98,ecw,eh)
  local ex=ecw+24;local exw=ew-ex-12
  for i,b in ipairs({U.Minus,U.Plus,U.Center,U.CustomFlip})do Bounds.Rect(b,ex,98+(i-1)*48,exw,44)end
  Bounds.Rect(U.SaveCustom,10,ah-52,ew-20,44)
  if eh<188 then
   local bh=44;local cardH=math.max(50,ah-154);local cardW=math.min(ew*.4,cardH*.70);Bounds.Rect(U.CustomPreview,12,96,cardW,cardH)
   local rx=cardW+24;local rw=ew-rx-10;local bw=(rw-6)/2
   for i,b in ipairs({U.Minus,U.Plus,U.Center,U.CustomFlip})do Bounds.Rect(b,rx+(i-1)%2*(bw+6),98+math.floor((i-1)/2)*(bh+6),bw,bh)end
  end
  if wide and ah<260 then
   local left=ew*.66;local cardH=ah-16;local cardW=math.min(ew-left-16,cardH*.70)
   Bounds.Rect(U.CustomID,10,8,left-192,44);Bounds.Rect(U.LoadImage,left-176,8,78,44);Bounds.Rect(U.ReloadImage,left-92,8,82,44);Bounds.Rect(U.ImageStatus,10,56,left-20,28)
   for i,b in ipairs({U.Minus,U.Plus,U.Center,U.CustomFlip})do Bounds.Rect(b,10+(i-1)*(left-14)/4,86,(left-38)/4,44)end
   Bounds.Rect(U.SaveCustom,10,ah-48,left-20,44);Bounds.Rect(U.CustomPreview,left+(ew-left-cardW)/2,8,cardW,cardH)
  end
  U.Dialog.Size=UDim2.fromOffset(math.min(620,aw-16),math.min(370,h-it-ib-16))
 end
 function U.Show()
  storeToken=storeToken+1;local token=storeToken;U.Root.Visible=true;U.Store=nil;refresh()
  local s,e=call("store");if token~=storeToken or not U.Root.Visible then return end;if not s then if e then toast(e)end;return end
  for _,group in ipairs({s.passes,s.products})do for _,entry in pairs(group)do entry.price=nil;entry.sale=false;entry.pending=true end end
  U.Store=s;U.Render();task.spawn(function()
   for _,kind in ipairs({"pass","product"})do local group=kind=="pass"and s.passes or s.products
    for _,entry in pairs(group)do if token~=storeToken or not U.Root.Visible then return end;local p=nativePrice(entry.id,kind);if token~=storeToken or not U.Root.Visible then return end;entry.price=p.price;entry.sale=p.sale;entry.pending=false end
   end
   if U.Tab=="Loja"and U.Selected then details(U.Selected)elseif U.Tab=="Ateliê"and not U.Data.ateliers then local p=s.passes[tostring(Catalog.CustomPass)];U.SaveCustom.Text=p and p.sale and("Ateliê • "..p.price.." Robux")or"Ateliê indisponível";D.SetEnabled(U.SaveCustom,p and p.sale)end
  end)
 end
 U.Close.Activated:Connect(function()storeToken=storeToken+1;imageToken=imageToken+1;U.Root.Visible=false;U.Dialog.Visible=false;U.Skip=true;drag=nil;if U.OnClose then U.OnClose()end end)
 gui.Destroying:Connect(function()moving:Disconnect();ending:Disconnect();if imageConnection then imageConnection:Disconnect()end end)
 safe.Watch(function()U.Layout();if U.Data and U.Tab~="Ateliê"then U.PaintPage()end end);return U
end
return M
