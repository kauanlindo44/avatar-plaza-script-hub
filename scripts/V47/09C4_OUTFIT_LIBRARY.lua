-- 09C4_OUTFIT_LIBRARY | ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V44: itens com X, corpo em popup e paginas exclusivas de Carrinho/Plus.
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local M={VERSION="V44_EDITOR"}
local CTX=nil
local cart={}
local function key(item)
 local id=tonumber(item and item.Id)
 if not id or id<=0 or id%1~=0 then return nil end
 return CTX.A.ItemType(item)..":"..tostring(id)
end
local mode="Selected";local outfit={};local quoteGeneration=0
local function rows()
 local out={};for _,v in pairs(mode=="Outfit"and outfit or cart)do table.insert(out,v)end
 table.sort(out,function(a,b)return tostring(a.item.Name or a.key)<tostring(b.item.Name or b.key)end);return out
end
local function clear(p)
 for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end
end
local refreshCart
local function syncOutfit()
 local current={};for _,e in ipairs(CTX.S.Current and CTX.A.Entries(CTX.S.Current)or{})do
  local k="Asset:"..e.Id;current[k]=outfit[k]or{key=k,item={Id=e.Id,Name=e.Slot.." • "..e.Id,ItemType="Asset"},selected=true}
 end;outfit=current
end
local function quote()
 if not CTX then return end;quoteGeneration=quoteGeneration+1;local mine=quoteGeneration;local entries=rows()
 task.spawn(function()
  for offset=1,#entries,20 do
   local items={};for i=offset,math.min(offset+19,#entries)do local e=entries[i];items[#items+1]={id=e.item.Id,kind=CTX.A.ItemType(e.item)}end
   local data=CTX.call("CartQuote",{items=items});if mine~=quoteGeneration then return end
   if data then for i,d in ipairs(data.items)do local e=entries[offset+i-1];e.owned=d.owned;e.item.Name=d.name or e.item.Name;e.item.Price=d.price;e.quoted=true end end
   refreshCart()
  end
 end)
end
refreshCart=function()
 if not CTX then return end
 local U,A=CTX.U,CTX.A;clear(U.CartList)
 local total,selected,count,unknown=0,0,0,0;local list=rows()
 U.CartSelected.BackgroundColor3=mode=="Selected"and U.Colors.soft or U.Colors.card
 U.CartOutfit.BackgroundColor3=mode=="Outfit"and U.Colors.soft or U.Colors.card
 if #list==0 then U.Text(U.CartList,"Adicione itens pelo catálogo ou abra Outfit atual.",{Size=UDim2.new(1,-8,0,64),TextSize=18,TextColor3=U.Colors.muted})end
 for _,entry in ipairs(list)do
  count=count+1;local item=entry.item;local p=A.Price(item)
  if entry.selected and entry.owned~=true then selected=selected+1;if p~=nil then total=total+p else unknown=unknown+1 end end
  local row=U.New("Frame",{Size=UDim2.new(1,-4,0,64),BackgroundColor3=U.Colors.card,BorderSizePixel=0},U.CartList);U.Round(row,9)
  local check=U.Button(row,entry.owned and"✓"or entry.selected and"ON"or"OFF",{Position=UDim2.fromOffset(4,10),Size=UDim2.fromOffset(44,44),BackgroundColor3=entry.selected and U.Colors.green or U.Colors.soft})
  check.Active=entry.owned~=true
  U.New("ImageLabel",{Position=UDim2.fromOffset(52,8),Size=UDim2.fromOffset(48,48),BackgroundTransparency=1,Image=A.Thumbnail(item,150),ScaleType=Enum.ScaleType.Fit},row)
  U.Text(row,tostring(item.Name or"Item"),{Position=UDim2.fromOffset(106,5),Size=UDim2.new(1,-162,0,26),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  local price=entry.owned and"JÁ NO SEU INVENTÁRIO"or p==nil and"CONSULTAR NO ROBLOX"or p==0 and"GRÁTIS"or tostring(math.floor(p)).." Robux"
  U.Text(row,price,{Position=UDim2.fromOffset(106,34),Size=UDim2.new(1,-162,0,22),TextColor3=U.Colors.green,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
  local rm=U.Button(row,"×",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-4,.5,0),Size=UDim2.fromOffset(44,48),BackgroundColor3=U.Colors.red})
  check.Activated:Connect(function()if entry.owned then return end;entry.selected=not entry.selected;refreshCart()end)
  rm.Activated:Connect(function()if mode=="Outfit"then entry.selected=false else cart[entry.key]=nil end;refreshCart()end)
 end
 U.CartCount.Text=selected.." para comprar • "..count..(mode=="Outfit"and" no outfit"or" no carrinho")..(unknown>0 and(" • "..unknown.." a consultar")or"")
 U.CartTotal.Text=(unknown>0 and"SUBTOTAL: "or"TOTAL: ")..math.floor(total).." Robux"
 U.CartBuySelected.Text=selected>20 and"COMPRAR PRÓXIMOS 20"or selected>0 and("COMPRAR "..selected)or"SELECIONE ITENS";U.BuyLook.Text="Carrinho"
end
function M.Add(item)
 if not CTX then return false end;local k=key(item);if not k then return false end
 cart[k]=cart[k]or{key=k,item=CTX.A.Copy(item),selected=true};cart[k].selected=true
 refreshCart();CTX.toast("Adicionado ao carrinho.");return true
end
function M.Open(body)
 if not CTX then return end
 if type(body)=="table"and body.props then
  outfit={};for _,e in ipairs(CTX.A.Entries(body))do local k="Asset:"..e.Id;outfit[k]={key=k,item={Id=e.Id,Name=e.Slot.." • "..e.Id,ItemType="Asset"},selected=true}end;mode="Outfit"
 elseif mode=="Outfit"then syncOutfit()end
 refreshCart();quote();if CTX.openUtility then CTX.openUtility("Cart")else CTX.U.CartPanel.Visible=true end
end
function M.Close()if CTX then quoteGeneration=quoteGeneration+1;if CTX.closeUtility then CTX.closeUtility()else CTX.U.CartPanel.Visible=false end end end
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
  local row=U.New("Frame",{Name="Equipped_"..e.Id,Size=UDim2.fromOffset(78,56),BackgroundColor3=U.Colors.card,BorderSizePixel=0},U.ItemStrip);U.Round(row,8)
  U.New("ImageLabel",{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(72,50),BackgroundTransparency=1,
   Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},row)
  row:SetAttribute("ItemId",e.Id);row:SetAttribute("Slot",e.Slot)
  local rm=U.Button(row,"X",{Name="RemoveItem",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(40,40),BackgroundColor3=U.Colors.panel,TextSize=16})
  rm.Activated:Connect(function()local ok,err=S.Remove(e.Id);if not ok then CTX.toast(err)end end)
 end
end
local prompting=false
function M.OpenPlus()
 if not CTX or prompting then return end;prompting=true
 local ok=pcall(function()Market:PromptRobloxSubscriptionPurchase(CTX.pl)end)
 task.delay(3,function()prompting=false end)
 if not ok then CTX.toast("O Roblox não abriu o plano. Tente no jogo publicado.")end
end
function M.Init(ctx)
 CTX=ctx;local U,S=ctx.U,ctx.S
 U.BodyToggle.Activated:Connect(function()U.BodyWindow.Visible=not U.BodyWindow.Visible;refreshBody()end)
 U.BodyClose.Activated:Connect(function()U.BodyWindow.Visible=false end)
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
 U.CartSelected.Activated:Connect(function()mode="Selected";refreshCart();quote()end)
 U.CartOutfit.Activated:Connect(function()mode="Outfit";syncOutfit();refreshCart();quote()end)
 U.CartClear.Activated:Connect(function()if mode=="Outfit"then for _,e in pairs(outfit)do e.selected=false end else cart={}end;refreshCart()end)
 Market.PromptBulkPurchaseFinished:Connect(function(who)if who==ctx.pl then quote()end end)
 local buying=false
 U.CartBuySelected.Activated:Connect(function()
  if buying then return end
  local items={};for _,e in ipairs(rows())do
   if e.selected and not e.owned then table.insert(items,{id=tonumber(e.item.Id),kind=ctx.A.ItemType(e.item)})end
  end
  if #items==0 then ctx.toast("Selecione pelo menos um item.");return end
    buying=true;local d,err=ctx.call("CartPurchase",{items=items});buying=false
  ctx.toast(d and(d.count==0 and"Você já possui os itens selecionados."or"Compra aberta. Confira o preço final no Roblox.")or err)
 end)
 S.Changed.Event:Connect(function()refreshBody();refreshItems();if mode=="Outfit"then syncOutfit();refreshCart()end end)
 refreshBody();refreshItems();refreshCart()
 return M
end
return M
