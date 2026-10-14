-- 09C11_SPONSOR_FEED | ModuleScript | ReplicatedStorage | V63 (NOVO)
-- Um envio ocupa um card; os outros exemplos permanecem. Sem duplicações.
local M={Version='V63'}
function M.Merge(real,examples,limit)
 local out,seen={},{};limit=math.clamp(tonumber(limit)or 60,1,120)
 local function add(row)
  if type(row)=='table'and row.key and row.item and not seen[row.key]and #out<limit then seen[row.key]=true;out[#out+1]=row end
 end
 for _,row in ipairs(real or{})do add(row)end
 for _,row in ipairs(examples or{})do add(row)end
 return out
end
return M
