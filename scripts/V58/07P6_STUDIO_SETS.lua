-- 07P6_STUDIO_SETS | ModuleScript | ReplicatedStorage | V58 (SUBSTITUIR)
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
 elseif preset.id=='GRAPHITE'then
  part('SlateStage',Vector3.new(19,.18,16),0,-.02,0,preset.b,nil,Enum.Material.Slate)
  for _,x in ipairs({-12,12})do
   part('StudioSoftbox',Vector3.new(3,14,.35),x,7,16,edge,nil,Enum.Material.Neon)
   part('SoftboxDiffuser',Vector3.new(3.4,14.5,.35),x,7,16.4,soft)
  end
  for i=1,9 do part('AcousticSlat',Vector3.new(.35,23,.5),i*2.5-12.5,11.5,27,soft,nil,Enum.Material.Wood)end
 elseif preset.id=='NEON'then
  floor.Material=Enum.Material.Concrete
  for _,x in ipairs({-15,15})do
   part('RainStreetBuilding',Vector3.new(9,26,7),x,13,24,soft,nil,Enum.Material.Brick)
   for y=1,4 do for j=-1,1 do part('NeonWindow',Vector3.new(1.6,2.8,.2),x+j*2.5,y*5,20.3,edge:Lerp(Color3.fromRGB(235,132,188),y/5),nil,Enum.Material.Neon)end end
   part('VerticalNeonSign',Vector3.new(.25,12,.4),x-(x>0 and 5 or-5),8,20,edge,nil,Enum.Material.Neon)
   part('StreetBench',Vector3.new(5,.5,1.4),x,1.5,11,preset.b,nil,Enum.Material.Wood)
   local reflection=part('RainReflection',Vector3.new(2,.02,12),x>0 and 9 or-9,.02,8,edge,nil,Enum.Material.Glass);reflection.Transparency=.55
  end
  for i=1,10 do
   local drop=part('DistantRain',Vector3.new(.025,.9,.025),i%2==0 and-11 or 11,3+(i%5)*2,15+i*.5,edge);drop.Transparency=.65
   moving[#moving+1]={parts={{drop,drop.CFrame}},phase=i,axis='y'}
  end
 elseif preset.id=='ROOFTOP'then
  floor.Material=Enum.Material.Concrete
  part('RoofParapet',Vector3.new(46,2,.6),0,1,20,soft,nil,Enum.Material.Concrete)
  for i=1,7 do local x=i*7-28;local bh=8+(i*7)%13
   part('DistantTower',Vector3.new(5,bh,5),x,bh/2,29,preset.a:Lerp(soft,.3),nil,Enum.Material.Concrete)
   for y=1,math.floor(bh/3)do part('TowerWindows',Vector3.new(3,.7,.15),x,y*3,26.4,edge,nil,Enum.Material.Neon)end
  end
  for _,x in ipairs({-12,12})do plant(x,12,Color3.fromRGB(69,100,93));part('RoofLight',Vector3.new(.5,.6,.5),x,2,11,edge,nil,Enum.Material.Neon)end
  ball('RoofMoon',-20,24,30,5,Color3.fromRGB(229,233,242))
 elseif preset.id=='LIBRARY'then
  floor.Material=Enum.Material.WoodPlanks
  for _,x in ipairs({-14,14})do
   part('Bookcase',Vector3.new(8,22,2),x,11,24,soft,nil,Enum.Material.Wood)
   for y=1,5 do
    part('BookShelf',Vector3.new(8,.3,2.3),x,y*4,23.8,edge,nil,Enum.Material.Wood)
    for j=1,6 do local col=Color3.fromRGB(65+j*12,45+y*7,58+j*6)
     part('BookSpine',Vector3.new(.65,1.7+(j%3)*.25,1.5),x-3.4+j, y*4+1.2,23.3,col,nil,Enum.Material.Fabric)
    end
   end
   part('LibraryColumn',Vector3.new(1.2,25,1.2),x+(x>0 and 5 or-5),12.5,23,soft,nil,Enum.Material.Marble)
   part('ReadingLamp',Vector3.new(.65,1.2,.65),x,2.4,10,edge,nil,Enum.Material.Neon)
  end
  part('LibraryRug',Vector3.new(18,.03,24),0,.015,2,Color3.fromRGB(77,48,58),nil,Enum.Material.Fabric)
 elseif preset.id=='HALLOWEEN'then
  floor.Material=Enum.Material.Cobblestone
  part('SalemWalkway',Vector3.new(15,.04,32),0,.01,0,preset.b,nil,Enum.Material.Slate)
  for _,x in ipairs({-15,15})do
   part('SalemHouse',Vector3.new(9,14,7),x,7,22,soft,nil,Enum.Material.Brick)
   for _,side in ipairs({-1,1})do local roof=part('GabledRoof',Vector3.new(6,.4,9),x+side*2.2,15.3,22,Color3.fromRGB(50,42,58),nil,Enum.Material.Slate);roof.CFrame=roof.CFrame*CFrame.Angles(0,0,math.rad(side*-32))end
   part('SalemDoor',Vector3.new(2.2,5,.2),x,2.5,18.4,Color3.fromRGB(49,35,39),nil,Enum.Material.Wood)
   for _,dx in ipairs({-2.7,2.7})do for _,y in ipairs({4,10})do
    part('WarmWindow',Vector3.new(1.8,2.3,.2),x+dx,y,18.35,edge,nil,Enum.Material.Neon)
    part('WindowCross',Vector3.new(.15,2.4,.3),x+dx,y,18.2,soft,nil,Enum.Material.Wood)
   end end
   for j=1,6 do part('SalemFence',Vector3.new(.25,2.7,.3),x-3.5+j,1.35,12,Color3.fromRGB(58,45,53),nil,Enum.Material.Wood)end
   part('FenceRail',Vector3.new(6,.25,.3),x,1.7,12,soft,nil,Enum.Material.Wood)
   for j=0,2 do local bx=x+(x>0 and-j*2 or j*2);local bz=8+j*2;local r=2.5-j*.35
    ball('SalemPumpkin',bx,r*.48,bz,r,Color3.fromRGB(207,114,47))
    part('PumpkinStem',Vector3.new(.23,.45,.23),bx,r,bz,Color3.fromRGB(103,115,69),nil,Enum.Material.Wood)
    for _,side in ipairs({-.22,.22})do part('PumpkinEye',Vector3.new(.3,.25,.1),bx+side*r,r*.6,bz-r*.46,edge,nil,Enum.Material.Neon)end
    part('PumpkinSmile',Vector3.new(.7,.15,.1),bx,r*.38,bz-r*.49,edge,nil,Enum.Material.Neon)
   end
   plant(x,29,Color3.fromRGB(74,65,87))
   local lantern=part('SalemLantern',Vector3.new(.5,1.4,.5),x>0 and 9 or-9,1.1,9,edge,nil,Enum.Material.Neon)
   local glow=Instance.new('PointLight');glow.Brightness=.65;glow.Range=9;glow.Color=edge;glow.Parent=lantern
   local ghost=ball('FriendlyGhost',x,6,16,1.5,Color3.fromRGB(211,204,221));ghost.Transparency=.35
   local pieces={{ghost,ghost.CFrame}}
   for _,side in ipairs({-.24,.24})do local eye=part('GhostEye',Vector3.new(.14,.19,.1),x+side,6.1,15.32,Color3.fromRGB(43,36,53));pieces[#pieces+1]={eye,eye.CFrame}end
   moving[#moving+1]={parts=pieces,phase=x,axis='y'}
  end
  local moon=ball('SalemMoon',-16,23,29,6,Color3.fromRGB(227,219,186));moon.Material=Enum.Material.Neon
  for i=1,6 do part('SalemPavingStone',Vector3.new(3,.04,1),0,.04,i*4-14,preset.b:Lerp(edge,.15),nil,Enum.Material.Cobblestone)end

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

