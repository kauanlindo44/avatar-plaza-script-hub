-- 07UI_GAME_AUDIO | ModuleScript | ReplicatedStorage | V75 (CRIAR)
-- Áudios da Creator Store. Falha de permissão nunca bloqueia a jogada ou o HUD.
local Sound=game:GetService('SoundService');local Debris=game:GetService('Debris');local Content=game:GetService('ContentProvider')
local Players=game:GetService('Players');local M={};local last={};local playing={};local templates={};local serial=0;local active=0;local warned={}
M.Assets={tap='rbxassetid://9120704522',move='rbxassetid://9120704522',push='rbxassetid://9120729005',
 explosion='rbxassetid://9125615451',foam='rbxassetid://9120705982',freeze='rbxassetid://9114856304',
 wave='rbxassetid://9126229716',swap='rbxassetid://9120725798'}
local folder=Instance.new('Folder');folder.Name='ACP_GameAudio';folder.Parent=Sound
local function prepare(key)
 if templates[key]then return templates[key]end;local id=M.Assets[key];if not id then return nil end
 local s=Instance.new('Sound');s.Name='Template_'..key;s.SoundId=id;s.Volume=.18;s.Parent=folder;templates[key]=s
 task.spawn(function()
  local ok=pcall(function()Content:PreloadAsync({s})end)
  if not ok and not warned[key]then warned[key]=true;warn('[Audio V75] Não foi possível carregar '..key..' ('..id..'). Confira permissão da experiência.')end
 end)
 return s
end
function M.Play(key,at,volume,speed)
 local pg=Players.LocalPlayer and Players.LocalPlayer:FindFirstChild('PlayerGui')
 if pg and pg:GetAttribute('ACP_EffectsEnabled')==false then return false end
 local now=os.clock();if now-(last[key]or -math.huge)<.1 or active>=6 then return false end
 local template=prepare(key);if not template then return false end;last[key]=now
 serial=serial+1;active=active+1;local s=template:Clone();s.Name='GameSFX_'..serial
 s.Volume=math.clamp(volume or .18,0,.35);s.PlaybackSpeed=math.clamp(speed or 1,.65,1.8);s.Looped=false
 local emitter
 if typeof(at)=='Vector3' then
  emitter=Instance.new('Part');emitter.Name='ACP_LocalSoundOrigin';emitter.Size=Vector3.new(.1,.1,.1);emitter.Transparency=1
  emitter.Anchored=true;emitter.CanCollide=false;emitter.CanTouch=false;emitter.CanQuery=false;emitter.Position=at;emitter.Parent=workspace
  s.Parent=emitter;s.RollOffMinDistance=12;s.RollOffMaxDistance=160;Debris:AddItem(emitter,4)
 else s.Parent=folder;Debris:AddItem(s,4)end
 local done=false
 local function release()if done then return end;done=true;playing[s]=nil;active=math.max(0,active-1);if emitter and emitter.Parent then emitter:Destroy()elseif s.Parent then s:Destroy()end end
 playing[s]=release;s.Ended:Connect(release);s:Play();task.delay(4,release)
 task.delay(3,function()if s.Parent and not s.IsLoaded and not warned[key]then warned[key]=true;warn('[Audio V75] Áudio '..key..' não carregou; conferir moderação/permissão no Roblox.')end end)
 return true
end
function M.StopAll()local releases={};for _,release in pairs(playing)do releases[#releases+1]=release end;for _,release in ipairs(releases)do release()end end
local focused=setmetatable({},{__mode='k'})
function M.Bind(root)
 local dead=false
 local function update()
  focused[root]=not dead and root.Visible==true;local on=false;for r,v in pairs(focused)do if r.Parent and v then on=true end end
  local pg=Players.LocalPlayer and Players.LocalPlayer:FindFirstChild('PlayerGui');if pg then pg:SetAttribute('ACP_GameAudioFocus',on)end
 end
 root:GetPropertyChangedSignal('Visible'):Connect(update);root.Destroying:Connect(function()dead=true;focused[root]=nil;update()end);update()
end
return M
