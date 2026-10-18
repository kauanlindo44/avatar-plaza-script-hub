-- 07G4_WORLD_SCENERY | ModuleScript | ReplicatedStorage | V69 (SUBSTITUIR)
-- Composições próprias para socializar e montar looks; centro plano e livre.
local Rep=game:GetService('ReplicatedStorage');local Details=require(Rep:WaitForChild('07G6_WORLD_DETAILS'))
local Plan=require(Rep:WaitForChild('07G8_VEGETATION_PLAN'))
local M={Version='V69',Budget=300,ClearRadius=48}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Build(id,center,part,alive)
 if id=='ADVENTURE'then return require(Rep:WaitForChild('07G7_ADVENTURE_WORLD')).Build(center,part,alive)end
 local count=0
 local function p(name,x,y,z,w,h,d,color,material,rotation,shape)
  if count>=M.Budget or alive and not alive()then return end;count=count+1
  if count%24==0 then task.wait();if alive and not alive()then return end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,material)
  o.CastShadow=name=='TreeTrunk';if rotation then o.Orientation=typeof(rotation)=='Vector3'and rotation or Vector3.new(0,rotation,0)end
  if name:find('Water')or name:find('Ripple')then o.Transparency=.12;o.Reflectance=0 end;return o
 end
 local wood=rgb(137,110,84)
 local function tree(t,kind)
  local x,z,s=t.x,t.z,t.scale;local height=(kind=='palm'and 20 or 13+t.variant)*s
  local trunk=p('TreeTrunk',x,height*.5,z,height,1.35*s,1.35*s,wood,Enum.Material.Wood,Vector3.new(0,t.yaw,90+t.lean),Enum.PartType.Cylinder)
  if trunk then trunk:SetAttribute('TreeGroup',t.group);trunk:SetAttribute('TreeVariant',t.variant)end
  if kind=='palm'then
   for j=1,5 do local a=math.rad(t.yaw+j*72+math.sin(j+t.variant)*8)
    p('PalmLeaf',x+math.cos(a)*4.5*s,height,z+math.sin(a)*4.5*s,12*s,.65*s,3.5*s,rgb(112+t.tint,163+j*2,123),Enum.Material.Grass,Vector3.new(0,-math.deg(a),6+j%2*4),Enum.PartType.Ball)
   end
  else
   local color=kind=='sakura'and rgb(235+t.tint,185+t.tint,208)or kind=='autumn'and rgb(185+t.tint,132+t.tint,84)or kind=='silver'and rgb(123+t.tint,161+t.tint,142)or rgb(111+t.tint,160+t.tint,114)
   local count=t.variant==1 and 2 or t.variant==4 and 4 or 3
   for j=1,count do local a=math.rad(t.yaw+j*119+t.variant*13)
    local off=t.variant==1 and 2 or 3.6;local width=t.variant==3 and 10 or 12
    p(kind=='sakura'and'SakuraBlossoms'or'TreeCanopy',x+math.cos(a)*off*s,height+(j%2*2.2)*s,z+math.sin(a)*off*s,
     width*s,(t.variant==1 and 10 or 7)*s,(width-1)*s,color:Lerp(rgb(230,239,216),j*.025),Enum.Material.Grass,Vector3.new(t.lean,t.yaw+j*17,0),Enum.PartType.Ball)
   end
   if t.variant%2==0 then p('TreeBranch',x+1.3*s,height*.77,z,5*s,.7*s,.7*s,wood,Enum.Material.Wood,Vector3.new(0,t.yaw,25),Enum.PartType.Cylinder)end
  end
 end
 for _,t in ipairs(Plan.Build(id))do tree(t,id=='ANIME'and'sakura'or id=='HALLOWEEN'and'autumn'or id=='COAST'and'palm'or id=='FOREST'and'silver'or'green')end
 if id=='COAST'then
  p('OceanWater',0,-.02,940,3000,.1,1300,rgb(114,179,190),Enum.Material.SmoothPlastic)
  for i=1,9 do p('CoastRipple',0,.06,310+i*28,2600,.04,1.1,rgb(211,233,224),Enum.Material.SmoothPlastic)end
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
 local Run=game:GetService('RunService');local pl=game:GetService('Players').LocalPlayer;local tiles={};local tick=0;local cell=2048
 for i=1,25 do local p=Instance.new('Part');p.Name='InfiniteVisualGround';p.Size=Vector3.new(cell,.06,cell);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color;p.Parent=folder;tiles[i]=p end
 if theme=='ORIGINAL'then
  for x=-4,4 do for z=-4,4 do local p=Instance.new('Part');p.Name='CatalogFieldTile';p.Size=Vector3.new(24,.02,24);p.Position=center+Vector3.new(x*24,.085,z*24);p.Color=(x+z)%2==0 and color:Lerp(Color3.new(1,1,1),.025)or color:Lerp(Color3.new(0,0,0),.025);p.Material=material or Enum.Material.Grass;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=folder end end
 end
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
