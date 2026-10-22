-- Native contracts used by the V1. Does not simulate Roblox physics/networking/rendering.
OverlapParams={new=function()return{}end}
local type74=typeof;local v74=getmetatable(Vector3.zero)
function typeof(v)if getmetatable(v)==v74 then return'Vector3'end;return type74(v)end
local ctor74=Instance.new
function Instance.new(class,parent)
 local o=ctor74(class,parent)
 if class=='ProximityPrompt'then o.Triggered=signal()end
 if class=='Tool'then o.Activated=signal()end
 return o
end
function BCPlayer(id,rig)
 local p=makePlayer(id);p.Character.Name='Character_'..id
 local hum=p.Character:FindFirstChildOfClass('Humanoid');hum.MaxHealth=100;hum.Health=100;hum.WalkSpeed=16;hum.JumpPower=50;hum.JumpHeight=7.2;hum.UseJumpPower=true;hum.AutoRotate=true;hum.Died=signal()
 local root=p.Character:FindFirstChild('HumanoidRootPart');root.Anchored=false;root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 if rig=='R6'then hum.RigType=Enum.HumanoidRigType.R6;local leg=Instance.new('Part');leg.Name='Left Leg';leg.Size=Vector3.new(1,2,1);leg.Parent=p.Character end
 local pack=Instance.new('Backpack');pack.Name='Backpack';p.Backpack=pack;p.ChildAdded=signal();p.AncestryChanged=signal()
 function p:FindFirstChildOfClass(c)if c=='Backpack'then return self.Backpack end end
 function p:FindFirstChild(n)if n=='Backpack'then return self.Backpack elseif n=='PlayerGui'then return pg end end
 function p:AddReplicationFocus(part)self.focus=part end
 function p:RemoveReplicationFocus(part)assert(self.focus==part);self.focus=nil end
 function hum:EquipTool(tool)tool.Parent=p.Character end
 return p
end
function BCSetup()
 BC_PLAYERS={};Services.Players.GetPlayers=function()return BC_PLAYERS end
 local meta=getmetatable(pg);local set=meta.__newindex;local get=meta.__index
 meta.__newindex=function(o,k,v)
  local before=o.props[k];set(o,k,v)
  if k=='Health'and o:IsA('Humanoid')and type(before)=='number'and before>0 and v<=0 and o.Died then o.Died:Fire()end
 end
 meta.__index=function(o,k)
  if k=='IsDescendantOf'then return function(self,ancestor)local p=self.Parent;while p do if p==ancestor then return true end;p=p.Parent end;return false end end
  if k=='Destroy'then return function(self)
   if self.destroyed or self.destroying then return end;self.destroying=true;self.Destroying:Fire()
   for _,child in ipairs(self:GetChildren())do child:Destroy()end;self.Parent=nil;self.destroyed=true;self.destroying=false
  end end
  return get(o,k)
 end
 function workspace:GetPartBoundsInBox(cf,size,params)
  local result={};for _,p in ipairs(self:GetDescendants())do if p:IsA('BasePart')and p.CanQuery~=false then
   local ignored=false;for _,r in ipairs(params.FilterDescendantsInstances or{})do if p==r or p:IsDescendantOf(r)then ignored=true end end
   if not ignored then local v=p.Position-cf.Position
    if math.abs(v.X)<(p.Size.X+size.X)/2 and math.abs(v.Y)<(p.Size.Y+size.Y)/2 and math.abs(v.Z)<(p.Size.Z+size.Z)/2 then result[#result+1]=p end
   end
  end end;return result
 end
 function workspace:Raycast(origin,dir,params)
  if BC_RAY then return BC_RAY(origin,dir,params)end
  local floor=self:FindFirstChild('BC_Arena')and self.BC_Arena:FindFirstChild('BC_Floor')
  if floor and dir.Y<0 then local top=floor.Position.Y+floor.Size.Y/2;local t=(top-origin.Y)/dir.Y;local at=origin+dir*t
   if t>=0 and t<=1 and math.abs(at.X-floor.Position.X)<=floor.Size.X/2 and math.abs(at.Z-floor.Position.Z)<=floor.Size.Z/2 then return{Instance=floor,Position=at,Normal=Vector3.new(0,1,0)}end
  end
  return nil -- floor intersection only; weapon cases provide explicit collision fixtures
 end
end
function BCInstall(name,source)
 local old=script;local mod=Instance.new('ModuleScript');mod.Name=name;mod.Parent=rep;script=mod
 Modules[name]=loadModule(source,name);script=old;return Modules[name]
end
function BCRandom()
 local rng={draw=0,integer=1}
 function rng:NextNumber(a,b)return a+(b-a)*self.draw end
 function rng:NextInteger(a,b)return math.clamp(self.integer,a,b)end
 return rng
end
Services.Debris={AddItem=function(_,object,seconds)task.delay(seconds,function()if object.Parent then object:Destroy()end end)end}
