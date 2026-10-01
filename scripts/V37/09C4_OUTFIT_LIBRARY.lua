-- 09C4_OUTFIT_LIBRARY
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V37 - extras do editor: CORPO R6/R15 + carrinho real.

local M={}
local CTX=nil
local cart={}

local SCALE_LABELS={
 HeightScale="ALTURA",WidthScale="LARGURA",DepthScale="PROFUNDIDADE",
 HeadScale="CABEÇA",BodyTypeScale="TIPO DE CORPO",ProportionScale="PROPORÇÃO"
}

local function key(item)
 if not item then return nil end
 local id=tonumber(item.Id);if not id then return nil end
 local kind=CTX and CTX.A and CTX.A.ItemType(item)or"Asset"
 return tostring(kind)..":"..tostring(id)
end

local function cartRows()
 local out={}
 for _,v in pairs(cart)do table.insert(out,v)end
 table.sort(out,function(a,b)return tostring(a.Name or"")<tostring(b.Name or"")end)
 return out
end

local function clearGui(p)
 if not p then return end
 for _,c in ipairs(p:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end
end

local function refreshCart()
 if not CTX then return end
 local U,A=CTX.U,CTX.A
 clearGui(U.CartList)
 local total,selected,count=0,0,0
 for _,entry in ipairs(cartRows())do
  count=count+1
  local item=entry.item;local price=A.Price(item);if entry.selected~=false and price then total=total+price end
  if entry.selected~=false then selected=selected+1 end
  local row=U.New("Frame",{Size=UDim2.new(1,-4,0,54),BackgroundColor3=Color3.fromRGB(39,40,45),BorderSizePixel=0},U.CartList);U.Round(row,8)
  local check=U.Button(row,entry.selected~=false and"OK"or"",{Position=UDim2.fromOffset(6,10),Size=UDim2.fromOffset(34,34),BackgroundColor3=entry.selected~=false and U.Colors.green or U.Colors.soft,TextColor3=Color3.fromRGB(20,22,25),TextSize=7})
  U.New("ImageLabel",{Position=UDim2.fromOffset(46,5),Size=UDim2.fromOffset(44,44),BackgroundColor3=Color3.fromRGB(52,53,58),BorderSizePixel=0,Image=A.Thumbnail(item,150),ScaleType=Enum.ScaleType.Fit},row)
  U.Text(row,tostring(item.Name or"Item"),{Position=UDim2.fromOffset(98,6),Size=UDim2.new(1,-210,0,20),Font=Enum.Font.GothamBold,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  U.Text(row,A.PriceText(item),{Position=UDim2.fromOffset(98,28),Size=UDim2.new(1,-210,0,16),TextColor3=Color3.fromRGB(89,228,135),TextSize=7,TextXAlignment=Enum.TextXAlignment.Left})
  local rm=U.Button(row,"X",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.fromOffset(34,34),BackgroundColor3=U.Colors.red,TextSize=8})
  check.Activated:Connect(function()entry.selected=not(entry.selected~=false);refreshCart()end)
  rm.Activated:Connect(function()cart[entry.key]=nil;refreshCart()end)
 end
 U.CartCount.Text=selected.." selecionado(s) • "..count.." no carrinho"
 U.CartTotal.Text="TOTAL: "..total.." R$"
 U.CartBuySelected.Text=selected>0 and("COMPRAR "..selected.." ITEM(NS)")or"SELECIONE ITENS"
 if U.BuyLook then U.BuyLook.Text=count>0 and("CARRINHO ("..count..")")or"CARRINHO" end
end

function M.Add(item)
 if not CTX or not item then return false end
 local k=key(item);if not k then return false end
 cart[k]={key=k,item=item,selected=true}
 refreshCart();CTX.toast("Adicionado ao carrinho.");return true
end

function M.Open()
 if not CTX then return end
 refreshCart();CTX.U.CartPanel.Visible=true
end
function M.Close()if CTX then CTX.U.CartPanel.Visible=false end end
function M.Count()local n=0;for _ in pairs(cart)do n=n+1 end;return n end

local function refreshBody()
 if not CTX then return end
 local U,S=CTX.U,CTX.S
 local rig=S.GetRig and S.GetRig()or S.Rig or"R15"
 U.RigR6.BackgroundColor3=rig=="R6"and U.Colors.green or U.Colors.soft
 U.RigR15.BackgroundColor3=rig=="R15"and U.Colors.green or U.Colors.soft
 U.BodyNote.Text=rig=="R6"and"R6 usa 6 partes e não usa escalas corporais."or"R15 usa 15 partes e permite ajustar proporções."
 for name,ctl in pairs(U.BodyControls or{})do
  local v=S.GetScale and S.GetScale(name)or 1
  ctl.Value.Text=string.format("%.2f",tonumber(v)or 1)
 end
end

local function showEditor(name)
 if not CTX then return end
 local U=CTX.U
 local body=name=="CORPO"
 U.BodyPanel.Visible=body
 if U.Tools then U.Tools.Visible=not body end
 if U.ItemStrip then U.ItemStrip.Visible=not body end
 if U.Total then U.Total.Visible=not body end
 for _,b in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook})do if b then b.Visible=not body end end
 for tab,b in pairs(U.EditorTabButtons or{})do
  b.BackgroundColor3=tab==name and Color3.fromRGB(72,75,83)or Color3.fromRGB(43,45,50)
 end
 if name=="EMOTES"then
  if U.OpenRequest then U.OpenRequest:Fire("Emotes")end
 elseif body then refreshBody()end
end

function M.Init(ctx)
 CTX=ctx
 local U,S=ctx.U,ctx.S
 if U.EditorAvatar then U.EditorAvatar.Activated:Connect(function()showEditor("AVATAR")end)end
 if U.EditorBody then U.EditorBody.Activated:Connect(function()showEditor("CORPO")end)end
 if U.EditorItems then U.EditorItems.Activated:Connect(function()showEditor("ITENS")end)end
 if U.EditorEmotes then U.EditorEmotes.Activated:Connect(function()showEditor("EMOTES")end)end
 U.RigR6.Activated:Connect(function()local ok,e=S.SetRig("R6");if not ok then ctx.toast(e)end;refreshBody()end)
 U.RigR15.Activated:Connect(function()local ok,e=S.SetRig("R15");if not ok then ctx.toast(e)end;refreshBody()end)
 for name,ctl in pairs(U.BodyControls or{})do
  local rules=S.ScaleRules and S.ScaleRules()or{};local rule=rules[name]
  if rule then
   ctl.Minus.Activated:Connect(function()local cur=S.GetScale(name)or 1;local ok,e=S.SetScale(name,cur-rule[3]);if not ok then ctx.toast(e)end;refreshBody()end)
   ctl.Plus.Activated:Connect(function()local cur=S.GetScale(name)or 1;local ok,e=S.SetScale(name,cur+rule[3]);if not ok then ctx.toast(e)end;refreshBody()end)
  end
 end
 U.BodyReset.Activated:Connect(function()local ok,e=S.ResetScales();if not ok then ctx.toast(e)else ctx.toast("Proporções restauradas.")end;refreshBody()end)
 U.BuyLook.Activated:Connect(M.Open)
 U.CartClose.Activated:Connect(M.Close)
 U.CartClear.Activated:Connect(function()cart={};refreshCart()end)
 U.CartBuySelected.Activated:Connect(function()
  local items={};for _,e in ipairs(cartRows())do if e.selected~=false then table.insert(items,{id=tonumber(e.item.Id),kind=ctx.A.ItemType(e.item)})end end
  if #items==0 then ctx.toast("Selecione pelo menos um item.");return end
  local _,err=ctx.call("CartPurchase",{items=items});if err then ctx.toast(err)end
 end)
 if S.Changed and S.Changed.Event then S.Changed.Event:Connect(refreshBody)end
 refreshBody();refreshCart();showEditor("AVATAR")
 return M
end

return M
