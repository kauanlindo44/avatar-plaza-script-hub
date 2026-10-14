-- 09B11_DATA_BUDGET | ModuleScript | ServerScriptService | V64 (NOVO)
-- Reserva orçamento para dados pessoais; nenhuma fila cega de pedidos de fundo.
local DS=game:GetService('DataStoreService');local M={Version='V64'};local retry={}
local names={Read={'StandardRead','GetAsync'},Write={'StandardWrite','SetIncrementAsync'},List={'OrderedList','GetSortedAsync'},OrderedWrite={'OrderedWrite','SetIncrementSortedAsync'}}
function M.Can(kind,background)
 if os.clock()<(retry[kind]or 0)then return false end
 local known=false
 for _,name in ipairs(names[kind]or{})do
  local ok,n=pcall(function()return DS:GetRequestBudgetForRequestType(Enum.DataStoreRequestType[name])end)
  if ok and type(n)=='number'then known=true;return n>=(background and(kind=='List'and 2 or 8)or 1)end
 end
 return not known and false
end
function M.Run(kind,background,fn)
 if not M.Can(kind,background)then return false,nil,'Armazenamento ocupado; tente novamente em instantes.'end
 if kind=='Write'and not M.Can('Read',background)then return false,nil,'Leitura ocupada; tente novamente em instantes.'end
 local ok,value=pcall(fn)
 if not ok then retry[kind]=os.clock()+15;warn('[Data V64] '..kind..' '..tostring(value));return false,nil,'O armazenamento não confirmou a operação.'end
 return true,value
end
return M
