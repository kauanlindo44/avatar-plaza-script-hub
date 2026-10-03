-- 07P6_STUDIO_SETS | ModuleScript | ReplicatedStorage
-- V43: cinco sets locais animados; cenografia permanece atras do avatar a 360 graus.
local Run=game:GetService("RunService")
local M={}
function M.Build(folder,center,floorY,preset)
 local scene=Instance.new("Model");scene.Name="PhotoScenery";scene.Parent=folder
 local animated={};local time,elapsed=0,0;local S={Alive=true,Animated=true}
 local function part(name,size,cf,color,material,shape,parent)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;if shape then p.Shape=shape end;p.Parent=parent or scene;return p
 end
 part("PhotoFloor",Vector3.new(600,.1,600),CFrame.new(center.X,floorY,center.Z),preset.b,nil,nil,folder)
 local backdrop=part("Backdrop",Vector3.new(440,340,.3),CFrame.new(0,0,6),preset.a)
 local function at(x,y,z)return CFrame.new(x,y,z or 0)end
 local function drift(p,phase,amp,rotate)table.insert(animated,{p=p,base=p.CFrame,phase=phase,amp=amp or 1,rotate=rotate})end
 local accent=preset.accent
 if preset.id=="STUDIO"then
  for _,x in ipairs({-15,15})do
   part("LightColumn",Vector3.new(.4,32,.4),at(x,6,-8),accent,Enum.Material.Neon)
   part("Softbox",Vector3.new(8,16,.4),at(x*1.8,5,-2)*CFrame.Angles(0,math.rad(x>0 and -20 or 20),0),preset.b)
  end
  for i=1,5 do part("StudioStep",Vector3.new(50-i*5,.4,3),at(0,-7-i*.5,-3+i),preset.b)end
 elseif preset.id=="SKY"then
  for i=1,6 do local x=-25+i*8
   for j=1,3 do local p=part("Cloud",Vector3.new(8+j*2,4+j,4),at(x+j*2,7+i%3*3,-5-j*.5),accent,nil,Enum.PartType.Ball)
    if j==2 then drift(p,i,.65)end
   end
  end
  local sun=part("Sun",Vector3.new(9,9,2),at(-20,21,0),Color3.fromRGB(255,235,177),Enum.Material.Neon,Enum.PartType.Ball);drift(sun,0,.3)
 elseif preset.id=="SUNSET"then
  part("Sun",Vector3.new(25,25,2),at(0,9,0),accent,Enum.Material.Neon,Enum.PartType.Ball)
  for i=1,9 do part("Horizon",Vector3.new(100,.16,.2),at(0,-12+i*1.4,-1),preset.b,Enum.Material.Neon)end
  for _,x in ipairs({-22,22})do part("SunsetArch",Vector3.new(3,35,4),at(x,5,-5),preset.b)end
 elseif preset.id=="GARDEN"then
  for _,x in ipairs({-23,-16,16,23})do
   part("Planter",Vector3.new(5,4,5),at(x,-6,-5),Color3.fromRGB(215,204,181))
   part("Stem",Vector3.new(1,15,1),at(x,2,-5),Color3.fromRGB(111,134,111))
   part("Canopy",Vector3.new(11,12,7),at(x,12,-5),accent,nil,Enum.PartType.Ball)
  end
  for i=1,7 do local p=part("Petal",Vector3.new(.4,.12,.4),at(-18+i*5,3+i%4*3,-9),Color3.fromRGB(255,205,224));drift(p,i,1.4,true)end
 else
  for _,x in ipairs({-18,18})do
   part("NeonPillar",Vector3.new(2,35,3),at(x,4,-6),preset.b)
   part("NeonEdge",Vector3.new(.25,35,.3),at(x-.9,4,-8),accent,Enum.Material.Neon)
  end
  part("NeonRoof",Vector3.new(38,1,3),at(0,22,-6),accent,Enum.Material.Neon)
  for i=1,24 do local x=-46+(i*17)%92;local y=-5+(i*11)%39
   local p=part("Star",Vector3.new(.28,.28,.28),at(x,y,-2),accent,Enum.Material.Neon,Enum.PartType.Ball)
   if i<=8 then drift(p,i,.35)end
  end
  for i=1,6 do part("NeonStep",Vector3.new(45-i*3,.18,2),at(0,-10+i*.3,-5+i),preset.b)end
 end
 scene.WorldPivot=CFrame.new()
 function S.Align(cf)if S.Alive and scene.Parent then scene:PivotTo(cf)end end
 function S.SetAnimated(on)S.Animated=on==true end
 S.Connection=Run.RenderStepped:Connect(function(dt)
  if not S.Alive or not S.Animated then return end;time=time+dt;elapsed=elapsed+dt;if elapsed<.05 then return end;elapsed=0
  local cf=scene:GetPivot()
  for _,e in ipairs(animated)do if e.p.Parent then
   local spin=e.rotate and CFrame.Angles(0,time*.3+e.phase,0)or CFrame.new()
   e.p.CFrame=cf*e.base*CFrame.new(math.sin(time*.3+e.phase)*e.amp*.4,math.sin(time*.65+e.phase)*e.amp,0)*spin
  end end
 end)
 function S.Destroy()if not S.Alive then return end;S.Alive=false;S.Connection:Disconnect();if scene.Parent then scene:Destroy()end end
 folder.Destroying:Connect(S.Destroy);S.Backdrop=backdrop;return S
end
return M
