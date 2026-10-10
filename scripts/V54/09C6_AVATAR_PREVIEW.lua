-- 09C6_AVATAR_PREVIEW | ModuleScript | ReplicatedStorage | V54 (SUBSTITUIR)
-- V51: enquadramento por cantos, 360 graus e nova tentativa de cargas nativas.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Native=require(Rep:WaitForChild("08B2_BODY_DESCRIPTION"))
local Load=require(Rep:WaitForChild("08B4_AVATAR_LOAD"))
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
 if view:GetAttribute('V54_Stage')then view.BackgroundTransparency=1 end
 local ownError=options.failed==nil
 local message=Instance.new('TextLabel');message.Name='PreviewLoadStatus';message.BackgroundTransparency=1
 message.Size=UDim2.new(1,-16,0,58);message.Position=UDim2.new(0,8,.5,-50);message.Text='Carregando…';message.TextWrapped=true
 message.Font=Enum.Font.GothamMedium;message.TextSize=13;message.TextColor3=Color3.fromRGB(25,35,49);message.ZIndex=view.ZIndex+3;message.Parent=view
 if options.compact then message.Size=UDim2.new(1,-8,0,22);message.Position=UDim2.new(0,4,1,-24);message.TextSize=10;message.TextWrapped=false;message.TextTruncate=Enum.TextTruncate.AtEnd end
 local retry=Instance.new('TextButton');retry.Name='RetryAvatar';retry.Size=UDim2.new(.7,0,0,44);retry.Position=UDim2.new(.15,0,.5,12)
 retry.Text='Tentar novamente';retry.Font=Enum.Font.GothamBold;retry.TextSize=13;retry.TextColor3=Color3.fromRGB(22,34,30)
 retry.BackgroundColor3=Color3.fromRGB(167,221,186);retry.ZIndex=view.ZIndex+4;retry.Visible=false;retry.Parent=view
 retry.Activated:Connect(function()if P.Alive then M.Mount(view,body,rig,options)end end)
 local gradient=view:FindFirstChildOfClass('UIGradient');if gradient then gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(.92,.94,.98))end
 function P.Fit()if P.Alive and P.Model then M.Fit(cam,view,P.Model,P.Yaw,P.Zoom)end end
 function P.Rotate(degrees)P.Yaw=(P.Yaw+degrees)%360;P.Fit();if options.changed then options.changed(P.Yaw,P.Zoom)end end
 function P.SetYaw(n)P.Yaw=n%360;P.Fit();if options.changed then options.changed(P.Yaw,P.Zoom)end end
 function P.SetZoom(n)P.Zoom=math.clamp(n,.65,1.6);P.Fit();if options.changed then options.changed(P.Yaw,P.Zoom)end end
 function P.Destroy()
  if not P.Alive then return end;P.Alive=false
  for _,c in ipairs(P.Connections)do c:Disconnect()end;P.Connections={}
  if wm.Parent then wm:Destroy()end;if cam.Parent then cam:Destroy()end
  message:Destroy();retry:Destroy()
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
  if not prepared then if P.Alive then message.Text=options.compact and'Prévia indisponível'or'Falha ao preparar o avatar.';message.Visible=ownError;retry.Visible=ownError and options.drag==true and not options.compact;if options.failed then options.failed(message.Text)end end;return end
  if options.emote then desc:AddEmote("PreviewEmote",options.emote)end
  local model,failure=Load.Create(desc,rig or "R15",{alive=function()return P.Alive end,progress=options.progress})
  local ok=model~=nil
  desc:Destroy()
  if not P.Alive or not wm.Parent then if ok and model then model:Destroy()end;return end
  if not ok or not model then message.Text=options.compact and'Prévia indisponível'or(failure or 'Prévia indisponível');message:SetAttribute('LoadError',failure);message.Visible=ownError;retry.Visible=ownError and options.drag==true and not options.compact;if options.failed then options.failed(failure or message.Text)end;return end
  for _,p in ipairs(model:GetDescendants())do
   if p:IsA("BasePart")then p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
   elseif p:IsA("Script")or p:IsA("LocalScript")then p:Destroy()end
  end
  model.Parent=wm;model:PivotTo(CFrame.new());P.Model=model
  message.Visible=false;retry.Visible=false
  view.BackgroundColor3=Color3.fromRGB(182,192,205)
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
