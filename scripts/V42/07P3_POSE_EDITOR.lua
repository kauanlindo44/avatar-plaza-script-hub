-- 07P3_POSE_EDITOR | ModuleScript | ReplicatedStorage
-- V42: pose local R6/R15 por articulacao; confirmar conserva a pose no estudio.
local Run=game:GetService("RunService")
local M={}
local labels={Neck="Pescoço",Waist="Cintura",LeftShoulder="Ombro esquerdo",RightShoulder="Ombro direito",LeftElbow="Cotovelo esquerdo",RightElbow="Cotovelo direito",LeftWrist="Pulso esquerdo",RightWrist="Pulso direito",LeftHip="Quadril esquerdo",RightHip="Quadril direito",LeftKnee="Joelho esquerdo",RightKnee="Joelho direito",LeftAnkle="Tornozelo esquerdo",RightAnkle="Tornozelo direito",["Left Shoulder"]="Braço esquerdo",["Right Shoulder"]="Braço direito",["Left Hip"]="Perna esquerda",["Right Hip"]="Perna direita"}
local function copy(t)local out={};for k,v in pairs(t)do out[k]={v[1],v[2],v[3]}end;return out end
function M.Bind(model)
 local P={Joints={},Values={},Saved={},Editing=false,Connection=nil}
 local motors={}
 for _,o in ipairs(model:GetDescendants())do if o:IsA("Motor6D")and labels[o.Name]and o.Part0 and o.Part1 then
  local key=o.Name;motors[key]={motor=o,base=o.Transform};P.Values[key]={0,0,0}
  table.insert(P.Joints,{key=key,name=labels[key]})
 end end
 table.sort(P.Joints,function(a,b)return a.name<b.name end);P.Saved=copy(P.Values)
 local hum=model:FindFirstChildOfClass("Humanoid");local animator=hum and hum:FindFirstChildOfClass("Animator")
 if animator then for _,track in ipairs(animator:GetPlayingAnimationTracks())do track:Stop(0)end end
 function P.Apply()
  for key,v in pairs(P.Values)do local e=motors[key]
   if e and e.motor.Parent then e.motor.Transform=e.base*CFrame.Angles(math.rad(v[1]),math.rad(v[2]),math.rad(v[3]))end
  end
 end
 function P.Begin()P.Values=copy(P.Saved);P.Editing=true;P.Apply()end
 function P.Set(key,axis,value)
  if not P.Editing or not P.Values[key]or axis<1 or axis>3 then return false end
  local n=tonumber(value);if not n or n~=n then return false end
  P.Values[key][axis]=math.clamp(n,-120,120);P.Apply();return true
 end
 function P.Reset(key)
  if not P.Editing then return end
  if key and P.Values[key]then P.Values[key]={0,0,0}else for k in pairs(P.Values)do P.Values[k]={0,0,0}end end;P.Apply()
 end
 function P.Confirm()P.Saved=copy(P.Values);P.Editing=false;P.Apply()end
 function P.Cancel()P.Values=copy(P.Saved);P.Editing=false;P.Apply()end
 function P.Destroy()
  if P.Connection then P.Connection:Disconnect();P.Connection=nil end
  for _,e in pairs(motors)do if e.motor.Parent then e.motor.Transform=e.base end end
 end
 P.Connection=Run.PreSimulation:Connect(P.Apply);model.Destroying:Connect(P.Destroy)
 return P
end
return M
