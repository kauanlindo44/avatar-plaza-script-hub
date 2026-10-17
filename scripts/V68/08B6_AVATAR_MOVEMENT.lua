-- 08B6_AVATAR_MOVEMENT | ModuleScript | ReplicatedStorage | V68 (SUBSTITUIR)
-- Posicionamento pelo Humanoid nativo: não usa o tamanho dos acessórios como perna.
local M={Version='V68'}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<100000 end
local function humanoid(model)return model and model:FindFirstChildOfClass('Humanoid')end
function M.Clearance(model)
 local h=humanoid(model);local root=model and model:FindFirstChild('HumanoidRootPart')
 if not h or not root or not finite(h.HipHeight)or h.HipHeight<0 then return nil,'HipHeight inválido no corpo gerado pelo Roblox.'end
 local extra=0
 if h.RigType==Enum.HumanoidRigType.R6 then local leg=model:FindFirstChild('Left Leg');extra=leg and leg.Size.Y or 0 end
 local height=root.Size.Y*.5+h.HipHeight+extra
 if not finite(height)or height<.05 or height>100 then return nil,'Altura de apoio inválida no corpo gerado.'end
 return height
end
-- Mede somente os pés/pernas do rig em repouso; roupa, cabelo e acessórios não dão apoio.
function M.Support(model)
 local h=humanoid(model);local root=model and model:FindFirstChild('HumanoidRootPart');if not h or not root then return end
 local lowest;local feet={LeftFoot=true,RightFoot=true,['Left Leg']=true,['Right Leg']=true}
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')and not p:FindFirstAncestorOfClass('Accessory')and not p:FindFirstAncestorOfClass('Tool')then
  local name=p.Name;if h.RigType~=Enum.HumanoidRigType.R6 then pcall(function()local kind=h:GetBodyPartR15(p);if kind and feet[kind.Name]then name=kind.Name end end)end
  if feet[name]then
  local cf,z=p.CFrame,p.Size;local extent=(math.abs(cf.RightVector.Y)*z.X+math.abs(cf.UpVector.Y)*z.Y+math.abs(cf.LookVector.Y)*z.Z)*.5
  local bottom=p.Position.Y-extent;lowest=lowest and math.min(lowest,bottom)or bottom
  end
 end end
 if not lowest then return end
 local measured=root.Position.Y-lowest;if not finite(measured)or measured<=0 or measured>80 then return end
 local native=M.Clearance(model);if not native then return end
 local support=math.max(native,measured);local extra=0
 if h.RigType==Enum.HumanoidRigType.R6 then local leg=model:FindFirstChild('Left Leg');extra=leg and leg.Size.Y or 0 end
 local desired=math.max(0,support-root.Size.Y*.5-extra)
 if desired>h.HipHeight+.12 then h.HipHeight=desired;model:SetAttribute('ACP_SupportAdjusted',true)end
 model:SetAttribute('ACP_SupportHipHeight',desired);model:SetAttribute('ACP_SupportHeight',support)
 return support
end
local function floorAt(position,exclude)
 local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Exclude;p.FilterDescendantsInstances=exclude;p.RespectCanCollide=true
 local hit=workspace:Raycast(position+Vector3.new(0,48,0),Vector3.new(0,-176,0),p)
 if hit and hit.Normal.Y>.55 then return hit.Position.Y end
end
local function upright(cf,position)
 local look=cf.LookVector;local direction=Vector3.new(look.X,0,look.Z)
 if direction.Magnitude<.01 then direction=Vector3.new(0,0,-1)else direction=direction.Unit end
 return CFrame.lookAt(position,position+direction)
end
function M.Prepare(model)
 local h=humanoid(model);local root=model and model:FindFirstChild('HumanoidRootPart')
 if not h or not root then return false,'Humanoid ou HumanoidRootPart ausente.'end
 local height,why=M.Clearance(model);if not height then return false,why end
 height=M.Support(model)or height;pcall(function()h.EvaluateStateMachine=true end)
 h.AutoRotate=true;h.PlatformStand=false;pcall(function()h:SetStateEnabled(Enum.HumanoidStateType.Running,true);h:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)end)
 for _,p in ipairs(model:GetDescendants())do
  if p:IsA('BasePart')then
   p.Anchored=false
   if p:FindFirstAncestorOfClass('Accessory')then p.CanCollide=false;p.CanTouch=false;p.Massless=true end
  elseif p:IsA('AnimationConstraint')then p.IsKinematic=true end
 end
 root.Anchored=false;root.Massless=false;root.CanCollide=false
 root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 model:SetAttribute('ACP_GroundClearance',height)
 return true,height
end
function M.Place(model,previous)
 local ok,height=M.Prepare(model);if not ok then return false,height end
 local root=model:FindFirstChild('HumanoidRootPart');local oldRoot=previous and previous:FindFirstChild('HumanoidRootPart')
 local cf=oldRoot and oldRoot.CFrame or model:GetPivot();local position=cf.Position
 local oldHeight=M.Clearance(previous)or height;local ground=floorAt(position,{model,previous})
 -- Ao saltar, conserva a altura dos pés; no chão, usa a altura do novo corpo.
 local grounded=ground and math.abs(position.Y-oldHeight-ground)<4
 local y=grounded and ground+height+.08 or position.Y+height-oldHeight
 model.PrimaryPart=root;model:PivotTo(upright(cf,Vector3.new(position.X,y,position.Z)))
 root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 model:SetAttribute('ACP_MovementStage','PLACED');return true
end
function M.Settle(model,valid,report)
 -- Revalidação limitada durante cinco segundos; nunca teleporta a cada frame.
 for _,delay in ipairs({.25,1,2.5,5})do task.delay(delay,function()
  if not model.Parent or valid and not valid()then return end
  local h=humanoid(model);local root=model:FindFirstChild('HumanoidRootPart')
  if not h or h.Health<=0 or not root or h.Sit or model:GetAttribute('ACP_PersonalFly')then return end
  pcall(function()if h.PlatformStand then h.PlatformStand=false;h:ChangeState(Enum.HumanoidStateType.GettingUp)end end)
  local target=model:GetAttribute('ACP_SupportHipHeight');if target and h.HipHeight<target-.12 then h.HipHeight=target end
  local height,why=M.Clearance(model);if not height then if report then report(why)end;return end
  local ground=floorAt(root.Position,{model});local penetration=ground and ground-(root.Position.Y-height)
  local tipped=root.CFrame.UpVector.Y<.65;local sinking=penetration and penetration>.18 and penetration<height+4
  if tipped or sinking then
   local position=root.Position;local y=sinking and ground+height+.08 or position.Y
   model:PivotTo(upright(root.CFrame,Vector3.new(position.X,y,position.Z)))
   root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
   model:SetAttribute('ACP_MovementStage',tipped and'UPRIGHT_REPAIRED'or'GROUND_REPAIRED')
   if report then report('Apoio corrigido: '..model:GetAttribute('ACP_MovementStage')..' | HipHeight='..h.HipHeight..' | apoio='..height)end
  else model:SetAttribute('ACP_MovementStage','VERIFIED')end
 end)end
end
return M
