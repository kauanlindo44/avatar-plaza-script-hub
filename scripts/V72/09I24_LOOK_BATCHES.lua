-- 09I24_LOOK_BATCHES | ModuleScript | ServerScriptService | V72 (NOVO)
-- Retém até 50 resultados por jogador; quantidade total é processada por lotes canceláveis.
local Http=game:GetService('HttpService');local M={};local stores={}
function M.Add(pl,looks,reset)
 local st=not reset and stores[pl]or nil;if not st then st={rows={},order={}};stores[pl]=st end
 for _,row in ipairs(looks)do row.key=Http:GenerateGUID(false);st.rows[row.key]=row;st.order[#st.order+1]=row.key end
 while #st.order>50 do local key=table.remove(st.order,1);st.rows[key]=nil end
end
function M.Find(pl,key)local s=stores[pl];return s and type(key)=='string'and s.rows[key]or nil end
function M.Clear(pl)stores[pl]=nil end
return M
