-- 09B5_AVATAR_RUNTIME | ModuleScript | ServerScriptService | V54 (SUBSTITUIR)
-- Aparência nativa ao entrar, rig explícito e confirmação da aparência efetiva.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Starter=game:GetService("StarterPlayer")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Load=require(Rep:WaitForChild("08B4_AVATAR_LOAD"))
local Last=require(script.Parent:WaitForChild('09B7_LAST_AVATAR'))
local M={};local states={};local started=false
local function state(pl)
 if not states[pl]then states[pl]={ready=false,busy=false,revision=0,epoch=0}end;return states[pl]
end
local function rigOf(h)return h.RigType==Enum.HumanoidRigType.R6 and"R6"or"R15"end
local function disableOverrides(desc)desc.UseAvatarSettings=false end
local function matches(expected,actual,rig)
 if not actual then return false end
 for _,k in ipairs(A.Props)do if tonumber(expected[k])~=tonumber(actual[k])then return false,"O Roblox não confirmou a peça "..k..". Tente novamente."end end
 local wantedParts,actualParts=A.Pack(expected).bodyParts,A.Pack(actual).bodyParts
 for k,v in pairs(wantedParts)do if v.shape~=""and(not actualParts[k]or actualParts[k].shape~=v.shape)then return false,"O Roblox não confirmou o formato da cabeça."end end
 if rig=="R15"then for _,k in ipairs(A.Scales)do if math.abs(expected[k]-actual[k])>.0001 then return false end end end
 for _,k in ipairs(A.Colors)do local a,b=expected[k],actual[k]
  if math.abs(a.R-b.R)+math.abs(a.G-b.G)+math.abs(a.B-b.B)>.015 then return false end
 end
 local wanted,got={},{}
 for _,v in ipairs(expected:GetAccessories(true))do wanted[v.AssetId]=v.AccessoryType.Name end
 for _,v in ipairs(actual:GetAccessories(true))do got[v.AssetId]=v.AccessoryType.Name end
 for id,t in pairs(wanted)do if got[id]~=t then return false end end
 for id in pairs(got)do if wanted[id]==nil then return false end end
 return true
end
local function verify(char,desc,rig)
 local h=char and char:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or rigOf(h)~=rig or not char:FindFirstChild("HumanoidRootPart")then return false end
 local required=rig=="R6"and{"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}or{"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
 local found={}
 for _,p in ipairs(char:GetDescendants())do if p:IsA("BasePart")then
  found[p.Name]=true
  if rig=="R15"then local ok,part=pcall(function()return h:GetBodyPartR15(p)end);if ok and part then found[part.Name]=true end end
 end end
 for _,name in ipairs(required)do if not found[name]then return false,"O Roblox carregou um corpo incompleto. Tente novamente."end end
 local ok,actual=pcall(function()return h:GetAppliedDescription()end)
 if not ok then return false end
 local good,why=matches(desc,actual,rig);actual:Destroy();if not good then return good,why end
 return Load.Check(char,desc,rig)
end
local function copyScripts(old,new,sameRig)
 for _,child in ipairs(old:GetChildren())do
  if(child:IsA("Script")or child:IsA("LocalScript"))and(child.Name~="Animate"or sameRig)and not new:FindFirstChild(child.Name)then child:Clone().Parent=new end
 end
 local templates=Starter:FindFirstChild("StarterCharacterScripts")
 if templates then for _,child in ipairs(templates:GetChildren())do if(child.Name~="Animate"or sameRig)and not new:FindFirstChild(child.Name)then child:Clone().Parent=new end end end
 -- Fallback de movimento no 09C11 quando o gerador não inclui Animate.
end
local function rebuild(pl,old,desc,rig,valid)
 local new,reason=Load.Create(desc,rig,{alive=valid})
 if not new then error(reason)end
 local h=old:FindFirstChildOfClass("Humanoid");local nh=new:FindFirstChildOfClass("Humanoid")
 new.Name=pl.Name;new:SetAttribute("ACP_AvatarManaged",true)
 if h then nh.WalkSpeed=h.WalkSpeed;nh.JumpPower=h.JumpPower;nh.JumpHeight=h.JumpHeight;nh.UseJumpPower=h.UseJumpPower
  nh.MaxHealth=h.MaxHealth;nh.Health=math.min(h.Health,nh.MaxHealth);nh.DisplayName=h.DisplayName
 end
 nh.AutomaticScalingEnabled=true
 if not nh:FindFirstChildOfClass("Animator")then Instance.new("Animator").Parent=nh end
 copyScripts(old,new,h and rigOf(h)==rig)
 local previousRoot=old:FindFirstChild("HumanoidRootPart");local root=new:FindFirstChild("HumanoidRootPart")
 new.PrimaryPart=root;new:PivotTo(previousRoot and previousRoot.CFrame or old:GetPivot());local seat=h and h.SeatPart
 if previousRoot then root.AssemblyLinearVelocity=previousRoot.AssemblyLinearVelocity end
 if not valid()then new:Destroy();error("Seu personagem mudou. Tente novamente.")end
 new.Parent=workspace;pl.Character=new
 if seat and seat.Parent then task.defer(function()if pl.Character==new and nh.Health>0 then pcall(function()seat:Sit(nh)end)end end)end
 for _,child in ipairs(old:GetChildren())do if child:IsA("Tool")then child.Parent=new end end
 old:Destroy()
 nh.Died:Connect(function()
  task.delay(Players.RespawnTime+.5,function()
   if pl.Parent and pl.Character==new and nh.Health<=0 then pcall(function()pl:LoadCharacterAsync()end)end
  end)
 end)
 return new
end
local function apply(pl,desc,rig,forceBody)
 local s=state(pl);if s.busy then error("Seu avatar está carregando. Aguarde um instante.")end
 local old=pl.Character;local hum=old and old:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 then error("Seu personagem ainda não está disponível.")end
 local backup=hum:GetAppliedDescription()
 s.busy=true;s.revision=s.revision+1;local revision=s.revision;disableOverrides(desc)
 local function valid()return pl.Parent and pl.Character==old and states[pl]==s and s.revision==revision and hum.Health>0 end
 local new=old
 local bodyChanged=forceBody==true
 for _,key in ipairs({"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"})do if desc[key]~=backup[key]then bodyChanged=true end end
 local oldParts,newParts=A.Pack(backup).bodyParts,A.Pack(desc).bodyParts
 for k,v in pairs(newParts)do if v.shape~=((oldParts[k]or{}).shape or"")then bodyChanged=true end end
 for k,v in pairs(oldParts)do if v.shape~=((newParts[k]or{}).shape or"")then bodyChanged=true end end
 local ok,result=pcall(function()
  if rigOf(hum)==rig and not bodyChanged then
   hum.AutomaticScalingEnabled=true
   local reset=pcall(function()hum:ApplyDescriptionResetAsync(desc,Enum.AssetTypeVerification.Always)end)
   if not valid()then error("Seu personagem mudou. Tente novamente.")end
   if not reset or not verify(old,desc,rig)then new=rebuild(pl,old,desc,rig,valid)end
  else new=rebuild(pl,old,desc,rig,valid)end
  local nh=new:FindFirstChildOfClass("Humanoid");local actual=nh:GetAppliedDescription()
  local clean,err=A.Clean(A.Pack(actual));if not clean then actual:Destroy();error(err)end
  if s.description then s.description:Destroy()end
  s.description=actual;s.rig=rig;s.ready=true;s.error=nil;s.epoch=s.epoch+1
  pl:SetAttribute("ACP_AvatarError",nil);pl:SetAttribute("ACP_AvatarEpoch",s.epoch)
  return{applied=true,body=clean,liveRig=rig,wantedRig=rig,epoch=s.epoch}
 end)
 if not ok and pl.Character==old and old.Parent then pcall(function()hum:ApplyDescriptionResetAsync(backup,Enum.AssetTypeVerification.Always)end)end
 backup:Destroy();s.busy=false
 if not ok then error(result)end;return result
end
function M.Apply(pl,desc,rig)
 local result=apply(pl,desc,rig=="R6"and not A.BodyRequiresR15(A.Pack(desc))and"R6"or"R15")
 Last.Remember(pl,result.body,result.liveRig);result.saveState='pending';return result
end
local normalize
function M.Description(pl)
 local s=state(pl)
 if not s.ready or s.busy then
  if s.error and not s.loading then task.spawn(normalize,pl,pl.Character)end
  error(s.error or"Seu corpo está carregando. Aguarde um instante.")
 end
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 or(not char:GetAttribute("ACP_AvatarManaged")and not pl:HasAppearanceLoaded())then error("Seu personagem ainda não carregou.")end
 return hum,hum:GetAppliedDescription(),s.epoch
end
normalize=function(pl,char)
 local s=state(pl);if s.loading or not char or pl.Character~=char or char:GetAttribute("ACP_AvatarManaged")then return end
 s.loading=true;s.ready=false;local revision=s.revision;local desc,rig
 local ok,err=pcall(function()
  local restored=false
  if s.description then desc=s.description:Clone();rig=s.rig
  else
   local saved=Last.Read(pl)
   if saved then local prepared,value=pcall(A.Unpack,saved.body)
    if prepared then desc=value;rig=saved.rig;restored=true end
   end
   if not desc then
    desc=Players:GetHumanoidDescriptionFromUserIdAsync(pl.UserId)
    local got,info=pcall(function()return Players:GetCharacterAppearanceInfoAsync(pl.UserId)end)
    rig=got and info and info.playerAvatarType=="R6"and"R6"or"R15"
   end
  end
  disableOverrides(desc)
  local clean,why=A.Clean(A.Pack(desc));if not clean then error(why)end
  if not pl.Parent or states[pl]~=s or pl.Character~=char or s.revision~=revision then return end
  -- Um corpo comprado nasce de novo, sem peças/meshes impostos pelo StarterCharacter.
  local nativeBody=false
  for _,key in ipairs({"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"})do if desc[key]>0 then nativeBody=true end end
  if nativeBody or A.BodyRequiresR15(clean)then rig="R15"end
  local applied,why=pcall(apply,pl,desc,rig,nativeBody)
  if not applied and restored and pl.Character==char then
   pl:SetAttribute('ACP_AvatarRestoreError','Seu look salvo não carregou. Ele continua guardado.')
   warn('[V54] Restaurar avatar '..pl.UserId..': '..tostring(why))
   desc:Destroy();desc=Players:GetHumanoidDescriptionFromUserIdAsync(pl.UserId)
   local fallback=A.Pack(desc);local got,info=pcall(function()return Players:GetCharacterAppearanceInfoAsync(pl.UserId)end)
   rig=A.BodyRequiresR15(fallback)and'R15'or got and info and info.playerAvatarType=='R6'and'R6'or'R15'
   apply(pl,desc,rig,true)
  elseif not applied then error(why)
  elseif restored then pl:SetAttribute('ACP_AvatarRestoreError',nil)end
 end)
 if desc then desc:Destroy()end;s.loading=false
 if not ok and pl.Character==char then s.error=tostring(err):gsub("^.-:%d+:%s*",""):sub(1,220)
  pl:SetAttribute("ACP_AvatarError",s.error);warn("[V54] Avatar de "..pl.UserId..": "..tostring(err))
 end
 if pl.Character~=char and pl.Character and not pl.Character:GetAttribute("ACP_AvatarManaged")then task.defer(normalize,pl,pl.Character)end
end
function M.Start()
 if started then return end;started=true;Last.Start()
 local function added(pl)
  local s=state(pl)
  local function character(char)
   if char:GetAttribute("ACP_AvatarManaged")then return end
   s.ready=false;s.revision=s.revision+1;local tries=0
   local function waitAppearance()
    if not pl.Parent or pl.Character~=char or s.ready or s.loading then return end
    tries=tries+1
    if pl:HasAppearanceLoaded()or tries>=40 then task.spawn(normalize,pl,char)else task.delay(.25,waitAppearance)end
   end
   task.defer(waitAppearance)
  end
  pl.CharacterAdded:Connect(character)
  pl.CharacterAppearanceLoaded:Connect(function(char)if pl.Character==char and not s.ready and not s.loading then task.spawn(normalize,pl,char)end end)
  if pl.Character then character(pl.Character)end
 end
 Players.PlayerAdded:Connect(added);for _,pl in ipairs(Players:GetPlayers())do added(pl)end
 Players.PlayerRemoving:Connect(function(pl)local s=states[pl];if s and s.description then s.description:Destroy()end;states[pl]=nil end)
end
return M
