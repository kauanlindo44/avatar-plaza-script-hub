-- 09I25_PLAN_PRODUCTS | ModuleScript | ReplicatedStorage | V76 (SUBSTITUIR)
-- Preço oficial; servidor confirma vínculo dos IDs Plus/Pro com esta experiência.
local Market=game:GetService('MarketplaceService');local Rep=game:GetService('ReplicatedStorage')
local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local M={Version='V76'};local cache={};local checking={};local membership
local function allowed(id)return Config.ProductPlans[id]~=nil end
local function price(info)
 local p=type(info)=='table'and tonumber(info.PriceInRobux)or nil
 return p and p==p and p>=1 and p<1e9 and p%1==0 and p or nil
end
function M.Inspect(info,belongs)
 if type(info)~='table'then return false,'RESPOSTA_INVALIDA'end
 if info.IsForSale==false then return false,'FORA_DE_VENDA'end
 if not price(info)then return false,'PRECO_NAO_CONFIRMADO'end
 if info.IsForSale==true or belongs==true then return true,'OK'end
 return false,'VENDA_NAO_CONFIRMADA'
end
local messages={ID_INVALIDO='ID do produto inválido.',ID_NAO_AUTORIZADO='Escolha um plano Plus ou Pro configurado.',
 FORA_DE_VENDA='O Roblox informou que o produto está fora de venda.',PRECO_NAO_CONFIRMADO='O Roblox não forneceu um preço válido.',
 VENDA_NAO_CONFIRMADA='O Roblox não confirmou a venda.',PRODUTO_DE_OUTRA_EXPERIENCIA='Esse ID não pertence aos Developer Products desta experiência.',
 CONSULTA_ROBLOX_FALHOU='A consulta ao Roblox falhou. Recarregue os preços.',RESPOSTA_INVALIDA='O Roblox devolveu uma resposta incompleta.',
 LISTA_INCOMPLETA='O Roblox não concluiu a lista de produtos. Tente novamente.',CONSULTA_EM_ANDAMENTO='Uma consulta dos planos já está em andamento.'}
local function result(id,stage,info,method)
 local ready=stage=='OK'
 return{ready=ready,id=id,price=ready and price(info)or nil,stage=stage,method=method or'GetProductInfoAsync',message=ready and'Confira o valor final no prompt oficial.'or messages[stage]or'Não foi possível confirmar o plano.'}
end
local function products(force)
 if membership and not force and os.clock()-membership.at<30 then return membership end
 local rows={};local finished=false
 local ok,e=pcall(function()
  local pages=Market:GetDeveloperProductsAsync()
  for _=1,16 do
   for _,row in ipairs(pages:GetCurrentPage())do
    for _,key in ipairs({'DeveloperProductId','TargetId','ProductId','Id'})do local id=tonumber(row[key]);if id and allowed(id)then rows[id]=row end end
   end
   if pages.IsFinished then finished=true;break end;pages:AdvanceToNextPageAsync()
  end
 end)
 local value={rows=rows,at=os.clock(),stage=ok and(finished and'OK'or'LISTA_INCOMPLETA')or'CONSULTA_ROBLOX_FALHOU'}
 if ok and finished then membership=value end
 if not ok then warn('[Planos V76] LIST '..tostring(e))end
 return value
end
function M.Check(id,force)
 id=tonumber(id)
 if not id or id~=id or id<=0 or id%1~=0 then return result(id,'ID_INVALIDO')end
 if not allowed(id)then return result(id,'ID_NAO_AUTORIZADO')end
 local old=cache[id];if old and not force and os.clock()-old.at<60 then return old.data end
 if checking[id]then return old and old.data or result(id,'CONSULTA_EM_ANDAMENTO')end
 checking[id]=true
 local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Product)end)
 local ready,stage=M.Inspect(ok and info or nil,false);local method='GetProductInfoAsync'
 if not ready and stage~='FORA_DE_VENDA'then
  local list=products(force);local row=list.rows[id]
  if row then
   if row.IsForSale==false then info=row;stage='FORA_DE_VENDA'
   else info=ok and price(info)and info or row;ready,stage=M.Inspect(info,true);method='GetDeveloperProductsAsync + produto desta experiência'end
  else stage=list.stage=='OK'and'PRODUTO_DE_OUTRA_EXPERIENCIA'or list.stage end
 end
 local value=result(id,stage,info,method);cache[id]={at=os.clock(),data=value};checking[id]=nil
 return value
end
function M.CheckForPurchase(id)
 local value=M.Check(id,false);if not value.ready then return value end
 local list=products();local row=list.rows[value.id]
 if not row then return result(value.id,list.stage=='OK'and'PRODUTO_DE_OUTRA_EXPERIENCIA'or list.stage)end
 if row.IsForSale==false then return result(value.id,'FORA_DE_VENDA')end
 local out={};for k,v in pairs(value)do out[k]=v end;out.experienceVerified=true;return out
end
return M
