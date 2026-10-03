import ast
from test_support import *
DATA=DATA.replace(';S.Init()','')
old=ast.parse((ROOT/'audits/V42/test_games.py').read_text())
for expr in old.body:
 if isinstance(expr,ast.Assign)and getattr(expr.targets[0],'id','')in{'CROSS','SERVER'}:exec(compile(ast.Module(body=[expr],type_ignores=[]),'<native rooms fixture>','exec'),globals())
 for_case=False
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  name=ast.literal_eval(expr.value.args[0])
  if name in {'real_room_server_create_join_close_and_arrival','room_cancellation_during_directory_close'}:case(name,eval(compile(ast.Expression(expr.value.args[1]),'<native rooms regression>','eval'),globals()))
case('board_room_end_frees_membership_and_cup_whitelist',SERVER+"function Services.Players:GetPlayers()return self:GetChildren()end\n"+r'''
local a,b,c=player(10),player(20),player(30)
local room=request(a,'create','Xadrez');assert(room.ok and a:GetAttribute('ACP_BoardWaiting'));assert(not request(a,'create','Batata').ok)
assert(request(b,'join',room.code).matched)
script.Parent.ACP_BoardFinished:Fire(room.code);assert(not a:GetAttribute('ACP_BoardWaiting')and not a:GetAttribute('ACP_InGameRoom'));advance(9)
local entry={id='cup-match',players={10,20}};local f=script.Parent.ACP_CreateBoardCup;local reservation=f.OnInvoke('Xadrez',entry,'cup-1');assert(reservation and reservation.code)
assert(not request(c,'join',reservation.code).ok);assert(request(b,'join',reservation.code).matched)
local tableModel=workspace.PracaAvatar_V2.ChallengeDistrict.Xadrez.Xadrez01;assert(tableModel:GetAttribute('ACP_Cup')=='cup-1')
Services.Players.PlayerRemoving:Fire(b);advance(650);local replacement=player(20);local r=request(replacement,'join',reservation.code);assert(r.ok and r.matched,r.error)
assert(replacement:GetAttribute('ACP_InGameRoom'));script.Parent.ACP_BoardFinished:Fire(reservation.code)
return 'no removed game, board result releases membership/table, cup accepts only classified players and reconnects after original 10-minute room creation lease'
''')
TRUCO=DATA+module('07K0_TRUCO_RULES')+module('07K1_TRUCO_AI')+module('07K6_CARD_CATALOG')+module('07K2_TRUCO_MATCH')+module('07K3_TRUCO_DIRECTORY')+module('07K4_TRUCO_TABLES')+module('07K8_CARD_INVENTORY')+module('07K10_CARD_COMMERCE')+module('07K11_GAMES_PROGRESS')+module('07K13_TOURNAMENT_SERVICE')+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit:SetAttribute('ActivitiesReady',true);kit.Parent=rep
local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local district=Instance.new('Folder');district.Name='ChallengeDistrict';district.Parent=world
local players={makePlayer(101),makePlayer(102),makePlayer(103),makePlayer(104)}
function Services.Players:GetPlayers()return players end
'''+src('07K_TRUCO_SERVER')+r'''
local loop=table.remove(task.queue);local wait=task.wait;task.wait=function(seconds)if seconds==.35 then script.Parent=nil end end
loop.fn();script.Parent=rep;task.wait=wait;flush()
local rq=rem.TrucoRequest;local push=rem.TrucoPush
local function ask(p,action,data)advance(.2);local result=rq.OnServerInvoke(p,action,data);assert(result,result and result.error);return result end
local function latest(p)local view;for _,m in ipairs(push.sent)do if m.kind=='match'and m.player==p then view=m.data end end;return view end
'''
case('truco_bootstrap_four_seats_private_payload_and_old_room_close',TRUCO+r'''
local made=ask(players[1],'create',{variant='Paulista'});assert(made.ok,made.error)
for i=2,4 do local joined=ask(players[i],'join',{code=made.data.code});assert(joined.ok,joined.error)end
for seat,p in ipairs(players)do local v=latest(p);assert(v and v.seat==seat and #v.hand==3 and #v.players==4 and not v.hands and not v.deck);assert(p:GetAttribute('ACP_InGameRoom'))end
local turn=latest(players[1]).turn;local wrongSeat=turn%4+1;local v=latest(players[wrongSeat]);local wrong=ask(players[wrongSeat],'action',{revision=v.revision,action='play',arg=1});assert(not wrong.ok)
v=latest(players[turn]);assert(ask(players[turn],'action',{revision=v.revision,action='play',arg=1}).ok)
assert(not ask(players[turn],'action',{revision=v.revision,action='play',arg=1}).ok,'stale revision accepted')
for _,p in ipairs(players)do assert(ask(p,'leave').ok)end
local new=ask(players[1],'create',{variant='Mineiro'});assert(new.ok);advance(26)
assert(players[1]:GetAttribute('ACP_TrucoRoom')==new.data.code,'old room cleared newer membership')
assert(ask(players[2],'join',{code=new.data.code}).ok)
return 'real bootstrap and RPC; four seats, own-hand-only pushes, turn/revision guard, resignation and delayed old cleanup cannot erase a new room'
''')
case('truco_cup_seats_can_arrive_in_any_order_and_reconnect',TRUCO+r'''
local cups=Modules['07K13_TOURNAMENT_SERVICE'];local callback
local original=cups.Start;cups.Start=function(fn,active)callback=fn;original(fn,active)end
-- Re-run startup in a fresh bootstrap scope, with no prior rooms and no second loop.
'''+src('07K_TRUCO_SERVER')+r'''
local loop2=table.remove(task.queue);task.wait=function(seconds)if seconds==.35 then script.Parent=nil end end;loop2.fn();script.Parent=rep;task.wait=wait;flush()
rq=rem.TrucoRequest;local reservation=callback('Truco',{id='cup-game',players={101,102,103,104}},'cup-id');assert(reservation)
cups.Match=function(p)return{game='Truco',code=reservation.code,host=game.JobId,id='cup-game',cup='cup-id'}end
for _,index in ipairs({4,2,3,1})do local r=ask(players[index],'cupjoin',{id='cup-id',match='cup-game'});assert(r.ok,r.error)end
assert(players[1]:GetAttribute('ACP_TrucoSeat')==1 and players[2]:GetAttribute('ACP_TrucoSeat')==3 and players[3]:GetAttribute('ACP_TrucoSeat')==2 and players[4]:GetAttribute('ACP_TrucoSeat')==4)
local old=players[2];Services.Players.PlayerRemoving:Fire(old);players[2]=makePlayer(102);Services.Players.PlayerAdded:Fire(players[2]);flush()
local joined=ask(players[2],'cupjoin',{id='cup-id',match='cup-game'});assert(joined.ok,joined.error);assert(players[2]:GetAttribute('ACP_TrucoSeat')==3)
return 'qualified duplas reserve fixed opposite seats despite reverse arrival order, and returning player retains their seat after disconnect'
''')
HERE.joinpath('server_flow_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('SERVER FLOWS',len(results),'PASS')
