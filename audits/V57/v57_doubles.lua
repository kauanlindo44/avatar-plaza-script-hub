-- Test-only native classification correction and rigid geometry; no real Roblox loading.
Services.ServerStorage=Instance.new('ServerStorage')
local physical57=physical
function physical(model,description)
 physical57(model,description)
 if not CorrectNativeHair then return end
 local h=model.Humanoid;local applied=h:FindFirstChildOfClass('HumanoidDescription')
 local entries=h.applied:GetAccessories(true)
 for _,v in ipairs(entries)do if v.AccessoryType.Name=='Hair'then
  v.IsLayered=false
  for _,a in ipairs(model:GetChildren())do if a:IsA('Accessory')and a.AccessoryType.Name=='Hair'then a:Destroy()end end
  for _,d in ipairs(applied:GetChildren())do if d:IsA('AccessoryDescription')and d.AssetId==v.AssetId then d:Destroy()end end
  local a=Instance.new('Accessory');a.AccessoryType=v.AccessoryType;a.Name='RigidHairFixture';a.Parent=model
  local handle=Instance.new('Part');handle.Name='Handle';handle.Transparency=0;handle.Parent=a
  local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId='rbxassetid://fixture-rigid-hair';mesh.Parent=handle
  local d=Instance.new('AccessoryDescription');d.AssetId=v.AssetId;d.AccessoryType=v.AccessoryType;d.IsLayered=false;d.Parent=applied
  function d:GetAppliedInstance()return a end
 end end
 h.applied:SetAccessories(entries,true)
end
