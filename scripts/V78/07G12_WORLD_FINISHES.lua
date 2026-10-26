-- 07G12_WORLD_FINISHES | ModuleScript | ReplicatedStorage | V78 (CRIAR)
-- Detalhes reutilizáveis com materiais nativos; sem imagens externas ou colisão local.
local M={Version='V78'}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.New(p)
 local K={};local wood=rgb(164,122,77);local white=rgb(235,235,226)
 function K.Column(name,x,z,c,height,width)
  p(name..'Shaft',x,height/2,z,width,height,width,c,nil,nil,Enum.Material.Marble)
  for _,y in ipairs({1.5,height-1})do p(name..'Capital',x,y,z,width*1.4,3,width*1.4,c,nil,nil,Enum.Material.Marble)end
 end
 function K.Crate(x,z,scale,c)
  c=c or wood;local s=scale or 1
  p('SupplyCrate',x,4*s,z,8*s,8*s,8*s,c,nil,nil,Enum.Material.WoodPlanks)
  for _,a in ipairs({-43,43})do p('CrateBrace',x,4*s,z-4.05*s,.65*s,10*s,.25*s,c:Lerp(white,.18),Vector3.new(0,0,a),nil,Enum.Material.Wood)end
 end
 function K.Gift(x,z,c)
  p('WrappedGift',x,5,z,10,10,10,c,nil,nil,Enum.Material.Fabric)
  p('GiftRibbonFront',x,5,z-5.08,1.7,10,.16,white)
  p('GiftRibbonTop',x,10.08,z,1.7,.16,10,white)
  for _,a in ipairs({-35,35})do p('GiftBow',x,11.3,z,6,1.3,1.4,white,Vector3.new(0,0,a))end
 end
 function K.Coins(x,z,c)
  for j=1,4 do
   local o=p('CoinStack',x+(j%2)*4,1+j*.55,z+math.floor(j/2)*3,1.2,6,6,c,Vector3.new(0,0,90),Enum.PartType.Cylinder,Enum.Material.Metal)
   if o then o.Reflectance=.08 end
  end
 end
 function K.Pine(x,z,c,s)
  s=s or 1;p('PineTrunk',x,9*s,z,2*s,18*s,2*s,rgb(103,78,78),nil,nil,Enum.Material.Wood)
  for j=1,3 do
   local width=(22-j*4)*s
   for _,a in ipairs({0,180})do p('PineNeedles',x,(9+j*5)*s,z,width,12*s,width*.7,c,Vector3.new(0,a,0),'Wedge',Enum.Material.Grass)end
  end
 end
 function K.Tree(x,z,c,s)
  s=s or 1;p('TreeTrunk',x,12*s,z,3*s,24*s,3*s,rgb(107,76,89),nil,nil,Enum.Material.Wood)
  for j=1,3 do
   p('TreeBranch',x+(j-2)*5*s,(16+j%2*4)*s,z,12*s,2*s,2*s,rgb(107,76,89),Vector3.new(0,0,(j-2)*28),nil,Enum.Material.Wood)
   p('FacetedCrown',x+(j-2)*8*s,(24+j%2*7)*s,z,22*s,14*s,18*s,c,Vector3.new(0,j*37,0),'Wedge',Enum.Material.Grass)
  end
 end
 function K.Boulder(x,z,c,s,material)
  p('FacetedRock',x,s*.27,z,s,s*.8,s*.75,c,Vector3.new(0,x%70,0),'Wedge',material or Enum.Material.Rock)
  p('RockFace',x+s*.3,s*.2,z+s*.1,s*.6,s*.5,s*.55,c:Lerp(white,.13),Vector3.new(0,x%70+130,0),'Wedge',material or Enum.Material.Rock)
 end
 function K.Arch(name,x,z,c,span,height,material)
  local mat=material or Enum.Material.Limestone;local leg=height*.67;local radius=span/2
  p(name..'Left',x-radius,leg/2,z,7,leg,10,c,nil,nil,mat);p(name..'Right',x+radius,leg/2,z,7,leg,10,c,nil,nil,mat)
  for j=0,6 do local a=math.pi*j/6
   p(name..'ArchStone',x+math.cos(a)*radius,leg+math.sin(a)*(height-leg),z,span/6+2,7,11,c,Vector3.new(0,0,-math.deg(a)+90),nil,mat)
  end
 end
 function K.Fence(x,z,c,count)
  count=count or 9
  for j=1,count do p('FencePicket',x+(j-1)*8,7,z,1,14,1,c,nil,nil,Enum.Material.Metal)end
  for _,y in ipairs({4,10})do p('FenceRail',x+(count-1)*4,y,z,(count-1)*8+2,.8,1,c,nil,nil,Enum.Material.Metal)end
 end
 function K.Path(id,tone)
  for j=1,6 do
   local z=-200-j*36
   p('ContinuationPath',0,.13,z,42,.12,32,tone,nil,nil,Enum.Material.Cobblestone)
   for _,side in ipairs({-1,1})do p('PathBorder',side*25,.55,z,2,1,34,tone:Lerp(white,.22),nil,nil,Enum.Material.Slate)end
  end
  for _,side in ipairs({-1,1})do
   p('DistantTerrace',side*100,.08,-470,148,.1,130,tone,nil,nil,Enum.Material.Slate)
  end
 end
 return K
end
return M
