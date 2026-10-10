-- 09C4_OUTFIT_LIBRARY | ModuleScript | ReplicatedStorage | V55 (SUBSTITUIR)
-- AVATAR PLAZA V44: itens com X, corpo em popup e paginas exclusivas de Carrinho/Plus.
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=Fx.Colors
local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local Native=require(Rep:WaitForChild('08B2_BODY_DESCRIPTION'))
local M={VERSION="V55"}
local CTX=nil
local cart={}
local function key(item)
 local id=tonumber(item and item.Id)
 if not id or id<=0 or id%1~=0 then return nil end
 return CTX.A.ItemType(item)..":"..tostring(id)
end
local mode="Selected";local outfit={};local outfitBody;local choices={};local quoteGeneration=0;local quoting=false
local quoteError;local previewKey
local function rows()
 local out={};for _,v in pairs(mode=="Outfit"and outfit or cart)do table.insert(out,v)end
 table.sort(out,function(a,b)return tostring(a.item.Name or a.key)<tostring(b.item.Name or b.key)end);return out
end
local function clear(p)
 for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end
end
local refreshCart;local layoutItems
local function refreshPreview()
 if not CTX or not CTX.U.CartPanel.Visible or not CTX.U.CartPreviewStage.Visible then return end
 local body=mode=='Outfit'and outfitBody or CTX.S.Current;if not body then return end
 local rig=CTX.A.BodyRequiresR15(body)and'R15'or CTX.S.Rig;local k=Native.Key(CTX.A,body,rig,false)
 if k==previewKey and Preview.Get(CTX.U.CartPreview)then return end;previewKey=k
 Preview.Mount(CTX.U.CartPreview,body,rig,{drag=true})
end
local function syncOutfit()
 outfitBody=CTX.S.Current and CTX.A.Copy(CTX.S.Current)
 local current={};for _,e in ipairs(CTX.S.Current and CTX.A.Entries(CTX.S.Current)or{})do
  local k="Asset:"..e.Id;current[k]=outfit[k]or{key=k,item={Id=e.Id,Name=e.Slot.." • "..e.Id,ItemType="Asset"},selected=true}
 end;outfit=current
end
local function quote()
 if not CTX then return end;quoteGeneration=quoteGeneration+1;local mine=quoteGeneration;local entries=rows();quoting=true;quoteError=nil;refreshCart()
 task.spawn(function()
  if mode=="Outfit"then
   local data,e=CTX.call("OutfitQuote",{body=CTX.A.Copy(outfitBody or CTX.S.Current)});if mine~=quoteGeneration then return end
   if not data then quoting=false;quoteError=e or'Não foi possível consultar o look. Toque em Recarregar.';refreshCart();return end
   local resolved={}
   for _,d in ipairs(data.items or{})do
    local k=d.kind..":"..d.id
    resolved[k]={key=k,item={Id=d.id,Name=d.name or "Item "..d.id,ItemType=d.kind,Price=d.price},selected=choices[k]~=false,
     owned=d.owned,unavailable=d.unavailable,quoted=d.known}
   end
   outfit=resolved;quoting=false;refreshCart();return
  end
  for offset=1,#entries,20 do
   local items={};for i=offset,math.min(offset+19,#entries)do local e=entries[i];items[#items+1]={id=e.item.Id,kind=CTX.A.ItemType(e.item)}end
   local data,err=CTX.call("CartQuote",{items=items});if mine~=quoteGeneration then return end
   if data then for i,d in ipairs(data.items)do local e=entries[offset+i-1];e.owned=d.owned;e.unavailable=d.unavailable;e.item.Name=d.name or e.item.Name;e.item.Price=d.price;e.quoted=true end end
   if not data then quoteError=err or'Alguns preços não carregaram. Toque em Recarregar.'end
   refreshCart()
  end
  quoting=false;refreshCart()
 end)
end
refreshCart=function()
 if not CTX then return end
 local U,A=CTX.U,CTX.A;clear(U.CartList)
 local layout=U.CartList:FindFirstChildOfClass('UIGridLayout');local previous=U.CartList:FindFirstChildOfClass('UIListLayout');if previous then previous:Destroy()end
 if not layout then layout=U.New('UIGridLayout',{SortOrder=Enum.SortOrder.LayoutOrder},U.CartList)end
 local cols=U.CartList.AbsoluteSize.X>=660 and 2 or 1;layout.FillDirectionMaxCells=cols;layout.CellPadding=UDim2.fromOffset(6,6);layout.CellSize=UDim2.fromOffset(math.floor((U.CartList.AbsoluteSize.X-6*(cols-1)-4)/cols),88)
 local total,selected,count,unknown=0,0,0,0;local list=rows()
 U.CartSelected.BackgroundColor3=mode=='Selected'and Color3.fromRGB(40,88,78)or C.panel
 U.CartOutfit.BackgroundColor3=mode=='Outfit'and Color3.fromRGB(40,88,78)or C.panel
 if #list==0 then U.Text(U.CartList,'Adicione itens pelo catálogo ou escolha Look completo.',{TextSize=14,TextColor3=U.Colors.muted})end
 for _,entry in ipairs(list)do
  if mode=='Outfit'then choices[entry.key]=entry.selected end
  count=count+1;local item=entry.item;local p=A.Price(item)
  if entry.selected and entry.owned~=true and not entry.unavailable then selected=selected+1;if p~=nil then total=total+p else unknown=unknown+1 end end
  local row=U.New('Frame',{Name='CartItem_'..item.Id,LayoutOrder=count,BackgroundColor3=C.panel,BorderSizePixel=0},U.CartList);U.Round(row,9);Fx.Surface(row,C.panel,Color3.fromRGB(31,52,65),entry.selected and C.jade or U.Colors.line)
  local check=U.Button(row,entry.owned and'✓'or entry.selected and'✓'or'○',{Name='SelectCartItem',Position=UDim2.fromOffset(4,22),Size=UDim2.fromOffset(44,44),BackgroundColor3=entry.selected and C.jade or U.Colors.soft,TextColor3=entry.selected and C.navy or U.Colors.white});Fx.Button(check,C.jade)
  check.Active=entry.owned~=true and not entry.unavailable
  U.New('ImageLabel',{Position=UDim2.fromOffset(52,10),Size=UDim2.fromOffset(64,64),BackgroundTransparency=1,Image=A.Thumbnail(item,150),ScaleType=Enum.ScaleType.Fit},row)
  U.Text(row,tostring(item.Name or'Item'),{Position=UDim2.fromOffset(122,10),Size=UDim2.new(1,-174,0,36),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=true})
  local price=entry.owned and"JÁ NO SEU INVENTÁRIO"or entry.unavailable and "INDISPONÍVEL"or p==nil and"CONSULTAR NO ROBLOX"or p==0 and"GRÁTIS"or tostring(math.floor(p)).." Robux"
  U.Text(row,price,{Position=UDim2.fromOffset(122,54),Size=UDim2.new(1,-174,0,22),TextColor3=entry.owned and U.Colors.muted or C.gold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  local rm=U.Button(row,'×',{Name='RemoveCartItem',AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-4,.5,0),Size=UDim2.fromOffset(44,44),BackgroundColor3=U.Colors.soft});Fx.Button(rm,C.blue)
  check.Activated:Connect(function()if entry.owned or entry.unavailable then return end;entry.selected=not entry.selected;refreshCart()end)
  rm.Activated:Connect(function()if mode=="Outfit"then entry.selected=false else cart[entry.key]=nil end;refreshCart()end)
 end
 U.CartCount.Text=selected..' selecionados · '..count..(mode=='Outfit'and' no look' or' no carrinho');U.CartCount.TextWrapped=false;U.CartCount.TextTruncate=Enum.TextTruncate.AtEnd
 U.CartTotal.Text=(unknown>0 and'Subtotal: 'or'Estimativa: ')..math.floor(total)..' Robux'
 U.CartHint.Text=quoteError or(quoting and'Consultando preços e itens que você já possui…'or unknown>0 and(unknown..' preços a consultar · confirme o total no Roblox.')or mode=='Outfit'and'Itens do look · marque quais deseja comprar.'or'Itens escolhidos no catálogo · confirme o total no Roblox.');U.CartHint.TextColor3=quoteError and U.Colors.red or U.Colors.muted;U.CartHint.TextWrapped=false;U.CartHint.TextTruncate=Enum.TextTruncate.AtEnd
 U.CartBuySelected.Text=selected>20 and'Comprar próximos 20'or selected>0 and('Comprar '..selected..' itens')or'Selecione itens';U.BuyLook.Text=''
 U.CartBuySelected.Active=not quoting and selected>0;U.CartBuySelected.AutoButtonColor=U.CartBuySelected.Active
 if quoting then U.CartBuySelected.Text='Consultando…'end
 U.CartRefresh.Active=not quoting
end
function M.Add(item,quiet)
 if not CTX then return false end;local k=key(item);if not k then return false end
 cart[k]=cart[k]or{key=k,item=CTX.A.Copy(item),selected=true};cart[k].selected=true
 refreshCart();if not quiet then CTX.toast("Adicionado ao carrinho.")end;return true
end
function M.Open(body)
 if not CTX then return end
 if type(body)=="table"and body.props then
  outfitBody=CTX.A.Copy(body);choices={}
  outfit={};for _,e in ipairs(CTX.A.Entries(body))do local k="Asset:"..e.Id;outfit[k]={key=k,item={Id=e.Id,Name=e.Slot.." • "..e.Id,ItemType="Asset"},selected=true}end;mode="Outfit"
 elseif mode=="Outfit"then syncOutfit()end
 refreshCart();if CTX.openUtility then CTX.openUtility('Cart')else CTX.U.CartPanel.Visible=true end;refreshPreview();quote()
end
function M.Close()if CTX then quoteGeneration=quoteGeneration+1;quoting=false;if CTX.closeUtility then CTX.closeUtility()else CTX.U.CartPanel.Visible=false end end end
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
 local U,A,S=CTX.U,CTX.A,CTX.S;U.ItemStrip.Visible=true;clear(U.ItemStrip);layoutItems()
 local entries=S.Current and A.Entries(S.Current)or{}
 U.Total.Text=#entries.." itens"
 if #entries==0 then U.Text(U.ItemStrip,"Sem itens",{Size=UDim2.fromOffset(104,44),TextColor3=U.Colors.muted});return end
 for _,e in ipairs(entries)do
  local row=U.New("Frame",{Name="Equipped_"..e.Id,Size=UDim2.fromOffset(110,64),BackgroundColor3=U.Colors.card,BorderSizePixel=0},U.ItemStrip);U.Round(row,8)
  U.New("ImageLabel",{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(60,58),BackgroundTransparency=1,
   Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},row)
  row:SetAttribute("ItemId",e.Id);row:SetAttribute("Slot",e.Slot)
  local rm=U.Button(row,"X",{Name="RemoveItem",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-3,0,10),Size=UDim2.fromOffset(44,44),BackgroundColor3=U.Colors.panel,TextSize=16})
  rm.Activated:Connect(function()local ok,err=S.Remove(e.Id);if not ok then CTX.toast(err)end end)
 end
end
layoutItems=function()
 if not CTX then return end
 local U=CTX.U;local strip=U.ItemStrip;local wrap=strip.AbsoluteSize.Y>=132
 local existing=strip:FindFirstChildOfClass("UIListLayout")or strip:FindFirstChildOfClass("UIGridLayout")
 local wanted=wrap and"UIGridLayout"or"UIListLayout"
 if existing and existing.ClassName~=wanted then existing:Destroy();existing=nil end
 if not existing then existing=U.New(wanted,{},strip)end
 existing.SortOrder=Enum.SortOrder.LayoutOrder
 if wrap then
  local cols=math.max(1,math.floor(strip.AbsoluteSize.X/114))
  existing.CellSize=UDim2.fromOffset(math.floor((strip.AbsoluteSize.X-(cols-1)*6-4)/cols),64)
  existing.CellPadding=UDim2.fromOffset(6,6);existing.FillDirectionMaxCells=cols
  strip.ScrollingDirection=Enum.ScrollingDirection.Y;strip.AutomaticCanvasSize=Enum.AutomaticSize.Y
 else existing.FillDirection=Enum.FillDirection.Horizontal;existing.Padding=UDim.new(0,6)
  strip.ScrollingDirection=Enum.ScrollingDirection.X;strip.AutomaticCanvasSize=Enum.AutomaticSize.X
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
 U.ItemStrip:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutItems);layoutItems()
 S.Changed.Event:Connect(refreshItems);refreshItems()
 require(Rep:WaitForChild('09A4_UTILITY_SKIN')).Bind(U,ctx.A,S,Preview)
 U.CartList:GetPropertyChangedSignal('AbsoluteSize'):Connect(refreshCart)
 U.CartPreviewStage:GetPropertyChangedSignal('Visible'):Connect(refreshPreview)
 U.CartPanel:GetPropertyChangedSignal('Visible'):Connect(function()if U.CartPanel.Visible then refreshPreview()else quoteGeneration=quoteGeneration+1;quoting=false;Preview.Unmount(U.CartPreview);previewKey=nil end end)
 U.CartRefresh.Activated:Connect(quote)
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
 U.CartSelected.Activated:Connect(function()mode='Selected';refreshCart();refreshPreview();quote()end)
 U.CartOutfit.Activated:Connect(function()mode='Outfit';syncOutfit();refreshCart();refreshPreview();quote()end)
 U.CartClear.Activated:Connect(function()if mode=="Outfit"then for _,e in pairs(outfit)do e.selected=false end else cart={}end;refreshCart()end)
 Market.PromptBulkPurchaseFinished:Connect(function(who)if who==ctx.pl then quote()end end)
 local buying=false
 U.CartBuySelected.Activated:Connect(function()
  if buying or quoting then return end
  local items={};for _,e in ipairs(rows())do
   if e.selected and not e.owned and not e.unavailable then table.insert(items,{id=tonumber(e.item.Id),kind=ctx.A.ItemType(e.item)})end
  end
  if #items==0 then ctx.toast("Selecione pelo menos um item.");return end
    buying=true;local d,err=ctx.call("CartPurchase",{items=items});buying=false
  ctx.toast(d and(d.count==0 and"Você já possui os itens selecionados."or"Compra aberta. Confira o preço final no Roblox.")or err)
 end)
 S.Changed.Event:Connect(function()refreshBody();if mode=='Outfit'then syncOutfit();refreshCart();if U.CartPanel.Visible then quote()else quoteGeneration=quoteGeneration+1;quoting=false end end;refreshPreview()end)
 refreshBody();refreshItems();refreshCart()
 return M
end
return M
