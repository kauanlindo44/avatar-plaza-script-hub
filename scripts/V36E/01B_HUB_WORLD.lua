-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V36E - Catalog Field.
-- Inspirado na linguagem visual do Catalog Avatar Creator: campo verde quadriculado,
-- céu aberto, área social simples e estúdios baixos. Não copia assets nem o mapa exato.

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
ground.Name="CatalogFieldGround"
ground.Parent=world

local accents=Instance.new("Folder")
accents.Name="AccentThemeParts"
accents.Parent=world

local structures=Instance.new("Folder")
structures.Name="CatalogFieldStructures"
structures.Parent=world

local props=Instance.new("Folder")
props.Name="CatalogFieldProps"
props.Parent=world

local function part(parent,name,size,pos,color,material,collide,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.Position=O+pos
 p.Anchored=true
 p.CanCollide=collide~=false
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=true
 p.Color=color
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent
 return p
end

local greenA=Color3.fromRGB(78,165,72)
local greenB=Color3.fromRGB(87,178,79)
local dark=Color3.fromRGB(43,45,51)
local mid=Color3.fromRGB(74,78,86)
local cyan=Color3.fromRGB(78,206,224)

part(
 ground,"Backdrop",
 Vector3.new(780,3,780),
 Vector3.new(0,-3,0),
 greenA,Enum.Material.SmoothPlastic,true,0
)

local tileSize=56
for r=-5,5 do
 for c=-5,5 do
  local col=((r+c)%2==0)and greenA or greenB
  local tile=part(
   ground,
   string.format("Grid_%02d_%02d",r+6,c+6),
   Vector3.new(tileSize+.25,2,tileSize+.25),
   Vector3.new(c*tileSize,-1,r*tileSize),
   col,Enum.Material.SmoothPlastic,true,0
  )
  tile:SetAttribute("Tone",(r+c)%2)
 end
end

part(
 ground,"SocialPad",
 Vector3.new(120,1.2,96),
 Vector3.new(0,.2,0),
 Color3.fromRGB(126,132,141),
 Enum.Material.Concrete,true,0
)
part(
 ground,"SocialInner",
 Vector3.new(96,1.35,72),
 Vector3.new(0,.32,0),
 Color3.fromRGB(91,96,105),
 Enum.Material.SmoothPlastic,true,0
)

local pads={
 {-150,-118},
 {150,-118},
 {-150,118},
 {150,118}
}
for i,v in ipairs(pads)do
 local x,z=v[1],v[2]
 part(
  ground,"Pad"..i,
  Vector3.new(88,1.1,66),
  Vector3.new(x,.15,z),
  Color3.fromRGB(105,111,121),
  Enum.Material.Concrete,true,0
 )
 local glow=part(
  accents,"PadGlow"..i,
  Vector3.new(78,.28,3),
  Vector3.new(x,.82,z-29),
  cyan,Enum.Material.Neon,false,.08
 )
 glow:SetAttribute("Themeable",true)
end

local studios={
 {-235,-165,0},
 {235,-165,180},
 {-235,165,0},
 {235,165,180}
}
for i,v in ipairs(studios)do
 local x,z,rotation=v[1],v[2],v[3]
 local model=Instance.new("Model")
 model.Name="Studio"..i
 model.Parent=structures

 part(
  model,"Floor",
  Vector3.new(92,1.2,64),
  Vector3.new(x,.3,z),
  Color3.fromRGB(62,66,74),
  Enum.Material.SmoothPlastic,true,0
 )

 part(
  model,"Back",
  Vector3.new(92,30,4),
  Vector3.new(x,14.8,z+(rotation==0 and 30 or -30)),
  dark,Enum.Material.SmoothPlastic,true,0
 )

 part(
  model,"Left",
  Vector3.new(4,24,60),
  Vector3.new(x-44,11.8,z),
  mid,Enum.Material.SmoothPlastic,true,0
 )

 part(
  model,"Right",
  Vector3.new(4,24,60),
  Vector3.new(x+44,11.8,z),
  mid,Enum.Material.SmoothPlastic,true,0
 )

 local glow=part(
  accents,"StudioGlow"..i,
  Vector3.new(70,.4,3),
  Vector3.new(x,1,z+(rotation==0 and -29 or 29)),
  cyan,Enum.Material.Neon,false,.12
 )
 glow:SetAttribute("Themeable",true)
end

for _,z in ipairs({-45,45})do
 part(
  props,"BenchA"..z,
  Vector3.new(30,2.8,6),
  Vector3.new(-36,2,z),
  Color3.fromRGB(66,69,76),
  Enum.Material.SmoothPlastic,true,0
 )
 part(
  props,"BenchB"..z,
  Vector3.new(30,2.8,6),
  Vector3.new(36,2,z),
  Color3.fromRGB(66,69,76),
  Enum.Material.SmoothPlastic,true,0
 )
end

part(
 ground,"PhotoPad",
 Vector3.new(62,1.25,48),
 Vector3.new(0,.28,-150),
 Color3.fromRGB(92,98,108),
 Enum.Material.SmoothPlastic,true,0
)
local photoGlow=part(
 accents,"PhotoGlow",
 Vector3.new(52,.3,3),
 Vector3.new(0,.95,-171),
 cyan,Enum.Material.Neon,false,.05
)
photoGlow:SetAttribute("Themeable",true)

local spawn=Instance.new("SpawnLocation")
spawn.Name="SpawnCentral"
spawn.Size=Vector3.new(8,1,8)
spawn.Position=O+Vector3.new(0,3,0)
spawn.Anchored=true
spawn.CanCollide=false
spawn.Transparency=1
spawn.Neutral=true
spawn.Duration=0
spawn.Parent=world

local bounds=Instance.new("Folder")
bounds.Name="InvisibleBounds"
bounds.Parent=world

local function wall(name,size,pos)
 local p=part(
  bounds,name,size,pos,
  Color3.new(),Enum.Material.SmoothPlastic,true,1
 )
 p.CanQuery=false
end

wall("North",Vector3.new(630,70,3),Vector3.new(0,35,-315))
wall("South",Vector3.new(630,70,3),Vector3.new(0,35,315))
wall("West",Vector3.new(3,70,630),Vector3.new(-315,35,0))
wall("East",Vector3.new(3,70,630),Vector3.new(315,35,0))

local teleport=kit.Remotes:WaitForChild("HubTeleport")
teleport.OnServerEvent:Connect(function(pl,key)
 local char=pl.Character
 if not char or pl:GetAttribute("ACP_InGameRoom")then return end
 local dest=spawn.CFrame*CFrame.new(0,4,0)
 if key=="Photo"then
  dest=CFrame.new(O+Vector3.new(0,5,-150))
 end
 char:PivotTo(dest)
end)

task.spawn(function()
 while world.Parent do
  task.wait(1)
  for _,pl in ipairs(Players:GetPlayers())do
   if not pl:GetAttribute("ACP_InGameRoom")then
    local char=pl.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y<O.Y-35 then
     char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
    end
   end
  end
 end
end)

kit:SetAttribute("BaseReady",true)
print("AVATAR PLAZA V36E: Catalog Field carregado")
