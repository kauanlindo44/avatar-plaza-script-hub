-- 07UI_SCREEN_BOUNDS | ModuleScript | ReplicatedStorage | V51
-- AbsolutePosition/GetInsetArea usam coordenadas relativas a CoreUISafeInsets.
local M={};local Gui=game:GetService("GuiService")
function M.Rect(o,x,y,w,h)
 o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
end
function M.Bind(gui)
 gui.IgnoreGuiInset=true;gui.ScreenInsets=Enum.ScreenInsets.None;gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;gui.ClipToDeviceSafeArea=false
 local guides={};local B={Connections={}}
 local function guide(name,kind)
  local g=Instance.new("ScreenGui");g.Name=gui.Name..name;g.ResetOnSpawn=false;g.ScreenInsets=kind;g.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;g.Parent=gui.Parent
  local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BackgroundTransparency=1;f.Active=false;f.Selectable=false;f.Parent=g
  guides[#guides+1]=g;return f
 end
 local core=guide("_SafeGuide",Enum.ScreenInsets.CoreUISafeInsets)
 local device=guide("_DeviceGuide",Enum.ScreenInsets.DeviceSafeInsets)
 local bar=guide("_TopbarGuide",Enum.ScreenInsets.TopbarSafeInsets);B.Guide=core
 local function area(kind,f)
  local ok,r=pcall(function()return Gui:GetInsetArea(kind)end)
  if ok and r then return r.Min.X,r.Min.Y,r.Max.X,r.Max.Y end
  local p,s=f.AbsolutePosition,f.AbsoluteSize;return p.X,p.Y,p.X+s.X,p.Y+s.Y
 end
 function B.Areas()
  local origin=gui.AbsolutePosition;local v=gui.AbsoluteSize
  local ok,x,y=pcall(function()local r=Gui:GetInsetArea(Enum.ScreenInsets.None);return r.Min.X,r.Min.Y end)
  if ok and x and y then origin=Vector2.new(x,y)end
  local dx,dy,ex,ey=area(Enum.ScreenInsets.DeviceSafeInsets,device)
  local cx,cy=area(Enum.ScreenInsets.CoreUISafeInsets,core)
  local bx,by,bex,bey=area(Enum.ScreenInsets.TopbarSafeInsets,bar)
  local function localRect(x1,y1,x2,y2)return{X=math.clamp(x1-origin.X,0,v.X),Y=math.clamp(y1-origin.Y,0,v.Y),Right=math.clamp(x2-origin.X,0,v.X),Bottom=math.clamp(y2-origin.Y,0,v.Y)}end
  return localRect(dx,dy,ex,ey),localRect(cx,cy,ex,ey),localRect(bx,by,bex,bey),v
 end
 function B.Read()
  local d,c,_,v=B.Areas();return d.X,math.max(d.Y,c.Y),v.X-d.Right,v.Y-d.Bottom,v.X,v.Y
 end
 function B.Topbar()local _,_,r=B.Areas();return r end
 function B.Heading(title,close)
  local il,it,ir,_,w=B.Read();local x,y,last=il+8,it+4,w-ir-8
  M.Rect(title,x,y,last-x-56,48);M.Rect(close,last-48,y,48,48)
  close.ZIndex=math.max(close.ZIndex,50);close.Active=true;close.Selectable=true;return y+54
 end
 function B.Watch(fn)
  for _,o in ipairs({gui,core,device,bar})do for _,p in ipairs({"AbsoluteSize","AbsolutePosition"})do B.Connections[#B.Connections+1]=o:GetPropertyChangedSignal(p):Connect(fn)end end
  pcall(function()B.Connections[#B.Connections+1]=Gui:GetPropertyChangedSignal("TopbarInset"):Connect(fn)end)
  task.defer(fn)
 end
 gui.Destroying:Connect(function()for _,c in ipairs(B.Connections)do c:Disconnect()end;for _,g in ipairs(guides)do g:Destroy()end end)
 return B
end
return M
