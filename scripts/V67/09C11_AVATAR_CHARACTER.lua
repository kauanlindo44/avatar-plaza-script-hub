-- 09C11_AVATAR_CHARACTER | LocalScript | StarterPlayer > StarterPlayerScripts | V67 (SUBSTITUIR)
-- Fallback somente quando o Animate nativo não toca; não altera juntas/attachments.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Run=game:GetService('RunService')
local pl=Players.LocalPlayer;local serial=0;local connections={};local tracks={};local description
local defaults={R15={IdleAnimation=507766666,WalkAnimation=507777826,RunAnimation=507767714,JumpAnimation=507765000,FallAnimation=507767968,ClimbAnimation=507765644,SwimAnimation=507784897},R6={IdleAnimation=180435571,WalkAnimation=180426354,RunAnimation=180426354,JumpAnimation=125750702,FallAnimation=180436148,ClimbAnimation=180436334,SwimAnimation=180426354}}
local function clear()
 for _,c in ipairs(connections)do c:Disconnect()end;connections={}
 for _,track in pairs(tracks)do pcall(function()track:Stop(.1);track:Destroy()end)end;tracks={}
 if description then description:Destroy();description=nil end
end
local function bind(char)
 serial=serial+1;local mine=serial;clear()
 if not char:GetAttribute('ACP_AvatarManaged')then return end
 local hum=char:WaitForChild('Humanoid',8);if not hum or pl.Character~=char or mine~=serial then return end
 local camera=workspace.CurrentCamera
 if camera and(camera.CameraType==Enum.CameraType.Custom or camera.CameraType==Enum.CameraType.Follow)then camera.CameraSubject=hum end
 local animator=hum:WaitForChild('Animator',8);if not animator or mine~=serial then return end
 local clips={};task.spawn(function()
  local rem=Rep:FindFirstChild('LMShop_Remotes');local rpc=rem and rem:FindFirstChild('Request');if not rpc then return end
  local ok,r;local deadline=os.clock()+14
  repeat ok,r=pcall(function()return rpc:InvokeServer('AvatarAnimations',{})end);if ok and r and r.ok and r.data then break end;if mine~=serial or pl.Character~=char then return end;task.wait(.6)until os.clock()>=deadline
  if mine~=serial or pl.Character~=char or not ok or not r or not r.ok or not r.data then return end
  clips=r.data.clips or{};local animate=char:FindFirstChild('Animate');local names={IdleAnimation='idle',WalkAnimation='walk',RunAnimation='run',JumpAnimation='jump',FallAnimation='fall',ClimbAnimation='climb',SwimAnimation='swim'}
  if animate then for key,list in pairs(clips)do local folder=animate:FindFirstChild(names[key]);if folder then local i=0;for _,v in ipairs(folder:GetChildren())do if v:IsA('Animation')then i=i+1;v.AnimationId=list[i]or list[1]end end end end end
 end)
 local rig=hum.RigType==Enum.HumanoidRigType.R6 and'R6'or'R15';local active;local speed=0;local state='Running';local nativeAt=os.clock();local elapsed=0
 local function stop()if active then active:Stop(.15);active=nil end end
 local function nativePlaying()
  for _,t in ipairs(animator:GetPlayingAnimationTracks())do
   local owned=false;for _,v in pairs(tracks)do if v==t then owned=true;break end end
   if not owned and t.IsPlaying and t.Length>0 then return true end
  end;return false
 end
 local function play(key,rate,loop)
  if hum.Health<=0 or mine~=serial or hum.Sit then stop();return end
  if nativePlaying()then nativeAt=os.clock();stop();return end
  if os.clock()-nativeAt<1.25 then return end
  local track=tracks[key]
  if not track then
   -- HumanoidDescription.*Animation pode identificar um pacote, não um AnimationClip.
   -- As animações personalizadas continuam a cargo do Animate; este é um fallback seguro.
   local animation=Instance.new('Animation');animation.AnimationId=clips[key]and clips[key][1]or('rbxassetid://'..defaults[rig][key])
   local ok,t=pcall(function()return animator:LoadAnimation(animation)end);animation:Destroy()
   if not ok then warn('[Avatar V67] LOCOMOTION | '..key..' | '..tostring(t));return end
   track=t;tracks[key]=t;track.Priority=key=='IdleAnimation'and Enum.AnimationPriority.Idle or Enum.AnimationPriority.Movement
  end
  if active~=track then stop();active=track;track.Looped=loop~=false;track:Play(.15)end
  track:AdjustSpeed(math.clamp(rate or 1,.4,1.6))
 end
 local function update()
  if hum.Sit or state=='Seated'or state=='Dead'then stop();return end
  if state=='Jumping'then play('JumpAnimation',1,false)
  elseif state=='Freefall'then play('FallAnimation')
  elseif state=='Climbing'then play('ClimbAnimation')
  elseif state=='Swimming'then play('SwimAnimation')
  elseif speed<.1 then play('IdleAnimation')else play(speed>18 and'RunAnimation'or'WalkAnimation',speed/math.max(6,16*(rig=='R6'and 1 or math.clamp(hum.HipHeight/2,.5,2.5))))end
 end
 connections[#connections+1]=hum.Running:Connect(function(v)speed=v;update()end)
 connections[#connections+1]=hum.StateChanged:Connect(function(_,v)state=v.Name;update()end)
 connections[#connections+1]=Run.Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed<.25 then return end;elapsed=0;update()end)
 connections[#connections+1]=hum.Died:Connect(clear)
 connections[#connections+1]=char.Destroying:Connect(function()if mine==serial then clear()end end)
end
pl.CharacterAdded:Connect(function(char)task.defer(bind,char)end)
pl:GetAttributeChangedSignal('ACP_AvatarEpoch'):Connect(function()if pl.Character then task.defer(bind,pl.Character)end end)
if pl.Character then task.defer(bind,pl.Character)end
