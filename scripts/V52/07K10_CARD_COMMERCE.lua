-- 07K10_CARD_COMMERCE | ModuleScript | ServerScriptService | V44
-- PolicyService não prova 18+. Aleatoriedade paga permanece bloqueada globalmente.
local Market=game:GetService("MarketplaceService")
local Policy=game:GetService("PolicyService")
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local C=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local I=require(script.Parent:WaitForChild("07K8_CARD_INVENTORY"))
local M={};local infoCache={};local guards={}
local function info(id,kind)
 if id<=0 then return nil end
 local key=kind..id;local old=infoCache[key];if old and os.clock()-old.time<120 then return old.data end
 local ok,d=pcall(function()return Market:GetProductInfoAsync(id,kind=="pass"and Enum.InfoType.GamePass or Enum.InfoType.Product)end)
 if not ok then return nil end
 infoCache[key]={time=os.clock(),data=d};return d
end
function M.PaidRandomAllowed(pl)
 -- Não habilitar com AccountAge, autodeclaração, IsVerified ou apenas PolicyService=false.
 local ok,p=pcall(function()return Policy:GetPolicyInfoForPlayerAsync(pl)end)
 if not ok or p.ArePaidRandomItemsRestricted then return false,"Compra aleatória indisponível para esta conta."end
 return false,"Caixas aleatórias estão desativadas. Escolha um visual garantido."
end
function M.RefreshPasses(pl)
 local passes={C.CustomPass};for id in pairs(C.Passes)do table.insert(passes,id)end
 for _,id in ipairs(passes)do
  local ok,owned=pcall(function()return Market:UserOwnsGamePassAsync(pl.UserId,id)end)
  if ok and owned then I.GrantPass(pl.UserId,id)end
 end
end
function M.Store(pl)
 -- O cliente consulta preços regionais/personalizados. Este registro só informa os IDs autorizados.
 local out={passes={},products={},randomEnabled=false,notice="Escolha garantida • cosméticos permanentes • sem apostas"}
 local passIDs={C.CustomPass};for id in pairs(C.Passes)do table.insert(passIDs,id)end
 for _,id in ipairs(passIDs)do
  out.passes[tostring(id)]={id=id,style=C.Passes[id]or"Ateliê",sale=false}
 end
 for key,id in pairs(C.Products)do if not C.Collection(key)then out.products[key]={id=id,sale=false}end end
 return out
end
function M.Prompt(pl,kind,key)
 if guards[pl]and os.clock()-guards[pl]<2 then return nil,"Aguarde o Roblox."end
 local inventory=I.View(pl.UserId);if not inventory then return nil,"Carregue o inventário antes da compra."end
 if kind=="pass"and(tonumber(key)==C.CustomPass and inventory.ateliers or inventory.owned[C.Passes[tonumber(key)]or""])then return nil,"Você já possui este benefício."end
 local style=kind=="pass"and C.Passes[tonumber(key)]or kind=="product"and tostring(key)
 if style and C.Covered(inventory,style)then return nil,"Resgate seu crédito antigo na loja deste visual."end
 if kind=="product"then local box=C.Collection(key)
  if box then return nil,"Caixas retiradas. Escolha um visual na compra direta."
  elseif inventory.owned[tostring(key)]then return nil,"Visual já adquirido."end
 end
 local id=kind=="pass"and tonumber(key)or C.Products[tostring(key)]
 if kind=="pass"and id~=C.CustomPass and not C.Passes[id]then return nil,"Passe desconhecido."end
 if kind~="pass"and kind~="product"then return nil,"Compra inválida."end
 if not id or id<=0 then return nil,"Este produto ainda não foi configurado pelo criador."end
 local d=info(id,kind);if not d or not d.IsForSale or not d.PriceInRobux then return nil,"Roblox não confirmou preço e disponibilidade."end
 guards[pl]=os.clock()
 local ok=pcall(function()if kind=="pass"then Market:PromptGamePassPurchase(pl,id)else Market:PromptProductPurchase(pl,id)end end)
 return ok and true or nil,ok and nil or"Não foi possível abrir a compra."
end
function M.Start()
 Market.PromptGamePassPurchaseFinished:Connect(function(pl,id,bought)
  if not bought or(id~=C.CustomPass and not C.Passes[id])then return end
  -- A confirmação nativa de passe permanente é validada de novo no servidor.
  task.spawn(function()M.RefreshPasses(pl)end)
 end)
 -- Único proprietário de ProcessReceipt. Novos produtos devem entrar neste registro.
 Market.ProcessReceipt=function(receipt)
  for key,id in pairs(C.Products)do if id>0 and id==receipt.ProductId then
   local granted=I.Receipt(receipt,key)
   return granted and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
  end end
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
 Players.PlayerRemoving:Connect(function(pl)guards[pl]=nil end)
end
return M
