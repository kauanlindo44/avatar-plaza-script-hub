-- 07K3_TRUCO_DIRECTORY | ModuleScript | ServerScriptService | V44
-- Quatro vagas atômicas, reservas por jogador e recuperação de falha de viagem.
local Memory=game:GetService("MemoryStoreService")
local Teleport=game:GetService("TeleportService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local map=Memory:GetHashMap("ACP_TrucoRooms_V44")
local D={};local pending={};local alphabet="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function copy(old)local v={};for k,x in pairs(old)do v[k]=x end;v.slots={};for k,x in pairs(old.slots or{})do v.slots[k]={uid=x.uid,untilTime=x.untilTime,present=x.present}end;return v end
local function code()local s="";for _=1,4 do local i=math.random(#alphabet);s=s..alphabet:sub(i,i)end;return s end
function D.Available()return not Run:IsStudio()and game.PlaceId>0 and game.JobId~=""end
function D.Reserve(room,exists)
 room.token=Http:GenerateGUID(false);room.expires=os.time()+600
 if not D.Available()then repeat room.code=code()until not exists(room.code);return true end
 for _=1,8 do
  local key=code();local entry={token=room.token,job=game.JobId,place=game.PlaceId,expires=room.expires,
   state="waiting",lease=os.time()+90,slots={[tostring(room.ownerSeat or 1)]={uid=room.owner.UserId,untilTime=room.expires,present=true}},variant=room.variant}
  local ok,v=pcall(function()return map:UpdateAsync(key,function(old)
   if old and old.lease>os.time()then return nil end;return entry
  end,90)end)
  if not ok then return nil,"Não foi possível reservar o código global."end
  if v and v.token==room.token then room.code=key;room.shared=true;return true end
 end
 return nil,"Todos os códigos tentados estavam ocupados. Tente novamente."
end
function D.Claim(key,pl,team,token,wantedSeat)
 local ok,v=pcall(function()return map:UpdateAsync(key,function(old)
  local now=os.time();if not old or old.state~="waiting"or old.lease<=now or old.expires<=now or token and old.token~=token then return nil end
  local x=copy(old)
  for seat,slot in pairs(x.slots)do
   if slot.uid==pl.UserId then slot.untilTime=now+120;return x end
   if not slot.present and slot.untilTime<now then x.slots[seat]=nil end
  end
  for seat=1,4 do if(not wantedSeat or seat==wantedSeat)and(not team or seat%2==(team==1 and 1 or 0))and not x.slots[tostring(seat)]then
   x.slots[tostring(seat)]={uid=pl.UserId,untilTime=now+120,present=false};return x
  end end
  return nil
 end,90)end)
 if not ok then return nil,"Serviço de salas indisponível."end
 if not v then return nil,"Código expirado, sala cheia ou dupla completa."end
 for seat,slot in pairs(v.slots)do if slot.uid==pl.UserId then return v,tonumber(seat)end end
 return nil,"Reserva não confirmada."
end
function D.Refresh(room)
 if not room.shared then return true end
 local ok,v=pcall(function()return map:UpdateAsync(room.code,function(old)
  if not old or old.token~=room.token or old.state~="waiting"then return nil end
  local x=copy(old);x.lease=os.time()+90
  for seat=1,4 do local pl=room.players[seat]
   if pl and pl.UserId>0 then x.slots[tostring(seat)]={uid=pl.UserId,untilTime=room.expires,present=true}end
  end
  return x
 end,90)end)
 return ok and v~=nil
end
function D.Release(pl,key,token)
 if not key then return end
 pcall(function()map:UpdateAsync(key,function(old)
  if not old or old.token~=token then return nil end;local x=copy(old)
  for seat,slot in pairs(x.slots)do if slot.uid==pl.UserId then x.slots[seat]=nil end end;return x
 end,90)end)
end
function D.Close(room)
 if not room.shared then return end
 pcall(function()map:UpdateAsync(room.code,function(old)
  if not old or old.token~=room.token then return nil end;local v=copy(old);v.state="closed";v.lease=os.time()+10;return v
 end,10)end)
end
function D.Cancel(pl)local p=pending[pl];if p then D.Release(pl,p.code,p.token);pending[pl]=nil end end
function D.Route(pl,key,team)
 if not D.Available()then return nil,"Códigos entre servidores funcionam no jogo publicado."end
 if pending[pl]then return nil,"Viagem em andamento."end
 local v,seat=D.Claim(key,pl,team);if not v then return nil,seat end
 if v.job==game.JobId then D.Release(pl,key,v.token);return nil,"Esta sala já está neste servidor. Tente novamente."end
 local options=Instance.new("TeleportOptions");options.ServerInstanceId=v.job
 options:SetTeleportData({ACP_TrucoCode=key,ACP_TrucoToken=v.token,ACP_TrucoSeat=seat,ACP_Guest=pl.UserId})
 pending[pl]={code=key,token=v.token}
 local ok=pcall(function()Teleport:TeleportAsync(v.place,{pl},options)end);options:Destroy()
 if not ok then D.Cancel(pl);return nil,"Não foi possível viajar. Tente novamente."end
 task.delay(125,function()D.Cancel(pl)end);return {teleporting=true,code=key}
end
function D.Arrival(pl,rooms)
 local ok,join=pcall(function()return pl:GetJoinData()end);local d=ok and join.TeleportData
 if type(d)~="table"or join.SourceGameId~=game.GameId or d.ACP_Guest~=pl.UserId then return end
 local room=rooms[tostring(d.ACP_TrucoCode or"")]
 if not room or not room.shared or room.token~=d.ACP_TrucoToken or room.started then return nil,"Sua sala não está mais disponível."end
 local read,v=pcall(function()return map:GetAsync(room.code)end);local slot=read and v and v.slots[tostring(d.ACP_TrucoSeat)]
 if not slot or slot.uid~=pl.UserId or slot.untilTime<os.time()then return nil,"Reserva de viagem expirada."end
 return room,tonumber(d.ACP_TrucoSeat)
end
function D.Bind(push)
 Teleport.TeleportInitFailed:Connect(function(pl)if pending[pl]then D.Cancel(pl);push:FireClient(pl,"notice","A viagem falhou. Você pode tentar novamente.")end end)
end
return D
