-- 09B6_CART_RESOLVER | ModuleScript | ServerScriptService | V53 (NOVO)
-- Converte peças vendidas em pacote; nunca inventa preço ou posse.
local Rep=game:GetService('ReplicatedStorage')
local Avatar=game:GetService('AvatarEditorService')
local Market=game:GetService('MarketplaceService')
local Asset=game:GetService('AssetService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local M={};local cache,order={},{}
local function cached(key,fn)
 local row=cache[key];if row and os.clock()-row.at<120 then return row.value end
 local ok,value=pcall(fn);if not ok or not value then return nil end
 if not row then order[#order+1]=key end;cache[key]={at=os.clock(),value=value}
 while #order>256 do cache[table.remove(order,1)]=nil end
 return value
end
function M.Owned(pl,item)
 local ok,value=pcall(function()
  if item.kind=='Bundle'then return Market:PlayerOwnsBundleAsync(pl,item.id)end
  return Market:PlayerOwnsAssetAsync(pl,item.id)
 end)
 if ok then return value==true end;return nil
end
local function details(item)
 return cached(item.kind..':'..item.id,function()
  if item.kind=='Bundle'then return Avatar:GetItemDetailsAsync(item.id,Enum.AvatarItemType.Bundle)end
  return Market:GetProductInfoAsync(item.id,Enum.InfoType.Asset)
 end)
end
function M.Quote(pl,items)
 local out={}
 for _,item in ipairs(items)do
  local d=details(item);local price=d and(item.kind=='Bundle'and A.Price(d)or tonumber(d.PriceInRobux))
  local unavailable=d and(d.IsForSale==false or d.PriceStatus=='Off Sale'or d.PriceStatus=='No Resellers')or false
  out[#out+1]={id=item.id,kind=item.kind,name=d and d.Name,price=not unavailable and price or nil,
   owned=M.Owned(pl,item),unavailable=unavailable==true,known=d~=nil}
 end
 return out
end
local function candidates(id)
 return cached('bundles:'..id,function()
  local p=Avatar:GetBundlesByAssetIdAsync(id,10)
  return p and p:GetCurrentPage()or{}
 end)or{}
end
local function contents(id)
 local d=cached('contents:'..id,function()return Asset:GetBundleDetailsAsync(id)end)
 local ids={}
 for _,v in ipairs(d and d.Items or{})do if tostring(v.Type or v.ItemType):lower()=='asset'and tonumber(v.Id)then ids[tonumber(v.Id)]=true end end
 return ids
end
function M.Outfit(pl,body)
 local entries=A.Entries(body);local wanted={};for _,e in ipairs(entries)do wanted[e.Id]=true end
 local picked,covered,result={},{},{}
 for _,e in ipairs(entries)do if not covered[e.Id]then
  local asset={id=e.Id,kind='Asset'};local d=details(asset);local own=M.Owned(pl,asset)
  local isOff=d and(d.IsForSale==false or d.PriceStatus=='Off Sale'or d.PriceStatus=='No Resellers')
  local bundled=({Head=true,Torso=true,LeftArm=true,RightArm=true,LeftLeg=true,RightLeg=true,LeftShoe=true,RightShoe=true})[e.Slot]
  local best,bestCost,bestCount,bestIds
  if own~=true and(isOff or bundled)then
   for _,v in ipairs(candidates(e.Id))do local id=tonumber(v.Id);if id then
    local row={id=id,kind='Bundle'};local info=details(row);local price=info and A.Price(info);local already=M.Owned(pl,row)
    if already or(info and info.PriceStatus~='Off Sale'and info.IsForSale~=false and price~=nil)then
     local ids=contents(id);local n=0;for part in pairs(ids)do if wanted[part]and not covered[part]then n=n+1 end end
     local cost=already and 0 or price
     if ids[e.Id]and n>0 and(not best or cost/n<bestCost/bestCount or cost/n==bestCost/bestCount and id<best.id)then
      best,bestCost,bestCount,bestIds=row,cost,n,ids
     end
    end
   end end
  end
  if best then
   if not picked['Bundle:'..best.id]then result[#result+1]=best;picked['Bundle:'..best.id]=true end
   for id in pairs(bestIds)do if wanted[id]then covered[id]=true end end
  else result[#result+1]=asset;covered[e.Id]=true end
 end end
 -- Um pacote escolhido pode cobrir peças encontradas antes dele.
 local packageIds={};for _,v in ipairs(result)do if v.kind=='Bundle'then for id in pairs(contents(v.id))do packageIds[id]=true end end end
 local out={};for _,v in ipairs(result)do if v.kind=='Bundle'or not packageIds[v.id]then out[#out+1]=v end end
 return out
end
return M
