-- 07P6_STUDIO_SETS | ModuleScript | ReplicatedStorage | V48
-- Cinco cenarios originais, com camadas e animacao limitada a 20 atualizacoes/s.
local Run=game:GetService("RunService")
local M={}
function M.Build(folder,center,floorY,preset)
 local scene=Instance.new("Model");scene.Name="PhotoScenery";scene.Parent=folder
 local animated={};local time,elapsed=0,0;local S={Alive=true,Animated=true,Count=0}
 local function part(name,size,cf,color,material,shape,parent)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  if shape then p.Shape=shape end;p.Parent=parent or scene;S.Count=S.Count+1;return p
 end
 local function at(x,y,z)return CFrame.new(x,y,z or 0)end
 local function drift(p,phase,amp,rotate,speed)table.insert(animated,{p=p,base=p.CFrame,phase=phase,amp=amp or 1,rotate=rotate,speed=speed or .4})end
 local accent=preset.accent;local dark=preset.b:Lerp(Color3.fromRGB(30,35,49),.32)
 local floor=part("PhotoFloor",Vector3.new(600,.1,600),CFrame.new(center.X,floorY,center.Z),preset.b,nil,nil,folder)
 if preset.id=="SUNSET"then floor.Material=Enum.Material.Glass;floor.Reflectance=.18
 elseif preset.id=="NIGHT"then floor.Material=Enum.Material.Marble;floor.Reflectance=.12 end
 local backdrop=part("Backdrop",Vector3.new(440,340,.3),at(0,0,15),preset.a)
 for i=1,8 do part("SkyLayer",Vector3.new(400,14,.15),at(0,-55+(i-1)*14,14.6),preset.a:Lerp(preset.b,(9-i)/11))end
 local function arch(name,cx,cy,r,z,color,material,segments)
  segments=segments or 20
  for i=0,segments-1 do
   local a=math.pi*i/segments;local p=part(name,Vector3.new(r*math.pi/segments+1,.30,.55),at(cx+math.cos(a)*r,cy+math.sin(a)*r,z)*CFrame.Angles(0,0,a+math.pi/2),color,material)
  end
 end
 local function light(p,color,brightness,range)
  local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness or .8;l.Range=range or 18;l.Shadows=false;l.Parent=p
 end
 if preset.id=="STUDIO"then
  for i=1,3 do arch("GalleryArch",0,-9,12+i*4,-3+i*2,preset.b:Lerp(accent,i/4),Enum.Material.Marble,24)end
  for _,x in ipairs({-21,21})do
   part("GalleryPier",Vector3.new(5,34,5),at(x,3,-1),dark,Enum.Material.Marble)
   local rim=part("GoldenRim",Vector3.new(.18,31,.25),at(x-2,3,-3.6),accent,Enum.Material.Neon);light(rim,accent,.5,24)
   part("GalleryPlinth",Vector3.new(9,3,9),at(x,-11,-1),preset.b,Enum.Material.Marble)
   local globe=part("GallerySculpture",Vector3.new(6,6,6),at(x,15,-2),accent,Enum.Material.Metal,Enum.PartType.Ball);drift(globe,x,.3)
  end
  for i=1,5 do part("GalleryStep",Vector3.new(60-i*4,.65,3),at(0,-12-i*.7,2+i*3),preset.b,Enum.Material.Marble)end
  for i=1,12 do
   local x=-27+i*4.2;local lamp=part("Pendant",Vector3.new(.55,.55,.55),at(x,18+(i%3)*3,-4),accent,Enum.Material.Neon,Enum.PartType.Ball)
   part("PendantCable",Vector3.new(.06,12,.06),at(x,24+(i%3)*3,-4),dark);if i%3==0 then drift(lamp,i,.35)end
  end
  for _,x in ipairs({-14,14})do
   part("GalleryBench",Vector3.new(10,.5,3),at(x,-8,1),preset.b,Enum.Material.Marble)
   for _,off in ipairs({-3,3})do part("BenchFoot",Vector3.new(.5,3,.5),at(x+off,-9.6,1),accent,Enum.Material.Metal)end
  end
 elseif preset.id=="SKY"then
  for i=1,7 do
   local x=-29+i*8;local y=-7+(i%3)*6;local z=-1+(i%2)*5
   local island=part("FloatingIsland",Vector3.new(12,4,7),at(x,y,z),dark,nil,Enum.PartType.Ball)
   part("IslandGarden",Vector3.new(11,.6,7),at(x,y+1.9,z),preset.b,nil,Enum.PartType.Ball)
   for j=1,3 do
    local cloud=part("Cloud",Vector3.new(8+j*2,3+j,5),at(x-4+j*3,y+6+(j%2),z+2),accent,nil,Enum.PartType.Ball)
    if j==2 then drift(cloud,i,.8,false,.20)end
   end
   if i%2==0 then part("SkyTree",Vector3.new(.4,5,.4),at(x,y+4,z-1),dark);part("SkyTreeCrown",Vector3.new(5,4,4),at(x,y+7,z-1),accent:Lerp(preset.b,.4),nil,Enum.PartType.Ball)end
  end
  for band,color in ipairs({Color3.fromRGB(247,184,206),Color3.fromRGB(241,211,164),Color3.fromRGB(179,227,235)})do
   arch("PastelRainbow",2,-8,26+band*1.3,9,color,Enum.Material.Neon,20)
  end
  local sun=part("Sun",Vector3.new(12,12,2),at(-21,22,7),Color3.fromRGB(255,242,199),Enum.Material.Neon,Enum.PartType.Ball)
  arch("SkyHalo",-21,22,9,6,accent,Enum.Material.Neon,24);drift(sun,0,.25)
  for i=1,14 do local p=part("SkySpark",Vector3.new(.16,.16,.16),at(-25+(i*13)%53,3+(i*7)%26,-6),accent,Enum.Material.Neon,Enum.PartType.Ball);if i<=6 then drift(p,i,.9)end end
 elseif preset.id=="SUNSET"then
  local water=part("GoldenWater",Vector3.new(130,.25,45),at(0,-10,0),preset.b,Enum.Material.Glass);water.Reflectance=.28
  part("Sun",Vector3.new(24,24,2),at(-2,9,7),accent,Enum.Material.Neon,Enum.PartType.Ball)
  for i=1,10 do
   local x=-56+i*11;local height=9+(i*7)%16
   part("DistantCoast",Vector3.new(18,height,6),at(x,-5+height/2,10),preset.a:Lerp(dark,.45),nil,Enum.PartType.Ball)
  end
  for i=1,18 do
   local ripple=part("SunReflection",Vector3.new(3+(i%6)*1.6,.025,.07),at(-4+(i%3)*2,-9.85,-11+i*1.5),accent,Enum.Material.Neon)
   if i%3==0 then drift(ripple,i,.02,false,.25)end
  end
  for _,x in ipairs({-23,23})do
   part("CoastTrunk",Vector3.new(.8,23,.8),at(x,1,-3)*CFrame.Angles(0,0,x>0 and -.12 or .12),dark,Enum.Material.Wood)
   for j=1,7 do
    local a=j*math.pi*2/7;part("PalmLeaf",Vector3.new(9,.25,1.3),at(x+math.cos(a)*3,12,-3+math.sin(a)*3)*CFrame.Angles(.13,a,.22),dark)
   end
   local glow=part("CoastLantern",Vector3.new(1.2,1.6,1.2),at(x,-7,-7),accent,Enum.Material.Neon);light(glow,accent,.8,14)
  end
  for i=1,10 do local wave=part("CoastWave",Vector3.new(60-i*3,.025,.22),at(0,-9.83,-14+i*2.5),Color3.fromRGB(251,237,215),Enum.Material.Glass);wave.Transparency=.35 end
  for i=1,4 do part("BeachStone",Vector3.new(4,2,3),at(-30+i*15,-9.4,-8),dark,Enum.Material.Slate,Enum.PartType.Ball)end
 elseif preset.id=="GARDEN"then
  arch("GardenPortal",0,-10,18,3,accent,Enum.Material.Marble,28)
  for _,x in ipairs({-22,22})do
   part("GardenTrunk",Vector3.new(1.7,22,1.7),at(x,1,1),Color3.fromRGB(117,90,90),Enum.Material.Wood)
   for j=1,9 do
    local a=j*2.4;local leaf=part("SakuraCanopy",Vector3.new(10,7,8),at(x+math.cos(a)*6,12+math.sin(a)*3,1+math.sin(a)*3),accent:Lerp(preset.b,(j%3)*.14),nil,Enum.PartType.Ball)
   end
   part("StonePlanter",Vector3.new(9,3,9),at(x,-9,1),preset.b,Enum.Material.Marble)
   local lamp=part("GardenLantern",Vector3.new(2,3,2),at(x*.65,-6,-5),Color3.fromRGB(255,230,185),Enum.Material.Neon);light(lamp,lamp.Color,.6,14)
  end
  for i=1,7 do part("GardenPath",Vector3.new(30-i*1.6,.15,2.2),at(0,-10.4,-6+i*2.9),dark,Enum.Material.Cobblestone)end
  part("ToriiBeam",Vector3.new(32,1.2,2),at(0,17,-1),Color3.fromRGB(118,76,93),Enum.Material.Wood)
  for _,x in ipairs({-13,13})do part("ToriiColumn",Vector3.new(1.2,28,1.2),at(x,3,-1),Color3.fromRGB(133,83,99),Enum.Material.Wood)end
  for i=1,20 do
   local p=part("Petal",Vector3.new(.28,.12,.44),at(-22+(i*17)%44,-2+(i*11)%23,-7+(i%4)*2),Color3.fromRGB(255,200,221))
   drift(p,i,1.4,true,.25)
  end
 else
  for i=1,14 do
   local x=-52+i*7.6;local height=12+(i*11)%34;local z=i%3+5
   part("PrismaTower",Vector3.new(5,height,5),at(x,-12+height/2,z),dark,Enum.Material.Metal)
   for j=1,5 do part("SkylineWindow",Vector3.new(3,.16,.08),at(x,-9+j*(height-3)/5,z-2.6),accent:Lerp(preset.a,(j%3)*.20),Enum.Material.Neon)end
   part("SkylineSpire",Vector3.new(.18,5,.18),at(x,-9+height,z),accent,Enum.Material.Neon)
  end
  for i=1,3 do
   local r=10+i*4;part("NeonGateTop",Vector3.new(r*2,.25,.35),at(0,17+i,-4+i),accent,Enum.Material.Neon)
   for _,x in ipairs({-r,r})do part("NeonGateSide",Vector3.new(.25,31,.35),at(x,2,-4+i),accent,Enum.Material.Neon)end
  end
  for i=1,8 do local rail=part("CityFloorLine",Vector3.new(52,.035,.12),at(0,-12.2,-12+i*3),accent,Enum.Material.Neon);if i%2==0 then drift(rail,i,.01,false,.3)end end
  for i=1,18 do local star=part("CitySpark",Vector3.new(.22,.22,.22),at(-25+(i*17)%53,4+(i*11)%25,-5),accent,Enum.Material.Neon,Enum.PartType.Ball);if i<=6 then drift(star,i,.7)end end
  for _,x in ipairs({-21,21})do
   part("PrismaSign",Vector3.new(8,6,.35),at(x,3,-2),preset.a,Enum.Material.Glass)
   for j=1,3 do part("SignLight",Vector3.new(6,.18,.15),at(x,1+j,-2.2),accent,Enum.Material.Neon)end
  end
  for i=1,7 do part("RoadReflection",Vector3.new(3,.02,1),at(-18+i*5,-12.17,-7),preset.accent,Enum.Material.Glass)end
  part("Moon",Vector3.new(6,6,1),at(18,29,10),Color3.fromRGB(216,233,255),Enum.Material.Neon,Enum.PartType.Ball)
 end
 scene.WorldPivot=CFrame.new()
 function S.Align(cf)if S.Alive and scene.Parent then scene:PivotTo(cf)end end
 function S.SetAnimated(on)S.Animated=on==true end
 S.Connection=Run.RenderStepped:Connect(function(dt)
  if not S.Alive or not S.Animated then return end;time=time+dt;elapsed=elapsed+dt;if elapsed<.05 then return end;elapsed=0
  local cf=scene:GetPivot()
  for _,e in ipairs(animated)do if e.p.Parent then
   local spin=e.rotate and CFrame.Angles(0,time*.3+e.phase,0)or CFrame.new()
   e.p.CFrame=cf*e.base*CFrame.new(math.sin(time*e.speed+e.phase)*e.amp*.6,math.sin(time*e.speed*1.5+e.phase)*e.amp,0)*spin
  end end
 end)
 function S.Destroy()if not S.Alive then return end;S.Alive=false;S.Connection:Disconnect();if scene.Parent then scene:Destroy()end end
 folder.Destroying:Connect(S.Destroy);S.Backdrop=backdrop;S.AnimatedCount=#animated;return S
end
return M
