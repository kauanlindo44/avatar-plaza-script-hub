-- 08B4_AVATAR_LOAD | ModuleScript | ReplicatedStorage | V57 (SUBSTITUIR)
-- Estrutura por item; usa a classificação nativa aplicada e preserva o diagnóstico.
local Players=game:GetService('Players');local Content=game:GetService('ContentProvider')
local Rep=game:GetService('ReplicatedStorage');local Starter=game:GetService('StarterPlayer')
local Run=game:GetService('RunService');local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local Native=require(Rep:WaitForChild('08B2_BODY_DESCRIPTION'))
local Verify=require(Rep:WaitForChild('08B3_AVATAR_VERIFY'))
local Diag=require(Rep:WaitForChild('08B5_AVATAR_DIAGNOSTICS'))
local M={VERSION='V57'};local running=0
local function server()local ok,v=pcall(function()return Run:IsServer()end);return ok and v end
local function alive(options)return not options.alive or options.alive()end
local function context(options,body)
 if not options.diagnostic then options.diagnostic=Diag.New({source='08B4_AVATAR_LOAD.Create',items=Diag.Items(body),quiet=true})end
 return options.diagnostic
end
local function reject(ctx,stage,why,detail)
 detail=detail or{};detail.stage=stage;detail.kind=detail.kind or'validation';detail.source=detail.source or(ctx and ctx.source)or'08B4_AVATAR_LOAD.Content'
 if ctx then ctx.stage=stage end;Diag.Evidence(ctx,detail);return false,why,detail
end
function M.LayeredDisabled(body,applied)
 local layered=false
 for _,v in ipairs(body.accessories or{})do if v.layer and(applied or Verify.LayerTypes[v.type])then layered=true;break end end
 if not layered then return false end
 local ok,value=pcall(function()return Starter.LoadCharacterLayeredClothing end)
 return ok and value and value.Name=='Disabled'or false
end
function M.Content(model,options)
 options=options or{};if server()and not options.forceContent then return true end
 local ctx=options.diagnostic;Diag.Mark(ctx,'CONTENT','08B4_AVATAR_LOAD.Content')
 local assets={};for _,v in ipairs(model:GetDescendants())do
  if not v:FindFirstAncestorOfClass('Tool')and(v:IsA('MeshPart')or v:IsA('SpecialMesh')or v:IsA('Shirt')or v:IsA('Pants')or v:IsA('Decal'))then assets[#assets+1]=v end
 end
 if #assets==0 then return true end
 local done=false;local ok,cause;local failed={}
 task.spawn(function()
  ok,cause=pcall(function()Content:PreloadAsync(assets,function(id,status)
   if status.Name~='Success'then failed[#failed+1]=tostring(id)..'='..status.Name end
  end)end);done=true
 end)
 local deadline=os.clock()+12
 while not done and os.clock()<deadline and alive(options)do task.wait(.05)end
 if not alive(options)then return false,'Carregamento cancelado.'end
 if not done then return reject(ctx,'CONTENT','ContentProvider:PreloadAsync excedeu 12 segundos.',{kind='timeout',check='PRELOAD_TIMEOUT'})end
 if not ok then return reject(ctx,'CONTENT',tostring(cause),{kind='roblox',check='PRELOAD_ASYNC'})end
 if #failed>0 then local why='ContentProvider: '..table.concat(failed,', ');return reject(ctx,'CONTENT',why,{kind='content',check='ASSET_FETCH',expected='Success',found=table.concat(failed,', ')})end
 return true
end
function M.Check(model,desc,rig,options)
 options=options or{};local body=A.Pack(desc);local ctx=context(options,body)
 Diag.Mark(ctx,'STRUCTURE','08B4_AVATAR_LOAD.Check')
 local hum=model and model:FindFirstChildOfClass('Humanoid')
 if not hum or hum.Health<=0 or not model:FindFirstChild('HumanoidRootPart')then return reject(ctx,'STRUCTURE','Humanoid ou HumanoidRootPart ausente.',{check='HUMANOID_ROOT'})end
 if hum.RigType.Name~=(rig or'R15')then return reject(ctx,'STRUCTURE','Rig esperado '..tostring(rig)..'; encontrado '..hum.RigType.Name..'.',{check='RIG',expected=rig,found=hum.RigType.Name})end
 local required=rig=='R6'and{'Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}or{'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'}
 local found={}
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then
  found[p.Name]=true
  if rig~='R6'then local good,part=pcall(function()return hum:GetBodyPartR15(p)end);if good and part then found[part.Name]=true end end
 end end
 for _,name in ipairs(required)do if not found[name]then return reject(ctx,'STRUCTURE','Parte do corpo ausente: '..name..'.',{check='BODY_PART',expected=name,found='Parte ausente'})end end
 local ok,actual=pcall(function()return hum:GetAppliedDescription()end)
 if not ok then return reject(ctx,'CONFIRM',tostring(actual),{kind='roblox',check='GET_APPLIED_DESCRIPTION',source='Humanoid.GetAppliedDescription'})end
 local same,reason=Native.Matches(desc,actual,rig)
 if not same then actual:Destroy();return reject(ctx,'CONFIRM',reason,{check='DESCRIPTION_MATCH',source='08B2_BODY_DESCRIPTION.Matches'})end
 if M.LayeredDisabled(A.Pack(actual),true)then
  actual:Destroy();return reject(ctx,'LAYERS','Layered Clothing está desabilitado nas configurações do projeto.',{kind='configuration',check='LAYERED_SETTING',expected='Enabled ou Default',found='Disabled'})
 end
 local content,why,detail=M.Content(model,options);if not content then actual:Destroy();return false,why,detail end
 Diag.Mark(ctx,'LAYERS','08B3_AVATAR_VERIFY.Check')
 local deadline=os.clock()+3;local good,reason2,evidence
 repeat
  if not alive(options)then actual:Destroy();return false,'Carregamento cancelado.'end
  good,reason2,evidence=Verify.Check(model,body,rig,{applied=actual})
  if good then actual:Destroy();return true end
  if os.clock()<deadline then task.wait(.1)end
 until os.clock()>=deadline
 actual:Destroy();return reject(ctx,'LAYERS',reason2,evidence)
end
function M.Create(desc,rig,options)
 options=options or{};local body=A.Pack(desc);local ctx=context(options,body)
 if A.BodyRequiresR15(body)then rig='R15'end;rig=rig or'R15'
 if M.LayeredDisabled(body)then
  local why,detail=Diag.Fail(ctx,'LAYERS','Layered Clothing está desabilitado nas configurações do projeto.',nil,nil,
   {kind='configuration',check='LAYERED_SETTING',expected='Enabled ou Default',found='Disabled'})
  return nil,why,detail
 end
 local queueUntil=os.clock()+10
 while running>=3 and os.clock()<queueUntil and alive(options)do task.wait(.05)end
 if not alive(options)then return nil,'Carregamento cancelado.'end
 if running>=3 then return nil,'Avatares carregando. Tente novamente em instantes.'end
 running=running+1
 local worked,model,reason,detail=pcall(function()
  local last='O Roblox não carregou esse avatar.';local evidence={stage='CREATE',kind='validation',check='NATIVE_MODEL'}
  for attempt=1,2 do
   if not alive(options)then return nil,'Carregamento cancelado.'end
   if options.progress then options.progress(attempt==1 and'Carregando avatar…'or'Tentando novamente…')end
   Diag.Mark(ctx,'CREATE','Players.CreateHumanoidModelFromDescriptionAsync')
   local made,value=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType[rig],Enum.AssetTypeVerification.Always)end)
   if made and value then
    local checked,good,why,proof=pcall(M.Check,value,desc,rig,options)
    if checked and good and alive(options)then return value end
    value:Destroy();last=checked and why or tostring(good);evidence=checked and proof or{stage=ctx.stage,kind='script',check='VERIFIER_EXCEPTION'}
   else last=made and'Roblox retornou um modelo vazio.'or tostring(value);evidence={stage='CREATE',kind=made and'validation'or'roblox',check='CREATE_MODEL'}end
   if attempt<2 and alive(options)then task.wait(.35)end
  end
  local message,report=Diag.Fail(ctx,evidence and evidence.stage or ctx.stage,last,rig,nil,evidence)
  return nil,message,report
 end)
 running=math.max(0,running-1)
 if not worked then local why,report=Diag.Fail(ctx,ctx.stage,model,nil,nil,{kind='script',check='LOADER_EXCEPTION'});return nil,why,report end
 return model,reason,detail
end
return M
