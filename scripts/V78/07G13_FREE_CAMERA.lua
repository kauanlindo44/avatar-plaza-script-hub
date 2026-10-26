-- 07G13_FREE_CAMERA | ModuleScript | ReplicatedStorage | V78 (CRIAR)
-- WASD/arrasto e joystick de câmera; o personagem não recebe movimento nem teleporte.
local Players=game:GetService('Players');local Input=game:GetService('UserInputService');local Run=game:GetService('RunService')
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local M={Version='V78'};local currentController
function M.StopActive()if currentController then currentController.Stop()end end
function M.Build(pg,safe,onNotice)
 local pl=Players.LocalPlayer;local W={Active=false};local saved;local lookPointer,last;local movePointer;local move=Vector2.zero;local vertical=0;local links={};local controls;local controlsWereEnabled
 local gui=D.New('ScreenGui',{Name='ACP_FreeCamera',ResetOnSpawn=false,DisplayOrder=250,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Enabled=false},pg);B.Bind(gui)
 local exit=D.Button(gui,'Sair da câmera',{Name='ExitLiveCamera',TextSize=15,BackgroundColor3=Color3.fromRGB(52,80,100),TextColor3=Color3.fromRGB(247,250,255)})
 local hint=D.Text(gui,'WASD · arraste para olhar · Q/E para descer/subir',{TextSize=13,BackgroundColor3=Color3.fromRGB(229,239,245),BackgroundTransparency=.08,TextColor3=Color3.fromRGB(37,57,76)})
 local pad=D.Button(gui,'',{Name='CameraJoystick',BackgroundColor3=Color3.fromRGB(57,81,105),BackgroundTransparency=.3});D.Round(pad,99)
 local knob=D.Frame(pad,{Name='CameraJoystickHandle',BackgroundColor3=Color3.fromRGB(210,230,242),BackgroundTransparency=.15});D.Round(knob,99)
 local up=D.Button(gui,'↑',{Name='CameraRise',TextSize=25,BackgroundColor3=Color3.fromRGB(75,96,120)})
 local down=D.Button(gui,'↓',{Name='CameraLower',TextSize=25,BackgroundColor3=Color3.fromRGB(75,96,120)})
 local yaw,pitch=0,0
 local function add(signal,fn)local c=signal:Connect(fn);links[#links+1]=c;return c end
 local function padReset()movePointer=nil;move=Vector2.zero;B.Rect(knob,34,34,52,52)end
 function W.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir
  B.Rect(exit,il+(aw-176)/2,it+8,176,52);B.Rect(hint,il+(aw-math.min(420,aw-16))/2,it+66,math.min(420,aw-16),30)
  hint.Visible=not Input.TouchEnabled and h-it-ib>310
  B.Rect(pad,il+24,h-ib-148,120,120);pad.Visible=Input.TouchEnabled==true
  B.Rect(up,w-ir-80,h-ib-154,56,56);B.Rect(down,w-ir-80,h-ib-90,56,56);up.Visible=Input.TouchEnabled==true;down.Visible=up.Visible
  padReset()
 end
 local function getControls()
  local ps=pl:FindFirstChild('PlayerScripts');local pm=ps and ps:FindFirstChild('PlayerModule')
  if pm then local ok,lib=pcall(require,pm);if ok and type(lib)=='table'and type(lib.GetControls)=='function'then local yes,c=pcall(lib.GetControls,lib);if yes then return c end end end
 end
 function W.Stop()
  if not W.Active then return end;W.Active=false;if currentController==W then currentController=nil end;gui.Enabled=false
  pcall(function()Run:UnbindFromRenderStep('ACP_FreeCamera_V78')end)
  for _,c in ipairs(links)do c:Disconnect()end;links={};padReset();lookPointer=nil;vertical=0
  if controls and controlsWereEnabled~=false then pcall(function()controls:Enable()end)end;controls=nil
  if saved then
   local cam=saved.Camera
   if cam and cam.Parent then cam.CameraType=saved.Type;cam.CameraSubject=saved.Subject;cam.CFrame=saved.Frame;cam.FieldOfView=saved.Fov;cam.Focus=saved.Focus end
   Input.MouseBehavior=saved.MouseBehavior;Input.MouseIconEnabled=saved.MouseIcon
  end;saved=nil;pg:SetAttribute('ACP_FreeCameraActive',false)
 end
 function W.Start()
  if W.Active then W.Stop();return true end
  if pl:GetAttribute('ACP_InGameRoom')or pl:GetAttribute('BC_MatchId')or pg:GetAttribute('ACP_TrucoActive')then onNotice('Saia da partida antes de abrir a câmera livre.');return false end
  local cam=workspace.CurrentCamera;if not cam then return false end
  saved={Camera=cam,Type=cam.CameraType,Subject=cam.CameraSubject,Frame=cam.CFrame,Focus=cam.Focus,Fov=cam.FieldOfView,MouseBehavior=Input.MouseBehavior,MouseIcon=Input.MouseIconEnabled}
  controls=getControls();controlsWereEnabled=controls and controls.controlsEnabled
  if controls then pcall(function()controls:Disable()end)end
  pitch,yaw=cam.CFrame:ToOrientation();cam.CameraType=Enum.CameraType.Scriptable;W.Active=true;currentController=W;gui.Enabled=true;pg:SetAttribute('ACP_FreeCameraActive',true);W.Layout()
  local function movePad(io)
   local c=pad.AbsolutePosition+pad.AbsoluteSize/2;local delta=Vector2.new(io.Position.X-c.X,io.Position.Y-c.Y)/44
   if delta.Magnitude>1 then delta=delta.Unit end;move=delta;B.Rect(knob,34+delta.X*34,34+delta.Y*34,52,52)
  end
  add(pad.InputBegan,function(io)if io.UserInputType==Enum.UserInputType.Touch or io.UserInputType==Enum.UserInputType.MouseButton1 then movePointer=io;movePad(io)end end)
  for _,pair in ipairs({{up,1},{down,-1}})do
   add(pair[1].InputBegan,function(io)if io.UserInputType==Enum.UserInputType.Touch or io.UserInputType==Enum.UserInputType.MouseButton1 then vertical=pair[2]end end)
   add(pair[1].InputEnded,function()vertical=0 end)
  end
  add(Input.InputBegan,function(io,gp)
   if io.KeyCode==Enum.KeyCode.Escape or io.KeyCode==Enum.KeyCode.ButtonB then W.Stop();return end
   if gp or movePointer==io then return end
   if io.UserInputType==Enum.UserInputType.MouseButton2 or io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
    if io.UserInputType==Enum.UserInputType.Touch and io.Position.X<safe.Read()+select(5,safe.Read())*.4 then return end
    lookPointer=io;last=io.Position
    if io.UserInputType==Enum.UserInputType.MouseButton2 then Input.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition end
   end
  end)
  add(Input.InputChanged,function(io)
   if io==movePointer then movePad(io);return end
   if lookPointer and(io==lookPointer or io.UserInputType==Enum.UserInputType.MouseMovement)then
    local delta=Input.MouseBehavior==Enum.MouseBehavior.LockCurrentPosition and io.Delta or io.Position-last
    yaw=yaw-delta.X*.004;pitch=math.clamp(pitch-delta.Y*.004,-1.48,1.48);last=io.Position
   elseif io.UserInputType==Enum.UserInputType.MouseWheel and not Input:GetFocusedTextBox()then cam.FieldOfView=math.clamp(cam.FieldOfView-io.Position.Z*3,30,100)end
  end)
  add(Input.InputEnded,function(io)
   if io==movePointer then padReset()end
   if io==lookPointer or io.UserInputType==Enum.UserInputType.MouseButton2 then lookPointer=nil;Input.MouseBehavior=saved and saved.MouseBehavior or Enum.MouseBehavior.Default end
  end)
  local function step(dt)
   if not W.Active or workspace.CurrentCamera~=cam then W.Stop();return end
   local char=pl.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
   if hum then hum:Move(Vector3.zero,false);hum.Jump=false;if hum.Health<=0 then W.Stop();return end end
   local function held(k)return not Input:GetFocusedTextBox()and Input:IsKeyDown(Enum.KeyCode[k])and 1 or 0 end
   local v=Vector3.new(move.X+held('D')-held('A'),vertical+held('E')-held('Q'),move.Y+held('S')-held('W'))
   if v.Magnitude>1 then v=v.Unit end
   local rotation=CFrame.Angles(0,yaw,0)*CFrame.Angles(pitch,0,0);local speed=held('LeftShift')==1 and 36 or 18
   cam.CFrame=CFrame.new(cam.CFrame.Position+rotation:VectorToWorldSpace(v)*math.min(dt,.08)*speed)*rotation
   cam.Focus=cam.CFrame*CFrame.new(0,0,-16)
  end
  Run:BindToRenderStep('ACP_FreeCamera_V78',Enum.RenderPriority.Camera.Value+1,step)
  return true
 end
 exit.Activated:Connect(W.Stop)
 safe.Watch(function()if W.Active then W.Layout()end end)
 for _,key in ipairs({'ACP_OpenPhotoNonce','ACP_OpenGamesNonce','ACP_OpenAINonce'})do pg:GetAttributeChangedSignal(key):Connect(W.Stop)end
 pl:GetAttributeChangedSignal('ACP_InGameRoom'):Connect(function()if pl:GetAttribute('ACP_InGameRoom')then W.Stop()end end)
 pl:GetAttributeChangedSignal('BC_MatchId'):Connect(function()if pl:GetAttribute('BC_MatchId')then W.Stop()end end)
 pl.CharacterAdded:Connect(W.Stop);gui.Destroying:Connect(W.Stop);W.Gui=gui;W.Pad=pad;W.Exit=exit
 return W
end
return M
