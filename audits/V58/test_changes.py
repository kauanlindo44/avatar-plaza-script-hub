from test_support import *
ACCOUNTS=module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')
ENGINE=THEME+ACCOUNTS+module('09I2_ASSISTANT_ENGINE')
AI=THEME+DATA+SERVER+ACCOUNTS+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')
case('native_ascii_probe_and_plain_text_are_not_a_format_failure',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];RejectUnicode58=true;AIText58='READY'
assert(e.Health());assert(LastAIRequest.UserPrompt=='Reply READY.'and LastAIRequest.MaxTokens==64)
assert(not LastAIRequest.JsonSchema and not LastAIRequest.ResponseFormatType and not LastAIRequest.ContextToken)
AIText58='Vamos montar um look emo com camisa preta.'
local r,err=e.Ask(pl,'Faça um look emo com acessórios e calça, por favor!')
assert(r,err);assert(r.answer==AIText58 and r.keyword=='emo'and e.Available)
assert(not LastAIRequest.UserPrompt:find('[\128-\255]'))
assert(LastAISystem:find('ASCII',1,true)and not LastAISystem:find('[\128-\255]'))
assert(e.Ascii('Ação À É Ó ü Ç')=='Acao A E O u C')
return 'minimal English health probe is independent of JSON; accent-free user/instruction transport; valid native plain text remains online with a catalog keyword derived from the style request'
''')
case('native_400_logs_stage_and_does_not_lock_five_minutes',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];local logs={};warn=function(v)logs[#logs+1]=v end
FailAI=true;assert(not e.Health());assert(e.Error=='HTTP 400'and e.Last.stage=='GENERATE')
assert(logs[1]:find('etapa=GENERATE',1,true)and logs[1]:find('HTTP 400 (Bad Request)',1,true))
local r,why=e.Ask(pl,'Ajuda');assert(not r and why:find('pausa'))
FailAI=false;advance(13);assert(e.Health());assert(e.Ask(pl,'Ajuda'))
return 'original native HTTP 400 and stage retained in Output; brief cooldown; recovery probe after 12 seconds instead of a 300-second outage cache'
''')
case('unavailable_storage_allows_only_temporary_free_help_and_blocks_paid_grants',AI+r'''
FailStores=true
local accounts=Modules['09I1_ASSISTANT_ACCOUNTS'];local v=accounts.View(pl.UserId)
assert(v.plan=='Normal'and v.storageAvailable==false and v.temporary and #v.collections==0)
assert(not accounts.Receipt({PlayerId=123,ProductId=3717699454,PurchaseId='offline'},'Pro'))
assert(not accounts.Collection(123,{name='x',body={}},'Favoritos'))
'''+src('09I_ASSISTANT_SERVER')+r'''
flush();local rpc=rep.ACP_AssistantRemotes.Request;local responses={}
rep.ACP_AssistantRemotes.Progress.FireClient=function(_,player,d)if d.kind=='result'or d.kind=='error'then responses[#responses+1]=d end end
advance(.3);local r=rpc.OnServerInvoke(pl,'status',{});assert(r.ok and r.data.available and not r.data.storageAvailable)
advance(.3);r=rpc.OnServerInvoke(pl,'prompt',{plan='Pro'});assert(not r.ok and r.error:find('armazenamento')and not LastPrompt)
for i=1,8 do advance(.3);r=rpc.OnServerInvoke(pl,'ask',{text='Como giro o avatar?',make=false,request='session'..i});assert(r.ok,r.error);flush();assert(responses[#responses].kind=='result'and responses[#responses].data.plan=='Normal')end
advance(.3);r=rpc.OnServerInvoke(pl,'ask',{text='Outro pedido',make=false});assert(not r.ok and r.error:find('oito'))
return 'storage outage is distinguished from native connection: brief free use remains available, eight requests still enforced, no paid entitlement or successful saved-collection claim'
''')
case('on_demand_request_recovers_when_cached_health_is_false',AI+src('09I_ASSISTANT_SERVER')+r'''
flush();local e=Modules['09I2_ASSISTANT_ENGINE'];e.Available=false;e.Checked=os.clock()
advance(.3);local rpc=rep.ACP_AssistantRemotes.Request
local r=rpc.OnServerInvoke(pl,'ask',{text='Ajuda com musica',make=false,request='recover'});assert(r.ok,r.error);flush();assert(e.Available)
return 'a stale unavailable snapshot no longer rejects every request before the native service is tried'
''')
case('server_identity_stamp_handles_replicated_history_but_not_broken_clothes',DATA+r'''
SERVER_SIDE=true;local Load=Modules['08B4_AVATAR_LOAD'];local Verify=Modules['08B3_AVATAR_VERIFY']
Details[72779265740934]={Id=72779265740934,AssetType='ShirtAccessory'}
assert(S.Try(Details[72779265740934]));local desc=A.Unpack(S.Current)
local layered={};for _,v in ipairs(desc:GetAccessories(true))do if v.IsLayered then layered[#layered+1]=v end end;desc:SetAccessories(layered,true)
local m=assert(Load.Create(desc,'R15'));m:SetAttribute('ACP_AvatarEpoch',10);m:SetAttribute('ACP_AvatarTrace','server-10')
local hum=m.Humanoid;local rows=hum:FindFirstChildOfClass('HumanoidDescription'):GetChildren();local shirt
for _,row in ipairs(rows)do if row:IsA('AccessoryDescription')then
 local acc=row:GetAppliedInstance();assert(acc:GetAttribute('ACP_VerifiedAssetId')==row.AssetId)
 if row.AccessoryType.Name=='Shirt'then shirt=acc end
 function row:GetAppliedInstance()error('Instance not found. ApplyDescription was called on server')end
end end
assert(shirt);hum.applied:SetAccessories({},true);SERVER_SIDE=false
local good,why,detail=Load.Check(m,desc,'R15');assert(good,tostring(why)..' / '..tostring(detail and detail.check))
shirt.Handle:FindFirstChildOfClass('WrapLayer').Enabled=false
local good,why,detail=Load.Check(m,desc,'R15');assert(not good and detail.check=='WRAP_ENABLED')
shirt.Handle:FindFirstChildOfClass('WrapLayer').Enabled=true;shirt:SetAttribute('ACP_VerifiedAssetId',99999999)
assert(not Load.Check(m,desc,'R15'),'wrong stamped ID must fail')
return 'the exact server-confirmed accessory can be verified without local application history; disabled wrapping and wrong asset identity still fail'
''')
case('trying_never_adds_to_cart_and_collapsed_preview_frees_list',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C2_SHOP_CATALOG')+r'''
local cart=Modules['09C4_OUTFIT_LIBRARY'];cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()return{items={}}end})
local cat=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end})
Details[81001]={Id=81001,Name='Hat',AssetType='Hat',ItemType='Asset',Price=3}
cat.ShowItem(Details[81001]);U.Try.Activated:Fire();assert(cart.Count()==0)
cat.ShowItem(Details[81001]);U.Favorite.Activated:Fire();assert(cart.Count()==1)
SCREEN_W,SCREEN_H=851,392;U.Layout();local width=U.CartList.AbsoluteSize.X
assert(not U.CartPreviewStage.Visible);U.CartPreviewToggle.Activated:Fire();assert(U.CartPreviewStage.Visible and U.CartList.AbsoluteSize.X<width)
U.CartPreviewToggle.Activated:Fire();assert(not U.CartPreviewStage.Visible and U.CartList.AbsoluteSize.X==width)
return 'trying is independent of the explicit cart action; one tap expands/collapses the cart preview without changing the avatar or selected items'
''')
case('halloween_search_keeps_real_catalog_filters_and_free_prices',DATA+r'''
assert(A.Groups[1].name=='TODOS');local index
for i,g in ipairs(A.Groups)do if g.name=='HALLOWEEN'then index=i end end;assert(index)
local p=A.BuildParams(index,1,'cat',1);assert(p.SearchKeyword=='halloween cat')
local p,sub,filter=A.BuildParams(index,5,'',1);assert(p.MinPrice==0 and p.MaxPrice==0 and p.SearchKeyword=='halloween')
assert(A.PostFilter({Price=0},sub,filter)and not A.PostFilter({Price=15},sub,filter)and not A.PostFilter({},sub,filter))
return 'seasonal category queries Roblox catalog instead of fabricated IDs; original category indices stay compatible; only confirmed zero prices pass the free filter'
''')
case('music_actual_controller_load_seek_volume_queue_and_saved_search',THEME+module('07M1_MUSIC_UI')+r'''
local rpc=Instance.new('RemoteFunction');rpc.Name='ACP_MusicRequest';rpc.Parent=rep
function rpc:InvokeServer(a,d)
 if a=='load'then return{ok=true,data={volume=.4,last=0,saved={}}}elseif a=='audio'then return{ok=true,data={id=d.id,name='Minha musica '..d.id}}end
 return {ok=true,data=true}
end
function Services.ContentProvider:PreloadAsync(assets,callback)for _,o in ipairs(assets)do o.IsLoaded=true;if callback then callback(o.SoundId,Enum.AssetFetchStatus.Success)end end end
local ui;local build=Modules['07M1_MUSIC_UI'].Build;Modules['07M1_MUSIC_UI'].Build=function(...)ui=build(...);return ui end
'''+src('07M_MUSIC_CLIENT')+r'''
flush();pg:SetAttribute('ACP_OpenMusicNonce',1);ui.ID.Text='12345';ui.Load.Activated:Fire();flush()
local sound=Services.SoundService:FindFirstChild('ACP_PersonalMusic');assert(sound.IsPlaying and sound.Volume==.4 and ui.Seek.Enabled)
ui.OnSeek(.5);assert(sound.TimePosition==60);ui.OnVolume(.65);assert(sound.Volume==.65 and ui.VolumeSlider.Label.Text=='Volume 65%')
ui.Enqueue.Activated:Fire();ui.Keep.Activated:Fire();ui.ID.Text='54321';ui.Load.Activated:Fire();flush();ui.Enqueue.Activated:Fire()
ui.Page='Fila';ui.OnLibrary();assert(#ui.List:GetChildren()==3)
ui.Next.Activated:Fire();flush();assert(sound.SoundId=='rbxassetid://54321')
ui.Previous.Activated:Fire();flush();assert(sound.SoundId=='rbxassetid://12345')
ui.Page='Salvos';ui.Filter.Text='54321';ui.Filter:GetPropertyChangedSignal('Text'):Fire();assert(#ui.List:GetChildren()==2)
ui.Filter.Text='Minha musica';ui.Filter:GetPropertyChangedSignal('Text'):Fire();assert(#ui.List:GetChildren()==2)
ui.Mute.Activated:Fire();assert(sound.Volume==0);ui.Mute.Activated:Fire();assert(sound.Volume==.65)
sound:Pause();sound.TimePosition=sound.TimeLength;ui.Play.Activated:Fire();assert(sound.IsPlaying and sound.TimePosition==0)
ui.Minimize.Activated:Fire();assert(ui.Mini and not ui.Content.Visible);ui.Close.Activated:Fire();assert(not ui.Root.Visible)
return 'actual music LocalScript checks and loads IDs, seeks, changes/mutes volume, saves/searches names, queues and skips tracks, and minimizes without a second sound'
''')
case('photo_motion_moves_camera_or_copy_while_all_set_blocks_stay_fixed',PHOTO+module('07P4_STUDIO_UI')+r'''
installModule('07P1_CAPTURE_ENGINE','return {TakePhoto=function()return true end,SaveLast=function()return true end,ShareLast=function()return true end}')
local ui;local build=Modules['07P4_STUDIO_UI'].Build;Modules['07P4_STUDIO_UI'].Build=function(...)ui=build(...);return ui end
'''+src('07P_PHOTO_MODE')+r'''
flush();pg:SetAttribute('ACP_OpenPhotoNonce',1);flush();local st=Modules['07P2_STUDIO_AVATAR'];assert(st.Model)
ui.Buttons.Animations.Activated:Fire();flush()
for _,o in ipairs(ui.Content:GetChildren())do if o:IsA('TextButton')and o.Text=='Movimentos para vídeo'then o.Activated:Fire();break end end
local scenery={};for _,o in ipairs(st.Scene.Model:GetChildren())do if o:IsA('BasePart')then scenery[o]=o.CFrame end end
for _,kind in ipairs({'Orbitar câmera','Girar avatar','Zoom suave','Travelling lateral'})do
 local before=st.Camera.CFrame;local yaw=st.AvatarYaw
 for _,o in ipairs(ui.Content:GetChildren())do if o:IsA('TextButton')and o.Text==kind then o.Activated:Fire();break end end
 Services.RunService.RenderStepped:Fire(.4)
 if kind=='Girar avatar'then assert(st.AvatarYaw~=yaw)else assert(st.Camera.CFrame~=before)end
 for o,cf in pairs(scenery)do assert(o.CFrame==cf)end
end
ui.Close.Activated:Fire();assert(not st.Scene and not st.Folder)
return 'real Photo Mode movement actions affect only camera/copy, preserve every fixed scene block and clean up on exit'
''')
case('settings_pages_fit_safe_mobile_rectangles_and_have_accessible_exit',THEME+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')+r'''
local gui=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='ACP_SettingsTest',ScreenInsets=Enum.ScreenInsets.None},pg)
local root=Instance.new('Frame');root.Size=UDim2.fromScale(1,1);root.Parent=gui
local u=Modules['07G1_HUB_SETTINGS'].Build(root,pg,function()end,function()end);u.Panel.Visible=true
for _,size in ipairs({{320,568},{568,320},{851,392},{390,844}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=0,0,0
 pg:SetAttribute('ACP_HalloweenEnabled',true);pg:SetAttribute('ACP_ReducedMotion',false);u.Layout()
 inside(u.Panel,root);inside(u.Close,u.Panel);assert(u.Close.AbsoluteSize.X>=44 and u.Close.AbsoluteSize.Y>=44)
 for _,o in ipairs(u.Body:GetChildren())do if o:IsA('TextButton')then inside(o,u.Body);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44)end end
 local button=named(u.Body,'Interface');button.Activated:Fire();u.Layout();assert(u.Back.Visible and u.Back.AbsoluteSize.Y==44)
 local theme=named(u.Body,'Theme');theme.Activated:Fire();assert(pg:GetAttribute('ACP_HalloweenEnabled')==false)
 named(u.Body,'Motion').Activated:Fire();assert(pg:GetAttribute('ACP_ReducedMotion')==true)
 u.Back.Activated:Fire();assert(u.Page=='Home')
end
return 'settings uses the full safe rectangle; back/X/categories preserve 44px targets; appearance controls affect theme and reduced motion locally'
''')
HERE.joinpath('changes_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
