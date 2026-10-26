do
-- Only unavailable engine services are doubled here. Project factories stay real.
RenderCallbacks78={}
function Services.RunService:BindToRenderStep(name,priority,fn)RenderCallbacks78[name]=fn end
function Services.RunService:UnbindFromRenderStep(name)RenderCallbacks78[name]=nil end
function render78(dt)for _,fn in pairs(table.clone(RenderCallbacks78))do fn(dt or 1/60)end end
local v2=getmetatable(Vector2.zero);local vi=v2.__index
v2.__div=function(a,b)return Vector2.new(a.X/b,a.Y/b)end
v2.__mul=function(a,b)if type(a)=='number'then a,b=b,a end;return Vector2.new(a.X*b,a.Y*b)end
v2.__index=function(v,k)if k=='Unit'then local n=v.Magnitude;return n==0 and Vector2.zero or v/n end;return vi(v,k)end
local cf78=getmetatable(CFrame.new())
function cf78:VectorToWorldSpace(v)return self.RightVector*v.X+self.UpVector*v.Y-self.LookVector*v.Z end

-- Typed native properties must reject nil rather than silently using a fake default.
local propertyMeta78=getmetatable(pg);local nativeSet78=propertyMeta78.__newindex
propertyMeta78.__newindex=function(o,k,v)
 if k=='Visible'or k=='Enabled'or k=='ScrollingEnabled'or k=='Interactable'then assert(type(v)=='boolean','native '..k..' boolean expected, got '..type(v)..' for '..tostring(o.Name))end
 return nativeSet78(o,k,v)
end

end
