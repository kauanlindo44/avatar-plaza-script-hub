-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V37 - Catalog Field refinado, mais intencional e menos saturado.
-- Inspirado na sensação do Catalog Avatar Creator: campo verde, pads claros,
-- estações abertas e mapa social mais preenchido, sem copiar assets/mapa exato.

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

local greenA=Color3.fromRGB(118,193,111)
local greenB=Color3.fromRGB(107,184,102)
local greenC=Color3.fromRGB(99,174,95)
local dark=Color3.fromRGB(37,40,48)
local mid=Color3.fromRGB(67,72,82)
local light=Color3.fromRGB(128,134,144)
local concrete=Color3.fromRGB(150,156,164)
local gold=Color3.fromRGB(233,188,73)
local cyan=Color3.fromRGB(97,219,233)

part(ground,"Backdrop",Vector3.new(860,3,860),Vector3.new(0,-3,0),greenC,Enum.Material.SmoothPlastic,true,0)

local tileSize=52
for r=-6,6 do
 for c=-6,6 do
  local tone=((r+c)%3==0)and greenA or((r+c)%2==0 and greenB or greenC)
  part(ground,string.format("Grid_%02d_%02d",r+7,c+7),Vector3.new(tileSize+.2,2,tileSize+.2),Vector3.new(c*tileSize,-1,r*tileSize),tone,Enum.Material.SmoothPlastic,true,0)
 end
end

local function slab(name,size,pos,color,material)
 return part(ground,name,size,pos,color,material or Enum.Material.Concrete,true,0)
end

-- Centro mais estruturado.
slab("SocialOuter",Vector3.new(166,1.2,128),Vector3.new(0,.2,0),concrete)
slab("SocialInner",Vector3.new(130,1.3,94),Vector3.new(0,.3,0),light,Enum.Material.SmoothPlastic)
slab("RunwayNorth",Vector3.new(54,1.12,16),Vector3.new(0,.25,-37),Color3.fromRGB(118,123,133))
slab("RunwaySouth",Vector3.new(54,1.12,16),Vector3.new(0,.25,37),Color3.fromRGB(118,123,133))

for _,z in ipairs({-54,54})do
 part(props,"BenchA"..z,Vector3.new(28,2.6,6),Vector3.new(-44,2,z),mid,Enum.Material.SmoothPlastic,true,0)
 part(props,"BenchB"..z,Vector3.new(28,2.6,6),Vector3.new(44,2,z),mid,Enum.Material.SmoothPlastic,true,0)
end
for i,v in ipairs({{-64,-38},{64,-38},{-64,38},{64,38}})do
 local ped=part(props,"AvatarPedestal"..i,Vector3.new(18,1.2,18),Vector3.new(v[1],1,v[2]),Color3.fromRGB(124,129,138),Enum.Material.SmoothPlastic,true,0)
 local rim=part(accents,"PedestalGlow"..i,Vector3.new(14,.22,2),Vector3.new(v[1],1.7,v[2]-8),i%2==0 and cyan or gold,Enum.Material.Neon,false,.12);rim:SetAttribute("Themeable",true)
end

-- Caminhos principais para lembrar o fluxo do CAC.
for i,info in ipairs({
 {"NorthPath",Vector3.new(58,1.05,92),Vector3.new(0,.14,-104)},
 {"SouthPath",Vector3.new(58,1.05,92),Vector3.new(0,.14,104)},
 {"WestPath",Vector3.new(110,1.05,42),Vector3.new(-138,.14,0)},
 {"EastPath",Vector3.new(110,1.05,42),Vector3.new(138,.14,0)}
})do
 slab(info[1],info[2],info[3],Color3.fromRGB(111,116,125))
end

local function addStation(i,x,z,kind)
 slab("Pad"..i,Vector3.new(94,1.12,70),Vector3.new(x,.16,z),Color3.fromRGB(116,121,131))
 local glow=part(accents,"PadGlow"..i,Vector3.new(82,.26,3),Vector3.new(x,.82,z-31),gold,Enum.Material.Neon,false,.06)
 glow:SetAttribute("Themeable",true)
 local model=Instance.new("Model")
 model.Name="Station"..i
 model.Parent=structures
 part(model,"Rear",Vector3.new(88,16,3),Vector3.new(x,8.4,z+30),dark,Enum.Material.SmoothPlastic,true,0)
 part(model,"Left",Vector3.new(3,14,58),Vector3.new(x-42,7.4,z),mid,Enum.Material.SmoothPlastic,true,0)
 part(model,"Right",Vector3.new(3,14,58),Vector3.new(x+42,7.4,z),mid,Enum.Material.SmoothPlastic,true,0)
 if kind=="preview"then
  part(model,"Counter",Vector3.new(34,3,8),Vector3.new(x,2,z+18),Color3.fromRGB(77,82,92),Enum.Material.SmoothPlastic,true,0)
 else
  part(model,"Accent",Vector3.new(38,2,6),Vector3.new(x,2,z+18),Color3.fromRGB(91,96,105),Enum.Material.SmoothPlastic,true,0)
 end
end

addStation(1,-170,-126,"preview")
addStation(2,170,-126,"preview")
addStation(3,-170,126,"social")
addStation(4,170,126,"social")

-- Pads extras mais discretos no perímetro para preencher o vazio.
for i,v in ipairs({{-254,-42},{254,-42},{-254,42},{254,42}})do
 slab("MiniPad"..i,Vector3.new(74,1,52),Vector3.new(v[1],.12,v[2]),Color3.fromRGB(109,114,122))
 local rail=part(props,"MiniRail"..i,Vector3.new(60,2.2,5),Vector3.new(v[1],2,v[2]+20),mid,Enum.Material.SmoothPlastic,true,0)
 rail:SetAttribute("Themeable",false)
end

-- Núcleos baixos no fundo para profundidade sem virar um bloco gigante.
for i,v in ipairs({{-258,-188,1},{258,-188,1},{-258,188,-1},{258,188,-1}})do
 local x,z,side=v[1],v[2],v[3]
 local m=Instance.new("Model")
 m.Name="BackdropStudio"..i
 m.Parent=structures
 part(m,"Floor",Vector3.new(104,1.1,76),Vector3.new(x,.2,z),Color3.fromRGB(79,84,94),Enum.Material.SmoothPlastic,true,0)
 part(m,"Back",Vector3.new(104,28,4),Vector3.new(x,14,z+side*35),dark,Enum.Material.SmoothPlastic,true,0)
 part(m,"Wing",Vector3.new(4,24,52),Vector3.new(x-side*47,12,z+10),mid,Enum.Material.SmoothPlastic,true,0)
 local glow=part(accents,"BackdropGlow"..i,Vector3.new(64,.35,3),Vector3.new(x,.8,z-side*31),cyan,Enum.Material.Neon,false,.10)
 glow:SetAttribute("Themeable",true)
end

slab("PhotoPad",Vector3.new(72,1.15,52),Vector3.new(0,.22,-188),Color3.fromRGB(118,123,132),Enum.Material.SmoothPlastic)
local photoGlow=part(accents,"PhotoGlow",Vector3.new(56,.28,3),Vector3.new(0,.9,-213),cyan,Enum.Material.Neon,false,.06)
photoGlow:SetAttribute("Themeable",true)
slab("MusicPad",Vector3.new(66,1.15,46),Vector3.new(0,.22,188),Color3.fromRGB(118,123,132),Enum.Material.SmoothPlastic)
local musicGlow=part(accents,"MusicGlow",Vector3.new(52,.28,3),Vector3.new(0,.9,211),gold,Enum.Material.Neon,false,.08)
musicGlow:SetAttribute("Themeable",true)

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
 local p=part(bounds,name,size,pos,Color3.new(),Enum.Material.SmoothPlastic,true,1)
 p.CanQuery=false
end
wall("North",Vector3.new(690,70,3),Vector3.new(0,35,-345))
wall("South",Vector3.new(690,70,3),Vector3.new(0,35,345))
wall("West",Vector3.new(3,70,690),Vector3.new(-345,35,0))
wall("East",Vector3.new(3,70,690),Vector3.new(345,35,0))

local teleport=kit.Remotes:WaitForChild("HubTeleport")
teleport.OnServerEvent:Connect(function(pl,key)
 local char=pl.Character
 if not char or pl:GetAttribute("ACP_InGameRoom")then return end
 local dest=spawn.CFrame*CFrame.new(0,4,0)
 if key=="Photo"then dest=CFrame.new(O+Vector3.new(0,5,-188)) end
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
print("AVATAR PLAZA V37: Catalog Field refinado carregado")
