-- 07P6_STUDIO_SETS | ModuleScript | ReplicatedStorage | V55 (SUBSTITUIR)
-- Fundos calmos: o avatar ocupa o centro; cenário sem letreiros, neon ou brilho forte.
local Run=game:GetService('RunService');local M={}
function M.Build(folder,center,floorY,preset)
 local scene=Instance.new('Model');scene.Name='PhotoScenery';scene.Parent=folder
 local S={Alive=true,Animated=false,Count=0};local animated={};local time=0;local elapsed=0
 local function part(name,size,x,y,z,color,shape,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=CFrame.new(x,y,z);p.Color=color;p.Shape=shape or Enum.PartType.Block
  p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=scene;S.Count=S.Count+1;return p
 end
 local floor=Instance.new('Part');floor.Name='PhotoFloor';floor.Size=Vector3.new(600,.1,600);floor.CFrame=CFrame.new(center.X,floorY,center.Z);floor.Color=preset.b
 floor.Material=Enum.Material.SmoothPlastic;floor.Anchored=true;floor.CanCollide=false;floor.CanTouch=false;floor.CanQuery=false;floor.CastShadow=false;floor.Parent=folder
 local backdrop=part('Backdrop',Vector3.new(460,340,.2),0,0,22,preset.a)
 for i=1,8 do part('SoftGradient',Vector3.new(450,18,.15),0,-60+i*18,21.8,preset.a:Lerp(preset.b,(9-i)/11))end
 local tint=preset.a:Lerp(preset.b,.45);local edge=preset.accent:Lerp(preset.b,.75)
 local function leaf(name,x,y,z,col)local p=part(name,Vector3.new(3,2,1.6),x,y,z,col,Enum.PartType.Ball);animated[#animated+1]={part=p,base=p.CFrame,phase=x+y};return p end
 if preset.id=='STUDIO'then
  for _,x in ipairs({-28,28})do part('StudioPanel',Vector3.new(6,38,.3),x,3,12,tint);part('StudioTrim',Vector3.new(.15,38,.35),x-3,3,11.7,edge)end
 elseif preset.id=='SKY'then
  for i=1,6 do leaf('DistantCloud',i%2==0 and -30-i*2 or 30+i*2,10+i*3,18,edge)end
 elseif preset.id=='SUNSET'then
  local sun=part('SoftSun',Vector3.new(9,9,.3),-30,20,17,edge,Enum.PartType.Ball);sun.Transparency=.35
  for i=1,4 do part('DistantHorizon',Vector3.new(100,2,.12),0,-16+i*3,18,preset.a:Lerp(preset.b,.25+i*.12))end
 elseif preset.id=='GARDEN'then
  for _,x in ipairs({-31,31})do
   part('GardenStem',Vector3.new(.9,27,.9),x,0,12,tint,nil,Enum.Material.Wood)
   for i=1,4 do leaf('QuietLeaves',x+math.cos(i)*4,11+i*2,12,preset.accent:Lerp(preset.b,.65+i*.05))end
  end
 elseif preset.id=='HALLOWEEN'then
  -- Halloween acolhedor, sem sustos; o espaço central inteiro fica livre.
  for _,x in ipairs({-28,28})do
   part('AutumnPumpkin',Vector3.new(5,4,4),x,-10,8,Color3.fromRGB(184,126,78),Enum.PartType.Ball)
   part('PumpkinStem',Vector3.new(.6,1,.6),x,-7.6,8,Color3.fromRGB(83,105,79))
   for i=-1,1 do part('PumpkinRib',Vector3.new(.06,2.8,.1),x+i,-10,5.96,Color3.fromRGB(158,110,73))end
   local lantern=part('WarmLantern',Vector3.new(1.8,2.5,1.8),x*.8,-11,9,edge);lantern.Transparency=.2
  end
 end
 scene.WorldPivot=CFrame.new()
 function S.Align(cf)if S.Alive and scene.Parent then scene:PivotTo(cf)end end
 function S.SetAnimated(on)S.Animated=on==true end
 S.Connection=Run.RenderStepped:Connect(function(dt)
  if not S.Alive or not S.Animated then return end;time=time+dt;elapsed=elapsed+dt;if elapsed<.1 then return end;elapsed=0
  local pivot=scene:GetPivot();for _,entry in ipairs(animated)do if entry.part.Parent then entry.part.CFrame=pivot*entry.base*CFrame.new(0,math.sin(time*.2+entry.phase)*.12,0)end end
 end)
 function S.Destroy()if not S.Alive then return end;S.Alive=false;S.Connection:Disconnect();if scene.Parent then scene:Destroy()end end
 folder.Destroying:Connect(S.Destroy);S.Backdrop=backdrop;S.AnimatedCount=#animated;return S
end
return M

