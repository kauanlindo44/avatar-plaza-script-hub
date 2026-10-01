-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - mapa limpo: campo + pequeno spawn central.
-- Nenhuma outra construcao, placa, banco ou set fisico e criado no mapa principal.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")

local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("CoreReady")do task.wait(.1)end

local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end

local O=Vector3.new(
 kit:GetAttribute("OriginX")or 0,
 kit:GetAttribute("OriginY")or 60,
 kit:GetAttribute("OriginZ")or 0
)

local ground=Instance.new("Folder")
ground.Name="AvatarFieldGround"
ground.Parent=world

local function part(name,size,pos,color,material,collide,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.Position=O+pos
 p.Anchored=true
 p.CanCollide=collide~=false
 p.CanTouch=false
 p.CanQuery=transparency~=1
 p.CastShadow=transparency~=1
 p.Color=color
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=ground
 return p
end

local G1=Color3.fromRGB(126,184,121)
local G2=Color3.fromRGB(119,178,116)
local G3=Color3.fromRGB(113,172,111)

part(
 "FieldBase",
 Vector3.new(820,3,820),
 Vector3.new(0,-3,0),
 G3,
 Enum.Material.SmoothPlastic,
 true,
 0
)

local tile=50
for r=-7,7 do
 for c=-7,7 do
  local toneId=((r+c)%4==0)and 1 or(((r+c)%2==0)and 2 or 3)
  local tone=toneId==1 and G1 or(toneId==2 and G2 or G3)
  local p=part(
   string.format("Field_%02d_%02d",r+8,c+8),
   Vector3.new(tile+.12,2,tile+.12),
   Vector3.new(c*tile,-1,r*tile),
   tone,
   Enum.Material.SmoothPlastic,
   true,
   0
  )
  p:SetAttribute("FieldTone",toneId)
 end
end

local spawnPad=part(
 "SpawnPad",
 Vector3.new(20,.7,20),
 Vector3.new(0,.35,0),
 Color3.fromRGB(83,112,105),
 Enum.Material.SmoothPlastic,
 true,
 0
)
spawnPad.CastShadow=false

local spawn=Instance.new("SpawnLocation")
spawn.Name="SpawnCentral"
spawn.Size=Vector3.new(7,1,7)
spawn.Position=O+Vector3.new(0,1.4,0)
spawn.Anchored=true
spawn.CanCollide=false
spawn.CanTouch=false
spawn.Transparency=1
spawn.Neutral=true
spawn.Duration=0
spawn.Parent=world

local bounds=Instance.new("Folder")
bounds.Name="InvisibleBounds"
bounds.Parent=world

local function wall(name,size,pos)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.Position=O+pos
 p.Anchored=true
 p.CanCollide=true
 p.CanTouch=false
 p.CanQuery=false
 p.Transparency=1
 p.Parent=bounds
end

wall("North",Vector3.new(740,70,3),Vector3.new(0,35,-370))
wall("South",Vector3.new(740,70,3),Vector3.new(0,35,370))
wall("West",Vector3.new(3,70,740),Vector3.new(-370,35,0))
wall("East",Vector3.new(3,70,740),Vector3.new(370,35,0))

local teleport=kit.Remotes:WaitForChild("HubTeleport")
local last={}
teleport.OnServerEvent:Connect(function(pl)
 if os.clock()-(last[pl]or 0)<.8 then return end
 last[pl]=os.clock()
 if pl:GetAttribute("ACP_InGameRoom")then return end
 local char=pl.Character
 if char then
  char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
 end
end)

Players.PlayerRemoving:Connect(function(pl)
 last[pl]=nil
end)

task.spawn(function()
 while world.Parent do
  task.wait(1.2)
  for _,pl in ipairs(Players:GetPlayers())do
   if not pl:GetAttribute("ACP_InGameRoom")then
    local char=pl.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
     local rel=root.Position-O
     if math.abs(rel.X)>385 or math.abs(rel.Z)>385 or rel.Y<-35 then
      char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
      root.AssemblyLinearVelocity=Vector3.zero
      root.AssemblyAngularVelocity=Vector3.zero
     end
    end
   end
  end
 end
end)

kit:SetAttribute("BaseReady",true)
print("AVATAR PLAZA V38.1: campo limpo + spawn central carregado")
