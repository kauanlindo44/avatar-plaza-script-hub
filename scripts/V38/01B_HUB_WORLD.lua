-- 01B_HUB_WORLD
-- Script | ServerScriptService
-- AVATAR PLAZA V38 - Avatar Field sem centro obrigatório.
-- O mundo inteiro funciona como cenário: campo contínuo, micro-áreas nas bordas e spawn sem monumento/plataforma central.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("CoreReady")do task.wait(.1)end

local world=workspace:WaitForChild("PracaAvatar_V2",20)
if not world then return end
local O=Vector3.new(kit:GetAttribute("OriginX")or 0,kit:GetAttribute("OriginY")or 60,kit:GetAttribute("OriginZ")or 0)

local ground=Instance.new("Folder");ground.Name="AvatarFieldGround";ground.Parent=world
local props=Instance.new("Folder");props.Name="AvatarFieldProps";props.Parent=world
local accents=Instance.new("Folder");accents.Name="AccentThemeParts";accents.Parent=world
local sets=Instance.new("Folder");sets.Name="AvatarFieldSets";sets.Parent=world

local function part(parent,name,size,pos,color,material,collide,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.Position=O+pos;p.Anchored=true
 p.CanCollide=collide~=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=true
 p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end

local G1=Color3.fromRGB(117,185,112)
local G2=Color3.fromRGB(111,179,107)
local G3=Color3.fromRGB(105,173,102)
local slab=Color3.fromRGB(127,132,139)
local panel=Color3.fromRGB(56,59,66)
local soft=Color3.fromRGB(82,86,94)
local warm=Color3.fromRGB(221,188,103)
local cool=Color3.fromRGB(105,200,218)

part(ground,"FieldBase",Vector3.new(820,3,820),Vector3.new(0,-3,0),G3,Enum.Material.SmoothPlastic,true,0)
local tile=50
for r=-7,7 do
 for c=-7,7 do
  local toneId=((r+c)%4==0)and 1 or(((r+c)%2==0)and 2 or 3)
  local tone=toneId==1 and G1 or(toneId==2 and G2 or G3)
  local tilePart=part(ground,string.format("Field_%02d_%02d",r+8,c+8),Vector3.new(tile+.15,2,tile+.15),Vector3.new(c*tile,-1,r*tile),tone,Enum.Material.SmoothPlastic,true,0)
  tilePart:SetAttribute("FieldTone",toneId)
 end
end

for i,v in ipairs({{-230,-120,100,36},{230,118,100,36},{-210,155,76,32},{215,-165,76,32}})do
 local x,z,w,d=v[1],v[2],v[3],v[4]
 part(ground,"SoftPad"..i,Vector3.new(w,1.05,d),Vector3.new(x,.12,z),slab,Enum.Material.SmoothPlastic,true,0)
end

local function lowSet(name,x,z,facing,accent)
 local m=Instance.new("Model");m.Name=name;m.Parent=sets
 part(m,"Floor",Vector3.new(82,1,58),Vector3.new(x,.2,z),Color3.fromRGB(105,109,117),Enum.Material.SmoothPlastic,true,0)
 local signZ=z+facing*26
 part(m,"Back",Vector3.new(74,11,2.5),Vector3.new(x,5.8,signZ),panel,Enum.Material.SmoothPlastic,true,0)
 part(m,"Bench",Vector3.new(30,2.4,6),Vector3.new(x,1.8,z-facing*18),soft,Enum.Material.SmoothPlastic,true,0)
 local line=part(accents,name.."Accent",Vector3.new(56,.22,2),Vector3.new(x,.82,z-facing*26),accent,Enum.Material.Neon,false,.12)
 line:SetAttribute("Themeable",true)
end

lowSet("NorthWestSet",-210,-205,1,cool)
lowSet("NorthEastSet",210,-205,1,warm)
lowSet("SouthWestSet",-210,205,-1,warm)
lowSet("SouthEastSet",210,205,-1,cool)

for i,v in ipairs({{-95,-145,0},{105,-110,90},{-135,95,90},{90,150,0},{-265,30,90},{270,-28,90}})do
 local p=part(props,"SeatBlock"..i,Vector3.new(26,2.4,6),Vector3.new(v[1],1.8,v[2]),soft,Enum.Material.SmoothPlastic,true,0)
 p.CFrame=CFrame.new(O+Vector3.new(v[1],1.8,v[2]))*CFrame.Angles(0,math.rad(v[3]),0)
end

part(ground,"PhotoPad",Vector3.new(64,1.08,46),Vector3.new(-275,.15,-115),Color3.fromRGB(116,121,129),Enum.Material.SmoothPlastic,true,0)
local photoAccent=part(accents,"PhotoAccent",Vector3.new(48,.25,2),Vector3.new(-275,.82,-136),cool,Enum.Material.Neon,false,.10)
photoAccent:SetAttribute("Themeable",true)

local spawn=Instance.new("SpawnLocation")
spawn.Name="SpawnCentral";spawn.Size=Vector3.new(8,1,8);spawn.Position=O+Vector3.new(0,2.5,0)
spawn.Anchored=true;spawn.CanCollide=false;spawn.Transparency=1;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=world

local bounds=Instance.new("Folder");bounds.Name="InvisibleBounds";bounds.Parent=world
local function wall(name,size,pos)
 local p=part(bounds,name,size,pos,Color3.new(),Enum.Material.SmoothPlastic,true,1);p.CanQuery=false
end
wall("North",Vector3.new(740,70,3),Vector3.new(0,35,-370))
wall("South",Vector3.new(740,70,3),Vector3.new(0,35,370))
wall("West",Vector3.new(3,70,740),Vector3.new(-370,35,0))
wall("East",Vector3.new(3,70,740),Vector3.new(370,35,0))

local teleport=kit.Remotes:WaitForChild("HubTeleport")
local last={}
teleport.OnServerEvent:Connect(function(pl,key)
 if os.clock()-(last[pl]or 0)<.8 then return end;last[pl]=os.clock()
 if pl:GetAttribute("ACP_InGameRoom")then return end
 local char=pl.Character;if not char then return end
 local dest=spawn.CFrame*CFrame.new(0,4,0)
 if key=="Photo"then dest=CFrame.new(O+Vector3.new(-275,4,-115))end
 char:PivotTo(dest)
end)
Players.PlayerRemoving:Connect(function(pl)last[pl]=nil end)

task.spawn(function()
 while world.Parent do
  task.wait(1.2)
  for _,pl in ipairs(Players:GetPlayers())do
   if not pl:GetAttribute("ACP_InGameRoom")then
    local char=pl.Character;local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
     local rel=root.Position-O
     if math.abs(rel.X)>385 or math.abs(rel.Z)>385 or rel.Y<-35 then
      char:PivotTo(spawn.CFrame*CFrame.new(0,4,0));root.AssemblyLinearVelocity=Vector3.zero
     end
    end
   end
  end
 end
end)

kit:SetAttribute("BaseReady",true)
print("AVATAR PLAZA V38: Avatar Field sem centro carregado")
