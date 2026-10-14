-- 07G6_WORLD_DETAILS | ModuleScript | ReplicatedStorage | V63 (NOVO)
-- Materiais Roblox, detalhes originais e animação local limitada; sem assets externos.
local Run=game:GetService('RunService');local Players=game:GetService('Players');local M={Version='V63'}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Detail(id,p)
 local grass=rgb(94,132,101);local wood=rgb(100,72,60)
 for i=1,36 do
  local a=i*2.399963;local radius=100+(i*41)%340;local x,z=math.cos(a)*radius,math.sin(a)*radius
  if id=='COAST'then
   p('BeachShell',x,.25,z,1.5,.5,1.2,rgb(233,219,191),Enum.Material.Marble,a*90,Enum.PartType.Ball)
   if i%3==0 then p('Driftwood',x+4,.6,z+2,12,1.2,2,wood,Enum.Material.Wood,a*90)end
  elseif id=='HALLOWEEN'then
   p('AutumnLeafCluster',x,.12,z,7,.22,5,i%2==0 and rgb(174,100,47)or rgb(127,77,62),Enum.Material.LeafyGrass,a*90)
   if i%4==0 then p('MoonGardenStone',x+5,1,z+8,5,2,4,rgb(108,103,121),Enum.Material.Rock,a*90,Enum.PartType.Ball)end
  else
   p('MeadowFlowers',x,.4,z,2,.8,2,id=='ANIME'and rgb(237,187,202)or id=='CLOUD'and rgb(196,217,252)or rgb(224,202,113),Enum.Material.LeafyGrass,a*90,Enum.PartType.Ball)
   if i%2==0 then p('WildGrass',x+4,.45,z-4,4,.9,3,grass,Enum.Material.Grass,a*90)end
  end
 end
end
function M.Animate(root,id)
 local list={};local lights=0
 for _,p in ipairs(root:GetChildren())do if p:IsA('BasePart')then
  if p.Name:find('Ripple')or p.Name=='Waterfall'then list[#list+1]={part=p,pos=p.Position,alpha=p.Transparency,phase=#list*.83}
  elseif p.Name:find('Glow')and lights<12 then
   lights=lights+1;local l=Instance.new('PointLight');l.Name='ThemeLanternLight';l.Color=p.Color;l.Brightness=1.15;l.Range=22;l.Shadows=false;l.Parent=p
  end
 end end
 local pg=Players.LocalPlayer and Players.LocalPlayer:FindFirstChild('PlayerGui');local timer,elapsed=0,0
 local connection=Run.Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;timer=timer+dt;if elapsed<.1 or not root.Parent then return end;elapsed=0
  if pg and pg:GetAttribute('ACP_ReducedMotion')then return end
  for i,v in ipairs(list)do if i<=24 and v.part.Parent then
   v.part.Position=v.pos+Vector3.new(0,math.sin(timer*.65+v.phase)*.08,0);v.part.Transparency=math.clamp(v.alpha+.04*math.sin(timer*.5+v.phase),0,.8)
  end end
 end)
 return function()connection:Disconnect()end
end
return M
