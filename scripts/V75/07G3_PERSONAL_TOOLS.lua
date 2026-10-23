-- 07G3_PERSONAL_TOOLS | ModuleScript | ReplicatedStorage | V75 (SUBSTITUIR)
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local M={};local pl=Players.LocalPlayer;local velocity,attachment,loop=nil,nil,nil;local busy=false;local finished=-100
local function stop()
 if loop then loop:Disconnect();loop=nil end;if velocity then velocity:Destroy();velocity=nil end;if attachment then attachment:Destroy();attachment=nil end
end
function M.Call(key,value)
 local rpc=Rep:WaitForChild("PracaKit"):WaitForChild("Remotes"):WaitForChild("PersonalSettings",10)
 if not rpc then return nil,"Comandos ainda estão conectando."end
 while busy or os.clock()-finished<.23 do task.wait(.03)end;busy=true
 local ok,r=pcall(function()return rpc:InvokeServer(key,value)end);busy=false;finished=os.clock()
 if not ok or type(r)~="table"then return nil,"Não foi possível ajustar seu personagem."end
 return r.ok and r.data or nil,r.error
end
function M.Privacy(value)
 local rpc=Rep:WaitForChild("PracaKit"):WaitForChild("Remotes"):FindFirstChild("TrucoRequest")
 if not rpc then return nil,"Configurações ainda estão conectando."end
 local ok,r=pcall(function()return rpc:InvokeServer("settings",{allowCopy=value})end);return ok and r.ok or nil,ok and r.error or"Não foi possível salvar a privacidade."
end
local function fly()
 stop();if not pl:GetAttribute("ACP_PersonalFly")or pl:GetAttribute("ACP_InGameRoom")then return end
 local char=pl.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
 attachment=Instance.new("Attachment");attachment.Name="ACP_FlightAttachment";attachment.Parent=root
 velocity=Instance.new("LinearVelocity");velocity.Name="ACP_PersonalFlight";velocity.Attachment0=attachment;velocity.MaxForce=math.min(100000,root.AssemblyMass*workspace.Gravity*5);velocity.RelativeTo=Enum.ActuatorRelativeTo.World;velocity.VectorVelocity=Vector3.zero;velocity.Parent=root
 loop=Run.PreSimulation:Connect(function()
  if not root.Parent or hum.Health<=0 or not pl:GetAttribute("ACP_PersonalFly")or pl:GetAttribute("ACP_InGameRoom")then stop();return end
  local move=hum.MoveDirection;local cam=workspace.CurrentCamera;local vertical=0
  if UIS:IsKeyDown(Enum.KeyCode.Space)or hum.Jump then vertical=1 elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl)then vertical=-1 end
  if cam and move.Magnitude>.1 then vertical=vertical+cam.CFrame.LookVector.Y*.6 end
  velocity.VectorVelocity=Vector3.new(move.X,vertical,move.Z)*math.min(32,pl:GetAttribute("ACP_PersonalSpeed")or 24)
 end)
end
pl:GetAttributeChangedSignal("ACP_InGameRoom"):Connect(fly);pl:GetAttributeChangedSignal("ACP_PersonalFly"):Connect(fly);pl.CharacterAdded:Connect(function()stop();task.delay(.5,fly)end)
M.Commands=require(Rep:WaitForChild('07G5_CHAT_COMMANDS'))
function M.CommandResult(r)
 local d=r and r.data
 local message=r and r.ok and'Comando aplicado ao seu personagem.'or r and r.error or'Comando indisponível.'
 if r and r.error then message=r.error end
 local pg=pl:FindFirstChild('PlayerGui')
 if d and d.camera and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=d.camera end
 if d and d.open and pg then
  if d.open=='Catalog'then local gui=pg:FindFirstChild('AvatarShop08Gui');local bus=gui and gui:FindFirstChild('OpenRequest');if bus then bus:Fire('Catalog')end
  else local key=d.open=='Photo'and'ACP_OpenPhotoNonce'or'ACP_OpenMusicNonce';pg:SetAttribute(key,(tonumber(pg:GetAttribute(key))or 0)+1)end
 end
 if d and d.help and pg then pg:SetAttribute('ACP_OpenCommandsNonce',(pg:GetAttribute('ACP_OpenCommandsNonce')or 0)+1);message='Lista de comandos aberta.'end
 if M.OnNotice then M.OnNotice(message)else warn('[Comandos] '..tostring(message))end
 local chat=game:GetService('TextChatService');local channels=chat:FindFirstChild('TextChannels');local channel=channels and(channels:FindFirstChild('RBXSystem')or channels:FindFirstChild('RBXGeneral'))
 if channel then pcall(function()channel:DisplaySystemMessage(tostring(message))end)end
end
local rem=Rep:WaitForChild('PracaKit'):WaitForChild('Remotes');local command=rem:WaitForChild('PersonalCommand',30)
if command then command.OnClientEvent:Connect(M.CommandResult)end
function M.Destroy()stop()end
return M
