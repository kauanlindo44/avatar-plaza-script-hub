-- 08B4_AVATAR_LOAD | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Servidor verifica estrutura; cliente carrega conteúdo. Erros nativos mantêm etapa/origem.
local Players=game:GetService('Players');local Content=game:GetService('ContentProvider')
local Rep=game:GetService('ReplicatedStorage');local Starter=game:GetService('StarterPlayer')
local Run=game:GetService('RunService');local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local Native=require(Rep:WaitForChild('08B2_BODY_DESCRIPTION'))
local Verify=require(Rep:WaitForChild('08B3_AVATAR_VERIFY'))
local Diag=require(Rep:WaitForChild('08B5_AVATAR_DIAGNOSTICS'))
local M={VERSION='V56'};local running=0
local function server()local ok,v=pcall(function()return Run:IsServer()end);return ok and v end
local function alive(options)return not options.alive or options.alive()end
local function context(options,body)
 if not options.diagnostic then options.diagnostic=Diag.New({source='08B4_AVATAR_LOAD.Create',items=Diag.Items(body),quiet=true})end
 return options.diagnostic
end
function M.LayeredDisabled(body)
 local layered=false;for _,v in ipairs(body.accessories or{})do if v.layer then layered=true;break end end
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
 if not done then return false,'ContentProvider:PreloadAsync excedeu 12 segundos.',{stage='CONTENT',cause='Timeout de conteúdo'}end
 if not ok then return false,tostring(cause),{stage='CONTENT',cause=tostring(cause)}end
 if #failed>0 then local why='ContentProvider: '..table.concat(failed,', ');return false,why,{stage='CONTENT',cause=why}end
 return true
end
function M.Check(model,desc,rig,options)
 options=options or{};local body=A.Pack(desc);local ctx=context(options,body)
 Diag.Mark(ctx,'STRUCTURE','08B4_AVATAR_LOAD.Check')
 if M.LayeredDisabled(body)then return false,'Layered Clothing está desabilitado nas configurações do projeto.',{stage='LAYERS'}end
 local hum=model and model:FindFirstChildOfClass('Humanoid')
 if not hum or hum.Health<=0 or not model:FindFirstChild('HumanoidRootPart')then return false,'Humanoid ou HumanoidRootPart ausente.',{stage='STRUCTURE'}end
 if hum.RigType.Name~=(rig or'R15')then return false,'Rig esperado '..tostring(rig)..'; encontrado '..hum.RigType.Name..'.',{stage='STRUCTURE'}end
 local required=rig=='R6'and{'Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}or{'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'}
 local found={}
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then
  found[p.Name]=true
  if rig~='R6'then local good,part=pcall(function()return hum:GetBodyPartR15(p)end);if good and part then found[part.Name]=true end end
 end end
 for _,name in ipairs(required)do if not found[name]then return false,'Parte do corpo ausente: '..name..'.',{stage='STRUCTURE'}end end
 local ok,actual=pcall(function()return hum:GetAppliedDescription()end)
 if not ok then return false,tostring(actual),{stage='CONFIRM'}end
 local same,reason=Native.Matches(desc,actual,rig);actual:Destroy()
 if not same then return false,reason,{stage='CONFIRM'}end
 local content,why,detail=M.Content(model,options);if not content then return false,why,detail end
 Diag.Mark(ctx,'LAYERS','08B3_AVATAR_VERIFY.Check')
 local deadline=os.clock()+3;local good,reason2,evidence
 repeat
  if not alive(options)then return false,'Carregamento cancelado.'end
  good,reason2,evidence=Verify.Check(model,body,rig)
  if good then return true end
  if os.clock()<deadline then task.wait(.1)end
 until os.clock()>=deadline
 return false,reason2,{stage='LAYERS',found=evidence}
end
function M.Create(desc,rig,options)
 options=options or{};local body=A.Pack(desc);local ctx=context(options,body)
 if A.BodyRequiresR15(body)then rig='R15'end;rig=rig or'R15'
 if M.LayeredDisabled(body)then local why,detail=Diag.Fail(ctx,'LAYERS','StarterPlayer.LoadCharacterLayeredClothing=Disabled nas configurações do projeto.','Layered Clothing permitido','Disabled');return nil,why,detail end
 local queueUntil=os.clock()+10
 while running>=3 and os.clock()<queueUntil and alive(options)do task.wait(.05)end
 if not alive(options)then return nil,'Carregamento cancelado.'end
 if running>=3 then return nil,'Avatares carregando. Tente novamente em instantes.'end
 running=running+1
 local worked,model,reason,detail=pcall(function()
  local last='O Roblox não carregou esse avatar.';local evidence={stage='CREATE'}
  for attempt=1,2 do
   if not alive(options)then return nil,'Carregamento cancelado.'end
   if options.progress then options.progress(attempt==1 and'Carregando avatar…'or'Tentando novamente…')end
   Diag.Mark(ctx,'CREATE','Players.CreateHumanoidModelFromDescriptionAsync')
   local made,value=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType[rig],Enum.AssetTypeVerification.Always)end)
   if made and value then
    local checked,good,why,proof=pcall(M.Check,value,desc,rig,options)
    if checked and good and alive(options)then return value end
    value:Destroy();last=checked and why or tostring(good);evidence=checked and proof or{stage=ctx.stage}
   else last=made and'Roblox retornou um modelo vazio.'or tostring(value);evidence={stage='CREATE'}end
   if attempt<2 and alive(options)then task.wait(.35)end
  end
  local message,report=Diag.Fail(ctx,evidence and evidence.stage or ctx.stage,last,rig,evidence and evidence.found)
  return nil,message,report
 end)
 running=math.max(0,running-1)
 if not worked then local why,report=Diag.Fail(ctx,ctx.stage,model);return nil,why,report end
 return model,reason,detail
end
return M
