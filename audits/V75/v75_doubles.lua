do
-- Contract doubles only: no native physics, permission checks or real sound playback.
local meta75=getmetatable(pg);local read75=meta75.__index
meta75.__index=function(o,k)
 if k=='Clone'and o:IsA('Sound')then return function(self)local x=Instance.new('Sound');for key,v in pairs(self.props)do if key~='Parent'then x[key]=v end end;return x end end
 if k=='AssemblyMass'and o:IsA('BasePart')then return o.props.AssemblyMass or 2 end
 if k=='SetNetworkOwner'then return function(self,owner)self.networkOwner=owner end end
 if k=='SetNetworkOwnershipAuto'then return function(self)self.networkAuto=true end end
 if k=='ApplyImpulse'then return function(self,v)self.lastImpulse=v;self.AssemblyLinearVelocity=self.AssemblyLinearVelocity+v/self.AssemblyMass end end
 return read75(o,k)
end
local vm75=getmetatable(Vector3.zero);local vr75=vm75.__index
vm75.__index=function(v,k)
 if k=='Dot'then return function(self,b)return self.X*b.X+self.Y*b.Y+self.Z*b.Z end end
 return type(vr75)=='function'and vr75(v,k)or vr75[k]
end

end
