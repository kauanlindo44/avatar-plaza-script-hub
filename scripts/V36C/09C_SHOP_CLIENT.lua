-- 09C_SHOP_CLIENT
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR CREATOR PLAZA V27.9.2 - foco fullscreen + HUD externo oculto + textos compatíveis.

local Players=game:GetService("Players")
local Avatar=game:GetService("AvatarEditorService")
local Rep=game:GetService("ReplicatedStorage")
local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")

local duplicateCount=0
for _,obj in ipairs(script.Parent:GetChildren())do
 if obj:IsA("LocalScript")and obj.Name=="09C_SHOP_CLIENT"then
  duplicateCount+=1
 end
end
if duplicateCount>1 then
 warn("[V27.9.2] DUPLICATA: existem "..duplicateCount.." scripts 09C_SHOP_CLIENT em PlayerScripts. Deixe apenas 1.")
end

print("[V27.9.2] 09C_SHOP_CLIENT iniciou")

-- UI primeiro: se a UI carregar, os botoes sao conectados antes dos outros modulos.
local uiObj=Rep:WaitForChild("09A_SHOP_UI")
print("[V27.9.2] usando "..uiObj:GetFullName())
local okUI,UI=pcall(require,uiObj)
if not okUI then
 warn("[V27.9.2] 09A falhou: "..tostring(UI))
 return
end
if type(UI)~="table"or type(UI.Build)~="function"then
 warn("[V27.9.2] 09A sem Build()")
 return
end
if UI.VERSION~="V27.8.10_CLEAN_RESCUE"then
 warn("[V27.9.2] 09A ERRADO/DUPLICADO. VERSION="..tostring(UI.VERSION))
 return
end

local okBuild,U=pcall(UI.Build,pl)
if not okBuild or type(U)~="table"then
 warn("[V27.9.2] Build falhou: "..tostring(U))
 return
end
print("[V27.9.2] UI construida")
if U.Undo then U.Undo.Text="UNDO";U.Undo.TextSize=5 end
if U.Redo then U.Redo.Text="REDO";U.Redo.TextSize=5 end
local focusState={};local focusActive=false
local focusNames={"LimitedMarketHUD","ACP_TitlesGui","ACP_PhotoMode"}
local function shopFocus(on)
 if on and focusActive then return elseif not on and not focusActive then return end
 focusActive=on;if U.LauncherGui then U.LauncherGui.Enabled=not on end
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
 warn("[V27.9.2] botao ausente: "..tostring(name));return false
end

local Catalog={Search=function()if U.Status then U.Status.Text="Catalogo carregando..."end end,Preset=function()end,ShowItem=function()end}
local LooksCtl={Saved=function()toast("Minhas Skins carregando...")end,Community=function()toast("Comunidade carregando...")end}
local StoresCtl={Search=function()end}
local catalogReady,looksReady,storesReady=false,false,false
local mode=nil
local pendingMode=nil
local loaderBody=nil
local openLoader=function()vis(U.Loader,true)end

local function hideModes()
 vis(U.Grid,false);vis(U.Status,false);vis(U.More,false);vis(U.Groups,false);vis(U.Subs,false)
 vis(U.Query,false);vis(U.Filter,false);vis(U.Sort,false);vis(U.FilterPanel,false);vis(U.Detail,false)
 vis(U.LooksArea,false);vis(U.CommunityArea,false);vis(U.StoresArea,false)
end

local function openShell(which)
 shopFocus(true);vis(U.Root,true);vis(U.Loader,false);hideModes()
 if type(U.SetWide)=="function"then pcall(U.SetWide,which~="Catalog")end
 if which=="Catalog"then
  if type(U.SetWide)=="function"then pcall(U.SetWide,false)end
  vis(U.Grid,true);vis(U.Status,true);vis(U.More,true);vis(U.Groups,true);vis(U.Subs,true)
  vis(U.Query,true);vis(U.Filter,true);vis(U.Sort,true)
  if U.Status and not catalogReady then U.Status.Text="Abrindo Catalogo..."end
 elseif which=="Looks"then vis(U.LooksArea,true)
 elseif which=="Community"then vis(U.CommunityArea,true)
 elseif which=="Stores"then vis(U.StoresArea,true)
 end
 if type(U.AnimateMode)=="function"then pcall(U.AnimateMode)end
end

-- CONEXOES CRITICAS PRIMEIRO.
connect(U.TopCatalog,function()
 print("[V27.9.2] CLIQUE CATALOGO")
 if mode then mode("Catalog")else pendingMode="Catalog";openShell("Catalog")end
end,"TopCatalog")
connect(U.TopStores,function()
 print("[V27.9.2] CLIQUE LOJAS UGC")
 if mode then mode("Stores")else pendingMode="Stores";openShell("Stores")end
end,"TopStores")
connect(U.Close,function()vis(U.Root,false);vis(U.LookDetail,false);shopFocus(false)end,"Close")

if U.OpenRequest and U.OpenRequest:IsA("BindableEvent")then
 U.OpenRequest.Event:Connect(function(which)
  if which=="Loader"then openLoader();return end
  local target=which=="Stores"and"Stores"or which=="Community"and"Community"or which=="Looks"and"Looks"or"Catalog"
  if mode then mode(target,which=="Emotes"and"Emotes"or nil)else pendingMode=target;openShell(target)end
 end)
end
print("[V27.9.2] launcher conectado")

-- Dependencias principais isoladas.
local A,S=nil,nil
do
 local o=Rep:FindFirstChild("08B_AVATAR_DATA")
 if o then local ok,r=pcall(require,o);if ok then A=r else warn("[V27.9.2] 08B falhou: "..tostring(r))end end
end
do
 local o=Rep:FindFirstChild("08D_SKIN_STATE")
 if o then local ok,r=pcall(require,o);if ok then S=r else warn("[V27.9.2] 08D falhou: "..tostring(r))end end
end

local rem=Rep:FindFirstChild("LMShop_Remotes")
local rpc=rem and rem:FindFirstChild("Request")
local function call(action,args)
 if not rpc then return nil,"Servidor da Shop nao iniciou."end
 local ok,r=pcall(function()return rpc:InvokeServer(action,args or{})end)
 if not ok then return nil,"O servidor nao respondeu."end
 if not r or not r.ok then return nil,r and r.error or"Falha no servidor."end
 return r.data
end

local previewModel,previewTrack=nil,nil
local gen,yaw,zoom=180,1.0480,1.04
local previousRig=nil

local function clearGui(p)
 if not p then return end
 for _,v in ipairs(p:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end
end
local function fit(cam,view,m)
 local cf,size=m:GetBoundingBox();local vp=view.AbsoluteSize
 local aspect=math.max(vp.X,1)/math.max(vp.Y,1);local fov=math.rad(cam.FieldOfView)
 local vd=size.Y*.5/math.tan(fov*.5);local hf=2*math.atan(math.tan(fov*.5)*aspect)
 local hd=size.X*.5/math.tan(hf*.5);local dist=(math.max(vd,hd)*1.24+size.Z*.20)/zoom
 local target=cf.Position+Vector3.new(0,size.Y*.04,0)
 local off=CFrame.Angles(0,math.rad(yaw),0).LookVector*-dist
 cam.CFrame=CFrame.lookAt(target+off,target)
end
local function render()
 if not A or not S or not S.Current or not U.Viewport then return end
 gen+=1;local mine=gen
 if previewTrack then pcall(function()previewTrack:Stop(.1)end);previewTrack=nil end
 for _,v in ipairs(U.Viewport:GetChildren())do if v:IsA("WorldModel")or v:IsA("Camera")then v:Destroy()end end
 local wm=Instance.new("WorldModel");wm.Parent=U.Viewport
 local cam=Instance.new("Camera");cam.FieldOfView=31;cam.Parent=U.Viewport;U.Viewport.CurrentCamera=cam
 U.Viewport.Ambient=Color3.fromRGB(238,242,247);U.Viewport.LightColor=Color3.new(1,1,1);U.Viewport.LightDirection=Vector3.new(-.7,-1,-.75)
 if U.PreviewInfo then U.PreviewInfo.Text="PREVIA "..tostring(S.Rig)end
 task.spawn(function()
  local d=A.Unpack(S.Current);local rig=S.Rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
  local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(d,rig)end);d:Destroy()
  if not ok or not m or mine~=gen or not wm.Parent then if m then m:Destroy()end return end
  for _,x in ipairs(m:GetDescendants())do
   if x:IsA("BasePart")then x.CanCollide=false;x.CanTouch=false;x.CanQuery=false
   elseif x:IsA("Script")or x:IsA("LocalScript")then x:Destroy()end
  end
  m.Parent=wm;m:PivotTo(CFrame.new());previewModel=m;fit(cam,U.Viewport,m)
 end)
 clearGui(U.ItemStrip)
 local count=0
 for _,e in ipairs(A.Entries(S.Current))do
  count+=1
  local f=U.New("Frame",{Size=UDim2.fromOffset(47,52),BackgroundColor3=U.Colors.card},U.ItemStrip);U.Round(f,6)
  U.New("ImageLabel",{Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(43,36),BackgroundTransparency=1,Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},f)
  local del=U.Button(f,"x",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-1,0,1),Size=UDim2.fromOffset(16,16),BackgroundColor3=U.Colors.red,TextSize=8})
  del.Activated:Connect(function()local ok,er=S.Remove(e.Id);if not ok then toast(er)end end)
 end
 if U.Total then U.Total.Text=count.." itens"end
end

local function buyBody(body)
 if not body then toast("Nao ha itens na previa.")return end;toast("Preparando compra dos itens...")
 local d,e=call("BulkPurchase",{body=body});if e then toast(e)return end
 if d then toast(d.remaining and d.remaining>0 and("Compra: "..tostring(d.count).." itens; restam "..tostring(d.remaining)..".")or("Compra aberta para "..tostring(d.count or 0).." itens."))end
end

local loaderUseR6=nil
local function loaderReset(clearQuery)
 loaderBody=nil
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
 -- Renomeia o cabeçalho antigo sem precisar alterar 09A.
 for _,o in ipairs(p:GetChildren())do
  if o:IsA("TextLabel")and o.Text=="CARREGAR SKIN"then o.Text="CARREGAR AVATAR";o.TextColor3=U.Colors.cyan end
 end
 -- Busca mais clara no celular: campo + MEU AVATAR + BUSCAR.
 if U.LoaderQuery then U.LoaderQuery.Size=UDim2.new(1,-206,0,38)end
 if U.LoaderSearch then U.LoaderSearch.Size=UDim2.fromOffset(84,38);U.LoaderSearch.Text="BUSCAR"end
 loaderMine=U.Button(p,"MEU",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-106,0,60),Size=UDim2.fromOffset(70,38),BackgroundColor3=U.Colors.purple,TextSize=6,ZIndex=96})
 -- Thumbnail é somente imagem do avatar; nenhum personagem real é criado pelo Loader.
 if U.LoaderThumb then U.LoaderThumb.Position=UDim2.new(.5,0,0,126);U.LoaderThumb.Size=UDim2.new(.48,0,.42,0);U.LoaderThumb.BackgroundColor3=Color3.fromRGB(25,31,40)end
 U.LoaderUse.Text="USAR R15";U.LoaderUse.AnchorPoint=Vector2.new(.5,1);U.LoaderUse.Position=UDim2.new(.66,0,1,-14);U.LoaderUse.Size=UDim2.fromOffset(132,32)
 loaderUseR6=U.Button(p,"USAR R6",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.34,0,1,-14),Size=UDim2.fromOffset(132,32),BackgroundColor3=U.Colors.purple,ZIndex=96});loaderUseR6.Visible=false
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
 local uid,name,err,display=resolveLoaderUser(U.LoaderQuery and U.LoaderQuery.Text or"");if err then if U.LoaderStatus then U.LoaderStatus.Text=err end;return end
 U.LoaderStatus.Text="Buscando avatar de @"..tostring(name).."...";U.LoaderUse.Visible=false;if loaderUseR6 then loaderUseR6.Visible=false end
 task.spawn(function()
  local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(uid)end)
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
 if not S or S.Rig~="R15"then return false,"Troque a previa para R15."end
 if not previewModel then render();task.wait(.35)end
 local m=previewModel;if not m then return false,"A previa ainda esta carregando."end
 local hum=m:FindFirstChildOfClass("Humanoid");local animator=hum and(hum:FindFirstChildOfClass("Animator")or Instance.new("Animator",hum))
 if not animator then return false,"Avatar sem Animator."end
 if previewTrack then pcall(function()previewTrack:Stop(.15)end)end
 local anim=Instance.new("Animation");anim.AnimationId="rbxassetid://"..tostring(id)
 local ok,tr=pcall(function()return animator:LoadAnimation(anim)end);anim:Destroy()
 if not ok or not tr then return false,"Emote nao carregou."end
 previewTrack=tr;local played=pcall(function()tr:Play(.15,1,1)end);return played
end

-- Cada modulo e independente. Um erro nao mata o launcher.
if A and S then
 local o=Rep:FindFirstChild("09C2_SHOP_CATALOG")
 if o then
  local ok,m=pcall(require,o)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,pl=pl,toast=toast,call=call,playEmote=playPreviewEmote})
   if ok2 and type(r)=="table"then Catalog=r;catalogReady=true;print("[V27.9.2] 09C2 Init OK")else warn("[V27.9.2] 09C2 Init falhou: "..tostring(r))end
  else warn("[V27.9.2] require 09C2 falhou: "..tostring(m))end
 end

 local o2=Rep:FindFirstChild("09C1_SHOP_LOOKS")
 if o2 then
  local ok,m=pcall(require,o2)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,call=call,toast=toast,buyBody=buyBody,showPublic=nil})
   if ok2 and type(r)=="table"then LooksCtl=r;looksReady=true;print("[V27.9.2] 09C1 Init OK")else warn("[V27.9.2] 09C1 Init falhou: "..tostring(r))end
  else warn("[V27.9.2] require 09C1 falhou: "..tostring(m))end
 end

 local o3=Rep:FindFirstChild("09C5_UGC_STORES")
 if o3 then
  local ok,m=pcall(require,o3)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,toast=toast,showItem=function(item)if catalogReady and Catalog.ShowItem then Catalog.ShowItem(item)end end})
   if ok2 and type(r)=="table"then StoresCtl=r;storesReady=true;print("[V27.9.2] 09C5 Init OK")else warn("[V27.9.2] 09C5 Init falhou: "..tostring(r))end
  else warn("[V27.9.2] require 09C5 falhou: "..tostring(m))end
 end
else
 warn("[V27.9.2] 08B/08D indisponivel; launcher segue ativo.")
end

mode=function(which,preset)
 openShell(which)
 if which=="Catalog"then
  if catalogReady then
   local ok,e=pcall(function()if preset and Catalog.Preset then Catalog.Preset(preset)else Catalog.Search()end end)
   if not ok then warn("[V27.9.2] busca Catalogo falhou: "..tostring(e));if U.Status then U.Status.Text="Catalogo abriu, mas a busca falhou."end end
  elseif U.Status then U.Status.Text="Catalogo abriu em modo seguro. Veja o Output."end
 elseif which=="Looks"and looksReady and LooksCtl.Saved then pcall(LooksCtl.Saved)
 elseif which=="Community"and looksReady and LooksCtl.Community then pcall(LooksCtl.Community)
 end
end

if pendingMode then local p=pendingMode;pendingMode=nil;mode(p)end

-- Controles secundarios. Erro aqui nao interfere no launcher.
connect(U.ViewLeft,function()yaw=(yaw-18)%360;render()end,"ViewLeft")
connect(U.ViewRight,function()yaw=(yaw+18)%360;render()end,"ViewRight")
connect(U.ZoomIn,function()zoom=math.min(1.6,zoom+.12);render()end,"ZoomIn")
connect(U.ZoomOut,function()zoom=math.max(.7,zoom-.12);render()end,"ZoomOut")

connect(U.Apply,function()
 if not S or not S.Current then toast("Aguarde a previa.")return end
 local d,e=call("Apply",{body=S.Current,rig=S.Rig});if not d then toast(e)else toast("Skin aplicada.")end
end,"Apply")

connect(U.Save,function()
 if not S or not S.Current then toast("Aguarde a previa.")return end
 if U.SaveName then U.SaveName.Text=""end;vis(U.SaveBox,true)
end,"Save")

connect(U.SaveR15,function()
 if not S then return end
 local d,e=call("Save",{name=U.SaveName and U.SaveName.Text or"",body=S.Current,rig="R15"})
 if not d then toast(e)else S.SetRig("R15",true);vis(U.SaveBox,false);toast("Skin salva como R15.");mode("Looks")end
end,"SaveR15")

connect(U.SaveR6,function()
 if not S then return end
 local d,e=call("Save",{name=U.SaveName and U.SaveName.Text or"",body=S.Current,rig="R6"})
 if not d then toast(e)else S.SetRig("R6",true);vis(U.SaveBox,false);toast("Skin salva como R6.");mode("Looks")end
end,"SaveR6")

connect(U.CancelSave,function()vis(U.SaveBox,false)end,"CancelSave")
connect(U.RigCancel,function()vis(U.RigBox,false)end,"RigCancel")

connect(U.SaveRoblox,function()
 if not S then return end;local d=S.Description();if not d then return end;local rig=S.Rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
 local ok=pcall(function()Avatar:PromptSaveAvatar(d,rig)end);d:Destroy();if not ok then toast("O Roblox nao abriu o salvamento.")end
end,"SaveRoblox")
connect(U.BuyLook,function()if S and S.Current then buyBody(S.Current)else toast("Aguarde a previa.")end end,"BuyLook")
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
connect(U.RigToR15,function()vis(U.RigBox,false);if S then S.SetRig("R15",true)end;mode("Catalog","Emotes")end,"RigToR15")
if U.OutfitSaveNew then connect(U.OutfitSaveNew,function()if U.SaveName then U.SaveName.Text=""end;vis(U.SaveBox,true)end,"OutfitSaveNew")end
if U.HudAction and U.HudAction:IsA("BindableEvent")then U.HudAction.Event:Connect(function(a)
 if a=="Undo"and S then local ok,e=S.Undo();if not ok then toast(e)end
 elseif a=="BuyLook"then if S and S.Current then buyBody(S.Current)else toast("Aguarde a previa.")end
 elseif a=="Blank"and S then local ok,e=S.Blank();if not ok then toast(e)end
 elseif a=="Reset"and S then local ok,e=S.Reset();if not ok then toast(e)end
 elseif a=="Emotes"then mode("Catalog","Emotes")end
end)end

if S and S.Changed and S.Changed.Event then S.Changed.Event:Connect(render)end
if S and type(S.Init)=="function"then
 local ok,a,b=pcall(S.Init)
 if not ok then warn("[V27.9.2] S.Init erro: "..tostring(a))
 elseif a==false then toast(b or"Falha ao iniciar previa.")
 else render()end
end

print("[V27.9.2] SHOP pronta | Catalog="..tostring(catalogReady).." | Looks="..tostring(looksReady).." | Stores="..tostring(storesReady))
