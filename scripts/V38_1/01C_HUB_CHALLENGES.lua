-- 01C_HUB_CHALLENGES
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - salas de jogos realmente ocultas do mapa principal.
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
 else
  local tray=part(m,"PotatoTray",Vector3.new(7,.18,5.5),pos+Vector3.new(0,3.45,0),C.wood);tray:SetAttribute("PotatoBoard",true)
  for i=1,10 do local row=math.floor((i-1)/5);local col=(i-1)%5;local spot=part(m,string.format("PotatoSpot%02d",i),Vector3.new(.9,.08,.9),pos+Vector3.new((col-2)*1.15,3.58,(row-.5)*1.55),C.gold,.75);spot.CanCollide=false;spot:SetAttribute("PotatoIndex",i)end
 end
 return m
end
local old=world:FindFirstChild("ChallengeDistrict")
if old then old:Destroy() end
local district=Instance.new("Folder");district.Name="ChallengeDistrict";district.Parent=world
local pools={Xadrez={},Damas={},Batata={}}
local starts={Xadrez=O+Vector3.new(4200,520,4200),Damas=O+Vector3.new(4200,520,4360),Batata=O+Vector3.new(4200,520,4520)}
for kind,startPos in pairs(starts)do
 local zone=Instance.new("Folder");zone.Name=kind;zone.Parent=district
 for i=1,4 do pools[kind][i]=makeTable(zone,kind,i,startPos+Vector3.new((i-1)*48,0,0))end
end

local rooms={};local playerRoom={};local alphabet="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function code4()local code="";repeat code="";for _=1,4 do local i=math.random(1,#alphabet);code=code..alphabet:sub(i,i)end until not rooms[code];return code end
local function people(room)local n=0;for _ in pairs(room.players)do n=n+1 end;return n end
local function roomOf(pl)return playerRoom[pl]and rooms[playerRoom[pl]]or nil end
local function findFreeTable(kind)for _,t in ipairs(pools[kind]or{})do if not t:GetAttribute("ACP_RoomCode")then return t end end end
local function spawnPos()local sp=world:FindFirstChild("SpawnCentral",true);return sp and sp.CFrame*CFrame.new(0,4,0)or CFrame.new(O+Vector3.new(0,5,0))end
local function clearPlayer(pl)
 playerRoom[pl]=nil;pl:SetAttribute("ACP_InGameRoom",nil);pl:SetAttribute("ACP_GameType",nil);pl:SetAttribute("ACP_RoomCode",nil)
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");if hum then hum.Sit=false end
 if char then task.delay(.1,function()if char.Parent then char:PivotTo(spawnPos())end end)end
end
local function destroyRoom(room,holdSeconds)
 if not room or room.closing then return end;room.closing=true;local heldTable=room.table
 for pl in pairs(room.players)do if pl.Parent==Players then clearPlayer(pl);push:FireClient(pl,"roomClosed")else playerRoom[pl]=nil end end
 rooms[room.code]=nil
 if heldTable then task.delay(holdSeconds or 0,function()if heldTable.Parent then heldTable:SetAttribute("ACP_RoomCode",nil);heldTable:SetAttribute("ACP_RoomOwner",nil)end end)end
end
local function match(room)
 if room.started or people(room)<2 then return false,"Aguardando jogador."end
 local t=findFreeTable(room.game);if not t then return false,"Todas as salas desse jogo estao ocupadas."end
 room.started=true;room.table=t;t:SetAttribute("ACP_RoomCode",room.code);t:SetAttribute("ACP_RoomOwner",room.owner.UserId)
 local ps={};for p in pairs(room.players)do table.insert(ps,p)end;table.sort(ps,function(a,b)return a.UserId<b.UserId end)
 for i,p in ipairs(ps)do
  p:SetAttribute("ACP_InGameRoom",true);p:SetAttribute("ACP_GameType",room.game);p:SetAttribute("ACP_RoomCode",room.code)
  local char=p.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local seat=t:FindFirstChild(i==1 and"SeatA"or"SeatB")
  if char and hum and seat then char:PivotTo(seat.CFrame*CFrame.new(0,3,0));task.wait(.08);seat:Sit(hum)end
 end
 task.wait(.18);for _,p in ipairs(ps)do push:FireClient(p,"matched",{game=room.game,tableName=t.Name,code=room.code})end;return true
end
local function makeRoom(pl,game,quick)
 if not pools[game]then return nil,"Jogo invalido."end;if roomOf(pl)then return nil,"Voce ja esta em uma sala."end
 local room={code=code4(),game=game,owner=pl,players={[pl]=true},quick=quick==true,started=false};rooms[room.code]=room;playerRoom[pl]=room.code;return room
end
local function waitingStats()local out={Xadrez=0,Damas=0,Batata=0};for _,r in pairs(rooms)do if not r.started and not r.closing then out[r.game]=(out[r.game]or 0)+1 end end;return out end
request.OnServerInvoke=function(pl,action,a)
 if action=="stats"then return{ok=true,waiting=waitingStats()}end
 if action=="create"then local room,e=makeRoom(pl,tostring(a),false);if not room then return{ok=false,error=e}end;return{ok=true,code=room.code,game=room.game}end
 if action=="quick"then
  local game=tostring(a);if roomOf(pl)then return{ok=false,error="Voce ja esta em uma sala."}end
  for _,r in pairs(rooms)do if r.game==game and r.quick and not r.started and not r.closing and people(r)==1 then r.players[pl]=true;playerRoom[pl]=r.code;local ok,e=match(r);if not ok then r.players[pl]=nil;playerRoom[pl]=nil;return{ok=false,error=e}end;return{ok=true,code=r.code,game=game,matched=true}end end
  local room,e=makeRoom(pl,game,true);if not room then return{ok=false,error=e}end;return{ok=true,code=room.code,game=game,matched=false}
 end
 if action=="join"then
  local code=string.upper(tostring(a or"")):gsub("%s+","");local r=rooms[code]
  if not r or r.closing then return{ok=false,error="Sala nao encontrada neste servidor."}end;if r.started or people(r)>=2 then return{ok=false,error="Essa sala ja iniciou."}end;if roomOf(pl)then return{ok=false,error="Voce ja esta em uma sala."}end
  r.players[pl]=true;playerRoom[pl]=code;local ok,e=match(r);if not ok then r.players[pl]=nil;playerRoom[pl]=nil;return{ok=false,error=e}end;return{ok=true,code=code,game=r.game,matched=true}
 end
 if action=="leave"or action=="cancel"then local r=roomOf(pl);if not r then return{ok=true}end;destroyRoom(r,r.started and 8 or 0);return{ok=true}end
 return{ok=false,error="Acao invalida."}
end
Players.PlayerRemoving:Connect(function(pl)local r=roomOf(pl);if r then r.players[pl]=nil;playerRoom[pl]=nil;destroyRoom(r,0)end end)
kit:SetAttribute("ActivitiesReady",true)
print("AVATAR PLAZA V38.1: salas ocultas dos jogos prontas")
