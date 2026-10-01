-- 09C_SHOP_CLIENT
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V39 - editor principal compativel com HUD externo e 09A SAFE.
local Players=game:GetService("Players")
local Avatar=game:GetService("AvatarEditorService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
local duplicateCount=0
for _,obj in ipairs(script.Parent:GetChildren())do
 if obj:IsA("LocalScript")and obj.Name=="09C_SHOP_CLIENT"then
  duplicateCount=duplicateCount+1
 end
end
if duplicateCount>1 then
 warn("[V39] DUPLICATA: existem "..duplicateCount.." scripts 09C_SHOP_CLIENT em PlayerScripts. Deixe apenas 1.")
end
print("[V39] 09C_SHOP_CLIENT iniciou")
local uiObj=Rep:WaitForChild("09A_SHOP_UI")
print("[V39] usando "..uiObj:GetFullName())
local okUI,UI=pcall(require,uiObj)
if not okUI then
 warn("[V39] 09A falhou: "..tostring(UI))
 return
end
if type(UI)~="table"or type(UI.Build)~="function"then
 warn("[V39] 09A sem Build()")
 return
end
if UI.VERSION~="V39_STUDIO_UI"then
 warn("[V39] 09A ERRADO/DUPLICADO. VERSION="..tostring(UI.VERSION))
 return
end
local okBuild,U=pcall(UI.Build,pl)
if not okBuild or type(U)~="table"then
 warn("[V39] Build falhou: "..tostring(U))
 return
end
print("[V39] UI construida")
if U.Undo then U.Undo.Text="DESFAZER"end
if U.Redo then U.Redo.Text="REFAZER"end
local focusState={};local focusActive=false
local focusNames={"LimitedMarketHUD","ACP_TitlesGui","ACP_PhotoMode"}
local function shopFocus(on)
 if on and focusActive then return elseif not on and not focusActive then return end
 focusActive=on;local launcher=U.LauncherGui or pg:FindFirstChild("AvatarShopLauncherGui");if launcher then launcher.Enabled=not on end
 if on then
  focusState={}
  for _,name in ipairs(focusNames)do local g=pg:FindFirstChild(name);if g and g:IsA("ScreenGui")then focusState[name]=g.Enabled;g.Enabled=false end end
 else
  for name,enabled in pairs(focusState)do local g=pg:FindFirstChild(name);if g and g:IsA("ScreenGui")then g.Enabled=enabled end end
  focusState={}
 end
end
local function vis(o,v)if o and o:IsA("GuiObject")then o.Visible=v end end
local function toast(s)
 if not U.Toast then print("[SHOP] "..tostring(s))return end
 U.Toast.Text=tostring(s or"");U.Toast.Visible=true
 local n=os.clock();U.Toast:SetAttribute("n",n)
 task.delay(3,function()
  if U.Toast and U.Toast.Parent and U.Toast:GetAttribute("n")==n then U.Toast.Visible=false end
 end)
end
local function connect(b,fn,name)
 if b and b:IsA("GuiButton")then b.Activated:Connect(fn);return true end
 warn("[V39] botao ausente: "..tostring(name));return false
end
local Catalog={Search=function()if U.Status then U.Status.Text="Catalogo carregando..."end end,Preset=function()end,ShowItem=function()end}
local LooksCtl={Saved=function()toast("Minhas Skins carregando...")end,Community=function()toast("Comunidade carregando...")end}
local StoresCtl={Search=function()end}
local catalogReady,looksReady,storesReady=false,false,false
local mode=nil
local pendingMode=nil;local activeMode=nil
local loaderBody=nil
local openLoader=function()vis(U.Loader,true)end
local function hideModes()
 vis(U.Grid,false);vis(U.Status,false);vis(U.More,false);vis(U.Groups,false);vis(U.SubsPopup,false);vis(U.SubToggle,false)
 vis(U.Query,false);vis(U.SearchGo,false);vis(U.PreviewToggle,false);vis(U.Filter,false);vis(U.Sort,false);vis(U.FilterPanel,false);vis(U.Detail,false)
 vis(U.LooksArea,false);vis(U.CommunityArea,false);vis(U.StoresArea,false)
end
local function openShell(which)
 activeMode=which
 shopFocus(true);vis(U.Root,true);vis(U.Loader,false);hideModes()
 if type(U.SetWide)=="function"then pcall(U.SetWide,which~="Catalog")end
 if which=="Catalog"then
  if type(U.SetWide)=="function"then pcall(U.SetWide,false)end
  vis(U.Grid,true);vis(U.Status,true);vis(U.More,true);vis(U.Groups,true);vis(U.SubToggle,true)
  vis(U.Query,true);vis(U.SearchGo,true);vis(U.Filter,true);vis(U.Sort,true);vis(U.SubsPopup,false)
  if U.Status and not catalogReady then U.Status.Text="Abrindo Catalogo..."end
 elseif which=="Looks"then vis(U.LooksArea,true)
 elseif which=="Community"then vis(U.CommunityArea,true)
 elseif which=="Stores"then vis(U.StoresArea,true)
 end
 if type(U.AnimateMode)=="function"then pcall(U.AnimateMode)end
end
-- V39: CATALOGO/LOJAS/PLUS pertencem ao 07G_HUB_UI.
-- A Shop recebe abertura somente pelo BindableEvent OpenRequest.
connect(U.Close,function()vis(U.Root,false);vis(U.LookDetail,false);shopFocus(false)end,"Close")
if U.OpenRequest and U.OpenRequest:IsA("BindableEvent")then
 U.OpenRequest.Event:Connect(function(which)
  if which=="Loader"then openLoader();return end
  local target=which=="Stores"and"Stores"or which=="Community"and"Community"or which=="Looks"and"Looks"or"Catalog"
  if mode then mode(target,which=="Emotes"and"Emotes"or nil)else pendingMode={target,which=="Emotes"and"Emotes"or nil};openShell(target)end
 end)
end
print("[V39] OpenRequest conectado")
local A,S=nil,nil
do
 local o=Rep:FindFirstChild("08B_AVATAR_DATA")
 if o then local ok,r=pcall(require,o);if ok then A=r else warn("[V39] 08B falhou: "..tostring(r))end end
end
do
 local o=Rep:FindFirstChild("08D_SKIN_STATE")
 if o then local ok,r=pcall(require,o);if ok then S=r else warn("[V39] 08D falhou: "..tostring(r))end end
end
local rem=Rep:FindFirstChild("LMShop_Remotes")
local rpc=rem and rem:FindFirstChild("Request")
local function call(action,args)
 if not rpc or not rpc.Parent then rem=Rep:FindFirstChild("LMShop_Remotes");rpc=rem and rem:FindFirstChild("Request")end
 if not rpc then return nil,"O editor ainda está conectando ao servidor."end
 local ok,r=pcall(function()return rpc:InvokeServer(action,args or{})end)
 if not ok then return nil,"O servidor nao respondeu."end
 if not r or not r.ok then return nil,r and r.error or"Falha no servidor."end
 return r.data
end
local Extras=nil
do local o=Rep:FindFirstChild("09C4_OUTFIT_LIBRARY");if o then local ok,r=pcall(require,o);if ok and type(r)=="table"then Extras=r end end end
local previewModel,previewTrack=nil,nil
local gen,yaw,zoom=0,180,1.02
local pendingPreviewEmote=nil
local function clearGui(p)
 if not p then return end
 for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end
end
local function bodyBounds(m)
 local minX,minY,minZ=math.huge,math.huge,math.huge;local maxX,maxY,maxZ=-math.huge,-math.huge,-math.huge;local found=0
 for _,p in ipairs(m:GetDescendants())do if p:IsA("BasePart")and p.Name~="HumanoidRootPart"then local h=p.Size*.5;local v=p.Position;minX=math.min(minX,v.X-h.X);minY=math.min(minY,v.Y-h.Y);minZ=math.min(minZ,v.Z-h.Z);maxX=math.max(maxX,v.X+h.X);maxY=math.max(maxY,v.Y+h.Y);
 maxZ=math.max(maxZ,v.Z+h.Z);found=found+1 end end
 if found<2 then return m:GetBoundingBox()end;local mn=Vector3.new(minX,minY,minZ);local mx=Vector3.new(maxX,maxY,maxZ);return CFrame.new((mn+mx)*.5),mx-mn
end
local function fit(cam,view,m)
 local cf,size=bodyBounds(m);local vp=view.AbsoluteSize;local aspect=math.max(vp.X,1)/math.max(vp.Y,1);local fov=math.rad(cam.FieldOfView)
 local vd=size.Y*.58/math.tan(fov*.5);local hf=2*math.atan(math.tan(fov*.5)*aspect);local hd=size.X*.58/math.tan(hf*.5);local dist=(math.max(vd,hd)+size.Z*.08)/zoom
 local target=cf.Position+Vector3.new(0,size.Y*.015,0);local off=CFrame.Angles(0,math.rad(yaw),0).LookVector*-dist;cam.CFrame=CFrame.lookAt(target+off,target)
end
local function stopEmote()
 if previewTrack then pcall(function()previewTrack:Stop(.15)end);previewTrack=nil end
 if U.StopEmote then U.StopEmote.Visible=false end
end
local function render(emoteId)
 if not A or not S or not S.Current or not U.Viewport then return end
 gen=gen+1;local mine=gen
 stopEmote();previewModel=nil
 local body,rigName=A.Copy(S.Current),S.Rig
 for _,v in ipairs(U.Viewport:GetChildren())do if v:IsA("WorldModel")or v:IsA("Camera")then v:Destroy()end end
 local wm=Instance.new("WorldModel");wm.Parent=U.Viewport
 local cam=Instance.new("Camera");cam.FieldOfView=25;cam.Parent=U.Viewport;U.Viewport.CurrentCamera=cam
 U.Viewport.Ambient=Color3.fromRGB(238,239,242);U.Viewport.LightColor=Color3.fromRGB(255,255,255);U.Viewport.LightDirection=Vector3.new(-.45,-1,-.38)
 if U.PreviewInfo then U.PreviewInfo.Text="PRÉVIA • "..tostring(S.Rig)end
 task.spawn(function()
  local got,d=pcall(A.Unpack,body);if not got then return end
  if emoteId then d:AddEmote("PreviewEmote",emoteId)end
  local rig=rigName=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
  local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(d,rig)end);d:Destroy()
  if not ok or not m or mine~=gen or not wm.Parent then if m then m:Destroy()end return end
  for _,x in ipairs(m:GetDescendants())do
   if x:IsA("BasePart")then x.CanCollide=false;x.CanTouch=false;x.CanQuery=false
   elseif x:IsA("Script")or x:IsA("LocalScript")then x:Destroy()end
  end
  m.Parent=wm;m:PivotTo(CFrame.new());previewModel=m
  local hrp=m:FindFirstChild("HumanoidRootPart");if hrp then hrp.Anchored=true end
  if pg:GetAttribute("ACP_PreviewStudio")~=false then
   local cf,size=bodyBounds(m);local floor=Instance.new("Part");floor.Name="StudioFloor";floor.Size=Vector3.new(16,.18,16);floor.Position=Vector3.new(cf.Position.X,cf.Position.Y-size.Y*.5-.12,cf.Position.Z);floor.Anchored=true;floor.CanCollide=false;floor.Color=Color3.fromRGB(89,110,104);
   floor.Material=Enum.Material.SmoothPlastic;floor.Parent=wm
   local back=Instance.new("Part");back.Name="StudioBack";back.Size=Vector3.new(17,13,.18);back.Position=Vector3.new(cf.Position.X,cf.Position.Y+.8,cf.Position.Z+5.2);back.Anchored=true;back.CanCollide=false;back.Color=Color3.fromRGB(110,137,128);back.Material=Enum.Material.SmoothPlastic;
   back.Parent=wm
  end
  fit(cam,U.Viewport,m)
 end)
 clearGui(U.ItemStrip)
 local count=0
 for _,e in ipairs(A.Entries(S.Current))do
  count=count+1
  local f=U.New("Frame",{Size=UDim2.fromOffset(47,52),BackgroundColor3=U.Colors.card},U.ItemStrip);U.Round(f,6)
  U.New("ImageLabel",{Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(43,36),BackgroundTransparency=1,Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},f)
  local del=U.Button(f,"x",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-1,0,1),Size=UDim2.fromOffset(16,16),BackgroundColor3=U.Colors.red,TextSize=8})
  del.Activated:Connect(function()local ok,er=S.Remove(e.Id);if not ok then toast(er)end end)
 end
 if U.Total then U.Total.Text=count.." itens"end
 return mine
end
local function buyBody(body)
 if not body then toast("Nao ha itens na previa.")return end;toast("Preparando compra dos itens...")
 local d,e=call("BulkPurchase",{body=body});if e then toast(e)return end
 if d then toast(d.remaining and d.remaining>0 and("Compra: "..tostring(d.count).." itens; restam "..tostring(d.remaining)..".")or("Compra aberta para "..tostring(d.count or 0).." itens."))end
end
local loaderUseR6=nil;local loaderGeneration=0
local function loaderReset(clearQuery)
 loaderGeneration=loaderGeneration+1;loaderBody=nil
 if clearQuery and U.LoaderQuery then U.LoaderQuery.Text=""end
 if U.LoaderName then U.LoaderName.Text="Nenhum avatar selecionado."end
 if U.LoaderStatus then U.LoaderStatus.Text="Digite @usuario, nome ou UserId. Nada muda ate voce tocar USAR."end
 if U.LoaderThumb then U.LoaderThumb.Image=""end
 if U.LoaderUse then U.LoaderUse.Visible=false end
 if loaderUseR6 then loaderUseR6.Visible=false end
end
local loaderMine=nil
local function loaderPrepareButtons()
 if not U.LoaderUse or not U.LoaderUse.Parent or loaderUseR6 then return end
 local p=U.LoaderUse.Parent
 for _,o in ipairs(p:GetChildren())do
  if o:IsA("TextLabel")and o.Text=="CARREGAR SKIN"then o.Text="CARREGAR AVATAR";o.TextColor3=U.Colors.cyan end
 end
 if U.LoaderQuery then U.LoaderQuery.Size=UDim2.new(1,-206,0,38)end
 if U.LoaderSearch then U.LoaderSearch.Size=UDim2.fromOffset(84,38);U.LoaderSearch.Text="BUSCAR"end
 loaderMine=U.Button(p,"MEU",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-106,0,60),Size=UDim2.fromOffset(70,38),BackgroundColor3=U.Colors.purple,TextSize=12,ZIndex=100})
 if U.LoaderThumb then U.LoaderThumb.Position=UDim2.new(.5,0,0,126);U.LoaderThumb.Size=UDim2.new(.48,0,.42,0);U.LoaderThumb.BackgroundColor3=Color3.fromRGB(25,31,40)end
 U.LoaderUse.Text="USAR R15";U.LoaderUse.AnchorPoint=Vector2.new(.5,1);U.LoaderUse.Position=UDim2.new(.66,0,1,-14);U.LoaderUse.Size=UDim2.fromOffset(132,32)
 loaderUseR6=U.Button(p,"USAR R6",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.34,0,1,-14),Size=UDim2.fromOffset(132,32),BackgroundColor3=U.Colors.purple,ZIndex=100});loaderUseR6.Visible=false
 U.Text(p,"BUSQUE → CONFIRA → ESCOLHA R6/R15",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,103),Size=UDim2.new(1,-32,0,18),TextColor3=U.Colors.muted,TextSize=6,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=96})
end
openLoader=function()
 shopFocus(true);loaderPrepareButtons();loaderReset(true);vis(U.Root,false);vis(U.Loader,true)
 if U.LoaderQuery then task.defer(function()pcall(function()U.LoaderQuery:CaptureFocus()end)end)end
end
local function resolveLoaderUser(raw)
 raw=tostring(raw or""):match("^%s*(.-)%s*$"):gsub("^@","");if raw==""then return nil,nil,"Digite um usuario ou ID."end
 local uid=tonumber(raw)
 if uid then uid=math.floor(uid);if uid<=0 then return nil,nil,"UserId invalido."end
 else local ok,id=pcall(function()return Players:GetUserIdFromNameAsync(raw)end);if not ok then return nil,nil,"Usuario nao encontrado."end;uid=id end
 local okName,name=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);name=okName and name or raw
 local display=name;local okInfo,info=pcall(function()return Players:GetUserInfosByUserIdsAsync({uid})end)
 if okInfo and type(info)=="table"and info[1]and info[1].DisplayName then display=info[1].DisplayName end
 return uid,name,nil,display
end
local function doLoaderSearch()
 if not A then toast("Sistema de avatar ainda nao carregou.")return end;loaderPrepareButtons()
 loaderGeneration=loaderGeneration+1;local mine=loaderGeneration;loaderBody=nil
 local uid,name,err,display=resolveLoaderUser(U.LoaderQuery and U.LoaderQuery.Text or"");if mine~=loaderGeneration then return end;if err then if U.LoaderStatus then U.LoaderStatus.Text=err end;return end
 U.LoaderStatus.Text="Buscando avatar de @"..tostring(name).."...";U.LoaderUse.Visible=false;if loaderUseR6 then loaderUseR6.Visible=false end
 task.spawn(function()
  local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(uid)end)
  if mine~=loaderGeneration then if desc then desc:Destroy()end;return end
  if not ok or not desc then U.LoaderStatus.Text="Avatar indisponivel para esse usuario.";return end
  local packed=A.Pack(desc);desc:Destroy();if not packed then U.LoaderStatus.Text="Nao foi possivel ler esse avatar.";return end
  loaderBody=packed;U.LoaderName.Text=tostring(display).."  •  @"..tostring(name);U.LoaderThumb.Image="rbxthumb://type=Avatar&id="..uid.."&w=420&h=420"
  U.LoaderStatus.Text="ID "..tostring(uid).." • pronto para a previa. Nenhum jogador real foi criado.";U.LoaderUse.Visible=true;if loaderUseR6 then loaderUseR6.Visible=true end
 end)
end
local function useLoader(rig)
 if not loaderBody then toast("Busque um avatar primeiro.")return end;if not S then toast("Estado da skin indisponivel.")return end
 local ok,err=S.Set(loaderBody,false,rig);if not ok then toast(err or"Nao foi possivel carregar a skin.")return end
 vis(U.Loader,false);mode("Catalog");toast("Skin carregada na previa em "..rig..".")
end
local function playPreviewEmote(id)
 if not S or not tonumber(id)then return false,"Prévia indisponível."end
 if S.Rig~="R15"then pendingPreviewEmote=id;vis(U.RigBox,true);return false,"Escolha R15 para testar este emote."end
 local mine=render(tonumber(id));local limit=os.clock()+8
 while mine==gen and not previewModel and os.clock()<limit do task.wait(.08)end
 if mine~=gen then return false,"A prévia mudou. Escolha o emote novamente."end
 local m=previewModel;local hum=m and m:FindFirstChildOfClass("Humanoid")
 if not hum then return false,"A prévia ainda está carregando."end
 local ok,played=pcall(function()return hum:PlayEmoteAsync("PreviewEmote")end)
 if mine~=gen then return false,"A prévia mudou."end
 if not ok or not played then return false,"Este emote não pôde ser reproduzido."end
 local animator=hum:FindFirstChildOfClass("Animator")
 if animator then
  local tracks=animator:GetPlayingAnimationTracks();previewTrack=tracks[#tracks]
  if previewTrack then previewTrack.Looped=true end
 end
 if U.StopEmote then U.StopEmote.Visible=true end
 return true
end
local function refit()
 local cam=U.Viewport and U.Viewport.CurrentCamera
 if cam and previewModel and previewModel.Parent then fit(cam,U.Viewport,previewModel)end
end
if U.StopEmote then U.StopEmote.Activated:Connect(function()stopEmote();render()end)end
if U.Viewport then U.Viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit)end
U.Root:GetPropertyChangedSignal("Visible"):Connect(function()
 if U.Root.Visible then if not previewModel then render()end else gen=gen+1;stopEmote()end
end)
if A and S then
 if Extras and type(Extras.Init)=="function"then pcall(Extras.Init,{U=U,A=A,S=S,call=call,toast=toast})end
 local o=Rep:FindFirstChild("09C2_SHOP_CATALOG")
 if o then
  local ok,m=pcall(require,o)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,pl=pl,toast=toast,call=call,playEmote=playPreviewEmote,preview=function()if activeMode~="Catalog"then mode("Catalog")end;if U.ShowPreview then U.ShowPreview()end end})
   if ok2 and type(r)=="table"then Catalog=r;catalogReady=true;print("[V39] 09C2 Init OK")else warn("[V39] 09C2 Init falhou: "..tostring(r))end
  else warn("[V39] require 09C2 falhou: "..tostring(m))end
 end
 local o2=Rep:FindFirstChild("09C1_SHOP_LOOKS")
 if o2 then
  local ok,m=pcall(require,o2)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,call=call,toast=toast,buyBody=buyBody,showPublic=nil})
   if ok2 and type(r)=="table"then LooksCtl=r;looksReady=true;print("[V39] 09C1 Init OK")else warn("[V39] 09C1 Init falhou: "..tostring(r))end
  else warn("[V39] require 09C1 falhou: "..tostring(m))end
 end
 local o3=Rep:FindFirstChild("09C5_UGC_STORES")
 if o3 then
  local ok,m=pcall(require,o3)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,toast=toast,showItem=function(item)if catalogReady and Catalog.ShowItem then Catalog.ShowItem(item)end end})
   if ok2 and type(r)=="table"then StoresCtl=r;storesReady=true;print("[V39] 09C5 Init OK")else warn("[V39] 09C5 Init falhou: "..tostring(r))end
  else warn("[V39] require 09C5 falhou: "..tostring(m))end
 end
else
 warn("[V39] 08B/08D indisponivel; launcher segue ativo.")
end
mode=function(which,preset)
 openShell(which)
 if which=="Catalog"then
  if catalogReady then
   local ok,e=pcall(function()if preset and Catalog.Preset then Catalog.Preset(preset)else Catalog.Search()end end)
   if not ok then warn("[V39] busca Catalogo falhou: "..tostring(e));if U.Status then U.Status.Text="Catalogo abriu, mas a busca falhou."end end
  elseif U.Status then U.Status.Text="Catalogo abriu em modo seguro. Veja o Output."end
 elseif which=="Looks"and looksReady and LooksCtl.Saved then pcall(LooksCtl.Saved)
 elseif which=="Community"and looksReady and LooksCtl.Community then pcall(LooksCtl.Community)
 elseif which=="Stores"and storesReady and StoresCtl.Search then pcall(StoresCtl.Search)
 end
end
if pendingMode then local p=pendingMode;pendingMode=nil;mode(p[1],p[2])end
connect(U.ViewLeft,function()yaw=(yaw-18)%360;refit()end,"ViewLeft")
connect(U.ViewRight,function()yaw=(yaw+18)%360;refit()end,"ViewRight")
connect(U.ZoomIn,function()zoom=math.min(1.6,zoom+.12);refit()end,"ZoomIn")
connect(U.ZoomOut,function()zoom=math.max(.7,zoom-.12);refit()end,"ZoomOut")
connect(U.Apply,function()
 if not S or not S.Current then toast("Aguarde a previa.")return end
 local d,e=call("Apply",{body=S.Current,rig=S.Rig});if not d then toast(e)elseif d.liveRig and d.wantedRig and d.liveRig~=d.wantedRig then toast("Look aplicado no rig atual ("..d.liveRig.."). R6/R15 da prévia continua salvo.")else toast("Skin aplicada.")end
end,"Apply")
connect(U.Save,function()
 if not S or not S.Current then toast("Aguarde a previa.")return end
 if U.SaveName then U.SaveName.Text=""end;vis(U.SaveBox,true)
end,"Save")
connect(U.SaveR15,function()
 if not S then return end
 local d,e=call("Save",{name=U.SaveName and U.SaveName.Text or"",body=S.Current,rig="R15"})
 if not d then toast(e)else S.SetRig("R15",true);vis(U.SaveBox,false);toast(d.persistent==false and"Salva somente nesta sessão. O armazenamento está indisponível."or"Skin R15 salva.");mode("Looks")end
end,"SaveR15")
connect(U.SaveR6,function()
 if not S then return end
 local d,e=call("Save",{name=U.SaveName and U.SaveName.Text or"",body=S.Current,rig="R6"})
 if not d then toast(e)else S.SetRig("R6",true);vis(U.SaveBox,false);toast(d.persistent==false and"Salva somente nesta sessão. O armazenamento está indisponível."or"Skin R6 salva.");mode("Looks")end
end,"SaveR6")
connect(U.CancelSave,function()vis(U.SaveBox,false)end,"CancelSave")
connect(U.RigCancel,function()pendingPreviewEmote=nil;vis(U.RigBox,false)end,"RigCancel")
connect(U.SaveRoblox,function()
 if not S then return end;local d=S.Description();if not d then return end;local rig=S.Rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
 local ok=pcall(function()Avatar:PromptSaveAvatar(d,rig)end);d:Destroy();if not ok then toast("O Roblox nao abriu o salvamento.")end
end,"SaveRoblox")
connect(U.Undo,function()if S then local ok,e=S.Undo();if not ok then toast(e)end end end,"Undo")
connect(U.Redo,function()if S then local ok,e=S.Redo();if not ok then toast(e)end end end,"Redo")
connect(U.Blank,function()if S then local ok,e=S.Blank();if not ok then toast(e)end end end,"Blank")
connect(U.Reset,function()if S then local ok,e=S.Reset();if not ok then toast(e)end end end,"Reset")
connect(U.LoaderClose,function()vis(U.Loader,false);loaderReset(false);shopFocus(false)end,"LoaderClose")
connect(U.LoaderSearch,doLoaderSearch,"LoaderSearch")
if U.LoaderQuery and U.LoaderQuery:IsA("TextBox")then U.LoaderQuery.FocusLost:Connect(function(enter)if enter then doLoaderSearch()end end)end
loaderPrepareButtons()
if loaderMine then connect(loaderMine,function()U.LoaderQuery.Text=pl.Name;doLoaderSearch()end,"LoaderMine")end
connect(U.LoaderUse,function()useLoader("R15")end,"LoaderUseR15")
if loaderUseR6 then connect(loaderUseR6,function()useLoader("R6")end,"LoaderUseR6")end
connect(U.RigToR15,function()vis(U.RigBox,false);if S then S.SetRig("R15")end;local id=pendingPreviewEmote;pendingPreviewEmote=nil;if id then local ok,e=playPreviewEmote(id);toast(ok and"Emote tocando."or e)else mode("Catalog","Emotes")end end,"RigToR15")
if U.OutfitSaveNew then connect(U.OutfitSaveNew,function()if U.SaveName then U.SaveName.Text=""end;vis(U.SaveBox,true)end,"OutfitSaveNew")end
if U.HudAction and U.HudAction:IsA("BindableEvent")then U.HudAction.Event:Connect(function(a)
 if a=="Undo"and S then local ok,e=S.Undo();if not ok then toast(e)end
 elseif a=="BuyLook"then if S and S.Current then buyBody(S.Current)else toast("Aguarde a previa.")end
 elseif a=="Blank"and S then local ok,e=S.Blank();if not ok then toast(e)end
 elseif a=="Reset"and S then local ok,e=S.Reset();if not ok then toast(e)end
 elseif a=="Emotes"then mode("Catalog","Emotes")end
end)end
pg:GetAttributeChangedSignal("ACP_PreviewStudio"):Connect(render)
if S and S.Changed and S.Changed.Event then S.Changed.Event:Connect(render)end
if S and type(S.Init)=="function"then
 local ok,a,b=pcall(S.Init)
 if not ok then warn("[V39] S.Init erro: "..tostring(a))
 elseif a==false then toast(b or"Falha ao iniciar previa.")
 else render()end
end
print("[V39] SHOP pronta | Catalog="..tostring(catalogReady).." | Looks="..tostring(looksReady).." | Stores="..tostring(storesReady))
