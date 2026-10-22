-- BC_EffectRegistry | ModuleScript | ServerScriptService | V74 (CRIAR)
local C=require(game:GetService('ReplicatedStorage'):WaitForChild('BC_Config'))
local M={}
function M.Eligible(round,actor)
 local enemies=0;for pl,s in pairs(round.players)do if pl~=actor and s.alive then enemies=enemies+1 end end
 local list,total={},0
 for _,e in ipairs(C.Effects)do
  if e.id~=round.lastEffect and(not e.target or enemies>0)and(not e.nuclear or not round.nuclearUsed)then list[#list+1]=e;total=total+e.weight end
 end
 return list,total
end
function M.Draw(round,actor,random)
 local list,total=M.Eligible(round,actor);if total<=0 then return nil end
 local pick=random:NextNumber(0,total);local sum=0
 for _,e in ipairs(list)do sum=sum+e.weight;if pick<sum then return e end end
 return list[#list]
end
return M
