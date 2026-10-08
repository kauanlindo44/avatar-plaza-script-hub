-- 08B3_AVATAR_VERIFY | ModuleScript | ReplicatedStorage | V53 (SUBSTITUIR)
-- Malha, WrapLayer ativo, corpo com WrapTarget e acessórios específicos.
local M={VERSION='V53'}
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
 if not target then return false,'O corpo carregou sem o encaixe necessário para roupas 3D. Tente novamente.'end
 local got={}
 for _,v in ipairs(model:GetChildren())do if usable(v,model)then local kind=v.AccessoryType.Name;got[kind]=(got[kind]or 0)+1 end end
 for kind,n in pairs(types)do if(got[kind]or 0)<n then
  return false,'A roupa 3D '..kind..' não carregou por completo. Tente novamente.'
 end end
 local desc=hum:FindFirstChildOfClass('HumanoidDescription')
 if desc then for _,v in ipairs(desc:GetChildren())do if v:IsA('AccessoryDescription')and expected[v.AssetId]then
  local ok,instance=pcall(function()return v:GetAppliedInstance()end)
  if ok and not usable(instance,model)then return false,'A roupa 3D # '..v.AssetId..' não apareceu no avatar. Tente novamente.'end
 end end end
 return true
end
return M
