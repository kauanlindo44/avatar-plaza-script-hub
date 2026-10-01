-- 01C_HUB_CHALLENGES
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - salas de jogos totalmente ocultas sob o mapa.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("BaseReady")do task.wait(0.1)end

local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end
local O=Vector3.new(
 kit:GetAttribute("OriginX")or 0,
 kit:GetAttribute("OriginY")or 60,
 kit:GetAttribute("OriginZ")or 0
)
local rem=kit:WaitForChild("Remotes")

local function remote(className,name)
 local x=rem:FindFirstChild(name)
 if x and x.ClassName~=className then x:Destroy();x=nil end
 if not x then
  x=Instance.new(className)
  x.Name=name
  x.Parent=rem
 end
 return x
end
local request=remote("RemoteFunction","GameRoomRequest")
local push=remote("RemoteEvent","GameRoomPush")

local function part(parent,name,size,pos)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.Position=pos
 p.Anchored=true
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=false
 p.CastShadow=false
 p.Transparency=1
 p.Parent=parent
 return p
end

local function status(model,pos)
 local anchor=part(model,"StatusAnchor",Vector3.new(0.2,0.2,0.2),pos+Vector3.new(0,7,0))
 local gui=Instance.new("BillboardGui")
 gui.Name="StatusGui"
 gui.Size=UDim2.fromOffset(150,34)
 gui.AlwaysOnTop=false
 gui.Enabled=false
 gui.Parent=anchor
 local label=Instance.new("TextLabel")
 label.Name="StatusLabel"
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text=""
 label.Parent=gui
end

local function makeTable(zone,kind,index,pos)
 local model=Instance.new("Model")
 model.Name=kind..string.format("%02d",index)
 model:SetAttribute("GameType",kind)
 model:SetAttribute("TableIndex",index)
 model.Parent=zone

 part(model,"RoomFloor",Vector3.new(34,1,28),pos+Vector3.new(0,-0.5,0))
 part(model,"Top",Vector3.new(8.6,0.55,8.6),pos+Vector3.new(0,3.1,0))
 for i,z in ipairs({-5.6,5.6})do
  local seat=Instance.new("Seat")
  seat.Name=i==1 and"SeatB"or"SeatA"
  seat.Size=Vector3.new(3,0.55,3)
  seat.Position=pos+Vector3.new(0,1.85,z)
  seat.Anchored=true
  seat.CanCollide=false
  seat.Transparency=1
  seat.CFrame=CFrame.lookAt(seat.Position,pos+Vector3.new(0,1.85,0))
  seat.Parent=model
 end

 local promptPart=part(
  model,"GamePromptPart",Vector3.new(6,3,6),
  pos+Vector3.new(4,3.7,0)
 )
 local prompt=Instance.new("ProximityPrompt")
 prompt.Name="GamePrompt"
 prompt.Enabled=false
 prompt.ActionText="JOGAR"
 prompt.ObjectText=kind
 prompt.RequiresLineOfSight=false
 prompt.Parent=promptPart
 status(model,pos)

 if kind=="Xadrez"or kind=="Damas"then
  local board=Instance.new("Folder")
  board.Name="Board"
  board.Parent=model
  for r=1,8 do
   for c=1,8 do
    local sq=part(
     board,string.format("Square_%d_%d",r,c),
     Vector3.new(0.76,0.08,0.76),
     pos+Vector3.new((c-4.5)*0.76,3.43,(r-4.5)*0.76)
    )
    sq:SetAttribute("Row",r)
    sq:SetAttribute("Col",c)
    sq:SetAttribute("BaseR",0.5)
    sq:SetAttribute("BaseG",0.5)
    sq:SetAttribute("BaseB",0.5)
    sq:SetAttribute("BaseMaterial","SmoothPlastic")
   end
  end
 else
  local tray=part(
   model,"PotatoTray",Vector3.new(7,0.18,5.5),
   pos+Vector3.new(0,3.45,0)
  )
  tray:SetAttribute("PotatoBoard",true)
  for i=1,10 do
   local row=math.floor((i-1)/5)
   local col=(i-1)%5
   local spot=part(
    model,string.format("PotatoSpot%02d",i),
    Vector3.new(0.9,0.08,0.9),
    pos+Vector3.new((col-2)*1.15,3.58,(row-0.5)*1.55)
   )
   spot:SetAttribute("PotatoIndex",i)
  end
 end
 return model
end

local old=world:FindFirstChild("ChallengeDistrict")
if old then old:Destroy()end
local district=Instance.new("Folder")
district.Name="ChallengeDistrict"
district.Parent=world

local pools={Xadrez={},Damas={},Batata={}}
local roomY=O.Y-1400
local starts={
 Xadrez=Vector3.new(O.X-90,roomY,O.Z),
 Damas=Vector3.new(O.X+90,roomY,O.Z),
 Batata=Vector3.new(O.X,roomY,O.Z+120)
}
for kind,startPos in pairs(starts)do
 local zone=Instance.new("Folder")
 zone.Name=kind
 zone.Parent=district
 for i=1,4 do
  pools[kind][i]=makeTable(
   zone,kind,i,startPos+Vector3.new((i-2.5)*40,0,0)
  )
 end
end

local rooms={}
local playerRoom={}
local alphabet="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function code4()
 local code=""
 repeat
  code=""
  for _=1,4 do
   local i=math.random(1,#alphabet)
   code=code..alphabet:sub(i,i)
  end
 until not rooms[code]
 return code
end
local function people(room)
 local n=0
 for _ in pairs(room.players)do n=n+1 end
 return n
end
local function roomOf(pl)
 return playerRoom[pl]and rooms[playerRoom[pl]]or nil
end
local function findFreeTable(kind)
 for _,t in ipairs(pools[kind]or{})do
  if not t:GetAttribute("ACP_RoomCode")then return t end
 end
end
local function spawnPos()
 local sp=world:FindFirstChild("SpawnCentral",true)
 return sp and sp.CFrame*CFrame.new(0,4,0)or CFrame.new(O+Vector3.new(0,5,0))
end
local function clearPlayer(pl)
 playerRoom[pl]=nil
 pl:SetAttribute("ACP_InGameRoom",nil)
 pl:SetAttribute("ACP_GameType",nil)
 pl:SetAttribute("ACP_RoomCode",nil)
 local char=pl.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if hum then hum.Sit=false end
 if char then
  task.delay(0.1,function()
   if char.Parent then char:PivotTo(spawnPos())end
  end)
 end
end
local function destroyRoom(room,holdSeconds)
 if not room or room.closing then return end
 room.closing=true
 local heldTable=room.table
 for pl in pairs(room.players)do
  if pl.Parent==Players then
   clearPlayer(pl)
   push:FireClient(pl,"roomClosed")
  else
   playerRoom[pl]=nil
  end
 end
 rooms[room.code]=nil
 if heldTable then
  task.delay(holdSeconds or 0,function()
   if heldTable.Parent then
    heldTable:SetAttribute("ACP_RoomCode",nil)
    heldTable:SetAttribute("ACP_RoomOwner",nil)
   end
  end)
 end
end
local function match(room)
 if room.started or people(room)<2 then return false,"Aguardando jogador."end
 local tableModel=findFreeTable(room.game)
 if not tableModel then return false,"Todas as salas estao ocupadas."end
 room.started=true
 room.table=tableModel
 tableModel:SetAttribute("ACP_RoomCode",room.code)
 tableModel:SetAttribute("ACP_RoomOwner",room.owner.UserId)
 local ps={}
 for p in pairs(room.players)do table.insert(ps,p)end
 table.sort(ps,function(a,b)return a.UserId<b.UserId end)
 for i,p in ipairs(ps)do
  p:SetAttribute("ACP_InGameRoom",true)
  p:SetAttribute("ACP_GameType",room.game)
  p:SetAttribute("ACP_RoomCode",room.code)
  local char=p.Character
  local hum=char and char:FindFirstChildOfClass("Humanoid")
  local seat=tableModel:FindFirstChild(i==1 and"SeatA"or"SeatB")
  if char and hum and seat then
   char:PivotTo(seat.CFrame*CFrame.new(0,3,0))
   task.wait(0.08)
   seat:Sit(hum)
  end
 end
 task.wait(0.18)
 for _,p in ipairs(ps)do
  push:FireClient(p,"matched",{
   game=room.game,tableName=tableModel.Name,code=room.code
  })
 end
 return true
end
local function makeRoom(pl,game,quick)
 if not pools[game]then return nil,"Jogo invalido."end
 if roomOf(pl)then return nil,"Voce ja esta em uma sala."end
 local room={
  code=code4(),game=game,owner=pl,
  players={[pl]=true},quick=quick==true,started=false
 }
 rooms[room.code]=room
 playerRoom[pl]=room.code
 return room
end
local function waitingStats()
 local out={Xadrez=0,Damas=0,Batata=0}
 for _,room in pairs(rooms)do
  if not room.started and not room.closing then
   out[room.game]=(out[room.game]or 0)+1
  end
 end
 return out
end

request.OnServerInvoke=function(pl,action,arg)
 if action=="stats"then
  return{ok=true,waiting=waitingStats()}
 end
 if action=="create"then
  local room,err=makeRoom(pl,tostring(arg),false)
  if not room then return{ok=false,error=err}end
  return{ok=true,code=room.code,game=room.game}
 end
 if action=="quick"then
  local game=tostring(arg)
  if roomOf(pl)then return{ok=false,error="Voce ja esta em uma sala."}end
  for _,room in pairs(rooms)do
   if room.game==game and room.quick and not room.started and
      not room.closing and people(room)==1 then
    room.players[pl]=true
    playerRoom[pl]=room.code
    local ok,err=match(room)
    if not ok then
     room.players[pl]=nil
     playerRoom[pl]=nil
     return{ok=false,error=err}
    end
    return{ok=true,code=room.code,game=game,matched=true}
   end
  end
  local room,err=makeRoom(pl,game,true)
  if not room then return{ok=false,error=err}end
  return{ok=true,code=room.code,game=game,matched=false}
 end
 if action=="join"then
  local code=string.upper(tostring(arg or"")):gsub("%s+","")
  local room=rooms[code]
  if not room or room.closing then
   return{ok=false,error="Sala nao encontrada neste servidor."}
  end
  if room.started or people(room)>=2 then
   return{ok=false,error="Essa sala ja iniciou."}
  end
  if roomOf(pl)then return{ok=false,error="Voce ja esta em uma sala."}end
  room.players[pl]=true
  playerRoom[pl]=code
  local ok,err=match(room)
  if not ok then
   room.players[pl]=nil
   playerRoom[pl]=nil
   return{ok=false,error=err}
  end
  return{ok=true,code=code,game=room.game,matched=true}
 end
 if action=="leave"or action=="cancel"then
  local room=roomOf(pl)
  if not room then return{ok=true}end
  destroyRoom(room,room.started and 8 or 0)
  return{ok=true}
 end
 return{ok=false,error="Acao invalida."}
end

Players.PlayerRemoving:Connect(function(pl)
 local room=roomOf(pl)
 if room then
  room.players[pl]=nil
  playerRoom[pl]=nil
  destroyRoom(room,0)
 end
end)

kit:SetAttribute("ActivitiesReady",true)
print("AVATAR PLAZA V38.1: salas ocultas sob o mapa prontas")
