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
GAME_ENV="""
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep
local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
local event=Instance.new('RemoteEvent');event.Name='HubGameUI';event.Parent=rem;GameEvent=event
local rq=Instance.new('RemoteFunction');rq.Name='GameRoomRequest';rq.Parent=rem
local push=Instance.new('RemoteEvent');push.Name='GameRoomPush';push.Parent=rem;RoomPush=push
requests={};sent={};failure=false
function event:FireServer(...)sent[#sent+1]={...}end
function rq:InvokeServer(action,arg)
 requests[#requests+1]={action,arg}
 if failure then return{ok=false,error='Falha controlada'}end
 if action=='arrival'then return{ok=true}end
 if action=='stats'then return{ok=true,waiting={Xadrez=2,Damas=0,Batata=1}}end
 if action=='cancel'or action=='leave'then push.OnClientEvent:Fire('roomClosed');return{ok=true}end
 if action=='join'then push.OnClientEvent:Fire('matched',{game='Xadrez',tableName='Sala1',code=arg});return{ok=true,code=arg,matched=true,game='Xadrez'}end
 return{ok=true,code='A7KD',game=arg}
end
local old=Instance.new('ScreenGui');old.Name='LimitedMarketHUD';old.Parent=pg
local disabled=Instance.new('ScreenGui');disabled.Name='ACP_TitlesGui';disabled.Enabled=false;disabled.Parent=pg
"""
GAME_ENV=THEME+GAME_ENV
GAME_ENV+="installModule('07A0_CHESS_RULES',"+q(src('07A0_CHESS_RULES','V37'))+")\n"
GAME_ENV+="installModule('07B0_CHECKERS_RULES',"+q(src('07B0_CHECKERS_RULES','V37'))+")\n"
for n,target in [('07H1_GAME_LOBBY','GL'),('07H2_GAME_BOARD','GB')]:
 GAME_ENV+="local mod=installModule('"+n+"',"+q(src(n))+");local build=mod.Build;mod.Build=function(g) "+target+"=build(g);return "+target+" end\n"
GAME_ENV+=src('07H_GAME_UI')+'\n'
case('game_controller_room_contract_and_failures',GAME_ENV+r"""
pg:SetAttribute('ACP_OpenGamesNonce',1);flush();assert(GL.Root.Visible and not pg.LimitedMarketHUD.Enabled)
local n=#requests;GL.Code.Text='bad';GL.Join.Activated:Fire();assert(#requests==n)
GL.ModeButtons.Friends.Activated:Fire();GL.Create.Activated:Fire();assert(GL.WaitingState and GL.CodeDisplay.Text=='A7KD')
assert(requests[#requests][1]=='create'and requests[#requests][2]=='Xadrez')
GL.Quick.Activated:Fire();assert(requests[#requests][1]=='create')
failure=true;GL.Cancel.Activated:Fire();assert(GL.WaitingState and GL.Status.Text=='Falha controlada');failure=false
GL.Cancel.Activated:Fire();assert(not GL.WaitingState and GL.Root.Visible and not pg.LimitedMarketHUD.Enabled);flush()
GL.Code.Text=' a7 kd ';GL.Join.Activated:Fire();assert(requests[#requests][1]=='join'and requests[#requests][2]=='A7KD')
assert(not GL.Root.Visible)
local board=Modules['07A0_CHESS_RULES'].New().board
GameEvent.OnClientEvent:Fire('boardOpen',{game='Xadrez',tableName='Sala1',side='B',board=board,turn='W'})
assert(GB.Root.Visible and GB.Grid.Visible and GB.Claim.Visible)
GameEvent.OnClientEvent:Fire('boardState',{tableName='Sala1',board=board,turn='B',whiteTime=600,blackTime=421,message='Sua vez',hints={{r=2,c=3}}})
assert(GB.WhiteClock.Text=='10:00'and GB.BlackClock.Text=='7:01'and GB.Turn.Text=='SUA VEZ')
GB.Cells[8][8].Activated:Fire();assert(sent[#sent][1]=='boardTap'and sent[#sent][3]==1 and sent[#sent][4]==1)
GB.Minimize.Activated:Fire();assert(GB.Mini.Visible and pg.LimitedMarketHUD.Enabled and not pg.ACP_TitlesGui.Enabled)
GB.Mini.Activated:Fire();assert(GB.Root.Visible and not pg.LimitedMarketHUD.Enabled)
GB.Resign.Activated:Fire();GB.ConfirmYes.Activated:Fire();assert(sent[#sent][1]=='resignGame')
GameEvent.OnClientEvent:Fire('boardClose',{tableName='Sala1'});assert(not GB.Root.Visible and pg.LimitedMarketHUD.Enabled)
pg:SetAttribute('ACP_OpenGamesNonce',2);flush();GL.Close.Activated:Fire();assert(pg.LimitedMarketHUD.Enabled and not pg.ACP_TitlesGui.Enabled)
return 'create/join/cancel, cancellation failure, push race, board RPC and HUD restoration'
""")
case('bot_training_and_stale_potato_callback',GAME_ENV+r"""
pg:SetAttribute('ACP_OpenGamesNonce',1);flush();GL.ModeButtons.Practice.Activated:Fire();GL.Bot.Activated:Fire()
assert(GB.Root.Visible and GB.TrainingInfo.Visible and not GB.ClockRow.Visible)
GB.Cells[7][5].Activated:Fire();assert(GB.Cells[5][5].Hint.Visible)
GB.Cells[5][5].Activated:Fire();advance(.36);flush();assert(GB.Cells[5][5].PieceIcon and GB.Turn.Text=='SUA VEZ')
GB.Resign.Activated:Fire();assert(GL.Root.Visible and not GB.Root.Visible)
GL.SetGame('Batata');GL.DiffButtons.FACIL.Activated:Fire();math.random=function(a,b)return a end;GL.Bot.Activated:Fire()
GB.PotatoButtons[2].Activated:Fire();assert(GB.Turn.Text=='BOT JOGANDO')
GB.PotatoButtons[3].Activated:Fire();assert(GB.PotatoButtons[3].Text=='3')
GB.Resign.Activated:Fire();GL.Bot.Activated:Fire();flush();assert(GB.PotatoButtons[1].Text=='1'and GB.PotatoButtons[2].Text=='2')
GB.PotatoButtons[2].Activated:Fire();advance(.46);flush();assert(GB.Resign.Text=='Voltar aos jogos'and GB.Turn.Text=='VOCÊ VENCEU')
GB.Resign.Activated:Fire();assert(GL.Root.Visible)
return 'legal chess training, turn lock, clear result and stale callback cancellation'
""")
case('online_potato_overlay_and_leave',GAME_ENV+r"""
GameEvent.OnClientEvent:Fire('potatoOpen',{tableName='SalaBatata'})
assert(GB.Root.Visible and GB.Root.BackgroundTransparency==1 and not GB.Grid.Visible and not GB.Potato.Visible)
GameEvent.OnClientEvent:Fire('potatoState',{tableName='SalaBatata',message='Seu turno'});assert(GB.Message.Text=='Seu turno')
GB.Resign.Activated:Fire();assert(GB.ConfirmYes.Text=='Sair da sala');GB.ConfirmYes.Activated:Fire()
assert(requests[#requests][1]=='leave'and not GB.Root.Visible)
return 'physical online table kept visible, honest status and room leave'
""")

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

SERVER=DATA+CROSS+"\n"+r"""
local previousPlayers=Services.Players;Services.Players=Instance.new('Folder');for k,v in pairs(previousPlayers)do Services.Players[k]=v end
local server=Instance.new('Folder');script.Parent=server
local m=Instance.new('ModuleScript');m.Name='07H3_CROSS_SERVER_ROOMS';m.Parent=server;Modules[m.Name]=Directory
local kit=Instance.new('Folder');kit.Name='PracaKit';kit:SetAttribute('BaseReady',true);kit.Parent=rep
local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local hub=Instance.new('RemoteEvent');hub.Name='HubGameUI';hub.Parent=rem
local originalNew=Instance.new
Pushes={};Instance.new=function(class)local o=originalNew(class);if class=='RemoteEvent'then function o:FireClient(p,action,data)Pushes[#Pushes+1]={player=p,action=action,data=data}end end;return o end
function player(id)
 local p=Instance.new('Player');p.UserId=id;p.Name='Player'..id;p.Parent=Services.Players
 function p:GetJoinData()return self.join or{}end
 p.Character=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);p.Character.Parent=workspace
 return p
end
"""+src('01C_HUB_CHALLENGES')+r"""
RQ=rep.PracaKit.Remotes.GameRoomRequest
function request(p,action,arg)advance(.21);local r=RQ.OnServerInvoke(p,action,arg);assert(r,r and r.error);return r end
"""
case('real_room_server_create_join_close_and_arrival',SERVER+r"""
local host,guest,other=player(10),player(20),player(30)
local created=request(host,'create','Xadrez');assert(created.ok and created.crossServer);local entry=Entries[created.code].value
local joined=request(guest,'join',created.code);assert(joined.ok and joined.matched,joined.error)
assert(host:GetAttribute('ACP_InGameRoom')and guest:GetAttribute('ACP_InGameRoom'))
local tableModel=workspace.PracaAvatar_V2.ChallengeDistrict.Xadrez.Xadrez01
assert(tableModel.SeatA.Occupant==host.Character.Humanoid and tableModel.SeatB.Occupant==guest.Character.Humanoid)
assert(not request(other,'join',created.code).ok);assert(Entries[created.code].value.state=='closed')
assert(request(host,'leave').ok);assert(not host:GetAttribute('ACP_InGameRoom')and not guest:GetAttribute('ACP_InGameRoom'));advance(9)
assert(not tableModel:GetAttribute('ACP_RoomCode'));local room=request(host,'create','Damas');assert(room.ok)
game.JobId='other-job';assert(Directory.Route(guest,room.code));local travel=LastTravel;game.JobId='host-job'
guest.join={SourceGameId=500,TeleportData=travel.data};local arrival=request(guest,'arrival');assert(arrival.ok and arrival.matched,arrival.error)
assert(guest:GetAttribute('ACP_GameType')=='Damas');assert(request(guest,'leave').ok);assert(not request(guest,'arrival').ok,'expired arrival silently ignored')
return 'actual 01C server reserves, seats both real character doubles, closes, frees tables and validates arrival'
""")
case('real_room_server_host_leave_expiry_and_studio',SERVER+r"""
local host,guest=player(10),player(20);local created=request(host,'create','Batata');assert(created.ok)
Services.Players.PlayerRemoving:Fire(host);assert(not request(guest,'join',created.code).ok)
STUDIO=true;local localRoom=request(guest,'create','Damas');assert(localRoom.ok and not localRoom.crossServer)
advance(601);local extra=player(30);assert(not request(extra,'join',localRoom.code).ok);assert(request(extra,'stats').waiting.Damas==0)
STUDIO=false;local departing=player(50);local update=Map.UpdateAsync;local dropped=false
function Map:UpdateAsync(k,fn,ttl)local out=update(self,k,fn,ttl);if not dropped and out and out.owner==50 then dropped=true;Services.Players.PlayerRemoving:Fire(departing)end;return out end
assert(not request(departing,'create','Batata').ok,'disconnect while reserving left a ghost room')
return 'host disconnect removes global room, including during reservation; Studio codes are local and expire'
""")


case('room_cancellation_during_directory_close',SERVER+r"""
local host,guest=player(10),player(20);local created=request(host,'create','Xadrez');assert(created.ok)
local update=Map.UpdateAsync;local removeHost=true
function Map:UpdateAsync(k,fn,ttl)
 local out=update(self,k,fn,ttl)
 if removeHost and out and out.state=='closed'then removeHost=false;Services.Players.PlayerRemoving:Fire(host)end
 return out
end
local joined=request(guest,'join',created.code);assert(not joined.ok)
assert(not guest:GetAttribute('ACP_InGameRoom')and not guest.Character.Humanoid.Sit)
for _,p in ipairs(Pushes)do assert(p.action~='matched','closed room sent a late match')end
return 'host departure during yielding MemoryStore close cannot seat a guest or reopen a closed game'
""")


case('simultaneous_matches_reserve_distinct_tables',SERVER+r"""
local host,guest,host2,guest2=player(10),player(20),player(30),player(40)
local r1=request(host,'create','Xadrez');local r2=request(host2,'create','Xadrez');assert(r1.ok and r2.ok)
local update=Map.UpdateAsync;local interleave=true
function Map:UpdateAsync(k,fn,ttl)
 local out=update(self,k,fn,ttl)
 if interleave and out and out.state=='closed'then interleave=false;local second=request(guest2,'join',r2.code);assert(second.ok,second.error)end
 return out
end
assert(request(guest,'join',r1.code).ok)
local zone=workspace.PracaAvatar_V2.ChallengeDistrict.Xadrez
assert(zone.Xadrez01:GetAttribute('ACP_RoomCode')==r1.code and zone.Xadrez02:GetAttribute('ACP_RoomCode')==r2.code)
assert(zone.Xadrez01.SeatA.Occupant==host.Character.Humanoid and zone.Xadrez02.SeatA.Occupant==host2.Character.Humanoid)
return 'separate simultaneous room matches claim separate physical tables before any network yield'
""")

Path(__file__).with_name('game_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print('Validated',len(results),'game cases')
