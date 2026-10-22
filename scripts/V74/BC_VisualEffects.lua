-- BC_VisualEffects | ModuleScript | ReplicatedStorage | V74 (CRIAR)
-- Todos os objetos e o apagão são locais. Sem Explosion, dano, gravidade ou flashes globais.
local Rep=game:GetService('ReplicatedStorage');local C=require(Rep:WaitForChild('BC_Config'));local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris');local Players=game:GetService('Players');local M={}
function M.New()
 local V={reduced=true,active=false,objects={},shields={}};local dark;local marker;local dead=false
 local folder=Instance.new('Folder');folder.Name='BC_LocalFX';folder.Parent=workspace
 local audio=Instance.new('Folder');audio.Name='BC_LocalAudio';audio.Parent=game:GetService('SoundService')
 local cue=Instance.new('Sound');cue.SoundId=C.CueSound;cue.Volume=C.CueVolume;cue.Name='BC_CueTemplate';local soundReady=false
 task.spawn(function()
  local ok=pcall(function()game:GetService('ContentProvider'):PreloadAsync({cue})end)
  if not dead then soundReady=ok and cue.IsLoaded==true;if not soundReady then warn('[BC][AUDIO] Sinal nativo indisponível neste cliente; avisos visuais continuam ativos.')end end
 end)
 local function tone(pitch)
  if not soundReady or dead then return end
  local s=cue:Clone();s.PlaybackSpeed=pitch or 1;s.Parent=audio;s:Play();Debris:AddItem(s,2)
 end
 local function part(at,size,color,seconds)
  local p=Instance.new('Part');p.Name='BC_LocalEffect';p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  p.Size=size;p.Color=color;p.Material=Enum.Material.Neon;p.CFrame=CFrame.new(at);p.Parent=folder;Debris:AddItem(p,seconds or 1);return p
 end
 local function avatar(id)local pl=Players:GetPlayerByUserId(id);return pl and pl.Character end
 local function glow(id,color,seconds)
  local char=avatar(id);if not char then return nil end
  local h=Instance.new('Highlight');h.Name='BC_LocalHighlight';h.Adornee=char;h.FillTransparency=.85;h.OutlineColor=color;h.FillColor=color;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=folder
  Debris:AddItem(h,seconds);return h
 end
 local function bubble(at,color,radius)
  local p=part(at,Vector3.new(1,1,1),color,.65);p.Shape=Enum.PartType.Ball;p.Transparency=.65
  Tween:Create(p,TweenInfo.new(V.reduced and .35 or .55),{Size=Vector3.new(radius,radius,radius),Transparency=1}):Play()
 end
 function V.Blackout(on)
  if not on then if dark then dark:Destroy();dark=nil end;return end
  if not dark then dark=Instance.new('ColorCorrectionEffect');dark.Name='BC_LocalBlackout';dark.Parent=workspace.CurrentCamera end
  dark.Brightness=V.reduced and -.16 or -.23;dark.Contrast=.08;dark.Saturation=-.12
 end
 function V.Clear()
  V.Blackout(false);for _,o in ipairs(folder:GetChildren())do o:Destroy()end;for _,o in ipairs(audio:GetChildren())do o:Destroy()end;V.shields={};marker=nil
 end
 function V.SetActive(active)if not active and V.active then V.Clear()end;V.active=active end
 function V.Handle(kind,data)
  if not V.active then return end
  if kind=='buttonPress'then
   tone(1.2)
   local p=part(data.at,Vector3.new(2.8,.7,2.8),C.Palette.Gold,.35);p.Material=Enum.Material.SmoothPlastic
   Tween:Create(p,TweenInfo.new(.28),{Position=data.at-Vector3.new(0,.3,0),Transparency=1}):Play()
  elseif kind=='trace'then
   local length=(data.to-data.from).Magnitude;if length<.01 then return end
   local p=part((data.from+data.to)/2,Vector3.new(.08,.08,length),C.Palette.Cyan,.18);p.CFrame=CFrame.lookAt((data.from+data.to)/2,data.to)
  elseif kind=='foamThrow'then
   local p=part(data.from,Vector3.new(.8,.8,.8),C.Palette.Violet,2);p.Shape=Enum.PartType.Ball
   Tween:Create(p,TweenInfo.new(data.seconds,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=data.to}):Play()
  elseif kind=='foam'then
   bubble(data.at,C.Palette.Violet,18)
   for i=1,V.reduced and 4 or 10 do local a=i*2.399;local p=part(data.at+Vector3.new(math.cos(a)*3,1,math.sin(a)*3),Vector3.new(1,1,1),C.Palette.Cyan,.7);p.Shape=Enum.PartType.Ball;Tween:Create(p,TweenInfo.new(.6),{Transparency=1,Position=p.Position+Vector3.new(math.cos(a)*4,2,math.sin(a)*4)}):Play()end
  elseif kind=='nuclearMark'then tone(.7);if marker then marker:Destroy()end;marker=glow(data.user,C.Palette.Danger,4.1)
  elseif kind=='nuclear'then tone(.85);if marker then marker:Destroy();marker=nil end;bubble(data.at,C.Palette.Gold,V.reduced and 12 or 20)
  elseif kind=='wave'then local p=part(data.at-Vector3.new(0,2,0),Vector3.new(1,.12,1),C.Palette.Cyan,.6);p.Shape=Enum.PartType.Cylinder;p.CFrame=p.CFrame*CFrame.Angles(0,0,math.pi/2);Tween:Create(p,TweenInfo.new(.5),{Size=Vector3.new(.12,28,28),Transparency=1}):Play()
  elseif kind=='freeze'then glow(data.user,C.Palette.Cyan,3)
  elseif kind=='heal'then glow(data.user,Color3.fromRGB(65,175,122),1)
  elseif kind=='swap'then bubble(data.from,C.Palette.Violet,5);bubble(data.to,C.Palette.Violet,5)
  elseif kind=='shield'and data.blocked then local h=V.shields[data.user];if h then h:Destroy();V.shields[data.user]=nil end
  elseif kind=='clearFx'then V.Clear()end
 end
 function V.Reconcile(data)
  V.SetActive(data.matchId~=nil and(data.phase=='COUNTDOWN'or data.phase=='ACTIVE'))
  V.Blackout(V.active and data.alive==true and(data.blackout or 0)>0)
  local keep={}
  for _,p in ipairs(data.roster or{})do if p.alive and(p.shield or 0)>0 then
   keep[p.id]=true;local h=V.shields[p.id];if not h or not h.Parent then V.shields[p.id]=glow(p.id,C.Palette.Gold,p.shield+.5)end
  end end
  for id,h in pairs(V.shields)do if not keep[id]then h:Destroy();V.shields[id]=nil end end
 end
 function V.Destroy()dead=true;V.Clear();folder:Destroy();audio:Destroy();cue:Destroy()end
 return V
end
return M
