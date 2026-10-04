-- V47 service additions; still not native Roblox rendering.
ColorSequenceKeypoint={new=function(t,c)return{Time=t,Value=c}end}
local previous=Instance.new
Instance.new=function(class)local o=previous(class);if class=='ImageLabel'then o.IsLoaded=true end;return o end
Services.UserInputService.InputBegan=Signal()
local vm=getmetatable(Vector3.zero);local priorIndex=vm.__index
vm.__index=function(v,k)
 if k=='Unit'then local length=math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z);return length==0 and Vector3.new(0,0,-1)or v/length end
 if k=='Magnitude'then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)end
 return type(priorIndex)=='function'and priorIndex(v,k)or type(priorIndex)=='table'and priorIndex[k]or nil
end
local cf=getmetatable(CFrame.new())
function cf:PointToObjectSpace(v)return self:Inverse()*v end
function cf:VectorToObjectSpace(v)return Vector3.new(v.X*self.RightVector.X+v.Y*self.RightVector.Y+v.Z*self.RightVector.Z,v.X*self.UpVector.X+v.Y*self.UpVector.Y+v.Z*self.UpVector.Z,-(v.X*self.LookVector.X+v.Y*self.LookVector.Y+v.Z*self.LookVector.Z))end
function workspace.CurrentCamera:WorldToViewportPoint(v)
 local p=self.CFrame:PointToObjectSpace(v);local tan=math.tan(math.rad(self.FieldOfView/2));local depth=-p.Z
 return Vector3.new((.5+p.X/(2*depth*tan*self.ViewportSize.X/self.ViewportSize.Y))*self.ViewportSize.X,(.5-p.Y/(2*depth*tan))*self.ViewportSize.Y,depth),depth>0
end
function workspace.CurrentCamera:ViewportPointToRay(x,y)
 local tan=math.tan(math.rad(self.FieldOfView/2));local dir=Vector3.new((x/self.ViewportSize.X-.5)*2*tan*self.ViewportSize.X/self.ViewportSize.Y,(.5-y/self.ViewportSize.Y)*2*tan,-1)
 dir=(self.CFrame.RightVector*dir.X+self.CFrame.UpVector*dir.Y-self.CFrame.LookVector*dir.Z).Unit
 return{Origin=self.CFrame.Position,Direction=dir}
end
local oldCtor=Instance.new
Instance.new=function(class)
 local o=oldCtor(class)
 if o:IsA('BasePart')then
  o.LocalTransparencyModifier=0
  function o:Clone()local n=Instance.new(self.ClassName);n.Size=self.Size;n.Color=self.Color;n.CFrame=self.CFrame;n.Name=self.Name;return n end
 end
 if class=='RemoteEvent'then o.OnClientEvent=Signal()end
 return o
end
local meta=getmetatable(pg);local setter=meta.__newindex
meta.__newindex=function(o,k,v)
 if k=='Active'or k=='AutoButtonColor'then assert(type(v)=='boolean','native boolean property '..k..' received '..type(v))end
 setter(o,k,v)
end

Services.GuiService.TouchControlsEnabled=true
-- Native Motor6D defaults and Euler decomposition for the pose capture tests.
local poseCtor=Instance.new
Instance.new=function(class)local o=poseCtor(class);if class=='Motor6D'then o.C0=CFrame.identity;o.C1=CFrame.identity end;return o end
function cf:ToOrientation()
 local y=math.asin(math.clamp(-self.LookVector.X,-1,1));local x=math.atan2(self.LookVector.Y,-self.LookVector.Z);local z=math.atan2(self.UpVector.X*-1,self.RightVector.X);return x,y,z
end
cf.ToEulerAnglesXYZ=cf.ToOrientation
RaycastParams={new=function()return{}end}
function workspace:Raycast()return TEST_RAY_HIT end
local nativeCtor=Instance.new
Instance.new=function(class)
 local o=nativeCtor(class);if class=='Animator'then o.AnimationPlayed=Signal()end
 function o:FindFirstChildWhichIsA(kind,recursive)for _,v in ipairs(recursive and self:GetDescendants()or self:GetChildren())do if v:IsA(kind)then return v end end end
 return o
end
local nativeIndex=meta.__index
meta.__index=function(o,k)
 if nativeIndex(o,'ClassName')=='ScreenGui'and nativeIndex(o,'ScreenInsets')==Enum.ScreenInsets.DeviceSafeInsets then
  local l,r,t,b=DEVICE_LEFT or CORE_LEFT or 0,DEVICE_RIGHT or CORE_RIGHT or 0,DEVICE_TOP or CORE_TOP or 0,DEVICE_BOTTOM or CORE_BOTTOM or 0
  if k=='AbsolutePosition'then return Vector2.new(l,t)end
  if k=='AbsoluteSize'then return Vector2.new(SCREEN_W-l-r,SCREEN_H-t-b)end
 end
 return nativeIndex(o,k)
end
