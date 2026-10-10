-- 09B7_LAST_AVATAR | ModuleScript | ServerScriptService | V54 (NOVO)
-- Última aparência confirmada; fila coalescida, lease por sessão e flush na saída.
local Players=game:GetService('Players');local DS=game:GetService('DataStoreService')
local Http=game:GetService('HttpService');local Rep=game:GetService('ReplicatedStorage')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local store=DS:GetDataStore('AvatarPlaza_LastApplied_v1')
local M={};local states={};local started=false
local function state(pl)
 if not states[pl]then states[pl]={token=Http:GenerateGUID(false),revision=0,saved=0}end;return states[pl]
end
local function status(pl,value)
 pcall(function()pl:SetAttribute('ACP_AvatarSaveState',value)end)
end
local function validRecord(old)
 return old==nil or type(old)=='table'and old.version==1
end
function M.Read(pl)
 local s=state(pl)
 if s.loaded then return s.record,true end
 if s.closed then return nil,false end
 if s.loading then for _=1,160 do if not s.loading then break end;task.wait(.05)end;return s.record,s.loaded==true end
 s.loading=true
 local ok,data
 for attempt=1,3 do
  ok,data=pcall(function()return store:UpdateAsync('u_'..pl.UserId,function(old)
   if not validRecord(old)then return nil end
   local next=A.Copy(old or{version=1});next.session=s.token;return next
  end)end)
  if ok and data and data.session==s.token then break end
  if attempt<3 then task.wait(attempt*.35)end
 end
 s.loading=false
 if not ok or not data or data.session~=s.token then status(pl,'unavailable');return nil,false end
 s.loaded=true
 if type(data.body)=='table'then local clean=A.Clean(data.body)
  if clean then s.record={body=clean,rig=A.BodyRequiresR15(clean)and'R15'or data.rig=='R6'and'R6'or'R15'}end
 end
 return s.record,true
end
local write,schedule
schedule=function(pl,s)
 if s.scheduled or s.closed then return end;s.scheduled=true
 task.delay(math.max(.75,8-(os.clock()-(s.lastWrite or-8))),function()s.scheduled=false;if not s.closed then write(pl,s)end end)
end
write=function(pl,s,flushing)
 if s.writing or not s.pending then return end;s.writing=true
 if not s.loaded then local _,loaded=M.Read(pl);if not loaded then s.writing=false;return end end
 while s.pending do
  local record=s.pending;local revision=s.revision;local ok,data;local lost=false
  for attempt=1,3 do
   lost=false
   ok,data=pcall(function()return store:UpdateAsync('u_'..pl.UserId,function(old)
    if not validRecord(old)or not old or old.session~=s.token then lost=true;return nil end
    local next=A.Copy(old);next.body=A.Copy(record.body);next.rig=record.rig;next.updated=os.time();return next
   end)end)
   if lost or ok and data then break end
   if attempt<3 then task.wait(attempt*.5)end
  end
  if not ok or not data or lost then status(pl,lost and'superseded'or'unavailable');break end
  s.saved=revision;s.record=record;s.lastWrite=os.clock()
  if s.revision==revision then s.pending=nil;status(pl,'saved')end
  if s.pending and not flushing then schedule(pl,s);break end
 end
 s.writing=false
end
function M.Remember(pl,body,rig)
 local clean,why=A.Clean(body);if not clean then return false,why end
 local s=state(pl);if s.closed then return false,'Sessão encerrada.'end
 s.revision=s.revision+1;s.pending={body=A.Copy(clean),rig=A.BodyRequiresR15(clean)and'R15'or rig=='R6'and'R6'or'R15'}
 status(pl,'pending')
 schedule(pl,s)
 return true
end
function M.Flush(pl)
 local s=states[pl];if not s then return true end
 local untilTime=os.clock()+20
 while s.writing and os.clock()<untilTime do task.wait(.05)end
 if not s.writing and s.pending then write(pl,s,true)end
 return s.pending==nil
end
function M.Start()
 if started then return end;started=true
 Players.PlayerRemoving:Connect(function(pl)
  local s=states[pl];if not s then return end
  M.Flush(pl);s.closed=true;states[pl]=nil
 end)
 game:BindToClose(function()
  local left=0
  for pl in pairs(states)do left=left+1;task.spawn(function()M.Flush(pl);left=left-1 end)end
  local untilTime=os.clock()+25;while left>0 and os.clock()<untilTime do task.wait(.05)end
 end)
end
return M
