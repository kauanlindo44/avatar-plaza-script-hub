-- 09C_SHOP_CLIENT
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V44 - previa clara 360 graus e corpo aplicado no avatar real.
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
 warn("[V44] DUPLICATA: existem "..duplicateCount.." scripts 09C_SHOP_CLIENT em PlayerScripts. Deixe apenas 1.")
end
local uiObj=Rep:WaitForChild("09A_SHOP_UI")
local okUI,UI=pcall(require,uiObj)
if not okUI then
 warn("[V44] 09A falhou: "..tostring(UI))
 return
end
if type(UI)~="table"or type(UI.Build)~="function"then
 warn("[V44] 09A sem Build()")
 return
end
if UI.VERSION~="V44_STUDIO_UI"then
 warn("[V44] 09A ERRADO/DUPLICADO. VERSION="..tostring(UI.VERSION))
 return
end
local okBuild,U=pcall(UI.Build,pl)
if not okBuild or type(U)~="table"then
 warn("[V44] Build falhou: "..tostring(U))
 return
end
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
 warn("[V44] botao ausente: "..tostring(name));return false
end
local Catalog={Search=function()if U.Status then U.Status.Text="Catalogo carregando..."end end,Preset=function()end,ShowItem=function()end}
local LooksCtl={Saved=function()toast("Minhas Skins carregando...")end,Community=function()toast("Comunidade carregando...")end}
local StoresCtl={Search=function()end}
local catalogReady,looksReady,storesReady=false,false,false
local mode=nil
local pendingMode=nil;local activeMode=nil
local Extras=nil;local utilityReturn=nil;local utilityActive=false
local loaderBody=nil;local loaderUID=nil
local openLoader=function()vis(U.Loader,true)end
local function closeViews()
 for _,o in ipairs({U.Root,U.Loader,U.CartPanel,U.PlusPanel,U.BodyWindow,U.LookDetail,U.SaveBox,U.PublishBox,U.RigBox})do vis(o,false)end
end
local function hideModes()
 vis(U.Grid,false);vis(U.Status,false);vis(U.More,false);vis(U.Groups,false);vis(U.SubsPopup,false);vis(U.SubToggle,false)
 vis(U.Query,false);vis(U.SearchGo,false);vis(U.PreviewToggle,false);vis(U.Filter,false);vis(U.Sort,false);vis(U.FilterPanel,false);vis(U.Detail,false)
 vis(U.LooksArea,false);vis(U.CommunityArea,false);vis(U.StoresArea,false)
end
local function openShell(which)
 activeMode=which
 utilityActive=false;closeViews();shopFocus(true);vis(U.Root,true);hideModes()
 if type(U.SetWide)=="function"then pcall(U.SetWide,which~="Catalog")end
 U.PageTitle.Text=which=="Looks"and"Meus looks"or which=="Community"and"Comunidade"or which=="Stores"and"Lojas UGC"or""
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
local function openUtility(which)
 if not utilityActive then utilityReturn=U.Root.Visible and activeMode or nil end
 utilityActive=true;closeViews();hideModes();shopFocus(true)
 vis(which=="Cart"and U.CartPanel or which=="Plus"and U.PlusPanel or U.Loader,true)
end
local function closeUtility()
 closeViews();utilityActive=false;local back=utilityReturn;utilityReturn=nil
 if back then openShell(back)else shopFocus(false)end
end
connect(U.Close,function()closeViews();shopFocus(false)end,"Close")
connect(U.CartClose,closeUtility,"CartClose")
if U.OpenRequest and U.OpenRequest:IsA("BindableEvent")then
 U.OpenRequest.Event:Connect(function(which)
  if which=="Loader"then openLoader();return end
  if which=="Cart"or which=="Plus"then
   if Extras then if which=="Cart"then Extras.Open()else Extras.OpenPlus()end elseif which=="Cart"then openUtility(which)else pcall(function()Market:PromptRobloxSubscriptionPurchase(pl)end)end;return
  end
  local target=which=="Stores"and"Stores"or which=="Community"and"Community"or which=="Looks"and"Looks"or"Catalog"
  if mode then mode(target,which=="Emotes"and"Emotes"or nil);if which=="Preview"and U.ShowPreview then U.ShowPreview()end else pendingMode={target,which=="Emotes"and"Emotes"or nil,which=="Preview"};openShell(target)end
 end)
end
local A,S=nil,nil
do
 local o=Rep:FindFirstChild("08B_AVATAR_DATA")
 if o then local ok,r=pcall(require,o);if ok then A=r else warn("[V44] 08B falhou: "..tostring(r))end end
end
do
 local o=Rep:FindFirstChild("08D_SKIN_STATE")
 if o then local ok,r=pcall(require,o);if ok then S=r else warn("[V44] 08D falhou: "..tostring(r))end end
end
local rem=Rep:FindFirstChild("LMShop_Remotes")
local rpc=rem and rem:FindFirstChild("Request")
local requestTicket,servingTicket=0,1
local function call(action,args)
 requestTicket=requestTicket+1;local ticket=requestTicket
 while ticket~=servingTicket do task.wait(.03)end
 local function finish(data,err)servingTicket=servingTicket+1;return data,err end
 if not rpc or not rpc.Parent then rem=Rep:FindFirstChild("LMShop_Remotes");rpc=rem and rem:FindFirstChild("Request")end
 if not rpc then return finish(nil,"O editor ainda está conectando ao servidor.")end
 local ok,r=pcall(function()return rpc:InvokeServer(action,args or{})end)
 if not ok then return finish(nil,"O servidor nao respondeu.")end
 if not r or not r.ok then return finish(nil,r and r.error or"Falha no servidor.")end
 return finish(r.data)
end
do local o=Rep:FindFirstChild("09C4_OUTFIT_LIBRARY");if o then local ok,r=pcall(require,o);if ok and type(r)=="table"then Extras=r end end end
if A and A.VERSION~="V41_AVATAR_DATA"then warn("[V44] Substitua 08B_AVATAR_DATA pelo modulo da V41.");A=nil end
if S and S.VERSION~="V41_SKIN_STATE"then warn("[V44] Substitua 08D_SKIN_STATE pelo modulo da V41.");S=nil end
if Extras and Extras.VERSION~="V44_EDITOR"then warn("[V44] Substitua 09C4_OUTFIT_LIBRARY pelo modulo da V44.");Extras=nil end
local previewModel,previewTrack=nil,nil
local gen,yaw,zoom=0,180,1.02
local pendingPreviewEmote=nil
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local previewController=nil
local function fit(cam,view,m)Preview.Fit(cam,view,m,yaw,zoom)end
local function stopEmote()
 if previewTrack then pcall(function()previewTrack:Stop(.15)end);previewTrack=nil end
 if U.StopEmote then U.StopEmote.Visible=false end
end
local function render(emoteId)
 if not A or not S or not S.Current or not U.Viewport then return end
 if previewController then yaw=previewController.Yaw;zoom=previewController.Zoom end
 gen=gen+1;local mine=gen;stopEmote();previewModel=nil
 U.PreviewInfo.Text=tostring(S.Rig)
 previewController=Preview.Mount(U.Viewport,S.Current,S.Rig,{yaw=yaw,zoom=zoom,drag=true,changed=function(y,z)yaw,zoom=y,z end,emote=emoteId,floor=pg:GetAttribute("ACP_PreviewStudio")~=false,
  ready=function(model)if mine==gen then previewModel=model end end,
  failed=function(msg)if mine==gen then U.PreviewInfo.Text=msg end end})
 return mine
end
local function buyBody(body)
 if not body then toast("Nao ha itens na previa.")return end;if Extras then Extras.Open(body);return end;toast("Preparando compra dos itens...")
 local d,e=call("BulkPurchase",{body=body});if e then toast(e)return end
 if d then toast(d.remaining and d.remaining>0 and("Compra: "..tostring(d.count).." itens; restam "..tostring(d.remaining)..".")or("Compra aberta para "..tostring(d.count or 0).." itens."))end
end
local loaderUseR6=U.LoaderUseR6;local loaderMine=U.LoaderMine;local loaderGeneration=0
local function loaderReset(clearQuery)
 loaderGeneration=loaderGeneration+1;loaderBody=nil
 if clearQuery then U.LoaderQuery.Text=""end
 U.LoaderName.Text="Nenhum avatar selecionado.";U.LoaderStatus.Text="Busque um usuário ou use MEU."
 U.LoaderThumb.Image="";U.LoaderUse.Visible=false;loaderUseR6.Visible=false
end
openLoader=function()
 openUtility("Loader");loaderReset(true);local mine=loaderGeneration
 task.defer(function()if mine==loaderGeneration and U.Loader.Visible then pcall(function()U.LoaderQuery:CaptureFocus()end)end end)
end
local function resolveLoaderUser(raw)
 raw=tostring(raw or""):match("^%s*(.-)%s*$"):gsub("^@","");if raw==""then return nil,nil,"Digite um usuario ou ID."end
 local uid=tonumber(raw)
 if uid then uid=math.floor(uid);if uid<=0 then return nil,nil,"UserId invalido."end
 else local ok,id=pcall(function()return Players:GetUserIdFromNameAsync(raw)end);if not ok then return nil,nil,"Usuario nao encontrado."end;uid=id end
 local okName,name=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);name=okName and name or raw
 local display=name;local okInfo,info=pcall(function()return game:GetService("UserService"):GetUserInfosByUserIdsAsync({uid})end)
 if okInfo and type(info)=="table"and info[1]and info[1].DisplayName then display=info[1].DisplayName end
 return uid,name,nil,display
end
local function doLoaderSearch()
 if not A then toast("Sistema de avatar ainda nao carregou.")return end
 loaderGeneration=loaderGeneration+1;local mine=loaderGeneration;loaderBody=nil
 local uid,name,err,display=resolveLoaderUser(U.LoaderQuery and U.LoaderQuery.Text or"");if mine~=loaderGeneration then return end;if err then if U.LoaderStatus then U.LoaderStatus.Text=err end;return end
 U.LoaderStatus.Text="Buscando avatar de @"..tostring(name).."...";U.LoaderUse.Visible=false;if loaderUseR6 then loaderUseR6.Visible=false end
 task.spawn(function()
  local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(uid)end)
  if mine~=loaderGeneration then if ok and desc then desc:Destroy()end;return end
  if not ok or not desc then U.LoaderStatus.Text="Avatar indisponivel para esse usuario.";return end
  local packed=A.Pack(desc);desc:Destroy();if not packed then U.LoaderStatus.Text="Nao foi possivel ler esse avatar.";return end
  loaderUID=uid;loaderBody=packed;U.LoaderName.Text=tostring(display).."  •  @"..tostring(name);U.LoaderThumb.Image="rbxthumb://type=Avatar&id="..uid.."&w=420&h=420"
  U.LoaderStatus.Text="Avatar pronto. Escolha R6 ou R15 para experimentar.";U.LoaderUse.Visible=true;if loaderUseR6 then loaderUseR6.Visible=true end
 end)
end
local function useLoader(rig)
 if not loaderBody then toast("Busque um avatar primeiro.")return end;if not S then toast("Estado da skin indisponivel.")return end
 if loaderUID and Players:GetPlayerByUserId(loaderUID)and loaderUID~=pl.UserId then local allowed,e=call("InspectUse",{id=loaderUID});if not allowed then toast(e);return end else call("ClearInspect")end
 local ok,err=S.Set(loaderBody,false,rig);if not ok then toast(err or"Nao foi possivel carregar a skin.")return end
 loaderGeneration=loaderGeneration+1;vis(U.Loader,false);mode("Catalog");if U.ShowPreview then U.ShowPreview()end;toast("Avatar carregado na prévia em "..rig..".")
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
 if previewController then previewController.Yaw=yaw;previewController.Zoom=zoom;previewController.Fit()end
end
if U.StopEmote then U.StopEmote.Activated:Connect(function()stopEmote();render()end)end
if U.Viewport then U.Viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit)end
U.Root:GetPropertyChangedSignal("Visible"):Connect(function()
 if U.Root.Visible then if not previewModel then render()end else gen=gen+1;stopEmote();Preview.Unmount(U.Viewport);previewModel=nil;previewController=nil end
end)
if A and S then
 if Extras and type(Extras.Init)=="function"then pcall(Extras.Init,{U=U,A=A,S=S,pl=pl,call=call,toast=toast,openUtility=openUtility,closeUtility=closeUtility})end
 local o=Rep:FindFirstChild("09C2_SHOP_CATALOG")
 if o then
  local ok,m=pcall(require,o)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,pl=pl,toast=toast,call=call,playEmote=playPreviewEmote,preview=function()if activeMode~="Catalog"then mode("Catalog")end;if U.ShowPreview then U.ShowPreview()end end})
   if ok2 and type(r)=="table"then Catalog=r;catalogReady=true;print("[V44] 09C2 Init OK")else warn("[V44] 09C2 Init falhou: "..tostring(r))end
  else warn("[V44] require 09C2 falhou: "..tostring(m))end
 end
 local o2=Rep:FindFirstChild("09C1_SHOP_LOOKS")
 if o2 then
  local ok,m=pcall(require,o2)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,call=call,toast=toast,buyBody=buyBody,showPublic=nil})
   if ok2 and type(r)=="table"then LooksCtl=r;looksReady=true;print("[V44] 09C1 Init OK")else warn("[V44] 09C1 Init falhou: "..tostring(r))end
  else warn("[V44] require 09C1 falhou: "..tostring(m))end
 end
 local o3=Rep:FindFirstChild("09C5_UGC_STORES")
 if o3 then
  local ok,m=pcall(require,o3)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,toast=toast,showItem=function(item)if catalogReady and Catalog.ShowItem then Catalog.ShowItem(item)end end})
   if ok2 and type(r)=="table"then StoresCtl=r;storesReady=true;print("[V44] 09C5 Init OK")else warn("[V44] 09C5 Init falhou: "..tostring(r))end
  else warn("[V44] require 09C5 falhou: "..tostring(m))end
 end
else
 warn("[V44] 08B/08D indisponivel; launcher segue ativo.")
end
mode=function(which,preset)
 openShell(which)
 if which=="Catalog"then
  if catalogReady then
   local ok,e=pcall(function()if preset and Catalog.Preset then Catalog.Preset(preset)else Catalog.Search()end end)
   if not ok then warn("[V44] busca Catalogo falhou: "..tostring(e));if U.Status then U.Status.Text="Catalogo abriu, mas a busca falhou."end end
  elseif U.Status then U.Status.Text="Catalogo abriu em modo seguro. Veja o Output."end
 elseif which=="Looks"and looksReady and LooksCtl.Saved then pcall(LooksCtl.Saved)
 elseif which=="Community"and looksReady and LooksCtl.Community then pcall(LooksCtl.Community)
 elseif which=="Stores"and storesReady and StoresCtl.Search then pcall(StoresCtl.Search)
 end
end
if pendingMode then local p=pendingMode;pendingMode=nil;mode(p[1],p[2]);if p[3]and U.ShowPreview then U.ShowPreview()end end
connect(U.ViewLeft,function()if previewController then previewController.Rotate(-18);yaw=previewController.Yaw end end,"ViewLeft")
connect(U.ViewRight,function()if previewController then previewController.Rotate(18);yaw=previewController.Yaw end end,"ViewRight")
connect(U.ZoomIn,function()zoom=math.min(1.6,zoom+.12);refit()end,"ZoomIn")
connect(U.ZoomOut,function()zoom=math.max(.7,zoom-.12);refit()end,"ZoomOut")
local Confirm=require(Rep:WaitForChild("09C10_CONFIRM_ACTION")).Build(U.Gui)
local applying=false
local function applyAvatar()
 if applying then return end
 if not S or not S.Current then toast("Aguarde a previa.")return end
 applying=true;U.Apply.Text="AGUARDE";local mine=S.Generation
 local d,e=call("Apply",{body=A.Copy(S.Current),rig=S.Rig,base=S.Base,replace=S.Replace==true})
 applying=false;U.Apply.Text="Aplicar"
 if d and d.body and S.AcceptApplied then S.AcceptApplied(d.body,mine)end
 if not d then toast(e)elseif d.liveRig and d.wantedRig and d.liveRig~=d.wantedRig then toast(d.liveRig=="R6"and"Look aplicado em R6. Proporções exigem R15 no avatar em jogo."or"Look aplicado em R15. O rig da prévia continua salvo.")else U.BodyWindow.Visible=false;toast("Skin e proporções aplicadas no jogo.")end
end
connect(U.Apply,applyAvatar,"Apply");connect(U.BodyApply,applyAvatar,"BodyApply")
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
connect(U.SaveClose,function()vis(U.SaveBox,false)end,"SaveClose")
connect(U.PublishClose,function()vis(U.PublishBox,false)end,"PublishClose")
connect(U.RigClose,function()pendingPreviewEmote=nil;vis(U.RigBox,false)end,"RigClose")
connect(U.RigCancel,function()pendingPreviewEmote=nil;vis(U.RigBox,false)end,"RigCancel")
local function saveRobloxAvatar()
 if not S then toast("Aguarde a prévia.");return end;local d=S.Description();if not d then return end;local rig=S.Rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
 local ok=pcall(function()Avatar:PromptSaveAvatar(d,rig)end);d:Destroy();if not ok then toast("O Roblox não abriu o salvamento.")end
end
connect(U.SaveRoblox,saveRobloxAvatar,"SaveRoblox")
connect(U.Undo,function()if S then local ok,e=S.Undo();if not ok then toast(e)end end end,"Undo")
connect(U.Redo,function()if S then local ok,e=S.Redo();if not ok then toast(e)end end end,"Redo")
connect(U.Blank,function()if S then local ok,e=S.Blank();if not ok then toast(e)end end end,"Blank")
connect(U.Reset,function()Confirm("Restaurar o avatar original?",function()call("ClearInspect");if S then local ok,e=S.Reset();if not ok then toast(e)else toast("Avatar restaurado. DESFAZER recupera a edição anterior.")end end end)end,"Reset")
connect(U.LoaderClose,function()U.LoaderQuery:ReleaseFocus(false);loaderReset(false);closeUtility()end,"LoaderClose")
connect(U.LoaderSearch,doLoaderSearch,"LoaderSearch")
if U.LoaderQuery and U.LoaderQuery:IsA("TextBox")then U.LoaderQuery.FocusLost:Connect(function(enter)if enter then doLoaderSearch()end end)end
if loaderMine then connect(loaderMine,function()U.LoaderQuery.Text=pl.Name;doLoaderSearch()end,"LoaderMine")end
connect(U.LoaderUse,function()useLoader("R15")end,"LoaderUseR15")
if loaderUseR6 then connect(loaderUseR6,function()useLoader("R6")end,"LoaderUseR6")end
connect(U.RigToR15,function()vis(U.RigBox,false);if S then S.SetRig("R15")end;local id=pendingPreviewEmote;pendingPreviewEmote=nil;if id then local ok,e=playPreviewEmote(id);toast(ok and"Emote tocando."or e)else mode("Catalog","Emotes")end end,"RigToR15")
if U.OutfitSaveNew then connect(U.OutfitSaveNew,function()if U.SaveName then U.SaveName.Text=""end;vis(U.SaveBox,true)end,"OutfitSaveNew")end
if U.HudAction and U.HudAction:IsA("BindableEvent")then U.HudAction.Event:Connect(function(a)
 if a=="Undo"and S then local ok,e=S.Undo();if not ok then toast(e)end
 elseif a=="BuyLook"then if S and S.Current then buyBody(S.Current)else toast("Aguarde a previa.")end
 elseif a=="Blank"and S then mode("Catalog");if U.ShowPreview then U.ShowPreview()end;local ok,e=S.Blank();if not ok then toast(e)end
 elseif a=="Reset"and S then Confirm("Restaurar o avatar original?",function()call("ClearInspect");local ok,e=S.Reset();if not ok then toast(e)end end)
 elseif a=="Cart"then if Extras and Extras.Open then Extras.Open()else toast("O carrinho está carregando.")end
 elseif a=="SaveRoblox"then saveRobloxAvatar()
 elseif a=="Emotes"then mode("Catalog","Emotes")end
end)end
if looksReady then require(Rep:WaitForChild("09C9_PLAYER_INSPECT")).Init({U=U,call=call,toast=toast,open=function()openShell("Community")end,show=LooksCtl.ShowLook})end
pg:GetAttributeChangedSignal("ACP_PreviewStudio"):Connect(render)
if S and S.Changed and S.Changed.Event then S.Changed.Event:Connect(render)end
if S and type(S.Init)=="function"then
 local attempts=0
 local function initAvatar()
  if S.Current then return end;attempts=attempts+1
  local ok,a,b=pcall(S.Init,call)
  if ok and a then return
  elseif attempts<8 then task.delay(.6,initAvatar)
  else U.PreviewInfo.Text="Avatar indisponível";toast(b or"Reabra o catálogo para carregar sua skin.")end
 end
 pl.CharacterAdded:Connect(function()attempts=0;task.defer(initAvatar)end)
 U.Root:GetPropertyChangedSignal("Visible"):Connect(function()if U.Root.Visible and not S.Current then attempts=0;task.defer(initAvatar)end end)
 initAvatar()
end
