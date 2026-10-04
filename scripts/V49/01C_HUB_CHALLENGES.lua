-- 01C_HUB_CHALLENGES
-- Script | ServerScriptService
-- AVATAR PLAZA V44 - salas de jogos realmente ocultas do mapa principal.
-- Mantém o Avatar Space completamente limpo: partidas acontecem longe do mapa principal.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("BaseReady") do task.wait(.1) end
local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end
local O=Vector3.new(kit:GetAttribute("OriginX")or 0,kit:GetAttribute("OriginY")or 60,kit:GetAttribute("OriginZ")or 0)
local rem=kit:WaitForChild("Remotes")
local function remote(className,name)
 local x=rem:FindFirstChild(name)
 if x and x.ClassName~=className then x:Destroy();x=nil end
 if not x then x=Instance.new(className);x.Name=name;x.Parent=rem end
 return x
end
local request=remote("RemoteFunction","GameRoomRequest")
local push=remote("RemoteEvent","GameRoomPush")
local Directory=require(script.Parent:WaitForChild("07H3_CROSS_SERVER_ROOMS"));Directory.Bind(push)
local C={dark=Color3.fromRGB(52,61,71),wood=Color3.fromRGB(145,105,75),white=Color3.fromRGB(235,237,237),black=Color3.fromRGB(65,70,77),gold=Color3.fromRGB(239,197,91)}
local function part(parent,name,size,pos,color,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.Color=color or C.dark;p.Material=Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function status(m,pos)
 local a=part(m,"StatusAnchor",Vector3.new(.2,.2,.2),pos+Vector3.new(0,7,0),C.dark,1);a.CanCollide=false
 local g=Instance.new("BillboardGui");g.Name="StatusGui";g.Size=UDim2.fromOffset(150,34);g.AlwaysOnTop=false;g.MaxDistance=55;g.Enabled=false;g.Parent=a
 local t=Instance.new("TextLabel");t.Name="StatusLabel";t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="DISPONIVEL";t.TextColor3=C.white;t.Font=Enum.Font.GothamBold;t.TextSize=10;t.Parent=g
end
local function makeTable(zone,kind,index,pos)
 local m=Instance.new("Model");m.Name=kind..string.format("%02d",index);m:SetAttribute("GameType",kind);m:SetAttribute("TableIndex",index);m.Parent=zone
 local floor=part(m,"RoomFloor",Vector3.new(34,1,28),pos+Vector3.new(0,-.5,0),Color3.fromRGB(83,89,98));floor.Material=Enum.Material.Concrete
 part(m,"Top",Vector3.new(8.6,.55,8.6),pos+Vector3.new(0,3.1,0),C.wood)
 for j,z in ipairs({-5.6,5.6})do
  local seat=Instance.new("Seat");seat.Name=j==1 and"SeatB"or"SeatA";seat.Size=Vector3.new(3,.55,3);seat.Position=pos+Vector3.new(0,1.85,z);seat.Anchored=true;seat.Color=Color3.fromRGB(62,157,207);seat.Parent=m;seat.CFrame=CFrame.lookAt(seat.Position,pos+Vector3.new(0,1.85,0))
 end
 local pp=part(m,"GamePromptPart",Vector3.new(6,3,6),pos+Vector3.new(4,3.7,0),C.dark,1);pp.CanCollide=false;pp.CanTouch=false
 local pr=Instance.new("ProximityPrompt");pr.Name="GamePrompt";pr.Enabled=false;pr.ActionText="JOGAR";pr.ObjectText=kind;pr.RequiresLineOfSight=false;pr.Parent=pp
 status(m,pos)
 if kind=="Xadrez"or kind=="Damas"then
  local board=Instance.new("Folder");board.Name="Board";board.Parent=m;local cell=.76
  for r=1,8 do for c=1,8 do
   local col=(r+c)%2==0 and C.white or C.black
   local sq=part(board,string.format("Square_%d_%d",r,c),Vector3.new(cell,.08,cell),pos+Vector3.new((c-4.5)*cell,3.43,(r-4.5)*cell),col,1)
   sq.CanCollide=false;sq:SetAttribute("Row",r);sq:SetAttribute("Col",c);sq:SetAttribute("BaseR",col.R);sq:SetAttribute("BaseG",col.G);sq:SetAttribute("BaseB",col.B);sq:SetAttribute("BaseMaterial","SmoothPlastic")
  end end

 end
 return m
end
local old=world:FindFirstChild("ChallengeDistrict")
if old then old:Destroy() end
local district=Instance.new("Folder");district.Name="ChallengeDistrict";district.Parent=world
local pools={Xadrez={},Damas={}}
local starts={Xadrez=O+Vector3.new(4200,520,4200),Damas=O+Vector3.new(4200,520,4360)}
for kind,startPos in pairs(starts)do
 local zone=Instance.new("Folder");zone.Name=kind;zone.Parent=district
 for i=1,10 do pools[kind][i]=makeTable(zone,kind,i,startPos+Vector3.new(((i-1)%5)*48,0,math.floor((i-1)/5)*40))end
end

local rooms={};local playerRoom={};local leaving=setmetatable({},{__mode="k"})
local function people(room)local n=0;for _ in pairs(room.players)do n=n+1 end;return n end
local function roomOf(pl)return playerRoom[pl]and rooms[playerRoom[pl]]or nil end
local function findFreeTable(kind)for _,t in ipairs(pools[kind]or{})do if not t:GetAttribute("ACP_RoomCode")then return t end end end
local function spawnPos()local sp=world:FindFirstChild("SpawnCentral",true);return sp and sp.CFrame*CFrame.new(0,4,0)or CFrame.new(O+Vector3.new(0,5,0))end
local function clearPlayer(pl)
 playerRoom[pl]=nil;pl:SetAttribute("ACP_BoardWaiting",nil);pl:SetAttribute("ACP_InGameRoom",nil);pl:SetAttribute("ACP_GameType",nil);pl:SetAttribute("ACP_RoomCode",nil)
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");if hum then hum.Sit=false end
 if char then task.delay(.1,function()if char.Parent then char:PivotTo(spawnPos())end end)end
end
local function destroyRoom(room,holdSeconds)
 if not room or room.closing then return end;room.closing=true;local heldTable=room.table
 for pl in pairs(room.players)do if pl.Parent==Players then clearPlayer(pl);push:FireClient(pl,"roomClosed")else playerRoom[pl]=nil end end
 rooms[room.code]=nil;Directory.Close(room)
 if heldTable then task.delay(holdSeconds or 0,function()if heldTable.Parent then heldTable:SetAttribute("ACP_RoomCode",nil);heldTable:SetAttribute("ACP_RoomOwner",nil);heldTable:SetAttribute("ACP_Cup",nil);heldTable:SetAttribute("ACP_CupMatch",nil)end end)end
end
local boardReconnect=Instance.new("BindableEvent");boardReconnect.Name="ACP_BoardReconnect";boardReconnect.Parent=script.Parent
local boardFinished=Instance.new("BindableEvent");boardFinished.Name="ACP_BoardFinished";boardFinished.Parent=script.Parent
boardFinished.Event:Connect(function(code)destroyRoom(rooms[code],8)end)
local function match(room)
 if room.started or people(room)<2 then return false,"Aguardando jogador."end
 local t=findFreeTable(room.game);if not t then return false,"Todas as salas desse jogo estao ocupadas."end
 room.started=true;room.table=t;t:SetAttribute("ACP_RoomCode",room.code);t:SetAttribute("ACP_RoomOwner",room.owner.UserId);t:SetAttribute("ACP_Cup",room.cup);t:SetAttribute("ACP_CupMatch",room.cupMatch)
 Directory.Close(room);if room.closing then return false,"A sala foi encerrada."end
 local ps={};for p in pairs(room.players)do table.insert(ps,p)end;table.sort(ps,function(a,b)return a.UserId<b.UserId end)
 for i,p in ipairs(ps)do
  p:SetAttribute("ACP_InGameRoom",true);p:SetAttribute("ACP_GameType",room.game);p:SetAttribute("ACP_RoomCode",room.code)
  local char=p.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local seat=t:FindFirstChild(i==1 and"SeatA"or"SeatB")
  if char and hum and seat then
   char:PivotTo(seat.CFrame*CFrame.new(0,3,0));task.wait(.08)
   if room.closing or p.Parent~=Players or p.Character~=char or hum.Health<=0 then destroyRoom(room,8);return false,"Um jogador saiu da sala."end;seat:Sit(hum)
  end
 end
 task.wait(.18);if room.closing then return false,"A sala foi encerrada."end
 for _,p in ipairs(ps)do push:FireClient(p,"matched",{game=room.game,tableName=t.Name,code=room.code})end;return true
end
local function makeRoom(pl,game,quick)
 if not pools[game]then return nil,"Jogo inválido."end
 if roomOf(pl)or pl:GetAttribute("ACP_TrucoRoom")then return nil,"Você já está em uma sala."end
 local room={game=game,owner=pl,players={[pl]=true},quick=quick==true,started=false}
 local ok,err=Directory.Reserve(room,function(code)return rooms[code]~=nil end)
 if not ok then return nil,err end
 if leaving[pl]or pl.Parent~=Players then Directory.Close(room);return nil,"Você saiu do servidor."end
 rooms[room.code]=room;playerRoom[pl]=room.code;pl:SetAttribute("ACP_BoardWaiting",room.code);return room
end
local function joinLocal(pl,r,arrival)
 if r and r.allowed and not r.allowed[pl.UserId]then return{ok=false,error="Sala exclusiva dos classificados."}end
 if not r or r.closing or not r.started and r.expires<=os.time()then return{ok=false,error="Sala expirada ou código inválido."}end
 if roomOf(pl)or pl:GetAttribute("ACP_TrucoRoom")then return{ok=false,error="Você já está em uma sala."}end
 if r.started and r.cup and r.allowed and r.allowed[pl.UserId]then
  local side;for old in pairs(r.players)do if old.UserId==pl.UserId then r.players[old]=nil;r.players[pl]=true;break end end
  playerRoom[pl]=r.code;pl:SetAttribute("ACP_InGameRoom",true);pl:SetAttribute("ACP_GameType",r.game);pl:SetAttribute("ACP_RoomCode",r.code)
  local ps={};for p in pairs(r.players)do table.insert(ps,p)end;table.sort(ps,function(a,b)return a.UserId<b.UserId end)
  for i,p in ipairs(ps)do if p==pl then side=i end end;local seat=r.table:FindFirstChild(side==1 and"SeatA"or"SeatB");local h=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
  if h and seat then pl.Character:PivotTo(seat.CFrame*CFrame.new(0,3,0));boardReconnect:Fire(r.game,r.table.Name,pl);task.delay(.2,function()seat:Sit(h)end);push:FireClient(pl,"matched",{game=r.game,tableName=r.table.Name,code=r.code});return{ok=true,matched=true}end
  return{ok=false,error="Aguarde seu personagem carregar."}
 end
 if r.started or people(r)>=2 or r.matching then return{ok=false,error="Essa sala já iniciou."}end
 r.matching=true
 if r.shared and not arrival then
  local claimed,err=Directory.Claim(r.code,pl,r.token)
  if not claimed then r.matching=false;return{ok=false,error=err}end
 end
 if r.closing or r.started or pl.Parent~=Players then r.matching=false;Directory.Release(pl,r.code,r.token);return{ok=false,error="Sala encerrada."}end
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
 local host=r.owner.Character;local hostHum=host and host:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 or not hostHum or hostHum.Health<=0 then r.matching=false;Directory.Release(pl,r.code,r.token);return{ok=false,error="Aguarde os dois avatares carregarem."}end
 r.players[pl]=true;playerRoom[pl]=r.code;local ok,err=match(r);r.matching=false
 if not ok then r.players[pl]=nil;playerRoom[pl]=nil;Directory.Release(pl,r.code,r.token);return{ok=false,error=err}end
 return{ok=true,code=r.code,game=r.game,matched=true}
end
local function waitingStats()local out={Xadrez=0,Damas=0};for _,r in pairs(rooms)do if not r.started and not r.closing then out[r.game]=(out[r.game]or 0)+1 end end;return out end
local function handle(pl,action,a)
 if action=="arrival"then
  local r,e=Directory.Arrival(pl,rooms);if not r then return{ok=e==nil,error=e}end
  if not pl.Character then pl.CharacterAdded:Wait()end
  local hum=pl.Character and pl.Character:WaitForChild("Humanoid",15);if not hum then return{ok=false,error="Avatar ainda não carregou."}end
  r,e=Directory.Arrival(pl,rooms);if not r then return{ok=false,error=e or"Sala encerrada."}end
  return joinLocal(pl,r,true)
 end
 if action=="stats"then return{ok=true,waiting=waitingStats(),crossServer=Directory.Available()}end
 if action=="create"then
  local room,e=makeRoom(pl,tostring(a),false);if not room then return{ok=false,error=e}end
  return{ok=true,code=room.code,game=room.game,crossServer=room.shared==true}
 end
 if action=="quick"then
  local kind=tostring(a);if roomOf(pl)then return{ok=false,error="Você já está em uma sala."}end
  for _,r in pairs(rooms)do if r.game==kind and r.quick and not r.started and not r.closing and not r.matching and people(r)==1 then return joinLocal(pl,r)end end
  local room,e=makeRoom(pl,kind,true);if not room then return{ok=false,error=e}end
  return{ok=true,code=room.code,game=kind,matched=false,crossServer=room.shared==true}
 end
 if action=="join"then
  if roomOf(pl)then return{ok=false,error="Cancele sua sala antes de entrar em outra."}end
  local code=string.upper(tostring(a or"")):gsub("%s+","")
  if #code~=4 or code:find("[^A-Z2-9]")then return{ok=false,error="Digite o código de quatro caracteres."}end
  local r=rooms[code];if r then return joinLocal(pl,r)end
  local res,err=Directory.Route(pl,code);return res or{ok=false,error=err}
 end
 if action=="leave"or action=="cancel"then Directory.Cancel(pl);local r=roomOf(pl);if r then destroyRoom(r,r.started and 8 or 0)end;return{ok=true}end
 return{ok=false,error="Ação inválida."}
end
local busy,last={},{}
request.OnServerInvoke=function(pl,action,a)
 if type(action)~="string"then return{ok=false,error="Pedido inválido."}end
 if busy[pl]or(last[pl]and os.clock()-last[pl]<.2)then return{ok=false,error="Aguarde um instante."}end
 busy[pl]=true;last[pl]=os.clock();local ok,res=pcall(handle,pl,action,a);busy[pl]=nil
 if not ok then warn("[V42] Sala: "..tostring(res));return{ok=false,error="Não foi possível concluir. Tente novamente."}end
 return res
end
local cupJoin=Instance.new("BindableFunction");cupJoin.Name="ACP_JoinBoardCup";cupJoin.Parent=script.Parent
cupJoin.OnInvoke=function(pl,code)local r=rooms[code];if r and r.allowed and r.allowed[pl.UserId]and roomOf(pl)==r then return{ok=true,code=code}end;return handle(pl,"join",code)end
local cupCreate=Instance.new("BindableFunction");cupCreate.Name="ACP_CreateBoardCup";cupCreate.Parent=script.Parent
local cupActive=Instance.new("BindableFunction");cupActive.Name="ACP_BoardCupActive";cupActive.Parent=script.Parent
cupActive.OnInvoke=function(code)local r=rooms[code];return r and r.cup~=nil and r.started and not r.closing or false end
cupCreate.OnInvoke=function(kind,entry,cup)
 for _,r in pairs(rooms)do if r.cupMatch==entry.id then return{code=r.code}end end
 local owner
 for _,uid in ipairs(entry.players)do local pl=Players:GetPlayerByUserId(uid);if pl and not roomOf(pl)and not pl:GetAttribute("ACP_TrucoRoom")then owner=pl;break end end
 if not owner then return end
 local r=makeRoom(owner,kind,false);if not r then return end
 r.cup=cup;r.cupMatch=entry.id;r.allowed={};for _,uid in ipairs(entry.players)do r.allowed[uid]=true end
 return{code=r.code}
end
local function refresh()
 for _,r in pairs(rooms)do if not r.started and not r.closing then
  if r.expires<=os.time()then destroyRoom(r,0)
  elseif r.shared then local ok=Directory.Refresh(r);if not ok then destroyRoom(r,0)end end
 end end
 task.delay(30,refresh)
end
task.delay(30,refresh)
Players.PlayerRemoving:Connect(function(pl)leaving[pl]=true;busy[pl]=nil;last[pl]=nil;Directory.Forget(pl);local r=roomOf(pl);if r then if r.cup and r.started then playerRoom[pl]=nil else r.players[pl]=nil;playerRoom[pl]=nil;destroyRoom(r,0)end end end)
kit:SetAttribute("ActivitiesReady",true)
print("AVATAR PLAZA V44: salas ocultas dos jogos prontas")
