-- 07G6_WORLD_DETAILS | ModuleScript | ReplicatedStorage | V64 (SUBSTITUIR)
-- Acabamentos originais com materiais nativos, vegetação e luz limitada.
local Run=game:GetService('RunService');local Players=game:GetService('Players');local M={Version='V64'}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Detail(id,p)
 local wood=rgb(112,85,65);local grass=rgb(82,121,88)
 for i=1,24 do
  local a=i*2.399963;local radius=100+(i*41)%290;local x,z=math.cos(a)*radius,math.sin(a)*radius
  if id=='COAST'then
   p('BeachShell',x,.18,z,1,.35,.7,rgb(237,223,197),Enum.Material.Marble,a*90,Enum.PartType.Ball)
   if i%3==0 then
    p('Driftwood',x+4,.6,z+2,12,1.2,1.2,wood,Enum.Material.Wood,Vector3.new(0,i*23,8),Enum.PartType.Cylinder)
    p('DriftwoodGrain',x+4,1.21,z+2,10,.06,.12,rgb(78,65,54),Enum.Material.Wood,i*23)
   end
  elseif id=='HALLOWEEN'then
   for j=1,3 do p('AutumnLeaf',x+j*.7,.13,z+j*.4,1.4,.07,.7,j==2 and rgb(188,111,51)or rgb(127,76,53),Enum.Material.LeafyGrass,i*31+j*50,'Wedge')end
   if i%4==0 then p('MoonGardenStone',x+5,.8,z+8,4,1.6,3,rgb(108,103,121),Enum.Material.Rock,a*90,Enum.PartType.Ball)end
  else
   local flower=id=='ANIME'and rgb(243,184,206)or id=='CLOUD'and rgb(195,216,250)or id=='FOREST'and rgb(177,182,220)or rgb(233,204,110)
   p('FlowerStem',x,.6,z,.14,1.2,.14,grass,Enum.Material.Grass)
   for j=1,4 do local b=j*math.pi*.5;p('FlowerPetal',x+math.cos(b)*.28,1.15,z+math.sin(b)*.28,.65,.16,.45,flower,Enum.Material.SmoothPlastic,j*90,Enum.PartType.Ball)end
   p('FlowerCenter',x,1.2,z,.27,.17,.27,rgb(211,170,75),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)
   if i%3==0 then p('WildGrassBlade',x+3,.8,z-1,.15,1.6,.6,grass,Enum.Material.Grass,Vector3.new(0,i*25,12),'Wedge')end
  end
 end
 if id=='ANIME'then
  for i=-5,5 do
   p('PavilionRoofTileSeam',180+i*4,27.5,75,.28,.4,60,rgb(91,105,119),Enum.Material.Slate)
   for _,z in ipairs({54,96})do p('PavilionWoodJoin',180+i*4,.74,z,3.9,.14,1.5,wood,Enum.Material.WoodPlanks)end
  end
  for i=1,10 do local a=i*math.pi/5;p('PondLilyLeaf',-190+math.cos(a)*41,.2,50+math.sin(a)*35,3,.12,3,rgb(86,128,102),Enum.Material.LeafyGrass,i*36,Enum.PartType.Ball)end
 elseif id=='FOREST'then
  for i=1,16 do local a=i*math.pi/8;local x,z=220+math.cos(a)*114,120+math.sin(a)*99
   p('LakesideMoss',x,.6,z,5,.5,4,rgb(77,109,94),Enum.Material.LeafyGrass,i*30,Enum.PartType.Ball)
  end
  for i=1,6 do p('WaterfallFoam',334+i*2,.4,174,3,.3,4,rgb(199,223,219),Enum.Material.Glass,i*29,Enum.PartType.Ball)end
 elseif id=='COAST'then
  for i=1,18 do p('ShoreFoam',-420+i*45,.2,258+math.sin(i*.9)*5,38,.08,2,rgb(225,237,219),Enum.Material.Glass,i%3*3)end
  for i=1,18 do p('PierPlankJoin',0,.52,240+i*11,.22,.04,22,rgb(102,85,63),Enum.Material.Wood,90)end
 elseif id=='HALLOWEEN'then
  for i=1,10 do p('ArchCarvedStone',-32+i*6,26.1,226.9,.3,3.6,.12,rgb(149,135,154),Enum.Material.Slate)end
  for i=1,12 do local a=i*math.pi/6;local x,z=math.cos(a)*110,math.sin(a)*110
   p('PumpkinRib',x,2,z+.2,.12,3.9,4.6,rgb(184,94,36),Enum.Material.SmoothPlastic,i*30,Enum.PartType.Ball)
  end
 elseif id=='CLOUD'then
  for i=1,6 do local a=i*math.pi/3;local x,z=math.cos(a)*230,math.sin(a)*230
   for _,dx in ipairs({-15,15})do
    p('MarbleColumnFoot',x+dx,1,z,5,2,5,rgb(222,224,216),Enum.Material.Marble)
    p('MarbleColumnCapital',x+dx,29,z,4.6,1.2,4.6,rgb(229,229,217),Enum.Material.Marble)
    p('MarbleGoldBand',x+dx,27.9,z,3.1,.3,3.1,rgb(185,161,102),Enum.Material.Metal)
   end
  end
 end
end
function M.Animate(root,id)
 local list={};local lights=0;local sway={};local pg=Players.LocalPlayer and Players.LocalPlayer:FindFirstChild('PlayerGui')
 for _,p in ipairs(root:GetChildren())do if p:IsA('BasePart')then
  if(p.Name:find('Ripple')or p.Name=='Waterfall'or p.Name=='ShoreFoam')and #list<24 then list[#list+1]={part=p,pos=p.Position,alpha=p.Transparency,phase=#list*.83}
  elseif p.Name:find('Glow')and lights<8 then lights=lights+1;local l=Instance.new('PointLight');l.Name='ThemeLanternLight';l.Color=p.Color;l.Brightness=1.1;l.Range=20;l.Shadows=false;l.Parent=p
  elseif(p.Name=='SakuraBlossoms'or p.Name=='PalmLeaf'or p.Name=='FlowerPetal')and #sway<20 then sway[#sway+1]={part=p,cf=p.CFrame,phase=#sway*.63}end
 end end
 local timer,elapsed=0,0
 local connection=Run.Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;timer=timer+dt;if elapsed<.1 or not root.Parent then return end;elapsed=0
  if pg and pg:GetAttribute('ACP_ReducedMotion')then return end
  local cam=workspace.CurrentCamera;local origin=root:GetAttribute('Center');if cam and typeof(origin)=='Vector3'and(cam.CFrame.Position-origin).Magnitude>650 then return end
  for _,v in ipairs(list)do if v.part.Parent then v.part.Position=v.pos+Vector3.new(0,math.sin(timer*.65+v.phase)*.06,0);v.part.Transparency=math.clamp(v.alpha+.03*math.sin(timer*.5+v.phase),0,.8)end end
  for _,v in ipairs(sway)do if v.part.Parent then v.part.CFrame=v.cf*CFrame.Angles(0,0,math.sin(timer*.4+v.phase)*.012)end end
 end)
 return function()connection:Disconnect()end
end
return M
