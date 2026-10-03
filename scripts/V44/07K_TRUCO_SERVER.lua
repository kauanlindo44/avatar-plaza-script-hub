-- 07K_TRUCO_SERVER | Script | ServerScriptService | V44
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Teleport=game:GetService("TeleportService")
local kit=Rep:WaitForChild("PracaKit",30);if not kit then return end
local rem=kit:WaitForChild("Remotes")
local function remote(class,name)local o=rem:FindFirstChild(name);if not o then o=Instance.new(class);o.Name=name;o.Parent=rem end;return o end
local request=remote("RemoteFunction","TrucoRequest");local push=remote("RemoteEvent","TrucoPush")
local R=require(Rep:WaitForChild("07K0_TRUCO_RULES"))
local Match=require(script.Parent:WaitForChild("07K2_TRUCO_MATCH"))
local Directory=require(script.Parent:WaitForChild("07K3_TRUCO_DIRECTORY"))
local Tables=require(script.Parent:WaitForChild("07K4_TRUCO_TABLES"))
local Inventory=require(script.Parent:WaitForChild("07K8_CARD_INVENTORY"))
local Commerce=require(script.Parent:WaitForChild("07K10_CARD_COMMERCE"))
local Progress=require(script.Parent:WaitForChild("07K11_GAMES_PROGRESS"))
local Cups=require(script.Parent:WaitForChild("07K13_TOURNAMENT_SERVICE"))
local rooms={};local memberships={};local guards={};local busy={};local ready=false
local function count(room)local n=0;for i=1,4 do if room.players[i]then n=n+1 end end;return n end
local function roomOf(pl)return rooms[memberships[pl.UserId]]end
local function send(pl,kind,data)if pl.UserId>0 and pl.Parent==Players then push:FireClient(pl,kind,data)end end
local function view(room)
 for seat=1,4 do local pl=room.players[seat];if pl and pl.UserId>0 and pl.Parent==Players then
  if room.started then
   local v=Match.View(room,seat);v.styles={}
   for i=1,4 do local d=Inventory.View(room.players[i].UserId);v.styles[i]=d and{style=d.equipped,custom=d.custom}or{style="Classic"}end
   send(pl,"match",v)
  else send(pl,"waiting",{code=room.code,count=count(room),variant=room.variant,team=R.Team(seat),manual=room.manual})end
 end end
end
local function close(room)
 if not room or room.closing then return end;room.closing=true;Directory.Close(room)
 for i=1,4 do local pl=room.players[i];if pl and pl.UserId>0 and memberships[pl.UserId]==room.code then memberships[pl.UserId]=nil;if pl.Parent==Players then Tables.Release(room,pl);send(pl,"closed")end end end
 room.table:SetAttribute("ACP_TrucoRoom",nil);rooms[room.code]=nil
end
local function start(room)
 if room.started or count(room)~=4 then return end
 room.started=true;room.match=Match.New(room);if room.cup then task.spawn(function()Cups.Begin(room.cup,room.cupMatch)end)end;room.disconnected={};Directory.Close(room)
 if room.closing or room.match.phase=="finished"then return end
 for i=1,4 do local pl=room.players[i];if pl.UserId>0 then
  pl:SetAttribute("ACP_InGameRoom",true);pl:SetAttribute("ACP_GameType","Truco");pl:SetAttribute("ACP_Competitive",not room.training)
  pl:SetAttribute("ACP_TrucoSeat",i);Tables.Seat(room,pl,i)
 end end
 view(room)
end
local function create(owner,data,cup,entry)
 if not ready then return nil,"Mesas ainda estão carregando."end
 if not cup and(roomOf(owner)or owner:GetAttribute("ACP_InGameRoom")or owner:GetAttribute("ACP_BoardWaiting"))then return nil,"Saia da partida atual primeiro."end
 local t=Tables.FindFree();if not t then return nil,"Todas as mesas estão ocupadas."end
 local variant=R.Profiles[data.variant]and data.variant or"Paulista"
 local room={owner=owner,players={},table=t,variant=variant,quick=data.quick==true,manual=not cup and data.manual==true and R.Profiles[variant].manual,
  training=data.training==true,difficulty=data.difficulty or"Médio",ownerSeat=not data.training and data.team==2 and 2 or 1,cup=cup,cupMatch=entry and entry.id,allowed={}}
 if entry then for _,uid in ipairs(entry.players)do room.allowed[uid]=true end end
 local ok,err=Directory.Reserve(room,function(code)return rooms[code]~=nil end);if not ok then return nil,err end
 if not cup and owner.Parent~=Players then Directory.Close(room);return nil,"Você saiu durante a criação da sala."end
 rooms[room.code]=room;t:SetAttribute("ACP_TrucoRoom",room.code)
 if not cup then room.players[room.ownerSeat]=owner;memberships[owner.UserId]=room.code;owner:SetAttribute("ACP_TrucoRoom",room.code)end
 return room
end
local function join(pl,room,seat,team)
 if not room or room.closing or room.expires<os.time()and not room.started then return nil,"Sala expirada."end
 if room.cup and not room.allowed[pl.UserId]then return nil,"Sala exclusiva dos classificados."end
 if room.started then
  for i=1,4 do if room.players[i].UserId==pl.UserId then
   room.players[i]=pl;room.disconnected[i]=nil;memberships[pl.UserId]=room.code;pl:SetAttribute("ACP_TrucoRoom",room.code);pl:SetAttribute("ACP_TrucoSeat",i)
   pl:SetAttribute("ACP_InGameRoom",true);pl:SetAttribute("ACP_GameType","Truco");pl:SetAttribute("ACP_Competitive",true)
   Tables.Seat(room,pl,i);view(room);return{matched=true,code=room.code}
  end end;return nil,"A partida já começou."
 end
 if roomOf(pl)or pl:GetAttribute("ACP_InGameRoom")or pl:GetAttribute("ACP_BoardWaiting")then return nil,"Você já está em uma sala."end
 local desired
 if room.cup then for i,uid in ipairs(room.entryPlayers or{})do if uid==pl.UserId then desired=({1,3,2,4})[i];team=R.Team(desired)end end end
 if not seat and room.shared then local claimed,e=Directory.Claim(room.code,pl,team,room.token,desired);if not claimed then return nil,e end
  for k,s in pairs(claimed.slots)do if s.uid==pl.UserId then seat=tonumber(k)end end
 end
 if desired and seat and seat~=desired then Directory.Release(pl,room.code,room.token);return nil,"Assento reservado para sua dupla. Tente novamente."end
 if room.closing or pl.Parent~=Players then Directory.Release(pl,room.code,room.token);return nil,"Sala encerrada durante a conexão."end
 seat=desired or seat
 if not seat then for i=1,4 do if not room.players[i]and(not team or R.Team(i)==team)then seat=i;break end end end
 if not seat or room.players[seat]then return nil,"A dupla escolhida está completa."end
 room.players[seat]=pl;memberships[pl.UserId]=room.code;pl:SetAttribute("ACP_TrucoRoom",room.code)
 if room.shared then Directory.Refresh(room)end
 if count(room)==4 then start(room)else view(room)end
 return {code=room.code,matched=room.started==true,count=count(room),variant=room.variant}
end
local function finish(room)
 if room.recorded or room.match.phase~="finished"then return end;room.recorded=true
 local s=room.match;local winners,losers={},{}
 for i=1,4 do table.insert(R.Team(i)==s.winner and winners or losers,room.players[i].UserId)end
 task.spawn(function()Progress.Record("Truco",s.id,winners,losers,{duration=os.clock()-s.startedAt,moves=s.plays,
  training=room.training,irregular=s.irregular==true,cup=room.cup,cupMatch=room.cupMatch})end)
 task.delay(25,function()close(room)end)
end
local handle
handle=function(pl,action,data)
 data=type(data)=="table"and data or{}
 if action=="inventory"then local d=Inventory.View(pl.UserId)or Inventory.Load(pl.UserId);return d end
 if action=="store"then return Commerce.Store(pl)end
 if action=="prompt"then return Commerce.Prompt(pl,data.kind,data.key)end
 if action=="buycoins"then return Inventory.BuyCoins(pl.UserId,data.kind,data.key,data.quantity)end
 if action=="openbox"then if data.styles then return Inventory.OpenChoices(pl.UserId,data.key,data.styles)end;return Inventory.OpenChoice(pl.UserId,data.key,data.style,data.quantity)end
 if action=="equip"then return Inventory.Equip(pl.UserId,tostring(data.style))end
 if action=="settings"then return Inventory.Settings(pl.UserId,data)end
 if action=="custom"then
  local id=tonumber(data.image);if not id or id%1~=0 or id<1 then return nil,"ID de imagem inválido."end
  local Market=game:GetService("MarketplaceService");local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
  if not ok or not info or(info.AssetTypeId~=1 and info.AssetTypeId~=13)then return nil,"Use um ID de imagem ou decal publicado e aprovado no Roblox."end
  return Inventory.SetCustom(pl.UserId,data)
 end
 if action=="rank"then return Progress.Top(data.game or"Truco",20)end
 if action=="inbox"then return Cups.Inbox(pl)end
 if action=="answer"then return Cups.Answer(pl,data.id,data.accept==true)end
 if action=="checkin"then return Cups.Checkin(pl,data.id)end
 if action=="shout"then
  local r=roomOf(pl);local allowed={['Boa jogada!']=true,['Vamos nessa!']=true,['É nossa vez!']=true,['Respeito à mesa']=true}
  if not r or not r.started or not allowed[data.text]then return nil,"Expressão indisponível."end
  r.shouts=r.shouts or{};if os.clock()-(r.shouts[pl.UserId]or-100)<6 then return nil,"Aguarde antes de outro grito."end;r.shouts[pl.UserId]=os.clock()
  for _,other in pairs(r.players)do send(other,"shout",pl.DisplayName..": "..data.text)end;return true
 end
 if action=="cupjoin"then
  local m,e=Cups.Match(pl,data.id,data.match);if not m then return nil,e end
  if m.host~=game.JobId then
   local options=Instance.new("TeleportOptions");options.ServerInstanceId=m.host;options:SetTeleportData({ACP_Cup=m.cup,ACP_CupMatch=m.id,ACP_Guest=pl.UserId})
   local ok=pcall(function()Teleport:TeleportAsync(game.PlaceId,{pl},options)end);options:Destroy();return ok and{teleporting=true}or nil,ok and nil or"Não foi possível viajar para o torneio."
  end
  if m.game=="Truco"then return join(pl,rooms[m.code])end
  local f=script.Parent:FindFirstChild("ACP_JoinBoardCup");local d=f and f:Invoke(pl,m.code);return d and d.ok and d or nil,d and d.error or"Sala indisponível."
 end
 if action=="rooms"then local n=0;for _,r in pairs(rooms)do if not r.started then n=n+1 end end;return{Truco=n}end
 if action=="create"or action=="training"or action=="quick"then
  if action=="quick"then for _,r in pairs(rooms)do if r.quick and not r.started and r.variant==(data.variant or"Paulista")then return join(pl,r)end end end
  data.quick=action=="quick";data.training=action=="training";if data.training then data.manual=false end
  local r,e=create(pl,data);if not r then return nil,e end
  if r.training then
   for i=2,4 do r.players[i]={UserId=-i,Name="Bot "..i,DisplayName="Bot "..r.difficulty}end;start(r)
  else view(r)end
  return{code=r.code,variant=r.variant,count=count(r),matched=r.started==true}
 end
 if action=="join"then
  local code=string.upper(tostring(data.code or"")):gsub("%s+","")
  if #code~=4 or code:find("[^A-Z2-9]")then return nil,"Informe o código de quatro caracteres."end
  local team=tonumber(data.team);if team~=1 and team~=2 then team=nil end
  if rooms[code]then return join(pl,rooms[code],nil,team)end;return Directory.Route(pl,code,team)
 end
 if action=="arrival"then
  local current=roomOf(pl);if current and current.started then return join(pl,current)end
  local ok,j=pcall(function()return pl:GetJoinData()end);local td=ok and j.TeleportData
  if type(td)=="table"and j.SourceGameId==game.GameId and td.ACP_Guest==pl.UserId and td.ACP_Cup then return handle(pl,"cupjoin",{id=td.ACP_Cup,match=td.ACP_CupMatch})end
  local r,seat=Directory.Arrival(pl,rooms);if r then return join(pl,r,seat)end;return true end
 local room=roomOf(pl)
 if action=="leave"then
  Directory.Cancel(pl);if not room then return true end
  if room.started and room.match.phase~="finished"then
   local seat=pl:GetAttribute("ACP_TrucoSeat")or 1;room.match.score[3-R.Team(seat)]=12;R.Award(room.match,3-R.Team(seat),0,"Desistência");view(room);finish(room)
  end
  if room.started then Tables.Release(room,pl);memberships[pl.UserId]=nil;send(pl,"closed")
  elseif room.owner==pl then close(room)
  else for i=1,4 do if room.players[i]==pl then room.players[i]=nil end end;memberships[pl.UserId]=nil;pl:SetAttribute("ACP_TrucoRoom",nil);Directory.Release(pl,room.code,room.token);view(room)end
  return true
 end
 if action=="action"and room and room.started then
  if next(room.disconnected)then return nil,"Aguardando reconexão por até três minutos."end
  if room.match.pauseUntil and os.clock()<room.match.pauseUntil then return nil,"Aguarde a conclusão da vaza."end
  local seat=pl:GetAttribute("ACP_TrucoSeat");if not seat or room.players[seat]~=pl then return nil,"Jogador não está na mesa."end
  if data.revision~=room.match.revision then return nil,"A mesa mudou. Aguarde a atualização."end
  local before=#room.match.tricks;local ok,err=Match.Action(room.match,seat,data.action,data.arg,data.extra);if not ok then return nil,err end
  if #room.match.tricks~=before then room.match.pauseUntil=os.clock()+1.4 end
  room.match.deadline=Match.Deadline(room.match,os.clock());view(room);finish(room);return true
 end
 return nil,"Pedido indisponível."
end
request.OnServerInvoke=function(pl,action,data)
 if type(action)~="string"or busy[pl]or guards[pl]and os.clock()-guards[pl]<.12 then return{ok=false,error="Aguarde um instante."}end
 busy[pl]=true;guards[pl]=os.clock();local ok,result,err=pcall(handle,pl,action,data);busy[pl]=nil
 if not ok then warn("ACP V44: "..tostring(result));return{ok=false,error="Serviço temporariamente indisponível."}end
 return{ok=result~=nil and result~=false,data=result,error=err}
end
Inventory.Changed:Connect(function(id)
 local pl=Players:GetPlayerByUserId(id);if pl then local d=Inventory.View(id);pl:SetAttribute("ACP_AllowAvatarCopy",d.privacy.allowCopy);send(pl,"inventory",d)end
end)
local function added(pl)
 task.spawn(function()Cups.LoadTitles(pl);local d=Inventory.Load(pl.UserId);if d then pl:SetAttribute("ACP_AllowAvatarCopy",d.privacy.allowCopy);Commerce.RefreshPasses(pl);send(pl,"inventory",Inventory.View(pl.UserId))end end)
 pl.CharacterAdded:Connect(function()local r=roomOf(pl);if r and r.started then task.wait(.5);for i=1,4 do if r.players[i].UserId==pl.UserId then Tables.Seat(r,pl,i);view(r)end end end end)
end
Players.PlayerAdded:Connect(added);for _,pl in ipairs(Players:GetPlayers())do added(pl)end
Players.PlayerRemoving:Connect(function(pl)
 guards[pl]=nil;busy[pl]=nil;Directory.Cancel(pl);local r=roomOf(pl)
 if r and r.started then for i=1,4 do if r.players[i]==pl then r.disconnected[i]=os.clock()+180 end end
 elseif r then if r.owner==pl then close(r)else for i=1,4 do if r.players[i]==pl then r.players[i]=nil end end;memberships[pl.UserId]=nil;Directory.Release(pl,r.code,r.token);view(r)end end
end)
Commerce.Start();Directory.Bind(push)
Cups.Start(function(kind,entry,cup)
 if kind~="Truco"then local f=script.Parent:FindFirstChild("ACP_CreateBoardCup");return f and f:Invoke(kind,entry,cup)end
 for _,r in pairs(rooms)do if r.cupMatch==entry.id then return{code=r.code}end end
 local owner={UserId=entry.players[1]};local r=create(owner,{variant="Paulista"},cup,entry)
 if r then r.entryPlayers=entry.players;return{code=r.code}end
end,function(kind,code)
 if kind=="Truco"then local r=rooms[code];return r and r.started and r.match.phase~="finished"or false end
 local f=script.Parent:FindFirstChild("ACP_BoardCupActive");return f and f:Invoke(code)or false
end)
task.spawn(function()
 while not kit:GetAttribute("ActivitiesReady")do task.wait(.1)end
 local world=workspace:WaitForChild("PracaAvatar_V2");Tables.Build(world:WaitForChild("ChallengeDistrict"));ready=true
 local lastDirectory,lastCups=0,0
 while script.Parent do
  task.wait(.35);local now=os.clock()
  for _,room in pairs(rooms)do
   if room.started then
    for seat,deadline in pairs(room.disconnected)do if now>deadline and room.match.phase~="finished"then
     room.match.score[3-R.Team(seat)]=12;R.Award(room.match,3-R.Team(seat),0,"Reconexão não concluída em três minutos");view(room)
    end end
    if next(room.disconnected)and room.match.phase~="finished"then room.match.deadline=now+30;room.match.nextHand=nil
    elseif Match.Step(room,now)then view(room)end;finish(room)
   elseif room.expires<os.time()then close(room)end
  end
  if now-lastDirectory>25 then lastDirectory=now;task.spawn(function()for _,r in pairs(rooms)do if not r.started and r.shared then Directory.Refresh(r)end end end)end
  if now-lastCups>30 then lastCups=now;task.spawn(function()Cups.Tick();for _,pl in ipairs(Players:GetPlayers())do send(pl,"inbox",Cups.Inbox(pl))end end)end
 end
end)
