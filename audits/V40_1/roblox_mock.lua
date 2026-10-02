-- Minimal test double. It does not emulate rendering, physics or Roblox services.
math.clamp=function(x,a,b)return math.max(a,math.min(b,x))end
table.find=function(t,v)for i,x in ipairs(t)do if x==v then return i end end end
table.clone=function(t)local c={};for k,v in pairs(t)do c[k]=v end;return c end
local function signal()
 local s={callbacks={}}
 function s:Connect(fn)table.insert(self.callbacks,fn);return{Disconnect=function()end}end
 function s:Fire(...)for _,fn in ipairs(self.callbacks)do fn(...)end end
 return s
end
Signal=signal
task={queue={}}
function task.spawn(fn,...)table.insert(task.queue,{fn=fn,args={...}})end
task.defer=task.spawn
function task.delay(_,fn,...)task.spawn(fn,...)end
function task.wait()end
function flush(index)
 local n=0
 while #task.queue>0 do
  local q=table.remove(task.queue,math.min(index or 1,#task.queue));q.fn(table.unpack(q.args));n=n+1
  assert(n<2000,'runaway task queue')
 end
end
local enumItem={__tostring=function(v)return 'Enum.'..v.Type..'.'..v.Name end}
Enum=setmetatable({},{__index=function(t,k)
 local e=setmetatable({},{__index=function(et,n)
  local item=setmetatable({Name=n,Type=k,Value=n=='EmoteAnimation'and 61 or #n},enumItem)
  rawset(et,n,item);return item
 end});rawset(t,k,e);return e
end})
function typeof(x)if type(x)=='table'and x.Type then return 'EnumItem'end;return type(x)end
Vector2={new=function(x,y)return{X=x or 0,Y=y or 0}end};Vector2.zero=Vector2.new()
Vector3={new=function(x,y,z)return{X=x or 0,Y=y or 0,Z=z or 0}end}
UDim={new=function(s,o)return{Scale=s or 0,Offset=o or 0}end}
UDim2={new=function(a,b,c,d)return{X=UDim.new(a,b),Y=UDim.new(c,d)}end}
function UDim2.fromOffset(x,y)return UDim2.new(0,x,0,y)end
function UDim2.fromScale(x,y)return UDim2.new(x,0,y,0)end
Color3={fromRGB=function(r,g,b)return{R=r/255,G=g/255,B=b/255}end}
ColorSequence={new=function(...)return{...}end}
local methods={}
function methods:IsA(c)
 if c==self.ClassName then return true end
 if c=='GuiButton'then return self.ClassName=='TextButton'or self.ClassName=='ImageButton'end
 if c=='GuiObject'then return not self.ClassName:match('^UI')and self.ClassName~='ScreenGui'and self.ClassName~='PlayerGui'and self.ClassName~='BindableEvent'and self.ClassName~='Folder'and self.ClassName~='RemoteFunction'end
 return false
end
function methods:GetChildren()local out={};for _,x in ipairs(self.children)do out[#out+1]=x end;return out end
function methods:GetDescendants()local out={};for _,x in ipairs(self.children)do out[#out+1]=x;for _,d in ipairs(x:GetDescendants())do out[#out+1]=d end end;return out end
function methods:FindFirstChild(n)for _,c in ipairs(self.children)do if c.Name==n then return c end end end
function methods:FindFirstChildOfClass(n)for _,c in ipairs(self.children)do if c.ClassName==n then return c end end end
function methods:WaitForChild(n)return self:FindFirstChild(n)or n end
function methods:GetPropertyChangedSignal(k)self.signals[k]=self.signals[k]or signal();return self.signals[k]end
function methods:GetAttributeChangedSignal(k)return self:GetPropertyChangedSignal('attr:'..k)end
function methods:SetAttribute(k,v)local old=self.attrs[k];self.attrs[k]=v;if old~=v then self:GetAttributeChangedSignal(k):Fire()end end
function methods:GetAttribute(k)return self.attrs[k]end
function methods:Fire(...)self.Event:Fire(...)end
function methods:Destroy()
 self.Destroying:Fire()
 if self.Parent then for i,x in ipairs(self.Parent.children)do if x==self then table.remove(self.Parent.children,i);break end end end
 self.props.Parent=nil;self.destroyed=true
end
function methods:GetFullName()return self.Name end
function methods:CaptureFocus()self.focused=true end
local meta={}
local function gridCell(o)
 local p=o.Parent;if not p or not o:IsA('GuiObject')then return end
 local g=p:FindFirstChildOfClass('UIGridLayout')
 if not g then
  local l=p:FindFirstChildOfClass('UIListLayout');if not l then return end
  local ps=p.AbsoluteSize;local s=o.Size;local w,h=ps.X*s.X.Scale+s.X.Offset,ps.Y*s.Y.Scale+s.Y.Offset
  local gap=l.Padding and l.Padding.Offset or 0;local n,offset=0,0;local passed=false
  for _,c in ipairs(p.children)do if c:IsA('GuiObject')then
   local ch=ps.Y*c.Size.Y.Scale+c.Size.Y.Offset
   if c==o then passed=true elseif not passed then offset=offset+ch+gap end;n=n+1
  end end
  if l.VerticalAlignment==Enum.VerticalAlignment.Center then offset=offset+(ps.Y-n*h-math.max(0,n-1)*gap)/2 end
  return w,h,0,offset
 end
 local ps=p.AbsoluteSize;local s=g.CellSize;local pad=g.CellPadding
 local w,h=ps.X*s.X.Scale+s.X.Offset,ps.Y*s.Y.Scale+s.Y.Offset
 local px,py=ps.X*pad.X.Scale+pad.X.Offset,ps.Y*pad.Y.Scale+pad.Y.Offset
 local cols=g.FillDirectionMaxCells or math.max(1,math.floor((ps.X+px)/(w+px)))
 local i=0;for _,c in ipairs(p.children)do if c:IsA('GuiObject')then if c==o then break end;i=i+1 end end
 return w,h,(i%cols)*(w+px),math.floor(i/cols)*(h+py)
end
local function screenArea(o)
 if o.ScreenInsets==Enum.ScreenInsets.None then return 0,0,SCREEN_W,SCREEN_H end
 local left,right,top,bottom=CORE_LEFT or 0,CORE_RIGHT or 0,CORE_TOP or 0,CORE_BOTTOM or 0
 return left,top,SCREEN_W-left-right,SCREEN_H-top-bottom
end
function meta.__index(o,k)
 if methods[k]then return methods[k]end
 if k=='AbsoluteSize'or k=='AbsoluteWindowSize'then
  if o.ClassName=='PlayerGui'then return Vector2.new(SCREEN_W,SCREEN_H)end
  if o.ClassName=='ScreenGui'then local _,_,w,h=screenArea(o);return Vector2.new(w,h)end
  local w,h=gridCell(o);if w then return Vector2.new(w,h)end
  local p=o.Parent;local ps=p and p.AbsoluteSize or Vector2.new(SCREEN_W,SCREEN_H);local s=o.Size
  return Vector2.new(ps.X*s.X.Scale+s.X.Offset,ps.Y*s.Y.Scale+s.Y.Offset)
 end
 if k=='AbsolutePosition'then
  if o.ClassName=='ScreenGui'then local x,y=screenArea(o);return Vector2.new(x,y)end
  local p=o.Parent;local ps=p and p.AbsoluteSize or Vector2.new(SCREEN_W,SCREEN_H)
  local pp=p and p.AbsolutePosition or Vector2.zero;local w,h,gx,gy=gridCell(o)
  if w then return Vector2.new(pp.X+gx,pp.Y+gy)end
  local pos,sz,an=o.Position,o.AbsoluteSize,o.AnchorPoint
  return Vector2.new(pp.X+ps.X*pos.X.Scale+pos.X.Offset-sz.X*an.X,pp.Y+ps.Y*pos.Y.Scale+pos.Y.Offset-sz.Y*an.Y)
 end
 if o.props[k]~=nil then return o.props[k]end
 return methods.FindFirstChild(o,k)
end
function meta.__newindex(o,k,v)
 if k=='Corner'or k=='IconColor'then error('invalid Instance property '..k)end
 if k=='Text'then assert(type(v)=='string','Text must be a string')end
 if k=='Parent'and o.props.Parent~=v then
  if o.props.Parent then for i,x in ipairs(o.props.Parent.children)do if x==o then table.remove(o.props.Parent.children,i);break end end end
  if v then table.insert(v.children,o)end
 end
 local old=o.props[k];o.props[k]=v
 if k=='Parent'and old~=v then if old then old.ChildRemoved:Fire(o)end;if v then v.ChildAdded:Fire(o)end end
 if old~=v and o.signals[k]then o.signals[k]:Fire()end
end
Instance={new=function(class)
 return setmetatable({props={ClassName=class,Name=class,Text='',Visible=true,Enabled=true,
  Size=UDim2.fromOffset(100,100),Position=UDim2.new(),AnchorPoint=Vector2.zero,
  CanvasPosition=Vector2.zero,AbsoluteCanvasSize=Vector2.new(100,100),
  ZIndex=1,DisplayOrder=0,ResetOnSpawn=false,BackgroundTransparency=0,TextTransparency=0,Active=true,
  ChildAdded=signal(),ChildRemoved=signal(),Destroying=signal(),
  MouseEnter=signal(),MouseLeave=signal(),SelectionGained=signal(),SelectionLost=signal(),
  Activated=signal(),FocusLost=signal(),Event=signal(),OnClientEvent=signal()},children={},signals={},attrs={}},meta)
end}
SCREEN_W,SCREEN_H=1600,720
pg=Instance.new('PlayerGui');pl={UserId=123,Name='Tester',WaitForChild=function(_,n)assert(n=='PlayerGui');return pg end}
rep=Instance.new('Folder');script=Instance.new('Folder');script.Parent=rep
Services={ReplicatedStorage=rep,GuiService={},Players={LocalPlayer=pl},AvatarEditorService={},MarketplaceService={}}
game={GetService=function(_,name)return Services[name]or{}end}
warn=function()end
require=function(name)if type(name)=='table'then name=name.Name end;assert(Modules[name],'unknown module '..tostring(name));return Modules[name]end
Modules={}
CatalogSearchParams={new=function()return{}end}
function loadModule(source,name)local f,e=load(source,'@'..name);assert(f,e);return f()end
function guiCards(grid)local n=0;for _,x in ipairs(grid:GetChildren())do if x:IsA('GuiButton')then n=n+1 end end;return n end

pl.CharacterAdded=Signal()
Services.UserInputService={InputBegan=Signal()}
TweenInfo={new=function()return{}end}
Services.TweenService={Create=function(_,o,_,props)return{Play=function()for k,v in pairs(props)do o[k]=v end end}end}
workspace=Instance.new('Folder');workspace.CurrentCamera={FieldOfView=70,CameraType=Enum.CameraType.Custom}
function installModule(name,source)
 local o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep;Modules[name]=loadModule(source,name);return Modules[name]
end
function named(parent,name)local o=parent:FindFirstChild(name);if o then return o end;for _,c in ipairs(parent:GetChildren())do local f=named(c,name);if f then return f end end end
function inside(o,p)
 local a,b,c,d=o.AbsolutePosition,o.AbsoluteSize,p.AbsolutePosition,p.AbsoluteSize
 assert(b.X>0 and b.Y>0,o.Name..' nonpositive size')
 assert(a.X>=c.X-1 and a.Y>=c.Y-1 and a.X+b.X<=c.X+d.X+1 and a.Y+b.Y<=c.Y+d.Y+1,o.Name..' outside '..p.Name..': '..a.X..','..a.Y..','..b.X..','..b.Y)
end
function intersects(a,b)
 local p,s,q,t=a.AbsolutePosition,a.AbsoluteSize,b.AbsolutePosition,b.AbsoluteSize
 return p.X<q.X+t.X-1 and p.X+s.X>q.X+1 and p.Y<q.Y+t.Y-1 and p.Y+s.Y>q.Y+1
end
