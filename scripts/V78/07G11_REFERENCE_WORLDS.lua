-- 07G11_REFERENCE_WORLDS | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
-- Releitura dos 13 trechos: portais, arquitetura, materiais e continuação além da tomada.
local Rep=game:GetService('ReplicatedStorage');local Input=game:GetService('UserInputService')
local Finishes=require(Rep:WaitForChild('07G12_WORLD_FINISHES'));local M={Version='V78',Budget=176,MobileBudget=144,ClearRadius=70}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
local gold=rgb(232,185,62);local stone=rgb(127,144,168);local white=rgb(232,234,230)
local cyan=rgb(95,212,229);local pink=rgb(232,158,203);local purple=rgb(117,83,163)
local themes={CLOUD=true,ICE=true,LAVA=true,PYRAMID=true,ANIME=true,CANDY=true,GRAVEYARD=true,CRYSTAL=true,CITY=true,GEARS=true,DIGITAL=true,LUMINOUS=true,PORTAL=true}
function M.Supports(id)return themes[id]==true end
function M.Build(id,center,part,alive)
 local count=0;local budget=Input.TouchEnabled and M.MobileBudget or M.Budget
 local function p(name,x,y,z,w,h,d,c,angle,shape,material)
  if count>=budget or alive and not alive()then return end
  count=count+1;if count%20==0 then task.wait();if alive and not alive()then return end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),c,shape,material or Enum.Material.SmoothPlastic)
  o.CastShadow=false;o:SetAttribute('ReferenceTheme',id);o:SetAttribute('DetailLayer',name:find('Continuation')and'extension'or'reference')
  if angle then o.Orientation=typeof(angle)=='Vector3'and angle or Vector3.new(0,angle,0)end
  if name:find('Glow')or name=='CityWindow'or name=='SkyRibbon'or id=='LUMINOUS'and name=='PineNeedles'then o.Material=Enum.Material.Neon end
  return o
 end
 local K=Finishes.New(p);local propsColor=stone
 if id=='CLOUD'then
  propsColor=white
  for _,x in ipairs({-78,78})do
   K.Column('GoldenGate',x,-148,gold,68,8)
   for j=1,5 do local xx=x+(x<0 and 1 or-1)*(j*9)
    p('GoldenGateRail',xx,40,-148,1.4,42,1.4,gold,nil,nil,Enum.Material.Metal)
    p('GoldenGateDiamond',xx,42,-148,7,13,1,gold,Vector3.new(0,0,45),nil,Enum.Material.Metal)
   end
   p('GoldenGateBeam',x+(x<0 and 24 or-24),59,-148,52,4,3,gold,nil,nil,Enum.Material.Metal)
  end
  for _,x in ipairs({-128,128})do
   K.Column('CelestialPillar',x,-180,white,42,7)
   p('CelestialOrb',x,49,-180,14,14,14,cyan,nil,Enum.PartType.Ball,Enum.Material.Glass)
   p('OrbGoldBelt',x,49,-180,14.5,2.2,14.5,gold,nil,nil,Enum.Material.Metal)
   K.Coins(x,118,gold);K.Gift(x+20,150,x<0 and cyan or pink)
  end
  for _,z in ipairs({-290,-380})do for _,side in ipairs({-1,1})do K.Column('ContinuationPillar',side*62,z,white,30,6)end end
 elseif id=='ICE'then
  propsColor=rgb(178,218,232);K.Arch('IceGate',0,-152,cyan,82,66,Enum.Material.Ice)
  for _,x in ipairs({-116,116})do
   K.Column('FrostTower',x,-175,propsColor,70,16)
   p('FrostTowerRoof',x,77,-175,32,27,30,cyan,Vector3.new(0,45,0),'Wedge',Enum.Material.Ice)
   for j=1,3 do p('IceTowerBand',x,j*17,-175,18,2,18,white,nil,nil,Enum.Material.Snow)end
   K.Crate(x,108,1.2,cyan)
  end
  for j=1,7 do K.Boulder(-210+j*52,-218,cyan,18+j%3*8,Enum.Material.Ice)end
 elseif id=='LAVA'then
  propsColor=rgb(63,65,80);K.Arch('LavaTemple',0,-158,propsColor,76,66,Enum.Material.Basalt)
  for _,x in ipairs({-112,112})do
   K.Column('TempleTower',x,-158,propsColor,76,24)
   for j=1,6 do p('LavaTowerGlow',x,9+j*9,-145,21,1.2,.25,gold)end
   for j=1,3 do p('LavaVerticalGlow',x+(j-2)*7,39,-145,.9,62,.25,gold)end
   K.Boulder(x,100,propsColor,24,Enum.Material.Basalt)
  end
  for j=1,8 do p('LavaCrackGlow',-160+j*40,.18,-112-j%2*12,24,.2,1.5,rgb(237,137,52),j*29)end
  p('TempleBrazier',0,8,-192,17,16,17,gold,nil,Enum.PartType.Ball)
 elseif id=='PYRAMID'then
  propsColor=rgb(132,152,169)
  for j=1,9 do local size=166-j*15;p('PyramidStep',0,j*6-3,-195,size,6,size,propsColor,nil,nil,Enum.Material.Slate)end
  for j=1,12 do p('PyramidStair',0,j*3-1,-112-j*6,22,3,7,stone,nil,nil,Enum.Material.Cobblestone)end
  K.Arch('PyramidDoor',0,-172,rgb(75,96,115),20,26,Enum.Material.Slate)
  for _,x in ipairs({-137,137})do K.Pine(x,-186,rgb(81,166,80),1.7);K.Crate(x,110,1.1);K.Coins(x+15,124,gold)end
 elseif id=='ANIME'then
  propsColor=rgb(117,169,150)
  local function torii(x,z,s)
   for _,side in ipairs({-1,1})do p('ToriiPost',x+side*27*s,22*s,z,4*s,44*s,4*s,rgb(187,71,69),nil,nil,Enum.Material.Wood)end
   p('ToriiCrossbeam',x,42*s,z,70*s,4*s,7*s,rgb(187,71,69),nil,nil,Enum.Material.Wood)
   p('ToriiCurvedTop',x,48*s,z,82*s,5*s,9*s,rgb(133,62,75),nil,nil,Enum.Material.Wood)
  end
  torii(0,-154,1);torii(-147,-244,.65);torii(151,-260,.65)
  K.Tree(-120,-95,pink,1.8);K.Tree(147,-166,rgb(226,179,218),1.5);K.Tree(-176,146,pink,1.3)
  for _,x in ipairs({-175,175})do p('PagodaBase',x,10,-286,48,20,38,white,nil,nil,Enum.Material.Plaster);p('PagodaRoof',x,28,-286,66,20,54,rgb(69,83,114),nil,'Wedge',Enum.Material.Slate)end
  for j=1,5 do K.Gift(-204+j*70,178,j%2==0 and pink or cyan)end
  p('SakuraPond',218,.15,105,82,.18,62,cyan,nil,Enum.PartType.Ball)
  for j=1,4 do K.Boulder(182+j*14,142,stone,8,Enum.Material.Slate)end
 elseif id=='CANDY'then
  propsColor=rgb(220,171,194)
  for j=1,7 do local x=-240+j*60;local z=j%2==0 and -163 or 160
   p('LollipopStick',x,16,z,2,32,2,white,nil,nil,Enum.Material.SmoothPlastic)
   p('RoundCandy',x,36,z,4,18,18,j%2==0 and pink or gold,Vector3.new(0,90,0),Enum.PartType.Cylinder)
   p('CandyStripe',x,36,z-2.1,2,15,.3,white,Vector3.new(0,0,28))
  end
  K.Arch('WaferGate',0,-188,rgb(211,171,116),78,52,Enum.Material.WoodPlanks)
  for _,x in ipairs({-190,190})do
   p('ChocolateBar',x,18,-225,28,36,7,rgb(157,112,82),Vector3.new(0,0,x/19),nil,Enum.Material.WoodPlanks)
   for j=1,4 do p('WaferScore',x,j*7,-220,26,.5,.25,rgb(202,167,123))end
  end
  for _,x in ipairs({-142,142})do K.Pine(x,-230,pink,1.4);K.Crate(x,100,1.3);K.Gift(x+26,140,cyan)end
 elseif id=='GRAVEYARD'then
  propsColor=rgb(135,142,165);K.Arch('CemeteryGate',0,-157,propsColor,80,68,Enum.Material.Cobblestone)
  for _,x in ipairs({-132,132})do
   p('CryptWall',x,19,-270,50,38,44,rgb(146,147,174),nil,nil,Enum.Material.Cobblestone)
   p('CryptRoof',x,42,-270,59,8,52,stone,nil,nil,Enum.Material.Slate)
   p('CryptDoor',x,13,-247,16,26,.4,rgb(84,73,118),nil,nil,Enum.Material.Slate)
  end
  K.Fence(-220,-207,rgb(50,52,73),14);K.Fence(76,-207,rgb(50,52,73),14)
  for j=1,5 do local x=-200+j*64;p('Gravestone',x,8,148,10,16,5,stone,nil,nil,Enum.Material.Slate);p('GraveCap',x,16,148,12,3,6,stone,nil,nil,Enum.Material.Slate)end
  for _,x in ipairs({-142,142})do
   p('BareTrunk',x,23,-110,4,46,4,rgb(81,69,91),nil,nil,Enum.Material.Wood)
   for _,side in ipairs({-1,1})do p('BareBranch',x+side*9,31,-110,22,3,3,rgb(81,69,91),Vector3.new(0,0,side*38),nil,Enum.Material.Wood)end
   K.Crate(x,110,1.1)
  end
 elseif id=='CRYSTAL'then
  propsColor=rgb(161,88,66)
  for j=1,10 do local a=j*2.399963;K.Boulder(math.cos(a)*196,math.sin(a)*171,rgb(170+j%3*21,72+j%3*13,55),30+j%4*12,Enum.Material.Sandstone)end
  for _,x in ipairs({-136,136})do p('RedCliff',x,42,-238,78,84,45,rgb(190,87,55),Vector3.new(0,x/5,0),'Wedge',Enum.Material.Sandstone);K.Crate(x,108,1.3,rgb(76,64,69))end
 elseif id=='CITY'then
  propsColor=rgb(74,67,109)
  for j=1,10 do local x=-280+j*50;local height=43+j%5*15
   p('CityBuilding',x,height/2,-223,34,height,34,propsColor,nil,nil,Enum.Material.Concrete)
   for row=1,3 do for col=1,2 do p('CityWindow',x+(col-1.5)*13,row*height/4,-205,6,7,.3,j%2==0 and cyan or pink)end end
  end
  for j=1,4 do p('SkyRibbon',-180+j*65,118,-267,150,1.5,2,purple,Vector3.new(0,0,j*9-23))end
  for _,x in ipairs({-160,160})do K.Boulder(x,130,purple,26,Enum.Material.Slate)end
 elseif id=='GEARS'then
  propsColor=rgb(115,129,151);K.Arch('MechanicalFacade',0,-176,propsColor,94,62,Enum.Material.Metal)
  for _,x in ipairs({-100,100})do
   K.Column('MechanicalTower',x,-184,propsColor,86,19)
   for j=1,7 do p('TowerGoldInset',x,8+j*10,-174,11,2,.3,gold,nil,nil,Enum.Material.Metal)end
   p('GearHub',x,66,-172,16,16,5,gold,nil,nil,Enum.Material.Metal)
   for j=1,12 do local a=j*math.pi/6;p('GearTooth',x+math.cos(a)*24,66+math.sin(a)*24,-172,12,7,6,gold,Vector3.new(0,0,j*30),nil,Enum.Material.Metal)end
  end
  p('MechanicalPedestal',0,4,-115,48,8,28,propsColor,nil,nil,Enum.Material.Metal)
  p('ClockworkPavilion',0,16,-238,40,32,35,propsColor,nil,nil,Enum.Material.Metal)
  p('PavilionRoof',0,40,-238,56,18,45,gold,nil,'Wedge',Enum.Material.Metal)
  for _,side in ipairs({-1,1})do
   for j=1,3 do K.Column('GalleryColumn',side*(105+j*30),-250,propsColor,42,6)end
   p('GalleryLintel',side*165,44,-250,110,7,14,gold,nil,nil,Enum.Material.Metal)
  end
 elseif id=='DIGITAL'then
  propsColor=rgb(77,82,119)
  for j=1,12 do local a=j*2.399963;local x,z=math.cos(a)*198,math.sin(a)*166
   p('DigitalCube',x,12+j%3*13,z,15,15,15,propsColor,Vector3.new(0,j*17,0),nil,Enum.Material.Metal)
   p('DigitalCubeGlow',x,4.4+j%3*13,z,15.2,.8,15.2,j%2==0 and cyan or pink,Vector3.new(0,j*17,0))
  end
  for j=1,8 do p('DigitalSkyline',-240+j*56,17+j%3*7,-250,42,34+j%3*14,30,propsColor,nil,nil,Enum.Material.Metal)end
 elseif id=='LUMINOUS'then
  propsColor=rgb(98,85,131)
  for j=1,8 do local a=j*2.399963;K.Pine(math.cos(a)*198,math.sin(a)*173,rgb(227,199,230),1.2+j%3*.25)end
  for _,x in ipairs({-143,143})do p('GlowingTreeTrunk',x,26,-140,2,52,2,pink,nil,nil,Enum.Material.Wood);K.Crate(x,120,1.3,propsColor)end
  for _,x in ipairs({-143,143})do
   for j=1,3 do p('LuminousSupplyGlow',x+(j-2)*3,7,-127,.4,5,.3,white)end
  end
  for j=1,5 do K.Boulder(-220+j*75,-275,rgb(149,128,157),24,Enum.Material.Slate)end
 elseif id=='PORTAL'then
  propsColor=rgb(61,66,95)
  for j=1,32 do local a=(j-1)*math.pi*2/32
   p('PortalRim',math.cos(a)*51,63+math.sin(a)*51,-180,12,8,9,propsColor,Vector3.new(0,0,math.deg(a)+90),nil,Enum.Material.Slate)
   p('PortalGlow',math.cos(a)*50,63+math.sin(a)*50,-174,7,1.5,.35,j%2==0 and pink or white,Vector3.new(0,0,math.deg(a)+90))
  end
  for j=1,10 do local a=j*math.pi/5
   p('CaveCeilingRock',math.cos(a)*165,128+math.sin(a)*18,-185,50,34,42,propsColor,Vector3.new(0,j*33,18),'Wedge',Enum.Material.Slate)
   if j%2==0 then p('CaveCrystalGlow',math.cos(a)*130,105,-172,3,3,3,white,Vector3.new(0,0,45))end
  end
  for j=1,8 do local a=j*math.pi/4;K.Boulder(math.cos(a)*188,math.sin(a)*168,propsColor,35+j%3*11,Enum.Material.Slate)end
 end
 -- A trilha continua além do enquadramento; não acompanha nem reposiciona o jogador.
 K.Path(id,propsColor)
 for j=1,3 do local x=(j-2)*115;K.Boulder(x,-540,propsColor,30+j*5,Enum.Material.Slate)end
 if not Input.TouchEnabled then for j=1,4 do local x=j%2==0 and 110 or-110;K.Crate(x,-310-j*40,.8,propsColor)end end
 return count
end
return M
