-- 08B3_AVATAR_VERIFY | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Malha, WrapLayer ativo, corpo com WrapTarget e acessórios específicos.
local M={VERSION='V56'}
local function usable(accessory,model)
 if not accessory or accessory.Parent~=model or not accessory:IsA('Accessory')then return false end
 local handle=accessory:FindFirstChild('Handle')
 local layer=handle and handle:FindFirstChildOfClass('WrapLayer')
 if not handle or not handle:IsA('MeshPart')or handle.Transparency>=1 or not layer or not layer.Enabled then return false end
 local ok,mesh=pcall(function()return handle.MeshId end)
 return ok and type(mesh)=='string'and mesh~=''
end
function M.Check(model,body,rig)
 local hum=model and model:FindFirstChildOfClass("Humanoid")
 if not hum or not model:FindFirstChild("HumanoidRootPart")then return false,"O Roblox retornou um avatar incompleto."end
 local expected={};local types={}
 for _,v in ipairs(body.accessories or{})do if v.layer then expected[v.id]=v;types[v.type]=(types[v.type]or 0)+1 end end
 if not next(expected)then return true end
 if hum.RigType.Name~='R15'then return false,"Esse visual 3D precisa do corpo R15."end
 local target=false
 for _,v in ipairs(model:GetChildren())do if v:IsA('MeshPart')and v:FindFirstChildOfClass('WrapTarget')then target=true;break end end
 if not target then return false,'Corpo sem WrapTarget para encaixar roupas 3D.','Nenhuma parte MeshPart contém WrapTarget'end
 local got={}
 for _,v in ipairs(model:GetChildren())do if usable(v,model)then local kind=v.AccessoryType.Name;got[kind]=(got[kind]or 0)+1 end end
 for kind,n in pairs(types)do if(got[kind]or 0)<n then
  return false,'Roupa 3D '..kind..': esperado '..n..', encontrado '..(got[kind]or 0)..'.','WrapLayer ativo, Handle MeshPart e malha visível exigidos'
 end end
 local desc=hum:FindFirstChildOfClass('HumanoidDescription')
 if desc then for _,v in ipairs(desc:GetChildren())do if v:IsA('AccessoryDescription')and expected[v.AssetId]then
  local ok,instance=pcall(function()return v:GetAppliedInstance()end)
  if not ok then return false,'GetAppliedInstance do item '..v.AssetId..': '..tostring(instance),'Erro nativo em AccessoryDescription.GetAppliedInstance'end
  if not instance then return false,'O item '..v.AssetId..' ainda não possui instância aplicada.','GetAppliedInstance retornou nil; aguardando a instância exata'end
  if instance and not usable(instance,model)then
   local handle=instance:FindFirstChild('Handle');local layer=handle and handle:FindFirstChildOfClass('WrapLayer')
   return false,'Roupa 3D # '..v.AssetId..' sem estrutura utilizável.','Handle='..tostring(handle and handle.ClassName)..'; WrapLayer='..tostring(layer~=nil)..'; Enabled='..tostring(layer and layer.Enabled)
  end
  -- Load.Check aguarda a replicação; não confirma outro acessório apenas por ter o mesmo tipo.
 end end end
 return true
end
return M
