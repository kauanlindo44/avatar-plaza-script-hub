-- 07UI_SCREEN_BOUNDS | ModuleScript | ReplicatedStorage
-- V43: viewport inteiro e area segura apenas para controles interativos.
local M={}
local Gui=game:GetService("GuiService")
function M.Rect(o,x,y,w,h)
 o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
end
function M.Bind(gui)
 local guide=Instance.new("ScreenGui");guide.Name=gui.Name.."_SafeGuide";guide.ResetOnSpawn=false
 guide.IgnoreGuiInset=false;guide.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;guide.DisplayOrder=0;guide.Parent=gui.Parent
 local frame=Instance.new("Frame");frame.Size=UDim2.fromScale(1,1);frame.BackgroundTransparency=1;frame.Active=false;frame.Selectable=false;frame.Parent=guide
 local B={Guide=frame,Connections={}}
 function B.Read()
  local p,s=frame.AbsolutePosition,frame.AbsoluteSize;local v=gui.AbsoluteSize
  return p.X,p.Y,math.max(0,v.X-p.X-s.X),math.max(0,v.Y-p.Y-s.Y),v.X,v.Y
 end
 function B.Heading(title,close)
  local il,it,ir,_,w=B.Read();local x,y,last=il+8,it+4,w-ir-8
  M.Rect(title,x,y,last-x-56,48);M.Rect(close,last-48,y,48,48)
  close.ZIndex=math.max(close.ZIndex,50);close.Active=true;close.Selectable=true
  return y+54
 end
 function B.Watch(fn)
  for _,pair in ipairs({{gui,"AbsoluteSize"},{frame,"AbsoluteSize"},{frame,"AbsolutePosition"}})do table.insert(B.Connections,pair[1]:GetPropertyChangedSignal(pair[2]):Connect(fn))end
  pcall(function()table.insert(B.Connections,Gui:GetPropertyChangedSignal("TopbarInset"):Connect(fn))end)
  task.defer(fn)
 end
 gui.Destroying:Connect(function()for _,c in ipairs(B.Connections)do c:Disconnect()end;guide:Destroy()end)
 return B
end
return M
