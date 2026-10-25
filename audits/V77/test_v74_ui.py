from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}}"
LIBRARY=THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')
HUD=THEME+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G7_ADVENTURE_WORLD')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
CHAOS=THEME+module('BC_Config')+module('BC_HUD')+module('BC_VisualEffects')
case('our_game_library_owns_four_cards_and_keeps_existing_game_options',LIBRARY+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui);flush();u.Root.Visible=true;u.OpenLibrary()
assert(u.Library.Root.Visible and not u.Hero.Visible and #u.Library.cards==4)
local entered=0;u.OnChaos=function()entered=entered+1 end;named(u.Library.Root,'Library_Botão do Caos').Activated:Fire();assert(entered==1)
for _,kind in ipairs({'Truco','Xadrez','Damas'})do
 local b=named(u.Library.Root,'Library_'..kind);assert(b:GetAttribute('OurGame'));b.Activated:Fire();assert(u.Selected==kind and not u.Library.Root.Visible and u.Hero.Visible)
 u.PlayButtons[kind].Practice.Activated:Fire();assert(u.Options.Visible and u.Mode=='Practice'and u.Bot.Visible)
 u.OptionsClose.Activated:Fire();u.Library.Back.Activated:Fire();assert(u.Library.Root.Visible)
end
return 'four clearly identified games; each existing card still opens its original modes/bots, while Chaos calls a separate integration callback and Back restores the library'
''')
case('desktop_game_selection_keeps_library_beside_the_original_actions',LIBRARY+r'''
SCREEN_W,SCREEN_H,CORE_TOP=1280,720,58
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui);flush()
named(u.Library.Root,'Library_Xadrez').Activated:Fire();u.Layout();assert(u.Library.Sidebar.Visible and not u.Library.Root.Visible)
inside(u.Library.Sidebar,u.Root);inside(u.Hero,u.Root);assert(not intersects(u.Library.Sidebar,u.Hero))
for _,b in ipairs(u.Library.sideButtons)do inside(b.root,u.Library.Sidebar);assert(b.root.AbsoluteSize.Y>=44)end
u.PlayButtons.Xadrez.Create.Activated:Fire();assert(u.Options.Visible and not u.Library.Sidebar.Visible)
return 'desktop keeps our four games in a separate selector beside the original play actions; setup retains its existing independent layout'
''')
case('library_and_chaos_touch_controls_fit_safe_phone_and_desktop_bounds',LIBRARY+module('BC_Config')+module('BC_HUD')+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui)
local bcGui=d.New('ScreenGui',{Name='BC_GameGui'},pg);local bc=Modules.BC_HUD.Build(bcGui);flush()
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 u.Layout();bc.Set({phase='QUEUE',queue=1});bc.Layout();inside(u.Library.Root,u.Root);inside(u.Close,u.Root)
 for _,c in ipairs(u.Library.cards)do assert(c.button.AbsoluteSize.X>=44 and c.button.AbsoluteSize.Y>=44);inside(c.art,c.button);inside(c.title,c.button);inside(c.meta,c.button)end
 for _,b in ipairs({bc.Join,bc.Training,bc.Back,bc.LeaveQueue})do inside(b,bc.Panel);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 inside(bc.Close,bc.Queue);assert(not intersects(bc.Join,bc.Training)and not intersects(bc.Training,bc.Back))
 bc.Set({phase='ACTIVE',matchId='r',alive=true,remaining=150,score=2,aliveCount=8,health=100,lastEffect='Supervelocidade',effects={},weapon={name='Blaster de energia',ammo=3,remaining=12}})
 for _,b in ipairs({bc.Exit,bc.Reduce,bc.Fire})do inside(b,bc.Hud);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 assert(not intersects(bc.Top,bc.Exit)and not intersects(bc.Health,bc.Top)and not intersects(bc.Fire,bc.Reduce))
 bc.Confirm.Visible=true;bc.Layout();inside(bc.Confirm,bc.Hud);inside(bc.Yes,bc.Confirm);inside(bc.No,bc.Confirm)
 assert(bc.Yes.AbsoluteSize.X>=44 and bc.Yes.AbsoluteSize.Y>=44 and not intersects(bc.Yes,bc.No))
end
return 'seven safe geometries preserve queue, exit, reduced-effects, firing and confirmation controls; scalable library cards retain readable titles/artwork and scroll vertically when needed'
''')
case('hud_primary_labels_and_every_avatar_shortcut_are_accessible',HUD+src('07G_HUB_UI')+r'''
flush();local hud=pg.LimitedMarketHUD;local launch=pg.AvatarShopLauncherGui;local root=named(hud,'HudRoot');local sheet=named(hud,'AvatarShortcuts')
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local prim={named(launch,'TopCatalog'),named(hud,'Games'),named(hud,'TopStores')}
 for _,b in ipairs(prim)do inside(b,hud);assert(b.AbsoluteSize.Y>=44 and #b.Text>0)end
 assert(not intersects(prim[1],prim[2])and not intersects(prim[2],prim[3]))
 for _,name in ipairs({'Assistant','Community','Looks','AvatarTools','TopMusic','Cart','Photo','Cfg'})do local b=named(hud,name);inside(b,hud);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44)end
 named(hud,'AvatarTools').Activated:Fire();assert(sheet.Visible);inside(sheet,hud)
 for _,name in ipairs({'Avatar','Loader','Emotes','CurrentlyWearing','NewAvatar','SaveRoblox','RestoreAvatar','Commands','Plus'})do local b=named(sheet,name);assert(b and b.Active and b.Visible);assert(b.Parent==named(sheet,'AvatarShortcutList')and named(sheet,'AvatarShortcutList').CanvasSize.Y.Offset>=b.Position.Y.Offset+b.Size.Y.Offset);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,'small shortcut '..SCREEN_W..' '..b.AbsoluteSize.Y)end
 named(sheet,'CloseAvatarShortcuts').Activated:Fire();assert(not sheet.Visible)
end
return 'primary actions use visible labels and separate touch targets; all existing avatar/load/emote/save/reset/Plus actions remain available through the identified Avatar menu'
''')
CLIENT=CHAOS+DATA+r'''
local bcRem=rep.PracaKit.Remotes;local request=Instance.new('RemoteFunction');request.Name='BC_Request';request.Parent=bcRem
local push=Instance.new('RemoteEvent');push.Name='BC_Push';push.Parent=bcRem
local fire=Instance.new('RemoteEvent');fire.Name='BC_Fire';fire.Parent=bcRem
local calls={};local snap={phase='QUEUE',queue=0};function request:InvokeServer(a)calls[#calls+1]=a;return{ok=true,data=a=='status'and snap or nil}end
local touch=Instance.new('ScreenGui');touch.Name='TouchGui';touch.Parent=pg;local other=Instance.new('ScreenGui');other.Name='UnrelatedEditorGui';other.Parent=pg
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Parent=pg
local previous=workspace.CurrentCamera.CameraSubject;script=Instance.new('LocalScript');script.Name='BC_Client';script.Parent=rep
'''
case('actual_chaos_client_keeps_touch_controls_and_restores_catalog_on_exit',CLIENT+src('BC_Client')+r'''
flush();pg:SetAttribute('ACP_OpenChaosNonce',1);flush();assert(calls[1]=='status'and not hud.Enabled and touch.Enabled and other.Enabled)
local gui=pg.BC_GameGui;assert(named(gui,'BC_QueueScreen').Visible)
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
push.OnClientEvent:Fire('state',{phase='ACTIVE',matchId='one',alive=true,remaining=100,health=100,score=1,aliveCount=2,roster={},effects={}});flush()
assert(named(gui,'BC_MatchHUD').Visible and touch.Enabled and not hud.Enabled)
named(gui,'BC_Exit').Activated:Fire();assert(named(gui,'BC_ExitConfirmation').Visible)
local confirmation=named(gui,'BC_ExitConfirmation');for _,b in ipairs(confirmation:GetChildren())do if b:IsA('TextButton')and b.Text=='Continuar jogando'then b.Activated:Fire()end end
assert(not confirmation.Visible and calls[#calls]~='leave')
push.OnClientEvent:Fire('return',{});assert(hud.Enabled and touch.Enabled and other.Enabled and not named(gui,'BC_MatchHUD').Visible and workspace.CurrentCamera.CameraType==Enum.CameraType.Custom)
return 'actual new LocalScript opens the queue, hides only our interfaces, keeps native touch/foreign editor UIs enabled, confirms exits and restores the catalog on the server return event'
''')
case('plan_products_diagnose_native_offsale_incomplete_wrong_game_and_official_fallback',THEME+r'''
local p=Modules['09I25_PLAN_PRODUCTS'];local market=Services.MarketplaceService
function market:GetProductInfoAsync(id)assert(id==3717699383);return{PriceInRobux=1}end
function market:GetDeveloperProductsAsync()return{IsFinished=true,GetCurrentPage=function()return{{ProductId=999999,DeveloperProductId=888888,TargetId=3717699383,PriceInRobux=1,Name='Plus'}}end}end
local r=p.Check(3717699383,true);assert(r.ready and r.price==1 and r.method:find('GetDeveloperProductsAsync',1,true))
function market:GetProductInfoAsync()return{IsForSale=false,PriceInRobux=1}end;r=p.Check(3717699383,true);assert(not r.ready and r.stage=='FORA_DE_VENDA')
function market:GetProductInfoAsync()error('HTTP 503 fixture')end
function market:GetDeveloperProductsAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
r=p.Check(3717699383,true);assert(not r.ready and r.stage=='PRODUTO_DE_OUTRA_EXPERIENCIA')
function market:GetDeveloperProductsAsync()error('offline fixture')end;r=p.Check(3717699383,true);assert(not r.ready and r.stage=='CONSULTA_ROBLOX_FALHOU')
assert(not p.Inspect({IsForSale=true,PriceInRobux=0},true));assert(not LastPrompt)
return 'missing sale flag can be verified by the official current-experience product list; explicit false is preserved, no price is invented and wrong-game/service failures have distinct stages'
''')
case('local_chaos_effects_cannot_change_global_lighting_or_leave_objects',CHAOS+DATA+r'''
BCSetup();function Services.Players:GetPlayers()return{pl}end
local ambient=Services.Lighting.Ambient;local gravity=workspace.Gravity
local v=Modules.BC_VisualEffects.New();flush();v.Reconcile({matchId='r',phase='ACTIVE',alive=true,blackout=5,roster={{id=123,alive=true,shield=12}}})
assert(workspace.CurrentCamera:FindFirstChild('BC_LocalBlackout'));assert(Services.Lighting.Ambient==ambient and workspace.Gravity==gravity)
for _,kind in ipairs({'buttonPress','foam','wave','nuclear','heal'})do v.Handle(kind,{at=Vector3.new(0,5,0),user=123})end
assert(#workspace.BC_LocalFX:GetChildren()<=20);v.Clear();assert(#workspace.BC_LocalFX:GetChildren()==0 and not workspace.CurrentCamera:FindFirstChild('BC_LocalBlackout'))
v.Destroy();assert(not workspace:FindFirstChild('BC_LocalFX')and not Services.SoundService:FindFirstChild('BC_LocalAudio'))
return 'real effect functions create only bounded local objects, darkness belongs to the local camera, global environment remains unchanged and clear/destroy remove all owned visual/audio objects'
''')
(HERE/'v74_ui_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
