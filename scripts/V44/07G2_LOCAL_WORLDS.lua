-- 07G2_LOCAL_WORLDS | ModuleScript | ReplicatedStorage
-- V43: mundos cosmeticos locais; nenhuma colisao ou regra do servidor muda.
local Lighting=game:GetService("Lighting")
local Run=game:GetService("RunService")
local M={Selected="ORIGINAL"}
M.Worlds={
 {id="ORIGINAL",name="Praça original",note="O ambiente da praça",color=Color3.fromRGB(133,190,116)},
 {id="CLOUD",name="Ilhas de nuvens",note="Céu azul e horizonte suave",color=Color3.fromRGB(128,190,236),time=13,tone=Color3.fromRGB(157,192,208)},
 {id="SAKURA",name="Jardim sakura",note="Árvores rosadas e luz quente",color=Color3.fromRGB(229,148,177),time=16,tone=Color3.fromRGB(148,180,153)},
 {id="NEON",name="Cidade neon",note="Violeta e luzes no horizonte",color=Color3.fromRGB(155,141,232),time=0,tone=Color3.fromRGB(75,80,113)},
 {id="COAST",name="Costa dourada",note="Mar, palmeiras e pôr do sol",color=Color3.fromRGB(237,186,118),time=17.2,tone=Color3.fromRGB(203,183,147)}
}
local savedParts,properties={},nil
local folder,effect,connection,watch=nil,nil,nil,nil
local moving={};local clock=0;local sky=nil;local atmosphere=nil;local savedSkies={}
local keys={"ClockTime","Brightness","Ambient","OutdoorAmbient","ExposureCompensation","FogColor","FogStart","FogEnd"}
local function restore()
 if connection then connection:Disconnect();connection=nil end
 if watch then watch:Disconnect();watch=nil end
 if folder then folder:Destroy();folder=nil end
 if effect then effect:Destroy();effect=nil end
 if sky then sky:Destroy();sky=nil end;if atmosphere then atmosphere:Destroy();atmosphere=nil end
 for _,s in ipairs(savedSkies)do s.Parent=Lighting end;savedSkies={}
 for p,c in pairs(savedParts)do if p.Parent then p.Color=c.color;p.Material=c.material end end;savedParts={};moving={}
 if properties then for k,v in pairs(properties)do Lighting[k]=v end;properties=nil end
end
local function part(name,size,pos,color,shape,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.Material=material or Enum.Material.SmoothPlastic;if shape then p.Shape=shape end;p.Parent=folder;return p
end
function M.Apply(id)
 local style;for _,v in ipairs(M.Worlds)do if v.id==id then style=v end end
 if not style then return false,"Mundo indisponível."end
 local world=workspace:FindFirstChild("PracaAvatar_V2")
 if id~="ORIGINAL"and not world then return false,"A praça está carregando. Tente novamente."end
 restore();M.Selected=id
 if id=="ORIGINAL"then return true end
 properties={};for _,k in ipairs(keys)do properties[k]=Lighting[k]end
 Lighting.ClockTime=style.time;Lighting.Brightness=2.3;Lighting.ExposureCompensation=.05
 Lighting.Ambient=Color3.fromRGB(153,163,184);Lighting.OutdoorAmbient=Color3.fromRGB(170,179,197)
 Lighting.FogColor=style.color;Lighting.FogStart=450;Lighting.FogEnd=2200
 effect=Instance.new("ColorCorrectionEffect");effect.Name="ACP_LocalWorldColor";effect.Saturation=.04;effect.Contrast=.04;effect.Parent=Lighting
 for _,s in ipairs(Lighting:GetChildren())do if s:IsA("Sky")or s:IsA("Atmosphere")then table.insert(savedSkies,s);s.Parent=nil end end
 sky=Instance.new("Sky");sky.Name="ACP_Sky_"..id;sky.CelestialBodiesShown=true;sky.StarCount=id=="NEON"and 5000 or 600;sky.SunAngularSize=id=="COAST"and 18 or 9;sky.MoonAngularSize=id=="NEON"and 16 or 9
 for property,file in pairs({SkyboxBk="bk",SkyboxDn="dn",SkyboxFt="ft",SkyboxLf="lf",SkyboxRt="rt",SkyboxUp="up"})do sky[property]="rbxasset://textures/sky/sky512_"..file..".tex"end;sky.Parent=Lighting
 atmosphere=Instance.new("Atmosphere");atmosphere.Name="ACP_Atmosphere_"..id;atmosphere.Color=style.color;atmosphere.Decay=style.tone;atmosphere.Density=id=="CLOUD"and .28 or id=="NEON"and .12 or .20;atmosphere.Haze=id=="COAST"and 1.8 or .6;atmosphere.Glare=id=="COAST"and .5 or .12;atmosphere.Parent=Lighting
 folder=Instance.new("Folder");folder.Name="ACP_LocalWorldVisuals";folder.Parent=workspace
 local kit=game:GetService("ReplicatedStorage"):FindFirstChild("PracaKit")
 local center=Vector3.new(kit and kit:GetAttribute("OriginX")or 0,kit and kit:GetAttribute("OriginY")or 60,kit and kit:GetAttribute("OriginZ")or 0)
 local function colorField(p)
  if p:IsA("BasePart")and(p:GetAttribute("FieldTone")or p.Name=="FieldBase")then
   if savedParts[p]==nil then savedParts[p]={color=p.Color,material=p.Material}end
   p.Material=id=="CLOUD"and Enum.Material.SmoothPlastic or id=="SAKURA"and Enum.Material.Grass or id=="NEON"and Enum.Material.Slate or Enum.Material.Sand
   p.Color=style.tone:Lerp(Color3.fromRGB(255,255,255),((p:GetAttribute("FieldTone")or 1)-1)*.025)
  end
 end
 local ground=world:FindFirstChild("AvatarFieldGround")
 if ground then for _,p in ipairs(ground:GetDescendants())do colorField(p)end;watch=ground.DescendantAdded:Connect(colorField)end
 for i=1,16 do
  local a=math.pi*2*i/16;local x,z=math.cos(a)*440,math.sin(a)*440
  if id=="CLOUD"then
   local p=part("Cloud",Vector3.new(70,20,45),center+Vector3.new(x,40+i%3*14,z),Color3.fromRGB(245,249,255),Enum.PartType.Ball)
   table.insert(moving,{p=p,base=p.Position,phase=i})
  elseif id=="SAKURA"then
   part("Trunk",Vector3.new(5,34,5),center+Vector3.new(x,17,z),Color3.fromRGB(112,88,91))
   part("Sakura",Vector3.new(38,24,38),center+Vector3.new(x,40,z),style.color,Enum.PartType.Ball)
  elseif id=="NEON"then
   local h=45+i%5*18
   part("Skyline",Vector3.new(24,h,20),center+Vector3.new(x,h*.5,z),Color3.fromRGB(45,48,76))
   part("Neon",Vector3.new(1,h,1),center+Vector3.new(x-12,h*.5,z-11),style.color,nil,Enum.Material.Neon)
  else
   part("PalmTrunk",Vector3.new(3,24,3),center+Vector3.new(x,12,z),Color3.fromRGB(135,107,73))
   for j=1,3 do local leaf=part("PalmLeaf",Vector3.new(28,1.4,6),center+Vector3.new(x,25,z),Color3.fromRGB(91,157,132));leaf.Orientation=Vector3.new(0,j*60,12)end
  end
 end
 if id=="COAST"then part("SeaHorizon",Vector3.new(2100,1,2100),center+Vector3.new(0,-5,0),Color3.fromRGB(83,156,183),nil,Enum.Material.Glass)end
 if #moving>0 then connection=Run.RenderStepped:Connect(function(dt)
  clock=clock+dt;for _,e in ipairs(moving)do if e.p.Parent then e.p.Position=e.base+Vector3.new(math.sin(clock*.12+e.phase)*6,math.sin(clock*.3+e.phase)*2,0)end end
 end)end
 return true
end
function M.Destroy()restore();M.Selected="ORIGINAL"end
return M
