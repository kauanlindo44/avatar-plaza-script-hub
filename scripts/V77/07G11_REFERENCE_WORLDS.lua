-- 07G11_REFERENCE_WORLDS | ModuleScript | ReplicatedStorage | V77 (CRIAR)
-- Composições dos trechos visíveis da referência; formas simples e centro livre.
local M={Version='V77',Budget=96,ClearRadius=92}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
local gold=rgb(235,188,61);local stone=rgb(128,137,153);local white=rgb(236,232,222)
local cyan=rgb(89,212,228);local pink=rgb(232,141,190);local purple=rgb(130,91,177)
local themes={CLOUD=true,ICE=true,LAVA=true,PYRAMID=true,ANIME=true,CANDY=true,GRAVEYARD=true,CRYSTAL=true,CITY=true,GEARS=true,DIGITAL=true,LUMINOUS=true,PORTAL=true}
function M.Supports(id)return themes[id]==true end
function M.Build(id,center,part,alive)
 local count=0
 local function p(name,x,y,z,w,h,d,color,angle,shape)
  if count>=M.Budget or alive and not alive()then return end
  count=count+1;if count%24==0 then task.wait();if alive and not alive()then return end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,Enum.Material.SmoothPlastic)
  o.CastShadow=false;o:SetAttribute('ReferenceTheme',id)
  if name=='PortalSegment'or name=='CityWindow'or name=='SkyRibbon'then o.Material=Enum.Material.Neon end
  if angle then o.Orientation=typeof(angle)=='Vector3'and angle or Vector3.new(0,angle,0)end
  return o
 end
 local function arch(name,x,z,color,span,height)
  p(name..'Left',x-span/2,height/2,z,6,height,8,color)
  p(name..'Right',x+span/2,height/2,z,6,height,8,color)
  p(name..'Lintel',x,height,z,span+10,6,9,color)
 end
 local function rock(x,z,c,s)
  p('FacetedRock',x,s*.2,z,s,s*.65,s*.7,c,Vector3.new(0,x%70,0),'Wedge')
  p('RockFace',x+s*.3,s*.12,z+s*.1,s*.6,s*.4,s*.6,c:Lerp(white,.15),Vector3.new(0,x%70+130,0),'Wedge')
 end
 local function tree(x,z,c,scale)
  p('TreeTrunk',x,9*scale,z,3*scale,18*scale,3*scale,rgb(117,83,89))
  for j=1,3 do p('FacetedCrown',x+(j-2)*6*scale,(18+j%2*4)*scale,z+(j%2)*4*scale,15*scale,9*scale,13*scale,c,Vector3.new(0,j*37,0),'Wedge')end
 end
 if id=='CLOUD'then
  arch('GoldenGate',0,-164,gold,72,72)
  for _,x in ipairs({-116,116})do
   p('CelestialPillar',x,28,-142,14,56,14,white);p('PillarCap',x,58,-142,23,5,23,gold)
   p('BlueOrnament',x,66,-142,13,13,13,cyan,Vector3.new(0,45,0),'Wedge')
   for i=1,5 do p('Coin',x+(i-3)*10,4,134,1.5,7,7,gold,Vector3.new(0,0,90),Enum.PartType.Cylinder)end
  end
  for i=1,4 do local x=-190+i*72;p('GiftBox',x,5,170,10,10,10,i%2==0 and pink or cyan);p('GiftRibbon',x,5,170,2,10.2,10.2,gold)end
 elseif id=='ICE'then
  arch('IceArch',0,-150,cyan,76,54)
  for i=1,9 do local x=-220+i*44;rock(x,-210,rgb(153,226,235),18+i%3*8)end
 elseif id=='LAVA'then
  arch('Temple',0,-158,rgb(70,66,75),82,66)
  for i=1,10 do local x=-210+i*40;p('LavaCrack',x,.2,-115-i%3*12,26,.3,3,rgb(238,123,51),i*31)end
  for _,x in ipairs({-155,155})do rock(x,-120,rgb(77,70,77),44)end
 elseif id=='PYRAMID'then
  for i=1,6 do local size=132-i*15;p('PyramidStep',0,i*7-2,-190,size,7,size,stone)end
  arch('PyramidDoor',0,-136,rgb(76,82,94),22,24)
  for _,x in ipairs({-142,142})do tree(x,-180,rgb(91,153,100),1.2)end
 elseif id=='ANIME'then
  arch('Torii',0,-160,rgb(183,70,65),64,48);p('ToriiTop',0,53,-160,88,5,12,rgb(147,56,65))
  tree(-132,-94,pink,2);tree(166,-150,rgb(235,170,200),1.6);tree(-184,144,pink,1.3)
 elseif id=='CANDY'then
  for i=1,6 do local x=-230+i*65;local z=i%2==0 and -165 or 170
   p('CandyStick',x,12,z,2,24,2,white);p('Lollipop',x,28,z,17,17,3,i%2==0 and pink or cyan)
  end
  arch('WaferGate',0,-190,rgb(210,170,119),76,50)
 elseif id=='GRAVEYARD'then
  arch('CemeteryArch',0,-168,stone,62,55)
  for i=1,12 do local x=-240+i*36;p('FencePost',x,10,-194,2,20,2,rgb(56,54,69));if i%3==0 then p('Gravestone',x,7,150,8,14,4,purple)end end
  for _,x in ipairs({-166,166})do p('BareTrunk',x,18,-120,4,36,4,rgb(82,69,88));p('BareBranch',x+6,28,-120,18,3,3,rgb(82,69,88),Vector3.new(0,0,32))end
 elseif id=='CRYSTAL'then
  for i=1,11 do local a=i*2.399963;local x,z=math.cos(a)*190,math.sin(a)*162
   rock(x,z,rgb(180+i%3*18,78+i%3*19,59),26+i%4*11)
  end
 elseif id=='CITY'then
  for i=1,12 do local x=-265+i*40;local height=40+i%5*13
   p('CityBlock',x,height/2,-215,28,height,26,rgb(65+i%3*8,57,98));p('CityWindow',x,height*.7,-201,14,3,.4,i%2==0 and cyan or pink)
  end
  for i=1,5 do p('SkyRibbon',-150+i*48,105,-235,110,3,3,i%2==0 and cyan or pink,Vector3.new(0,0,i*12-30))end
 elseif id=='GEARS'then
  arch('MechanicalFacade',0,-182,stone,110,66)
  for _,x in ipairs({-74,74})do
   p('GearHub',x,39,-174,12,12,5,gold)
   for i=1,8 do local a=i*math.pi/4;p('GearTooth',x+math.cos(a)*17,39+math.sin(a)*17,-174,10,7,6,gold,Vector3.new(0,0,i*45))end
  end
 elseif id=='DIGITAL'then
  for i=1,16 do local a=i*2.399963;local x,z=math.cos(a)*198,math.sin(a)*165
   p('DigitalCube',x,8+i%3*9,z,15,15,15,i%2==0 and cyan or pink,Vector3.new(0,i*17,0))
  end
 elseif id=='LUMINOUS'then
  tree(-150,-150,rgb(248,216,240),2);tree(150,-140,purple,1.7);tree(-185,146,rgb(238,202,236),1.4)
  for i=1,5 do rock(-230+i*76,190,rgb(196,170,148),12+i%2*8)end
 elseif id=='PORTAL'then
  for i=1,18 do local a=(i-1)*math.pi*2/18
   p('PortalSegment',math.cos(a)*48,57+math.sin(a)*48,-185,17,6,6,i%2==0 and cyan or rgb(199,228,240),Vector3.new(0,0,math.deg(a)+90))
  end
  for _,x in ipairs({-91,91})do rock(x,-175,rgb(72,76,92),35)end
 end
 return count
end
return M
