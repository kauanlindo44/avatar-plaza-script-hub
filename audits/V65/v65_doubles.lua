-- Only contract/control-flow doubles. No physics solver, meshes, audio permissions or rendering.
RaycastParams={new=function()return{}end}
function workspace:Raycast(origin,direction,params)
 Raycasts65=Raycasts65 or{};Raycasts65[#Raycasts65+1]={origin=origin,direction=direction,params=params}
 if NoFloor65 then return nil end
 return{Position=Vector3.new(origin.X,Floor65 or 0,origin.Z),Normal=Vector3.new(0,1,0)}
end
Services.UserInputService.InputEnded=Services.UserInputService.InputEnded or Signal()
local ctor65=Instance.new
function track65(id)
 local t={AnimationId=id,IsPlaying=false,Length=EmoteZeroLength65 and 0 or 3,Stopped=Signal()}
 function t:Play()self.IsPlaying=true end
 function t:Stop()local playing=self.IsPlaying;self.IsPlaying=false;if playing then self.Stopped:Fire()end end
 function t:AdjustSpeed(v)self.speed=v end
 function t:Destroy()self.destroyed=true end
 return t
end
Instance.new=function(class)
 local o=ctor65(class)
 if class=='AnimationConstraint'then o.Transform=CFrame.new();o.IsKinematic=true end
 if class=='Humanoid'then
  o.HipHeight=2;o.AutoRotate=true;o.PlatformStand=false;o.Sit=false
  function o:PlayEmoteAsync(name)
   if RejectEmote65 then return false end
   if HangEmote65 then advance60(20);return true end
   local a=self:FindFirstChildOfClass('Animator');local t=track65(name);t:Play();a.playing[#a.playing+1]=t;a.AnimationPlayed:Fire(t);return true
  end
 end
 if class=='Animator'then
  o.AnimationPlayed=Signal();o.playing={};o.loaded={}
  function o:LoadAnimation(animation)local t=track65(animation.AnimationId);self.loaded[#self.loaded+1]=t;return t end
  function o:GetPlayingAnimationTracks()local rows={};for _,t in ipairs(self.playing)do if t.IsPlaying then rows[#rows+1]=t end end;for _,t in ipairs(self.loaded)do if t.IsPlaying then rows[#rows+1]=t end end;return rows end
 end
 if class=='Model'then
  local pivot=o.GetPivot
  function o:GetPivot()return self.PrimaryPart and self.PrimaryPart.CFrame or pivot(self)end
  function o:PivotTo(cf)
   local before=self:GetPivot();local delta=cf*before:Inverse()
   for _,v in ipairs(self:GetDescendants())do if v:IsA('BasePart')then v.CFrame=delta*v.CFrame end end
   self.pivot=cf;self.WorldPivot=cf
  end
  o.scale=1
  function o:GetScale()return self.scale end
  function o:ScaleTo(value)self.scale=value;self.scaleCalls=(self.scaleCalls or 0)+1 end
 end
 return o
end
-- The older model factory installs an empty per-instance PlayEmote stub; replace it
-- with a controllable native-signal contract for these focused controller tests.
local make65=Services.Players.CreateHumanoidModelFromDescriptionAsync
local function play65(self,name)
 if RejectEmote65 then return false end
 if HangEmote65 then advance60(20);return true end
 local a=self:FindFirstChildOfClass('Animator');local t=track65(name);t:Play();a.playing[#a.playing+1]=t;a.AnimationPlayed:Fire(t);return true
end
function Services.Players:CreateHumanoidModelFromDescriptionAsync(...)
 local model=make65(self,...);model.Humanoid.PlayEmoteAsync=play65;return model
end
local v2meta65={}
v2meta65.__index=function(v,k)if k=='Magnitude'then return math.sqrt(v.X*v.X+v.Y*v.Y)end end
v2meta65.__add=function(a,b)return Vector2.new(a.X+b.X,a.Y+b.Y)end
v2meta65.__sub=function(a,b)return Vector2.new(a.X-b.X,a.Y-b.Y)end
Vector2.new=function(x,y)return setmetatable({X=x or 0,Y=y or 0},v2meta65)end
Vector2.zero=Vector2.new()
