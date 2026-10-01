-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - campo aberto; somente um pequeno spawn visivel no centro.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("CoreReady")do task.wait(0.1)end

local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end
local O=Vector3.new(
 kit:GetAttribute("OriginX")or 0,
 kit:GetAttribute("OriginY")or 60,
 kit:GetAttribute("OriginZ")or 0
)

for _,name in ipairs({
 "AvatarFieldGround","AvatarFieldProps","AvatarFieldSets",
 "AccentThemeParts","SpawnPoint","InvisibleBounds"
})do
 local old=world:FindFirstChild(name)
 if old then old:Destroy()end
end

local ground=Instance.new("Folder")
ground.Name="AvatarFieldGround"
ground.Parent=world
local spawnFolder=Instance.new("Folder")
spawnFolder.Name="SpawnPoint"
spawnFolder.Parent=world
local bounds=Instance.new("Folder")
bounds.Name="InvisibleBounds"
bounds.Parent=world

local function part(parent,name,size,pos,color,material,collide,transparency)
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
 p.Parent=parent
 return p
end

local G1=Color3.fromRGB(116,177,145)
local G2=Color3.fromRGB(108,169,138)
local G3=Color3.fromRGB(101,162,131)
local spawnColor=Color3.fromRGB(84,112,109)

part(
 ground,"FieldBase",Vector3.new(840,3,840),
 Vector3.new(0,-3,0),G3,Enum.Material.SmoothPlastic,true,0
)

local tile=60
for r=-6,6 do
 for c=-6,6 do
  local toneId=((r+c)%4==0)and 1 or(((r+c)%2==0)and 2 or 3)
  local tone=toneId==1 and G1 or(toneId==2 and G2 or G3)
  local p=part(
   ground,string.format("Field_%02d_%02d",r+7,c+7),
   Vector3.new(tile+0.12,2,tile+0.12),
   Vector3.new(c*tile,-1,r*tile),tone,
   Enum.Material.SmoothPlastic,true,0
  )
  p:SetAttribute("FieldTone",toneId)
 end
end

-- Unica construcao visivel: pequeno ponto de spawn no centro.
part(
 spawnFolder,"SpawnPad",Vector3.new(18,0.8,18),
 Vector3.new(0,0.45,0),spawnColor,
 Enum.Material.SmoothPlastic,true,0
)

local spawn=Instance.new("SpawnLocation")
spawn.Name="SpawnCentral"
spawn.Size=Vector3.new(7,1,7)
spawn.Position=O+Vector3.new(0,2.1,0)
spawn.Anchored=true
spawn.CanCollide=false
spawn.CanTouch=false
spawn.Transparency=1
spawn.Neutral=true
spawn.Duration=0
spawn.Parent=spawnFolder

local function wall(name,size,pos)
 local p=part(
  bounds,name,size,pos,Color3.new(),
  Enum.Material.SmoothPlastic,true,1
 )
 p.CanQuery=false
end
wall("North",Vector3.new(780,70,3),Vector3.new(0,35,-390))
wall("South",Vector3.new(780,70,3),Vector3.new(0,35,390))
wall("West",Vector3.new(3,70,780),Vector3.new(-390,35,0))
wall("East",Vector3.new(3,70,780),Vector3.new(390,35,0))

local teleport=kit.Remotes:WaitForChild("HubTeleport")
local last={}
teleport.OnServerEvent:Connect(function(pl)
 if os.clock()-(last[pl]or 0)<0.8 then return end
 last[pl]=os.clock()
 if pl:GetAttribute("ACP_InGameRoom")then return end
 local char=pl.Character
 if char then char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))end
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
     if math.abs(rel.X)>405 or math.abs(rel.Z)>405 or rel.Y<-35 then
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
print("AVATAR PLAZA V38.1: campo limpo + spawn pequeno prontos")
