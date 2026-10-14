-- 07K4_TRUCO_TABLES | ModuleScript | ServerScriptService | V63 (SUBSTITUIR)
-- Salas virtuais: a mesa é desenhada em 2D, sem assentos ou teleporte físico.
local T={Version='V63',Protocol=2};local tables={}
function T.Build(world)
 local old=world:FindFirstChild('TrucoVirtualRooms');if old then old:Destroy()end
 local root=Instance.new('Folder');root.Name='TrucoVirtualRooms';root.Parent=world;tables={}
 for n=1,24 do local room=Instance.new('Folder');room.Name='Truco_'..n;room:SetAttribute('GameType','Truco');room.Parent=root;tables[n]=room end
 return tables
end
function T.FindFree()for _,room in ipairs(tables)do if not room:GetAttribute('ACP_TrucoRoom')then return room end end end
function T.Seat(room,pl,seat)
 if not pl.Parent or room.closing or room.players[seat]~=pl then return false end
 pl:SetAttribute('ACP_TrucoSeat',seat);return true
end
function T.Release(room,pl)
 if pl:GetAttribute('ACP_GameType')=='Truco'then pl:SetAttribute('ACP_InGameRoom',nil);pl:SetAttribute('ACP_GameType',nil)end
 pl:SetAttribute('ACP_TrucoRoom',nil);pl:SetAttribute('ACP_TrucoSeat',nil);pl:SetAttribute('ACP_Competitive',nil)
end
return T
