-- 09B14_AVATAR_BASES | ModuleScript | ServerScriptService | V72 (NOVO)
-- Catálogo nativo de corpos: metadados e composição confirmados; sem IDs inventados.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local M={};local cache={};local inflight={}
function M.Catalog(pl,args)
 args=type(args)=='table'and args or{};local id=tonumber(args.id)
 if id then
  if id%1~=0 or id<1 or id>9007199254740991 then return nil,'ID de corpo inválido.'end
  local ok,item=pcall(function()return Avatar:GetItemDetailsAsync(id,Enum.AvatarItemType.Bundle)end)
  if not ok or type(item)~='table'then return nil,'O Roblox não confirmou esse corpo. Tente novamente.'end
  if not(item.BundleType=='BodyParts'or item.BundleType==Enum.BundleType.BodyParts or tostring(item.BundleType)=='1')then return nil,'Esse pacote não é um corpo completo.'end
  item.Id=id;item.ItemType='Bundle';local base=args.base and A.Clean(args.base)
  if not base then local d=Instance.new('HumanoidDescription');base=A.Pack(d);d:Destroy()end
  local body,rig,why=A.BundleBody(item,base);if not body then return nil,why end
  return {id=id,name=item.Name or('Corpo # '..id),price=A.Price(item),body=body,rig='R15',item=item}
 end
 local word=tostring(args.query or''):gsub('[%c<>]',''):sub(1,80);local key=word:lower();local now=os.clock()
 if cache[key]and now-cache[key].at<90 then return A.Copy(cache[key].rows)end
 if inflight[key]then return nil,'A busca está em andamento. Tente novamente em instantes.'end;inflight[key]=true
 local ok,rows=pcall(function()
  local p=CatalogSearchParams.new();p.SearchKeyword=word;p.IncludeOffSale=false;p.BundleTypes={Enum.BundleType.BodyParts};p.Limit=30;p.SortType=Enum.CatalogSortType.Relevance
  local pages=Avatar:SearchCatalogAsync(p);local out={}
  for _,item in ipairs(pages:GetCurrentPage())do if tonumber(item.Id)then out[#out+1]={id=item.Id,name=item.Name or'Corpo',price=A.Price(item)}end end
  return out
 end);inflight[key]=nil
 if not ok then return nil,'O catálogo de corpos não respondeu. Use Recarregar.'end
 cache[key]={at=os.clock(),rows=rows};local n=0;for _ in pairs(cache)do n=n+1 end;if n>24 then cache={[key]=cache[key]}end;return A.Copy(rows)
end
return M
