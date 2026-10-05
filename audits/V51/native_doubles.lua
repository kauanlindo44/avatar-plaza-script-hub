-- V51: native coordinate system and native BodyPartDescription children.
local previousIndex=getmetatable(pg).__index
getmetatable(pg).__index=function(o,k)
 if previousIndex(o,'ClassName')=='ScreenGui'and k=='AbsolutePosition'then
  local left,top=CORE_LEFT or 0,CORE_TOP or 0
  if previousIndex(o,'ScreenInsets')==Enum.ScreenInsets.None then return Vector2.new(-left,-top)end
  if previousIndex(o,'ScreenInsets')==Enum.ScreenInsets.DeviceSafeInsets then return Vector2.new((DEVICE_LEFT or left)-left,(DEVICE_TOP or top)-top)end
  if previousIndex(o,'ScreenInsets')==Enum.ScreenInsets.TopbarSafeInsets then return Vector2.new((TOPBAR_LEFT or 180)-left,(DEVICE_TOP or 0)-top)end
  return Vector2.zero
 end
 if previousIndex(o,'ClassName')=='ScreenGui'and k=='AbsoluteSize'and previousIndex(o,'ScreenInsets')==Enum.ScreenInsets.TopbarSafeInsets then
  return Vector2.new(SCREEN_W-(DEVICE_RIGHT or CORE_RIGHT or 0)-(TOPBAR_LEFT or 180),(CORE_TOP or 0)-(DEVICE_TOP or 0))
 end
 return previousIndex(o,k)
end
function Services.GuiService:GetInsetArea(kind)
 if NoInsetAPI then error('unavailable')end
 local cl,ct=CORE_LEFT or 0,CORE_TOP or 0
 local l,r,t,b=0,0,0,0
 if kind==Enum.ScreenInsets.DeviceSafeInsets then l,r,t,b=DEVICE_LEFT or cl,DEVICE_RIGHT or CORE_RIGHT or 0,DEVICE_TOP or 0,DEVICE_BOTTOM or CORE_BOTTOM or 0
 elseif kind==Enum.ScreenInsets.CoreUISafeInsets then l,r,t,b=cl,CORE_RIGHT or 0,ct,CORE_BOTTOM or 0
 elseif kind==Enum.ScreenInsets.TopbarSafeInsets then l,r,t,b=TOPBAR_LEFT or 180,DEVICE_RIGHT or CORE_RIGHT or 0,DEVICE_TOP or 0,SCREEN_H-ct end
 return{Min=Vector2.new(l-cl,t-ct),Max=Vector2.new(SCREEN_W-r-cl,SCREEN_H-b-ct)}
end
local ctor=Instance.new
Instance.new=function(class)
 local o=ctor(class)
 if class=='BodyPartDescription'then
  o.AssetId=0;o.BodyPart=Enum.BodyPart.Head;o.HeadShape='';o.Color=Color3.new(.6,.5,.4)
  function o:Clone()local p=Instance.new(class);p.AssetId=self.AssetId;p.BodyPart=self.BodyPart;p.HeadShape=self.HeadShape;p.Color=self.Color;p.Instance=self.Instance;return p end
 end
 if class=='HumanoidDescription'then
  local old=o.Clone
  function o:Clone()
   local n=old(self)
   for _,p in ipairs(self:GetChildren())do if p:IsA('BodyPartDescription')then p:Clone().Parent=n end end
   return n
  end
 end
 return o
end
function bodyChild(d,k,id,shape)
 d[k]=id;local p=Instance.new('BodyPartDescription');p.AssetId=id;p.BodyPart=Enum.BodyPart[k];p.Color=d[k..'Color'];p.HeadShape=shape or '';p.Parent=d;return p
end
