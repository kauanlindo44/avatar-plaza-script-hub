-- 07G4_WORLD_SCENERY | ModuleScript | ReplicatedStorage | V62 (SUBSTITUIR)
-- Cenários originais locais, com construção em lotes e limite de partes por tema.
local M={Version='V62',Budget=640}
function M.Build(id,center,part,alive)
 local count=0;local decorations={}
 local function p(name,x,y,z,w,h,d,color,material,rotation,shape)
  if count>=M.Budget or alive and not alive()then return nil end;count=count+1
  if count%32==0 then task.wait();if alive and not alive()then return nil end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,material)
  if rotation then o.Orientation=typeof(rotation)=='Vector3'and rotation or Vector3.new(0,rotation,0)end;return o
 end
 local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
 local wood=rgb(95,66,58);local cream=rgb(236,216,183);local dark=rgb(43,41,60);local gold=rgb(237,185,92)
 local function lamp(x,z,color,tag)
  p((tag or'Lantern')..'Post',x,6,z,.65,12,.65,wood,Enum.Material.Wood)
  p((tag or'Lantern')..'Crown',x,12.8,z,4.5,.7,4.5,dark,Enum.Material.Slate)
  p((tag or'Lantern')..'Glow',x,11,z,2.7,3,2.7,color,Enum.Material.Neon)
  p((tag or'Lantern')..'Base',x,.5,z,3,1,3,wood,Enum.Material.Wood)
 end
 local function sakura(x,z,scale)
  local a=scale or 1;p('SakuraTrunk',x,8*a,z,2*a,16*a,2*a,wood,Enum.Material.Wood)
  for i=1,3 do p('SakuraBranch',x+(i-2)*3*a,15*a,z,9*a,1.3*a,1.3*a,wood,Enum.Material.Wood,Vector3.new(0,i*55,(i-2)*28))end
  for i=1,5 do local angle=i*math.pi*2/5;p('SakuraBlossom',x+math.cos(angle)*6*a,(19+i%2*2)*a,z+math.sin(angle)*5*a,12*a,8*a,12*a,i%2==0 and rgb(240,177,197)or rgb(255,215,225),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)end
 end
 local function house(x,z,index)
  local roof=rgb(63,78,108);p('AnimeVillageHouse',x,12,z,32,24,32,cream,Enum.Material.Wood)
  p('RaisedFoundation',x,1,z,35,2,35,rgb(146,138,126),Enum.Material.Cobblestone)
  for _,dx in ipairs({-15,0,15})do p('TimberFacade',x+dx,12,z-16.2,1.3,24,.6,wood,Enum.Material.Wood)end
  for _,y in ipairs({5,18,23})do p('TimberBeam',x,y,z-16.7,32,1.2,.6,wood,Enum.Material.Wood)end
  for _,dx in ipairs({-8,8})do
   p('PaperWindow',x+dx,13,z-16.9,8,9,.4,rgb(240,218,161),Enum.Material.SmoothPlastic)
   p('WindowMullion',x+dx,13,z-17.2,.45,9,.3,wood,Enum.Material.Wood);p('WindowCrossbar',x+dx,13,z-17.3,8,.45,.3,wood,Enum.Material.Wood)
  end
  p('WoodenDoor',x,6,z-17.5,6,12,.7,wood,Enum.Material.WoodPlanks)
  for i=1,2 do p('EntryStep',x,i*.5,z-19-i,10,i,2.3,rgb(161,151,135),Enum.Material.Cobblestone)end
  p('RoofTileLeft',x-9,27,z,20,2.4,39,roof,Enum.Material.Slate,Vector3.new(0,0,14))
  p('RoofTileRight',x+9,27,z,20,2.4,39,roof,Enum.Material.Slate,Vector3.new(0,0,-14))
  p('RoofRidge',x,30,z,2.5,2.5,42,roof,Enum.Material.Slate)
  p('Awning',x,16,z-20,13,1.2,8,index%2==0 and rgb(159,91,96)or rgb(94,130,124),Enum.Material.Fabric)
 end
 local function palm(x,z)
  p('PalmTrunk',x,10,z,1.7,20,1.7,rgb(145,109,74),Enum.Material.Wood,Vector3.new(0,0,7))
  for i=1,5 do p('PalmFrond',x,21,z,22,.65,3.5,rgb(73,134,109),Enum.Material.Grass,Vector3.new(0,i*72,9))end
  for i=1,3 do p('Coconut',x+math.cos(i)*1.2,19.5,z+math.sin(i)*1.2,1.5,1.5,1.5,rgb(121,87,53),Enum.Material.Wood,nil,Enum.PartType.Ball)end
 end
 if id=='ANIME'then
  p('VillageMainPath',0,.08,0,24,.16,640,rgb(187,177,157),Enum.Material.Cobblestone);p('VillageCrossPath',0,.08,40,600,.16,20,rgb(187,177,157),Enum.Material.Cobblestone)
  for _,side in ipairs({-1,1})do for i=1,6 do house(side*(78+i%2*50),(i-3.5)*72,i);if i%2==0 then lamp(side*42,(i-3.5)*72,gold,'PaperLantern')end end end
  for _,z in ipairs({-280,280})do
   for _,x in ipairs({-18,18})do p('ToriiColumn',x,16,z,3.5,32,3.5,rgb(172,71,71),Enum.Material.Wood)end
   p('ToriiBeam',0,30,z,48,3,5,rgb(180,74,70),Enum.Material.Wood);p('ToriiCap',0,34,z,54,3,7,dark,Enum.Material.Slate)
   for i=-3,3 do p('ToriiRope',i*5,26,z,.7,.8,1.2,gold,Enum.Material.Fabric)end
  end
  for level=1,4 do local width=70-level*10;local y=level*17
   p('PagodaLevel',0,y+5,340,width,14,width,cream,Enum.Material.Wood)
   p('PagodaEave',0,y+14,340,width+16,3,width+16,dark,Enum.Material.Slate)
   for _,dx in ipairs({-width/2+2,width/2-2})do p('PagodaColumn',dx,y+6,340-width/2-1,2,14,2,wood,Enum.Material.Wood)end
   for i=-1,1 do p('PagodaWindow',i*8,y+8,340-width/2-.2,5,7,.4,gold,Enum.Material.SmoothPlastic)end
  end
  p('DojoPlatform',225,1,45,72,2,72,wood,Enum.Material.WoodPlanks)
  for _,x in ipairs({198,252})do for _,z in ipairs({18,72})do p('DojoColumn',x,15,z,2.7,28,2.7,wood,Enum.Material.Wood)end end
  p('DojoRoof',225,30,45,80,4,80,dark,Enum.Material.Slate)
  p('KoiPond',-235,.08,40,75,.15,105,rgb(100,157,155),Enum.Material.Glass,nil,Enum.PartType.Ball)
  for i=1,12 do local angle=i*math.pi/6;p('PondStone',-235+math.cos(angle)*39,1,40+math.sin(angle)*52,7,3,7,rgb(145,152,145),Enum.Material.Rock,angle*180/math.pi,Enum.PartType.Ball)end
  for i=-4,4 do p('BridgeDeck',-235+i*4,3+math.cos(i*.28)*3,40,4.5,1.2,17,wood,Enum.Material.WoodPlanks)
   for _,z in ipairs({31,49})do p('BridgeRailPost',-235+i*4,8,z,.6,6,.6,wood,Enum.Material.Wood)end
  end
  for i=1,12 do local a=i*math.pi/6;sakura(math.cos(a)*315,math.sin(a)*300,1+i%3*.18)end
  for i=1,8 do local a=i*math.pi/4;p('AnimeMountain',math.cos(a)*670,38,math.sin(a)*670,170,90+i%3*25,170,rgb(125,155,175),Enum.Material.Rock,a*180/math.pi,Enum.PartType.Ball)end
 elseif id=='NEON'then
  for _,x in ipairs({-120,120})do
   p('NeonAvenue',x,.1,0,40,.2,690,rgb(30,34,47),Enum.Material.Asphalt)
   for i=-5,5 do p('RoadCenterMark',x,.24,i*55,1,.08,18,rgb(191,183,138),Enum.Material.SmoothPlastic)end
   for i=-3,3 do local z=i*82;local bx=x+(x>0 and 62 or-62);local h=65+(i+3)%4*18
    p('CityTower',bx,h/2,z,42,h,40,rgb(40,42,63),Enum.Material.Slate)
    p('TowerCornice',bx,h,z,47,2,45,rgb(63,61,87),Enum.Material.Metal)
    p('NeonVerticalTrim',bx-20.5,h/2,z-20.6,.5,h,.5,i%2==0 and rgb(156,132,245)or rgb(92,205,214),Enum.Material.Neon)
    for floor=1,5 do for col=-1,1 do p('OfficeWindow',bx+col*11,floor*11,z-20.3,6,5,.4,(floor+col)%3==0 and rgb(143,117,203)or rgb(105,167,184),Enum.Material.Neon)end end
    p('StorefrontGlass',bx,7,z-20.8,32,11,.5,rgb(62,99,120),Enum.Material.Glass)
    p('StoreAwning',bx,14,z-24,37,1.2,8,rgb(102,91,149),Enum.Material.Metal)
   end
  end
  for i=-4,4 do lamp(-30,i*72,rgb(130,177,239),'Streetlight');lamp(30,i*72,rgb(174,137,225),'Streetlight')end
  p('CentralFountainBasin',0,.7,115,1.4,40,40,rgb(76,79,107),Enum.Material.Marble,Vector3.new(0,0,90),Enum.PartType.Cylinder)
  for i=1,8 do local a=i*math.pi/4;p('FountainStream',math.cos(a)*9,4,115+math.sin(a)*9,1.1,6,1.1,rgb(101,185,213),Enum.Material.Glass)end
  for _,x in ipairs({-60,60})do p('PedestrianBench',x,2,40,18,1.2,5,rgb(79,78,106),Enum.Material.Metal);p('BenchBack',x,4,42,18,4,.7,rgb(79,78,106),Enum.Material.Metal)end
  p('TransitArch',0,30,-270,80,5,8,rgb(145,133,218),Enum.Material.Neon)
  for _,x in ipairs({-38,38})do p('TransitColumn',x,15,-270,4,30,4,rgb(59,61,88),Enum.Material.Metal)end
 elseif id=='COAST'then
  p('Ocean',0,-.3,550,2000,.4,550,rgb(72,152,171),Enum.Material.Glass)
  for i=1,6 do p('OceanWave',0,.15,300+i*38,1800,.18,2.3,i%2==0 and rgb(176,213,213)or rgb(118,186,189),Enum.Material.Glass)end
  p('Boardwalk',0,.4,215,560,.8,26,rgb(174,135,92),Enum.Material.WoodPlanks)
  for i=-6,6 do p('BoardwalkPost',i*40,3,228,1,6,1,wood,Enum.Material.Wood)end;p('BoardwalkRail',0,5,228,560,.8,.8,wood,Enum.Material.Wood)
  p('Pier',0,1,345,26,2,240,rgb(157,122,83),Enum.Material.WoodPlanks)
  for i=1,10 do for _,x in ipairs({-13,13})do p('PierPost',x,4,245+i*22,1.2,8,1.2,wood,Enum.Material.Wood)end end
  for i=-3,3 do local x=i*55
   p('SunUmbrellaPole',x,6,168,.7,12,.7,cream,Enum.Material.Wood)
   p('SunUmbrella',x,13,168,23,1.5,23,i%2==0 and rgb(214,157,137)or rgb(144,186,173),Enum.Material.Fabric)
   p('BeachLounger',x,1.7,180,8,1.4,14,cream,Enum.Material.Wood);p('LoungerCushion',x,2.6,179,6,.8,10,rgb(210,186,157),Enum.Material.Fabric)
  end
  for _,x in ipairs({-210,210})do for i=-2,3 do palm(x,i*66)end end
  for i=1,3 do local x=-310+i*75
   p('BeachCabana',x,8,-90,32,16,27,rgb(224,207,169),Enum.Material.WoodPlanks);p('CabanaRoof',x,18,-90,38,4,34,rgb(133,153,142),Enum.Material.Wood)
   p('CabanaWindow',x,10,-104,11,7,.4,rgb(140,195,197),Enum.Material.Glass);p('CabanaDoor',x+10,5,-104,5,10,.6,wood,Enum.Material.Wood)
  end
  for i=1,12 do p('CoastStone',-350+i*60,1,-200,12+i%3*4,5,10,rgb(167,159,139),Enum.Material.Rock,i*19,Enum.PartType.Ball)end
 elseif id=='HALLOWEEN'then
  p('MoonGardenPath',0,.08,0,24,.16,670,rgb(79,72,91),Enum.Material.Cobblestone)
  for _,x in ipairs({-175,175})do
   p('HauntedHouse',x,24,215,68,48,60,rgb(72,61,83),Enum.Material.WoodPlanks)
   p('HauntedRoofLeft',x-19,54,215,42,4,72,dark,Enum.Material.Slate,Vector3.new(0,0,24));p('HauntedRoofRight',x+19,54,215,42,4,72,dark,Enum.Material.Slate,Vector3.new(0,0,-24))
   p('HouseTower',x+23,51,238,19,72,19,rgb(60,53,76),Enum.Material.Wood);p('TowerRoof',x+23,90,238,26,7,26,dark,Enum.Material.Slate)
   for _,dx in ipairs({-22,0,22})do for _,y in ipairs({16,34})do p('HalloweenWindow',x+dx,y,184.7,9,13,.4,gold,Enum.Material.Neon);p('GothicWindowCross',x+dx,y,184.4,.7,13,.6,dark,Enum.Material.Wood);p('WindowBar',x+dx,y,184.3,9,.7,.7,dark,Enum.Material.Wood)end end
   p('HauntedDoor',x,8,184,8,16,.7,dark,Enum.Material.Wood)
   for i=1,3 do p('PorchStep',x,i*.5,177-i*2,22,i,2.3,rgb(111,100,115),Enum.Material.Cobblestone)end
  end
  for i=-8,8 do p('IronFencePost',i*24,6,-250,.7,12,.7,rgb(65,60,76),Enum.Material.Metal);p('IronFenceRail',i*24,7,-250,24,.7,.7,rgb(65,60,76),Enum.Material.Metal)end
  for i=1,16 do local angle=i*math.pi/8;local x,z=math.cos(angle)*290,math.sin(angle)*280
   p('BareTreeTrunk',x,13,z,3,26,3,rgb(65,53,68),Enum.Material.Wood,Vector3.new(0,0,i%2==0 and 8 or-8))
   for j=1,3 do p('TwistedBranch',x+3,13+j*4,z,14,1.4,1.4,rgb(65,53,68),Enum.Material.Wood,Vector3.new(0,i*21,28+j*9))end
   local px,pz=x*.7,z*.7
   for j=-1,1 do p('PumpkinLobe',px+j*1.8,3,pz,5,6,5,rgb(202,107,48),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)end
   p('PumpkinStem',px,6.6,pz,.8,2,.8,rgb(87,101,57),Enum.Material.Wood)
   for _,dx in ipairs({-1.3,1.3})do p('PumpkinEye',px+dx,3.6,pz-2.7,.8,.8,.3,gold,Enum.Material.Neon,Vector3.new(0,0,45))end
   p('PumpkinSmile',px,2.4,pz-2.8,2.8,.5,.3,gold,Enum.Material.Neon)
  end
  for i=-4,4 do lamp(i%2==0 and-28 or 28,i*53,gold,'MoonLantern')end
  p('MoonPond',-90,.08,-85,45,.15,55,rgb(93,100,132),Enum.Material.Glass,nil,Enum.PartType.Ball)
 elseif id=='CLOUD'then
  p('CloudMarblePath',0,.08,0,22,.16,560,rgb(225,230,240),Enum.Material.Marble)
  for i=1,8 do local a=i*math.pi/4;local x,z=math.cos(a)*275,math.sin(a)*275
   p('FloatingGarden',x,10+i%3*8,z,52,8,45,rgb(154,184,165),Enum.Material.Grass,nil,Enum.PartType.Ball)
   for _,dx in ipairs({-18,18})do p('CloudArchColumn',x+dx,38+i%3*8,z,3,40,3,cream,Enum.Material.Marble)end
   p('CloudArchTop',x,60+i%3*8,z,44,5,8,rgb(222,229,245),Enum.Material.Marble)
   for j=-2,2 do p('CloudPuff',x+j*9,24+i%3*8,z+12,26,12,24,rgb(241,247,255),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)end
  end
  for _,x in ipairs({-100,100})do
   p('CloudGardenBase',x,1,0,56,2,94,rgb(193,210,200),Enum.Material.Grass)
   for i=-3,3 do p('GardenFlower',x+i%2*10,3,i*11,4,4,4,i%2==0 and rgb(233,193,212)or rgb(182,174,233),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)end
  end
  for i=1,7 do p('CloudStep',0,1+i*.15,70+i*15,30,1.5,13,cream,Enum.Material.Marble)end
  p('HorizonHalo',0,120,420,4,95,95,rgb(223,203,142),Enum.Material.Neon,Vector3.new(0,0,90),Enum.PartType.Cylinder)
  for _,x in ipairs({-145,145})do
   p('ReflectingPool',x,.12,85,48,.2,62,rgb(143,196,203),Enum.Material.Glass)
   for i=-3,3 do for _,z in ipairs({53,117})do p('PoolMarbleEdge',x+i*7,1,z,7.2,1.4,3,cream,Enum.Material.Marble)end end
   for _,dx in ipairs({-26,26})do p('PoolSideEdge',x+dx,1,85,3,1.4,68,cream,Enum.Material.Marble)end
   p('GardenPavilionRoof',x,25,-75,54,3,54,rgb(194,213,231),Enum.Material.Marble)
   for _,dx in ipairs({-22,22})do for _,z in ipairs({-97,-53})do
    p('FlutedPavilionColumn',x+dx,13,z,2.8,24,2.8,cream,Enum.Material.Marble)
    p('ColumnCapital',x+dx,25,z,5,2,5,rgb(219,207,173),Enum.Material.Marble)
    p('ColumnPlinth',x+dx,1,z,5,2,5,cream,Enum.Material.Marble)
   end end
   for i=-2,2 do p('PavilionGardenPetal',x+i*8,3,-110,5,4,5,rgb(222,184,215),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)end
  end
 end
 return count
end
function M.Floor(folder,center,color,material)
 local Run=game:GetService('RunService');local pl=game:GetService('Players').LocalPlayer;local tiles={};local tick=0;local cell=2048
 for i=1,25 do local p=Instance.new('Part');p.Name='InfiniteVisualGround';p.Size=Vector3.new(cell+.1,.06,cell+.1);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color;p.Parent=folder;tiles[i]=p end
 local lastX,lastZ
 local function update()
  local root=pl.Character and pl.Character:FindFirstChild('HumanoidRootPart');local pos=root and root.Position or center
  local x,z=math.floor((pos.X-center.X)/cell+.5),math.floor((pos.Z-center.Z)/cell+.5);if x==lastX and z==lastZ then return end;lastX,lastZ=x,z
  for i,p in ipairs(tiles)do p.Position=center+Vector3.new((x+(i-1)%5-2)*cell,-.04,(z+math.floor((i-1)/5)-2)*cell)end
 end
 update();local connection=Run.Heartbeat:Connect(function(dt)tick=tick+dt;if tick<.25 then return end;tick=0;update()end)
 return function()connection:Disconnect();for _,p in ipairs(tiles)do p:Destroy()end end
end
return M
