-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V36D - Catalog Studio Plaza.
-- Praça compacta, cinza/grafite, passarela social, lounges e pórticos; sem clarão branco gigante.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("CoreReady")do task.wait(.1)end

local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end
local O=Vector3.new(kit:GetAttribute("OriginX")or 0,kit:GetAttribute("OriginY")or 60,kit:GetAttribute("OriginZ")or 0)

local ground=Instance.new("Folder")
ground.Name="CatalogStudioGround"
ground.Parent=world

local accents=Instance.new("Folder")
accents.Name="AccentThemeParts"
accents.Parent=world

local structures=Instance.new("Folder")
structures.Name="StudioStructures"
structures.Parent=world

local props=Instance.new("Folder")
props.Name="StudioProps"
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

local function cylinder(parent,name,size,pos,color)
 local p=part(parent,name,size,pos,color,Enum.Material.SmoothPlastic,true,0)
 p.Shape=Enum.PartType.Cylinder
 p.Orientation=Vector3.new(0,0,90)
 return p
end

local graphite=Color3.fromRGB(47,50,59)
local floor2=Color3.fromRGB(57,61,72)
local floor3=Color3.fromRGB(69,73,86)
local white=Color3.fromRGB(211,216,224)
local wall=Color3.fromRGB(126,133,145)
local dark=Color3.fromRGB(31,34,41)
local cyan=Color3.fromRGB(92,205,226)
local lilac=Color3.fromRGB(164,129,231)

part(ground,"MainFloor",Vector3.new(520,4,520),Vector3.new(0,-3,0),graphite,Enum.Material.SmoothPlastic,true,0)
part(ground,"InnerFloor",Vector3.new(360,1,360),Vector3.new(0,-.45,0),floor2,Enum.Material.SmoothPlastic,true,0)
part(ground,"RunwayZ",Vector3.new(42,1.2,326),Vector3.new(0,.15,0),floor3,Enum.Material.SmoothPlastic,true,0)
part(ground,"RunwayX",Vector3.new(326,1.2,42),Vector3.new(0,.15,0),floor3,Enum.Material.SmoothPlastic,true,0)

for _,d in ipairs({
 {"AccentN",Vector3.new(2,.35,324),Vector3.new(-22,.8,0),cyan},
 {"AccentS",Vector3.new(2,.35,324),Vector3.new(22,.8,0),lilac},
 {"AccentW",Vector3.new(324,.35,2),Vector3.new(0,.8,-22),cyan},
 {"AccentE",Vector3.new(324,.35,2),Vector3.new(0,.8,22),lilac}
})do
 local p=part(accents,d[1],d[2],d[3],d[4],Enum.Material.Neon,false,.12)
 p:SetAttribute("Themeable",true)
end

local pads={
 Vector3.new(-112,0,-112),Vector3.new(112,0,-112),
 Vector3.new(-112,0,112),Vector3.new(112,0,112)
}
for i,pos in ipairs(pads)do
 cylinder(ground,"SocialPad"..i,Vector3.new(1.4,82,82),pos+Vector3.new(0,.55,0),i%2==0 and Color3.fromRGB(63,67,79) or Color3.fromRGB(59,64,76))
 local ring=cylinder(accents,"PadRing"..i,Vector3.new(.36,88,88),pos+Vector3.new(0,1.26,0),i%2==0 and lilac or cyan)
 ring.Material=Enum.Material.Neon
 ring.Transparency=.28
 ring:SetAttribute("Themeable",true)
end

local function arch(name,z,accent)
 part(structures,name.."Left",Vector3.new(8,34,8),Vector3.new(-45,15,z),wall,Enum.Material.SmoothPlastic,true,0)
 part(structures,name.."Right",Vector3.new(8,34,8),Vector3.new(45,15,z),wall,Enum.Material.SmoothPlastic,true,0)
 part(structures,name.."Top",Vector3.new(98,7,8),Vector3.new(0,29,z),white,Enum.Material.SmoothPlastic,true,0)
 local strip=part(accents,name.."Glow",Vector3.new(82,.8,1.2),Vector3.new(0,25.2,z-4.4),accent,Enum.Material.Neon,false,.08)
 strip:SetAttribute("Themeable",true)
end
arch("NorthPortal",-178,cyan)
arch("SouthPortal",178,lilac)

for _,side in ipairs({-1,1})do
 local x=side*194
 part(structures,"SideWall"..side,Vector3.new(16,44,286),Vector3.new(x,18,0),dark,Enum.Material.SmoothPlastic,true,0)
 for z=-112,112,56 do
  part(structures,"DisplayFrame"..side.."_"..z,Vector3.new(6,24,38),Vector3.new(x-side*11,10,z),Color3.fromRGB(91,97,111),Enum.Material.SmoothPlastic,true,0)
  local glow=part(accents,"DisplayGlow"..side.."_"..z,Vector3.new(1,18,30),Vector3.new(x-side*14.2,10,z),side==1 and lilac or cyan,Enum.Material.Neon,false,.22)
  glow:SetAttribute("Themeable",true)
 end
end

for i,pos in ipairs(pads)do
 local c=i%2==0 and Color3.fromRGB(91,96,109) or Color3.fromRGB(84,90,103)
 part(props,"BenchA"..i,Vector3.new(28,3,7),pos+Vector3.new(0,2,-27),c,Enum.Material.SmoothPlastic,true,0)
 part(props,"BenchB"..i,Vector3.new(28,3,7),pos+Vector3.new(0,2,27),c,Enum.Material.SmoothPlastic,true,0)
end

for _,z in ipairs({-72,72})do
 part(ground,"PreviewStage"..z,Vector3.new(76,2.2,42),Vector3.new(0,.6,z),Color3.fromRGB(76,80,94),Enum.Material.SmoothPlastic,true,0)
 local edge=part(accents,"PreviewEdge"..z,Vector3.new(68,.45,2),Vector3.new(0,1.95,z+(z>0 and -20 or 20)),z>0 and lilac or cyan,Enum.Material.Neon,false,.1)
 edge:SetAttribute("Themeable",true)
end

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
local function wallPart(name,size,pos)
 local p=part(bounds,name,size,pos,Color3.new(),Enum.Material.SmoothPlastic,true,1)
 p.CanQuery=false
end
wallPart("North",Vector3.new(520,70,3),Vector3.new(0,35,-258))
wallPart("South",Vector3.new(520,70,3),Vector3.new(0,35,258))
wallPart("West",Vector3.new(3,70,520),Vector3.new(-258,35,0))
wallPart("East",Vector3.new(3,70,520),Vector3.new(258,35,0))

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
    if root and root.Position.Y<O.Y-35 then
     char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))
    end
   end
  end
 end
end)

kit:SetAttribute("BaseReady",true)
print("AVATAR PLAZA V36D: Catalog Studio Plaza carregado")
