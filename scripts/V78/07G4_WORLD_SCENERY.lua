-- 07G4_WORLD_SCENERY | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
-- Composições próprias para socializar e montar looks; centro plano e livre.
local Rep=game:GetService('ReplicatedStorage');local Details=require(Rep:WaitForChild('07G6_WORLD_DETAILS'))
local Plan=require(Rep:WaitForChild('07G8_VEGETATION_PLAN'))
local M={Version='V78',Budget=120,ClearRadius=48}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Build(id,center,part,alive)
 local Reference=require(Rep:WaitForChild('07G11_REFERENCE_WORLDS'));if Reference.Supports(id)then return Reference.Build(id,center,part,alive)end
 if id=='ADVENTURE'then return require(Rep:WaitForChild('07G7_ADVENTURE_WORLD')).Build(center,part,alive)end
 local count=0
 local function p(name,x,y,z,w,h,d,color,material,rotation,shape)
  if count>=M.Budget or alive and not alive()then return end;count=count+1
  if count%24==0 then task.wait();if alive and not alive()then return end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,material)
  o.CastShadow=false;if rotation then o.Orientation=typeof(rotation)=='Vector3'and rotation or Vector3.new(0,rotation,0)end
  if name:find('Water')or name:find('Ripple')then o.Transparency=.12;o.Reflectance=0 end;return o
 end
 local wood=rgb(137,110,84)
 local function tree(t,kind)
  local x,z,s=t.x,t.z,t.scale;local height=(kind=='palm'and 20 or 13+t.variant)*s
  local trunk=p('TreeTrunk',x,height*.5,z,height,1.35*s,1.35*s,wood,Enum.Material.Wood,Vector3.new(0,t.yaw,90+t.lean),Enum.PartType.Cylinder)
  if trunk then trunk:SetAttribute('TreeGroup',t.group);trunk:SetAttribute('TreeVariant',t.variant)end
  if kind=='palm'then
   for j=1,3 do local a=math.rad(t.yaw+j*120)
    p('PalmLeaf',x+math.cos(a)*4.5*s,height,z+math.sin(a)*4.5*s,12*s,.65*s,3.5*s,rgb(112+t.tint,163+j*2,123),Enum.Material.Grass,Vector3.new(0,-math.deg(a),6+j%2*4),Enum.PartType.Ball)
   end
  else
   local color=kind=='sakura'and rgb(235+t.tint,185+t.tint,208)or kind=='autumn'and rgb(185+t.tint,132+t.tint,84)or kind=='silver'and rgb(123+t.tint,161+t.tint,142)or rgb(111+t.tint,160+t.tint,114)
   local count=1
   for j=1,count do local a=math.rad(t.yaw+j*119+t.variant*13)
    local off=t.variant==1 and 2 or 3.6;local width=t.variant==3 and 10 or 12
    p(kind=='sakura'and'SakuraBlossoms'or'TreeCanopy',x+math.cos(a)*off*s,height+(j%2*2.2)*s,z+math.sin(a)*off*s,
     width*s,(t.variant==1 and 10 or 7)*s,(width-1)*s,color:Lerp(rgb(230,239,216),j*.025),Enum.Material.Grass,Vector3.new(t.lean,t.yaw+j*17,0),Enum.PartType.Ball)
   end
  end
 end
 for _,t in ipairs(Plan.Build(id))do tree(t,id=='ANIME'and'sakura'or id=='HALLOWEEN'and'autumn'or id=='COAST'and'palm'or id=='FOREST'and'silver'or'green')end
 if id=='COAST'then
  p('OceanWater',0,-.02,940,3000,.1,1300,rgb(114,179,190),Enum.Material.SmoothPlastic)
  for i=1,3 do p('CoastRipple',0,.06,310+i*64,2600,.04,1.1,rgb(211,233,224),Enum.Material.SmoothPlastic)end
 elseif id=='FOREST'then
  p('MoonReflectionWater',-320,.035,230,150,.07,110,rgb(127,158,177),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)
  for i=1,4 do p('MoonRipple',-320,.09,195+i*13,95,.02,.5,rgb(193,214,218),Enum.Material.SmoothPlastic)end
 elseif id=='ANIME'then
  p('SakuraReflectionWater',310,.035,210,138,.07,104,rgb(160,194,185),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)
  for i=1,5 do p('SakuraRipple',310,.09,182+i*10,90,.02,.5,rgb(223,232,220),Enum.Material.SmoothPlastic)end
 elseif id=='HALLOWEEN'then
  for i=1,5 do local a=i*2.399963;local x,z=math.cos(a)*165,math.sin(a)*165
   p('Pumpkin',x,1.5,z,3.8,3,3.8,rgb(202+i%3*8,130+i%2*10,65),Enum.Material.SmoothPlastic,i*17,Enum.PartType.Ball)
   p('PumpkinStem',x,3.1,z,.4,.8,.4,wood,Enum.Material.SmoothPlastic,Vector3.new(0,0,12))
   for _,side in ipairs({-1,1})do p('PumpkinEyeGlow',x+side*.7,1.8,z-1.7,.45,.45,.12,rgb(252,213,140),Enum.Material.Neon)end
   p('PumpkinSmile',x,1,z-1.8,1.3,.16,.12,rgb(252,213,140),Enum.Material.Neon)
  end
 end
 Details.Detail(id,p);return count
end
function M.Floor(folder,center,color,material,theme)
 local floor=Instance.new('Part');floor.Name='FixedWorldGround';floor.Size=Vector3.new(1600,.08,1600)
 floor.Position=center+Vector3.new(0,.045,0);floor.Color=color;floor.Material=material or Enum.Material.Grass
 floor.Anchored=true;floor.CanCollide=false;floor.CanTouch=false;floor.CanQuery=false;floor.CastShadow=false;floor.Parent=folder
 floor:SetAttribute('FixedOrigin',center)
 return function()floor:Destroy()end
end
return M
