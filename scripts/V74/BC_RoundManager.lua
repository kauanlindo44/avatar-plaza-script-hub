-- BC_RoundManager | ModuleScript | ServerScriptService | V74 (CRIAR)
-- Um único estado autoritativo. Sem economia, compras, ranking ou teleporte entre Places.
local Rep=game:GetService('ReplicatedStorage');local C=require(Rep:WaitForChild('BC_Config'))
local function dep(n)return require(script.Parent:WaitForChild(n))end
local State,Integration,Queue=dep('BC_PlayerState'),dep('BC_Integration'),dep('BC_Queue')
local Combat,Effects,Button=dep('BC_Combat'),dep('BC_EffectExecutor'),dep('BC_ButtonController')
local M={}
function M.New(ctx)
 local G={queue=Queue.New(),watchers={},round=nil,prep=nil,serial=0,lastPush=-math.huge};local now=ctx.now
 local function ready(pl)if not ctx.ready then return true end;local ok,value=pcall(ctx.ready,pl);return ok and value==true end
 local function member(pl)local r=G.round;local s=r and r.players[pl];return s and not s.left and s or nil end
 local function push(pl,kind,data)if pl.Parent then ctx.push(pl,kind,data)end end
 local function emit(kind,data)
  local r=G.round;if not r then return end
  for pl,s in pairs(r.players)do if not s.left then push(pl,kind,data)end end
 end
 local function announce(title,text,seconds)emit('announce',{title=title,text=text,seconds=seconds or 2})end
 local shared={arena=ctx.arena,now=now,random=ctx.random,emit=emit,announce=announce,eliminate=function(...)return G.Eliminate(...)end}
 G.combat=Combat.New(shared);shared.combat=G.combat;G.effects=Effects.New(shared)
 shared.execute=function(...)return G.effects.Execute(...)end;G.button=Button.New(shared)
 function G.Snapshot(pl)
  local r=G.round;local s=member(pl);local data={protocol=1,queued=G.queue.members[pl]==true,queue=G.queue.Count(),position=G.queue.Position(pl),
   phase=G.prep and'INTERMISSION'or'QUEUE',remaining=G.prep and math.max(0,math.ceil(G.prep-now()))or 0,arenaBusy=r~=nil,min=2,max=8}
  if s then
   data.phase=r.phase;data.matchId=r.id;data.alive=s.alive;data.training=r.training;data.score=s.score;data.health=math.max(0,math.ceil(s.hum.Health))
   data.remaining=math.max(0,math.ceil(r.deadline-now()));data.lastEffect=r.lastEffectName or'Nenhum efeito ainda';data.button=G.button.state
   data.effects=State.Timers(s,now());data.blackout=math.max(0,(r.blackoutUntil or 0)-now());data.roster={};data.aliveCount=0
   for p,v in pairs(r.players)do
    data.roster[#data.roster+1]={id=p.UserId,name=p.DisplayName,score=v.score,alive=v.alive and not v.left,winner=v.winner==true,left=v.left==true,shield=math.max(0,v.shield-now())}
    if v.alive and not v.left then data.aliveCount=data.aliveCount+1 end
   end
   table.sort(data.roster,function(a,b)if a.score==b.score then return a.id<b.id end;return a.score>b.score end)
   if s.weapon then data.weapon={name=s.weapon.kind=='E01'and'Blaster de energia'or'Bomba de espuma',ammo=s.weapon.ammo,token=s.weapon.token,remaining=math.max(0,math.ceil(s.weapon.untilAt-now()))}end
   if r.nuclear then data.nuclear={target=r.nuclear.target,name=r.nuclear.name,remaining=math.max(0,math.ceil(r.nuclear.untilAt-now()))}end
   data.winner=s.winner==true;data.noWinner=r.noWinner;data.continueNext=s.continueNext==true
  end
  return data
 end
 function G.Broadcast(force)
  if not force and now()-G.lastPush<C.SnapshotInterval then return end;G.lastPush=now()
  local sent={};if G.round then for pl,s in pairs(G.round.players)do if not s.left then push(pl,'state',G.Snapshot(pl));sent[pl]=true end end end
  for pl in pairs(G.watchers)do if not pl.Parent then G.watchers[pl]=nil elseif not sent[pl]then push(pl,'state',G.Snapshot(pl))end end
 end
 function G.Watch(pl)G.watchers[pl]=true;return G.Snapshot(pl)end
 function G.Join(pl)
  if member(pl)then return false,'Você já está nesta rodada.'end
  local ok,err=Integration.Available(pl);if not ok then return false,err end
  if not ready(pl)then return false,'Aguarde a confirmação do seu avatar no catálogo antes de entrar.'end
  local s,why=State.Capture(pl);if not s then return false,why end
  G.queue.Add(pl);pl:SetAttribute('BC_Queued',true);G.watchers[pl]=true;G.Broadcast(true);return true
 end
 function G.Eliminate(pl,killer,kind)
  local r=G.round;local s=r and r.players[pl];if not s or not s.alive then return end
  s.alive=false;G.combat.Clear(s);s.effects={};s.shield=0;s.killer=killer;Integration.Eliminated(s)
  if not r.training and killer and killer~=pl and r.players[killer]and(kind=='weapon'or kind=='nuclear')then r.players[killer].score=r.players[killer].score+C.KillPoints end
  push(pl,'announce',{title='Você foi eliminado',text='Acompanhe os sobreviventes ou volte ao catálogo.',seconds=2})
  -- O fim é conferido no Tick, depois de processar todos os danos simultâneos.
 end
 function G.Return(s)
  if s.returned then return end;s.returned=true
  G.combat.Clear(s)
  local restored,why=pcall(State.Restore,s);if not restored then warn('[BC][RESTORE] '..s.pl.UserId..' '..tostring(why))end
  Integration.Return(s,ctx.arena);push(s.pl,'return',{})
 end
 function G.Leave(pl)
  G.queue.Remove(pl);pl:SetAttribute('BC_Queued',nil)
  local s=member(pl);if s then G.Eliminate(pl,nil,'leave');s.left=true;s.continueNext=false;G.Return(s)end
  G.watchers[pl]=nil;G.Broadcast(true);return true
 end
 function G.Start(players,training)
  G.serial=G.serial+1;local r={id=ctx.serverId..':'..G.serial,players={},training=training==true,phase='COUNTDOWN',deadline=now()+C.Countdown,lastEffect=nil,nuclearUsed=false}
  G.round=r;G.prep=nil;local slot=0
  for _,pl in ipairs(players)do
   local available=Integration.Available(pl);local s=available and ready(pl)and State.Capture(pl)or nil
   pl:SetAttribute('BC_Queued',nil)
   if s then
    slot=slot+1;r.players[pl]=s
    local ok,err=pcall(function()
     Integration.Enter(s,r.id,ctx.arena);State.Begin(s,ctx.arena.Spawns[slot])
     s.connections[#s.connections+1]=s.hum.Died:Connect(function()G.Eliminate(pl,s.killer,s.killKind)end)
     s.connections[#s.connections+1]=pl.CharacterAdded:Connect(function()G.Eliminate(pl,nil,'respawn')end)
    end)
    if not ok then warn('[BC][ENTRY] '..pl.UserId..' '..tostring(err));s.alive=false;s.left=true;G.Return(s)end
   else push(pl,'error',{text='Seu avatar ou sua sala mudou. Entre novamente na fila.'})end
  end
  local count=0;for _,s in pairs(r.players)do if s.alive then count=count+1 end end
  if count<(training and 1 or C.MinPlayers)then
   for pl,s in pairs(r.players)do G.Return(s);if s.alive and not training then G.queue.Add(pl);pl:SetAttribute('BC_Queued',true)end end
   G.round=nil;G.button.Stop();G.Broadcast(true);return false
  end
  announce('Partida começando',training and'Treinamento individual · sem vitórias persistentes.'or'5 segundos · todos contra todos.',2);G.Broadcast(true);return true
 end
 function G.Training(pl)
  if G.round or G.prep or G.queue.Count()>0 then return false,'A arena está reservada para a fila. Aguarde a próxima rodada.'end
  local ok,err=Integration.Available(pl);if not ok then return false,err end
  if not ready(pl)then return false,'Aguarde seu avatar terminar de carregar.'end
  if not State.Capture(pl)then return false,'Aguarde seu avatar carregar.'end
  G.watchers[pl]=true;return G.Start({pl},true)
 end
 function G.Finish()
  local r=G.round;if not r or r.phase=='RESULTS'then return end
  G.button.Stop();G.combat.Cleanup(r);G.effects.Cleanup();r.nuclear=nil;r.blackoutUntil=nil
  local alive,best={},-math.huge
  for _,s in pairs(r.players)do if s.alive and not s.left then alive[#alive+1]=s;best=math.max(best,s.score)end end
  r.noWinner=#alive==0;r.phase='RESULTS';r.deadline=now()+C.Results
  for _,s in pairs(r.players)do
   s.effects={};s.shield=0
   if s.alive and not s.left then
    s.winner=not r.training and s.score==best
    if s.winner then s.score=s.score+C.WinPoints end
    s.frozen=true;s.root.Anchored=true;State.Recalculate(s,now())
   end
  end
  emit('clearFx',{});G.Broadcast(true)
 end
 function G.Continue(pl)
  local s=member(pl);if not s or G.round.phase~='RESULTS'then return false,'Aguarde o resultado da rodada.'end
  s.continueNext=true;G.Broadcast(true);return true
 end
 function G.Tick()
  local r=G.round
  if not r then
   if G.queue.Count()<C.MinPlayers then G.prep=nil
   elseif not G.prep then G.prep=now()+C.Intermission
   elseif now()>=G.prep then
    local players=G.queue.Take(C.MaxPlayers,function(pl)local ok=Integration.Available(pl);if not ok then pl:SetAttribute('BC_Queued',nil)end;return ok end)
    if #players>=C.MinPlayers then G.Start(players,false)else for _,pl in ipairs(players)do G.queue.Add(pl)end;G.prep=nil end
   end
  elseif r.phase=='COUNTDOWN'then
   for pl,s in pairs(r.players)do if s.alive and(not pl.Parent or pl.Character~=s.char or s.hum.Health<=0)then G.Eliminate(pl,nil,'unavailable')end end
   if now()>=r.deadline then
    r.phase='ACTIVE';r.deadline=now()+(r.training and C.Training or C.Duration)
    for _,s in pairs(r.players)do if s.alive then State.Release(s,now())end end;G.button.Start(r)
   end
  elseif r.phase=='ACTIVE'then
   for pl,s in pairs(r.players)do if s.alive then
    if not pl.Parent or pl.Character~=s.char or s.hum.Health<=0 then G.Eliminate(pl,s.killer,s.killKind)
    else
     State.Recalculate(s,now())
     if not ctx.arena.Inside(s.root.Position,1)then
      s.char:PivotTo(s.lastSafe*s.root.CFrame:Inverse()*s.char:GetPivot());s.root.AssemblyLinearVelocity=Vector3.zero
     else s.lastSafe=s.root.CFrame end
    end
   end end
   if now()>=r.deadline then G.Finish();G.Broadcast(false);return end
   G.combat.Tick(r);G.effects.Tick(r);G.button.Tick(r)
   local count=0;for _,s in pairs(r.players)do if s.alive and not s.left then count=count+1 end end
   if count==0 or(not r.training and count==1)or now()>=r.deadline then G.Finish()end
  elseif r.phase=='RESULTS'and now()>=r.deadline then
   for pl,s in pairs(r.players)do if not s.left then
    G.Return(s)
    if s.continueNext and pl.Parent then G.queue.Add(pl);pl:SetAttribute('BC_Queued',true);G.watchers[pl]=true end
   end end
   G.round=nil
  end
  G.Broadcast(false)
 end
 function G.Request(pl,action,arg)
  if action=='status'then return true,G.Watch(pl)
  elseif action=='watchOff'then G.watchers[pl]=nil;return true
  elseif action=='join'then return G.Join(pl)
  elseif action=='training'then return G.Training(pl)
  elseif action=='leave'then return G.Leave(pl)
  elseif action=='continue'then return G.Continue(pl)
  elseif action=='fire'then return G.combat.Shoot(G.round,pl,arg)end
  return false,'Ação desconhecida.'
 end
 function G.Shutdown()
  G.button.Destroy();G.combat.Cleanup(G.round);G.effects.Cleanup()
  if G.round then for _,s in pairs(G.round.players)do if not s.left then G.Return(s)end end end
  for _,pl in ipairs(G.queue.players)do pl:SetAttribute('BC_Queued',nil)end;G.queue=Queue.New();G.watchers={};G.round=nil;G.prep=nil
 end
 return G
end
return M
