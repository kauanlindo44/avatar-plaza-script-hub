-- 07G4_WORLD_SCENERY | ModuleScript | ReplicatedStorage | V61 (NOVO)
-- Arquitetura temática original, limitada e local; nenhum asset executável externo.
local M={}
function M.Build(id,center,part)
 local function p(name,x,y,z,w,h,d,color,material,angle,shape)
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,material);if angle then o.Orientation=Vector3.new(0,angle,0)end;return o
 end
 local wood=Color3.fromRGB(94,62,55);local roof=Color3.fromRGB(58,75,105);local cream=Color3.fromRGB(239,219,182)
 if id=='ANIME'then
  p('VillagePath',0,.08,0,24,.08,680,Color3.fromRGB(188,177,153),Enum.Material.Cobblestone)
  p('VillageCrossPath',0,.08,0,680,.08,24,Color3.fromRGB(188,177,153),Enum.Material.Cobblestone)
  for i=1,12 do
   local side=i%2==0 and 1 or-1;local x=side*(88+(i%3)*46);local z=(math.floor((i-1)/2)-2.5)*76;local h=20+i%3*8
   p('AnimeVillageHouse',x,h/2,z,35,h,32,cream,Enum.Material.Wood)
   p('TieredRoof',x,h+3,z,43,5,40,roof,Enum.Material.Slate)
   p('AnimeWindow',x-8,h*.6,z-16.2,9,8,.3,Color3.fromRGB(222,186,98),Enum.Material.Neon)
   p('AnimeWindow',x+8,h*.6,z-16.2,9,8,.3,Color3.fromRGB(222,186,98),Enum.Material.Neon)
   p('TimberDoor',x,6,z-16.5,6,12,.5,wood,Enum.Material.Wood)
   for _,dx in ipairs({-18,18})do p('HouseColumn',x+dx,h/2,z,2,h,34,wood,Enum.Material.Wood)end
   p('LanternPole',x-side*25,10,z-22,1,20,1,wood,Enum.Material.Wood)
   p('PaperLantern',x-side*25,18,z-22,5,7,5,Color3.fromRGB(245,174,108),Enum.Material.Neon,nil,Enum.PartType.Ball)
  end
  for floor=1,4 do local width=84-floor*12
   p('PagodaLevel',0,12+floor*17,330,width,14,width,cream,Enum.Material.Wood)
   p('PagodaRoof',0,21+floor*17,330,width+16,4,width+16,roof,Enum.Material.Slate)
  end
  p('DojoPlatform',260,1,0,80,2,80,wood,Enum.Material.Wood)
  for _,x in ipairs({230,290})do for _,z in ipairs({-30,30})do p('DojoPillar',x,18,z,3,34,3,wood,Enum.Material.Wood)end end
  p('DojoRoof',260,37,0,86,5,86,roof,Enum.Material.Slate)
  for i=1,10 do local angle=i*36;local x,z=math.cos(math.rad(angle))*580,math.sin(math.rad(angle))*580
   p('DistantAnimeMountain',x,36+i%4*12,z,130,86+i%4*24,130,Color3.fromRGB(141,164,190),Enum.Material.Slate,angle,Enum.PartType.Ball)
  end
 elseif id=='NEON'then
  for _,x in ipairs({-170,170})do
   p('CityAvenue',x,.08,0,52,.08,720,Color3.fromRGB(37,39,60),Enum.Material.Asphalt)
   for i=-4,4 do local z=i*76
    p('CityTower',x+(x>0 and 70 or-70),50+i%3*16,z,48,100+i%3*32,42,Color3.fromRGB(38,43,69),Enum.Material.Slate)
    for floor=1,5 do p('WindowBand',x+(x>0 and 44.8 or-44.8),floor*18,z,1,3,28,Color3.fromRGB(115,193,229),Enum.Material.Neon)end
    p('CityStreetlight',x-20,12,z,1,24,1,Color3.fromRGB(76,74,99),Enum.Material.Metal)
    p('CityLight',x-20,24,z,10,1,3,Color3.fromRGB(177,148,248),Enum.Material.Neon)
   end
  end
 elseif id=='COAST'then
  p('Boardwalk',0,.12,220,320,.2,32,Color3.fromRGB(171,139,95),Enum.Material.WoodPlanks)
  for i=-3,3 do local x=i*44
   p('BeachDeck',x,2,250,32,4,28,Color3.fromRGB(158,128,84),Enum.Material.WoodPlanks)
   p('SunUmbrellaPole',x,12,250,1,20,1,Color3.fromRGB(198,187,159),Enum.Material.Metal)
   p('SunUmbrella',x,23,250,25,2,25,i%2==0 and cream or Color3.fromRGB(147,198,199),Enum.Material.SmoothPlastic)
  end
  for i=1,12 do local x=math.cos(i)*700;local z=math.sin(i)*700
   p('SeaCliff',x,12,z,90,24,65,Color3.fromRGB(137,143,133),Enum.Material.Rock,i*30,Enum.PartType.Ball)
  end
 elseif id=='HALLOWEEN'then
  p('MoonGardenPath',0,.08,0,26,.08,620,Color3.fromRGB(74,69,85),Enum.Material.Cobblestone)
  for _,x in ipairs({-180,180})do
   p('HauntedHouse',x,36,260,74,72,68,Color3.fromRGB(77,65,89),Enum.Material.WoodPlanks)
   p('HouseRoof',x,75,260,84,7,78,Color3.fromRGB(48,41,66),Enum.Material.Slate)
   for _,dx in ipairs({-20,0,20})do p('HalloweenWindow',x+dx,42,225.8,9,18,.4,Color3.fromRGB(240,168,71),Enum.Material.Neon)end
   p('HouseTower',x,84,260,25,35,25,Color3.fromRGB(69,56,79),Enum.Material.Wood)
  end
  for i=-5,5 do p('FencePost',i*34,9,-270,2,18,2,wood,Enum.Material.Wood);p('FenceRail',i*34,8,-270,34,1,1,wood,Enum.Material.Wood)end
 elseif id=='CLOUD'then
  for i=1,8 do local a=math.pi*2*i/8;local x,z=math.cos(a)*540,math.sin(a)*540
   p('CloudArchLeft',x-18,70,z,4,45,4,Color3.fromRGB(222,232,243),Enum.Material.Marble)
   p('CloudArchRight',x+18,70,z,4,45,4,Color3.fromRGB(222,232,243),Enum.Material.Marble)
   p('CloudArchTop',x,94,z,40,5,6,Color3.fromRGB(234,237,250),Enum.Material.Marble)
  end
 end
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
