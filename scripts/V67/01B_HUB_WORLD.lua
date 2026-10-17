-- 01B_HUB_WORLD | Script | ServerScriptService | V67 (SUBSTITUIR)
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

-- Physical chunks are shared; only a 3×3 neighbourhood per active avatar is retained.
local chunks={};local cell=1024
local function ensure(x,z)
 local key=x..':'..z;local p=chunks[key]
 if not p then p=part('GroundChunk_'..key,Vector3.new(cell+.1,2,cell+.1),Vector3.new(x*cell,-1,z*cell),G3,Enum.Material.SmoothPlastic,true,0);p:SetAttribute('FieldTone',3);p.CastShadow=false;chunks[key]=p end
 return key
end
for x=-1,1 do for z=-1,1 do ensure(x,z)end end

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
spawn.CFrame=CFrame.new(O+Vector3.new(0,1.4,0))
spawn.Anchored=true
spawn.CanCollide=true
spawn.CanTouch=false
spawn.Transparency=0;spawn.Color=Color3.fromRGB(227,232,234);spawn.Material=Enum.Material.SmoothPlastic;spawn.CastShadow=false
local decal=Instance.new("Decal");decal.Name="SpawnEmblem";decal.Face=Enum.NormalId.Top;decal.Texture="rbxasset://textures/SpawnLocation.png";decal.Parent=spawn
spawn.Neutral=true
spawn.Duration=0
spawn.Parent=world

-- A localização é explícita: outros spawns do lugar não capturam o reaparecimento.
local function safeHeight(char,root)
 local hum=char:FindFirstChildOfClass('Humanoid');return math.max(5,(hum and hum.HipHeight or 0)+root.Size.Y*.5+1)
end
local function safeCharacter(pl,char)
 task.spawn(function()
  local root=char:WaitForChild('HumanoidRootPart',12)
  if not root or pl.Character~=char or not char.Parent then return end
  local managed=char:GetAttribute('ACP_AvatarManaged')==true
  if not managed or root.Position.Y<O.Y-8 then
   ensure(0,0);char:PivotTo(spawn.CFrame*CFrame.new(0,safeHeight(char,root),0));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
  end
 end)
end
local function playerAdded(pl)
 pl.RespawnLocation=spawn
 pl.CharacterAdded:Connect(function(char)safeCharacter(pl,char)end)
 if pl.Character then safeCharacter(pl,pl.Character)end
end
Players.PlayerAdded:Connect(playerAdded);for _,pl in ipairs(Players:GetPlayers())do playerAdded(pl)end

local teleport=kit.Remotes:WaitForChild("HubTeleport")
local last={}
teleport.OnServerEvent:Connect(function(pl)
 if os.clock()-(last[pl]or 0)<.8 then return end
 last[pl]=os.clock()
 if pl:GetAttribute("ACP_InGameRoom")then return end
 local char=pl.Character
 local root=char and char:FindFirstChild('HumanoidRootPart')
 if root then
  char:PivotTo(spawn.CFrame*CFrame.new(0,safeHeight(char,root),0));root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 end
end)

Players.PlayerRemoving:Connect(function(pl)
 last[pl]=nil
end)

task.spawn(function()
 while world.Parent do
  task.wait(.3)
  local needed={};for x=-1,1 do for z=-1,1 do needed[ensure(x,z)]=true end end
  for _,pl in ipairs(Players:GetPlayers())do
   do
    local char=pl.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
     local rel=root.Position-O
     local x,z=math.floor(rel.X/cell+.5),math.floor(rel.Z/cell+.5)
     for dx=-1,1 do for dz=-1,1 do needed[ensure(x+dx,z+dz)]=true end end
     if rel.Y<-12 then
      char:PivotTo(spawn.CFrame*CFrame.new(0,safeHeight(char,root),0))
      root.AssemblyLinearVelocity=Vector3.zero
      root.AssemblyAngularVelocity=Vector3.zero
     end
    end
   end
  end
  for key,p in pairs(chunks)do if not needed[key]then p:Destroy();chunks[key]=nil end end
 end
end)

kit:SetAttribute("BaseReady",true)
print("[V63 Hub] reaparecimento no SpawnCentral + piso reutilizado")
