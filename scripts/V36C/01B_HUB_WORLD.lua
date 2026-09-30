-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V36C - mapa mais bonito, claro e simples no estilo Avatar Catalog.
-- Sem centro pesado; foco em piso bonito, leitura limpa e espaço para a skin aparecer.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("CoreReady")do task.wait(.1)end
local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end
local O=Vector3.new(kit:GetAttribute("OriginX")or 0,kit:GetAttribute("OriginY")or 60,kit:GetAttribute("OriginZ")or 0)

local ground=Instance.new("Folder")
ground.Name="AvatarWorldGround"
ground.Parent=world

local function p(name,size,pos,color,material,transparency,parent)
 local x=Instance.new("Part")
 x.Name=name
 x.Size=size
 x.Position=O+pos
 x.Anchored=true
 x.CanCollide=true
 x.CanTouch=false
 x.CanQuery=true
 x.CastShadow=false
 x.Color=color
 x.Material=material or Enum.Material.SmoothPlastic
 x.Transparency=transparency or 0
 x.TopSurface=Enum.SurfaceType.Smooth
 x.BottomSurface=Enum.SurfaceType.Smooth
 x.Parent=parent or ground
 return x
end

local function decoCylinder(name,size,pos,color,parent)
 local x=p(name,size,pos,color,Enum.Material.SmoothPlastic,0,parent)
 x.Shape=Enum.PartType.Cylinder
 x.Orientation=Vector3.new(0,0,90)
 return x
end

local palette={
 Color3.fromRGB(177,230,235),
 Color3.fromRGB(170,221,234),
 Color3.fromRGB(176,232,221),
 Color3.fromRGB(187,224,240),
 Color3.fromRGB(165,227,214)
}

p("Backdrop",Vector3.new(1250,2,1250),Vector3.new(0,-2.15,0),Color3.fromRGB(177,228,232),Enum.Material.SmoothPlastic,0)

local tileSize=68
for r=-4,4 do
 for c=-4,4 do
  local col=palette[((r*2+c*3)%#palette)+1]
  local tone=((r+c)%3)-1
  p(string.format("Tile_%02d_%02d",r+5,c+5),Vector3.new(tileSize+.25,2,tileSize+.25),Vector3.new(c*tileSize,-1,r*tileSize),col:Lerp(Color3.new(1,1,1),tone==1 and .06 or 0),Enum.Material.SmoothPlastic,0)
 end
end

local lanes=Instance.new("Folder")
lanes.Name="AccentLanes"
lanes.Parent=world
p("MainLaneX",Vector3.new(700,.3,24),Vector3.new(0,.02,0),Color3.fromRGB(205,241,244),Enum.Material.Neon,.15,lanes)
p("MainLaneZ",Vector3.new(24,.3,700),Vector3.new(0,.02,0),Color3.fromRGB(205,241,244),Enum.Material.Neon,.15,lanes)
p("SoftLaneNorth",Vector3.new(560,.3,18),Vector3.new(0,.02,-136),Color3.fromRGB(222,247,238),Enum.Material.Neon,.2,lanes)
p("SoftLaneSouth",Vector3.new(560,.3,18),Vector3.new(0,.02,136),Color3.fromRGB(222,247,238),Enum.Material.Neon,.2,lanes)
p("SoftLaneWest",Vector3.new(18,.3,560),Vector3.new(-136,.02,0),Color3.fromRGB(216,236,248),Enum.Material.Neon,.2,lanes)
p("SoftLaneEast",Vector3.new(18,.3,560),Vector3.new(136,.02,0),Color3.fromRGB(216,236,248),Enum.Material.Neon,.2,lanes)

local pads=Instance.new("Folder")
pads.Name="SocialPads"
pads.Parent=world
local padData={
 {"NorthPad",Vector3.new(0,-.45,-184),Color3.fromRGB(190,229,241)},
 {"SouthPad",Vector3.new(0,-.45,184),Color3.fromRGB(182,233,223)},
 {"WestPad",Vector3.new(-184,-.45,0),Color3.fromRGB(178,224,236)},
 {"EastPad",Vector3.new(184,-.45,0),Color3.fromRGB(194,233,246)}
}
for _,d in ipairs(padData)do
 p(d[1],Vector3.new(116,1.2,116),d[2],d[3],Enum.Material.SmoothPlastic,0,pads)
 p(d[1].."Inner",Vector3.new(84,1.35,84),d[2]+Vector3.new(0,.11,0),d[3]:Lerp(Color3.new(1,1,1),.12),Enum.Material.SmoothPlastic,0,pads)
 decoCylinder(d[1].."Disc",Vector3.new(1.1,40,40),d[2]+Vector3.new(0,.45,0),d[3]:Lerp(Color3.fromRGB(255,255,255),.22),pads)
end

local edges=Instance.new("Folder")
edges.Name="VisualEdges"
edges.Parent=world
for i,off in ipairs({-255,255})do
 p("EdgeX"..i,Vector3.new(10,1,520),Vector3.new(off,-.8,0),Color3.fromRGB(200,232,241),Enum.Material.SmoothPlastic,0,edges)
 p("EdgeZ"..i,Vector3.new(520,1,10),Vector3.new(0,-.8,off),Color3.fromRGB(200,232,241),Enum.Material.SmoothPlastic,0,edges)
end

local spawn=Instance.new("SpawnLocation")
spawn.Name="SpawnCentral"
spawn.Size=Vector3.new(8,1,8)
spawn.Position=O+Vector3.new(0,1.5,0)
spawn.Anchored=true
spawn.CanCollide=false
spawn.Transparency=1
spawn.Neutral=true
spawn.Duration=0
spawn.Parent=world

local walls=Instance.new("Folder")
walls.Name="InvisibleBounds"
walls.Parent=world
local function wall(name,size,pos)
 local x=Instance.new("Part")
 x.Name=name
 x.Size=size
 x.Position=O+pos
 x.Anchored=true
 x.CanCollide=true
 x.CanTouch=false
 x.CanQuery=false
 x.Transparency=1
 x.Parent=walls
end
wall("North",Vector3.new(640,80,3),Vector3.new(0,38,-320))
wall("South",Vector3.new(640,80,3),Vector3.new(0,38,320))
wall("West",Vector3.new(3,80,640),Vector3.new(-320,38,0))
wall("East",Vector3.new(3,80,640),Vector3.new(320,38,0))

local teleport=kit.Remotes:WaitForChild("HubTeleport")
teleport.OnServerEvent:Connect(function(pl)
 local char=pl.Character
 if char and not pl:GetAttribute("ACP_InGameRoom")then
  char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
 end
end)

task.spawn(function()
 while world.Parent do
  task.wait(1)
  for _,pl in ipairs(Players:GetPlayers())do
   if not pl:GetAttribute("ACP_InGameRoom")then
    local char=pl.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y<O.Y-30 then
     char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
    end
   end
  end
 end
end)

kit:SetAttribute("BaseReady",true)
print("AVATAR PLAZA V36C: Avatar World claro e estilizado carregado")
