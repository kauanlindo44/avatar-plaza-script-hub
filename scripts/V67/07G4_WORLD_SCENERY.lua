-- 07G4_WORLD_SCENERY | ModuleScript | ReplicatedStorage | V67 (SUBSTITUIR)
-- Composições próprias para socializar e montar looks; centro plano e livre.
local Rep=game:GetService('ReplicatedStorage');local Details=require(Rep:WaitForChild('07G6_WORLD_DETAILS'))
local M={Version='V67',Budget=300,ClearRadius=100}
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
 local wood=rgb(122,96,78)
 local function tree(x,z,s,kind)
  local height=kind=='palm'and 22 or 17
  p('TreeTrunk',x,height*s*.5,z,height*s,1.4*s,1.4*s,wood,Enum.Material.SmoothPlastic,Vector3.new(0,0,90),Enum.PartType.Cylinder)
  if kind=='palm'then
   for j=1,6 do local a=j*math.pi/3
    p('PalmLeaf',x+math.cos(a)*5*s,(height+.4)*s,z+math.sin(a)*5*s,13*s,.6*s,3.8*s,rgb(110,156+j*3,123),Enum.Material.SmoothPlastic,Vector3.new(0,-j*60,8),Enum.PartType.Ball)
   end
  else
   for j=1,3 do local a=j*2.399963
    local c=kind=='sakura'and rgb(242+j%2*8,192+j%3*5,211+j%2*9)or kind=='autumn'and rgb(161+j%3*12,113+j%2*12,73+j%3*8)or kind=='silver'and rgb(135+j%2*10,160+j%3*5,158+j%2*8)or rgb(117+j%2*8,157+j%3*6,115+j%2*11)
    p(kind=='sakura'and'SakuraBlossoms'or'TreeCanopy',x+math.cos(a)*4*s,(height+1.5+j%2*3)*s,z+math.sin(a)*4*s,12*s,7*s,11*s,c,Enum.Material.SmoothPlastic,j*31,Enum.PartType.Ball)
   end
  end
 end
 local radius=id=='COAST'and 150 or id=='CLOUD'and 180 or 130
 for i=1,id=='CLOUD'and 5 or 8 do
  local a=i*2.399963;local r=radius+i%3*35
  -- A praia abre a vista do mar; nenhum detalhe ocupa o ponto de chegada.
  if id~='COAST'or math.sin(a)<.25 then tree(math.cos(a)*r,math.sin(a)*r,.8+i%3*.13,id=='ANIME'and'sakura'or id=='HALLOWEEN'and'autumn'or id=='COAST'and'palm'or id=='FOREST'and'silver'or'green')end
 end
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
