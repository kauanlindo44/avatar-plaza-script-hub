-- 07H3_CROSS_SERVER_ROOMS | ModuleScript | ServerScriptService
-- V42: codigos globais, reserva atomica do convidado e viagem ao anfitriao.
local Memory=game:GetService("MemoryStoreService")
local Teleport=game:GetService("TeleportService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local M={};local pending={}
local map=Memory:GetHashMap("ACP_GameRooms_V42")
local alphabet="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function code4()
 local s="";for _=1,4 do local i=math.random(1,#alphabet);s=s..alphabet:sub(i,i)end;return s
end
local function copy(t)local out={};for k,v in pairs(t)do out[k]=v end;return out end
function M.Available()return not Run:IsStudio()and game.PlaceId>0 and game.JobId~=""and game.PrivateServerId==""end
function M.Reserve(room,exists)
 room.expires=os.time()+600;room.token=Http:GenerateGUID(false)
 if not M.Available()then repeat room.code=code4()until not exists(room.code);return true,false end
 for _=1,8 do
  local code=code4();if not exists(code)then
   local now=os.time();local entry={token=room.token,job=game.JobId,place=game.PlaceId,owner=room.owner.UserId,game=room.game,state="waiting",expires=room.expires,lease=now+90,claim=0,claimUntil=0}
   local ok,result=pcall(function()return map:UpdateAsync(code,function(old)
    if old and old.lease and old.lease>now then return nil end;return entry
   end,90)end)
   if not ok then return false,"Não foi possível criar o código global. Tente novamente."end
   if result and result.token==room.token then room.code=code;room.shared=true;return true,true end
  end
 end
 return false,"Não foi possível reservar uma sala. Tente novamente."
end
function M.Refresh(room)
 if not room.shared then return true end
 local now=os.time()
 local ok,data=pcall(function()return map:UpdateAsync(room.code,function(old)
  if not old or old.token~=room.token or old.state~="waiting"then return nil end
  local v=copy(old);v.lease=now+90;return v
 end,90)end)
 return ok and data~=nil,data
end
function M.Close(room)
 if not room.shared then return end
 pcall(function()map:UpdateAsync(room.code,function(old)
  if not old or old.token~=room.token then return nil end
  local v=copy(old);v.state="closed";v.lease=os.time()+10;return v
 end,10)end)
end
function M.Claim(code,pl,token)
 local now=os.time()
 local ok,data=pcall(function()return map:UpdateAsync(code,function(old)
  if not old or old.state~="waiting"or old.expires<=now or old.lease<=now or old.place~=game.PlaceId then return nil end
  if token and old.token~=token then return nil end
  if old.owner==pl.UserId then return nil end
  if old.claim~=0 and old.claim~=pl.UserId and old.claimUntil>now then return nil end
  local v=copy(old);v.claim=pl.UserId;v.claimUntil=now+120;return v
 end,90)end)
 if not ok then return nil,"Não foi possível consultar as salas. Tente novamente."end
 if not data then return nil,"Sala expirada, ocupada ou código inválido."end
 return data
end
function M.Release(pl,code,token)
 if not code then return end
 pcall(function()map:UpdateAsync(code,function(old)
  if not old or old.token~=token or old.claim~=pl.UserId or old.state~="waiting"then return nil end
  local v=copy(old);v.claim=0;v.claimUntil=0;return v
 end,90)end)
end
function M.Cancel(pl)
 local p=pending[pl];if p then M.Release(pl,p.code,p.token);pending[pl]=nil end
end
function M.Route(pl,code)
 if not M.Available()then return nil,"Entre no jogo publicado para usar códigos de outro servidor."end
 if pending[pl]then return nil,"Sua viagem já está iniciando."end
 local entry,err=M.Claim(code,pl);if not entry then return nil,err end
 if entry.job==game.JobId then M.Release(pl,code,entry.token);return nil,"A sala já está neste servidor. Tente o código novamente."end
 local options=Instance.new("TeleportOptions");options.ServerInstanceId=entry.job
 options:SetTeleportData({ACP_RoomCode=code,ACP_RoomToken=entry.token,ACP_Guest=pl.UserId})
 local p={code=code,token=entry.token};pending[pl]=p
 local ok=pcall(function()Teleport:TeleportAsync(entry.place,{pl},options)end);options:Destroy()
 if not ok then M.Cancel(pl);return nil,"Não foi possível viajar. O servidor pode estar cheio. Tente novamente."end
 task.delay(125,function()if pending[pl]==p then M.Cancel(pl)end end)
 return{ok=true,code=code,game=entry.game,teleporting=true}
end
function M.Arrival(pl,rooms)
 local ok,join=pcall(function()return pl:GetJoinData()end)
 local data=ok and join.TeleportData
 if type(data)~="table"or join.SourceGameId~=game.GameId or data.ACP_Guest~=pl.UserId then return end
 local room=rooms[tostring(data.ACP_RoomCode or"")]
 if not room or not room.shared or room.token~=data.ACP_RoomToken or room.started or room.closing then return nil,"A sala foi encerrada durante a viagem. Peça um novo código."end
 local read,entry=pcall(function()return map:GetAsync(room.code)end)
 if not read then return nil,"Não foi possível confirmar a sala. Tente o código novamente."end
 if not entry or entry.token~=room.token or entry.claim~=pl.UserId or entry.claimUntil<os.time()or entry.state~="waiting"then return nil,"Sua reserva expirou. Tente entrar pelo código novamente."end
 return room
end
function M.Bind(push)
 Teleport.TeleportInitFailed:Connect(function(pl)
  if not pending[pl]then return end;M.Cancel(pl)
  push:FireClient(pl,"travelFailed",{error="A viagem falhou. Tente entrar pelo código novamente."})
 end)
end
function M.Forget(pl)pending[pl]=nil end
return M
