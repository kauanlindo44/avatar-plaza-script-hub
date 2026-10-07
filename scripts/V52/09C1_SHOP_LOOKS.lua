-- 09C1_SHOP_LOOKS
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V44 - Comunidade curada e Meus looks com prévia maior.
local Players=game:GetService("Players")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local M={}
function M.Init(ctx)
 local U,A,S=ctx.U,ctx.A,ctx.S
 local call,toast,buyBody=ctx.call,ctx.toast,ctx.buyBody
 local savedCache={}
 local activeSaved=nil
 local savedDraft,savedRig=nil,"R15"
 local savedYaw,savedZoom=180,1
 local function clear(p)
  for _,c in ipairs(p:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end
 end
 local function fit(cam,view,m,yaw,zoom)Preview.Fit(cam,view,m,yaw,zoom)end
 local function mount(view,body,rig,yaw,zoom)
  return Preview.Mount(view,body,rig,{yaw=yaw,zoom=zoom,drag=view==U.SavedPreview,changed=view==U.SavedPreview and function(y,z)savedYaw,savedZoom=y,z end or nil})
 end
 local lazyPreviews={};local previewQueued=false
 local function visiblePreviews()
  previewQueued=false
  for i=#lazyPreviews,1,-1 do
   local e=lazyPreviews[i];local v,p=e.view,e.parent
   if not v.Parent or not p.Parent then table.remove(lazyPreviews,i)
   else
    local areaVisible=e.public and U.CommunityArea.Visible or(not e.public and U.LooksArea.Visible)
    local y=v.AbsolutePosition.Y;local top=p.AbsolutePosition.Y;local height=p.AbsoluteWindowSize.Y
    local visible=U.Root.Visible and areaVisible and y+v.AbsoluteSize.Y>top-80 and y<top+height+80
    local model=v:FindFirstChildOfClass("WorldModel")
    if visible and not model then mount(v,e.body,e.rig,180,e.public and 1.06 or 1)
    elseif not visible and model then
     Preview.Unmount(v)
    end
   end
  end
 end
 local function queuePreviews()if not previewQueued then previewQueued=true;task.defer(visiblePreviews)end end
 for _,o in ipairs({U.SavedGrid})do
  o:GetPropertyChangedSignal("CanvasPosition"):Connect(queuePreviews)
  o:GetPropertyChangedSignal("AbsoluteSize"):Connect(queuePreviews)
 end
 for _,o in ipairs({U.Root,U.LooksArea})do o:GetPropertyChangedSignal("Visible"):Connect(queuePreviews)end
 local function resizeGrid(grid,minWidth,extra)
  local w=grid.AbsoluteSize.X;if w<1 then return end
  local layout=grid:FindFirstChildOfClass("UIGridLayout");if not layout then return end
  local cols=w>=600 and 4 or math.clamp(math.floor((w+6)/110),2,4);local cw=math.floor((w-4-(cols-1)*6)/cols)
  local h=grid.AbsoluteSize.Y;local rows=math.clamp(math.floor((h+6)/118),1,4)
  layout.CellPadding=UDim2.fromOffset(6,6)
  layout.CellSize=UDim2.fromOffset(cw,math.max(112,math.min(162,math.floor((h-(rows-1)*6)/rows))));layout.FillDirectionMaxCells=cols
  layout.SortOrder=Enum.SortOrder.LayoutOrder
 end
 U.SavedGrid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()resizeGrid(U.SavedGrid,140,42)end)
 local function info(id)
  local ok,r=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
  return ok and r or nil
 end
 local function refreshDraft()end
 local function renderItems(parent,body,editable)
  clear(parent)
  for _,e in ipairs(A.Entries(body or{}))do
   local id=tonumber(e.Id)
   local f=U.New("Frame",{Size=UDim2.fromOffset(96,56),BackgroundColor3=U.Colors.card},parent);U.Round(f,7)
   U.New("ImageLabel",{Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(92,32),BackgroundTransparency=1,Image=A.AssetThumb(id,150),ScaleType=Enum.ScaleType.Fit},f)
   local t=U.Text(f,"...",{Position=UDim2.fromOffset(2,34),Size=UDim2.new(1,-4,0,18),TextColor3=U.Colors.muted,TextSize=13,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
   if editable then
    local del=U.Button(f,"×",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,2),Size=UDim2.fromOffset(40,40),BackgroundColor3=U.Colors.red,TextSize=13})
    del.Activated:Connect(function()
     if not savedDraft then return end
     local nextBody=A.Remove(savedDraft,id)
     if nextBody then savedDraft=nextBody;refreshDraft()else toast("Não consegui remover esse item.")end
    end)
   end
   task.spawn(function()
    local d=info(id);if not t.Parent then return end
    local price=d and tonumber(d.PriceInRobux);t.Text=price and(price.." Robux")or"—"
   end)
  end
 end
 refreshDraft=function()
  if not activeSaved or not savedDraft then return end
  U.OutfitActions.Visible=true;U.OutfitPublish.Visible=true
  U.OutfitSelected.Text=tostring(activeSaved.name or"Skin").." • "..savedRig..(activeSaved.publicCode and(" • "..activeSaved.publicCode)or"")
  mount(U.SavedPreview,savedDraft,savedRig,savedYaw,savedZoom)
  renderItems(U.SavedItems,savedDraft,true)
  U.OutfitPublish.Text=activeSaved.publicCode and"RETIRAR PUBLICAÇÃO"or"PUBLICAR"
 end
 local function selectSaved(r,reveal)
  activeSaved=r;savedDraft=A.Copy(r.body);savedRig=A.BodyRequiresR15(r.body)and"R15"or tostring(r.rig or"R15")
  savedYaw=180;savedZoom=1;refreshDraft();if reveal then U.SavedPreviewPanel.Visible=true end
 end
 local function card(parent,r)
  local c=U.New("Frame",{BackgroundColor3=U.Colors.card,BorderSizePixel=0},parent);U.Round(c,10);U.New("UIStroke",{Color=U.Colors.line,Transparency=.48,Thickness=1},c)
  local v=U.New("ViewportFrame",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-36),BackgroundColor3=Color3.fromRGB(139,149,167),BorderSizePixel=0},c);U.Round(v,8)
  table.insert(lazyPreviews,{view=v,parent=parent,body=r.body,rig=r.rig,public=false});queuePreviews()
  local hit=U.Button(c,"",{Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false})
  local badge=U.Text(c,tostring(r.rig or"R15"),{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(38,20),BackgroundTransparency=.12,BackgroundColor3=U.Colors.soft,Font=Enum.Font.GothamBold,TextSize=13});U.Round(badge,5)
  U.Text(c,tostring(r.name or"Look"),{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,9,1,-8),Size=UDim2.new(1,-18,0,21),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  hit.Activated:Connect(function()selectSaved(r,true)end)
 end
 local function renderSaved()
  for _,e in ipairs(lazyPreviews)do Preview.Unmount(e.view)end;lazyPreviews={}
  clear(U.SavedGrid);local q=string.lower(tostring(U.LookSearch.Text or""));local shown=0
  for _,r in ipairs(savedCache)do
   if q==""or string.lower(tostring(r.name or"")):find(q,1,true)then shown=shown+1;card(U.SavedGrid,r)end
  end
  if U.SavedCount then U.SavedCount.Text=shown..(shown==1 and" skin"or" skins")end
  if shown==0 then U.OutfitActions.Visible=false;U.OutfitPublish.Visible=false;U.OutfitSelected.Text="Nenhuma skin encontrada. Salve uma no Catálogo ou limpe a pesquisa."end
 end
 local function saved()
  local keepId=activeSaved and activeSaved.id
  local d,e=call("List",{});if not d then toast(e)return end
  savedCache=d.skins or{};renderSaved();if d.persistent==false then toast("Seus looks estão disponíveis apenas nesta sessão.")end
  local pick=nil
  if keepId then for _,r in ipairs(savedCache)do if r.id==keepId then pick=r break end end end
  pick=pick or savedCache[1]
  if pick then
   selectSaved(pick,true)
  else
   activeSaved=nil;savedDraft=nil;U.OutfitActions.Visible=false;U.OutfitPublish.Visible=false;U.OutfitSelected.Text="Seu avatar atual · salve um look";if S.Current then mount(U.SavedPreview,S.Current,S.Rig,180,1);renderItems(U.SavedItems,S.Current,false)end
  end
 end
 local details=require(Rep:WaitForChild("09C8_COMMUNITY_DETAILS")).Init(ctx)
 local feed=require(Rep:WaitForChild("09C7_COMMUNITY_FEED")).Init({U=U,A=A,call=call,toast=toast,show=details.Show})
 ctx.onNamed=feed.Named;ctx.showPublic=details.Show
 U.LookSearch:GetPropertyChangedSignal("Text"):Connect(renderSaved)
 U.SavedPreviewClose.Activated:Connect(function()U.SavedPreviewPanel.Visible=false end)
 U.SavedPreviewToggle.Activated:Connect(function()if activeSaved then U.SavedPreviewPanel.Visible=true else toast("Salve um look primeiro.")end end)
 local function refitSaved()
  local wm=U.SavedPreview:FindFirstChildOfClass("WorldModel")
  local m=wm and wm:FindFirstChildOfClass("Model");local cam=U.SavedPreview.CurrentCamera
  local p=Preview.Get(U.SavedPreview);if p then p.Yaw=savedYaw;p.Zoom=savedZoom;p.Fit()end
 end
 U.SavedLeft.Activated:Connect(function()if activeSaved then savedYaw=(Preview.Get(U.SavedPreview)and Preview.Get(U.SavedPreview).Yaw or savedYaw)-18;refitSaved()end end)
 U.SavedRight.Activated:Connect(function()if activeSaved then savedYaw=(Preview.Get(U.SavedPreview)and Preview.Get(U.SavedPreview).Yaw or savedYaw)+18;refitSaved()end end)
 U.SavedZoomIn.Activated:Connect(function()if activeSaved then savedZoom=math.min(1.6,savedZoom+.12);refitSaved()end end)
 U.SavedZoomOut.Activated:Connect(function()if activeSaved then savedZoom=math.max(.7,savedZoom-.12);refitSaved()end end)
 U.OutfitApply.Activated:Connect(function()
  if not savedDraft then return end;ctx.call("ClearInspect");local ok,e=S.Set(savedDraft,false,savedRig);toast(ok and"Skin carregada na prévia principal."or e);if ok then U.OpenRequest:Fire("Catalog");if U.ShowPreview then U.ShowPreview()end end
 end)
 U.OutfitUpdate.Activated:Connect(function()
  if not activeSaved or not savedDraft then return end
  local d,e=call("Update",{id=activeSaved.id,body=savedDraft,rig=savedRig});if not d then toast(e)return end
  toast(d.persistent==false and"Alterações guardadas apenas nesta sessão."or"Alterações salvas.");saved()
 end)
 U.OutfitRestore.Activated:Connect(function()
  if not activeSaved then return end;savedDraft=A.Copy(activeSaved.body);savedRig=A.BodyRequiresR15(activeSaved.body)and"R15"or tostring(activeSaved.rig or"R15");savedYaw=180;savedZoom=1;refreshDraft();U.SavedPreviewPanel.Visible=true;toast("Skin salva restaurada.")
 end)
 U.OutfitBuy.Activated:Connect(function()if savedDraft then buyBody(savedDraft)end end)
 U.OutfitDelete.Activated:Connect(function()
  if not activeSaved then return end;local _,e=call("Delete",{id=activeSaved.id});if e then toast(e)return end
  activeSaved=nil;savedDraft=nil;U.OutfitActions.Visible=false;U.OutfitPublish.Visible=false;toast("Skin excluída.");saved()
 end)
 U.OutfitPublish.Activated:Connect(function()
  if not activeSaved then return end
  if activeSaved.publicCode then local _,e=call("Unpublish",{id=activeSaved.id});if e then toast(e)return end;toast("Publicação removida.");saved()
  else U.PublishName.Text=tostring(activeSaved.name or"Meu Look");U.PublishBox.Visible=true end
 end)
 U.PublishCancel.Activated:Connect(function()U.PublishBox.Visible=false end)
 U.PublishConfirm.Activated:Connect(function()
  if not activeSaved or not savedDraft then U.PublishBox.Visible=false;return end
  local name=tostring(U.PublishName.Text or""):match("^%s*(.-)%s*$");if name==""then toast("Digite um nome para publicar.");return end
  local up,e=call("Update",{id=activeSaved.id,name=name,body=savedDraft,rig=savedRig});if not up then toast(e)return end
  local d,e2=call("Publish",{id=activeSaved.id});if not d then toast(e2)return end
  U.PublishBox.Visible=false;toast("Publicado na Comunidade! Código: "..tostring(d.code));saved()
 end)
 resizeGrid(U.SavedGrid,140,42)
 return{Saved=saved,Community=function()feed.Open()end,ShowLook=details.Show,Active=function()return activeSaved end,RefreshSaved=renderSaved}
end
print("AVATAR PLAZA V44: Community/Looks carregado")
return M
