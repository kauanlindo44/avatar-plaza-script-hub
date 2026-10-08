import ast
from test_support import *
base=ast.parse((ROOT/'audits/V51/test_server_flows.py').read_text())
for expr in base.body:
 if isinstance(expr,ast.Assign)and getattr(expr.targets[0],'id','')=='TRUCO':
  exec(compile(ast.Module(body=[expr],type_ignores=[]),'<four-player server fixture>','exec'),globals())
TRUCO=module('07K14_DECK_OPTIONS')+TRUCO
START=r'''
local made=ask(players[1],'create',{variant='Paulista'});assert(made.ok,made.error)
for i=2,4 do assert(ask(players[i],'join',{code=made.data.code}).ok)end
'''
READY=r'''
for _,p in ipairs(players)do assert(ask(p,'ready',{ready=true}).ok)end
'''
case('four_real_players_ready_consent_and_private_hands',TRUCO+START+r'''
assert(not latest(players[1]));for _,p in ipairs(players)do assert(not p:GetAttribute('ACP_InGameRoom'))end
for i=1,3 do assert(ask(players[i],'ready',{ready=true}).ok)end;assert(not latest(players[1]))
-- Leaving a staging room clears old readiness.
assert(ask(players[3],'leave').ok);assert(ask(players[3],'join',{code=made.data.code}).ok)
assert(ask(players[4],'ready',{ready=true}).ok);assert(not latest(players[1]))
assert(ask(players[3],'ready',{ready=true}).ok)
for seat,p in ipairs(players)do local v=latest(p);assert(v and v.seat==seat and #v.hand==3 and #v.players==4 and not v.hands and not v.deck);assert(p:GetAttribute('ACP_InGameRoom'))end
local turn=latest(players[1]).turn;local other=turn%4+1;local v=latest(players[other])
assert(not ask(players[other],'action',{revision=v.revision,action='play',arg=1}).ok)
v=latest(players[turn]);assert(ask(players[turn],'action',{revision=v.revision,action='play',arg=1}).ok)
assert(not ask(players[turn],'action',{revision=v.revision,action='play',arg=1}).ok)
return 'four joined players wait for all ready; rejoin resets consent; 2v2 own-hand-only payloads and turn/revision validation'
''')
case('friend_partner_slot_is_reserved_and_expires',TRUCO+r'''
players[1].IsFriendsWithAsync=function(self,uid)return uid==103 end
local made=ask(players[1],'create',{variant='Mineiro'});assert(made.ok)
assert(not ask(players[2],'partner',{user='103'}).ok)
assert(not ask(players[1],'partner',{user='104'}).ok)
assert(ask(players[1],'partner',{user='103'}).ok)
assert(not ask(players[4],'join',{code=made.data.code,team=1}).ok)
assert(ask(players[3],'join',{code=made.data.code,team=1}).ok)
local row=StoreData.ACP_TrucoRooms_V44[made.data.code];assert(row.slots['3'].uid==103 and row.slots['3'].present)
assert(ask(players[3],'leave').ok);assert(ask(players[1],'partner',{user='103'}).ok)
-- The periodic heartbeat is intentionally stopped in this fixture; preserve its lease.
StoreData.ACP_TrucoRooms_V44[made.data.code].lease=os.time()+200
advance(121);assert(ask(players[4],'join',{code=made.data.code,team=1}).ok)
return 'only host reserves verified Roblox friend in opposite team seat; others cannot take it; free after 120s'
''')
case('cross_server_friend_arrival_uses_reserved_seat',TRUCO+r'''
local Directory=Modules['07K3_TRUCO_DIRECTORY'];local room={owner=players[1],ownerSeat=1,players={[1]=players[1]},variant='Paulista'}
assert(Directory.Reserve(room,function()return false end));assert(Directory.HoldPartner(room,103))
local teleport=Services.TeleportService.TeleportAsync;local payload
Services.TeleportService.TeleportAsync=function(self,place,users,options)payload=deep(options.TeleportData);assert(options.ServerInstanceId=='job-A');return teleport(self,place,users,options)end
local host=game.JobId;game.JobId='job-B'
local routed,e=Directory.Route(players[3],room.code,1);assert(routed and routed.teleporting,e)
assert(payload.ACP_TrucoSeat==3 and payload.ACP_Guest==103)
game.JobId=host;players[3].JoinData={SourceGameId=game.GameId,TeleportData=payload}
local got,seat=Directory.Arrival(players[3],{[room.code]=room});assert(got==room and seat==3)
players[3].JoinData.TeleportData.ACP_Guest=104;assert(not Directory.Arrival(players[3],{[room.code]=room}))
return 'another server claims reserved opposite seat and routes to host; arrival validates room token, guest and source universe'
''')
case('ten_second_raise_deadline_is_enforced_by_server',TRUCO+START+READY+r'''
local v=latest(players[1]);local actor=players[v.turn];v=latest(actor)
assert(ask(actor,'action',{revision=v.revision,action='raise'}).ok)
local defender;for i=1,4 do if i%2~=v.turn%2 then defender=players[i];break end end
v=latest(defender);assert(v.phase=='raise'and v.remaining==10)
advance(10);local late=ask(defender,'action',{revision=v.revision,action='respond',arg='accept'})
assert(not late.ok and late.error:find('prazo'));assert(latest(defender).phase~='raise')
return 'native RPC refuses a response after deadline and settles the pending call before processing late action'
''')
case('rematch_requires_all_votes_and_old_cleanup_is_cancelled',TRUCO+r'''
local Match=Modules['07K2_TRUCO_MATCH'];local original=Match.New;local live
Match.New=function(room)live=original(room);return live end
'''+START+READY+r'''
local id=live.id;live.score[3-Modules['07K0_TRUCO_RULES'].Team(live.turn)]=11
assert(ask(players[live.turn],'action',{revision=live.revision,action='run'}).ok);assert(live.phase=='finished')
for i=1,3 do assert(ask(players[i],'action',{action='rematch'}).ok);assert(live.id==id)end
assert(ask(players[4],'action',{action='rematch'}).ok);assert(live.id~=id and live.phase=='play'and live.score[1]==0 and live.score[2]==0)
advance(26);for _,p in ipairs(players)do assert(p:GetAttribute('ACP_InGameRoom')and latest(p).phase=='play')end
return 'one vote cannot restart a 2v2 match; all four reset score and fresh hands; delayed cleanup of old result cannot close new match'
''')
HERE.joinpath('server_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

