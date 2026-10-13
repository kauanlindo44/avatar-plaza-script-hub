-- 01C_HUB_CHALLENGES | Script | ServerScriptService | V62 (SUBSTITUIR)
-- Salas de xadrez/damas no mesmo servidor. Personagens permanecem no mapa.
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService')
local kit=Rep:WaitForChild('PracaKit',30);if not kit then return end;local rem=kit:WaitForChild('Remotes')
local Engine=require(script.Parent:WaitForChild('07H7_BOARD_SESSIONS'));Engine.Bind()
local function remote(class,name)local o=rem:FindFirstChild(name)or Instance.new(class);o.Name=name;o.Parent=rem;return o end
local request=remote('RemoteFunction','GameRoomRequest');local push=remote('RemoteEvent','GameRoomPush');request:SetAttribute('Version','V62')
local rooms,byPlayer,pending,series,busy,last={},{},{},{},{},{}
local function count(r)local n=0;for _ in pairs(r.players)do n=n+1 end;return n end
local function roomOf(p)return byPlayer[p]and rooms[byPlayer[p]]end
local function clear(p)
 byPlayer[p]=nil;p:SetAttribute('ACP_BoardWaiting',nil);p:SetAttribute('ACP_InGameRoom',nil);p:SetAttribute('ACP_GameType',nil);p:SetAttribute('ACP_RoomCode',nil)
end
local function destroy(r)
 if not r or r.closing then return end;r.closing=true;rooms[r.code]=nil
 for p in pairs(r.players)do clear(p);if p.Parent==Players then push:FireClient(p,'roomClosed')end end
end
Engine.Finished.Event:Connect(function(code,summary)
 local r=rooms[code];if not r then return end
 local ps={};for p in pairs(r.players)do ps[#ps+1]=p end;table.sort(ps,function(a,b)return a.UserId<b.UserId end);local ticket
 if #ps==2 and not r.cup then
  local key=r.game..':'..ps[1].UserId..':'..ps[2].UserId;local score=series[key]or{wins={},round=0};series[key]=score;score.round=score.round+1;score.expires=os.time()+1800
  if summary.winnerUID then score.wins[summary.winnerUID]=(score.wins[summary.winnerUID]or 0)+1 end
  ticket={token=Http:GenerateGUID(false),game=r.game,players=ps,score=score,votes={},expires=os.time()+120};for _,p in ipairs(ps)do pending[p]=ticket end
 end
 destroy(r)
 if ticket then for i,p in ipairs(ps)do local other=ps[3-i];if p.Parent==Players then push:FireClient(p,'postMatch',{token=ticket.token,game=r.game,yours=ticket.score.wins[p.UserId]or 0,theirs=ticket.score.wins[other.UserId]or 0,opponent=other.DisplayName or other.Name,canRematch=other.Parent==Players})end end end
end)
local chars='ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
local function code()
 for _=1,80 do local s='';for _=1,4 do local n=math.random(1,#chars);s=s..chars:sub(n,n)end;if not rooms[s]then return s end end
end
local function create(p,kind,quick)
 if kind~='Xadrez'and kind~='Damas'then return nil,'Jogo inválido.'end
 if roomOf(p)or p:GetAttribute('ACP_TrucoRoom')then return nil,'Você já está em uma sala.'end
 local id=code();if not id then return nil,'Não há código disponível. Tente novamente.'end
 local r={code=id,game=kind,owner=p,players={[p]=true},quick=quick==true,expires=os.time()+600};rooms[id]=r;byPlayer[p]=id;p:SetAttribute('ACP_BoardWaiting',id);return r
end
local function join(p,r)
 if not r or r.closing or r.expires<=os.time()then return{ok=false,error='Sala indisponível neste servidor. Use Partida rápida ou compartilhe o código com quem está aqui.'}end
 if r.allowed and not r.allowed[p.UserId]then return{ok=false,error='Sala exclusiva dos classificados.'}end
 if roomOf(p)or p:GetAttribute('ACP_TrucoRoom')then return{ok=false,error='Você já está em uma sala.'}end
 if r.started or r.matching or count(r)>=2 then return{ok=false,error='A sala já iniciou.'}end
 if r.owner.Parent~=Players then destroy(r);return{ok=false,error='O anfitrião saiu.'}end
 r.matching=true;r.players[p]=true;byPlayer[p]=r.code
 local ps={};for player in pairs(r.players)do ps[#ps+1]=player end;table.sort(ps,function(a,b)return a.UserId<b.UserId end);if r.swapSides then ps[1],ps[2]=ps[2],ps[1]end
 r.started=true;r.expires=os.time()+1200
 for _,player in ipairs(ps)do player:SetAttribute('ACP_BoardWaiting',nil);player:SetAttribute('ACP_InGameRoom',true);player:SetAttribute('ACP_GameType',r.game);player:SetAttribute('ACP_RoomCode',r.code)end
 local name,why=Engine.Open(r,ps);r.matching=false;if not name then destroy(r);return{ok=false,error=why}end;r.tableName=name
 -- boardOpen já traz estado completo; matched não deve apagar o resultado iniciado.
 return{ok=true,matched=true,game=r.game,code=r.code,tableName=name,crossServer=false}
end
local function handle(p,action,a)
 if action=='stats'then local waiting={Xadrez=0,Damas=0};for _,r in pairs(rooms)do if not r.started then waiting[r.game]=waiting[r.game]+1 end end;return{ok=true,waiting=waiting,crossServer=false,protocol=2}end
 if action=='arrival'then return{ok=true,protocol=2}end
 if action=='create'then local r,e=create(p,tostring(a),false);return r and{ok=true,code=r.code,game=r.game,crossServer=false}or{ok=false,error=e}end
 if action=='quick'then
  if roomOf(p)then return{ok=false,error='Você já está em uma sala.'}end
  for _,r in pairs(rooms)do if r.game==a and r.quick and not r.started and not r.matching and count(r)==1 then return join(p,r)end end
  local r,e=create(p,tostring(a),true);return r and{ok=true,code=r.code,game=r.game,crossServer=false}or{ok=false,error=e}
 end
 if action=='join'then return join(p,rooms[tostring(a or''):upper():gsub('%s+','')])end
 if action=='leave'or action=='cancel'then local r=roomOf(p);if r and r.started then Engine.Leave(p)elseif r then destroy(r)end;return{ok=true}end
 if action=='rematch'or action=='declineRematch'then
  local t=pending[p];if not t or t.token~=(type(a)=='table'and a.token or a)or t.expires<os.time()then return{ok=false,error='Convite de revanche expirado.'}end
  if action=='declineRematch'then pending[p]=nil;t.votes[p.UserId]=nil;return{ok=true}end
  for _,player in ipairs(t.players)do if player.Parent~=Players or pending[player]~=t or roomOf(player)or player:GetAttribute('ACP_TrucoRoom')then return{ok=false,error='Adversário indisponível.'}end end
  t.votes[p.UserId]=true;local n=0;for _ in pairs(t.votes)do n=n+1 end
  if n<2 then for _,player in ipairs(t.players)do push:FireClient(player,'rematchVote',{votes=n,canRematch=true})end;return{ok=true,waiting=true}end
  local r,e=create(t.players[1],t.game,false);if not r then return{ok=false,error=e}end;r.swapSides=t.score.round%2==1
  local result=join(t.players[2],r);if result.ok then for _,player in ipairs(t.players)do pending[player]=nil end end;return result
 end
 return{ok=false,error='Ação inválida.'}
end
request.OnServerInvoke=function(p,action,a)
 if type(action)~='string'or busy[p]or last[p]and os.clock()-last[p]<.15 then return{ok=false,error='Aguarde um instante.'}end
 busy[p]=true;last[p]=os.clock();local ok,value=pcall(handle,p,action,a);busy[p]=nil
 if not ok then warn('[Board V62] ROOM '..tostring(value));return{ok=false,error='Falha na sala 2D. Confira o Output do servidor.'}end;value.protocol=2;return value
end
local function bind(name,callback)local b=script.Parent:FindFirstChild(name)or Instance.new('BindableFunction');b.Name=name;b.Parent=script.Parent;b.OnInvoke=callback end
bind('ACP_JoinBoardCup',function(p,id)local r=roomOf(p);if r and r.code==id then return{ok=true,code=id}end;return handle(p,'join',id)end)
bind('ACP_BoardCupActive',function(id)local r=rooms[id];return r and r.cup~=nil and r.started or false end)
bind('ACP_CreateBoardCup',function(kind,entry,cup)
 for _,r in pairs(rooms)do if r.cupMatch==entry.id then return{code=r.code}end end
 for _,uid in ipairs(entry.players)do local p=Players:GetPlayerByUserId(uid);if p and not roomOf(p)then local r=create(p,kind,false);if r then r.cup=cup;r.cupMatch=entry.id;r.allowed={};for _,id in ipairs(entry.players)do r.allowed[id]=true end;return{code=r.code}end end end
end)
Players.PlayerRemoving:Connect(function(p)Engine.Leave(p);local r=roomOf(p);if r then destroy(r)end;pending[p]=nil;last[p]=nil;busy[p]=nil end)
local function expire()
 for p,t in pairs(pending)do if t.expires<os.time()or p.Parent~=Players then pending[p]=nil end end
 for key,v in pairs(series)do if v.expires<os.time()then series[key]=nil end end
 for _,r in pairs(rooms)do if not r.started and r.expires<os.time()then destroy(r)end end;task.delay(30,expire)
end
task.delay(30,expire);kit:SetAttribute('ActivitiesReady',true);print('[V62] Xadrez/damas 2D: sem assentos e sem teleporte')
