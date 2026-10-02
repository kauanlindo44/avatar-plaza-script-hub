-- 07P2_STUDIO_AVATAR | ModuleScript | ReplicatedStorage
-- V42: estudio claro, rig real, pose local e camera 360 sem paredes no caminho.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local S=require(Rep:WaitForChild("08D_SKIN_STATE"))
local Presets=require(Rep:WaitForChild("07P0_STUDIO_PRESETS"))
local Pose=require(Rep:WaitForChild("07P3_POSE_EDITOR"))
local M={Center=Vector3.new(0,1400,-10000),Yaw=180,Zoom=1,Frame="FULL",FOV=30,AvatarYaw=0,EmoteSpeed=1,Loop=true}
local generation=0
local lightingKeys={"ClockTime","Brightness","ExposureCompensation","Ambient","OutdoorAmbient","ColorShift_Top","ColorShift_Bottom","EnvironmentDiffuseScale","EnvironmentSpecularScale","FogStart","FogEnd","GlobalShadows"}
local envRules={Exposure={-.5,.65,.05},Brightness={1,4,.2},Time={6,20,.5},Contrast={-.12,.25,.02},Saturation={-.45,.35,.05}}
M.EnvironmentRules=envRules
local function part(name,size,cf,color,material,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;if shape then p.Shape=shape end;p.Parent=M.SetFolder;return p
end
local function bodyBounds(model)
 local mn=Vector3.new(math.huge,math.huge,math.huge);local mx=Vector3.new(-math.huge,-math.huge,-math.huge);local count=0
 for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")and p.Name~="HumanoidRootPart"then
  local half=p.Size*.5;local cf=p.CFrame;local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
  local h=Vector3.new(math.abs(r.X)*half.X+math.abs(u.X)*half.Y+math.abs(l.X)*half.Z,math.abs(r.Y)*half.X+math.abs(u.Y)*half.Y+math.abs(l.Y)*half.Z,math.abs(r.Z)*half.X+math.abs(u.Z)*half.Y+math.abs(l.Z)*half.Z);local v=p.Position
  mn=Vector3.new(math.min(mn.X,v.X-h.X),math.min(mn.Y,v.Y-h.Y),math.min(mn.Z,v.Z-h.Z))
  mx=Vector3.new(math.max(mx.X,v.X+h.X),math.max(mx.Y,v.Y+h.Y),math.max(mx.Z,v.Z+h.Z));count=count+1
 end end
 if count<2 then return model:GetBoundingBox()end;return CFrame.new((mn+mx)*.5),mx-mn
end
local function fixRig()
 if not M.Model then return end
 local hum=M.Model:FindFirstChildOfClass("Humanoid")
 if hum then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;hum.AutoRotate=false end
 for _,x in ipairs(M.Model:GetDescendants())do
  if x:IsA("BasePart")then x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;x.Massless=true
  elseif x:IsA("Script")or x:IsA("LocalScript")then x:Destroy()end
 end
 local root=M.Model:FindFirstChild("HumanoidRootPart");if root then root.Anchored=true end
end
function M.Fit()
 if not M.Camera or not M.Model then return end
 local cf,size=bodyBounds(M.Model);local target=cf.Position;local height=size.Y;local margin=1.18
 if M.Frame=="MEDIUM"then height=height*.62;target=target+Vector3.new(0,size.Y*.18,0)
 elseif M.Frame=="FACE"then height=height*.32;target=target+Vector3.new(0,size.Y*.33,0)end
 local vp=M.Camera.ViewportSize;local aspect=math.max(1,vp.X)/math.max(1,vp.Y)
 local fov=math.rad(M.FOV);local tangent=math.tan(fov*.5)
 local a=M.Margins or{0,0,0,0};local aw=math.max(80,vp.X-a[1]-a[3]);local ah=math.max(80,vp.Y-a[2]-a[4])
 local angle=math.rad(M.Yaw);local width=size.X*math.abs(math.cos(angle))+size.Z*math.abs(math.sin(angle));local depth=size.Z*math.abs(math.cos(angle))+size.X*math.abs(math.sin(angle))
 local dist=(math.max(height*.5*margin/(tangent*ah/math.max(1,vp.Y)),width*.5*margin/(tangent*aw/math.max(1,vp.Y)))+depth*.5)/M.Zoom
 local off=CFrame.Angles(0,math.rad(M.Yaw),0).LookVector*-dist
 local base=CFrame.lookAt(target+off,target)
 local nx=2*(a[1]+aw*.5)/math.max(1,vp.X)-1;local ny=1-2*(a[2]+ah*.5)/math.max(1,vp.Y)
 local shift=base.RightVector*(-nx*dist*tangent*aspect)+base.UpVector*(-ny*dist*tangent)
 M.Camera.CFrame=CFrame.lookAt(target+off+shift,target+shift);M.Camera.FieldOfView=M.FOV
 if M.Backdrop and M.Backdrop.Parent then
  local back=target+M.Camera.CFrame.LookVector*math.max(65,dist+20)
  M.Backdrop.CFrame=CFrame.lookAt(back,target)
 end
end
function M.SetMargins(l,t,r,b)M.Margins={l,t,r,b};M.Fit()end
function M.SetFrame(v)M.Frame=v or"FULL";M.Fit()end
function M.SetZoom(v)M.Zoom=math.clamp(tonumber(v)or 1,.65,1.55);M.Fit()end
function M.Rotate(v)M.Yaw=(M.Yaw+(tonumber(v)or 0))%360;M.Fit()end
function M.SetYaw(v)M.Yaw=tonumber(v)or 180;M.Fit()end
function M.SetFOV(v)M.FOV=math.clamp(tonumber(v)or 30,24,44);M.Fit()end
function M.SetAvatarYaw(v)
 M.AvatarYaw=tonumber(v)or 0
 if M.Model then M.Model:PivotTo(CFrame.new(M.Center)*CFrame.Angles(0,math.rad(M.AvatarYaw),0));M.Fit()end
end
local function applyEnvironment()
 local e=M.Environment;if not e then return end
 Lighting.ClockTime=e.Time;Lighting.Brightness=e.Brightness;Lighting.ExposureCompensation=e.Exposure
 if M.ColorEffect then M.ColorEffect.Contrast=e.Contrast;M.ColorEffect.Saturation=e.Saturation end
end
function M.SetEnvironment(key,value)
 local rule=envRules[key];local n=tonumber(value)
 if not rule or not M.Environment or not n or n~=n then return false end
 M.Environment[key]=math.clamp(n,rule[1],rule[2]);applyEnvironment();return true
end
function M.ResetEnvironment()
 M.Environment={Exposure=.1,Brightness=2.5,Time=13,Contrast=.02,Saturation=0};applyEnvironment()
end
function M.SetLight(id)
 for _,p in ipairs(Presets.Lights)do if p.id==id then Lighting.Ambient=p.ambient;Lighting.OutdoorAmbient=p.ambient;Lighting.ColorShift_Top=p.light;M.Light=id;return true end end
 return false
end
function M.BuildSet(id)
 if not M.SetFolder then return false end
 local selected=Presets.Backgrounds[1]
 for _,p in ipairs(Presets.Backgrounds)do if p.id==id then selected=p end end
 M.SetFolder:ClearAllChildren();M.Background=selected.id
 local cf,size=bodyBounds(M.Model);local y=cf.Position.Y-size.Y*.5-.08
 part("StudioFloor",Vector3.new(280,.12,280),CFrame.new(M.Center.X,y,M.Center.Z),selected.b)
 M.Backdrop=part("Backdrop",Vector3.new(420,320,.3),CFrame.new(M.Center+Vector3.new(0,0,90)),selected.a)
 local function at(x,h,z)return CFrame.new(M.Center.X+x,y+h,M.Center.Z+z)end
 if selected.id=="SKY"then
  for i=1,8 do part("Cloud"..i,Vector3.new(7,3,4),at(-35+i*8,8+i%3*3,48),selected.accent,nil,Enum.PartType.Ball)end
 elseif selected.id=="SUNSET"then
  part("Sun",Vector3.new(16,16,2),at(0,14,52),selected.accent,Enum.Material.Neon,Enum.PartType.Ball)
  for i=1,6 do part("Horizon"..i,Vector3.new(18,.12,.3),at(0,3+i*2,50),selected.b)end
 elseif selected.id=="GARDEN"then
  for _,x in ipairs({-26,-18,18,26})do
   part("Planter",Vector3.new(4,3,4),at(x,1.5,42),selected.b)
   part("Leaves",Vector3.new(7,10,7),at(x,8,42),selected.accent,nil,Enum.PartType.Ball)
  end
 elseif selected.id=="NIGHT"then
  for i=1,24 do local x=-45+(i*17)%90;local h=4+(i*7)%27
   part("Star"..i,Vector3.new(.35,.35,.35),at(x,h,55),selected.accent,Enum.Material.Neon,Enum.PartType.Ball)
  end
 else
  for _,x in ipairs({-30,30})do part("LightPanel",Vector3.new(1,22,1),at(x,11,50),selected.accent,Enum.Material.Neon)end
 end
 M.Fit();return true
end
local function saveLighting()
 local saved={Properties={},Effects={},Atmospheres={}}
 for _,key in ipairs(lightingKeys)do saved.Properties[key]=Lighting[key]end
 for _,o in ipairs(Lighting:GetChildren())do
  if o:IsA("PostEffect")then saved.Effects[o]=o.Enabled;o.Enabled=false
  elseif o:IsA("Atmosphere")then saved.Atmospheres[o]={o.Density,o.Haze,o.Glare};o.Density=0;o.Haze=0;o.Glare=0 end
 end
 M.SavedLighting=saved
 Lighting.FogStart=100000;Lighting.FogEnd=100001;Lighting.GlobalShadows=false
 Lighting.EnvironmentDiffuseScale=1;Lighting.EnvironmentSpecularScale=.5
 Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0)
 M.ColorEffect=Instance.new("ColorCorrectionEffect");M.ColorEffect.Name="ACP_PhotoLocalColor";M.ColorEffect.Parent=Lighting
 M.SetLight("BRIGHT");M.ResetEnvironment()
end
local function restoreLighting()
 if M.ColorEffect then M.ColorEffect:Destroy();M.ColorEffect=nil end
 local s=M.SavedLighting;if not s then return end
 for key,v in pairs(s.Properties)do Lighting[key]=v end
 for o,enabled in pairs(s.Effects)do if o.Parent then o.Enabled=enabled end end
 for o,v in pairs(s.Atmospheres)do if o.Parent then o.Density=v[1];o.Haze=v[2];o.Glare=v[3]end end
 M.SavedLighting=nil;M.Environment=nil
end
function M.StopEmote()if M.Track then pcall(function()M.Track:Stop(0)end);M.Track=nil end end
function M.SetEmoteSpeed(v)M.EmoteSpeed=tonumber(v)or 1 end
function M.SetLoop(on)M.Loop=on==true end
function M.PlayEmote()return false,"Use o editor de poses neste estúdio."end
function M.Enter()
 if M.Folder then M.Exit()end
 local cam=workspace.CurrentCamera;if not cam then return false,"Câmera indisponível."end
 if not S.Current then return false,"Abra o catálogo primeiro para carregar seu avatar."end
 generation=generation+1;local mine=generation
 local body,rig=A.Copy(S.Current),S.Rig
 local d=A.Unpack(body);local ok,model=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(d,rig=="R6"and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15)end);d:Destroy()
 if mine~=generation then if ok and model then model:Destroy()end;return false,"Estúdio fechado."end
 if not ok or not model then return false,"Não consegui criar sua prévia. Tente novamente."end
 M.SavedCamera={Type=cam.CameraType,Subject=cam.CameraSubject,CFrame=cam.CFrame,FOV=cam.FieldOfView}
 M.Folder=Instance.new("Folder");M.Folder.Name="ACP_PhotoPreview_"..Players.LocalPlayer.UserId;M.Folder.Parent=workspace
 M.SetFolder=Instance.new("Folder");M.SetFolder.Name="Set";M.SetFolder.Parent=M.Folder
 M.Camera=cam;cam.CameraType=Enum.CameraType.Scriptable
 M.Model=model;model.Name="PhotoAvatar";model.Parent=M.Folder;model:PivotTo(CFrame.new(M.Center));fixRig()
 M.Margins=nil;M.Pose=Pose.Bind(model);M.Yaw=180;M.Zoom=1;M.Frame="FULL";M.FOV=30;M.AvatarYaw=0
 saveLighting();M.BuildSet("STUDIO");M.Fit()
 M.Resize=cam:GetPropertyChangedSignal("ViewportSize"):Connect(M.Fit)
 return true
end
function M.Exit()
 generation=generation+1;M.StopEmote()
 if M.Resize then M.Resize:Disconnect();M.Resize=nil end
 if M.Pose then M.Pose.Destroy();M.Pose=nil end
 if M.Folder then M.Folder:Destroy()end
 M.Folder=nil;M.SetFolder=nil;M.Model=nil;M.Backdrop=nil;restoreLighting()
 local cam=workspace.CurrentCamera;local s=M.SavedCamera
 if cam and s then
  cam.FieldOfView=s.FOV
  if s.Subject and s.Subject.Parent then cam.CameraSubject=s.Subject
  else local ch=Players.LocalPlayer.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");if hum then cam.CameraSubject=hum end end
  cam.CFrame=s.CFrame;cam.CameraType=s.Type or Enum.CameraType.Custom
 end
 M.SavedCamera=nil;M.Camera=nil
end
return M
