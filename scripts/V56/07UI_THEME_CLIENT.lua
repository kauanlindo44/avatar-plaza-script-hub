-- 07UI_THEME_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V56 (NOVO)
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage')
local pg=Players.LocalPlayer:WaitForChild('PlayerGui')
require(Rep:WaitForChild('07UI_HALLOWEEN_THEME')).Start(pg)
