-- 08B3_AVATAR_VERIFY | ModuleScript | ReplicatedStorage | V52 (NOVO)
-- A descrição pode conter um ID mesmo quando o acessório físico não carregou.
local M={}
function M.Check(model,body,rig)
 local hum=model and model:FindFirstChildOfClass("Humanoid")
 if not hum or not model:FindFirstChild("HumanoidRootPart")then return false,"O Roblox retornou um avatar incompleto."end
 local expected={};local layered=false
 for _,v in ipairs(body.accessories or{})do if v.layer then layered=true;expected[v.type]=(expected[v.type]or 0)+1 end end
 if not layered then return true end
 if hum.RigType~=Enum.HumanoidRigType.R15 then return false,"Esse visual 3D precisa do corpo R15."end
 local got={}
 for _,v in ipairs(model:GetChildren())do if v:IsA("Accessory")then
  local kind=v.AccessoryType.Name;local handle=v:FindFirstChild("Handle")
  local wrap=handle and handle:FindFirstChildOfClass("WrapLayer")
  if handle and handle:IsA("BasePart")and wrap and wrap.Enabled then got[kind]=(got[kind]or 0)+1 end
 end end
 for kind,n in pairs(expected)do if(got[kind]or 0)<n then
  return false,"A roupa 3D não carregou no Roblox. Confira Layered Clothing em Avatar Settings e tente novamente."
 end end
 return true
end
return M
