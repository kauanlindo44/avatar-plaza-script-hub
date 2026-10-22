-- BC_Queue | ModuleScript | ServerScriptService | V74 (CRIAR)
-- Fila FIFO; a nona pessoa espera a rodada seguinte. Não há inscrição automática.
local M={}
function M.New()
 local Q={players={},members={}}
 function Q.Add(pl)if Q.members[pl]then return false end;Q.members[pl]=true;Q.players[#Q.players+1]=pl;return true end
 function Q.Remove(pl)
  Q.members[pl]=nil;for i=#Q.players,1,-1 do if Q.players[i]==pl then table.remove(Q.players,i)end end
 end
 function Q.Count()return #Q.players end
 function Q.Position(pl)for i,p in ipairs(Q.players)do if p==pl then return i end end;return 0 end
 function Q.Take(limit,valid)
  local result={}
  while #Q.players>0 and #result<limit do
   local pl=table.remove(Q.players,1);Q.members[pl]=nil
   if not valid or valid(pl)then result[#result+1]=pl end
  end
  return result
 end
 return Q
end
return M
