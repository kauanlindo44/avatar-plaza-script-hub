-- 09C4_OUTFIT_LIBRARY
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V38 - editor lateral: AVATAR / CORPO / ITENS / EMOTES + carrinho.

local M={};local CTX=nil;local cart={}
local function key(item)if not item then return nil end;local id=tonumber(item.Id);if not id then return nil end;local kind=CTX and CTX.A and CTX.A.ItemType(item)or"Asset";return tostring(kind)..":"..id end
local function rows()local out={};for _,v in pairs(cart)do table.insert(out,v)end;table.sort(out,function(a,b)return tostring(a.item.Name or"")<tostring(b.item.Name or"")end);return out end
local function clear(p)if not p then return end;for _,c in ipairs(p:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end end
local function refreshCart()
 if not CTX then return end;local U,A=CTX.U,CTX.A;clear(U.CartList);local total,selected,count=0,0,0
 for _,entry in ipairs(rows())do count=count+1;local item=entry.item;local price=A.Price(item);if entry.selected~=false then selected=selected+1;if price then total=total+price end end
  local row=U.New("Frame",{Size=UDim2.new(1,-4,0,60),BackgroundColor3=Color3.fromRGB(38,40,45),BorderSizePixel=0},U.CartList);U.Round(row,9)
  local check=U.Button(row,entry.selected~=false and"ON"or"OFF",{Position=UDim2.fromOffset(7,13),Size=UDim2.fromOffset(40,34),BackgroundColor3=entry.selected~=false and U.Colors.green or U.Colors.soft,TextColor3=entry.selected~=false and U.Colors.bg or U.Colors.white,TextSize=6})
  local im=U.New("ImageLabel",{Position=UDim2.fromOffset(54,6),Size=UDim2.fromOffset(48,48),BackgroundColor3=Color3.fromRGB(52,54,59),BorderSizePixel=0,Image=A.Thumbnail(item,150),ScaleType=Enum.ScaleType.Fit},row);U.Round(im,7)
  U.Text(row,tostring(item.Name or"Item"),{Position=UDim2.fromOffset(110,7),Size=UDim2.new(1,-224,0,20),Font=Enum.Font.GothamBold,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  U.Text(row,A.PriceText(item),{Position=UDim2.fromOffset(110,31),Size=UDim2.new(1,-224,0,17),TextColor3=U.Colors.green,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left})
  local rm=U.Button(row,"X",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.fromOffset(34,34),BackgroundColor3=U.Colors.red,TextSize=8})
  check.Activated:Connect(function()entry.selected=not(entry.selected~=false);refreshCart()end);rm.Activated:Connect(function()cart[entry.key]=nil;refreshCart()end)
 end
 U.CartCount.Text=selected.." selecionado(s) • "..count.." no carrinho";U.CartTotal.Text="TOTAL: "..total.." R$";U.CartBuySelected.Text=selected>0 and("COMPRAR "..selected.." ITEM(NS)")or"SELECIONE ITENS";U.BuyLook.Text=count>0 and("CARRINHO ("..count..")")or"CARRINHO"
end
function M.Add(item)if not CTX then return false end;local k=key(item);if not k then return false end;cart[k]={key=k,item=item,selected=true};refreshCart();CTX.toast("Adicionado ao carrinho.");return true end
function M.Open()if CTX then refreshCart();CTX.U.CartPanel.Visible=true end end
function M.Close()if CTX then CTX.U.CartPanel.Visible=false end end
function M.Count()local n=0;for _ in pairs(cart)do n=n+1 end;return n end

local function refreshBody()
 if not CTX then return end;local U,S=CTX.U,CTX.S;local rig=S.GetRig and S.GetRig()or S.Rig or"R15";U.RigR6.BackgroundColor3=rig=="R6"and U.Colors.green or U.Colors.soft;U.RigR15.BackgroundColor3=rig=="R15"and U.Colors.green or U.Colors.soft;U.BodyNote.Text=rig=="R6"and"R6: corpo clássico, sem escalas R15."or"R15: ajuste corpo e proporções antes de aplicar."
 for name,ctl in pairs(U.BodyControls or{})do local v=S.GetScale and S.GetScale(name)or 1;ctl.Value.Text=string.format("%.2f",tonumber(v)or 1)end
end
local function refreshItems()
 if not CTX or not CTX.U.ItemsPanel then return end;local U,A,S=CTX.U,CTX.A,CTX.S;clear(U.ItemsPanel)
 local entries=S.Current and A.Entries(S.Current)or{};if #entries==0 then U.Text(U.ItemsPanel,"Nenhum item equipado.",{Size=UDim2.new(1,-8,0,34),TextColor3=U.Colors.muted,TextSize=6});return end
 for _,e in ipairs(entries)do local row=U.New("Frame",{Size=UDim2.new(1,-4,0,48),BackgroundColor3=Color3.fromRGB(39,41,46),BorderSizePixel=0},U.ItemsPanel);U.Round(row,8);U.New("ImageLabel",{Position=UDim2.fromOffset(5,5),Size=UDim2.fromOffset(38,38),BackgroundTransparency=1,Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},row);U.Text(row,tostring(e.Slot or"ITEM").."  •  "..tostring(e.Id),{Position=UDim2.fromOffset(49,7),Size=UDim2.new(1,-96,0,32),TextSize=6,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false});local rm=U.Button(row,"X",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.fromOffset(30,30),BackgroundColor3=U.Colors.red});rm.Activated:Connect(function()local ok,e2=S.Remove(e.Id);if not ok then CTX.toast(e2)end end)end
end
local function show(name)
 if not CTX then return end;local U=CTX.U;local avatar=name=="AVATAR";local body=name=="CORPO";local items=name=="ITENS";local emotes=name=="EMOTES"
 U.Tools.Visible=avatar;U.Total.Visible=avatar;U.ItemStrip.Visible=avatar;U.BodyPanel.Visible=body;U.ItemsPanel.Visible=items;U.EmotePanel.Visible=emotes
 for tab,b in pairs(U.EditorTabButtons or{})do b.BackgroundColor3=tab==name and U.Colors.soft or Color3.fromRGB(39,41,46)end
 if type(U.LayoutEditor)=="function"then U.LayoutEditor(name)end
 if body then refreshBody()elseif items then refreshItems()end
end

function M.Init(ctx)
 CTX=ctx;local U,S=ctx.U,ctx.S
 U.EditorAvatar.Activated:Connect(function()show("AVATAR")end);U.EditorBody.Activated:Connect(function()show("CORPO")end);U.EditorItems.Activated:Connect(function()show("ITENS")end);U.EditorEmotes.Activated:Connect(function()show("EMOTES")end);if U.OpenEmotes then U.OpenEmotes.Activated:Connect(function()if U.OpenRequest then U.OpenRequest:Fire("Emotes")end end)end
 U.RigR6.Activated:Connect(function()local ok,e=S.SetRig("R6");if not ok then ctx.toast(e)end;refreshBody()end);U.RigR15.Activated:Connect(function()local ok,e=S.SetRig("R15");if not ok then ctx.toast(e)end;refreshBody()end)
 for name,ctl in pairs(U.BodyControls or{})do local rule=(S.ScaleRules and S.ScaleRules()or{})[name];if rule then ctl.Minus.Activated:Connect(function()local ok,e=S.SetScale(name,(S.GetScale(name)or 1)-rule[3]);if not ok then ctx.toast(e)end;refreshBody()end);ctl.Plus.Activated:Connect(function()local ok,e=S.SetScale(name,(S.GetScale(name)or 1)+rule[3]);if not ok then ctx.toast(e)end;refreshBody()end)end end
 U.BodyReset.Activated:Connect(function()local ok,e=S.ResetScales();ctx.toast(ok and"Proporções restauradas."or e);refreshBody()end)
 U.BuyLook.Activated:Connect(M.Open);U.CartClose.Activated:Connect(M.Close);U.CartClear.Activated:Connect(function()cart={};refreshCart()end)
 U.CartBuySelected.Activated:Connect(function()local items={};for _,e in ipairs(rows())do if e.selected~=false then table.insert(items,{id=tonumber(e.item.Id),kind=ctx.A.ItemType(e.item)})end end;if #items==0 then ctx.toast("Selecione pelo menos um item.");return end;local _,err=ctx.call("CartPurchase",{items=items});if err then ctx.toast(err)end end)
 if S.Changed and S.Changed.Event then S.Changed.Event:Connect(function()refreshBody();refreshItems()end)end
 refreshBody();refreshItems();refreshCart();show("AVATAR");print("AVATAR PLAZA V38: editor lateral + carrinho carregado");return M
end
return M
