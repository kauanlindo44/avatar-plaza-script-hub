-- 09I25_PLAN_PRODUCTS | ModuleScript | ReplicatedStorage | V74 (CRIAR)
-- Consulta oficial, preço real e diagnóstico por etapa. Não concede benefícios.
local Market=game:GetService('MarketplaceService');local M={};local cache={}
local function price(info)
 local p=type(info)=='table'and tonumber(info.PriceInRobux)or nil
 return p and p==p and p>=1 and p<1e9 and p or nil
end
function M.Inspect(info,belongs)
 if type(info)~='table'then return false,'RESPOSTA_INVALIDA'end
 if info.IsForSale==false then return false,'FORA_DE_VENDA'end
 if not price(info)then return false,'PRECO_NAO_CONFIRMADO'end
 if info.IsForSale==true or belongs==true then return true,'OK'end
 return false,'VENDA_NAO_CONFIRMADA'
end
function M.Check(id,force)
 id=tonumber(id);if not id or id<=0 or id%1~=0 then return{ready=false,stage='ID_INVALIDO',message='ID do produto inválido.'}end
 local cached=cache[id];if cached and not force and os.clock()-cached.at<60 then return cached.data end
 local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Product)end)
 local nativeError=not ok and tostring(info)or nil;local ready,stage=M.Inspect(ok and info or nil,false);local method='GetProductInfoAsync'
 if not ready and stage~='FORA_DE_VENDA'then
  local found,complete=false,false
  local listed,why=pcall(function()
   local pages=Market:GetDeveloperProductsAsync()
   for _=1,8 do
    for _,row in ipairs(pages:GetCurrentPage())do
     if tonumber(row.DeveloperProductId)==id or tonumber(row.TargetId)==id or tonumber(row.ProductId)==id or tonumber(row.Id)==id then
      found=true
      -- Um IsForSale=false explícito nunca é ignorado por outra resposta.
      if ok and type(info)=='table'and info.IsForSale==false then return end
      if row.IsForSale==false then info=row;ready=false;stage='FORA_DE_VENDA';return end
      local candidate=ok and price(info)and info or row
      ready,stage=M.Inspect(candidate,true);if ready then info=candidate;method='GetDeveloperProductsAsync + produto desta experiência'end;return
     end
    end
    if pages.IsFinished then complete=true;return end;pages:AdvanceToNextPageAsync()
   end
  end)
  if not found then
   if listed and complete then stage='PRODUTO_DE_OUTRA_EXPERIENCIA'
   elseif not listed then nativeError=(nativeError and nativeError..' | 'or'')..tostring(why);stage='CONSULTA_ROBLOX_FALHOU'end
  end
 end
 local messages={ID_INVALIDO='Confira o ID do Developer Product.',FORA_DE_VENDA='O Roblox informou que o produto está fora de venda.',
  PRECO_NAO_CONFIRMADO='O Roblox não forneceu um preço válido. Recarregue os preços.',VENDA_NAO_CONFIRMADA='O Roblox não confirmou a venda. Recarregue os preços.',
  PRODUTO_DE_OUTRA_EXPERIENCIA='Esse ID não foi encontrado nos Developer Products desta experiência. Confira o jogo em que ele foi criado.',
  CONSULTA_ROBLOX_FALHOU='A consulta ao Roblox falhou. Recarregue e confira o Output.',RESPOSTA_INVALIDA='O Roblox devolveu uma resposta incompleta.'}
 local result={ready=ready==true,id=id,price=ready and price(info)or nil,stage=stage,method=method,message=ready and'Confira o valor final no prompt oficial.'or messages[stage]or'Não foi possível confirmar o produto.'}
 if not ready then warn('[Planos V74] product='..id..' universe='..tostring(game.GameId)..' stage='..stage..' method='..method..' detail='..tostring(nativeError or'campos incompletos na resposta oficial'))end
 cache[id]={at=os.clock(),data=result};return result
end
return M
