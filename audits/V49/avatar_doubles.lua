-- Extends the older doubles with rig parts/lifecycle. No real mesh loading.
local constructor=Instance.new
Instance.new=function(class)
 local o=constructor(class)
 if class=='Humanoid'then
  o.Died=Signal();o.Running=Signal();o.StateChanged=Signal();o.Health=100;o.MaxHealth=100;o.WalkSpeed=16;o.JumpPower=50;o.JumpHeight=7.2;o.UseJumpPower=true;o.DisplayName='Tester'
 end
 if class=='Model'then
  local previous=o.GetPivot
  function o:GetPivot()return previous and previous(self)or CFrame.new(0,4,0)end
 end
 if class=='LocalScript'or class=='Script'then function o:Clone()local n=Instance.new(class);n.Name=self.Name;return n end end
 return o
end
local function parts(char,rig)
 local names=rig==Enum.HumanoidRigType.R6 and{'Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}or{'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'}
 names[#names+1]='HumanoidRootPart'
 for _,name in ipairs(names)do if not char:FindFirstChild(name)then local p=Instance.new('Part');p.Name=name;p.Size=Vector3.new(1,2,1);p.Position=Vector3.new(0,3,0);p.Parent=char end end
 char.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
end
local existingCharacter=pl.Character;rawset(pl,'Character',nil)
setmetatable(pl,{
 __index=function(t,k)if k=='Character'then return rawget(t,'_character')end end,
 __newindex=function(t,k,v)if k=='Character'then rawset(t,'_character',v);if v then t.CharacterAdded:Fire(v)end else rawset(t,k,v)end end
})
pl.Character=existingCharacter
local setup=setupAvatar
function setupAvatar()
 local h=setup();pl.Character.Parent=workspace;parts(pl.Character,Enum.HumanoidRigType.R15)
 local reset=h.ApplyDescriptionResetAsync
 function h:ApplyDescriptionResetAsync(desc)
  if FailReset then error('native apply unavailable')end
  reset(self,desc)
  if desc.UseAvatarSettings then self.applied.Torso=0;self.applied.HeightScale=1 end
  if WrongReadback and(not MismatchID or desc.Torso==MismatchID)then self.applied.Torso=0 end
 end
 return h
end
local create=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig)
 if FailBuild then error('native assets unavailable')end
 local m=create(self,desc,rig);parts(m,rig)
 local h=m.Humanoid;h.applyCount=0
 function m.AnimatorTestSetup()
  local a=h:FindFirstChildOfClass('Animator');a.loaded={}
  function a:LoadAnimation(animation)
   local t={AnimationId=animation.AnimationId,playing=false}
   function t:Play()self.playing=true end;function t:Stop()self.playing=false end
   function t:AdjustSpeed(speed)self.speed=speed end;function t:Destroy()self.destroyed=true end
   a.loaded[#a.loaded+1]=t;return t
  end
  return a
 end
 function h:ApplyDescriptionResetAsync(d)
  if FailReset then error('native unavailable')end;self.applied=d:Clone();self.applyCount=self.applyCount+1
  if WrongReadback and(not MismatchID or d.Torso==MismatchID)then self.applied.Torso=0 end
 end
 if WrongBuild then h.applied.Torso=0 end
 if WrongStructure then local p=m:FindFirstChild('UpperTorso');if p then p:Destroy()end end
 return m
end
function Services.Players:GetCharacterAppearanceInfoAsync()return{playerAvatarType=ProfileRig or 'R15'}end
Services.Players.RespawnTime=5
Services.StarterPlayer=Instance.new('StarterPlayer');local scripts=Instance.new('Folder');scripts.Name='StarterCharacterScripts';scripts.Parent=Services.StarterPlayer
function pl:LoadCharacterAsync()
 local m=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);m.Parent=workspace;self.Character=m;self.CharacterAppearanceLoaded:Fire(m)
end
