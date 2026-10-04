-- 07K13_TOURNAMENT_SERVICE | ModuleScript | ServerScriptService | V44
-- Entrada gratuita e prêmio somente título. Convites no jogo; nenhuma mensagem externa.
local DS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Players=game:GetService("Players")
local P=require(script.Parent:WaitForChild("07K11_GAMES_PROGRESS"))
local store=DS:GetDataStore("ACP_WeeklyCups_V44")
local titles=DS:GetDataStore("ACP_WeeklyTitles_V44")
local presence=game:GetService("MemoryStoreService"):GetHashMap("ACP_CupPresence_V44")
local leaders=game:GetService("MemoryStoreService"):GetHashMap("ACP_CupLeaders_V44")
local pulses=game:GetService("MemoryStoreService"):GetHashMap("ACP_CupMatches_V44")
local T={};local cache={};local hostCallback,activeCallback;local awarded={}
local function online(uid)local ok,d=pcall(function()return presence:GetAsync(tostring(uid))end);return ok and d and d.time>os.time()-75 end
local function leader(id,now)
 local ok,d=pcall(function()return leaders:UpdateAsync(id,function(old)
  if old and old.untilTime>now and old.job~=game.JobId then return nil end;return{job=game.JobId,untilTime=now+45}
 end,60)end);return ok and d and d.job==game.JobId
end
local offsets={Xadrez=5*86400+22*3600,Damas=5*86400+23*3600,Truco=6*86400+22*3600}
local function cupID(game,week)return week.."_"..game end
local function members(key)
 local out={};for n in tostring(key):gmatch("%d+")do table.insert(out,tonumber(n))end;return out
end
local function contains(ids,uid)for _,v in ipairs(ids)do if v==uid then return true end end;return false end
local function update(id,fn)
 local ok,d=pcall(function()return store:UpdateAsync(id,fn)end);if ok and d then cache[id]={time=os.clock(),data=d};return d end
end
local function read(id)
 local old=cache[id];if old and os.clock()-old.time<20 then return old.data end
 local ok,d=pcall(function()return store:GetAsync(id)end);if ok and d then cache[id]={time=os.clock(),data=d};return d end
end
local function candidateReady(v,now)
 for _,uid in ipairs(v.members)do if v.answers[tostring(uid)]~="yes"then return false end end
 return true
end
function T.Snapshot(game,week,now)
 local id=cupID(game,week);local start=345600+week*604800+offsets[game];local old=read(id)
 if old or now<start-4*86400 or now>=start then return old end
 local top=P.Top(game,60,week);if not top then return end
 if #top==0 then top=P.Top(game,60,week-1)or{}end
 local entries={};for i,row in ipairs(top)do entries[i]={key=row.key,members=members(row.key),wins=row.value,
  answers={},checkins={},rank=i,status=i<=10 and"invited"or"reserve",deadline=math.min(start-1800,now+48*3600)}end
 return update(id,function(current)if current then return current end
  return {id=id,game=game,start=start,entries=entries,phase="invites",round=0,matches={},created=now}
 end)
end
function T.Inbox(pl)
 local now=os.time();local out={};local week=P.Week(now)
 for _,w in ipairs({week-1,week,week+1})do for game in pairs(offsets)do
  local c=read(cupID(game,w));if c then
   for _,v in ipairs(c.entries)do if contains(v.members,pl.UserId)then
    local joined=v.answers[tostring(pl.UserId)]=="yes";local expired=v.status=="expired"or v.status=="invited"and now>v.deadline and not joined
    local message={id=c.id,game=game,start=c.start,deadline=v.status=="reserve"and c.start-1800 or v.deadline,status=expired and"Prazo encerrado"or v.status,
     answered=v.answers[tostring(pl.UserId)],canAnswer=(v.status=="reserve"and now<c.start-1800 or now<=v.deadline)and c.phase=="invites",members=v.members,
     canCheckin=joined and now>=c.start-900 and now<c.start-300,checked=v.checkins[tostring(pl.UserId)]~=nil}
    for _,m in ipairs(c.matches)do if contains(m.players,pl.UserId)and(m.status=="ready"or m.status=="playing")then message.match={id=m.id,code=m.code,host=m.host,expires=m.expires}end end
    table.insert(out,message)
   end end
  end
 end end
 return out
end
function T.Answer(pl,id,accept)
 local now=os.time();local accepted=false
 local d=update(tostring(id),function(c)
  if not c or c.phase~="invites"then return nil end
  for _,v in ipairs(c.entries)do if contains(v.members,pl.UserId)and(v.status=="invited"and now<=v.deadline or v.status=="reserve"and now<c.start-1800)then
   v.answers[tostring(pl.UserId)]=accept and"yes"or"no";accepted=true;return c
  end end;return nil
 end)
 return d and accepted and true or nil,"Convite encerrado ou não disponível."
end
function T.Checkin(pl,id)
 local now=os.time()
 local d=update(tostring(id),function(c)
  if not c or now<c.start-900 or now>=c.start-300 then return nil end
  for _,v in ipairs(c.entries)do if contains(v.members,pl.UserId)and candidateReady(v,now)then
   v.checkins[tostring(pl.UserId)]=now;return c
  end end;return nil
 end)
 return d and true or nil,"Check-in entre 15 e 5 minutos antes do início."
end
local function fill(c,now)
 local active=0
 for _,v in ipairs(c.entries)do
  if v.status=="invited"then
   local refused=false;for _,a in pairs(v.answers)do if a=="no"then refused=true end end
   if refused or now>v.deadline and not candidateReady(v,now)then v.status="expired"else active=active+1 end
  end
 end
 for _,v in ipairs(c.entries)do if active<10 and v.status=="reserve"and now<c.start-1800 then
  v.status="invited";v.deadline=math.min(c.start-1800,now+24*3600);active=active+1
 end end
end
local function bracket(c,keys)
 local size=1;while size<#keys do size=size*2 end
 -- Classificados de maior posição recebem as folgas quando há dez vagas.
 c.round=c.round+1;c.matches={};local byes=size-#keys;local nextKeys={}
 for i=1,byes do table.insert(nextKeys,keys[i])end
 local remaining={};for i=byes+1,#keys do table.insert(remaining,keys[i])end
 for i=1,#remaining/2 do
  local a,b=remaining[i],remaining[#remaining-i+1];local ids={}
  for _,uid in ipairs(members(a))do table.insert(ids,uid)end;for _,uid in ipairs(members(b))do table.insert(ids,uid)end
  table.insert(c.matches,{id=Http:GenerateGUID(false),a=a,b=b,players=ids,status="pending",created=os.time(),waitUntil=math.max(c.start,os.time())+600})
 end
 c.advance=nextKeys
end
function T.Tick()
 local now=os.time();local week=P.Week(now)
 for _,pl in ipairs(Players:GetPlayers())do pcall(function()presence:SetAsync(tostring(pl.UserId),{time=now,job=game.JobId},90)end)end
 for gameName in pairs(offsets)do for _,w in ipairs({week-1,week,week+1})do
  local id=cupID(gameName,w);local c=read(id)
  if c and activeCallback then for _,m in ipairs(c.matches)do if m.status=="playing"and m.host==game.JobId and activeCallback(c.game,m.code)then
   pcall(function()pulses:SetAsync(m.id,{job=game.JobId,time=now},240)end)
  end end end
  if leader(id,now)then c=T.Snapshot(gameName,w,now)
  local connected,activity={},{}
  if c then
   -- Async reads are completed BEFORE UpdateAsync: its callback may never yield.
   for _,entry in ipairs(c.entries)do if entry.status=="reserve"and candidateReady(entry,now)then for _,uid in ipairs(entry.members)do connected[uid]=online(uid)==true end end end
   for _,m in ipairs(c.matches)do
    if m.status=="ready"and m.expires<now or m.status=="pending"and now>(m.waitUntil or m.created+600)then for _,uid in ipairs(m.players)do connected[uid]=online(uid)==true end end
    if m.status=="playing"then local ok,p=pcall(function()return pulses:GetAsync(m.id)end);activity[m.id]={ok=ok,data=p}end
   end
   update(id,function(v)
   if not v or v.phase=="finished"or v.phase=="cancelled"then return nil end
   if v.phase=="invites"then
    fill(v,now)
    if now>=v.start-300 then
     local keys={}
     for _,entry in ipairs(v.entries)do if entry.status=="invited"and candidateReady(entry,now)then
      local ready=true;for _,uid in ipairs(entry.members)do if not entry.checkins[tostring(uid)]then ready=false end end
      if ready then table.insert(keys,entry.key);entry.status="qualified"end
     end end
     -- Reservas online precisam ter aceitado previamente; nunca inscrição automática.
     for _,entry in ipairs(v.entries)do if #keys<10 and entry.status=="reserve"and candidateReady(entry,now)then
      local available=true;for _,uid in ipairs(entry.members)do if not connected[uid]then available=false end end
      if available then table.insert(keys,entry.key);entry.status="qualified"end
     end end
     if #keys<2 then v.phase="cancelled"else v.phase="playing";bracket(v,keys)end
    end
   elseif v.phase=="playing"and now>=v.start then
    local done=true
    for _,m in ipairs(v.matches)do
     if m.status~="finished"then done=false end
     if m.status=="pending"and(not m.lease or m.lease<now)then
      m.host=game.JobId;m.lease=now+60
     end
     if m.status=="playing"then local pulse=activity[m.id]
      if pulse and pulse.ok and now>(m.started or v.start)+180 and(not pulse.data or pulse.data.time<now-120)then
       m.id=Http:GenerateGUID(false);m.status="pending";m.code=nil;m.host=nil;m.lease=nil;m.waitUntil=now+600;m.restarts=(m.restarts or 0)+1
      end
     end
     if m.status=="ready"and m.expires<now or m.status=="pending"and now>(m.waitUntil or m.created+600)then
      local a,b=true,true;for _,uid in ipairs(members(m.a))do if not connected[uid]then a=false end end;for _,uid in ipairs(members(m.b))do if not connected[uid]then b=false end end
      m.status="finished";m.winner=a and not b and m.a or b and not a and m.b or nil
     end
    end
    if done then
     local keys=v.advance or{};for _,m in ipairs(v.matches)do if m.winner then table.insert(keys,m.winner)end end
     if #keys==0 then v.phase="cancelled"elseif #keys==1 then v.phase="finished";v.champion=keys[1]else bracket(v,keys)end
    end
   end
   return v
  end)end
  c=read(id)
  if c and c.phase=="playing"and now>=c.start and hostCallback then
   for _,m in ipairs(c.matches)do if m.status=="pending"and m.host==game.JobId then
    local room=hostCallback(c.game,m,c.id)
    if room then update(c.id,function(v)for _,x in ipairs(v.matches)do if x.id==m.id and x.status=="pending"and x.host==game.JobId then
     x.code=room.code;x.status="ready";x.expires=now+600;break
    end end;return v end)end
   end end
  elseif c and c.phase=="finished"and c.champion then
   for _,uid in ipairs(members(c.champion))do local awardKey=c.id..":"..uid;if not awarded[awardKey]then local ok=pcall(function()titles:UpdateAsync(tostring(uid),function(old)
    old=old or{};if old[c.id]then return nil end;old[c.id]={game=c.game,title="Campeão semanal • "..c.game,week=w};return old
   end)end);if ok then awarded[awardKey]=true end end;local pl=Players:GetPlayerByUserId(uid);if pl then pl:SetAttribute("ACP_WeeklyTitle","Campeão semanal • "..c.game)end end
  end
  end
 end end
end
function T.Result(gameName,id,winners,losers,context)
 if not context.cup or not context.cupMatch then return end
 local key=gameName=="Truco"and P.TeamKey(winners[1],winners[2])or tostring(winners[1])
 update(context.cup,function(c)
  if not c or c.game~=gameName then return nil end
  for _,m in ipairs(c.matches)do if m.id==context.cupMatch and(m.a==key or m.b==key)and(m.status=="ready"or m.status=="playing")then m.winner=key;m.status="finished";return c end end
  return nil
 end)
end
function T.Match(pl,id,matchID)
 local c=read(tostring(id));if not c or c.phase~="playing"then return nil,"Torneio indisponível."end
 for _,m in ipairs(c.matches)do if m.id==matchID and contains(m.players,pl.UserId)and(m.status=="ready"or m.status=="playing")then return{game=c.game,code=m.code,host=m.host,id=m.id,cup=c.id}end end
 return nil,"Você não está classificado para esta partida."
end
function T.Begin(cup,matchID)
 if not cup then return end
 return update(cup,function(c)if not c then return nil end;for _,m in ipairs(c.matches)do if m.id==matchID and m.status=="ready"then m.status="playing";m.started=os.time();return c end end;return nil end)
end
function T.Draw(cup,matchID)
 return update(cup,function(c)if not c then return nil end;for _,m in ipairs(c.matches)do if m.id==matchID and m.status=="playing"then
  m.status="pending";m.code=nil;m.host=nil;m.lease=nil;m.waitUntil=os.time()+600;m.rematches=(m.rematches or 0)+1;return c
 end end;return nil end)
end
function T.LoadTitles(pl)
 local ok,d=pcall(function()return titles:GetAsync(tostring(pl.UserId))end);if not ok or not d then return end
 local latest=-1;local title
 for _,v in pairs(d)do if v.week>latest then latest=v.week;title=v.title end end
 if title then pl:SetAttribute("ACP_WeeklyTitle",title)end
end
function T.Start(callback,active)hostCallback=callback;activeCallback=active;P.Completed:Connect(T.Result)end
return T
