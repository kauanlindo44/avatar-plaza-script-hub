-- 07P2_STUDIO_AVATAR | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Cópia verificada do avatar, emotes transacionais e cenário local independente.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Load=require(Rep:WaitForChild("08B4_AVATAR_LOAD"))
local S=require(Rep:WaitForChild("08D_SKIN_STATE"))
local Presets=require(Rep:WaitForChild("07P0_STUDIO_PRESETS"))
local Pose=require(Rep:WaitForChild("07P3_POSE_EDITOR"))
local M={Center=Vector3.new(0,1400,-10000),Yaw=180,Zoom=1,Frame="FULL",FOV=30,AvatarYaw=0,Pitch=0,EmoteSpeed=1,Loop=true}
local generation=0
local lightingKeys={"ClockTime","Brightness","ExposureCompensation","Ambient","OutdoorAmbient","ColorShift_Top","ColorShift_Bottom","EnvironmentDiffuseScale","EnvironmentSpecularScale","FogStart","FogEnd","GlobalShadows"}
local envRules={Exposure={-.5,.65,.05},Brightness={1,4,.2},Time={6,20,.5},Contrast={-.12,.25,.02},Saturation={-.45,.35,.05}}
M.EnvironmentRules=envRules
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local Sets=require(Rep:WaitForChild("07P6_STUDIO_SETS"))
local function bodyBounds(model)return Preview.Bounds(model)end
local function fixRig(model)
 model=model or M.Model;if not model then return end
 local hum=model:FindFirstChildOfClass("Humanoid")
 if hum then
  hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;hum.AutoRotate=false
  if not hum:FindFirstChildOfClass("Animator")then local animator=Instance.new("Animator");animator.Parent=hum end
 end
 for _,x in ipairs(model:GetDescendants())do
  if x:IsA("BasePart")then x.CanCollide=false;x.CanTouch=false;x.CanQuery=x.Parent==model and x.Name~="HumanoidRootPart";x.Massless=true
  elseif x:IsA("Script")or x:IsA("LocalScript")then x:Destroy()end
 end
 local root=model:FindFirstChild("HumanoidRootPart");if root then root.Anchored=true end
end
function M.Fit()
 if not M.Camera or not M.Model then return end
 local cf,size=bodyBounds(M.Model);local target=cf.Position;local height=size.Y;local margin=1.08
 if M.Frame=="MEDIUM"then height=height*.62;target=target+Vector3.new(0,size.Y*.18,0)
 elseif M.Frame=="FACE"then height=height*.32;target=target+Vector3.new(0,size.Y*.33,0)end
 local vp=M.Camera.ViewportSize;local aspect=math.max(1,vp.X)/math.max(1,vp.Y)
 local fov=math.rad(M.FOV);local tangent=math.tan(fov*.5)
 local a=M.Margins or{0,0,0,0};local aw=math.max(80,vp.X-a[1]-a[3]);local ah=math.max(80,vp.Y-a[2]-a[4])
 local angle=math.rad(M.Yaw);local width=size.X*math.abs(math.cos(angle))+size.Z*math.abs(math.sin(angle));local depth=size.Z*math.abs(math.cos(angle))+size.X*math.abs(math.sin(angle))
 local dist=(math.max(height*.5*margin/(tangent*ah/math.max(1,vp.Y)),width*.5*margin/(tangent*aw/math.max(1,vp.Y)))+depth*.5)/M.Zoom
 local off=CFrame.Angles(math.rad(M.Pitch),math.rad(M.Yaw),0).LookVector*-dist
 local base=CFrame.lookAt(target+off,target)
 local nx=2*(a[1]+aw*.5)/math.max(1,vp.X)-1;local ny=1-2*(a[2]+ah*.5)/math.max(1,vp.Y)
 local shift=base.RightVector*(-nx*dist*tangent*aspect)+base.UpVector*(-ny*dist*tangent)
 M.Camera.CFrame=CFrame.lookAt(target+off+shift,target+shift);M.Camera.FieldOfView=M.FOV

end
function M.SetMargins(l,t,r,b)M.Margins={l,t,r,b};M.Fit()end
function M.SetFrame(v)M.Frame=v or"FULL";M.Fit()end
function M.SetZoom(v)M.Zoom=math.clamp(tonumber(v)or 1,.65,1.55);M.Fit()end
function M.Rotate(v)M.SetAvatarYaw(M.AvatarYaw+(tonumber(v)or 0))end
function M.RotateCamera(dx,dy)M.Yaw=(M.Yaw+(tonumber(dx)or 0))%360;M.Pitch=math.clamp(M.Pitch+(tonumber(dy)or 0),-25,25);M.Fit()end
function M.SetYaw(v)M.Yaw=tonumber(v)or 180;M.Fit()end
function M.SetFOV(v)M.FOV=math.clamp(tonumber(v)or 30,24,44);M.Fit()end
function M.SetAvatarYaw(v)
 M.AvatarYaw=tonumber(v)or 0
 if M.Model then M.Model:PivotTo(CFrame.new(M.Center)*CFrame.Angles(0,math.rad(M.AvatarYaw),0))end
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
 if M.Scene then M.Scene.Destroy();M.Scene=nil end
 M.SetFolder:ClearAllChildren();M.Background=selected.id
 local cf,size=bodyBounds(M.Model);local y=cf.Position.Y-size.Y*.5-.08
 M.Scene=Sets.Build(M.SetFolder,M.Center,y,selected);M.Backdrop=M.Scene.Backdrop
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
function M.StopEmote(keepPending)
 if not keepPending then generation=generation+1 end
 local track=M.Track;M.Track=nil;if M.EmoteStopped then M.EmoteStopped:Disconnect();M.EmoteStopped=nil end
 if track then pcall(function()track:Stop(0)end)end
 if M.Pose then M.Pose.SetPlayback(false)end
end
function M.SetEmoteSpeed(v)M.EmoteSpeed=math.clamp(tonumber(v)or 1,.25,2);if M.Track then M.Track:AdjustSpeed(M.EmoteSpeed)end end
function M.SetLoop(on)M.Loop=on==true;if M.Track then M.Track.Looped=M.Loop end end
function M.FreezeEmote()
 if not M.Track or not M.Pose then return false end
 M.Track:AdjustSpeed(0);M.Pose.Capture();M.Track:Stop(0);M.Track=nil;M.Pose.Apply();return true
end
function M.PlayEmote(id)
 if not M.Model or not S.Current then return false,"Abra o estúdio primeiro."end
 if M.Model:FindFirstChildOfClass('Humanoid').RigType.Name~='R15'then return false,"As animações do catálogo exigem R15."end
 id=tonumber(id);if not id or id%1~=0 or id<=0 then return false,"Emote inválido."end
 generation=generation+1;local mine=generation
 local avatar=game:GetService("AvatarEditorService")
 local checked,item=pcall(function()return avatar:GetItemDetailsAsync(id,Enum.AvatarItemType.Asset)end)
 if mine~=generation or not M.Folder then return false,"Estúdio fechado."end
 local kind=checked and item and item.AssetType;kind=typeof(kind)=="EnumItem"and kind.Name or tostring(kind)
 if kind~="EmoteAnimation"and kind~=tostring(Enum.AvatarAssetType.EmoteAnimation.Value)then return false,"Escolha uma animação do catálogo."end
 local live=M.Model:FindFirstChildOfClass('Humanoid'):GetAppliedDescription();local desc=A.Unpack(A.Pack(live));live:Destroy();local em=desc:GetEmotes();em.PhotoEmote={id};desc:SetEmotes(em)
 local model,reason=Load.Create(desc,"R15",{alive=function()return mine==generation and M.Folder~=nil end});local ok=model~=nil;desc:Destroy()
 if mine~=generation or not M.Folder then if ok and model then model:Destroy()end;return false,"Estúdio fechado."end
 if not ok or not model then return false,reason or "A animação não carregou. Tente outra."end
 local previous=M.Model;model.Name="PendingPhotoEmote";model.Parent=M.Folder;model:PivotTo(CFrame.new(M.Center)*CFrame.Angles(0,math.rad(M.AvatarYaw),0));fixRig(model)
 local transparency={};for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then transparency[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end end
 local pose=Pose.Bind(model);pose.SetPlayback(true);local hum=model:FindFirstChildOfClass("Humanoid")
 local animator=hum:FindFirstChildOfClass("Animator");local started
 local connection=animator.AnimationPlayed:Connect(function(track)started=track end)
 local played,result=pcall(function()return hum:PlayEmoteAsync("PhotoEmote")end)
 local deadline=os.clock()+2
 while played and result and not started and mine==generation and M.Model==previous and os.clock()<deadline do
  local tracks=animator:GetPlayingAnimationTracks();started=tracks[#tracks];if not started then task.wait(.05)end
 end
 connection:Disconnect()
 if mine~=generation or M.Model~=previous then if started then pcall(function()started:Stop(0)end)end;pose.Destroy();model:Destroy();return false,"Emote cancelado."end
 if not played or not result or not started then pose.Destroy();model:Destroy();return false,"Este emote não carregou. Sua pose anterior foi mantida. Tente outro."end
 M.StopEmote(true);if M.Pose then M.Pose.Destroy()end;previous:Destroy();M.Model=model;M.Pose=pose;model.Name='PhotoAvatar'
 for p,value in pairs(transparency)do p.LocalTransparencyModifier=value end
 M.Track=started;M.Track.Priority=Enum.AnimationPriority.Action;M.Track.Looped=M.Loop;M.Track:AdjustSpeed(M.EmoteSpeed)
 M.EmoteStopped=started.Stopped:Connect(function()if M.Track==started then M.Track=nil;if M.Pose then M.Pose.SetPlayback(false)end end end)
 M.Fit();return true
end
function M.Enter()
 if M.Folder then M.Exit()end
 local cam=workspace.CurrentCamera;if not cam then return false,"Câmera indisponível."end
 if not S.Current then return false,"Abra o catálogo primeiro para carregar seu avatar."end
 generation=generation+1;local mine=generation
 local body,rig=A.Copy(S.Current),S.Rig
 local d=A.Unpack(body);local model,reason
 local char=Players.LocalPlayer.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
 if hum and hum.Health>0 then
  local got,actual=pcall(function()return hum:GetAppliedDescription()end)
  if got then
   local Native=require(Rep:WaitForChild('08B2_BODY_DESCRIPTION'))
   if Native.Key(A,A.Pack(actual),hum.RigType.Name,false)==Native.Key(A,body,rig,false)then
    local archivable=char.Archivable;char.Archivable=true;local cloned,value=pcall(function()return char:Clone()end);char.Archivable=archivable
    if cloned and value then local valid=Load.Check(value,d,rig);if valid then model=value;M.Source='Cópia do avatar no mapa'else value:Destroy()end end
   end;actual:Destroy()
  end
 end
 if not model then model,reason=Load.Create(d,rig,{alive=function()return mine==generation end});M.Source='Avatar da aparência selecionada'end
 local ok=model~=nil;d:Destroy()
 if mine~=generation then if ok and model then model:Destroy()end;return false,"Estúdio fechado."end
 if not ok or not model then return false,reason or "Não consegui criar sua prévia. Tente novamente."end
 M.SavedCamera={Type=cam.CameraType,Subject=cam.CameraSubject,CFrame=cam.CFrame,FOV=cam.FieldOfView}
 M.Folder=Instance.new("Folder");M.Folder.Name="ACP_PhotoPreview_"..Players.LocalPlayer.UserId;M.Folder.Parent=workspace
 M.SetFolder=Instance.new("Folder");M.SetFolder.Name="Set";M.SetFolder.Parent=M.Folder
 M.Camera=cam;cam.CameraType=Enum.CameraType.Scriptable
 M.Model=model;model.Name="PhotoAvatar";model.Parent=M.Folder;model:PivotTo(CFrame.new(M.Center));fixRig()
 M.Margins=nil;M.Pose=Pose.Bind(model);M.Yaw=180;M.Zoom=1;M.Frame="FULL";M.FOV=30;M.AvatarYaw=0;M.Pitch=0
 saveLighting();M.BuildSet("STUDIO");M.Fit()
 M.Resize=cam:GetPropertyChangedSignal("ViewportSize"):Connect(M.Fit)
 return true
end
function M.Exit()
 generation=generation+1;M.StopEmote()
 if M.Resize then M.Resize:Disconnect();M.Resize=nil end
 if M.Pose then M.Pose.Destroy();M.Pose=nil end
 if M.Scene then M.Scene.Destroy();M.Scene=nil end
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
