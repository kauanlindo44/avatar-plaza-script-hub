-- 01D_HUB_FASHION_TOP
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - limpeza de estruturas antigas no mundo principal.

local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
local world=workspace:WaitForChild("PracaAvatar_V2",20)
if world then
 for _,name in ipairs({
  "FashionDistrict","AvatarWorldPolish","PlazaEventStatus",
  "StylePlaza","LookLab","RunwayDistrict","GameCafe"
 })do
  local old=world:FindFirstChild(name,true)
  if old then old:Destroy()end
 end
end
kit:SetAttribute("FashionReady",false)
print("AVATAR PLAZA V38.1: estruturas antigas removidas")
