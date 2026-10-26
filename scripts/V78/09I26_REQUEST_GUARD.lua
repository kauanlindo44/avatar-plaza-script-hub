-- 09I26_REQUEST_GUARD | ModuleScript | ServerScriptService | V78 (SUBSTITUIR)
-- Limites globais por jogador, payload finito e bloqueio de chamadas concorrentes.
local M={Version='V78',Protocol=1}
-- New é uma fábrica pública: cliente/servidor conferem funções, nunca o rótulo da versão.
function M.Validate(value)
 local nodes,bytes=0,0;local seen={}
 local function visit(v,depth)
  nodes=nodes+1;if nodes>1024 or depth>8 then return false end
  local kind=type(v)
  if kind=='nil'or kind=='boolean'then return true end
  if kind=='number'then return v==v and v~=math.huge and v~=-math.huge and math.abs(v)<=9007199254740991 end
  if kind=='string'then bytes=bytes+#v;return #v<=8192 and bytes<=32768 and utf8.len(v)~=nil end
  if kind~='table'or getmetatable(v)~=nil or seen[v]then return false end
  seen[v]=true;local count=0
  for k,x in pairs(v)do
   count=count+1;if count>128 then return false end
   if type(k)=='string'then if #k>80 or not visit(k,depth+1)then return false end
   elseif type(k)~='number'or k%1~=0 or k<1 or k>1024 then return false end
   if not visit(x,depth+1)then return false end
  end
  seen[v]=nil;return true
 end
 return visit(value,0)
end
function M.New()
 local players={};local total=0;local G={}
 local writes={prompt=5,invite=1,accept=1,decline=1,revoke=1,leave=1,pref=.5,delete=.5,save=.8,copyshared=1,['chat.share']=2,
  HighlightSubmit=2,HighlightWithdraw=2,HighlightPurchase=2,DestinationSubmit=2,DestinationWithdraw=2,DestinationPlay=2,CartPurchase=2}
 function G.Check(pl,action,args)
  if not pl or not pl.Parent or type(action)~='string'or #action>64 then return false,'Pedido inválido.'end
  local now=os.clock();local s=players[pl]
  if not s then s={tokens=12,at=now,active=0,last={}};players[pl]=s end
  s.tokens=math.min(12,s.tokens+math.max(0,now-s.at)*4);s.at=now
  -- Cancelar continua possível mesmo depois de esgotar o lote de chamadas comuns.
  local cancel=action=='cancel'or action=='newchat'
  if cancel then
   if now-(s.cancelAt or-10)<.25 then return false,'Aguarde um instante.'end;s.cancelAt=now
  else
   if s.tokens<1 then return false,'Muitas ações. Aguarde um instante.'end;s.tokens=s.tokens-1
  end
  if not M.Validate(args)then return false,'Dados inválidos ou maiores que o permitido.'end
  local cooldown=writes[action]or .20
  if s.last[action]and now-s.last[action]<cooldown then return false,'Aguarde antes de repetir esta ação.'end
  if not cancel and(s.active>=3 or total>=24)then return false,'O serviço está ocupado. Tente em instantes.'end
  s.last[action]=now;return true
 end
 function G.Enter(pl)
  local s=players[pl];if not s then return nil end
  s.active=s.active+1;total=total+1;local released=false
  return function()if released then return end;released=true;s.active=math.max(0,s.active-1);total=math.max(0,total-1)end
 end
 function G.Forget(pl)players[pl]=nil end
 return G
end
return M
