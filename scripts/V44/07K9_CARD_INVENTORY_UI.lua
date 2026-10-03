-- 07K9_CARD_INVENTORY_UI | ModuleScript | ReplicatedStorage | V44
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Catalog=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local UIS=game:GetService("UserInputService")
local M={}
function M.Build(gui,call,toast)
 local U={Tab="Caixas",Data=nil,Store=nil,Style="Classic",Back=true};local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="CardInventory",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false},gui)
 U.Title=D.Text(U.Root,"Baralhos",{Font=Enum.Font.GothamBold,TextSize=24,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,"CloseInventory","close","Fechar inventário",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 U.Coins=D.Text(U.Root,"",{TextColor3=C.yellow,TextXAlignment=Enum.TextXAlignment.Left})
 U.Tabs=D.New("Frame",{BackgroundTransparency=1},U.Root);local tabs={}
 for i,key in ipairs({"Caixas","Visuais","Loja","Ateliê"})do local b=D.Button(U.Tabs,key,{});tabs[i]=b
  b.Activated:Connect(function()U.Tab=key;U.Render()end)
 end
 U.Preview=D.Frame(U.Root,{BackgroundColor3=C.panel});U.PreviewName=D.Text(U.Preview,"Clássico",{Size=UDim2.new(1,0,0,32),Font=Enum.Font.GothamBold})
 U.CardHost=D.New("Frame",{Position=UDim2.new(.2,0,0,40),Size=UDim2.new(.6,0,1,-98),BackgroundTransparency=1},U.Preview)
 U.Flip=D.Button(U.Preview,"Ver frente",{Position=UDim2.new(0,8,1,-52),Size=UDim2.new(1,-16,0,44)})
 U.List=D.Scroll(U.Root,{Name="InventoryItems"});local grid=D.New("UIGridLayout",{SortOrder=Enum.SortOrder.LayoutOrder,CellPadding=UDim2.fromOffset(8,8)},U.List)
 U.Dialog=D.Frame(U.Root,{Name="OpenBox",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(560,320),Visible=false,ZIndex=60})
 U.DialogTitle=D.Text(U.Dialog,"",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-74,0,48),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=61})
 U.DialogClose=D.IconButton(U.Dialog,"CloseBox","close","Fechar caixa",{Position=UDim2.new(1,-56,0,4),Size=UDim2.fromOffset(48,48),ZIndex=70})
 U.Choices=D.New("Frame",{Position=UDim2.fromOffset(10,60),Size=UDim2.new(1,-20,1,-136),BackgroundTransparency=1,ZIndex=61},U.Dialog)
 U.Open=D.Button(U.Dialog,"Escolha seus visuais",{Position=UDim2.new(0,10,1,-64),Size=UDim2.new(1,-20,0,52),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=62})
 U.DialogClose.Activated:Connect(function()U.Dialog.Visible=false;U.Skip=true end)
 local function clear(p)for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end end
 function U.SetPreview(style,custom)
  U.Style=style;U.PreviewCustom=custom;clear(U.CardHost);Cards.Render(U.CardHost,not U.Back and{rank="A",suit="S"}or nil,style,{Size=UDim2.fromScale(1,1)},custom or U.Data and U.Data.custom)
  U.PreviewName.Text=style=="Custom"and"Ateliê"or Catalog.Styles[style]and Catalog.Styles[style].name or style
  U.Flip.Text=U.Back and"Ver frente"or"Ver verso"
 end
 U.Flip.Activated:Connect(function()U.Back=not U.Back;U.SetPreview(U.Style,U.PreviewCustom)end)
 local function refresh()local d,e=call("inventory");if d then U.Data=d;U.Render()elseif e then toast(e)end end
 local function buy(kind,key,quantity)local d,e=call("buycoins",{kind=kind,key=key,quantity=quantity or 1});toast(d and"Compra adicionada ao inventário."or e);if d then refresh()end end
 local function prompt(kind,key)local d,e=call("prompt",{kind=kind,key=key});if not d then toast(e)end end
 local function card(key,title,note)
  local b=D.Frame(U.List,{Name=key,BackgroundColor3=C.panel})
  D.Text(b,title,{Position=UDim2.fromOffset(8,6),Size=UDim2.new(1,-16,0,24),Font=Enum.Font.GothamBold})
  D.Text(b,note,{Position=UDim2.fromOffset(8,34),Size=UDim2.new(1,-16,0,38),TextColor3=C.muted,TextSize=13})
  return b
 end
 function U.OpenBox(box)
  U.Dialog.Visible=true;U.DialogTitle.Text=box.id.." • escolha garantida";clear(U.Choices);U.Skip=false
  local selected={};local buttons={}
  local function paint()
   local n=0;for _,style in ipairs(box.skins)do local own=U.Data.owned[style];local on=selected[style]
    buttons[style].Text=style..(own and" • adquirido"or on and" • escolhido"or"");buttons[style].BackgroundColor3=on and C.green or C.card
    if on then n=n+1 end
   end
   U.Open.Text=n==0 and"Selecione os visuais"or"Abrir "..n.." caixa(s) • "..n.." visual(is) garantido(s)";D.SetEnabled(U.Open,n>0 and n<=(U.Data.boxes[box.id]or 0))
  end
  for i,style in ipairs(box.skins)do
   Cards.Render(U.Choices,nil,style,{Position=UDim2.new((i-1)/3,4,0,0),Size=UDim2.new(1/3,-8,1,-46),ZIndex=62})
   local b=D.Button(U.Choices,style,{Position=UDim2.new((i-1)/3,4,1,-44),Size=UDim2.new(1/3,-8,0,44),ZIndex=65});buttons[style]=b
   D.SetEnabled(b,not U.Data.owned[style]);b.Activated:Connect(function()selected[style]=not selected[style];U.SetPreview(style);paint()end)
  end
  if U.OpenConnection then U.OpenConnection:Disconnect()end
  U.OpenConnection=U.Open.Activated:Connect(function()
   local styles={};for _,style in ipairs(box.skins)do if selected[style]then table.insert(styles,style)end end
   D.SetEnabled(U.Open,false);local result,e=call("openbox",{key=box.id,styles=styles})
   if not result then toast(e);paint();return end
   if U.OpenConnection then U.OpenConnection:Disconnect();U.OpenConnection=nil end
   clear(U.Choices);U.DialogTitle.Text="Seus visuais";U.Open.Text="Pular animação";U.Skip=false
   if U.SkipConnection then U.SkipConnection:Disconnect()end;U.SkipConnection=U.Open.Activated:Connect(function()U.Skip=true end);D.SetEnabled(U.Open,true)
   for i,style in ipairs(result.styles)do
    if not U.Skip and U.Dialog.Visible then
     local name=D.Text(U.Choices,style,{Size=UDim2.fromScale(1,1),TextSize=32,Font=Enum.Font.GothamBold,ZIndex=66})
     for _=1,12 do if U.Skip or not U.Dialog.Visible then break end;task.wait(.04)end;name:Destroy()
    end
   end
   clear(U.Choices);for i,style in ipairs(result.styles)do Cards.Render(U.Choices,{rank="A",suit="S"},style,{Position=UDim2.new((i-1)/#result.styles,4,0,0),Size=UDim2.new(1/#result.styles,-8,1,0),ZIndex=62})end
   if U.OpenConnection then U.OpenConnection:Disconnect();U.OpenConnection=nil end;if U.SkipConnection then U.SkipConnection:Disconnect();U.SkipConnection=nil end
   U.Open.Text="Visuais adicionados ao inventário";D.SetEnabled(U.Open,false);refresh()
  end);paint();U.Layout()
 end
 function U.Render()
  clear(U.List);if not U.Data then return end
  if #U.CardHost:GetChildren()==0 then U.SetPreview(U.Data.equipped or"Classic")end
  U.Coins.Text=U.Data.coins.." moedas • ganhas em partidas PvP";for i,b in ipairs(tabs)do b.BackgroundColor3=b.Text==U.Tab and C.soft or C.card end
  if U.Tab=="Caixas"then
   for _,box in ipairs(Catalog.Collections)do
    local b=card(box.id,box.id,(U.Data.boxes[box.id]or 0).." caixa(s) • escolha o conteúdo antes de abrir")
    Cards.Render(b,nil,box.skins[1],{Position=UDim2.fromScale(.32,.27),Size=UDim2.fromScale(.36,.45)})
    local open=D.Button(b,"Ver e abrir",{Position=UDim2.new(0,8,1,-52),Size=UDim2.new(1,-16,0,44)});open.Activated:Connect(function()U.OpenBox(box)end)
   end
  elseif U.Tab=="Visuais"then
   local styles={};for key in pairs(U.Data.owned)do table.insert(styles,key)end;if U.Data.ateliers then table.insert(styles,"Custom")end;table.sort(styles)
   for _,style in ipairs(styles)do
    local b=card(style,style,U.Data.equipped==style and"Equipado"or"Visual permanente")
    Cards.Render(b,nil,style,{Position=UDim2.fromScale(.28,.27),Size=UDim2.fromScale(.44,.45)},U.Data.custom)
    local equip=D.Button(b,"Equipar",{Position=UDim2.new(0,8,1,-52),Size=UDim2.new(1,-16,0,44)});equip.Activated:Connect(function()
     U.SetPreview(style);local d,e=call("equip",{style=style});if d then refresh()else toast(e)end
    end)
   end
  elseif U.Tab=="Loja"then
   for _,box in ipairs(Catalog.Collections)do
    local b=card(box.id,box.id,"Caixa de escolha • "..box.coins.." moedas")
    local coin=D.Button(b,"Comprar com moedas",{Position=UDim2.new(0,8,1,-100),Size=UDim2.new(1,-16,0,44)});coin.Activated:Connect(function()buy("box",box.id)end)
    local p=U.Store and U.Store.products[box.id];local rb=D.Button(b,p and p.sale and(p.price.." Robux • garantida")or"Robux: produto não configurado",{Position=UDim2.new(0,8,1,-52),Size=UDim2.new(1,-16,0,44)})
    D.SetEnabled(rb,p and p.sale==true);rb.Activated:Connect(function()prompt("product",box.id)end)
   end
   for key,s in pairs(Catalog.Styles)do if key~="Classic"then
    local b=card(key,key,s.coins.." moedas • compra direta")
    Cards.Render(b,nil,key,{Position=UDim2.fromScale(.38,.27),Size=UDim2.fromScale(.24,.32)})
    local covered=Catalog.Covered(U.Data,key)
    local coin=D.Button(b,covered and not U.Data.owned[key]and"Escolha nas suas caixas"or"Comprar • "..s.coins.." moedas",{Position=UDim2.new(0,8,1,-100),Size=UDim2.new(1,-16,0,44)});D.SetEnabled(coin,not U.Data.owned[key]and not covered);coin.Activated:Connect(function()buy("style",key)end)
    local id=Catalog.PassFor(key);local p=id and U.Store and U.Store.passes[tostring(id)]or U.Store and U.Store.products[key]
    local rb=D.Button(b,p and p.sale and(p.price.." Robux • "..key)or"Robux: indisponível",{Position=UDim2.new(0,8,1,-52),Size=UDim2.new(1,-16,0,44)})
    D.SetEnabled(rb,p and p.sale and not U.Data.owned[key]and not covered);rb.Activated:Connect(function()prompt(id and"pass"or"product",id or key)end)
   end end
  else
   local b=card("Atelier","Ateliê","Imagem aprovada pela Roblox. Só o visual do seu baralho muda.")
   local id=D.Box(b,"ID da imagem",{Name="CustomImageID",Position=UDim2.fromOffset(10,84),Size=UDim2.new(.58,-14,0,44),Text=tostring(U.Data.custom.image>0 and U.Data.custom.image or"")})
   local zoom=U.Data.custom.zoom or 1;local x,y=U.Data.custom.x or 0,U.Data.custom.y or 0
   local minus=D.Button(b,"− zoom",{Position=UDim2.fromOffset(10,136),Size=UDim2.new(.29,-12,0,44)})
   local plus=D.Button(b,"+ zoom",{Position=UDim2.new(.29,2,0,136),Size=UDim2.new(.29,-6,0,44)})
   D.Text(b,"Arraste a imagem na carta para ajustar.",{Position=UDim2.fromOffset(10,186),Size=UDim2.new(.58,-14,0,44),TextColor3=C.muted,TextSize=13})
   local inline=D.New("Frame",{Name="CustomCardPreview",Position=UDim2.new(.6,0,0,84),Size=UDim2.new(.36,0,1,-152),BackgroundTransparency=1,Active=true},b)
   local function preview()
    local limit=(zoom-1)/2;x=math.clamp(x,-limit,limit);y=math.clamp(y,-limit,limit)
    local custom={image=tonumber(id.Text)or 0,zoom=zoom,x=x,y=y};U.SetPreview("Custom",custom);clear(inline);Cards.Render(inline,nil,"Custom",{Size=UDim2.fromScale(1,1)},custom)
   end
   local drag,origin,startX,startY
   inline.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=i;origin=i.Position;startX,startY=x,y end end)
   local moving=UIS.InputChanged:Connect(function(i)
    if drag and(i==drag or i.UserInputType==Enum.UserInputType.MouseMovement)then local delta=i.Position-origin;x=startX+delta.X/math.max(1,inline.AbsoluteSize.X);y=startY+delta.Y/math.max(1,inline.AbsoluteSize.Y);preview()end
   end)
   local ending=UIS.InputEnded:Connect(function(i)if i==drag or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end end)
   b.Destroying:Connect(function()moving:Disconnect();ending:Disconnect()end);preview()
   minus.Activated:Connect(function()zoom=math.max(1,zoom-.1);preview()end);plus.Activated:Connect(function()zoom=math.min(2,zoom+.1);preview()end);id.FocusLost:Connect(preview)
   local apply=D.Button(b,U.Data.ateliers and"Salvar visual"or"Adquirir Ateliê",{Position=UDim2.new(0,10,1,-54),Size=UDim2.new(1,-20,0,44),BackgroundColor3=C.green,TextColor3=C.bg})
   local p=U.Store and U.Store.passes[tostring(Catalog.CustomPass)];if not U.Data.ateliers then apply.Text=p and p.sale and("Ateliê • "..p.price.." Robux")or"Ateliê indisponível";D.SetEnabled(apply,p and p.sale)end
   apply.Activated:Connect(function()if not U.Data.ateliers then prompt("pass",Catalog.CustomPass);return end
    local d,e=call("custom",{image=tonumber(id.Text),zoom=zoom,x=x,y=y});toast(d and"Visual salvo. Equipe o Ateliê em Visuais."or e);if d then refresh()end
   end)
  end
  U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local y=safe.Heading(U.Title,U.Close);local aw=w-il-ir
  Bounds.Rect(U.Coins,il+10,y,aw-20,26);Bounds.Rect(U.Tabs,il+8,y+32,aw-16,44)
  for i,b in ipairs(tabs)do Bounds.Rect(b,(i-1)*(aw-12)/4,0,(aw-28)/4,44)end
  local top=y+84;local ah=h-ib-top-8;local preview=w>=700;U.Preview.Visible=preview
  local pw=preview and math.min(320,aw*.27)or 0;Bounds.Rect(U.Preview,il+8,top,pw,ah)
  Bounds.Rect(U.List,il+pw+(preview and 16 or 8),top,aw-pw-(preview and 24 or 16),ah)
  local cols=U.Tab=="Ateliê"and 1 or math.clamp(math.floor(U.List.AbsoluteSize.X/190),1,5)
  local cw=(U.List.AbsoluteSize.X-8-(cols-1)*8)/cols;grid.CellSize=UDim2.fromOffset(cw,U.Tab=="Ateliê"and math.max(320,ah-8)or math.max(220,math.min(300,ah/2-8)));grid.FillDirectionMaxCells=cols
  U.Dialog.Size=UDim2.fromOffset(math.min(620,aw-16),math.min(370,h-it-ib-16))
 end
 function U.Show()U.Root.Visible=true;refresh();local s,e=call("store");if s then U.Store=s;U.Render()elseif e then toast(e)end end
 U.Close.Activated:Connect(function()U.Root.Visible=false;U.Dialog.Visible=false;U.Skip=true;if U.OnClose then U.OnClose()end end)
 safe.Watch(U.Layout);return U
end
return M
