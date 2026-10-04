-- 09C11_AVATAR_CHARACTER | LocalScript | StarterPlayer > StarterPlayerScripts | V49
-- Câmera e movimento dos personagens reconstruídos pelo servidor.
local Players=game:GetService("Players")
local pl=Players.LocalPlayer;local serial=0;local connections={};local tracks={}
local defaults={
 R15={IdleAnimation=507766666,WalkAnimation=507777826,RunAnimation=507767714,JumpAnimation=507765000,FallAnimation=507767968,ClimbAnimation=507765644,SwimAnimation=507784897},
 R6={IdleAnimation=180435571,WalkAnimation=180426354,RunAnimation=180426354,JumpAnimation=125750702,FallAnimation=180436148,ClimbAnimation=180436334,SwimAnimation=180426354}
}
local function clear()
 for _,c in ipairs(connections)do c:Disconnect()end;connections={}
 for _,track in pairs(tracks)do pcall(function()track:Stop(.1);track:Destroy()end)end;tracks={}
end
local function bind(char)
 serial=serial+1;local mine=serial;clear()
 if not char:GetAttribute("ACP_AvatarManaged")then return end
 local hum=char:WaitForChild("Humanoid",8);if not hum or pl.Character~=char or mine~=serial then return end
 local camera=workspace.CurrentCamera
 if camera and(camera.CameraType==Enum.CameraType.Custom or camera.CameraType==Enum.CameraType.Follow)then camera.CameraSubject=hum end
 if char:FindFirstChild("Animate")then return end
 local animator=hum:WaitForChild("Animator",8);if not animator or mine~=serial then return end
 local desc=hum:GetAppliedDescription();local rig=hum.RigType==Enum.HumanoidRigType.R6 and"R6"or"R15"
 local active=nil;local function play(key,speed,loop)
  if hum.Health<=0 or mine~=serial then return end
  local track=tracks[key]
  if not track then
   local id=tonumber(desc[key]);if not id or id<=0 then id=defaults[rig][key]end
   local animation=Instance.new("Animation");animation.AnimationId="rbxassetid://"..id
   local ok,t=pcall(function()return animator:LoadAnimation(animation)end);animation:Destroy()
   if not ok then return end;track=t;tracks[key]=t
   track.Priority=key=="IdleAnimation"and Enum.AnimationPriority.Idle or Enum.AnimationPriority.Movement
  end
  if active~=track then if active then active:Stop(.15)end;active=track;track.Looped=loop~=false;track:Play(.15)end
  track:AdjustSpeed(speed or 1)
 end
 connections[#connections+1]=hum.Running:Connect(function(speed)
  if hum.Sit then if active then active:Stop(.1);active=nil end;return end
  if speed<.1 then play("IdleAnimation")else play(speed>18 and"RunAnimation"or"WalkAnimation",math.max(.2,speed/16))end
 end)
 connections[#connections+1]=hum.StateChanged:Connect(function(_,state)
  local n=state.Name
  if n=="Jumping"then play("JumpAnimation",1,false)
  elseif n=="Freefall"then play("FallAnimation")
  elseif n=="Climbing"then play("ClimbAnimation")
  elseif n=="Swimming"then play("SwimAnimation")
  elseif n=="Seated"or n=="Dead"then if active then active:Stop(.1);active=nil end end
 end)
 connections[#connections+1]=hum.Died:Connect(clear)
 connections[#connections+1]=char.Destroying:Connect(function()desc:Destroy();if mine==serial then clear()end end)
 play("IdleAnimation")
 -- O controle padrão do Roblox recebe CharacterAdded; não se força câmera de estúdio/partida.
end
pl.CharacterAdded:Connect(function(char)task.defer(bind,char)end)
pl:GetAttributeChangedSignal("ACP_AvatarEpoch"):Connect(function()if pl.Character then task.defer(bind,pl.Character)end end)
if pl.Character then task.defer(bind,pl.Character)end
