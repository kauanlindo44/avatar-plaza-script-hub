-- 07UI_SLIDER | ModuleScript | ReplicatedStorage | V58 (NOVO)
-- Controle por arraste/toque/teclado com área de interação de 44px.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local UIS=game:GetService('UserInputService');local M={}
function M.Build(parent,label,onChange,onCommit)
 local S={Value=0,Dragging=false,Enabled=true};local C=D.Colors
 S.Root=D.New('Frame',{Name='Slider_'..label,Size=UDim2.new(1,0,0,44),BackgroundTransparency=1},parent)
 S.Label=D.Text(S.Root,label,{Position=UDim2.fromOffset(4,0),Size=UDim2.new(1,-8,0,18),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
 local track=D.Frame(S.Root,{Position=UDim2.new(0,10,0,29),Size=UDim2.new(1,-20,0,5),BackgroundColor3=C.soft})
 S.Fill=D.Frame(track,{Size=UDim2.fromScale(0,1),BackgroundColor3=C.orange})
 S.Knob=D.Frame(track,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(16,16),BackgroundColor3=C.white})
 S.Hit=D.Button(S.Root,'',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1});S.Hit:SetAttribute('ActionLabel',label)
 function S.Set(v,silent)
  v=tonumber(v);if not v or v~=v then return end;S.Value=math.clamp(v,0,1)
  S.Fill.Size=UDim2.fromScale(S.Value,1);S.Knob.Position=UDim2.fromScale(S.Value,.5)
  if not silent and onChange then onChange(S.Value)end
 end
 function S.Enable(value)S.Enabled=value==true;D.SetEnabled(S.Hit,S.Enabled);S.Knob.BackgroundTransparency=S.Enabled and 0 or .6 end
 local touch;local function move(i)
  if not S.Enabled or track.AbsoluteSize.X<=0 then return end
  S.Set((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X)
 end
 S.Hit.InputBegan:Connect(function(i)
  if S.Enabled and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then S.Dragging=true;touch=i;move(i)
  elseif S.Enabled and i.UserInputType==Enum.UserInputType.Keyboard and(i.KeyCode==Enum.KeyCode.Left or i.KeyCode==Enum.KeyCode.Right)then
   S.Set(S.Value+(i.KeyCode==Enum.KeyCode.Right and .05 or-.05));if onCommit then onCommit(S.Value)end
  end
 end)
 local moved=UIS.InputChanged:Connect(function(i)if S.Dragging and(i==touch or i.UserInputType==Enum.UserInputType.MouseMovement)then move(i)end end)
 local ended=UIS.InputEnded:Connect(function(i)
  if S.Dragging and(i==touch or i.UserInputType==Enum.UserInputType.MouseButton1)then move(i);S.Dragging=false;touch=nil;if onCommit then onCommit(S.Value)end end
 end)
 S.Root.Destroying:Connect(function()moved:Disconnect();ended:Disconnect();S.Dragging=false end)
 return S
end
return M
