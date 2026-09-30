-- 07X_SOCIAL_TAGS
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V36D - tags de troféu/sequência removidas.

local Players=game:GetService("Players")
local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")

pg:SetAttribute("ACP_ShowMyStats",false)
pg:SetAttribute("ACP_ShowOtherStats",false)

local function clearCharacter(char)
 if not char then return end
 for _,obj in ipairs(char:GetDescendants())do
  if obj.Name=="ACP_StatsTag"then obj:Destroy()end
 end
end

local function watch(p)
 if p.Character then clearCharacter(p.Character)end
 p.CharacterAdded:Connect(function(char)
  task.wait(.2)
  clearCharacter(char)
 end)
end

for _,p in ipairs(Players:GetPlayers())do watch(p)end
Players.PlayerAdded:Connect(watch)

print("AVATAR PLAZA V36D: troféu/fogo acima da cabeça removidos")
