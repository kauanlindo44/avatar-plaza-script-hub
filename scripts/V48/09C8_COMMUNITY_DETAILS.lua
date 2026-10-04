-- 09C8_COMMUNITY_DETAILS | ModuleScript | ReplicatedStorage
-- V48: fundo opaco, avatar 360, itens com X e consentimento de uso.
local Rep=game:GetService("ReplicatedStorage")
local Market=game:GetService("MarketplaceService")
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local Cart=require(Rep:WaitForChild("09C4_OUTFIT_LIBRARY"))
local M={}
function M.Init(ctx)
 local U,A,S,call,toast=ctx.U,ctx.A,ctx.S,ctx.call,ctx.toast
 local record,draft=nil,nil;local rig="R15";local generation=0;local controller=nil
 local cache,cacheOrder={},{}
 local function clearItems()for _,o in ipairs(U.LookItems:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end end
 local function info(id)
  local old=cache[id];if old and os.clock()-old.at<90 then return old.data end
  local ok,d=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
  if not ok then return nil end
  if not cache[id]then table.insert(cacheOrder,id)end;cache[id]={data=d,at=os.clock()}
  while #cacheOrder>256 do cache[table.remove(cacheOrder,1)]=nil end;return d
 end
 local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local itemSelected
 local itemPanel=D.Frame(U.LookDetail,{Name="CommunityItemInfo",BackgroundColor3=U.Colors.panel,Visible=false,ZIndex=140})
 local itemClose=D.IconButton(itemPanel,"CloseCommunityItem","close","Fechar item",{Size=UDim2.fromOffset(48,48),ZIndex=150})
 local itemImage=D.New("ImageLabel",{Name="CommunityItemImage",BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=141},itemPanel)
 local itemTitle=D.Text(itemPanel,"",{Font=Enum.Font.GothamBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=141})
 local itemMeta=D.Text(itemPanel,"",{TextSize=13,TextColor3=U.Colors.green,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=141})
 local itemDescription=D.Text(itemPanel,"",{TextSize=12,TextColor3=U.Colors.muted,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=141})
 local itemCart=D.Button(itemPanel,"Carrinho",{TextSize=13,ZIndex=142});local itemTry=D.Button(itemPanel,"Experimentar",{BackgroundColor3=U.Colors.green,TextColor3=U.Colors.bg,TextSize=13,ZIndex=142})
 local function itemLayout()
  local il,it,ir,ib,w,h=U.SafeBounds.Read();local pw=math.min(420,w-il-ir-16);local ph=math.min(300,h-it-ib-16)
  itemPanel.Position=UDim2.fromOffset(il+(w-il-ir-pw)/2,it+(h-it-ib-ph)/2);itemPanel.Size=UDim2.fromOffset(pw,ph)
  itemClose.Position=UDim2.fromOffset(pw-54,4);itemImage.Position=UDim2.fromOffset(8,8);itemImage.Size=UDim2.fromOffset(88,88)
  itemTitle.Position=UDim2.fromOffset(104,6);itemTitle.Size=UDim2.fromOffset(pw-166,52)
  itemMeta.Position=UDim2.fromOffset(104,60);itemMeta.Size=UDim2.fromOffset(pw-112,40)
  itemDescription.Position=UDim2.fromOffset(10,108);itemDescription.Size=UDim2.fromOffset(pw-20,math.max(20,ph-170))
  itemCart.Position=UDim2.fromOffset(10,ph-52);itemCart.Size=UDim2.fromOffset((pw-26)/2,44);itemTry.Position=UDim2.fromOffset(pw/2+3,ph-52);itemTry.Size=itemCart.Size
 end
 local function showItem(item,detail)
  itemSelected=item;itemImage.Image=A.AssetThumb(item.Id,420);itemTitle.Text=item.Name
  itemMeta.Text=(item.PriceInRobux~=nil and(item.PriceInRobux==0 and"GRÁTIS"or item.PriceInRobux.." Robux")or"Consultar preço")..(detail and detail.Creator and("\n@"..tostring(detail.Creator.Name or""))or"")
  itemDescription.Text=detail and tostring(detail.Description or"")or"Os detalhes não carregaram. Tente abrir novamente.";itemPanel.Visible=true;itemLayout()
 end
 itemClose.Activated:Connect(function()itemSelected=nil;itemPanel.Visible=false end)
 itemCart.Activated:Connect(function()if itemSelected then Cart.Add(itemSelected);toast("Item adicionado ao carrinho.")end end)
 itemTry.Activated:Connect(function()if itemSelected then local ok,e=S.Try(itemSelected);toast(ok and"Item experimentado · aplicando no personagem."or e);if ok then itemPanel.Visible=false end end end)
 U.SafeBounds.Watch(itemLayout)
 local function mount()
  local yaw,zoom=controller and controller.Yaw or 180,controller and controller.Zoom or 1
  if controller then controller.Destroy()end
  if draft then controller=Preview.Mount(U.LookPreview,draft,rig,{drag=true,yaw=yaw,zoom=zoom})end
  U.LookRigToggle.Text=rig;U.LookMeta.Text=rig..(record and record.character and" • Referência nos nomes das roupas"or"")
 end
 local renderItems
 renderItems=function()
  clearItems();local mine=generation;local entries=A.Entries(draft);local nextIndex=0;local remaining=#entries;local total,missing=0,0
  U.LookTotal.Text=#entries==0 and"Sem itens compráveis"or"Consultando os preços..."
  local cards={}
  for i,e in ipairs(entries)do
   local card=U.Button(U.LookItems,"",{Name="LookItem_"..e.Id,LayoutOrder=i,BackgroundColor3=U.Colors.card,ZIndex=84})
   local padding=card:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
   U.New("ImageLabel",{Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,1,-28),BackgroundTransparency=1,Image=A.AssetThumb(e.Id,420),ScaleType=Enum.ScaleType.Fit,Active=false,ZIndex=85},card)
   local name=U.Text(card,"Item "..e.Id,{Position=UDim2.new(0,5,1,-24),Size=UDim2.new(1,-10,0,22),TextSize=13,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=85})
   local rm=U.Button(card,"×",{Name="RemoveLookItem",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,2),Size=UDim2.fromOffset(40,40),BackgroundColor3=U.Colors.soft,TextSize=22,ZIndex=87})
   rm.Activated:Connect(function()
    if generation~=mine then return end
    local changed,err=A.Remove(draft,e.Id);if not changed then toast(err);return end
    draft=changed;generation=generation+1;record.character=nil;U.LookName.Text="Edição de "..tostring(record.name or"look");mount();renderItems()
   end)
   cards[i]={root=card,name=name,item={Id=e.Id,Name="Item "..e.Id,ItemType="Asset"},detail=nil}
   card.Activated:Connect(function()if generation==mine and cards[i].item then showItem(cards[i].item,cards[i].detail)end end)
  end
  for _=1,math.min(3,#entries)do task.spawn(function()
   while generation==mine do
    nextIndex=nextIndex+1;local i=nextIndex;local entry=entries[i];if not entry then return end
    local d=info(entry.Id);if generation~=mine then return end
    local p=d and tonumber(d.PriceInRobux);local card=cards[i]
    if p then total=total+p else missing=missing+1 end
    card.name.Text=d and tostring(d.Name)or("Item "..entry.Id)
    card.detail=d;card.item={Id=entry.Id,Name=card.name.Text,ItemType="Asset",AssetType=d and d.AssetTypeId,PriceInRobux=p}
    if itemPanel.Visible and itemSelected and itemSelected.Id==entry.Id then showItem(card.item,d)end
    remaining=remaining-1
    if remaining==0 then U.LookTotal.Text=(missing>0 and"Subtotal: "or"Total: ")..math.floor(total).." Robux"..(missing>0 and" • preços a consultar"or"")end
   end
  end)end
  U.LayoutLookDetail()
 end
 local function paint(r,mine)
  if mine~=generation then return end;record=A.Copy(r);draft=A.Copy(r.body);rig=tostring(r.rig or"R15")
  U.LookName.Text=tostring(r.name or"Look")
  U.LookCreator.Visible=false;U.LookCreator.Text="Publicado por @"..tostring(r.publisher or r.username or"")..(r.sourceUsername and(" • Avatar de @"..r.sourceUsername)or"")
  U.LookCodeBox.Text=tostring(r.code or"SEM CÓDIGO");U.LookFav.Text=(r.source=="Roblox"or r.source=="Curated")and"Salvar"or r.liked and"Curtido"or"Curtir"
  U.LookTry.Active=r.source~="Player"or r.allowCopy==true;U.LookTry.Text=U.LookTry.Active and"Experimentar"or"Uso desativado pelo dono";U.LookBuy.Active=true;U.LookFav.Active=true
  mount();renderItems()
  if r.source=="Roblox"and not r.checkedAt then task.spawn(function()
   local data=call("DiscoverResearch",{id=r.owner});if generation~=mine or not record then return end
   if data then record.character=data.character;record.name=data.name;U.LookName.Text=data.name;U.LookMeta.Text=rig..(data.character and" • Referência nos nomes das roupas"or"")
    if ctx.onNamed then ctx.onNamed(r.id,data.name)end
   end
  end)end
 end
 local function show(r)
  generation=generation+1;local mine=generation;itemPanel.Visible=false;record=nil;draft=nil
  U.LookDetail.Visible=true;U.LookName.Text=tostring(r.name or"Carregando avatar...")
  U.LookCreator.Visible=false;U.LookCreator.Text="Publicado por @"..tostring(r.publisher or r.username or"")..(r.sourceUsername and(" • Avatar de @"..r.sourceUsername)or"")
  U.LookMeta.Text="Carregando avatar...";U.LookCodeBox.Text="SEM CÓDIGO";U.LookTotal.Text="";clearItems();Preview.Unmount(U.LookPreview);controller=nil
  U.LookTry.Active=false;U.LookBuy.Active=false;U.LookFav.Active=false;U.LayoutLookDetail()
  if r.body then paint(r,mine)
  else task.spawn(function()
   local data,err=call("DiscoverAvatar",{id=r.owner})
   if mine~=generation then return end
   if data then paint(data,mine)else U.LookMeta.Text=err or"Avatar indisponível."end
  end)end
 end
 local function close()
  generation=generation+1;itemSelected=nil;itemPanel.Visible=false;record=nil;draft=nil;Preview.Unmount(U.LookPreview);controller=nil;clearItems();U.LookDetail.Visible=false
 end
 U.LookClose.Activated:Connect(close)
 for i,b in ipairs(U.LookViews)do b.Activated:Connect(function()if controller then controller.SetYaw(({180,0,90,270})[i])end end)end
 U.LookRigToggle.Activated:Connect(function()if draft then rig=rig=="R15"and"R6"or"R15";mount()end end)
 U.LookTry.Activated:Connect(function()
  if not draft or not U.LookTry.Active then return end
  if record and record.source=="Player"then local allowed,reason=call("InspectUse",{id=record.owner});if not allowed then toast(reason);return end
  else call("ClearInspect")end
  local ok,err=S.Set(draft,false,rig);if not ok then toast(err);return end
  close();U.OpenRequest:Fire("Catalog");if U.ShowPreview then U.ShowPreview()end;toast("Look na prévia · aplicando no personagem.")
 end)
 U.LookBuy.Activated:Connect(function()if draft and U.LookBuy.Active then ctx.buyBody(draft)end end)
 U.LookFav.Activated:Connect(function()
  if not record or not draft or not U.LookFav.Active then return end;local mine=generation;U.LookFav.Active=false
  if record.source=="Player"then local d,e=call("InspectLike",{id=record.owner});if generation~=mine then return end;U.LookFav.Active=true;toast(d and("Curtida registrada • "..d.likes.." curtidas")or e)
  elseif record.source=="Roblox"or record.source=="Curated"then
   local result,err=call("Save",{name=record.name,body=draft,rig=rig});if generation~=mine then return end;U.LookFav.Active=true
   toast(result and"Look salvo em Meus looks."or err)
  else
   local d,err=call("Favorite",{id=record.id,value=not record.liked});if generation~=mine then return end;U.LookFav.Active=true
   if d then record.liked=d.liked;record.likes=d.likes;U.LookFav.Text=d.liked and"Curtido"or"Curtir"else toast(err)end
  end
 end)
 U.LookCopy.Activated:Connect(function()
  if not record or not record.code then return end
  U.LookCodeBox.TextEditable=true;U.LookCodeBox:CaptureFocus();U.LookCodeBox.SelectionStart=1;U.LookCodeBox.CursorPosition=#record.code+1
  toast("Código selecionado para copiar.")
 end)
 U.Root:GetPropertyChangedSignal("Visible"):Connect(function()if not U.Root.Visible then close()end end)
 return{Show=show,Close=close,Active=function()return record,draft end}
end
return M
