-- V43 additions to the V42 doubles. Still no rendering or actual Roblox services.
math.atan2=function(y,x)return math.atan(y,x)end
local colorMeta={}
function colorMeta:Lerp(b,t)return Color3.new(self.R+(b.R-self.R)*t,self.G+(b.G-self.G)*t,self.B+(b.B-self.B)*t)end
Color3.new=function(r,g,b)return setmetatable({R=r,G=g,B=b}, {__index=colorMeta})end
Color3.fromRGB=function(r,g,b)return Color3.new(r/255,g/255,b/255)end
local oldNew=Instance.new
Instance.new=function(class)
 local o=oldNew(class)
 o.InputBegan=Signal();o.InputChanged=Signal();o.InputEnded=Signal();o.DescendantAdded=Signal()
 if o:IsA('BasePart')then o.Transparency=0 end
 function o:ReleaseFocus()self.focused=false end
 local destroy=o.Destroy
 function o:Destroy()
  if self.destroyed or self.destroying then return end;self.destroying=true
  for _,child in ipairs(self:GetChildren())do child:Destroy()end
  destroy(self);self.destroying=false
 end
 if class=='Model'then
  function o:PivotTo(c)
   local before=self.WorldPivot or self.pivot;local delta=c*before:Inverse()
   for _,p in ipairs(self:GetDescendants())do if p:IsA('BasePart')then p.CFrame=delta*p.CFrame end end
   self.pivot=c;self.WorldPivot=c
  end
  function o:GetPivot()return self.WorldPivot or self.pivot end
 end
 return o
end
local cm=getmetatable(CFrame.new())
function cm:Inverse()
 local r,u,l=self.RightVector,self.UpVector,self.LookVector
 local out=CFrame.new()
 out.RightVector=Vector3.new(r.X,u.X,-l.X);out.UpVector=Vector3.new(r.Y,u.Y,-l.Y);out.LookVector=Vector3.new(-r.Z,-u.Z,l.Z)
 local p=self.Position
 out.Position=Vector3.new(-(r.X*p.X+r.Y*p.Y+r.Z*p.Z),-(u.X*p.X+u.Y*p.Y+u.Z*p.Z),l.X*p.X+l.Y*p.Y+l.Z*p.Z)
 return out
end
cm.__index=cm
local create=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig)
 if onCreate then return onCreate(desc,rig,create)end
 local m=create(self,desc,rig)
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then p.CFrame=CFrame.new(p.Position)end end
 local joints=rig==Enum.HumanoidRigType.R6 and{'RootJoint'}or{'RightWrist','LeftWrist','RightHip','LeftHip','RightKnee','LeftKnee','RightAnkle','LeftAnkle'}
 for _,key in ipairs(joints)do local motor=Instance.new('Motor6D');motor.Name=key;motor.Part0=m.Torso;motor.Part1=m.Head;motor.Parent=m.Torso end
 return m
end
Services.UserService={}
UserBatches={}
function Services.UserService:GetUserInfosByUserIdsAsync(ids)
 UserBatches[#UserBatches+1]=table.clone(ids);local out={}
 for _,id in ipairs(ids)do if id%17~=0 then out[#out+1]={Id=id,Username='User'..id,DisplayName='Display '..id}end end
 return out
end
function Services.Players:GetPlayers()return{pl}end
function Services.MarketplaceService:GetProductInfoAsync(id)
 if onProduct then return onProduct(id)end
 return{Name='Item '..id,PriceInRobux=id*3,Creator={Name='Creator'..id}}
end
Services.Lighting.FogColor=Color3.fromRGB(140,160,180)
