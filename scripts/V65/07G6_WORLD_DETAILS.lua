-- 07G6_WORLD_DETAILS | ModuleScript | ReplicatedStorage | V65 (SUBSTITUIR)
-- Flores baixas, acabamentos naturais e movimento discreto nas bordas da praça.
local Run=game:GetService('RunService');local Players=game:GetService('Players');local M={Version='V65'}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Detail(id,p)
 for i=1,36 do
  local a=i*2.399963;local radius=125+(i*37)%210;local x,z=math.cos(a)*radius,math.sin(a)*radius
  if id=='COAST'then
   if z<255 then p('BeachShell',x,.14,z,.8,.27,.6,rgb(231,221,206),Enum.Material.Marble,i*29,Enum.PartType.Ball)end
  elseif id=='HALLOWEEN'then
   for j=1,3 do p('AutumnLeaf',x+j*.5,.09,z+j*.3,1.1,.05,.55,j==2 and rgb(192,135,71)or rgb(160,106,76),Enum.Material.LeafyGrass,i*31+j*50,'Wedge')end
  else
   local flower=id=='ANIME'and rgb(244,206,219)or id=='CLOUD'and rgb(224,228,245)or id=='FOREST'and rgb(190,201,221)or rgb(241,220,166)
   p('FlowerStem',x,.28,z,.08,.56,.08,rgb(116,145,99),Enum.Material.Grass)
   for j=1,4 do local b=j*math.pi*.5;p('FlowerPetal',x+math.cos(b)*.19,.57,z+math.sin(b)*.19,.42,.1,.3,flower,Enum.Material.SmoothPlastic,j*90,Enum.PartType.Ball)end
   p('FlowerCenter',x,.61,z,.16,.1,.16,rgb(212,182,116),Enum.Material.SmoothPlastic,nil,Enum.PartType.Ball)
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
