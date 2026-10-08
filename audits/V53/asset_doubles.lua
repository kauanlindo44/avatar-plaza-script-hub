-- Explicit test doubles: these IDs never load actual Roblox meshes or textures.
local priorIsA=methods.IsA
function methods:IsA(class)
 if class=='BasePart'and self.ClassName=='MeshPart'then return true end
 return priorIsA(self,class)
end
function task.wait(seconds)
 TEST_TIME=TEST_TIME+(seconds or .04)
 local q=table.remove(task.queue,1);if q then q.fn(table.unpack(q.args))end
end
Services.ContentProvider={}
function Services.ContentProvider:PreloadAsync(assets,callback)
 PreloadCount=(PreloadCount or 0)+1
 for _,o in ipairs(assets)do callback(o.MeshId or 'fixture',Enum.AssetFetchStatus[FailVisual and 'Failure'or'Success'])end
end
Services.StarterPlayer.LoadCharacterLayeredClothing=Enum.LoadCharacterLayeredClothing.Enabled
local oldPhysical=physical
function physical(model,description)
 oldPhysical(model,description)
 for _,p in ipairs(model:GetChildren())do
  if p:IsA('BasePart')and p.Name~='HumanoidRootPart'then
   p.ClassName='MeshPart';p.MeshId='rbxassetid://fixture-body';p.Transparency=0
   local old=p:FindFirstChildOfClass('WrapTarget');if old then old:Destroy()end
   if not MissingCage then local w=Instance.new('WrapTarget');w.Parent=p end
  end
 end
 local hum=model:FindFirstChildOfClass('Humanoid');local previous=hum:FindFirstChildOfClass('HumanoidDescription');if previous then previous:Destroy()end
 local applied=description:Clone();applied.Parent=hum
 local used={}
 for _,a in ipairs(model:GetChildren())do if a:IsA('Accessory')then
  local h=a.Handle;h.ClassName='MeshPart';h.MeshId=EmptyMesh and ''or'rbxassetid://fixture-shirt';h.Transparency=0
  for _,entry in ipairs(description:GetAccessories(true))do if not used[entry.AssetId]and entry.IsLayered and entry.AccessoryType.Name==a.AccessoryType.Name then
   local p=Instance.new('AccessoryDescription');p.AssetId=entry.AssetId;p.IsLayered=true;p.AccessoryType=entry.AccessoryType;p.Parent=applied
   used[entry.AssetId]=true;function p:GetAppliedInstance()if WrongPhysicalID then return nil end;return a end
   break
  end end
 end end
end
