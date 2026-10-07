-- Explicit structural asset double; cannot model cages, textures or actual rendering.
local make=Services.Players.CreateHumanoidModelFromDescriptionAsync
function physical(model,description)
 for _,o in ipairs(model:GetChildren())do if o:IsA('Accessory')then o:Destroy()end end
 for _,v in ipairs(description:GetAccessories(true))do
  if not MissingPhysical and(v.IsLayered==true or v.AccessoryType==Enum.AccessoryType.Shirt)then
   local a=Instance.new('Accessory');a.AccessoryType=v.AccessoryType;a.Parent=model
   local p=Instance.new('Part');p.Name='Handle';p.Parent=a;local w=Instance.new('WrapLayer');w.Enabled=not DisabledWrap;w.Parent=p
  end
 end
end
function Services.Players:CreateHumanoidModelFromDescriptionAsync(d,rig,verification)
 local model=make(self,d,rig,verification);physical(model,d)
 local h=model.Humanoid;local reset=h.ApplyDescriptionResetAsync
 function h:ApplyDescriptionResetAsync(desc,v)reset(self,desc,v);physical(model,desc)end
 return model
end
