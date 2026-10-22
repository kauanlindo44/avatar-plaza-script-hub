-- BC_Client | LocalScript | StarterPlayer > StarterPlayerScripts | V74 (CRIAR)
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local Run=game:GetService('RunService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');local kit=Rep:WaitForChild('PracaKit',40);if not kit then return end
local rem=kit:WaitForChild('Remotes');local rpc=rem:WaitForChild('BC_Request',30);local push=rem:WaitForChild('BC_Push',30);local fire=rem:WaitForChild('BC_Fire',30)
if not rpc or not push or not fire then warn('[BC][CLIENT] Servidor ausente: confira todos os módulos BC_ e BC_Server.');return end
if pg:GetAttribute('BC_ClientRunning')then warn('[BC][CLIENT] BC_Client duplicado.');return end;pg:SetAttribute('BC_ClientRunning',true)
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local old=pg:FindFirstChild('BC_GameGui');if old then old:Destroy()end
local gui=D.New('ScreenGui',{Name='BC_GameGui',ResetOnSpawn=false,DisplayOrder=190,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local U=require(Rep:WaitForChild('BC_HUD')).Build(gui);local V=require(Rep:WaitForChild('BC_VisualEffects')).New()
local state={};local hidden={};local focusOn=false;local oldCamera;local watched;local lastFire=-100;local busy=false;local toolConnections={};local visible=false
local function owned(g)
 if not g:IsA('ScreenGui')or g==gui or g.Name:find('Guide')then return false end
 local n=g.Name;return n:find('^ACP_')or n:find('^Avatar')or n:find('^LM')or n:find('^Fashion')or n=='LimitedMarketHUD'or n=='GameClubGui'or n=='CreatorHUD_V2'or n=='HubAvatarLauncher'or n=='PlazaProgressGui'
end
local function focus(on)
 if on==focusOn then return end;focusOn=on
 for _,g in ipairs(pg:GetChildren())do
  if owned(g)then
   if on then hidden[g]=g.Enabled;g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end
  end
 end
 if not on then for g,value in pairs(hidden)do if g.Parent then g.Enabled=value end;hidden[g]=nil end end
end
local function restoreCamera()
 local camera=workspace.CurrentCamera
 if oldCamera and camera then
  camera.CameraType=oldCamera.kind;camera.CameraSubject=oldCamera.subject and oldCamera.subject.Parent and oldCamera.subject or pl.Character and pl.Character:FindFirstChildOfClass('Humanoid')
  camera.FieldOfView=oldCamera.fov;oldCamera=nil
 end
 U.Spectating=false;watched=nil
end
local function arenaVisibility()
 local arena=workspace:FindFirstChild('BC_Arena');if not arena then return end
 local participant=state.matchId~=nil
 for _,o in ipairs(arena:GetDescendants())do
  if o:IsA('BasePart')then o.LocalTransparencyModifier=participant and 0 or 1
  elseif o:IsA('ProximityPrompt')then o.Enabled=participant and state.phase=='ACTIVE'and state.alive==true and state.button=='DISPONÍVEL'end
 end
end
local function render(data)
 state=data or{};visible=visible or state.matchId~=nil
 gui.Enabled=true
 if not visible then return end
 local match=state.matchId~=nil;focus(true)
 if match and not oldCamera then
  local camera=workspace.CurrentCamera;if camera then oldCamera={kind=camera.CameraType==Enum.CameraType.Scriptable and Enum.CameraType.Custom or camera.CameraType,subject=camera.CameraSubject,fov=camera.FieldOfView};camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=pl.Character and pl.Character:FindFirstChildOfClass('Humanoid')end
  task.spawn(function()pcall(function()pl:RequestStreamAroundAsync(Vector3.new(0,6000,0),3)end)end)
 end
 if not match and oldCamera then restoreCamera()end
 if state.alive==true then U.Spectating=false;watched=nil end
 U.Set(state);V.Reconcile(state);arenaVisibility()
end
local function close()
 visible=false;U.Queue.Visible=false;U.Hud.Visible=false;U.Result.Visible=false;U.Confirm.Visible=false;V.Clear();restoreCamera();focus(false);arenaVisibility()
end
local function call(action,arg)
 if busy then return nil end;busy=true
 local ok,r=pcall(function()return rpc:InvokeServer(action,arg or{})end);busy=false
 if not ok or type(r)~='table'or not r.ok then
  local msg=ok and r and r.error or'O servidor não respondeu. Tente novamente.'
  U.QueueStatus.Text=tostring(msg);if U.Hud.Visible then U.Announce({title='Não foi possível concluir',text=msg,seconds=2})end
  return nil
 end
 return r
end
local function leave()
 task.spawn(function()local r=call('leave');if r then state={};close()end end)
end
local function requestExit()
 if state.matchId and state.phase~='RESULTS'then U.Confirm.Visible=true;U.Layout()else leave()end
end
local function shoot()
 if not visible or not state.weapon or state.phase~='ACTIVE'or not state.alive or os.clock()-lastFire<.15 then return end
 lastFire=os.clock();local camera=workspace.CurrentCamera;if not camera then return end
 -- Mira no centro da câmera; o servidor usa a posição real do personagem, nunca a origem enviada.
 local ray=camera:ViewportPointToRay(camera.ViewportSize.X*.5,camera.ViewportSize.Y*.5)
 local root=pl.Character and pl.Character:FindFirstChild('HumanoidRootPart');if not root then return end
 local direction=(ray.Origin+ray.Direction*55-(root.Position+Vector3.new(0,1,0)))
 fire:FireServer({token=state.weapon.token,direction=direction.Unit})
end
local function bindTools()
 for _,c in ipairs(toolConnections)do c:Disconnect()end;toolConnections={}
 local char=pl.Character;if not char then return end
 local function bind(o)if o:IsA('Tool')and o:GetAttribute('BC_Tool')then toolConnections[#toolConnections+1]=o.Activated:Connect(shoot)end end
 for _,o in ipairs(char:GetChildren())do bind(o)end;toolConnections[#toolConnections+1]=char.ChildAdded:Connect(bind)
end
U.Join.Activated:Connect(function()task.spawn(function()call('join')end)end)
U.Training.Activated:Connect(function()task.spawn(function()call('training')end)end)
U.LeaveQueue.Activated:Connect(leave);U.Back.Activated:Connect(requestExit);U.Close.Activated:Connect(requestExit)
U.Exit.Activated:Connect(requestExit);U.SpectatorBack.Activated:Connect(requestExit);U.ResultBack.Activated:Connect(leave)
U.Yes.Activated:Connect(function()U.Confirm.Visible=false;leave()end);U.No.Activated:Connect(function()U.Confirm.Visible=false end)
U.Continue.Activated:Connect(function()task.spawn(function()call('continue')end)end);U.Fire.Activated:Connect(shoot)
U.Reduce.Activated:Connect(function()V.reduced=not V.reduced;U.Reduce.Text=V.reduced and'Efeitos: suaves'or'Efeitos: completos' end)
local function nextSpectator()
 local list={};for _,v in ipairs(state.roster or{})do if v.alive then list[#list+1]=v.id end end
 if #list==0 then return end
 local index=(table.find(list,watched)or 0)%#list+1;watched=list[index];U.Spectating=true
 local p=Players:GetPlayerByUserId(watched);local h=p and p.Character and p.Character:FindFirstChildOfClass('Humanoid')
 if h and workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;workspace.CurrentCamera.CameraSubject=h;U.Eliminated.Text='Assistindo '..p.DisplayName end
 U.Set(state)
end
U.Watch.Activated:Connect(nextSpectator);U.Next.Activated:Connect(nextSpectator)
push.OnClientEvent:Connect(function(kind,data)
 if kind=='state'then render(data)
 elseif kind=='return'then local again=state.continueNext;state={};close();if again then visible=true;focus(true);U.Queue.Visible=true;U.QueueStatus.Text='Retornando à próxima fila…'end
 elseif kind=='announce'then if visible then U.Announce(data)end
 elseif kind=='error'then U.QueueStatus.Text=data.text or'Não foi possível entrar.'
 else V.Handle(kind,data or{})end
end)
local function open()
 if busy then return end
 if pg:GetAttribute('ACP_LocalBoardActive')or pg:GetAttribute('ACP_TrucoActive')then return end
 visible=true;U.Queue.Visible=true;focus(true);U.QueueStatus.Text='Consultando a fila…'
 task.spawn(function()local r=call('status');if r and r.data then render(r.data)end end)
end
pg:GetAttributeChangedSignal('ACP_OpenChaosNonce'):Connect(open)
pl.CharacterAdded:Connect(function()task.defer(bindTools);if state.matchId and state.alive==false and not U.Spectating and workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject=pl.Character and pl.Character:FindFirstChildOfClass('Humanoid')end end)
local visibilityClock=0;local conn=Run.Heartbeat:Connect(function(dt)
 visibilityClock=visibilityClock+dt;if visibilityClock<.5 then return end;visibilityClock=0;arenaVisibility()
 if U.Spectating then local p=watched and Players:GetPlayerByUserId(watched);if not p or not p.Character or not p.Character:FindFirstChildOfClass('Humanoid')or p.Character:FindFirstChildOfClass('Humanoid').Health<=0 then nextSpectator()end end
end)
gui.Destroying:Connect(function()conn:Disconnect();for _,c in ipairs(toolConnections)do c:Disconnect()end;V.Destroy();restoreCamera();focus(false);pg:SetAttribute('BC_ClientRunning',nil)end)
pg.ChildAdded:Connect(function(g)if focusOn and owned(g)then hidden[g]=g.Enabled;g.Enabled=false end end)
bindTools();arenaVisibility();print('[V74][BC] Interface, mira e espectador conectados')
