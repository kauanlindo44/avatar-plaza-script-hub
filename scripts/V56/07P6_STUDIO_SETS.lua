-- 07P6_STUDIO_SETS | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Blocos fixos em uma sala local: girar personagem/câmera nunca reposiciona o cenário.
local Run=game:GetService('RunService');local M={}
function M.Build(folder,center,floorY,preset)
 local room=Instance.new('Model');room.Name='PhotoScenery';room.Parent=folder
 local origin=CFrame.new(center.X,floorY,center.Z)
 local S={Alive=true,Animated=false,Count=0,Origin=origin};local moving={};local time=0;local elapsed=0
 local function part(name,size,x,y,z,color,shape,material,angle)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=origin*CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(angle or 0),0)
  p.Color=color;p.Shape=shape or Enum.PartType.Block;p.Material=material or Enum.Material.SmoothPlastic
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=room;S.Count=S.Count+1;return p
 end
 local floor=part('PhotoFloor',Vector3.new(80,.2,80),0,-.12,0,preset.b)
 local backdrop=part('Backdrop',Vector3.new(80,42,.3),0,20.8,35,preset.a)
 part('WallLeft',Vector3.new(.3,42,80),-35,20.8,0,preset.a:Lerp(preset.b,.25))
 part('WallRight',Vector3.new(.3,42,80),35,20.8,0,preset.a:Lerp(preset.b,.25))
 part('WallFront',Vector3.new(80,42,.3),0,20.8,-35,preset.a)
 part('Ceiling',Vector3.new(80,.3,80),0,42,0,preset.a)
 local edge=preset.accent;local soft=preset.a:Lerp(preset.b,.55)
 local function ball(name,x,y,z,size,col)
  return part(name,Vector3.new(size,size*.85,size),x,y,z,col,Enum.PartType.Ball)
 end
 local function plant(x,z,color)
  part('Planter',Vector3.new(2.4,1.8,2.4),x,.9,z,soft)
  part('TreeStem',Vector3.new(.5,6,.5),x,4,z,Color3.fromRGB(120,94,78),nil,Enum.Material.Wood)
  for i=1,3 do ball('Leaves',x+math.sin(i)*1.5,5+i*1.2,z+math.cos(i),3,color)end
 end
 local function panels()
  for _,x in ipairs({-13,13})do
   part('EditorialPanel',Vector3.new(5,17,.4),x,8.5,18,soft)
   part('PanelTrim',Vector3.new(.16,17,.5),x-2.4,8.5,17.7,edge)
  end
 end
 if preset.id=='STUDIO'then
  panels();part('PortraitPlinth',Vector3.new(17,.18,15),0,-.03,0,preset.b:Lerp(Color3.new(1,1,1),.22))
  for _,x in ipairs({-9,9})do part('StudioLight',Vector3.new(.3,11,.3),x,5.5,9,edge)end
 elseif preset.id=='SKY'then
  for i=1,6 do local x=i%2==0 and-10-i or 10+i;local cloud=ball('Cloud',x,7+i,16,4,edge)
   local puff=ball('CloudPuff',x+2,7+i,16,3,edge);moving[#moving+1]={parts={{cloud,cloud.CFrame},{puff,puff.CFrame}},phase=i,axis='x'}
  end
  part('SkyHorizon',Vector3.new(68,1,.3),0,1,26,preset.b)
 elseif preset.id=='RUNWAY'then
  part('Runway',Vector3.new(12,.2,34),0,-.02,0,preset.b:Lerp(Color3.new(1,1,1),.2))
  for _,x in ipairs({-6.5,6.5})do part('RunwayEdge',Vector3.new(.25,.08,32),x,.12,0,edge)
   for i=1,4 do local bulb=ball('RunwayLight',x,.36,i*6-12,.45,edge);bulb.Material=Enum.Material.Neon end
  end
  panels()
 elseif preset.id=='GARDEN'then
  for _,x in ipairs({-10,10})do plant(x,13,preset.a:Lerp(Color3.fromRGB(140,166,127),.55))end
  part('GardenPath',Vector3.new(13,.15,28),0,-.03,2,preset.b:Lerp(Color3.new(1,1,1),.15))
  for i=1,6 do ball('AutumnFlower',i%2==0 and-8 or 8,.7,i*3-2,.7,edge)end
 elseif preset.id=='URBAN'then
  for _,x in ipairs({-12,12})do
   part('BrickFacade',Vector3.new(7,19,1),x,9.5,20,soft)
   for y=1,3 do part('Window',Vector3.new(3,3,.2),x,y*5,19.4,preset.a:Lerp(Color3.new(1,1,1),.45))end
  end
  part('StreetMark',Vector3.new(.3,.06,25),-7,.02,1,edge);part('StreetMark',Vector3.new(.3,.06,25),7,.02,1,edge)
  plant(-17,8,Color3.fromRGB(144,165,145))
 elseif preset.id=='HALLOWEEN'then
  panels()
  for _,x in ipairs({-8,8})do
   for j=0,1 do local bx=x+(x>0 and j*2.5 or-j*2.5);local bz=10+j*2
    ball('SalemPumpkin',bx,1.2,bz,2.6-j*.3,Color3.fromRGB(224,144,68))
    part('PumpkinStem',Vector3.new(.25,.65,.25),bx,2.5,bz,Color3.fromRGB(106,137,90))
    for _,side in ipairs({-.45,.45})do part('PumpkinEye',Vector3.new(.32,.25,.1),bx+side,1.5,bz-1.1,Color3.fromRGB(66,49,59))end
    part('PumpkinSmile',Vector3.new(.8,.18,.1),bx,1.05,bz-1.22,Color3.fromRGB(66,49,59))
   end
   part('LanternBase',Vector3.new(.8,.2,.8),x,.1,7,Color3.fromRGB(82,66,87))
   local lantern=part('LanternGlow',Vector3.new(.6,1.4,.6),x,.9,7,edge);lantern.Material=Enum.Material.Neon
  end
  local moon=ball('SalemMoon',-16,18,26,5,Color3.fromRGB(237,225,195));moon.Transparency=.12
  for _,x in ipairs({-18,18})do
   local ghost=ball('FriendlyGhost',x,5,18,1.8,Color3.fromRGB(233,231,240))
   local pieces={{ghost,ghost.CFrame}}
   for _,side in ipairs({-.3,.3})do local eye=part('GhostEye',Vector3.new(.18,.22,.1),x+side,5.15,17.1,Color3.fromRGB(82,66,99));pieces[#pieces+1]={eye,eye.CFrame}end
   moving[#moving+1]={parts=pieces,phase=x,axis='y'}
  end
 end
 function S.SetAnimated(on)S.Animated=on==true end
 S.Connection=Run.RenderStepped:Connect(function(dt)
  if not S.Alive or not S.Animated then return end;time=time+dt;elapsed=elapsed+dt;if elapsed<.08 then return end;elapsed=0
  for _,e in ipairs(moving)do
   local v=math.sin(time*.35+e.phase)*.35
   for _,piece in ipairs(e.parts)do if piece[1].Parent then piece[1].CFrame=piece[2]*CFrame.new(e.axis=='x'and v or 0,e.axis=='y'and v or 0,0)end end
  end
 end)
 function S.Destroy()if not S.Alive then return end;S.Alive=false;S.Connection:Disconnect();if room.Parent then room:Destroy()end end
 folder.Destroying:Connect(S.Destroy);S.Backdrop=backdrop;S.Floor=floor;S.Model=room;S.AnimatedCount=#moving;return S
end
return M

