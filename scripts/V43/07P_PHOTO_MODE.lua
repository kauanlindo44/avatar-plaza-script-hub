-- 07P_PHOTO_MODE | LocalScript | StarterPlayer > StarterPlayerScripts
-- V43: poses confirmadas, cinco fundos, ambiente e captura nativa.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Studio=require(Rep:WaitForChild("07P2_STUDIO_AVATAR"))
local Presets=require(Rep:WaitForChild("07P0_STUDIO_PRESETS"))
local Capture=require(Rep:WaitForChild("07P1_CAPTURE_ENGINE"))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local U=require(Rep:WaitForChild("07P4_STUDIO_UI")).Build(pl)
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local hidden={};local current=nil;local active=false;local entering=false;local serial=0
local orbit=nil;local orbitSpeed=.5;local capturing=false;local captureId=0;local drag=nil;local lastX=0
local function status(msg)U.Status.Text=tostring(msg or"")end
local function stopOrbit()if orbit then orbit:Disconnect();orbit=nil end end
local function cancelPose()if Studio.Pose and Studio.Pose.Editing then Studio.Pose.Cancel()end end
local function closePanel()
 cancelPose();if U.PoseEditor then U.PoseEditor.Destroy();U.PoseEditor=nil end
 U.PoseMode=false;current=nil;U.Popup.Visible=false;U.PoseFooter.Visible=false;U.Layout()
end
U.OnLayout=function(il,it,ir,ib,w,h,landscape,top)
 if not active then return end
 if U.Restore.Visible or capturing then Studio.SetMargins(0,0,0,0);return end
 if U.PoseMode then Studio.SetMargins(il+6,it+58,ir+U.Popup.AbsoluteSize.X+18,ib+54);return end
 local right=ir+(U.Popup.Visible and landscape and U.Popup.AbsoluteSize.X+12 or 0)
 local bottom=ib+60+(U.Popup.Visible and not landscape and U.Popup.AbsoluteSize.Y+10 or 0)
 Studio.SetMargins(il+6,top,right+6,bottom)
end
local function leave()
 serial=serial+1;active=false;entering=false;capturing=false;drag=nil;stopOrbit();closePanel();Studio.Exit()
 U.Root.Visible=false;U.Popup.Visible=false;U.Restore.Visible=false;U.Gui.Enabled=true
 for g,enabled in pairs(hidden)do if g.Parent then g.Enabled=enabled end end
 hidden={};current=nil
end
local function enter()
 if active or entering then return end
 serial=serial+1;local mine=serial;entering=true
 local ok,worked,msg=pcall(Studio.Enter)
 entering=false
 if mine~=serial then return end
 if not ok or not worked then Studio.Exit();U.Root.Visible=true;status(ok and msg or"Não foi possível abrir o estúdio.");task.delay(3,function()if not active then U.Root.Visible=false end end);return end
 active=true;hidden={}
 for _,g in ipairs(pg:GetChildren())do if g:IsA("ScreenGui")and g~=U.Gui then hidden[g]=g.Enabled;g.Enabled=false end end
 U.Gui.Enabled=true;U.Root.Visible=true;U.SetClean(false);status("Arraste para girar. Abra Pose para editar o corpo.");U.Layout()
end
local function showPose()
 local pose=Studio.Pose;if not pose or #pose.Joints==0 then status("Este avatar não tem articulações editáveis.");return end
 pose.Begin();U.PoseMode=true;U.PoseFooter.Visible=true;U.PopupTitle.Text="Editar pose"
 U.PoseEditor=require(Rep:WaitForChild("07P5_POSE_CANVAS")).Build(U.Popup,pose,function()
  task.defer(function()Run.RenderStepped:Wait();if active then Studio.Fit()end end)
 end)
 status("Toque e arraste o manequim.")
end
local function showBackgrounds()
 U.PopupTitle.Text="Fundos"
 for i,p in ipairs(Presets.Backgrounds)do
  local b=U.Option(p.name,i,p.a:Lerp(D.Colors.bg,.4));b.Size=UDim2.new(1,-4,0,54)
  b.Activated:Connect(function()Studio.BuildSet(p.id);status("Fundo: "..p.name)end)
 end
 U.Option("Animar / pausar fundo",6).Activated:Connect(function()if Studio.Scene then Studio.Scene.SetAnimated(not Studio.Scene.Animated)end end)
end
local function showEnvironment()
 U.PopupTitle.Text="Ambiente"
 U.TextLine("Ajustes de luz somente para esta foto.",1)
 local defs={{"Exposure","Exposição"},{"Brightness","Intensidade"},{"Time","Hora do dia"},{"Contrast","Contraste"},{"Saturation","Saturação"}}
 for i,def in ipairs(defs)do
  local key=def[1];local ctl=U.Row(def[2],string.format("%.2f",Studio.Environment[key]),i+1);U.Environment[key]=ctl
  local function set(n)if Studio.SetEnvironment(key,n)then ctl.Value.Text=string.format("%.2f",Studio.Environment[key])end end
  local step=Studio.EnvironmentRules[key][3]
  ctl.Minus.Activated:Connect(function()set(Studio.Environment[key]-step)end)
  ctl.Plus.Activated:Connect(function()set(Studio.Environment[key]+step)end)
  ctl.Value.FocusLost:Connect(function()local n=tonumber(ctl.Value.Text);if n then set(n)else ctl.Value.Text=string.format("%.2f",Studio.Environment[key])end end)
 end
 for i,p in ipairs(Presets.Lights)do U.Option("Luz "..p.name,7+i).Activated:Connect(function()Studio.SetLight(p.id);status("Luz "..p.name)end)end
 U.Option("Restaurar ambiente",12).Activated:Connect(function()Studio.SetLight("BRIGHT");Studio.ResetEnvironment();for key,c in pairs(U.Environment)do c.Value.Text=string.format("%.2f",Studio.Environment[key])end end)
end
local function startOrbit()
 stopOrbit();orbit=Run.RenderStepped:Connect(function(dt)if active then Studio.SetAvatarYaw((Studio.AvatarYaw+dt*45*orbitSpeed)%360)end end)
 status("Órbita ativa.")
end
local function showCamera()
 U.PopupTitle.Text="Câmera"
 for i,p in ipairs(Presets.Frames)do U.Option(p.name,i).Activated:Connect(function()Studio.SetFrame(p.id)end)end
 U.Option("Frente",4).Activated:Connect(function()stopOrbit();Studio.SetAvatarYaw(0);Studio.SetYaw(180)end)
 U.Option("Costas",5).Activated:Connect(function()stopOrbit();Studio.SetAvatarYaw(0);Studio.SetYaw(0)end)
 U.Option("Lado esquerdo",6).Activated:Connect(function()stopOrbit();Studio.SetYaw(90)end)
 U.Option("Lado direito",7).Activated:Connect(function()stopOrbit();Studio.SetYaw(270)end)
 U.Option("Aproximar",8).Activated:Connect(function()Studio.SetZoom(Studio.Zoom+.1)end)
 U.Option("Afastar",9).Activated:Connect(function()Studio.SetZoom(Studio.Zoom-.1)end)
 U.Option("Iniciar / parar órbita",10).Activated:Connect(function()if orbit then stopOrbit();status("Órbita parada.")else startOrbit()end end)
end
local function takePhoto()
 if capturing then return end
 capturing=true;captureId=captureId+1;local shot=captureId;local mine=serial;closePanel();U.Gui.Enabled=false;Studio.SetMargins(0,0,0,0)
 task.spawn(function()
  Run.RenderStepped:Wait();Run.RenderStepped:Wait()
  local function finish(msg)
   if mine~=serial or shot~=captureId or not capturing then return end;capturing=false;U.Gui.Enabled=true;U.SetClean(false);status(msg)
  end
  local worked,ok,err=pcall(Capture.TakePhoto,nil,function(success)finish(success and"Foto pronta. Abra Foto para salvar ou compartilhar."or"Não foi possível criar a foto.")end)
  if not worked or not ok then finish(worked and err or"Não foi possível criar a foto.")end
  task.delay(12,function()if mine==serial and capturing then finish("Captura indisponível neste dispositivo. Tente novamente.")end end)
 end)
end
local function showCapture()
 U.PopupTitle.Text="Foto"
 U.TextLine("Capture sem a interface e salve pela galeria do Roblox.",1)
 U.Option("Tirar foto",2,D.Colors.green).Activated:Connect(takePhoto)
 U.Option("Salvar última foto",3).Activated:Connect(function()local ok,err=Capture.SaveLast(function()status("Pedido de salvamento concluído.")end);if not ok then status(err)end end)
 U.Option("Compartilhar última foto",4).Activated:Connect(function()local ok,err=Capture.ShareLast(function()status("Compartilhamento confirmado.")end,function()status("Compartilhamento cancelado.")end);if not ok then status(err)end end)
end
local shows={Pose=showPose,Background=showBackgrounds,Environment=showEnvironment,Camera=showCamera,Capture=showCapture}
local function panel(key)
 if not active or capturing then return end
 if current==key and U.Popup.Visible then closePanel();return end
 closePanel();U.Clear();current=key;U.Popup.Visible=true
 shows[key]();U.Layout()
end
for key,fn in pairs(shows)do U.Buttons[key].Activated:Connect(function()panel(key)end)end
U.Buttons.Hide.Activated:Connect(function()if active then closePanel();U.SetClean(true)end end)
U.Close.Activated:Connect(leave);U.PopupClose.Activated:Connect(closePanel)
U.Restore.Activated:Connect(function()U.SetClean(false);U.Layout()end)
U.PoseConfirm.Activated:Connect(function()if Studio.Pose then Studio.Pose.Confirm()end;closePanel();status("Pose confirmada. O avatar permanece assim no estúdio.")end)
U.PoseCancel.Activated:Connect(closePanel)
U.PoseReset.Activated:Connect(function()if U.PoseEditor then U.PoseEditor.Reset()end end)
local nonce=tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0
pg:GetAttributeChangedSignal("ACP_OpenPhotoNonce"):Connect(function()
 local n=tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0
 if n~=nonce then nonce=n;if active or entering then leave()else enter()end end
end)
pl.CharacterAdded:Connect(function()if active or entering then leave()end end)
UIS.InputBegan:Connect(function(input,gp)
 if not active or capturing then return end
 if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then if U.Popup.Visible then closePanel()elseif U.Restore.Visible then U.SetClean(false)else leave()end;return end
 if gp then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  local p=input.Position
  for _,o in ipairs({U.Nav,U.Popup,U.Close,U.Restore})do if o.Visible then local a,s=o.AbsolutePosition,o.AbsoluteSize;if p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y then return end end end
  drag=input;lastX=p.X;stopOrbit()
 end
end)
UIS.InputChanged:Connect(function(input)
 if active and drag and(input==drag or input.UserInputType==Enum.UserInputType.MouseMovement)then local x=input.Position.X;Studio.Rotate(-(x-lastX)*.3);lastX=x end
end)
UIS.InputEnded:Connect(function(input)if input==drag or input.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end end)
U.Gui.Destroying:Connect(leave)
print("[V43] Photo Mode com poses e ambiente pronto")
