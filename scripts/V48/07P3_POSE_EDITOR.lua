-- 07P3_POSE_EDITOR | ModuleScript | ReplicatedStorage
-- V46: pose local R6/R15 por articulacao; confirmar conserva a pose no estudio.
local Run=game:GetService("RunService")
local M={}
local labels={RootJoint="Cintura",Neck="Pescoço",Waist="Cintura",LeftShoulder="Ombro esquerdo",RightShoulder="Ombro direito",LeftElbow="Cotovelo esquerdo",RightElbow="Cotovelo direito",LeftWrist="Pulso esquerdo",RightWrist="Pulso direito",LeftHip="Quadril esquerdo",RightHip="Quadril direito",LeftKnee="Joelho esquerdo",RightKnee="Joelho direito",LeftAnkle="Tornozelo esquerdo",RightAnkle="Tornozelo direito",["Left Shoulder"]="Braço esquerdo",["Right Shoulder"]="Braço direito",["Left Hip"]="Perna esquerda",["Right Hip"]="Perna direita"}
local partKeys={Head="Neck",UpperTorso="Waist",LowerTorso="RootJoint",RightUpperArm="RightShoulder",LeftUpperArm="LeftShoulder",RightLowerArm="RightElbow",LeftLowerArm="LeftElbow",RightHand="RightWrist",LeftHand="LeftWrist",RightUpperLeg="RightHip",LeftUpperLeg="LeftHip",RightLowerLeg="RightKnee",LeftLowerLeg="LeftKnee",RightFoot="RightAnkle",LeftFoot="LeftAnkle"}
local function copy(t)local out={};for k,v in pairs(t)do out[k]={v[1],v[2],v[3]}end;return out end
function M.Bind(model)
 local P={Joints={},Parts={},Values={},Saved={},Offsets={},SavedOffsets={},Editing=false,Playback=false,Connection=nil}
 local motors={}
 local undo,redo={},{}
 for _,o in ipairs(model:GetDescendants())do if(o:IsA("Motor6D")or o:IsA("AnimationConstraint"))and o.Part0 and o.Part1 and(labels[o.Name]or o:IsA("AnimationConstraint")and partKeys[o.Part1.Name])then
  local key=labels[o.Name]and o.Name or partKeys[o.Part1.Name];motors[key]={motor=o,base=o.Transform,kinematic=o:IsA("AnimationConstraint")and o.IsKinematic};if o:IsA("AnimationConstraint")then o.IsKinematic=true end;P.Values[key]={0,0,0};P.Offsets[key]={0,0,0}
  P.Parts[o.Part1.Name]=key;table.insert(P.Joints,{key=key,name=labels[key]})
 end end
 table.sort(P.Joints,function(a,b)return a.name<b.name end);P.Saved=copy(P.Values);P.SavedOffsets=copy(P.Offsets)
 local hum=model:FindFirstChildOfClass("Humanoid");local animator=hum and hum:FindFirstChildOfClass("Animator")
 if animator then for _,track in ipairs(animator:GetPlayingAnimationTracks())do track:Stop(0)end end
 function P.Apply()
  if P.Playback then return end
  for key,v in pairs(P.Values)do local e=motors[key]
   if e and e.motor.Parent then e.motor.Transform=e.base*CFrame.new(table.unpack(P.Offsets[key]))*CFrame.Angles(math.rad(v[1]),math.rad(v[2]),math.rad(v[3]))end
  end
 end
 function P.SetPlayback(on)
  P.Playback=on==true
  for _,e in pairs(motors)do if e.motor:IsA("AnimationConstraint")then e.motor.IsKinematic=not P.Playback end end
  if not P.Playback then P.Apply()end
 end
 function P.Point(key)
  local e=motors[key];if not e then return end
  if e.motor:IsA("Motor6D")then return(e.motor.Part0.CFrame*e.motor.C0*e.motor.Transform).Position end
  return e.motor.Part1.Position
 end
 function P.Capture()
  for key,e in pairs(motors)do if e.motor.Parent then
   local relative=e.base:Inverse()*e.motor.Transform;local x,y,z=relative:ToEulerAnglesXYZ();local pos=relative.Position
   P.Values[key]={math.deg(x),math.deg(y),math.deg(z)};P.Offsets[key]={pos.X,pos.Y,pos.Z}
  end end
  P.Saved=copy(P.Values);P.SavedOffsets=copy(P.Offsets);P.SetPlayback(false);P.Editing=false
 end
 function P.Checkpoint()table.insert(undo,{values=copy(P.Values),offsets=copy(P.Offsets)});if #undo>30 then table.remove(undo,1)end;redo={}end
 function P.Undo()local v=table.remove(undo);if v then table.insert(redo,{values=copy(P.Values),offsets=copy(P.Offsets)});P.Values=v.values;P.Offsets=v.offsets;P.Apply();return true end end
 function P.Redo()local v=table.remove(redo);if v then table.insert(undo,{values=copy(P.Values),offsets=copy(P.Offsets)});P.Values=v.values;P.Offsets=v.offsets;P.Apply();return true end end
 function P.Begin()P.SetPlayback(false);undo={};redo={};P.Values=copy(P.Saved);P.Offsets=copy(P.SavedOffsets);P.Editing=true;P.Apply()end
 function P.Set(key,axis,value)
  if not P.Editing or not P.Values[key]or axis<1 or axis>3 then return false end
  local n=tonumber(value);if not n or n~=n then return false end
  P.Values[key][axis]=math.clamp(n,-120,120);P.Apply();return true
 end
 function P.SetOffset(key,axis,value)
  if not P.Editing or not P.Offsets[key]or axis<1 or axis>3 then return false end
  local n=tonumber(value);if not n or n~=n then return false end
  P.Offsets[key][axis]=math.clamp(n,-1.5,1.5);P.Apply();return true
 end
 function P.Reset(key)
  if not P.Editing then return end;P.Checkpoint()
  if key and P.Values[key]then P.Values[key]={0,0,0};P.Offsets[key]={0,0,0}else for k in pairs(P.Values)do P.Values[k]={0,0,0};P.Offsets[k]={0,0,0}end end;P.Apply()
 end
 function P.Confirm()P.Saved=copy(P.Values);P.SavedOffsets=copy(P.Offsets);P.Editing=false;P.Apply()end
 function P.Cancel()P.Values=copy(P.Saved);P.Offsets=copy(P.SavedOffsets);P.Editing=false;P.Apply()end
 function P.Destroy()
  if P.Connection then P.Connection:Disconnect();P.Connection=nil end
  for _,e in pairs(motors)do if e.motor.Parent then e.motor.Transform=e.base;if e.motor:IsA("AnimationConstraint")then e.motor.IsKinematic=e.kinematic end end end
 end
 P.Connection=Run.PreSimulation:Connect(P.Apply);model.Destroying:Connect(P.Destroy)
 return P
end
return M
