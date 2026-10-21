-- 09C_SHOP_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V73 (SUBSTITUIR)
-- Prévia recuperável, corpo confirmado e compatibilidade com carrinho V55.
local Players=game:GetService("Players")
local Avatar=game:GetService("AvatarEditorService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
if script:IsA('LocalScript')and script.Name~='09C_SHOP_CLIENT'then warn('[ACP V73] Fonte do catálogo no script errado: '..script:GetFullName());return end
local owner=pg:FindFirstChild('ACP_ShopOwner');if owner and owner.Value and owner.Value.Parent then warn('[ACP V73] Catálogo duplicado: '..owner.Value:GetFullName()..'. Mantenha só um 09C_SHOP_CLIENT.');return end
owner=owner or Instance.new('ObjectValue');owner.Name='ACP_ShopOwner';owner.Value=script;owner.Parent=pg
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
 focusActive=on;if on then local music=pg:FindFirstChild('ACP_Music');local popup=music and music:FindFirstChild('MusicPopup');if popup then popup.Visible=false end end;local launcher=U.LauncherGui or pg:FindFirstChild("AvatarShopLauncherGui");if launcher then launcher.Enabled=not on end
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
local catalogError='Inicialização ainda não concluída.'
local function catalogFault(stage,why)
 catalogError=stage..': '..tostring(why);pg:SetAttribute('ACP_CatalogDiagnostic',catalogError);warn('[ACP V73][CATALOGO]['..stage..'] '..tostring(why))
end
local mode=nil;local queueApply;local Home;local compareOriginal=false
local pendingMode=nil;local activeMode=nil
local Extras=nil;local utilityReturn=nil;local utilityActive=false
local loaderBody=nil;local loaderUID=nil
local openLoader=function()vis(U.Loader,true)end
local function closeViews()
 for _,o in pairs({U.Root,U.AvatarTools,U.AccessoryAdjustments,U.Loader,U.CartPanel,U.PlusPanel,U.BodyWindow,U.LookDetail,U.SaveBox,U.PublishBox,U.RigBox})do vis(o,false)end
end
local function hideModes()
 U.HomeOpen=false;vis(U.CatalogHome,false);vis(U.Grid,false);vis(U.Status,false);vis(U.More,false);vis(U.Groups,false);vis(U.SubsPopup,false);vis(U.SubToggle,false)
 vis(U.Query,false);vis(U.SearchGo,false);vis(U.PreviewToggle,false);vis(U.Filter,false);vis(U.Sort,false);vis(U.FilterPanel,false);vis(U.Detail,false)
 vis(U.LooksArea,false);vis(U.CommunityArea,false);vis(U.StoresArea,false)
end
local function openShell(which)
 U.ActivePage=which
 activeMode=which
 utilityActive=false;closeViews();shopFocus(true);vis(U.Root,true);hideModes()
 if type(U.SetWide)=="function"then pcall(U.SetWide,which~="Catalog"and which~="Stores"and which~="Community")end
 U.PageTitle.Text=which=="Looks"and"Meus looks"or which=="Community"and"Comunidade"or which=="Stores"and"Patrocinar + IA"or""
 if which=="Catalog"then
  if type(U.SetWide)=="function"then pcall(U.SetWide,false)end
  U.Groups.Parent.Visible=true;vis(U.Grid,true);vis(U.Status,true);vis(U.More,true);vis(U.Groups,true);vis(U.SubToggle,true)
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
 local done=false;local ok,r
 task.spawn(function()ok,r=pcall(function()return rpc:InvokeServer(action,args or{})end);done=true end)
 local deadline=os.clock()+14;while not done and os.clock()<deadline do task.wait(.05)end
 if not done then return finish(nil,'Operação ainda não confirmada. Confira o resultado antes de repetir; use Recarregar para consultar.')end
 if not ok then return finish(nil,"O servidor nao respondeu.")end
 if not r or not r.ok then return finish(nil,r and r.error or"Falha no servidor.")end
 return finish(r.data)
end
do local o=Rep:FindFirstChild("09C4_OUTFIT_LIBRARY");if o then local ok,r=pcall(require,o);if ok and type(r)=="table"then Extras=r end end end
if A and A.VERSION~="V41_AVATAR_DATA"then warn("[V44] Substitua 08B_AVATAR_DATA pelo modulo da V41.");A=nil end
if S and S.VERSION~="V41_SKIN_STATE"then warn("[V44] Substitua 08D_SKIN_STATE pelo modulo da V41.");S=nil end
if Extras and(Extras.VERSION~='V58'or type(Extras.Init)~='function')then warn('[V58] 09C4_OUTFIT_LIBRARY precisa ser atualizado para V58.');Extras=nil end
local previewModel,previewTrack=nil,nil
local gen,yaw,zoom=0,180,1.02
local pendingPreviewEmote=nil
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local previewController=nil;local retryAvatar;local previewKey;local previewFailed=false
local Native=require(Rep:WaitForChild("08B2_BODY_DESCRIPTION"))
local appliedKey=A and S and S.Base and Native.Key(A,S.Base,S.OriginalRig,false)or nil
local function fit(cam,view,m)Preview.Fit(cam,view,m,yaw,zoom)end
local function stopEmote()
 if previewTrack then pcall(function()previewTrack:Stop(.15);previewTrack:Destroy()end);previewTrack=nil end
 if U.StopEmote then U.StopEmote.Visible=false end
end
local function render(emoteId,force)
 if not A or not S or not S.Current or not U.Viewport then return end
 if not U.Root.Visible then return end
 local shownBody=compareOriginal and S.Original or S.Current;local shownRig=compareOriginal and S.OriginalRig or S.Rig
 local floor=pg:GetAttribute("ACP_PreviewStudio")~=false;local key=Native.Key(A,shownBody,shownRig,floor,emoteId)
 if not force and not previewFailed and previewController and previewController.Alive and not previewTrack and key==previewKey then return gen end
 previewKey=key;previewFailed=false
 if previewController then yaw=previewController.Yaw;zoom=previewController.Zoom end
 gen=gen+1;local mine=gen;stopEmote();previewModel=nil
 U.PreviewInfo.Text=compareOriginal and"Antes"or tostring(S.Rig);U.PreviewError.Text="Carregando avatar...";U.PreviewError.Visible=true;U.PreviewRetry.Visible=false
 previewController=Preview.Mount(U.Viewport,shownBody,shownRig,{yaw=yaw,zoom=zoom,drag=true,changed=function(y,z)yaw,zoom=y,z end,emote=emoteId,floor=floor,
  ready=function(model)if mine==gen then previewModel=model;U.PreviewError.Visible=false;U.PreviewRetry.Visible=false end end,
  failed=function(msg)if mine==gen then previewFailed=true;U.PreviewError.Text=U.Viewport.AbsoluteSize.Y<170 and"Corpo indisponível"or msg;U.PreviewError:SetAttribute("LoadError",msg);U.PreviewError.Visible=true;U.PreviewRetry.Visible=true end end})
 return mine
end
connect(U.PreviewRetry,function()if retryAvatar then retryAvatar()end end,"PreviewRetry")
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
 if not previewModel then render()end;local mine=gen;local limit=os.clock()+8
 while mine==gen and not previewModel and os.clock()<limit do task.wait(.08)end
 if mine~=gen or not previewModel then return false,"A prévia mudou ou não carregou."end
 local m=previewModel;local hum=m:FindFirstChildOfClass('Humanoid');if not hum then return false,'Humanoid ausente na prévia.'end
 local data,err=call('PhotoEmote',{id=tonumber(id)});if not data then return false,err end
 if mine~=gen or previewModel~=m then return false,'A prévia mudou.'end
 if data.id~=tonumber(id)or data.source~='RobloxEmote'or not tostring(data.animation):match('^rbxassetid://%d+$')then return false,'Clip do emote não confirmado.'end
 local animator=hum:FindFirstChildOfClass('Animator')or Instance.new('Animator');animator.Parent=hum
 local animation=Instance.new('Animation');animation.AnimationId=data.animation
 local ok,track=pcall(function()return animator:LoadAnimation(animation)end);animation:Destroy();if not ok then return false,'O Roblox recusou a animação na prévia.'end
 track.Priority=Enum.AnimationPriority.Action;track.Looped=true;track:Play(.12);local deadline=os.clock()+6
 while track.Length<=0 and mine==gen and os.clock()<deadline do task.wait(.05)end
 if mine~=gen or track.Length<=0 then track:Stop(0);track:Destroy();return false,'Esse emote não carregou. Tente outro.'end
 stopEmote();previewTrack=track;if U.StopEmote then U.StopEmote.Visible=true end;return true
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
 Home=require(Rep:WaitForChild('09C16_CATALOG_HOME')).Build({U=U,A=A,call=call,toast=toast,browse=function(kind)Catalog.Preset(kind)end,showItem=function(item)Catalog.ShowItem(item)end})
 require(Rep:WaitForChild('09C15_AVATAR_TOOLS')).Build({U=U,S=S,A=A,call=call,toast=toast,favorites=function()Home.OpenFavorites()end,compare=function(on)compareOriginal=on;render(nil,true)end})
 local zero=require(Rep:WaitForChild('09C14_NEW_AVATAR')).Build({U=U,A=A,S=S,call=call,toast=toast});U.NewAvatarWizard=zero
 if Extras and type(Extras.Init)=="function"then local worked,why=pcall(Extras.Init,{U=U,A=A,S=S,pl=pl,call=call,toast=toast,openUtility=openUtility,closeUtility=closeUtility});if not worked then warn("[V57] Utilidades: "..tostring(why))end end
 local issues={};for _,n in ipairs({'09C2_SHOP_CATALOG','09C3_CATALOG_FILTERS','09C4_OUTFIT_LIBRARY'})do local count=0;for _,o in ipairs(Rep:GetChildren())do if o.Name==n then count=count+1;if not o:IsA('ModuleScript')then issues[#issues+1]=n..' deve ser ModuleScript'end end end;if count==0 then issues[#issues+1]='Falta '..n..' em ReplicatedStorage'elseif count>1 then issues[#issues+1]=n..' duplicado'end end
 if #issues>0 then catalogFault('INSTALAÇÃO',table.concat(issues,'; '))else
  local ok,m=pcall(require,Rep:FindFirstChild('09C2_SHOP_CATALOG'))
  if not ok then catalogFault('REQUIRE 09C2_SHOP_CATALOG',m)
  elseif type(m)~='table'or type(m.Init)~='function'then catalogFault('EXPORTAÇÃO 09C2_SHOP_CATALOG','Fonte incorreta: falta Init().')else
   local ok2,r=xpcall(function()return m.Init({U=U,A=A,S=S,pl=pl,toast=toast,call=call,playEmote=playPreviewEmote,preview=function()if activeMode~='Catalog'then mode('Catalog')end;if U.ShowPreview then U.ShowPreview()end end})end,debug.traceback)
   if ok2 and type(r)=='table'and type(r.Preset)=='function'then Catalog=r;catalogReady=true;pg:SetAttribute('ACP_CatalogDiagnostic','OK V73');print('[ACP V73] Catálogo inicializado.')else catalogFault('INIT 09C2_SHOP_CATALOG',r)end
  end
 end
 local o2=Rep:FindFirstChild("09C1_SHOP_LOOKS")
 if o2 then
  local ok,m=pcall(require,o2)
  if ok and type(m)=="table"and type(m.Init)=="function"then
   local ok2,r=pcall(m.Init,{U=U,A=A,S=S,call=call,toast=toast,buyBody=buyBody,showPublic=nil})
   if ok2 and type(r)=="table"then LooksCtl=r;looksReady=true;print("[V44] 09C1 Init OK")else warn("[V44] 09C1 Init falhou: "..tostring(r))end
  else warn("[V44] require 09C1 falhou: "..tostring(m))end
 end
 local os=Rep:FindFirstChild('09C5_UGC_STORES')
 if os then local ok,m=pcall(require,os);if ok then local ready,r=pcall(m.Init,{U=U,A=A,call=call,toast=toast,openAssistant=function()vis(U.Root,false);shopFocus(false);pg:SetAttribute('ACP_OpenAINonce',(tonumber(pg:GetAttribute('ACP_OpenAINonce'))or 0)+1)end,showItem=function(item)Catalog.ShowItem(item)end});if ready then StoresCtl=r;storesReady=true else warn('[V60] Destaques: '..tostring(r))end end end
else
 catalogFault('DADOS','08B_AVATAR_DATA ou 08D_SKIN_STATE não carregou; confira os módulos e os erros anteriores no Output.')
end
mode=function(which,preset)
 openShell(which)
 if which=="Catalog"then
  if catalogReady then
   local ok,e=pcall(function()if preset and Catalog.Preset then Catalog.Preset(preset)elseif Home then Home.Open()else Catalog.Search()end end)
   if not ok then warn("[V44] busca Catalogo falhou: "..tostring(e));if U.Status then U.Status.Text="Catalogo abriu, mas a busca falhou."end end
  elseif U.Status then U.Status.Text='Catálogo indisponível • '..catalogError;toast('Catálogo: '..catalogError..' • corrija e reinicie Play.')end
 elseif which=="Looks"and looksReady and LooksCtl.Saved then pcall(LooksCtl.Saved)
 elseif which=="Community"and looksReady and LooksCtl.Community then pcall(LooksCtl.Community)
 elseif which=="Stores"and storesReady and StoresCtl.Search then pcall(StoresCtl.Search)
 end
 if which=="Catalog"and queueApply then queueApply()end
end
if pendingMode then local p=pendingMode;pendingMode=nil;mode(p[1],p[2]);if p[3]and U.ShowPreview then U.ShowPreview()end end
connect(U.ViewLeft,function()if previewController then previewController.Rotate(-18);yaw=previewController.Yaw end end,"ViewLeft")
connect(U.ViewRight,function()if previewController then previewController.Rotate(18);yaw=previewController.Yaw end end,"ViewRight")
connect(U.ZoomIn,function()zoom=math.min(1.6,zoom+.12);refit()end,"ZoomIn")
connect(U.ZoomOut,function()zoom=math.max(.7,zoom-.12);refit()end,"ZoomOut")
local Confirm=require(Rep:WaitForChild("09C10_CONFIRM_ACTION")).Build(U.Gui)
local applying=false;local acceptGuard=false;local applyStamp=0;local applyAgain=false
local applyAvatar;local notifySave=false;local appliedHere=false;local saveErrorAt=-30
pl:GetAttributeChangedSignal('ACP_AvatarSaveState'):Connect(function()
 local state=pl:GetAttribute('ACP_AvatarSaveState')
 if state=='saved'and notifySave then notifySave=false;toast('Skin guardada. Você entrará com ela na próxima vez.')
 elseif state=='unavailable'and appliedHere and os.clock()-saveErrorAt>=30 then saveErrorAt=os.clock();toast('Skin aplicada, mas o salvamento não respondeu. Tente Aplicar novamente.')end
end)
pl:GetAttributeChangedSignal('ACP_AvatarRestoreError'):Connect(function()local e=pl:GetAttribute('ACP_AvatarRestoreError');if e then toast(e)end end)
queueApply=function()
 if acceptGuard or not S or not S.Current then return end
 applyStamp=applyStamp+1;local stamp=applyStamp
 if Native.Key(A,S.Current,S.Rig,false)==appliedKey then return end
 task.delay(.4,function()if stamp==applyStamp and Native.Key(A,S.Current,S.Rig,false)~=appliedKey then if applying then applyAgain=true else applyAvatar(true)end end end)
end
applyAvatar=function(quiet)
 if applying then applyAgain=true;return end
 if not S or not S.Current then toast("Aguarde a previa.")return end
 applying=true;U.Apply.Text="AGUARDE";local mine=S.Generation
 local d,e=call("Apply",{body=A.Copy(S.Current),rig=S.Rig,base=S.Base,replace=S.Replace==true})
 if d and d.body then appliedKey=Native.Key(A,d.body,d.liveRig or S.Rig,false)end
 if d and d.body and S.AcceptApplied then acceptGuard=true;S.AcceptApplied(d.body,mine,d.liveRig);acceptGuard=false end
 applying=false;U.Apply.Text="Aplicar"
 if not d then toast(e)else appliedHere=true;if not quiet then U.BodyWindow.Visible=false;notifySave=pl:GetAttribute('ACP_AvatarSaveState')~='saved';toast(d.visualPending and'Aplicado no servidor. Conferindo roupa no mapa…'or'Skin aplicada.')end end
 if applyAgain then applyAgain=false;queueApply()end
end
connect(U.Apply,function()applyAvatar(false)end,"Apply");connect(U.BodyApply,function()applyAvatar(false)end,"BodyApply")
local SaveFlow=require(Rep:WaitForChild('09C18_AVATAR_SAVE')).Build({U=U,A=A,S=S,call=call,toast=toast,buyBody=buyBody,showItem=function(item)mode('Catalog');Catalog.ShowItem(item)end})
local Utilities=require(Rep:WaitForChild('09C19_EDITOR_UTILITIES')).Build({U=U,A=A,S=S,call=call,toast=toast,showItem=function(it)mode('Catalog');Catalog.ShowItem(it)end})
connect(U.Save,SaveFlow.Open,"Save")
connect(U.SaveR15,function()
 if not S then return end
 local d,e=call("Save",{name=U.SaveName and U.SaveName.Text or"",body=S.Current,rig="R15"})
 if not d then toast(e)else S.SetRig("R15",true);vis(U.SaveBox,false);toast(d.persistent==false and"Salva somente nesta sessão. O armazenamento está indisponível."or"Skin R15 salva.");mode("Looks")end
end,"SaveR15")
connect(U.SaveR6,function()
 if not S then return end;if A.BodyRequiresR15(S.Current)then toast("Esse corpo usa R15. Salve em R15 para preservar sua aparência.");return end
 local d,e=call("Save",{name=U.SaveName and U.SaveName.Text or"",body=S.Current,rig="R6"})
 if not d then toast(e)else S.SetRig("R6",true);vis(U.SaveBox,false);toast(d.persistent==false and"Salva somente nesta sessão. O armazenamento está indisponível."or"Skin R6 salva.");mode("Looks")end
end,"SaveR6")
connect(U.CancelSave,function()vis(U.SaveBox,false)end,"CancelSave")
connect(U.SaveClose,function()vis(U.SaveBox,false)end,"SaveClose")
connect(U.PublishClose,function()vis(U.PublishBox,false)end,"PublishClose")
connect(U.RigClose,function()pendingPreviewEmote=nil;vis(U.RigBox,false)end,"RigClose")
connect(U.RigCancel,function()pendingPreviewEmote=nil;vis(U.RigBox,false)end,"RigCancel")
local function saveRobloxAvatar()SaveFlow.Open()end
connect(U.SaveRoblox,saveRobloxAvatar,"SaveRoblox")
connect(U.Undo,function()if S then local ok,e=S.Undo();if not ok then toast(e)end end end,"Undo")
connect(U.Redo,function()if S then local ok,e=S.Redo();if not ok then toast(e)end end end,"Redo")
connect(U.Blank,function()if S then local ok,e=S.Blank();if not ok then toast(e)end end end,"Blank")
connect(U.Reset,SaveFlow.Restore,"Reset")
connect(U.LoaderClose,function()U.LoaderQuery:ReleaseFocus(false);loaderReset(false);closeUtility()end,"LoaderClose")
connect(U.LoaderSearch,doLoaderSearch,"LoaderSearch")
if U.LoaderQuery and U.LoaderQuery:IsA("TextBox")then U.LoaderQuery.FocusLost:Connect(function(enter)if enter then doLoaderSearch()end end)end
if loaderMine then connect(loaderMine,function()U.LoaderQuery.Text=pl.Name;doLoaderSearch()end,"LoaderMine")end
connect(U.LoaderUse,function()useLoader("R15")end,"LoaderUseR15")
if loaderUseR6 then connect(loaderUseR6,function()useLoader("R6")end,"LoaderUseR6")end
connect(U.RigToR15,function()vis(U.RigBox,false);if S then S.SetRig("R15")end;local id=pendingPreviewEmote;pendingPreviewEmote=nil;if id then local ok,e=playPreviewEmote(id);toast(ok and"Emote tocando."or e)else mode("Catalog","Emotes")end end,"RigToR15")
if U.OutfitSaveNew then connect(U.OutfitSaveNew,SaveFlow.Open,"OutfitSaveNew")end
if U.HudAction and U.HudAction:IsA("BindableEvent")then U.HudAction.Event:Connect(function(a)
 if a=="Undo"and S then local ok,e=S.Undo();if not ok then toast(e)end
 elseif a=="BuyLook"then if S and S.Current then buyBody(S.Current)else toast("Aguarde a previa.")end
 elseif a=="Blank"and S then mode("Catalog");if U.NewAvatarWizard then U.NewAvatarWizard.Open()end
 elseif a=="Reset"and S then SaveFlow.Restore()
 elseif a=="Wearing"then SaveFlow.Wearing()
 elseif a=="CleanUI"then Utilities.Clean()
 elseif a=="FreeCamera"then Utilities.Camera()
 elseif a=="Purchases"then Utilities.Purchases()
 elseif a=="Redo"then local ok,e=S.Redo();if not ok then toast(e)end
 elseif a=="Cart"then if Extras and Extras.Open then Extras.Open()else toast("O carrinho está carregando.")end
 elseif a=="SaveRoblox"then saveRobloxAvatar()
 elseif a=="Emotes"then mode("Catalog","Emotes")end
end)end
if looksReady then require(Rep:WaitForChild("09C9_PLAYER_INSPECT")).Init({U=U,S=S,A=A,call=call,toast=toast,open=function()openShell("Community")end,show=LooksCtl.ShowLook})end
pg:GetAttributeChangedSignal("ACP_PreviewStudio"):Connect(render)
pg:GetAttributeChangedSignal('ACP_OpenCatalogAsset'):Connect(function()
 local id=tonumber(pg:GetAttribute('ACP_OpenCatalogAsset'));if not id or id<=0 or not catalogReady then return end
 mode('Catalog');task.spawn(function()local ok,item=pcall(function()return Avatar:GetItemDetailsAsync(id,Enum.AvatarItemType.Asset)end);if ok and item then Catalog.ShowItem(item)else toast('O item não carregou. Tente pesquisar no catálogo.')end end)
end)
if S and S.Changed and S.Changed.Event then S.Changed.Event:Connect(function()render();queueApply()end)end
if S and type(S.Init)=="function"then
 local attempts=0
 local function initAvatar()
  if S.Current then return end;attempts=attempts+1
  local ok,a,b=pcall(S.Init,call)
  if ok and a then appliedKey=Native.Key(A,S.Current,S.Rig,false);return
  elseif attempts<24 then task.delay(.6,initAvatar)
  else U.PreviewError.Text=b or"O Roblox não carregou seu avatar.";U.PreviewError.Visible=true;U.PreviewRetry.Visible=true end
 end
 retryAvatar=function()attempts=0;if S.Current then render(nil,true);queueApply()else task.defer(initAvatar)end end
 pl.CharacterAdded:Connect(function()attempts=0;task.defer(initAvatar)end)
 pl:GetAttributeChangedSignal("ACP_AvatarEpoch"):Connect(function()if not S.Current then attempts=0;task.defer(initAvatar)end end)
 U.Root:GetPropertyChangedSignal("Visible"):Connect(function()if U.Root.Visible and not S.Current then attempts=0;task.defer(initAvatar)end end)
 initAvatar()
end
