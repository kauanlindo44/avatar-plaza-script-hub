-- 07M_MUSIC_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V73 (SUBSTITUIR)
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local SoundService=game:GetService('SoundService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui')
if script:IsA('LocalScript')and script.Name~='07M_MUSIC_CLIENT'then warn('[ACP V73] Fonte da música no script errado: '..script:GetFullName());return end
local owner=pg:FindFirstChild('ACP_MusicOwner');if owner and owner.Value and owner.Value.Parent then warn('[ACP V73] Música duplicada; mantendo uma única reprodução.');return end
owner=owner or Instance.new('ObjectValue');owner.Name='ACP_MusicOwner';owner.Value=script;owner.Parent=pg
local function retireLegacy(o)
 if o.Name=='07M_PLAZA_MUSIC'and o:IsA('LocalScript')then pcall(function()o.Disabled=true end)end
 if o.Name=='ACP_MusicPanel'and o:IsA('GuiObject')then o:Destroy()end
end
local ps=pl:WaitForChild('PlayerScripts');for _,o in ipairs(ps:GetDescendants())do retireLegacy(o)end
ps.DescendantAdded:Connect(retireLegacy);for _,o in ipairs(pg:GetDescendants())do retireLegacy(o)end;pg.DescendantAdded:Connect(retireLegacy)
local U=require(Rep:WaitForChild('07M1_MUSIC_UI')).Build(pl)
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Content=game:GetService('ContentProvider')
local rpc=Rep:WaitForChild('ACP_MusicRequest',30);local prefs={volume=.4,saved={},last=0};local token=0;local saveToken=0;local current;local loaded=false;local lastVolume=.4;local chosenByUser=false;local userVolume=false
local legacy=SoundService:FindFirstChild('ACPPlazaMusicV2')or SoundService:FindFirstChild('ACPPlazaMusic')or SoundService:FindFirstChild('BackgroundMusic')or SoundService:FindFirstChild('Music')
local sound=SoundService:FindFirstChild('ACP_PersonalMusic')or(legacy and legacy:IsA('Sound')and legacy)or Instance.new('Sound')
local startingID=tonumber((sound.SoundId or''):match('(%d+)'))or 0
sound.Name='ACP_PersonalMusic';sound.Looped=true;sound.Volume=.4;sound.Parent=SoundService
local function singleAudio(o)if o~=sound and o:IsA('Sound')and(o.Name=='ACPPlazaMusicV2'or o.Name=='ACPPlazaMusic'or o.Name=='ACP_PersonalMusic')then o:Stop();o.Volume=0 end end
for _,o in ipairs(SoundService:GetChildren())do singleAudio(o)end;SoundService.ChildAdded:Connect(singleAudio)
local lastCall={};local callBusy={}
local function call(action,args)
 if not rpc then return nil,'O servidor de música ainda não conectou.'end
 local queueUntil=os.clock()+10;while callBusy[action] and os.clock()<queueUntil do task.wait(.05)end
 if callBusy[action] then return nil,'Biblioteca ocupada. Tente em instantes.'end;callBusy[action]=true
 local waitFor=.3-(os.clock()-(lastCall[action]or-10));if waitFor>0 then task.wait(waitFor)end;lastCall[action]=os.clock()
 local done=false;local ok,r;task.spawn(function()ok,r=pcall(function()return rpc:InvokeServer(action,args or{})end);done=true end)
 local untilTime=os.clock()+12;while not done and os.clock()<untilTime do task.wait(.05)end
 callBusy[action]=false
 if not done or not ok or not r then return nil,'O Roblox demorou. Use Recarregar.'end;return r.ok and r.data or nil,r.error
end
local function status(text,error)U.Status.Text=tostring(text or'');U.Status.TextColor3=error and D.Colors.red or D.Colors.muted end
local function volume(v)
 prefs.volume=math.clamp(v,0,1);sound.Volume=prefs.volume;U.VolumeSlider.Set(prefs.volume,true);U.VolumeSlider.Label.Text='Volume '..math.floor(prefs.volume*100+.5)..'%';U.Mute.Text=prefs.volume==0 and'Mudo'or'Som'
 pg:SetAttribute('ACP_MusicEnabled',prefs.volume>0)
end
local function save()
 saveToken=saveToken+1;local mine=saveToken;task.delay(1,function()if mine~=saveToken or not loaded then return end
  local copied={volume=prefs.volume,saved=table.clone(prefs.saved),last=prefs.last};local ok,e=call('save',copied);if not ok then status(e,true)end
 end)
end
local function parse(text)return tonumber(text)or tonumber(tostring(text):match('[?&]id=(%d+)')or tostring(text):match('/library/(%d+)')or tostring(text):match('/asset/(%d+)')or tostring(text):match('/store/asset/(%d+)')or tostring(text):match('rbxassetid://(%d+)'))end
local curated={{id=1837379560,name='Fall in Love · bossa lounge'},{id=1840917953,name='Sunday Jazz (B)'},{id=1845756152,name='Mellow'}}
local defaultQueue=false;local discover;local pendingDiscovery=false;local autoStarted=false;local recommendations=table.clone(curated);local discovered=false;local discoverBusy=false
local renderSaved;local load;local queue={};local queueIndex=0;local names={};for _,r in ipairs(curated)do names[r.id]=r.name end;local rendered=0;local failedDefaults={};local fallbackCount=0;local waitingFallback=false;local initialPreferencesDone=false
local function failedAudio(id,mine,stage,reason)
 if mine~=token then return end
 U.Load.Active=true;U.Seek.Enable(false);U.Play.Text="Ouvir";sound:Stop()
 warn("[Music V73] "..stage.." | id="..id.." | "..tostring(reason))
 status("Não carregou: permissão, moderação ou conexão. Recarregue ou escolha outra faixa.",true)
 failedDefaults[id]=true;fallbackCount=fallbackCount+1
 if fallbackCount>=6 then status('O Roblox não liberou áudio nessas tentativas. Use outro ID permitido ou Recarregar.',true);return end
 local nextID,nextIndex
 for i=queueIndex+1,#queue do if not failedDefaults[queue[i]]then nextID=queue[i];nextIndex=i;break end end
 if not nextID then for i,v in ipairs(queue)do if not failedDefaults[v]then nextID=v;nextIndex=i;break end end end
 if not nextID then for _,v in ipairs(recommendations)do if not failedDefaults[v.id]then nextID=v.id;break end end end
 if nextID then
  if nextIndex then queueIndex=nextIndex end;waitingFallback=false
  status('Essa música não abriu. Carregando outra faixa…')
  task.delay(1.5,function()if mine==token then load(nextID)end end)
 else waitingFallback=true;if discover and not pendingDiscovery then discover(false)end end
end
load=function(id,user)
 if user then chosenByUser=true;failedDefaults={};fallbackCount=0;waitingFallback=false end
 id=tonumber(id);if not id or id%1~=0 or id<=0 then status('Informe um ID de áudio válido.',true);return end
 token=token+1;local mine=token;sound:Stop();status('Verificando áudio no Roblox…');U.Play.Text='Ouvir';U.Load.Active=false
 task.spawn(function()
  local meta,e=call('audio',{id=id});if mine~=token then return end
  U.Load.Active=true;if not meta then failedAudio(id,mine,'METADATA',e);return end
  current=meta;names[id]=meta.name;U.Seek.Enable(false);U.ID.Text=tostring(id);U.Track.Text=meta.name;sound.SoundId='rbxassetid://'..id;local done=false;local failed=false;local fetchStatus='Pending'
  local uri=sound.SoundId;status('Carregando áudio…');task.spawn(function()local worked,cause=pcall(function()Content:PreloadAsync({uri},function(asset,result)if mine~=token then return end;fetchStatus=result.Name;if result.Name~='Success'then failed=true end end)end);if not worked then failed=true;fetchStatus=tostring(cause)end;done=true end)
  local deadline=os.clock()+12;while mine==token and(not done or not sound.IsLoaded or sound.TimeLength<=0)and os.clock()<deadline do if done and failed then task.wait(.5);break end;task.wait(.1)end
  if mine~=token then return end
  if not sound.IsLoaded or sound.TimeLength<=0 then failedAudio(id,mine,'CONTENT_LOAD',fetchStatus..' | IsLoaded='..tostring(sound.IsLoaded)..' | duration='..tostring(sound.TimeLength));return end
  U.Seek.Enable(sound.TimeLength>0);prefs.last=id;volume(prefs.volume);sound:Play();U.Play.Text='Pausar';fallbackCount=0;waitingFallback=false;renderSaved();status('Áudio carregado • som pessoal');save()
 end)
end
local function startRecommended()
 if not initialPreferencesDone or autoStarted or chosenByUser or prefs.last~=0 or startingID~=0 or #recommendations==0 then return end
 autoStarted=true;defaultQueue=true;queue={};for i,v in ipairs(recommendations)do if i<=8 then queue[#queue+1]=v.id end end;queueIndex=1;failedDefaults={};sound.Looped=false;load(queue[1])
end
renderSaved=function()
 rendered=rendered+1;local mine=rendered
 for _,o in ipairs(U.List:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
 local source=U.Page=='Descobrir'and recommendations or U.Page=='Fila'and queue or prefs.saved;local query=U.Filter.Text:lower();local count=0
 for i,value in ipairs(source)do
  local id=type(value)=='table'and value.id or value
  local text=names[id]or('Áudio '..id)
  if U.Page=='Descobrir'or query==''or text:lower():find(query,1,true)or tostring(id):find(query,1,true)then
   count=count+1;local row=D.New('Frame',{Size=UDim2.new(1,-4,0,56),BackgroundColor3=D.Colors.card,BackgroundTransparency=.16,LayoutOrder=i},U.List)
   local b=D.Button(row,(U.Page=='Fila'and(i..'. ')or'')..text,{Size=UDim2.new(1,-50,1,0),TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1})
   b.Activated:Connect(function()if U.Page=='Fila'then queueIndex=i end;load(id,true)end)
   local x=D.Button(row,U.Page=='Descobrir'and'+'or'×',{Position=UDim2.new(1,-46,0,6),Size=UDim2.fromOffset(44,44),TextSize=20})
   x.Activated:Connect(function()
    if U.Page=='Descobrir'then if not table.find(queue,id)and #queue<24 then queue[#queue+1]=id;sound.Looped=false;status('Adicionado à fila.')end
    elseif U.Page=='Fila'then table.remove(queue,i);if i<=queueIndex then queueIndex=math.max(0,queueIndex-1)end
    else table.remove(prefs.saved,i);save()end;renderSaved()
   end)
   if not names[id]then task.spawn(function()
    local info=call('audio',{id=id});if info then names[id]=info.name;if mine==rendered and b.Parent then b.Text=(U.Page=='Fila'and(i..'. ')or'')..info.name end end
   end)end
  end
 end
 if count==0 then D.Text(U.List,U.Page=='Descobrir'and'Consultando a biblioteca Roblox…'or query~=''and'Nenhum resultado.'or U.Page=='Fila'and'Carregue um áudio e toque + Fila.'or'Carregue um áudio e toque Salvar.',{Size=UDim2.new(1,-4,0,62),TextSize=12})end
end
discover=function(nextPage,reload)
 if discoverBusy then return end;discoverBusy=true;status('Buscando músicas no Roblox…')
 task.spawn(function()
  local r,e=call('search',{search=U.Filter.Text,next=nextPage==true,reload=reload==true});discoverBusy=false
  if not r then pendingDiscovery=false;status(e,true);return end
  if r.pending then pendingDiscovery=true;U.More.Active=false;status('Atualizando biblioteca • ID/link disponível');return end;pendingDiscovery=r.refreshing==true
  recommendations=r.items or{};if U.Filter.Text==''then local merged={};local seen={};for _,list in ipairs({curated,recommendations})do for _,row in ipairs(list)do if not seen[row.id]then merged[#merged+1]=row;seen[row.id]=true end end end;recommendations=merged end;for _,v in ipairs(recommendations)do names[v.id]=v.name end;discovered=true
  if waitingFallback then local nextID;for _,v in ipairs(recommendations)do if not failedDefaults[v.id]then nextID=v.id;break end end;if nextID then waitingFallback=false;task.defer(function()load(nextID)end)end end
  U.More.Active=not r.finished;renderSaved();startRecommended();status(waitingFallback and'Nenhuma dessas músicas pôde tocar. Pesquise outra ou use Recarregar.'or'Biblioteca Roblox • toque para ouvir, + para a fila',waitingFallback)
 end)
end
U.Search.Activated:Connect(function()discover(false)end);U.More.Activated:Connect(function()discover(true)end)
U.Filter.FocusLost:Connect(function(enter)if enter and U.Page=='Descobrir'then discover(false)end end)
U.OnLibrary=function()renderSaved();if U.Page=='Descobrir'and not discovered then discover(false)end end;U.Filter:GetPropertyChangedSignal('Text'):Connect(renderSaved)
local function advance(step,user)
 if #queue==0 then status('A fila está vazia. Carregue um áudio e toque + Fila.',true);return end
 queueIndex=math.clamp(queueIndex+step,1,#queue);load(queue[queueIndex],user)
end
U.Previous.Activated:Connect(function()advance(-1,true)end);U.Next.Activated:Connect(function()advance(1,true)end)
U.Enqueue.Activated:Connect(function()
 if not current or not sound.IsLoaded then status('Carregue um áudio antes de adicionar à fila.',true);return end
 if #queue>=24 then status('A fila comporta 24 músicas.',true);return end
 queue[#queue+1]=current.id;if queueIndex==0 then queueIndex=1 end
 sound.Looped=false;renderSaved();status('Adicionado à fila • '..#queue..' música(s)')
end)
sound.Ended:Connect(function()if queueIndex<#queue then advance(1)elseif defaultQueue and #queue>0 then queueIndex=0;advance(1)else U.Play.Text='Ouvir';status('Fila concluída. Toque Ouvir para repetir a música.')end end)
U.OnVolume=function(v)userVolume=true;volume(v)end;U.OnVolumeEnd=save
U.OnSeek=function(v)if sound.IsLoaded and sound.TimeLength>0 then sound.TimePosition=v*sound.TimeLength end end
local function timeText(n)n=math.max(0,math.floor(tonumber(n)or 0));return math.floor(n/60)..':'..string.format('%02d',n%60)end
local elapsed=0
local ticking=game:GetService('RunService').RenderStepped:Connect(function(dt)
 elapsed=elapsed+dt;if elapsed<.25 or not U.Root.Visible then return end;elapsed=0
 local length=sound.TimeLength;local position=sound.TimePosition
 U.Seek.Enable(sound.IsLoaded and length>0);U.Seek.Label.Text=timeText(position)..' / '..timeText(length)
 if not U.Seek.Dragging then U.Seek.Set(length>0 and position/length or 0,true)end
end)
U.Load.Activated:Connect(function()load(parse(U.ID.Text),true)end)
U.Reload.Activated:Connect(function()
 local id=parse(U.ID.Text)
 if id then load(id,true)else discovered=false;pendingDiscovery=false;discover(false,true)end
 if not loaded then task.spawn(function()local d,e=call('load');if d then local v=prefs.volume;prefs=d;if userVolume then prefs.volume=v end;loaded=true;volume(prefs.volume);renderSaved()else status(e,true)end end)end
end)
U.ID.FocusLost:Connect(function(enter)if enter then load(parse(U.ID.Text),true)end end)
U.Play.Activated:Connect(function()chosenByUser=true;if sound.SoundId==''or not sound.IsLoaded then status('Carregue uma música primeiro.',true);return end;if sound.IsPlaying then sound:Pause();U.Play.Text='Ouvir'else if sound.TimeLength>0 and sound.TimePosition>=sound.TimeLength then sound.TimePosition=0 end;sound:Resume();U.Play.Text='Pausar'end end)
U.Keep.Activated:Connect(function()
 if not current or not sound.IsLoaded then status('Carregue o áudio antes de salvar.',true);return end
 if table.find(prefs.saved,current.id)then status('Essa música já está salva.');return end
 if #prefs.saved>=24 then status('Remova uma das 24 músicas salvas.',true);return end;prefs.saved[#prefs.saved+1]=current.id;renderSaved();save();status('Música adicionada aos salvos.')
end)
U.Mute.Activated:Connect(function()userVolume=true;if prefs.volume>0 then lastVolume=prefs.volume;volume(0)else volume(lastVolume)end;save()end)
U.Close.Activated:Connect(function()U.Root.Visible=false end)
local nonce=tonumber(pg:GetAttribute('ACP_OpenMusicNonce'))or 0
pg:GetAttributeChangedSignal('ACP_OpenMusicNonce'):Connect(function()local n=tonumber(pg:GetAttribute('ACP_OpenMusicNonce'))or 0;if n~=nonce then nonce=n;U.Root.Visible=not U.Root.Visible;U.Layout();if U.Root.Visible then U.OnLibrary()end end end)
pg:GetAttributeChangedSignal('ACP_MusicEnabled'):Connect(function()local on=pg:GetAttribute('ACP_MusicEnabled');if on==false and prefs.volume>0 then lastVolume=prefs.volume;volume(0);save()elseif on==true and prefs.volume==0 then volume(lastVolume);save()end end)
renderSaved();task.defer(function()discover(false)end)
task.spawn(function()
 local d,e=call('load');if d then local sessionPrefs=prefs;prefs=d;if userVolume then prefs.volume=sessionPrefs.volume end;for _,id in ipairs(sessionPrefs.saved)do if not table.find(prefs.saved,id)and #prefs.saved<24 then prefs.saved[#prefs.saved+1]=id end end;loaded=true else status(e,true);loaded=false end;volume(prefs.volume)
 initialPreferencesDone=true;local id=prefs.last>0 and prefs.last~=119682972981199 and prefs.last or curated[1].id;if prefs.last==0 or prefs.last==119682972981199 then queue={};for _,row in ipairs(curated)do queue[#queue+1]=row.id end;defaultQueue=true;sound.Looped=false end
 if id and not chosenByUser then autoStarted=true;queueIndex=table.find(queue,id)or 0;load(id)else startRecommended()end
end)
local changed=Rep:FindFirstChild('ACP_AudioLibraryChanged');local changedConnection
if changed then changedConnection=changed.OnClientEvent:Connect(function(query)if pendingDiscovery and(query==U.Filter.Text or (query=='lofi'or query=='bossa nova')and U.Filter.Text=='')then discover(false)end end)end
local musicRefresh=0;local refreshConnection=game:GetService('RunService').Heartbeat:Connect(function(dt)
 musicRefresh=musicRefresh+dt;if pendingDiscovery and musicRefresh>=2 then musicRefresh=0;discover(false)end;if musicRefresh>=600 and U.Root.Visible and U.Page=='Descobrir'and U.Filter.Text==''then musicRefresh=0;discover(false)end
end)
U.Gui.Destroying:Connect(function()token=token+1;ticking:Disconnect();refreshConnection:Disconnect();if changedConnection then changedConnection:Disconnect()end;sound:Stop()end)
