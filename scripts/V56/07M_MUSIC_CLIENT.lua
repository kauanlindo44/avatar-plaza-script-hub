-- 07M_MUSIC_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V56
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local SoundService=game:GetService('SoundService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui')
local function retireLegacy(o)
 if o.Name=='07M_PLAZA_MUSIC'and o:IsA('LocalScript')then pcall(function()o.Disabled=true end)end
 if o.Name=='ACP_MusicPanel'and o:IsA('GuiObject')then o:Destroy()end
end
local ps=pl:WaitForChild('PlayerScripts');for _,o in ipairs(ps:GetDescendants())do retireLegacy(o)end
ps.DescendantAdded:Connect(retireLegacy);for _,o in ipairs(pg:GetDescendants())do retireLegacy(o)end;pg.DescendantAdded:Connect(retireLegacy)
local U=require(Rep:WaitForChild('07M1_MUSIC_UI')).Build(pl)
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Content=game:GetService('ContentProvider')
local rpc=Rep:WaitForChild('ACP_MusicRequest',30);local prefs={volume=.4,saved={},last=0};local token=0;local saveToken=0;local current;local loaded=false;local lastVolume=.4
local legacy=SoundService:FindFirstChild('ACPPlazaMusicV2')or SoundService:FindFirstChild('ACPPlazaMusic')or SoundService:FindFirstChild('BackgroundMusic')or SoundService:FindFirstChild('Music')
local sound=SoundService:FindFirstChild('ACP_PersonalMusic')or(legacy and legacy:IsA('Sound')and legacy)or Instance.new('Sound')
local startingID=tonumber((sound.SoundId or''):match('(%d+)'))or 0
sound.Name='ACP_PersonalMusic';sound.Looped=true;sound.Volume=.4;sound.Parent=SoundService
local function singleAudio(o)if o~=sound and o:IsA('Sound')and(o.Name=='ACPPlazaMusicV2'or o.Name=='ACPPlazaMusic'or o.Name=='ACP_PersonalMusic')then o:Stop();o.Volume=0 end end
for _,o in ipairs(SoundService:GetChildren())do singleAudio(o)end;SoundService.ChildAdded:Connect(singleAudio)
local lastCall=0
local function call(action,args)
 if not rpc then return nil,'O servidor de música ainda não conectou.'end
 local waitFor=.3-(os.clock()-lastCall);if waitFor>0 then task.wait(waitFor)end;lastCall=os.clock()
 local done=false;local ok,r;task.spawn(function()ok,r=pcall(function()return rpc:InvokeServer(action,args or{})end);done=true end)
 local untilTime=os.clock()+12;while not done and os.clock()<untilTime do task.wait(.05)end
 if not done or not ok or not r then return nil,'O Roblox demorou. Use Recarregar.'end;return r.ok and r.data or nil,r.error
end
local function status(text,error)U.Status.Text=tostring(text or'');U.Status.TextColor3=error and D.Colors.red or D.Colors.muted end
local function volume(v)
 prefs.volume=math.clamp(v,0,1);sound.Volume=prefs.volume;U.Volume.Text=math.floor(prefs.volume*100+.5)..'% • '..(prefs.volume==0 and'ativar'or'silenciar')
 pg:SetAttribute('ACP_MusicEnabled',prefs.volume>0)
end
local function save()
 saveToken=saveToken+1;local mine=saveToken;task.delay(1,function()if mine~=saveToken or not loaded then return end
  local copied={volume=prefs.volume,saved=table.clone(prefs.saved),last=prefs.last};local ok,e=call('save',copied);if not ok then status(e,true)end
 end)
end
local function parse(text)return tonumber(text)or tonumber(tostring(text):match('[?&]id=(%d+)')or tostring(text):match('/library/(%d+)')or tostring(text):match('/asset/(%d+)')or tostring(text):match('rbxassetid://(%d+)'))end
local renderSaved;local load
load=function(id)
 id=tonumber(id);if not id or id%1~=0 or id<=0 then status('Informe um ID de áudio válido.',true);return end
 token=token+1;local mine=token;sound:Stop();status('Verificando áudio no Roblox…');U.Play.Text='Ouvir';U.Load.Active=false
 task.spawn(function()
  local meta,e=call('audio',{id=id});if mine~=token then return end
  U.Load.Active=true;if not meta then status(e,true);return end
  current=meta;U.ID.Text=tostring(id);U.Track.Text=meta.name;sound.SoundId='rbxassetid://'..id;local done=false;local failed=false
  status('Carregando áudio…');task.spawn(function()local worked,cause=pcall(function()Content:PreloadAsync({sound},function(_,result)if result.Name~='Success'then failed=true end end)end);if not worked then failed=true;warn('[Music V56] '..tostring(cause))end;done=true end)
  local deadline=os.clock()+12;while mine==token and not sound.IsLoaded and not failed and os.clock()<deadline do task.wait(.1)end
  if mine~=token then return end
  if not sound.IsLoaded or failed then status('Não carregou: pode ser permissão, moderação ou conexão. Use Recarregar.',true);return end
  prefs.last=id;volume(prefs.volume);sound:Play();U.Play.Text='Pausar';renderSaved();status('Áudio carregado • som pessoal');save()
 end)
end
renderSaved=function()
 for _,o in ipairs(U.List:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
 if #prefs.saved==0 then D.Text(U.List,'Nenhuma música salva. Carregue um áudio e toque Salvar.',{Size=UDim2.new(1,-4,0,60),TextSize=12})end
 for i,id in ipairs(prefs.saved)do
  local row=D.New('Frame',{Size=UDim2.new(1,-4,0,44),BackgroundTransparency=1,LayoutOrder=i},U.List)
  local b=D.Button(row,current and current.id==id and current.name or('Áudio '..id),{Size=UDim2.new(1,-50,1,0),TextSize=12});b.Activated:Connect(function()load(id)end)
  local x=D.Button(row,'×',{Position=UDim2.new(1,-44,0,0),Size=UDim2.fromOffset(44,44),TextSize=20});x.Activated:Connect(function()table.remove(prefs.saved,i);renderSaved();save()end)
 end
end
U.Load.Activated:Connect(function()load(parse(U.ID.Text))end);U.Reload.Activated:Connect(function()if not loaded then task.spawn(function()local d,e=call('load');if d then prefs=d;loaded=true;volume(prefs.volume);renderSaved();load(parse(U.ID.Text)or prefs.last)else status(e,true)end end)else load(parse(U.ID.Text))end end)
U.ID.FocusLost:Connect(function(enter)if enter then load(parse(U.ID.Text))end end)
U.Play.Activated:Connect(function()if sound.SoundId==''or not sound.IsLoaded then status('Carregue uma música primeiro.',true);return end;if sound.IsPlaying then sound:Pause();U.Play.Text='Ouvir'else sound:Resume();U.Play.Text='Pausar'end end)
U.Keep.Activated:Connect(function()
 if not current or not sound.IsLoaded then status('Carregue o áudio antes de salvar.',true);return end
 if table.find(prefs.saved,current.id)then status('Essa música já está salva.');return end
 if #prefs.saved>=24 then status('Remova uma das 24 músicas salvas.',true);return end;prefs.saved[#prefs.saved+1]=current.id;renderSaved();save();status('Música adicionada aos salvos.')
end)
U.Minus.Activated:Connect(function()volume(prefs.volume-.05);save()end);U.Plus.Activated:Connect(function()volume(prefs.volume+.05);save()end)
U.Volume.Activated:Connect(function()if prefs.volume>0 then lastVolume=prefs.volume;volume(0)else volume(lastVolume)end;save()end)
U.Close.Activated:Connect(function()U.Root.Visible=false end)
local nonce=tonumber(pg:GetAttribute('ACP_OpenMusicNonce'))or 0
pg:GetAttributeChangedSignal('ACP_OpenMusicNonce'):Connect(function()local n=tonumber(pg:GetAttribute('ACP_OpenMusicNonce'))or 0;if n~=nonce then nonce=n;U.Root.Visible=not U.Root.Visible;U.Layout()end end)
pg:GetAttributeChangedSignal('ACP_MusicEnabled'):Connect(function()local on=pg:GetAttribute('ACP_MusicEnabled');if on==false and prefs.volume>0 then lastVolume=prefs.volume;volume(0);save()elseif on==true and prefs.volume==0 then volume(lastVolume);save()end end)
task.spawn(function()
 local d,e=call('load');if d then prefs=d;loaded=true;volume(prefs.volume);renderSaved();if prefs.last>0 then load(prefs.last)elseif startingID>0 then load(startingID)end else status(e,true);loaded=false;volume(.4);if startingID>0 then load(startingID)end end
end)
U.Gui.Destroying:Connect(function()token=token+1;sound:Stop()end)
