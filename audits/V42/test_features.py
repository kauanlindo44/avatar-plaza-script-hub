"""V42 functional doubles: layout, poses, photo lifecycle and cross-server rooms.
No real Roblox rendering, network teleports, asset loading or native captures.
"""
from pathlib import Path
import json
from lua_runner import Lua
ROOT=Path(__file__).resolve().parents[2]
MOCK=Path(__file__).with_name('roblox_mock.lua').read_text()
def src(n,v='V42'):return (ROOT/'scripts'/v/(n+'.lua')).read_text()
def q(s):return '[====['+s+']====]'
def module(n,v='V42'):return "installModule('"+n+"',"+q(src(n,v))+")\n"
THEME=module('07UI_DESIGN_SYSTEM','V41')+module('07UI_SCREEN_BOUNDS')
UI=THEME+module('09A1_SHOP_LAYOUT')+"U=loadModule("+q(src('09A_SHOP_UI'))+",'Shop').Build(pl);flush()\n"
DATA=module('08B_AVATAR_DATA','V41')+"A=Modules['08B_AVATAR_DATA'];HUM=setupAvatar()\n"+module('08D_SKIN_STATE','V41')+"S=Modules['08D_SKIN_STATE'];S.Init()\n"
results=[]
def case(name,code):
 l=Lua()
 try:
  detail=l.run(MOCK+code,name);results.append(dict(case=name,result='pass',detail=detail));print('PASS',name,detail or'')
 except Exception:
  Path(__file__).with_name('failed_case.lua').write_text(MOCK+code);raise
 finally:l.close()
case('actions_below_preview_and_body_apply',UI+DATA+"setupServer("+q(src('09B_SHOP_SERVER'))+")\n"+r'''
for _,v in ipairs({{360,640},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H=v[1],v[2];U.SetWide(false);flush()
 assert(U.EditorFooter.AbsolutePosition.Y>=U.Viewport.AbsolutePosition.Y+U.Viewport.AbsoluteSize.Y)
 assert(U.BodyToggle.Parent==U.EditorFooter and U.ItemStrip.Parent==U.EditorFooter)
end
assert(S.SetScale('HeightScale',.97)and S.SetScale('WidthScale',.79));HUM.AutomaticScalingEnabled=false
local r=RPC:InvokeServer('Apply',{body=S.Current,base=S.Base,rig=S.Rig,replace=S.Replace})
assert(r.ok,r.error);assert(HUM.applied.HeightScale==.97 and HUM.applied.WidthScale==.79 and HUM.AutomaticScalingEnabled)
assert(HUM.applied.Shirt==11 and HUM.applied.Pants==12 and #HUM.applied.accessories==3)
return 'all preview actions below avatar; actual server scales change without deleting clothing and accessories'
''')
case('saved_looks_5_by_4_and_mobile_detail',UI+DATA+r'''
local saved={};for i=1,20 do saved[i]={id=tostring(i),name='Look '..i,rig='R15',body=A.Copy(S.Current)}end
local ctl=loadModule('LOOKS','Looks').Init({U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function(a)if a=='List'then return{skins=saved,persistent=true}end end})
SCREEN_W,SCREEN_H,CORE_TOP=1920,1080,58;U.SetWide(true);U.Root.Visible=true;U.LooksArea.Visible=true;ctl.Saved();flush()
local layout=U.SavedGrid:FindFirstChildOfClass('UIGridLayout');assert(layout.FillDirectionMaxCells==5)
assert(math.floor((U.SavedGrid.AbsoluteSize.Y+6)/(layout.CellSize.Y.Offset+6))==4);assert(#U.SavedGrid:GetChildren()==21)
SCREEN_W,SCREEN_H=360,640;U.Layout();flush();U.SavedPreviewClose.Activated:Fire();assert(not U.SavedPreviewPanel.Visible)
assert(U.SavedGalleryPanel.AbsoluteSize.X==U.LooksArea.AbsoluteSize.X)
U.SavedPreviewToggle.Activated:Fire();assert(U.SavedPreviewPanel.Visible);inside(U.SavedPreviewClose,U.Root)
U.SavedPreviewClose.Activated:Fire();assert(not U.SavedPreviewPanel.Visible)
return '20 clear cards in 5x4 at 1080p; full-width phone gallery and closable selected look'
'''.replace("'LOOKS'",q(src('09C1_SHOP_LOOKS'))))
case('ugc_full_page_price_and_stale_search',UI+DATA+r'''
local pages={IsFinished=true,GetCurrentPage=function()return{{Id=70,Name='UGC real',ItemType='Asset',Price=1234}}end}
function Services.AvatarEditorService:SearchCatalogAsync(params)assert(params.CategoryFilter==Enum.CatalogCategoryFilter.CommunityCreations);return pages end
local ctl=loadModule('STORES','Stores').Init({U=U,A=A,toast=function()end,showItem=function()end})
SCREEN_W,SCREEN_H,CORE_TOP=1920,1080,58;U.SetWide(true);U.Root.Visible=true;U.StoresArea.Visible=true;ctl.Search();flush()
local grid=U.StoreGrid:FindFirstChildOfClass('UIGridLayout');assert(grid.FillDirectionMaxCells==5 and math.floor((U.StoreGrid.AbsoluteSize.Y+6)/(grid.CellSize.Y.Offset+6))==6)
local price=false;for _,c in ipairs(U.StoreGrid:GetChildren())do for _,t in ipairs(c:GetChildren())do if t.Text=='1.234 Robux'then price=t.TextSize==15 end end end;assert(price)
ctl.Search();U.StoresArea.Visible=false;flush();assert(guiCards(U.StoreGrid)==0,'late search populated closed page')
return 'full-screen UGC uses up to 5x6, grouped explicit prices and stale-response cancellation'
'''.replace("'STORES'",q(src('09C5_UGC_STORES'))))
GAMES=THEME+r'''
local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.None;gui.Name='GameClubGui';gui.Parent=pg
L=loadModule('LOBBY','Lobby').Build(gui);B=loadModule('BOARD','Board').Build(gui);flush()
'''
case('games_raw_viewport_safe_controls_and_top_categories',GAMES.replace("'LOBBY'",q(src('07H1_GAME_LOBBY'))).replace("'BOARD'",q(src('07H2_GAME_BOARD')))+r'''
for _,v in ipairs({{320,568,0,0},{360,640,0,0},{844,390,44,44},{1920,1080,0,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT=v[1],v[2],v[3],v[4];CORE_TOP=58;CORE_BOTTOM=0
 L.Layout();B.Layout();flush();assert(L.Root.AbsoluteSize.Y==SCREEN_H and B.Root.AbsoluteSize.Y==SCREEN_H)
 local y;for _,b in pairs(L.GameButtons)do inside(b,L.Root);if y then assert(b.AbsolutePosition.Y==y)else y=b.AbsolutePosition.Y end end
 for _,b in pairs(L.ModeButtons)do inside(b,L.Root)end
 for _,o in ipairs({L.Close,L.Status,B.Grid,B.Side,B.Minimize,B.Title,B.Message})do inside(o,gui)end
 assert(not intersects(B.Grid,B.Side));assert(not intersects(B.Grid,B.Message))
end
L.SetWaiting('A7KD',false,true);assert(L.WaitDesc.Text:find('virá para este servidor'))
L.SetTransfer('A7KD');assert(L.WaitTitle.Text=='Indo até seu amigo');L.Reset()
return 'four raw viewports incl. notch; all game categories horizontal at top, board and controls fit'
''')
PHOTO=DATA+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"
case('pose_confirm_cancel_clamp_and_cleanup',PHOTO+r'''
assert(Studio.Enter());local P=Studio.Pose;local joint=Studio.Model.Torso:FindFirstChild('RightShoulder')
local untouched=Studio.Model.Torso.LeftShoulder;P.Begin();assert(P.Set('RightShoulder',1,45));assert(P.Set('RightShoulder',3,500));assert(P.Values.RightShoulder[3]==120)
Services.RunService.PreSimulation:Fire();assert(joint.Transform.UpVector.Y~=1 and untouched.Transform.UpVector.Y==1)
P.Confirm();P.Begin();P.Set('RightShoulder',1,80);P.Cancel();assert(P.Values.RightShoulder[1]==45)
P.Begin();P.Reset();P.Cancel();assert(P.Values.RightShoulder[3]==120);P.Begin();P.Reset('RightShoulder');P.Confirm();assert(P.Values.RightShoulder[1]==0)
Studio.Exit();assert(not Studio.Pose and not Studio.Model)
return 'joint edits affect one limb, clamp, stay after confirm, undo on cancel, restore on exit'
''')
case('photo_five_sets_environment_camera_restore',PHOTO+r'''
local effect=Instance.new('ColorCorrectionEffect');effect.Enabled=true;effect.Parent=Services.Lighting
local atm=Instance.new('Atmosphere');atm.Density=.14;atm.Haze=.38;atm.Glare=.01;atm.Parent=Services.Lighting
local cam=workspace.CurrentCamera;local previous=cam.CFrame;local clock=Services.Lighting.ClockTime
assert(Studio.Enter());assert(#Modules['07P0_STUDIO_PRESETS'].Backgrounds==5 and not effect.Enabled and atm.Density==0)
for _,p in ipairs(Modules['07P0_STUDIO_PRESETS'].Backgrounds)do assert(Studio.BuildSet(p.id));assert(Studio.Background==p.id)end
for _,yaw in ipairs({0,90,180,270})do Studio.SetYaw(yaw);local dir=cam.CFrame.LookVector;local from=Studio.Backdrop.Position-cam.CFrame.Position
 assert(from.X*dir.X+from.Y*dir.Y+from.Z*dir.Z>0,'backdrop not behind model')
end
assert(Studio.SetEnvironment('Exposure',20)and Studio.Environment.Exposure==.65);assert(Studio.SetEnvironment('Brightness',.2)and Services.Lighting.Brightness==1)
Studio.SetMargins(6,100,350,60);assert(cam.CFrame~=previous);Studio.Exit()
assert(cam.CFrame==previous and cam.CameraType==Enum.CameraType.Custom and cam.FieldOfView==70)
assert(Services.Lighting.ClockTime==clock and Services.Lighting.Brightness==2.35 and effect.Enabled and atm.Density==.14)
assert(not workspace:FindFirstChild('ACP_PhotoPreview_123'))
return 'five real sets, four angles unobstructed, bounded environment edits and exact local state restoration'
''')
case('photo_ui_mobile_fit_pose_and_failed_capture',THEME+PHOTO+module('07P4_STUDIO_UI')+r'''
Modules['07P1_CAPTURE_ENGINE']={TakePhoto=function()return false,'Captura indisponível'end,SaveLast=function()return false,'Sem foto'end,ShareLast=function()return false,'Sem foto'end}
local mod=Instance.new('ModuleScript');mod.Name='07P1_CAPTURE_ENGINE';mod.Parent=rep
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Enabled=true;hud.Parent=pg
local hidden=Instance.new('ScreenGui');hidden.Name='AlreadyHidden';hidden.Enabled=false;hidden.Parent=pg
''' + src('07P_PHOTO_MODE')+r'''
flush();pg:SetAttribute('ACP_OpenPhotoNonce',1);flush();local gui=pg.ACP_PhotoMode;local root=gui.PhotoStudio
assert(root.Visible and Studio.Model and not hud.Enabled and not hidden.Enabled)
local tools=named(root,'PhotoTools');local nav=root:FindFirstChildOfClass('ScrollingFrame')
for _,v in ipairs({{320,568},{360,640},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;gui:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 inside(tools,root);inside(nav,root);inside(named(root,'ClosePhoto'),root)
end
local function clickText(t)local o;for _,c in ipairs(root:GetDescendants())do if c:IsA('GuiButton')and c.Text==t then o=c;break end end;assert(o,t);o.Activated:Fire();flush()end
clickText('Pose');assert(Studio.Pose.Editing and tools.Visible);clickText('Confirmar');assert(not Studio.Pose.Editing and not tools.Visible)
clickText('Foto');clickText('Tirar foto');assert(gui.Enabled and not capturing,'failed capture did not restore UI')
clickText('Ocultar');assert(named(root,'ClosePhoto').Visible==false);clickText('Mostrar UI');assert(named(root,'ClosePhoto').Visible)
named(root,'ClosePhoto').Activated:Fire();assert(not root.Visible and hud.Enabled and not hidden.Enabled and not Studio.Model)
return 'phone/desktop controls fit; pose confirmation, UI hide/restore, failed capture and HUD state preserved'
''')

case('capture_timeout_rejects_stale_callbacks',THEME+PHOTO+module('07P4_STUDIO_UI')+r"""
Callbacks={};Modules['07P1_CAPTURE_ENGINE']={TakePhoto=function(_,cb)if THROW_CAPTURE then error('device failure')end;Callbacks[#Callbacks+1]=cb;return true end}
local mod=Instance.new('ModuleScript');mod.Name='07P1_CAPTURE_ENGINE';mod.Parent=rep
"""+src('07P_PHOTO_MODE')+r"""
flush();pg:SetAttribute('ACP_OpenPhotoNonce',1);flush();local gui=pg.ACP_PhotoMode;local root=gui.PhotoStudio
local function clickText(t)for _,o in ipairs(root:GetDescendants())do if o:IsA('GuiButton')and o.Text==t then o.Activated:Fire();flush();return end end;error(t)end
local function shoot()clickText('Foto');clickText('Tirar foto');assert(not gui.Enabled)end
shoot();advance(12.1);assert(gui.Enabled);shoot();Callbacks[1](true);assert(not gui.Enabled,'old callback interrupted a new photo')
Callbacks[2](true);assert(gui.Enabled);THROW_CAPTURE=true;clickText('Foto');clickText('Tirar foto');assert(gui.Enabled,'thrown capture stranded hidden UI')
THROW_CAPTURE=false;shoot();named(root,'ClosePhoto').Activated:Fire();Callbacks[3](true);assert(not root.Visible and not Studio.Model,'late capture revived closed studio')
return 'timeout, overlapping stale completion, thrown service error and closed studio leave UI recoverable'
""")

# Directory service double models UpdateAsync (including nil cancellation), ownership and TTL.
CROSS=r'''
STUDIO=false;game.PlaceId=900;game.GameId=500;game.JobId='host-job';game.PrivateServerId=''
Entries={};GUID=0
function Services.HttpService:GenerateGUID()GUID=GUID+1;return 'guid-'..GUID end
Map={}
function Map:UpdateAsync(k,fn,ttl)
 local old=Entries[k];if old and old.ttl<=TEST_TIME then Entries[k]=nil;old=nil end
 local changed=fn(old and old.value or nil);if not changed then return nil end
 Entries[k]={value=changed,ttl=TEST_TIME+ttl};return changed
end
function Map:GetAsync(k)local r=Entries[k];if not r or r.ttl<=TEST_TIME then return end;return r.value end
Services.MemoryStoreService={GetHashMap=function()return Map end}
Services.TeleportService={TeleportInitFailed=Signal(),TeleportAsync=function(_,place,players,options)
 if FAIL_TRAVEL then error('full server')end
 LastTravel={place=place,players=players,job=options.ServerInstanceId,data=options.data}
end}
local old=Instance.new
Instance.new=function(c)local o=old(c);if c=='TeleportOptions'then function o:SetTeleportData(d)self.data=d end end;return o end
Directory=loadModule('CROSS_SOURCE','Directory')
'''.replace("'CROSS_SOURCE'",q(src('07H3_CROSS_SERVER_ROOMS')))
case('cross_server_claim_route_arrival_failures',CROSS+r'''
local host={UserId=10};local room={owner=host,game='Xadrez'};assert(Directory.Reserve(room,function()return false end));assert(room.shared)
local guest={UserId=20,GetJoinData=function(self)return self.join end};local other={UserId=30}
game.JobId='guest-job';local r,e=Directory.Route(guest,room.code);assert(r and r.teleporting,e)
assert(LastTravel.place==900 and LastTravel.job=='host-job' and LastTravel.players[1]==guest)
assert(not Directory.Claim(room.code,other),'double booking guest slot')
game.JobId='host-job';guest.join={SourceGameId=500,TeleportData=LastTravel.data};assert(Directory.Arrival(guest,{[room.code]=room})==room)
guest.join.SourceGameId=999;assert(not Directory.Arrival(guest,{[room.code]=room}));guest.join.SourceGameId=500
Directory.Cancel(guest);assert(Directory.Claim(room.code,other));Directory.Release(other,room.code,room.token)
game.JobId='guest-job';FAIL_TRAVEL=true;assert(not Directory.Route(guest,room.code));assert(Entries[room.code].value.claim==0)
FAIL_TRAVEL=false;local push={FireClient=function(_,p,a)assert(p==guest and a=='travelFailed');TRAVEL_FAILED=true end};Directory.Bind(push);assert(Directory.Route(guest,room.code));Services.TeleportService.TeleportInitFailed:Fire(guest);assert(TRAVEL_FAILED and Entries[room.code].value.claim==0)
game.JobId='host-job';Directory.Close(room);assert(not Directory.Claim(room.code,guest));STUDIO=true;assert(not Directory.Route(guest,'ABCD'))
return 'global code, atomic guest claim, target host teleport, server-checked arrival and failure rollback'
''')
case('directory_expiry_collision_and_host_lease',CROSS+r'''
local first={owner={UserId=1},game='Damas'};assert(Directory.Reserve(first,function()return false end));local other={owner={UserId=2},game='Batata'}
local originalRandom=math.random;math.random=function()return 1 end
Entries.AAAA={value={lease=os.time()+90},ttl=90};assert(not Directory.Reserve(other,function()return false end),'collision overwritten')
math.random=originalRandom;assert(Directory.Refresh(first));advance(40);assert(Directory.Claim(first.code,{UserId=5}));for _=1,4 do advance(30);assert(Directory.Refresh(first))end;advance(1);assert(Directory.Claim(first.code,{UserId=6}),'stale claim blocked future guests')
advance(610);assert(not Directory.Claim(first.code,{UserId=7}),'expired room still accepts guests')
return 'global collisions rejected, lease renewed, guest reservation expires and old room cannot be joined'
''')
Path(__file__).with_name('feature_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print('Validated',len(results),'feature cases')
