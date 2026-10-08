-- 08B4_AVATAR_LOAD | ModuleScript | ReplicatedStorage | V53 (NOVO)
-- Carregamento compartilhado, conteúdo visual e cancelamento de prévias antigas.
local Players=game:GetService('Players')
local Content=game:GetService('ContentProvider')
local Rep=game:GetService('ReplicatedStorage')
local Starter=game:GetService('StarterPlayer')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local Native=require(Rep:WaitForChild('08B2_BODY_DESCRIPTION'))
local Verify=require(Rep:WaitForChild('08B3_AVATAR_VERIFY'))
local M={VERSION='V53'};local running=0
local function alive(options)return not options.alive or options.alive()end
function M.LayeredDisabled(body)
 local layered=false;for _,v in ipairs(body.accessories or{})do if v.layer then layered=true;break end end
 if not layered then return false end
 local ok,value=pcall(function()return Starter.LoadCharacterLayeredClothing end)
 return ok and value and value.Name=='Disabled' or false
end
function M.Content(model,options)
 options=options or{};local assets={}
 for _,v in ipairs(model:GetDescendants())do
  if v:IsA('MeshPart')or v:IsA('SpecialMesh')or v:IsA('Shirt')or v:IsA('Pants')or v:IsA('Decal')then assets[#assets+1]=v end
 end
 if #assets==0 then return true end
 local done,ok,failed=false,false,false
 task.spawn(function()
  ok=pcall(function()Content:PreloadAsync(assets,function(_,status)
   if status.Name~='Success'then failed=true end
  end)end);done=true
 end)
 local deadline=os.clock()+10
 while not done and os.clock()<deadline and alive(options)do task.wait(.05)end
 if not alive(options)then return false,'Carregamento cancelado.'end
 if not done then return false,'A aparência demorou para carregar. Toque em tentar novamente.'end
 if not ok or failed then return false,'Uma malha ou textura do avatar não carregou. Tente novamente.'end
 return true
end
function M.Check(model,desc,rig,options)
 options=options or{};local body=A.Pack(desc)
 if M.LayeredDisabled(body)then return false,'Habilite Layered Clothing nas configurações de avatar do projeto.'end
 local hum=model and model:FindFirstChildOfClass('Humanoid')
 if not hum or hum.Health<=0 or not model:FindFirstChild('HumanoidRootPart')then return false,'O Roblox retornou um avatar incompleto.'end
 if hum.RigType.Name~=(rig or 'R15')then return false,'O Roblox retornou um rig diferente do solicitado.'end
 local required=rig=='R6'and{'Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}or{'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'}
 local found={}
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then
  found[p.Name]=true
  if rig~='R6'then local good,part=pcall(function()return hum:GetBodyPartR15(p)end);if good and part then found[part.Name]=true end end
 end end
 for _,name in ipairs(required)do if not found[name]then return false,'O Roblox carregou um corpo incompleto. Tente novamente.'end end
 local ok,actual=pcall(function()return hum:GetAppliedDescription()end)
 if not ok then return false,'Não foi possível confirmar o avatar.'end
 local same,reason=Native.Matches(desc,actual,rig);actual:Destroy()
 if not same then return false,reason end
 local content,error=M.Content(model,options);if not content then return false,error end
 local deadline=os.clock()+2;local good,why
 repeat
  if not alive(options)then return false,'Carregamento cancelado.'end
  good,why=Verify.Check(model,body,rig)
  if good then return true end
  if os.clock()<deadline then task.wait(.1)end
 until os.clock()>=deadline
 return false,why
end
function M.Create(desc,rig,options)
 options=options or{};local body=A.Pack(desc)
 if A.BodyRequiresR15(body)then rig='R15'end
 if M.LayeredDisabled(body)then return nil,'Habilite Layered Clothing nas configurações de avatar do projeto.'end
 local queueUntil=os.clock()+10
 while running>=3 and os.clock()<queueUntil and alive(options)do task.wait(.05)end
 if not alive(options)then return nil,'Carregamento cancelado.'end
 if running>=3 then return nil,'Avatares carregando. Tente novamente em instantes.'end
 running=running+1
 local ok,result,reason=pcall(function()
  local last='O Roblox não carregou esse avatar. Tente novamente.'
  for attempt=1,2 do
   if not alive(options)then return nil,'Carregamento cancelado.'end
   if options.progress then options.progress(attempt==1 and 'Carregando avatar…'or'Tentando carregar novamente…')end
   local made,model=pcall(function()
    return Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType[rig or 'R15'],Enum.AssetTypeVerification.Always)
   end)
   if made and model then
    local checked,good,why=pcall(M.Check,model,desc,rig or 'R15',options)
    if checked and good and alive(options)then return model end
    model:Destroy();last=checked and why or 'Falha ao confirmar a aparência. Tente novamente.'
   end
   if attempt<2 and alive(options)then task.wait(.35)end
  end
  return nil,last
 end)
 running=math.max(0,running-1)
 if not ok then warn('[V53] Avatar: '..tostring(result));return nil,'Não foi possível carregar a aparência. Tente novamente.'end
 return result,reason
end
return M
