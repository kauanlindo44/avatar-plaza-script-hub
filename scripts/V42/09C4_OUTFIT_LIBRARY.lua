-- 09C4_OUTFIT_LIBRARY | ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V42: itens com X, corpo em popup e paginas exclusivas de Carrinho/Plus.
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local M={VERSION="V42_EDITOR"}
local CTX=nil
local cart={}
local function key(item)
 local id=tonumber(item and item.Id)
 if not id or id<=0 or id%1~=0 then return nil end
 return CTX.A.ItemType(item)..":"..tostring(id)
end
local function rows()
 local out={};for _,v in pairs(cart)do table.insert(out,v)end
 table.sort(out,function(a,b)
  local an,bn=tostring(a.item.Name or""),tostring(b.item.Name or"")
  if an~=bn then return an<bn end;return a.key<b.key
 end)
 return out
end
local function clear(p)
 for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end
end
local function refreshCart()
 if not CTX then return end
 local U,A=CTX.U,CTX.A
 clear(U.CartList)
 local total,selected,count,unknown=0,0,0,0
 if M.Count()==0 then U.Text(U.CartList,"Seu carrinho está vazio. Adicione itens pelo catálogo.",{Size=UDim2.new(1,-8,0,64),TextSize=18,TextColor3=U.Colors.muted})end
 for _,entry in ipairs(rows())do
  count=count+1;local item=entry.item;local p=A.Price(item)
  if entry.selected then
   selected=selected+1;if p~=nil then total=total+p else unknown=unknown+1 end
  end
  local row=U.New("Frame",{Size=UDim2.new(1,-4,0,60),BackgroundColor3=U.Colors.card,BorderSizePixel=0},U.CartList)
  U.Round(row,9)
  local check=U.Button(row,entry.selected and"ON"or"OFF",{Position=UDim2.fromOffset(6,8),Size=UDim2.fromOffset(38,44),
   BackgroundColor3=entry.selected and U.Colors.green or U.Colors.soft,TextColor3=entry.selected and U.Colors.bg or U.Colors.white})
  U.New("ImageLabel",{Position=UDim2.fromOffset(50,8),Size=UDim2.fromOffset(44,44),BackgroundTransparency=1,
   Image=A.Thumbnail(item,150),ScaleType=Enum.ScaleType.Fit},row)
  U.Text(row,tostring(item.Name or"Item"),{Position=UDim2.fromOffset(102,6),Size=UDim2.new(1,-150,0,24),
   Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  local price=p==nil and"CONSULTAR NO ROBLOX"or p==0 and"GRÁTIS"or tostring(math.floor(p)).." Robux"
  U.Text(row,price,{Position=UDim2.fromOffset(102,32),Size=UDim2.new(1,-150,0,20),
   TextColor3=p~=nil and U.Colors.green or U.Colors.muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
  local rm=U.Button(row,"X",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),
   Size=UDim2.fromOffset(36,44),BackgroundColor3=U.Colors.red})
  check.Activated:Connect(function()entry.selected=not entry.selected;refreshCart()end)
  rm.Activated:Connect(function()cart[entry.key]=nil;refreshCart()end)
 end
 U.CartCount.Text=selected.." selecionados • "..count.." no carrinho"..(unknown>0 and(" • "..unknown.." sem preço")or"")
 U.CartTotal.Text=(unknown>0 and"SUBTOTAL: "or"TOTAL: ")..math.floor(total).." Robux"
 U.CartBuySelected.Text=selected>0 and("COMPRAR "..selected.." ITENS")or"SELECIONE ITENS"
 U.BuyLook.Text="Carrinho"
end
function M.Add(item)
 if not CTX then return false end
 local k=key(item);if not k then return false end
 if cart[k]then cart[k].selected=true;refreshCart();CTX.toast("Este item já está no carrinho.");return true end
 cart[k]={key=k,item=CTX.A.Copy(item),selected=true}
 refreshCart();CTX.toast("Adicionado ao carrinho.");return true
end
function M.Open()if CTX then refreshCart();if CTX.openUtility then CTX.openUtility("Cart")else CTX.U.CartPanel.Visible=true end end end
function M.Close()if CTX then if CTX.closeUtility then CTX.closeUtility()else CTX.U.CartPanel.Visible=false end end end
function M.Count()local n=0;for _ in pairs(cart)do n=n+1 end;return n end
local function refreshBody()
 if not CTX then return end
 local U,S=CTX.U,CTX.S;local rig=S.Rig or"R15"
 for _,r in ipairs({{"R6",U.RigR6},{"R15",U.RigR15}})do
  r[2].BackgroundColor3=rig==r[1]and U.Colors.green or U.Colors.soft
  r[2].TextColor3=rig==r[1]and U.Colors.bg or U.Colors.white
 end
 U.BodyNote.Text=rig=="R6"and"R6: proporções fixas."or"R15: limites oficiais do Roblox."
 for name,ctl in pairs(U.BodyControls or{})do
  local v=S.GetScale and S.GetScale(name)or 1;ctl.Value.Text=string.format("%.2f",tonumber(v)or 1)
  ctl.Minus.TextColor3=rig=="R15"and U.Colors.white or U.Colors.muted
  ctl.Plus.TextColor3=ctl.Minus.TextColor3
  ctl.Minus.Active=rig=="R15";ctl.Plus.Active=rig=="R15"
 end
end
local function refreshItems()
 if not CTX then return end
 local U,A,S=CTX.U,CTX.A,CTX.S;clear(U.ItemStrip)
 local entries=S.Current and A.Entries(S.Current)or{}
 U.Total.Text=#entries.." itens"
 if #entries==0 then U.Text(U.ItemStrip,"Sem itens",{Size=UDim2.fromOffset(104,44),TextColor3=U.Colors.muted});return end
 for _,e in ipairs(entries)do
  local row=U.New("Frame",{Name="Equipped_"..e.Id,Size=UDim2.fromOffset(66,62),BackgroundColor3=U.Colors.card,BorderSizePixel=0},U.ItemStrip);U.Round(row,8)
  U.New("ImageLabel",{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(60,56),BackgroundTransparency=1,
   Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},row)
  row:SetAttribute("ItemId",e.Id);row:SetAttribute("Slot",e.Slot)
  local rm=U.Button(row,"X",{Name="RemoveItem",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(32,32),BackgroundColor3=U.Colors.panel,TextSize=16})
  rm.Activated:Connect(function()local ok,err=S.Remove(e.Id);if not ok then CTX.toast(err)end end)
 end
end
local plusRevision,owned,prompting=0,false,false
local function refreshPlus()
 local U=CTX.U;plusRevision=plusRevision+1;local mine=plusRevision
 U.PlusName.Text="Roblox Plus"
 U.PlusDescription.Text="A assinatura do Roblox oferece descontos em compras elegíveis e benefícios na plataforma.\n\nConfira planos, disponibilidade e preço na janela oficial do Roblox."
 U.PlusBuy.Active=false;U.PlusBuy.Text="AGUARDE";U.PlusPrice.Text="Assinatura Roblox";U.PlusStatus.Text="Consultando sua assinatura..."
 task.spawn(function()
  local data,err=CTX.call("RobloxPlusStatus",{});if mine~=plusRevision then return end
  if not data then U.PlusStatus.Text=err or"Consulta indisponível.";U.PlusBuy.Text="TENTAR NOVAMENTE";U.PlusBuy.Active=true;owned=false
  else
   owned=data.active==true
   U.PlusStatus.Text=owned and"Sua assinatura está ativa."or"Veja os planos e confirme no Roblox."
   U.PlusBuy.Text=owned and"PLUS ATIVO"or"VER PLANOS";U.PlusBuy.Active=not owned
  end
  U.PlusPrice.Text=owned and"PLUS ATIVO"or"Preço no Roblox"
  U.PlusBuy.BackgroundColor3=U.PlusBuy.Active and U.Colors.green or U.Colors.soft
  U.PlusBuy.TextColor3=U.PlusBuy.Active and U.Colors.bg or U.Colors.muted
 end)
end
function M.OpenPlus()if CTX then CTX.openUtility("Plus");refreshPlus()end end
function M.Init(ctx)
 CTX=ctx;local U,S=ctx.U,ctx.S
 U.BodyToggle.Activated:Connect(function()U.BodyWindow.Visible=not U.BodyWindow.Visible;refreshBody()end)
 U.BodyClose.Activated:Connect(function()U.BodyWindow.Visible=false end)
 U.PlusBuy.Activated:Connect(function()
  if not U.PlusBuy.Active or owned or prompting then return end
  if U.PlusBuy.Text=="TENTAR NOVAMENTE"then refreshPlus();return end
  prompting=true
  local ok=pcall(function()Market:PromptRobloxSubscriptionPurchase(ctx.pl)end)
  task.delay(3,function()prompting=false end)
  if not ok then ctx.toast("O Roblox não abriu os planos. Tente no aplicativo publicado.")end
 end)
 pcall(function()Market.PromptRobloxSubscriptionPurchaseFinished:Connect(function(player,attempted)
  if player~=ctx.pl then return end;prompting=false
  if U.PlusPanel.Visible then refreshPlus();if attempted then
   local mine=plusRevision;task.delay(2,function()if U.PlusPanel.Visible and mine==plusRevision then refreshPlus()end end)
  end end
 end)end)
 pcall(function()ctx.pl:GetPropertyChangedSignal("HasRobloxSubscription"):Connect(function()if U.PlusPanel.Visible then refreshPlus()end end)end)
 U.RigR6.Activated:Connect(function()S.SetRig("R6");refreshBody()end)
 U.RigR15.Activated:Connect(function()S.SetRig("R15");refreshBody()end)
 for name,ctl in pairs(U.BodyControls)do
  local rule=S.ScaleRules()[name]
  if rule then
   local function change(sign)
    local ok,err=S.SetScale(name,(S.GetScale(name)or 1)+sign*rule[3]);if not ok then ctx.toast(err)end;refreshBody()
   end
   ctl.Minus.Activated:Connect(function()change(-1)end);ctl.Plus.Activated:Connect(function()change(1)end)
  end
 end
 U.BodyReset.Activated:Connect(function()local ok,err=S.ResetScales();ctx.toast(ok and"Proporções restauradas."or err);refreshBody()end)
 U.BuyLook.Activated:Connect(M.Open)
 U.CartClear.Activated:Connect(function()cart={};refreshCart()end)
 local buying=false
 U.CartBuySelected.Activated:Connect(function()
  if buying then return end
  local items={};for _,e in ipairs(rows())do
   if e.selected then table.insert(items,{id=tonumber(e.item.Id),kind=ctx.A.ItemType(e.item)})end
  end
  if #items==0 then ctx.toast("Selecione pelo menos um item.");return end
  if #items>20 then ctx.toast("Até 20 itens por compra. Desmarque alguns itens.");return end
  buying=true;local d,err=ctx.call("CartPurchase",{items=items});buying=false
  ctx.toast(d and"Compra aberta. Confira os preços finais no Roblox."or err)
 end)
 S.Changed.Event:Connect(function()refreshBody();refreshItems()end)
 refreshBody();refreshItems();refreshCart()
 return M
end
return M
