-- AccessoryDescription children and refinement vectors are part of the upgraded API.
local new68=Instance.new
function Instance.new(class,parent)
 local o=new68(class,parent)
 if class=='AccessoryDescription'then o.Position=Vector3.zero;o.Rotation=Vector3.zero;o.Scale=Vector3.new(1,1,1)end
 if class=='HumanoidDescription'then
  local set=o.SetAccessories
  function o:SetAccessories(rows,includeRigid)
   set(self,rows,includeRigid)
   for _,c in ipairs(self:GetChildren())do if c:IsA('AccessoryDescription')then c:Destroy()end end
   for _,r in ipairs(rows)do local d=Instance.new('AccessoryDescription');d.AssetId=r.AssetId;d.AccessoryType=r.AccessoryType;d.IsLayered=r.IsLayered;d.Order=r.Order or 0;d.Parent=self end
  end
 end
 return o
end
RefinementRules68={AccessoryRefinementLowerBounds={},AccessoryRefinementUpperBounds={}}
for _,kind in ipairs({'Hat','HairAccessory','FaceAccessory','NeckAccessory','ShoulderAccessory','FrontAccessory','BackAccessory'})do
 local lo,hi={},{ }
 for _,f in ipairs({'Position','Rotation','Scale'})do lo[f]={};hi[f]={};for _,a in ipairs({'X','Y','Z'})do lo[f][a..f]=f=='Position'and -.25 or f=='Rotation'and -30 or .8;hi[f][a..f]=f=='Position'and .25 or f=='Rotation'and 30 or 1.2 end end
 RefinementRules68.AccessoryRefinementLowerBounds[kind]=lo;RefinementRules68.AccessoryRefinementUpperBounds[kind]=hi
end
function Services.AvatarEditorService:GetAvatarRulesAsync()if RulesDenied68 then error('rules unavailable')end;return deep(RefinementRules68)end
-- Native player camera properties have numeric defaults.
pl.CameraMinZoomDistance=.5;pl.CameraMaxZoomDistance=50
local type68=Services.AvatarEditorService.GetAccessoryType
function Services.AvatarEditorService:GetAccessoryType(asset)
 local extra={TShirtAccessory='TShirt',JacketAccessory='Jacket',SweaterAccessory='Sweater',ShortsAccessory='Shorts',DressSkirtAccessory='DressSkirt',NeckAccessory='Neck',FrontAccessory='Front',ShoulderAccessory='Shoulder',WaistAccessory='Waist'}
 if extra[asset.Name]then return Enum.AccessoryType[extra[asset.Name]]end;return type68(self,asset)
end
local cloneNew68=Instance.new
function Instance.new(class,parent)
 local o=cloneNew68(class,parent)
 if class=='HumanoidDescription'then local original=o.Clone
  function o:Clone()
   local n=original(self);n:SetAccessories(self:GetAccessories(true),true)
   for _,child in ipairs(self:GetChildren())do if child:IsA('AccessoryDescription')then for _,copy in ipairs(n:GetChildren())do if copy:IsA('AccessoryDescription')and copy.AssetId==child.AssetId then for _,key in ipairs({'Position','Rotation','Scale'})do copy[key]=child[key]end end end end end
   return n
  end
 end;return o
end
