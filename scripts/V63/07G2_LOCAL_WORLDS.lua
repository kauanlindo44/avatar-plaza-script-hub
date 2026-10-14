-- 07G2_LOCAL_WORLDS | ModuleScript | ReplicatedStorage | V63 (SUBSTITUIR)
-- Tema local, céu/nuvens/luz próprios, cenário em lotes e chão reutilizado.
local Lighting=game:GetService('Lighting');local Rep=game:GetService('ReplicatedStorage');local Run=game:GetService('RunService')
local Scenery=require(Rep:WaitForChild('07G4_WORLD_SCENERY'));local M={Version='V63',Selected='ORIGINAL'}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
M.Worlds={{id='ORIGINAL',name='Campo das flores',note='Prado aberto, árvores e trilhas de pedra',color=rgb(144,189,116),tone=rgb(119,164,108),sky=rgb(209,227,217),time=14.2,cover=.34,density=.2,material=Enum.Material.Grass},
{id='ANIME',name='Bosque das cerejeiras',note='Sakuras, lago, ponte e pavilhão ao ar livre',color=rgb(239,173,200),tone=rgb(144,174,132),sky=rgb(236,222,238),time=15.2,cover=.22,density=.2,material=Enum.Material.Grass},
{id='FOREST',name='Floresta lunar',note='Pinheiros, lago, pedras luminosas e cascata',color=rgb(145,178,214),tone=rgb(84,119,106),sky=rgb(143,171,211),time=1.2,cover=.12,density=.22,material=Enum.Material.LeafyGrass},
{id='COAST',name='Costa dourada',note='Mar, coqueiros, dunas e madeira ao pôr do sol',color=rgb(235,187,130),tone=rgb(219,197,156),sky=rgb(239,207,181),time=17.4,cover=.18,density=.2,material=Enum.Material.Sand},
{id='HALLOWEEN',name='Bosque das lanternas',note='Folhas de outono, abóboras e jardim sob a lua',color=rgb(192,136,86),tone=rgb(100,87,102),sky=rgb(163,151,188),time=21.6,cover=.48,density=.24,material=Enum.Material.Ground},
{id='CLOUD',name='Jardim celeste',note='Mármore, dourado, sebes e horizonte nas nuvens',color=rgb(179,211,243),tone=rgb(210,223,218),sky=rgb(227,241,252),time=12.4,cover=.62,density=.18,material=Enum.Material.Marble}}
local folder,cleanup,watch,lod,ambience;local savedParts,savedObjects,props={},{},nil;local generation=0
local keys={'ClockTime','Brightness','ExposureCompensation','Ambient','OutdoorAmbient','FogColor','FogStart','FogEnd'}
local terrain=workspace:FindFirstChildOfClass('Terrain')
local function restore()
 if ambience then ambience();ambience=nil end
 if cleanup then cleanup();cleanup=nil end;if watch then watch:Disconnect();watch=nil end;if lod then lod:Disconnect();lod=nil end
 if folder then folder:Destroy();folder=nil end
 for _,entry in ipairs(savedObjects)do if entry.original then entry.object.Parent=entry.parent else entry.object:Destroy()end end;savedObjects={}
 for p,v in pairs(savedParts)do if p.Parent then p.Color=v.color;p.Material=v.material end end;savedParts={}
 if props then for key,value in pairs(props)do Lighting[key]=value end;props=nil end
end
local function owned(object,parent)object.Parent=parent;savedObjects[#savedObjects+1]={object=object};return object end
function M.Apply(id)
 if id=='SAKURA'then id='ANIME'elseif id=='NEON'then id='FOREST'end;local style;for _,v in ipairs(M.Worlds)do if v.id==id then style=v;break end end;if not style then return false,'Mundo indisponível.'end
 local world=workspace:FindFirstChild('PracaAvatar_V2');if not world then return false,'A praça ainda está carregando.'end
 generation=generation+1;local mine=generation;restore();M.Selected=id
 local kit=Rep:FindFirstChild('PracaKit');local center=Vector3.new(kit and kit:GetAttribute('OriginX')or 0,kit and kit:GetAttribute('OriginY')or 60,kit and kit:GetAttribute('OriginZ')or 0)
 local root=Instance.new('Folder');root.Name='ACP_LocalWorldVisuals';root:SetAttribute('Theme',id);root.Parent=workspace;folder=root
 cleanup=Scenery.Floor(root,center,style.tone or rgb(113,172,111),style.material)
 props={};for _,key in ipairs(keys)do props[key]=Lighting[key]end
 for _,o in ipairs(Lighting:GetChildren())do if o:IsA('Sky')or o:IsA('Atmosphere')then savedObjects[#savedObjects+1]={object=o,parent=o.Parent,original=true};o.Parent=nil end end
 if terrain then for _,o in ipairs(terrain:GetChildren())do if o:IsA('Clouds')then savedObjects[#savedObjects+1]={object=o,parent=terrain,original=true};o.Parent=nil end end end
 Lighting.ClockTime=style.time;Lighting.Brightness=id=='FOREST'and 1.7 or 2.4;Lighting.ExposureCompensation=id=='HALLOWEEN'and .12 or .04
 Lighting.Ambient=style.sky:Lerp(rgb(168,177,198),.55);Lighting.OutdoorAmbient=style.sky;Lighting.FogColor=style.sky;Lighting.FogStart=1100;Lighting.FogEnd=3600
 local sky=Instance.new('Sky');sky.Name='ACP_Sky_'..id;sky:SetAttribute('SkyTheme',id);sky.CelestialBodiesShown=true;sky.StarCount=id=='FOREST'and 4000 or id=='HALLOWEEN'and 2200 or id=='CLOUD'and 0 or 300;sky.SunAngularSize=id=='COAST'and 19 or 10;sky.MoonAngularSize=id=='HALLOWEEN'and 28 or 11
 for key,file in pairs({SkyboxBk='bk',SkyboxDn='dn',SkyboxFt='ft',SkyboxLf='lf',SkyboxRt='rt',SkyboxUp='up'})do sky[key]='rbxasset://textures/sky/sky512_'..file..'.tex'end;owned(sky,Lighting)
 local at=Instance.new('Atmosphere');at.Name='ACP_Atmosphere_'..id;at.Color=style.sky;at.Decay=style.color;at.Density=style.density;at.Haze=id=='COAST'and 1.6 or id=='HALLOWEEN'and 1.1 or .35;at.Glare=id=='COAST'and .5 or .1;owned(at,Lighting)
 local fx=Instance.new('ColorCorrectionEffect');fx.Name='ACP_LocalWorldColor';fx.TintColor=style.sky:Lerp(rgb(255,255,255),.86);fx.Saturation=.035;fx.Contrast=.04;owned(fx,Lighting)
 local bloom=Instance.new('BloomEffect');bloom.Name='ACP_WorldBloom';bloom.Intensity=id=='FOREST'and .2 or .1;bloom.Size=14;bloom.Threshold=1.5;owned(bloom,Lighting)
 if terrain then local clouds=Instance.new('Clouds');clouds.Name='ACP_Clouds_'..id;clouds.Cover=style.cover;clouds.Density=.6;clouds.Color=style.sky;owned(clouds,terrain)end
 local function colorGround(p)
  if p:IsA('BasePart')and(p:GetAttribute('FieldTone')or p.Name=='FieldBase')then savedParts[p]=savedParts[p]or{color=p.Color,material=p.Material};p.Color=style.tone;p.Material=style.material end
 end
 local ground=world:FindFirstChild('AvatarFieldGround');if ground then for _,p in ipairs(ground:GetDescendants())do colorGround(p)end;watch=ground.DescendantAdded:Connect(colorGround)end
 task.spawn(function()
  local function alive()return mine==generation and root.Parent~=nil end
  local function part(name,size,pos,color,shape,material)
   local p=Instance.new(shape=='Wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=material or Enum.Material.SmoothPlastic;if shape and shape~='Wedge'then p.Shape=shape end;p.Parent=root;return p
  end
  local ok,n=pcall(Scenery.Build,id,center,part,alive);if not alive()then return end
  if not ok then warn('[World V63] '..id..' '..tostring(n));return end;root:SetAttribute('SceneryParts',n);root:SetAttribute('Ready',true);ambience=require(Rep:WaitForChild('07G6_WORLD_DETAILS')).Animate(root,id)
  local parts={};for _,p in ipairs(root:GetChildren())do if p:IsA('BasePart')and p.Name~='InfiniteVisualGround'then parts[#parts+1]=p end end
  local elapsed=0;local lastFar;lod=Run.Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed<.5 then return end;elapsed=0
   local camera=workspace.CurrentCamera;if not camera then return end;local far=(camera.CFrame.Position-center).Magnitude>1800
   if far==lastFar then return end;lastFar=far
   for _,p in ipairs(parts)do p.LocalTransparencyModifier=far and 1 or 0 end
  end)
 end)
 local home=kit and kit:FindFirstChild('Remotes')and kit.Remotes:FindFirstChild('HubTeleport');if home then home:FireServer()end
 return true
end
function M.Destroy()generation=generation+1;restore();M.Selected='ORIGINAL'end
task.delay(2,function()if M.Selected=='ORIGINAL'then M.Apply('ORIGINAL')end end)
return M
