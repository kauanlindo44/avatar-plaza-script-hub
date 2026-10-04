-- 07UI_SCREEN_BOUNDS | ModuleScript | ReplicatedStorage
-- V47: area nativa no topo; somente o recorte fisico do dispositivo na base.
local M={}
local Gui=game:GetService("GuiService")
function M.Rect(o,x,y,w,h)
 o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
end
function M.Bind(gui)
 gui.IgnoreGuiInset=true;gui.ScreenInsets=Enum.ScreenInsets.None;gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;gui.ClipToDeviceSafeArea=false
 local guide=Instance.new("ScreenGui");guide.Name=gui.Name.."_SafeGuide";guide.ResetOnSpawn=false
 guide.IgnoreGuiInset=false;guide.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;guide.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;guide.DisplayOrder=0;guide.Parent=gui.Parent
 local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundTransparency=1;frame.Active=false;frame.Selectable=false;frame.Parent=guide
 local device=Instance.new("ScreenGui");device.Name=gui.Name.."_DeviceGuide";device.ResetOnSpawn=false;device.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets;device.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;device.Parent=gui.Parent
 local area=Instance.new("Frame");area.Size=UDim2.fromScale(1,1);area.BackgroundTransparency=1;area.Active=false;area.Selectable=false;area.Parent=device
 local B={Guide=frame,Connections={}}
 function B.Read()
  local p=frame.AbsolutePosition;local dp,ds=area.AbsolutePosition,area.AbsoluteSize;local v=gui.AbsoluteSize
  local top=math.max(dp.Y,p.Y)
  pcall(function()top=math.max(top,Gui.TopbarInset.Max.Y)end)
  return dp.X,top,math.max(0,v.X-dp.X-ds.X),math.max(0,v.Y-dp.Y-ds.Y),v.X,v.Y
 end
 function B.Heading(title,close)
  local il,it,ir,_,w=B.Read();local x,y,last=il+8,it+4,w-ir-8
  M.Rect(title,x,y,last-x-56,48);M.Rect(close,last-48,y,48,48)
  close.ZIndex=math.max(close.ZIndex,50);close.Active=true;close.Selectable=true
  return y+54
 end
 function B.Watch(fn)
  for _,pair in ipairs({{gui,"AbsoluteSize"},{frame,"AbsoluteSize"},{frame,"AbsolutePosition"},{area,"AbsoluteSize"},{area,"AbsolutePosition"}})do table.insert(B.Connections,pair[1]:GetPropertyChangedSignal(pair[2]):Connect(fn))end
  pcall(function()table.insert(B.Connections,Gui:GetPropertyChangedSignal("TopbarInset"):Connect(fn))end)
  task.defer(fn)
 end
 gui.Destroying:Connect(function()for _,c in ipairs(B.Connections)do c:Disconnect()end;guide:Destroy();device:Destroy()end)
 return B
end
return M
