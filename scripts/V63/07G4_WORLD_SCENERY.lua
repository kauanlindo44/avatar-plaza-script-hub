-- 07G4_WORLD_SCENERY | ModuleScript | ReplicatedStorage | V63 (SUBSTITUIR)
-- Seis paisagens ao ar livre, com composição original, materiais e partes limitadas.
local Rep=game:GetService('ReplicatedStorage');local Details=require(Rep:WaitForChild('07G6_WORLD_DETAILS'));local M={Version='V63',Budget=720}
function M.Build(id,center,part,alive)
 local count=0
 local function p(name,x,y,z,w,h,d,color,material,rotation,shape)
  if count>=M.Budget or alive and not alive()then return nil end;count=count+1
  if count%24==0 then task.wait();if alive and not alive()then return nil end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,material)
  if rotation then o.Orientation=typeof(rotation)=='Vector3'and rotation or Vector3.new(0,rotation,0)end
  if name:find('Water')or name:find('Ripple')then o.Transparency=.22;o.Reflectance=.12 end
  return o
 end
 local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
 local wood=rgb(98,71,59);local dark=rgb(49,49,66);local stone=rgb(145,151,143);local cream=rgb(232,216,187)
 local function rock(x,z,s,color)
  p('WeatheredRock',x,s*.28,z,s,s*.65,s*.8,color or stone,Enum.Material.Rock,(x+z)%180,Enum.PartType.Ball)
  p('RockFacet',x+s*.15,s*.47,z-s*.1,s*.8,s*.5,s*.55,(color or stone):Lerp(rgb(255,255,255),.07),Enum.Material.Slate,Vector3.new(12,(x+z)%90,18),'Wedge')
 end
 local function tree(x,z,s,kind)
  p('TreeTrunk',x,9*s,z,2*s,18*s,2*s,wood,Enum.Material.Wood)
  p('TreeBranch',x+3*s,16*s,z,9*s,1.1*s,1.1*s,wood,Enum.Material.Wood,Vector3.new(0,30,24))
  if kind=='pine'then
   for j=1,3 do p('PineCanopy',x,(15+j*5)*s,z,(22-j*4)*s,10*s,(22-j*4)*s,rgb(65+j*8,104+j*6,98+j*4),Enum.Material.LeafyGrass,nil,Enum.PartType.Ball)end
  else
   for j=1,4 do local a=j*math.pi*.5;local col=kind=='sakura'and(j%2==0 and rgb(244,183,208)or rgb(255,211,225))or kind=='autumn'and(j%2==0 and rgb(164,97,47)or rgb(130,77,60))or rgb(94+j*6,139+j*5,104+j*3)
    p(kind=='sakura'and'SakuraBlossoms'or'TreeCanopy',x+math.cos(a)*5*s,(20+j%2*2)*s,z+math.sin(a)*5*s,13*s,9*s,13*s,col,Enum.Material.LeafyGrass,nil,Enum.PartType.Ball)
   end
  end
 end
 local function lantern(x,z,color)
  p('LanternFoot',x,.5,z,3,1,3,stone,Enum.Material.Cobblestone);p('LanternPost',x,6,z,.8,12,.8,wood,Enum.Material.Wood)
  p('LanternGlow',x,11,z,2.7,3.4,2.7,color,Enum.Material.Neon);p('LanternCap',x,13.2,z,4.8,.8,4.8,dark,Enum.Material.Slate)
 end
 local function steps(x,z,length,width)
  for i=1,length do p('PathStone',x+math.sin(i*.7)*2,.12,z+i*12,width,.24,8,rgb(157+i%3*8,151+i%3*7,134+i%3*8),Enum.Material.Cobblestone,i%3*8)end
 end
 local function hills(color)
  for i=1,8 do local a=i*math.pi/4;local x,z=math.cos(a)*720,math.sin(a)*720
   p('DistantMountain',x,34,z,230,85+i%3*20,180,color,Enum.Material.Rock,Vector3.new(0,i*45,8),'Wedge')
   p('MountainRidge',x+70,48,z+45,160,110,140,color:Lerp(rgb(230,235,243),.14),Enum.Material.Slate,Vector3.new(0,i*45+60,0),'Wedge')
  end
 end
 if id=='ANIME'then
  steps(0,38,18,19);steps(0,-300,16,19)
  p('KoiWater',-190,.04,50,126,.12,104,rgb(107,170,166),Enum.Material.Glass,nil,Enum.PartType.Ball)
  for i=1,16 do local a=i*math.pi/8;rock(-190+math.cos(a)*67,50+math.sin(a)*56,6,rgb(139,152,143))end
  for i=-5,5 do p('ArchedBridgePlanks',-190+i*5,2+math.cos(i*.22)*4,50,5.2,1,22,wood,Enum.Material.WoodPlanks)
   for _,z in ipairs({38,62})do p('BridgeBaluster',-190+i*5,7,z,.6,7,.6,wood,Enum.Material.Wood)end
  end
  for _,z in ipairs({-250,250})do
   for _,x in ipairs({-20,20})do p('ShrineGateColumn',x,16,z,3,32,3,rgb(165,68,65),Enum.Material.Wood)end
   p('ShrineGateCrossbeam',0,31,z,52,3,5,rgb(171,68,62),Enum.Material.Wood);p('ShrineGateCap',0,34,z,60,3,6,dark,Enum.Material.Slate)
  end
  p('OpenTeaPavilionFloor',180,.7,75,52,1.4,52,wood,Enum.Material.WoodPlanks)
  for _,x in ipairs({160,200})do for _,z in ipairs({55,95})do p('PavilionColumn',x,13,z,2,26,2,wood,Enum.Material.Wood)end end
  for _,side in ipairs({-1,1})do p('PavilionRoofTiles',180+side*14,27,75,31,2,62,rgb(68,82,99),Enum.Material.Slate,Vector3.new(0,0,-side*15))end
  p('PavilionRoofRidge',180,31,75,2,2,64,dark,Enum.Material.Slate)
  for i=1,10 do local a=i*math.pi/5;tree(math.cos(a)*310,math.sin(a)*290,1+i%3*.16,'sakura');lantern(math.cos(a)*82,math.sin(a)*82,rgb(246,204,143))end
  for i=1,5 do p('PondRipple',-190,.17,20+i*11,80,.04,.5,rgb(202,222,201),Enum.Material.Glass)end
  hills(rgb(138,171,175))
 elseif id=='FOREST'then
  p('ForestLakeWater',220,.03,120,224,.08,196,rgb(75,117,139),Enum.Material.Glass,nil,Enum.PartType.Ball)
  for i=1,16 do local a=i*math.pi/8;rock(220+math.cos(a)*117,120+math.sin(a)*102,9,rgb(109,135,141))end
  for i=1,5 do p('MoonlitRipple',220,.15,60+i*19,140,.03,1,rgb(145,191,203),Enum.Material.Glass)end
  for i=1,20 do local a=i*2.399963;tree(math.cos(a)*(165+i%5*40),math.sin(a)*(165+i%5*40),1+i%3*.22,'pine')end
  steps(0,-240,16,17)
  for i=1,8 do local a=i*math.pi/4;p('LuminousForestStone',math.cos(a)*100,1,math.sin(a)*100,5,2.2,4,rgb(133,172,204),Enum.Material.Neon,a*90,Enum.PartType.Ball)end
  p('ForestWaterfallRock',340,15,200,65,32,52,rgb(109,130,140),Enum.Material.Rock,20,'Wedge')
  p('Waterfall',340,14,174,22,28,.7,rgb(153,201,211),Enum.Material.Glass)
  hills(rgb(91,116,143))
 elseif id=='COAST'then
  p('OceanWater',0,-.12,650,2100,.22,800,rgb(75,155,175),Enum.Material.Glass)
  for i=1,8 do p('CoastRipple',0,.13,275+i*40,1900,.05,1.7,i%2==0 and rgb(179,221,220)or rgb(126,192,204),Enum.Material.Glass)end
  p('WeatheredPier',0,.25,348,24,.5,230,rgb(165,128,91),Enum.Material.WoodPlanks)
  for i=1,10 do for _,x in ipairs({-12,12})do p('PierPost',x,3,242+i*22,1,6,1,wood,Enum.Material.Wood)end end
  for i=1,12 do local a=i*math.pi/6;local x,z=math.cos(a)*250,math.sin(a)*180
   p('PalmTrunk',x,12,z,1.8,24,1.8,rgb(156,116,76),Enum.Material.Wood,Vector3.new(0,0,6))
   for j=1,5 do p('PalmLeaf',x,25,z,25,.8,4,rgb(82,143,108),Enum.Material.LeafyGrass,Vector3.new(0,j*72,12))end
  end
  for i=1,7 do rock(-390+i*42,-180,12+i%3*4,rgb(188,173,150))end
  for i=-2,2 do local x=i*60;p('BeachCanvasPole',x,6,165,.7,12,.7,cream,Enum.Material.Wood)
   p('BeachCanvas',x,12.5,165,21,1,20,i%2==0 and rgb(221,157,115)or rgb(145,185,169),Enum.Material.Fabric,Vector3.new(0,0,5))
   p('WovenBeachMat',x,.1,179,11,.2,18,cream,Enum.Material.Fabric)
  end
  for i=1,4 do p('CoastalDune',-500+i*240,.4,-360,180,2,110,rgb(223,204,166),Enum.Material.Sand,i*14,Enum.PartType.Ball)end
 elseif id=='HALLOWEEN'then
  steps(0,-250,34,20)
  for i=1,14 do local a=i*2.399963;tree(math.cos(a)*(150+i%4*50),math.sin(a)*(150+i%4*50),1+i%3*.16,'autumn')end
  for i=1,12 do local a=i*math.pi/6;local x,z=math.cos(a)*110,math.sin(a)*110
   p('Pumpkin',x,2,z,5,4,5,rgb(218,126+i%3*9,47),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)
   p('PumpkinStem',x,4.3,z,.8,1.8,.8,wood,Enum.Material.Wood)
   for _,dx in ipairs({-1,1})do p('PumpkinEyeGlow',x+dx,2.7,z-2.2,.7,.7,.2,rgb(255,205,108),Enum.Material.Neon)end
   p('PumpkinMouthGlow',x,1.4,z-2.3,1.8,.35,.2,rgb(255,205,108),Enum.Material.Neon)
  end
  for i=1,8 do local a=i*math.pi/4;lantern(math.cos(a)*70,math.sin(a)*70,rgb(237,170,85))end
  p('MoonGardenArchBeam',0,26,230,72,4,6,rgb(105,97,120),Enum.Material.Slate)
  for _,x in ipairs({-33,33})do p('MoonGardenArchColumn',x,12,230,4,24,5,rgb(105,97,120),Enum.Material.Slate)end
  for i=1,10 do rock(-240+i*45,290,9,rgb(99,99,113))end
  p('MoonGardenWater',-220,.06,-90,100,.12,90,rgb(89,88,133),Enum.Material.Glass,nil,Enum.PartType.Ball)
  hills(rgb(85,86,113))
 elseif id=='CLOUD'then
  steps(0,-230,34,22)
  for i=1,6 do local a=i*math.pi/3;local x,z=math.cos(a)*230,math.sin(a)*230
   for _,dx in ipairs({-15,15})do p('SkyGardenMarbleColumn',x+dx,15,z,3,30,3,rgb(235,235,224),Enum.Material.Marble)end
   p('SkyGardenArch',x,31,z,39,4,6,rgb(225,226,220),Enum.Material.Marble);p('SkyGardenGoldTrim',x,33.1,z,38,.3,5,rgb(197,178,117),Enum.Material.Metal)
   p('SkyGardenHedge',x,3,z+23,45,6,12,rgb(139,181,167),Enum.Material.LeafyGrass,nil,Enum.PartType.Ball)
  end
  p('SkyGardenWater',0,.05,220,100,.1,95,rgb(144,191,212),Enum.Material.Glass,nil,Enum.PartType.Ball)
  for i=1,10 do local a=i*math.pi/5;rock(math.cos(a)*340,math.sin(a)*340,25,rgb(201,210,216))end
  hills(rgb(196,213,225))
 else
  steps(0,-200,30,16)
  for i=1,16 do local a=i*2.399963;tree(math.cos(a)*(210+i%4*45),math.sin(a)*(210+i%4*45),1+i%3*.12,'green')end
  for i=1,8 do local a=i*math.pi/4;rock(math.cos(a)*140,math.sin(a)*140,6)end
  hills(rgb(150,179,158))
 end
 Details.Detail(id,p);return count
end
function M.Floor(folder,center,color,material)
 local Run=game:GetService('RunService');local pl=game:GetService('Players').LocalPlayer;local tiles={};local tick=0;local cell=2048
 for i=1,25 do local p=Instance.new('Part');p.Name='InfiniteVisualGround';p.Size=Vector3.new(cell,.06,cell);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color;p.Parent=folder;tiles[i]=p end
 local lastX,lastZ
 local function update()
  local root=pl.Character and pl.Character:FindFirstChild('HumanoidRootPart');local pos=root and root.Position or center
  local x,z=math.floor((pos.X-center.X)/cell+.5),math.floor((pos.Z-center.Z)/cell+.5);if x==lastX and z==lastZ then return end;lastX,lastZ=x,z
  for i,p in ipairs(tiles)do p.Position=center+Vector3.new((x+(i-1)%5-2)*cell,.04,(z+math.floor((i-1)/5)-2)*cell)end
 end
 update();local connection=Run.Heartbeat:Connect(function(dt)tick=tick+dt;if tick<.25 then return end;tick=0;update()end)
 return function()connection:Disconnect();for _,p in ipairs(tiles)do p:Destroy()end end
end
return M
