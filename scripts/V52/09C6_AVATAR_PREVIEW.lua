-- 09C6_AVATAR_PREVIEW | ModuleScript | ReplicatedStorage
-- V51: enquadramento por cantos, 360 graus e nova tentativa de cargas nativas.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Native=require(Rep:WaitForChild("08B2_BODY_DESCRIPTION"))
local Verify=require(Rep:WaitForChild("08B3_AVATAR_VERIFY"))
local M={};local mounted=setmetatable({},{__mode="k"})
function M.Bounds(model)
 local mn=Vector3.new(math.huge,math.huge,math.huge);local mx=Vector3.new(-math.huge,-math.huge,-math.huge);local count=0
 for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")and p.Name~="HumanoidRootPart"and p.Transparency<1 then
  local half=p.Size*.5;local cf=p.CFrame;local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
  local h=Vector3.new(math.abs(r.X)*half.X+math.abs(u.X)*half.Y+math.abs(l.X)*half.Z,math.abs(r.Y)*half.X+math.abs(u.Y)*half.Y+math.abs(l.Y)*half.Z,math.abs(r.Z)*half.X+math.abs(u.Z)*half.Y+math.abs(l.Z)*half.Z);local v=p.Position
  mn=Vector3.new(math.min(mn.X,v.X-h.X),math.min(mn.Y,v.Y-h.Y),math.min(mn.Z,v.Z-h.Z))
  mx=Vector3.new(math.max(mx.X,v.X+h.X),math.max(mx.Y,v.Y+h.Y),math.max(mx.Z,v.Z+h.Z));count=count+1
 end end
 if count==0 then return model:GetBoundingBox()end;return CFrame.new((mn+mx)*.5),mx-mn
end
function M.Fit(cam,view,model,yaw,zoom)
 if not cam or not model or not model.Parent then return end
 local cf,size=M.Bounds(model);local vp=view.AbsoluteSize;local a=math.rad(yaw or 180)
 local tan=math.tan(math.rad(cam.FieldOfView)*.5);local aspect=math.max(1,vp.X)/math.max(1,vp.Y)
 local right=Vector3.new(math.cos(a),0,-math.sin(a));local back=CFrame.Angles(0,a,0).LookVector*-1
 local dist=0
 for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
  local p=Vector3.new(size.X*x*.5,size.Y*y*.5,size.Z*z*.5)
  local side=math.abs(p.X*right.X+p.Z*right.Z);local depth=p.X*back.X+p.Z*back.Z
  dist=math.max(dist,depth+math.max(math.abs(p.Y)*1.06/tan,side*1.06/(tan*aspect)))
 end end end
 dist=math.max(.5,dist)/math.clamp(zoom or 1,.65,1.6)
 local target=cf.Position;local off=CFrame.Angles(0,a,0).LookVector*-dist
 cam.CFrame=CFrame.lookAt(target+off,target)
end
function M.Mount(view,body,rig,options)
 options=options or{};local old=mounted[view];if old then old.Destroy()end
 local P={View=view,Yaw=options.yaw or 180,Zoom=options.zoom or 1,Model=nil,Alive=true,Connections={}}
 mounted[view]=P
 for _,o in ipairs(view:GetChildren())do if o:IsA("WorldModel")or o:IsA("Camera")then o:Destroy()end end
 local wm=Instance.new("WorldModel");wm.Parent=view
 local cam=Instance.new("Camera");cam.FieldOfView=28;cam.Parent=view;view.CurrentCamera=cam;P.Camera=cam
 view.Ambient=Color3.fromRGB(235,238,244);view.LightColor=Color3.fromRGB(255,255,255);view.LightDirection=Vector3.new(-.4,-1,-.7)
 view.BackgroundColor3=Color3.fromRGB(137,149,167)
 function P.Fit()if P.Alive and P.Model then M.Fit(cam,view,P.Model,P.Yaw,P.Zoom)end end
 function P.Rotate(degrees)P.Yaw=(P.Yaw+degrees)%360;P.Fit();if options.changed then options.changed(P.Yaw,P.Zoom)end end
 function P.SetYaw(n)P.Yaw=n%360;P.Fit();if options.changed then options.changed(P.Yaw,P.Zoom)end end
 function P.SetZoom(n)P.Zoom=math.clamp(n,.65,1.6);P.Fit();if options.changed then options.changed(P.Yaw,P.Zoom)end end
 function P.Destroy()
  if not P.Alive then return end;P.Alive=false
  for _,c in ipairs(P.Connections)do c:Disconnect()end;P.Connections={}
  if wm.Parent then wm:Destroy()end;if cam.Parent then cam:Destroy()end
  P.Model=nil;if mounted[view]==P then mounted[view]=nil end
 end
 table.insert(P.Connections,view:GetPropertyChangedSignal("AbsoluteSize"):Connect(P.Fit))
 table.insert(P.Connections,view.Destroying:Connect(P.Destroy))
 if options.drag then
  local pointer,last=nil,nil;view.Active=true
  table.insert(P.Connections,view.InputBegan:Connect(function(input)
   if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
    local pos=input.Position
    for _,child in ipairs(view:GetChildren())do if child:IsA("GuiButton")and child.Visible then local q,s=child.AbsolutePosition,child.AbsoluteSize
     if pos.X>=q.X and pos.X<=q.X+s.X and pos.Y>=q.Y and pos.Y<=q.Y+s.Y then return end
    end end
    pointer=input;last=pos.X
   end
  end))
  table.insert(P.Connections,UIS.InputChanged:Connect(function(input)
   if pointer and(input==pointer or(pointer.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement))then P.Rotate(-(input.Position.X-last)*.5);last=input.Position.X end
  end))
  table.insert(P.Connections,UIS.InputEnded:Connect(function(input)if input==pointer or input.UserInputType==Enum.UserInputType.MouseButton1 then pointer=nil end end))
 end
 local copied=A.Copy(body);if A.BodyRequiresR15(copied)then rig="R15"end
 task.spawn(function()
  local prepared,desc=pcall(A.Unpack,copied)
  if not prepared then if P.Alive and options.failed then options.failed("Falha ao preparar o avatar.")end;return end
  if options.emote then desc:AddEmote("PreviewEmote",options.emote)end
  local ok,model=false,nil
  local failure="O Roblox não carregou a prévia desse corpo. Tente novamente."
  for attempt=1,2 do
   if not P.Alive then desc:Destroy();return end
   ok,model=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(desc,rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15,Enum.AssetTypeVerification.Always)end)
   if ok and model then
    local good,why=pcall(function()
     local hum=model:FindFirstChildOfClass("Humanoid");if not hum or not model:FindFirstChild("HumanoidRootPart")then return false end
     local actual=hum:GetAppliedDescription();local same,reason=Native.Matches(desc,actual);actual:Destroy();failure=reason or failure;if not same then return false end
     local physical,why=Verify.Check(model,copied,rig or"R15");failure=why or failure;return physical
    end)
    if good and why then break end;model:Destroy();model=nil;ok=false
   elseif not ok then warn("[V51] Prévia do corpo: "..tostring(model))
   end
   if attempt<2 then task.wait(.35)end
  end
  desc:Destroy()
  if not P.Alive or not wm.Parent then if ok and model then model:Destroy()end;return end
  if not ok or not model then if options.failed then options.failed(failure)end;return end
  for _,p in ipairs(model:GetDescendants())do
   if p:IsA("BasePart")then p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
   elseif p:IsA("Script")or p:IsA("LocalScript")then p:Destroy()end
  end
  model.Parent=wm;model:PivotTo(CFrame.new());P.Model=model
  local total,lum=0,0
  for _,part in ipairs(model:GetDescendants())do if part:IsA("BasePart")and part.Name~="HumanoidRootPart"and part.Transparency<1 then local area=part.Size.X*part.Size.Y+part.Size.Z*part.Size.Y;total=total+area;lum=lum+(part.Color.R*.2126+part.Color.G*.7152+part.Color.B*.0722)*area end end
  view.BackgroundColor3=total>0 and lum/total>.65 and Color3.fromRGB(103,118,143)or Color3.fromRGB(171,181,197)
  local root=model:FindFirstChild("HumanoidRootPart");if root then root.Anchored=true end
  if options.floor then
   local cf,size=M.Bounds(model);local floor=Instance.new("Part");floor.Name="StudioFloor"
   floor.Size=Vector3.new(24,.08,24);floor.Position=Vector3.new(cf.Position.X,cf.Position.Y-size.Y*.5-.08,cf.Position.Z)
   floor.Anchored=true;floor.CanCollide=false;floor.CanTouch=false;floor.CanQuery=false;floor.Color=Color3.fromRGB(153,164,182);floor.Parent=wm
  end
  P.Fit();task.delay(.15,P.Fit)
  if options.ready then options.ready(model)end
 end)
 return P
end
function M.Get(view)return mounted[view]end
function M.Unmount(view)local p=mounted[view];if p then p.Destroy()end end
return M
