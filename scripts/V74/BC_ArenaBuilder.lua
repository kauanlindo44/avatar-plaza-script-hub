-- BC_ArenaBuilder | ModuleScript | ServerScriptService | V74 (CRIAR)
-- Geometria própria, leve e distante da praça. Nenhum asset executável de terceiros.
local C=require(game:GetService('ReplicatedStorage'):WaitForChild('BC_Config'))
local M={}
function M.Build()
 local old=workspace:FindFirstChild('BC_Arena');if old then old:Destroy()end
 local A={};local model=Instance.new('Model');model.Name='BC_Arena';model:SetAttribute('BC_Arena',true)
 pcall(function()model.ModelStreamingMode=Enum.ModelStreamingMode.PersistentPerPlayer end)
 local function part(name,size,position,color,collide)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false
  p.Material=Enum.Material.SmoothPlastic;p.Color=color;p.CFrame=CFrame.new(position);p.Parent=model;return p
 end
 A.Model=model;A.Floor=part('BC_Floor',Vector3.new(C.Size,2,C.Size),C.Center,C.Palette.Floor)
 A.Top=C.Center.Y+1;A.Center=C.Center;A.Spawns={};A.ButtonPositions={}
 for _,s in ipairs({{-49,0,2,100},{49,0,2,100},{0,-49,96,2},{0,49,96,2}})do
  part('BC_Boundary',Vector3.new(s[3],16,s[4]),C.Center+Vector3.new(s[1],9,s[2]),C.Palette.Ink)
  part('BC_Rim',Vector3.new(s[3],.3,s[4]),C.Center+Vector3.new(s[1],17.2,s[2]),C.Palette.Cyan,false)
 end
 for i,v in ipairs(C.Spawns)do
  local pos=Vector3.new(C.Center.X+v[1],A.Top,C.Center.Z+v[2]);A.Spawns[i]=pos
  local pad=part('BC_Spawn_'..i,Vector3.new(6,.12,6),pos+Vector3.new(0,.06,0),i%2==0 and C.Palette.Cyan or C.Palette.Violet,false)
  pad.Material=Enum.Material.Neon
 end
 for _,v in ipairs(C.ButtonPositions)do A.ButtonPositions[#A.ButtonPositions+1]=Vector3.new(C.Center.X+v[1],A.Top+1.6,C.Center.Z+v[2])end
 -- Quatro barreiras baixas no centro: preservam corredores e todos os locais do botão.
 for i,v in ipairs({{-8,-8},{8,-8},{-8,8},{8,8}})do
  part('BC_Cover_'..i,Vector3.new(5,3,5),C.Center+Vector3.new(v[1],2.5,v[2]),C.Palette.Surface)
 end
 A.Base=part('BC_ButtonBase',Vector3.new(4,1,4),Vector3.new(0,A.Top+.5,0),C.Palette.Ink,false)
 A.Cap=part('BC_Button',Vector3.new(2.8,.7,2.8),Vector3.new(0,A.Top+1.35,0),C.Palette.Gold,false)
 local prompt=Instance.new('ProximityPrompt');prompt.Name='BC_Press';prompt.ActionText='Apertar';prompt.ObjectText='Botão do Caos'
 prompt.HoldDuration=0;prompt.MaxActivationDistance=C.PromptDistance;prompt.RequiresLineOfSight=true;prompt.Enabled=false;prompt.Parent=A.Cap;A.Prompt=prompt
 function A.Position(pos)
  A.Base.CFrame=CFrame.new(pos-Vector3.new(0,1.1,0));A.Cap.CFrame=CFrame.new(pos-Vector3.new(0,.25,0))
 end
 function A.Show(on)A.Base.Transparency=on and 0 or 1;A.Cap.Transparency=on and 0 or 1;prompt.Enabled=on end
 function A.Pressed()A.Show(false);A.Cap:SetAttribute('BC_PressAnimation',(A.Cap:GetAttribute('BC_PressAnimation')or 0)+1)end
 function A.Inside(pos,margin)
  if typeof(pos)~='Vector3' or pos.X~=pos.X or pos.Y~=pos.Y or pos.Z~=pos.Z then return false end
  local m=C.Size/2-(margin or 2);return math.abs(pos.X-C.Center.X)<=m and math.abs(pos.Z-C.Center.Z)<=m and pos.Y>=A.Top-2 and pos.Y<=A.Top+90
 end
 function A.Clamp(pos,margin)
  local m=C.Size/2-(margin or 4);return Vector3.new(math.clamp(pos.X,C.Center.X-m,C.Center.X+m),pos.Y,math.clamp(pos.Z,C.Center.Z-m,C.Center.Z+m))
 end
 function A.Safe(pos,ignore)
  if not A.Inside(pos,4)then return false end
  local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances=ignore or{}
  for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos+Vector3.new(0,1,0)),Vector3.new(3,3,3),params))do
   if p.CanCollide and p~=A.Floor and p.Name~='BC_Rim'then return false end
  end
  return true
 end
 function A.Reachable(pos,characters)
  local ignored={A.Base,A.Cap};for _,char in ipairs(characters or{})do ignored[#ignored+1]=char end
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances=ignored;ray.RespectCanCollide=true
  local hit=workspace:Raycast(pos+Vector3.new(0,12,0),Vector3.new(0,-20,0),ray)
  if not hit or hit.Instance~=A.Floor or hit.Normal.Y<.8 then return false,'Piso inacessível no local do botão.'end
  local box=OverlapParams.new();box.FilterType=Enum.RaycastFilterType.Exclude;box.FilterDescendantsInstances=ignored
  for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pos),Vector3.new(5,3,5),box))do
   if p.CanCollide and p~=A.Floor then return false,'Obstáculo bloqueia o botão: '..p.Name end
  end
  return true
 end
 function A.Destroy()model:Destroy()end
 A.Show(false);model.Parent=workspace;return A
end
return M
