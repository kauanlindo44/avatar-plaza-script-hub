-- 09C21_EDITOR_CONNECTION | ModuleScript | ReplicatedStorage | V78 (CRIAR)
-- Fila limitada, descoberta dinâmica do servidor e contratos por funções públicas.
local M={Version='V78'}
function M.Compatible(value,methods)
 if type(value)~='table'then return false end
 for _,name in ipairs(methods)do if type(value[name])~='function'then return false end end
 return true
end
function M.New(rep,folderName)
 local L={};local nextTicket,serving,queued=0,1,0
 function L.Call(action,args)
  if queued>=6 then return nil,'Há ações aguardando. Espere a operação atual terminar.'end
  nextTicket=nextTicket+1;local mine=nextTicket;queued=queued+1
  while mine~=serving do task.wait(.03)end
  local function done(value,errorText)queued=queued-1;serving=serving+1;return value,errorText end
  local folder=rep:FindFirstChild(folderName);local rpc=folder and folder:FindFirstChild('Request')
  if not rpc or not rpc:IsA('RemoteFunction')then return done(nil,'O editor ainda está conectando ao servidor.')end
  local bootError=folder:GetAttribute('BootError');if bootError then return done(nil,tostring(bootError))end
  local finished,ok,response=false
  task.spawn(function()ok,response=pcall(function()return rpc:InvokeServer(action,args or{})end);finished=true end)
  local deadline=os.clock()+14;while not finished and os.clock()<deadline do task.wait(.05)end
  if not finished then return done(nil,'Operação ainda não confirmada. Confira o resultado antes de repetir; use Recarregar para consultar.')end
  if not ok or type(response)~='table'then return done(nil,'O servidor não respondeu. Tente novamente em instantes.')end
  if response.ok then return done(response.data)end
  return done(nil,response.error)
 end
 return L
end
return M
