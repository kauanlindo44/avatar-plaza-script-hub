-- 09C1_SHOP_LOOKS
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V39 - Community editorial + Minhas Skins limpas e preview mais clara.
local Players=game:GetService("Players")
local Market=game:GetService("MarketplaceService")
local M={}
function M.Init(ctx)
 local U,A,S=ctx.U,ctx.A,ctx.S
 local call,toast,buyBody=ctx.call,ctx.toast,ctx.buyBody
 local savedCache,communityCache={},{}
 local activeSaved,activePublic=nil,nil
 local communityMode="NOVOS"
 local communityFinished=true
 local featuredPublic=nil
 local savedDraft,savedRig=nil,"R15"
 local detailGen=0
 local savedYaw,savedZoom=180,.76
 local function clear(p)
  for _,c in ipairs(p:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end
 end
 local function bodyBounds(m)
  local minX,minY,minZ=math.huge,math.huge,math.huge
  local maxX,maxY,maxZ=-math.huge,-math.huge,-math.huge
  local found=0
  for _,p in ipairs(m:GetDescendants())do
   if p:IsA("BasePart")and p.Name~="HumanoidRootPart"then
    local pos=p.Position;local half=p.Size*.5
    minX=math.min(minX,pos.X-half.X);minY=math.min(minY,pos.Y-half.Y);minZ=math.min(minZ,pos.Z-half.Z)
    maxX=math.max(maxX,pos.X+half.X);maxY=math.max(maxY,pos.Y+half.Y);maxZ=math.max(maxZ,pos.Z+half.Z)
    found=found+1
   end
  end
  if found<2 then return m:GetBoundingBox()end
  local mn=Vector3.new(minX,minY,minZ);local mx=Vector3.new(maxX,maxY,maxZ)
  return CFrame.new((mn+mx)*.5),mx-mn
 end
 local function fit(cam,view,m,yaw,zoom)
  local cf,size=bodyBounds(m);local vp=view.AbsoluteSize
  local aspect=math.max(vp.X,1)/math.max(vp.Y,1);local fov=math.rad(cam.FieldOfView)
  local margin=1.30
  local vd=size.Y*.5*margin/math.tan(fov*.5)
  local hf=2*math.atan(math.tan(fov*.5)*aspect)
  local hd=size.X*.5*margin/math.tan(hf*.5)
  local dist=(math.max(vd,hd)+size.Z*.10)/math.clamp(zoom or 1,.6,1.8)
  -- Centraliza o conjunto inteiro, incluindo acessórios, para não cortar cabeça, pernas ou UGC.
  local target=cf.Position
  cam.CFrame=CFrame.lookAt(target+CFrame.Angles(0,math.rad(yaw or 180),0).LookVector*-dist,target)
 end
 local function mount(view,body,rig,yaw,zoom)
  for _,c in ipairs(view:GetChildren())do if c:IsA("WorldModel")or c:IsA("Camera")then c:Destroy()end end
  local wm=Instance.new("WorldModel");wm.Parent=view
  local cam=Instance.new("Camera");cam.FieldOfView=27;cam.Parent=view;view.CurrentCamera=cam
  view.Ambient=Color3.fromRGB(238,240,243);view.LightColor=Color3.fromRGB(255,255,255);view.LightDirection=Vector3.new(-.52,-1,-.5)
  local mountedModel=nil
  local resizeConn
  resizeConn=view:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
   local m=mountedModel
   if wm.Parent~=view then if resizeConn then resizeConn:Disconnect();resizeConn=nil end;return end
   if m and m.Parent and cam.Parent then
    task.defer(function()if m.Parent and cam.Parent and wm.Parent==view then fit(cam,view,m,yaw or 180,zoom or 1)end end)
   end
  end)
  wm.Destroying:Connect(function()if resizeConn then resizeConn:Disconnect();resizeConn=nil end end)
  task.spawn(function()
   local d=A.Unpack(body);local rt=rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
   local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(d,rt)end);d:Destroy()
   if not ok or not m or not view.Parent or wm.Parent~=view then if m then m:Destroy()end return end
   for _,v in ipairs(m:GetDescendants())do
    if v:IsA("BasePart")then v.CanCollide=false;v.CanTouch=false;v.CanQuery=false
    elseif v:IsA("Script")or v:IsA("LocalScript")then v:Destroy()end
   end
   m.Parent=wm;m:PivotTo(CFrame.new());mountedModel=m;fit(cam,view,m,yaw or 180,zoom or 1)
   task.delay(.12,function()if m.Parent and cam.Parent then fit(cam,view,m,yaw or 180,zoom or 1)end end)
  end)
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
     for _,o in ipairs(v:GetChildren())do if o:IsA("WorldModel")or o:IsA("Camera")then o:Destroy()end end
    end
   end
  end
 end
 local function queuePreviews()if not previewQueued then previewQueued=true;task.defer(visiblePreviews)end end
 for _,o in ipairs({U.SavedGrid,U.CommunityGrid})do
  o:GetPropertyChangedSignal("CanvasPosition"):Connect(queuePreviews)
  o:GetPropertyChangedSignal("AbsoluteSize"):Connect(queuePreviews)
 end
 for _,o in ipairs({U.Root,U.LooksArea,U.CommunityArea})do o:GetPropertyChangedSignal("Visible"):Connect(queuePreviews)end
 local function resizeGrid(grid,minWidth,extra)
  local w=grid.AbsoluteSize.X;if w<1 then return end
  local layout=grid:FindFirstChildOfClass("UIGridLayout");if not layout then return end
  local cols=math.max(1,math.floor((w-4)/(minWidth+8)));local cw=math.floor((w-12-(cols-1)*8)/cols)
  layout.CellSize=UDim2.fromOffset(cw,cw+extra);layout.FillDirectionMaxCells=cols
  layout.SortOrder=Enum.SortOrder.LayoutOrder
 end
 U.SavedGrid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()resizeGrid(U.SavedGrid,140,42)end)
 U.CommunityGrid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()resizeGrid(U.CommunityGrid,158,64)end)
 local function info(id)
  local ok,r=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
  return ok and r or nil
 end
 local function refreshDraft()end
 local function renderItems(parent,body,editable)
  clear(parent)
  for _,e in ipairs(A.Entries(body or{}))do
   local id=tonumber(e.Id)
   local f=U.New("Frame",{Size=UDim2.fromOffset(54,52),BackgroundColor3=U.Colors.card},parent);U.Round(f,7)
   U.New("ImageLabel",{Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(50,37),BackgroundTransparency=1,Image=A.AssetThumb(id,150),ScaleType=Enum.ScaleType.Fit},f)
   local t=U.Text(f,"...",{Position=UDim2.fromOffset(2,38),Size=UDim2.new(1,-4,0,10),TextColor3=U.Colors.muted,TextSize=5})
   if editable then
    local del=U.Button(f,"×",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,2),Size=UDim2.fromOffset(24,24),BackgroundColor3=U.Colors.red,TextSize=13})
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
  U.OutfitSelected.Text=tostring(activeSaved.name or"Skin").."\n"..savedRig..(activeSaved.publicCode and(" • "..activeSaved.publicCode)or"")
  mount(U.SavedPreview,savedDraft,savedRig,savedYaw,savedZoom)
  renderItems(U.SavedItems,savedDraft,true)
  U.OutfitPublish.Text=activeSaved.publicCode and"RETIRAR PUBLICAÇÃO"or"PUBLICAR"
 end
 local function selectSaved(r)
  activeSaved=r;savedDraft=A.Copy(r.body);savedRig=tostring(r.rig or"R15")
  savedYaw=180;savedZoom=.76;refreshDraft()
 end
 local function card(parent,r,public)
  local c=U.New("Frame",{BackgroundColor3=public and Color3.fromRGB(34,35,39)or Color3.fromRGB(31,32,36),BorderSizePixel=0},parent);U.Round(c,12)
  U.New("UIStroke",{Color=public and Color3.fromRGB(76,78,84)or Color3.fromRGB(82,84,91),Transparency=public and .62 or .48,Thickness=1},c)
  U.New("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(39,40,44),Color3.fromRGB(26,27,31)),Rotation=90},c)
  local bottom=public and 62 or 42
  local v=U.New("ViewportFrame",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-bottom-8),BackgroundColor3=Color3.fromRGB(50,51,56),BorderSizePixel=0},c);U.Round(v,10)
  table.insert(lazyPreviews,{view=v,parent=parent,body=r.body,rig=r.rig,public=public});queuePreviews()
  local hit=U.Button(c,"",{Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false})
  if public then
   local nItems=#A.Entries(r.body or{});local likes=tonumber(r.likes)or 0
   U.Text(c,tostring(r.name or"Look"),{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,9,1,-42),Size=UDim2.new(1,-18,0,18),Font=Enum.Font.GothamBlack,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
   U.Text(c,"@"..tostring(r.username or"").."  •  "..tostring(r.rig or"R15"),{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,9,1,-25),Size=UDim2.new(1,-18,0,13),TextColor3=Color3.fromRGB(200,204,212),TextSize=5,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
   U.Text(c,nItems.." ITENS  •  "..likes.." CURTIDAS"..(r.code and("  •  "..tostring(r.code))or""),{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,9,1,-9),Size=UDim2.new(1,-18,0,13),TextColor3=Color3.fromRGB(92,224,137),TextSize=5,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  else
   local badge=U.Text(c,tostring(r.rig or"R15"),{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(38,16),BackgroundTransparency=.12,BackgroundColor3=Color3.fromRGB(45,47,55),Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(235,240,246),TextSize=5});
   U.Round(badge,8)
   U.Text(c,tostring(r.name or"Look"),{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,9,1,-8),Size=UDim2.new(1,-18,0,21),Font=Enum.Font.GothamBlack,TextSize=7,TextColor3=Color3.fromRGB(248,252,255),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  end
  hit.Activated:Connect(function()if public then ctx.showPublic(r)else selectSaved(r)end end)
 end
 local function renderSaved()
  clear(U.SavedGrid);local q=string.lower(tostring(U.LookSearch.Text or""));local shown=0
  for _,r in ipairs(savedCache)do
   if q==""or string.lower(tostring(r.name or"")):find(q,1,true)then shown=shown+1;card(U.SavedGrid,r,false)end
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
   selectSaved(pick)
  else
   activeSaved=nil;savedDraft=nil;U.OutfitActions.Visible=false;U.OutfitPublish.Visible=false;U.OutfitSelected.Text="Nenhuma skin salva."
  end
 end
 local function showLook(r)
  activePublic=r;detailGen=detailGen+1;local gen=detailGen;U.LookDetail.Visible=true
  U.LookName.Text=tostring(r.name or"Look");U.LookCreator.Text="Criador: @"..tostring(r.username or"")
  U.LookMeta.Text="RIG: "..tostring(r.rig or"R15");U.LookCodeBox.Text=tostring(r.code or"SEM CÓDIGO")
  U.LookFav.Text=r.liked and"CURTIDO"or"CURTIR";U.LookFav:SetAttribute("FavId",r.id or"");U.LookTotal.Text="Valor total: calculando..."
  clear(U.LookItems);mount(U.LookPreview,r.body,r.rig,180,1)
  task.spawn(function()
   local total,missing=0,0
   for _,e in ipairs(A.Entries(r.body or{}))do
    if gen~=detailGen then return end
    local d=info(e.Id);if gen~=detailGen then return end;local p=d and tonumber(d.PriceInRobux);if p then total=total+p else missing=missing+1 end
    local row=U.New("Frame",{Size=UDim2.new(1,-4,0,38),BackgroundColor3=Color3.fromRGB(38,39,44)},U.LookItems);U.Round(row,7)
    U.New("ImageLabel",{Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(30,30),BackgroundTransparency=1,Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},row)
    U.Text(row,d and tostring(d.Name or("Item "..e.Id))or("Item "..e.Id),{Position=UDim2.fromOffset(40,3),Size=UDim2.new(1,-108,0,17),TextSize=6,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
    U.Text(row,p and("+ "..p.." Robux")or"consultar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,11),Size=UDim2.fromOffset(72,15),TextColor3=p and Color3.fromRGB(78,226,126)or U.Colors.muted,TextSize=6,TextXAlignment=Enum.TextXAlignment.Right})
   end
   if gen==detailGen then U.LookTotal.Text="Valor total: "..total.." Robux"..(missing>0 and(" • "..missing.." sem preço")or"")end
  end)
 end
 ctx.showPublic=showLook
 local function trendScore(r)
  local likes=tonumber(r.likes)or 0;local updated=tonumber(r.updated)or 0
  local age=updated>0 and math.max(0,(os.time()-updated)/86400)or 30
  return(likes+1)/(1+age*.42)
 end
 local function communityRows()
  local rows={}
  for _,r in ipairs(communityCache)do
   local updated=tonumber(r.updated)or 0
   if communityMode~="LOOK DA SEMANA"or(updated>0 and os.time()-updated<=604800)then table.insert(rows,r)end
  end
  table.sort(rows,function(a,b)
   if communityMode=="MAIS CURTIDOS"then
    local al,bl=tonumber(a.likes)or 0,tonumber(b.likes)or 0;if al~=bl then return al>bl end
   elseif communityMode=="EM ALTA"then
    local as,bs=trendScore(a),trendScore(b);if as~=bs then return as>bs end
   elseif communityMode=="LOOK DA SEMANA"then
    local al,bl=tonumber(a.likes)or 0,tonumber(b.likes)or 0;if al~=bl then return al>bl end
   end
   return(tonumber(a.updated)or 0)>(tonumber(b.updated)or 0)
  end)
  return rows
 end
 local function paintCommunityTabs()
  for name,b in pairs(U.ComTabButtons or{})do
   local on=name==communityMode;b.BackgroundColor3=on and Color3.fromRGB(66,70,77)or Color3.fromRGB(43,45,50);b.TextColor3=on and Color3.fromRGB(248,249,251)or U.Colors.muted
  end
 end
 local function setFeatured(r)
  featuredPublic=r
  if not U.ComFeatured then return end
  if not r then
   U.ComFeaturedName.Text="A comunidade está vazia";U.ComFeaturedCreator.Text="Publique um outfit em Meus Outfits";U.ComFeaturedMeta.Text="R15";U.ComFeaturedOpen.Visible=false
   for _,c in ipairs(U.ComFeaturedPreview:GetChildren())do if c:IsA("WorldModel")or c:IsA("Camera")then c:Destroy()end end
   return
  end
  U.ComFeaturedOpen.Visible=true;U.ComFeaturedEyebrow.Text="DESTAQUE • "..communityMode
  U.ComFeaturedName.Text=tostring(r.name or"Look");U.ComFeaturedCreator.Text="@"..tostring(r.username or"")..(r.code and("  •  "..tostring(r.code))or"")
  U.ComFeaturedMeta.Text="RIG: "..tostring(r.rig or"R15")
  if U.ComFeatured.Visible then mount(U.ComFeaturedPreview,r.body,r.rig,180,.94)end
 end
 local function renderCommunity()
  clear(U.CommunityGrid);local rows=communityRows()
  for _,r in ipairs(rows)do card(U.CommunityGrid,r,true)end
  setFeatured(rows[1])
  local label=communityMode=="LOOK DA SEMANA"and"destaques desta semana"or string.lower(communityMode)
  U.CommunityStatus.Text=#rows==0 and("Nenhum look em "..label..".")or("Explore "..#rows.." looks em "..label..".")
  U.ComCount.Text=#rows..(#rows==1 and" look"or" looks")
  U.ComGridTitle.Text=communityMode=="NOVOS"and"PUBLICAÇÕES RECENTES"or communityMode
  U.ComMore.Visible=not communityFinished
  paintCommunityTabs()
 end
 local function community(nextPage)
  local d,e=call("Feed",{next=nextPage==true,search=U.ComSearch.Text});if not d then toast(e)return end
  if nextPage then for _,r in ipairs(d.items or{})do table.insert(communityCache,r)end else communityCache=d.items or{}end
  communityFinished=d.finished==true;renderCommunity()
 end
 U.LookSearch:GetPropertyChangedSignal("Text"):Connect(renderSaved)
 U.ComSearch.FocusLost:Connect(function(enter)if enter then community(false)end end);U.ComSearchGo.Activated:Connect(function()community(false)end)
 U.ComMore.Activated:Connect(function()if not communityFinished then community(true)end end)
 U.ComRefresh.Activated:Connect(function()community(false)end)
 U.ComMyOutfits.Activated:Connect(function()if U.OpenRequest then U.OpenRequest:Fire("Looks")end end)
 U.ComFeaturedOpen.Activated:Connect(function()if featuredPublic then showLook(featuredPublic)end end)
 for name,b in pairs(U.ComTabButtons or{})do b.Activated:Connect(function()communityMode=name;renderCommunity()end)end
 local function refitSaved()
  local wm=U.SavedPreview:FindFirstChildOfClass("WorldModel")
  local m=wm and wm:FindFirstChildOfClass("Model");local cam=U.SavedPreview.CurrentCamera
  if m and cam then fit(cam,U.SavedPreview,m,savedYaw,savedZoom)end
 end
 U.SavedLeft.Activated:Connect(function()if activeSaved then savedYaw=savedYaw-18;refitSaved()end end)
 U.SavedRight.Activated:Connect(function()if activeSaved then savedYaw=savedYaw+18;refitSaved()end end)
 U.SavedZoomIn.Activated:Connect(function()if activeSaved then savedZoom=math.min(1.6,savedZoom+.12);refitSaved()end end)
 U.SavedZoomOut.Activated:Connect(function()if activeSaved then savedZoom=math.max(.7,savedZoom-.12);refitSaved()end end)
 U.OutfitApply.Activated:Connect(function()
  if not savedDraft then return end;local ok,e=S.Set(savedDraft,false,savedRig);toast(ok and"Skin carregada na prévia principal."or e);if ok then U.OpenRequest:Fire("Catalog");if U.ShowPreview then U.ShowPreview()end end
 end)
 U.OutfitUpdate.Activated:Connect(function()
  if not activeSaved or not savedDraft then return end
  local d,e=call("Update",{id=activeSaved.id,body=savedDraft,rig=savedRig});if not d then toast(e)return end
  toast(d.persistent==false and"Alterações guardadas apenas nesta sessão."or"Alterações salvas.");saved()
 end)
 U.OutfitRestore.Activated:Connect(function()
  if not activeSaved then return end;savedDraft=A.Copy(activeSaved.body);savedRig=tostring(activeSaved.rig or"R15");savedYaw=180;savedZoom=.76;refreshDraft();toast("Skin salva restaurada.")
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
 U.LookClose.Activated:Connect(function()U.LookDetail.Visible=false;activePublic=nil;detailGen=detailGen+1 end)
 U.LookTry.Activated:Connect(function()if activePublic then local ok,e=S.Set(activePublic.body,false,activePublic.rig);toast(ok and"Look na prévia. Edite e use APLICAR para vestir."or e);if ok then U.LookDetail.Visible=false;U.OpenRequest:Fire("Catalog");
 if U.ShowPreview then U.ShowPreview()end end end end)
 U.LookBuy.Activated:Connect(function()if activePublic then buyBody(activePublic.body)end end)
 U.LookFav.Activated:Connect(function()
  if not activePublic then return end;local d,e=call("Favorite",{id=activePublic.id,value=not activePublic.liked});if not d then toast(e)return end
  activePublic.liked=d.liked;activePublic.likes=d.likes;U.LookFav.Text=d.liked and"CURTIDO"or"CURTIR";U.LookMeta.Text="RIG: "..tostring(activePublic.rig or"R15")
 end)
 U.LookCopy.Activated:Connect(function()
  local code=tostring(U.LookCodeBox.Text);U.LookCodeBox.TextEditable=true;U.LookCodeBox:CaptureFocus();U.LookCodeBox.SelectionStart=1;U.LookCodeBox.CursorPosition=#code+1;toast("Código selecionado para copiar.")
  task.delay(2,function()if U.LookCodeBox.Parent then U.LookCodeBox.TextEditable=false end end)
 end)
 resizeGrid(U.SavedGrid,140,42);resizeGrid(U.CommunityGrid,158,64)
 return{Saved=saved,Community=function()community(false)end,ShowLook=showLook,Active=function()return activeSaved end,RefreshSaved=renderSaved}
end
print("AVATAR PLAZA V39: Community/Looks carregado")
return M
