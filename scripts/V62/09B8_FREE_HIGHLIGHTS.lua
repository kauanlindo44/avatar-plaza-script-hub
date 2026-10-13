-- 09B8_FREE_HIGHLIGHTS | ModuleScript | ServerScriptService | V62 (SUBSTITUIR)
-- Vitrine voluntária do catálogo Roblox. Não cobra moeda, Robux ou contrapartida.
local DS=game:GetService('DataStoreService');local Rep=game:GetService('ReplicatedStorage')
local Market=game:GetService('MarketplaceService');local Assets=game:GetService('AssetService')
local Http=game:GetService('HttpService');local Players=game:GetService('Players')
local M={Duration=86400,PageSize=60,Version='V62'};local store=DS:GetDataStore('AvatarPlaza_FreeHighlights_v1')
local index=game:GetService('MemoryStoreService'):GetSortedMap('AvatarPlaza_FreeHighlights_v1')
local sessions,records,recordOrder,prices,priceOrder={},{},{},{},{}
M.Changed=Instance.new('BindableEvent');local Messages=game:GetService('MessagingService')
local function notify()M.Changed:Fire();pcall(function()Messages:PublishAsync('ACP_Highlights_V61',{at=os.time()})end)end
local subscription;pcall(function()subscription=Messages:SubscribeAsync('ACP_Highlights_V61',function()M.Changed:Fire()end)end)
game:BindToClose(function()if subscription then subscription:Disconnect()end end)
local allowed={};local clothes={TShirt=true,Shirt=true,Pants=true,TShirtAccessory=true,ShirtAccessory=true,PantsAccessory=true,JacketAccessory=true,SweaterAccessory=true,ShortsAccessory=true,DressSkirtAccessory=true}
for _,name in ipairs({'TShirt','Shirt','Pants','Hat','Head','Face','Torso','RightArm','LeftArm','LeftLeg','RightLeg','HairAccessory','FaceAccessory','NeckAccessory','ShoulderAccessory','FrontAccessory','BackAccessory','WaistAccessory','TShirtAccessory','ShirtAccessory','PantsAccessory','JacketAccessory','SweaterAccessory','ShortsAccessory','LeftShoeAccessory','RightShoeAccessory','DressSkirtAccessory','EyebrowAccessory','EyelashAccessory','DynamicHead','EmoteAnimation'})do
 local ok,v=pcall(function()return Enum.AvatarAssetType[name]end);if ok and v then allowed[v.Value]={name=name,group=clothes[name]and'Roupas'or(name:find('Accessory')or name=='Hat')and'Acessórios'or name=='EmoteAnimation'and'Emotes'or'Corpo'}end
end
local function ident(args)
 local n=tonumber(args.id);local kind=args.kind or'Asset'
 if not n or n~=n or n<1 or n>9007199254740991 or n%1~=0 or(kind~='Asset'and kind~='Bundle')then error('Use o ID de um item ou pacote do catálogo Roblox.',0)end
 return n,kind,kind..':'..string.format('%.0f',n)
end
local function cached(map,key,ttl)local r=map[key];return r and os.clock()-r.at<ttl and r.data or nil end
local function put(map,order,key,data,limit)
 if not map[key]then order[#order+1]=key end;map[key]={at=os.clock(),data=data}
 while #order>limit do map[table.remove(order,1)]=nil end
end
local function item(args,fresh,offSale)
 local id,kind,key=ident(args);local old=not fresh and cached(prices,key,60);if old and(not old.unavailable or offSale)then return old,key end
 local ok,info=pcall(function()return Market:GetProductInfoAsync(id,kind=='Bundle'and Enum.InfoType.Bundle or Enum.InfoType.Asset)end)
 if not ok or type(info)~='table'then error('O Roblox não confirmou esse item. Confira o ID e tente novamente.',0)end
 local group,assetType,bundleType='Corpo',nil,nil
 if kind=='Asset'then
  local valid=allowed[tonumber(info.AssetTypeId)]
  if not valid then error('Destaques aceita somente roupas, acessórios, corpos e emotes do catálogo.',0)end
  group=valid.group;assetType=valid.name
 else
  local got,details=pcall(function()return Assets:GetBundleDetailsAsync(id)end)
  if not got or type(details)~='table'or tonumber(details.Id)~=id or not details.BundleType then error('Esse ID não corresponde a um pacote de avatar.',0)end
  bundleType=details.BundleType
 end
 local sale=info.IsForSale==true
 if not sale and not offSale then error('Esse item não está disponível para compra no Roblox.',0)end
 if not offSale and(not tonumber(info.PriceInRobux)or tonumber(info.PriceInRobux)<=0)then error('Patrocinar aceita somente itens pagos em Robux. Publicar o destaque continua grátis.',0)end
 local name=tostring(info.Name or'Item Roblox');local endAt=utf8.offset(name,81);if endAt then name=name:sub(1,endAt-1)end
 local result={Id=id,ItemType=kind,AssetType=assetType,BundleType=bundleType,Name=name,Price=tonumber(info.PriceInRobux),group=group,unavailable=not sale}
 put(prices,priceOrder,key,result,300);return result,key
end
local function rank(id)local n=(tonumber(id)or 0)%2147483647;n=n*48271%2147483647;return n*48271%2147483647 end
local function readOwner(owner)
 local key=tostring(owner);local c=cached(records,key,45);if c then return c end
 local ok,r=pcall(function()return store:GetAsync('u_'..key)end);if not ok then error('O armazenamento dos destaques não respondeu. Tente novamente.',0)end
 if r then put(records,recordOrder,key,r,600)end;return r
end
local function forget(owner)records[tostring(owner)]=nil end
local function favorites(pl)
 local s=sessions[pl]or{};sessions[pl]=s;if s.favorites then return s.favorites end
 local ok,v=pcall(function()return store:GetAsync('f_'..pl.UserId)end)
 if not ok then error('Seus favoritos não carregaram. Tente novamente.',0)end
 s.favorites=type(v)=='table'and v or{};return s.favorites
end
function M.Status(pl)
 forget(pl.UserId);local r=readOwner(pl.UserId);local now=os.time();local indexed=true
 if r and not r.active then
  indexed=pcall(function()index:RemoveAsync(tostring(pl.UserId))end)
  pcall(function()store:UpdateAsync('a_'..r.key,function(old)if old and old.owner==pl.UserId and old.token==r.token then old.expires=0 end;return old end)end)
 end
 local paid=r and r.item and tonumber(r.item.Price)and r.item.Price>0
 if r and r.active and r.ready and r.expires>now then indexed=pcall(function()if paid then index:SetAsync(tostring(pl.UserId),r,r.expires-now,rank(pl.UserId))else index:RemoveAsync(tostring(pl.UserId))end end)end
 return{version=M.Version,indexed=indexed,duration=M.Duration,free=true,paidOnly=true,item=paid and r.active and r.expires>now and r or nil,nextAllowed=paid and math.max(now,r.expires)or now,favorites=favorites(pl)}
end
function M.Check(pl,args)return item(args,true)end
function M.Submit(pl,args)
 local v,key=item(args,true);local now=os.time();local token=Http:GenerateGUID(false)
 local ok,r=pcall(function()return store:UpdateAsync('u_'..pl.UserId,function(old)
  if old and old.expires>now and old.item and tonumber(old.item.Price)and old.item.Price>0 then return old end
  return{owner=pl.UserId,key=key,item=v,created=now,expires=now+M.Duration,active=true,token=token,ready=false}
 end)end)
 if not ok or not r then error('Não foi possível salvar. Nenhum destaque foi publicado.',0)end
 forget(pl.UserId)
 if r.key~=key or not r.active then error('Você já usou seu destaque de 24 horas. Aguarde o prazo terminar.',0)end
 -- Repetir o mesmo envio repara o índice; nunca renova o prazo.
 local claimOK,claim=pcall(function()return store:UpdateAsync('a_'..key,function(old)
  if old and old.expires>now and old.owner~=pl.UserId then return old end
  return{owner=pl.UserId,expires=r.expires,token=r.token}
 end)end)
 if not claimOK or not claim then error('O item ainda não foi publicado. Tente o mesmo ID novamente.',0)end
 if claim.owner~=pl.UserId then
  pcall(function()store:UpdateAsync('u_'..pl.UserId,function(old)if old and old.token==r.token and not old.ready then old.active=false;old.expires=now end;return old end)end);forget(pl.UserId)
  error('Esse item já está em destaque. Escolha outro; não há cards repetidos.',0)
 end
 local saved,ready=pcall(function()return store:UpdateAsync('u_'..pl.UserId,function(old)
  if old and old.token==r.token then old.ready=true end;return old
 end)end);forget(pl.UserId)
 if not saved or not ready or not ready.ready or not ready.active then error('A confirmação demorou. Reenvie o mesmo ID; o prazo não será reiniciado.',0)end
 local indexed=pcall(function()index:SetAsync(tostring(pl.UserId),ready,math.max(1,ready.expires-os.time()),rank(pl.UserId))end)
 if not indexed then error('Envio salvo, mas a vitrine ainda não confirmou. Reenvie o mesmo ID para concluir.',0)end
 notify();return{item=ready,free=true,expires=ready.expires}
end
function M.Withdraw(pl)
 local ok,r=pcall(function()return store:UpdateAsync('u_'..pl.UserId,function(old)if old then old.active=false end;return old end)end)
 if not ok then error('Não foi possível retirar agora. Tente novamente.',0)end;forget(pl.UserId)
 local removed=pcall(function()index:RemoveAsync(tostring(pl.UserId))end)
 if not removed then error('Retirada salva, mas a vitrine ainda não confirmou. Reabra Destacar grátis para tentar novamente.',0)end
 if r then pcall(function()store:UpdateAsync('a_'..r.key,function(old)if old and old.owner==pl.UserId and old.token==r.token then old.expires=0 end;return old end)end)end
 notify();return{removed=true,nextAllowed=r and r.expires or os.time()}
end
function M.Favorite(pl,args)
 local _,_,key=ident(args);if type(args.value)~='boolean'then error('Preferência inválida.',0)end
 if args.value then item(args,false)end
 local ok,r=pcall(function()return store:UpdateAsync('f_'..pl.UserId,function(old)
  local out,seen={},{};for _,v in ipairs(type(old)=='table'and old or{})do if type(v)=='string'and v~=key and not seen[v]and #out<119 then out[#out+1]=v;seen[v]=true end end
  if args.value then table.insert(out,1,key)end;return out
 end)end)
 if not ok or not r then error('O favorito não foi salvo. Tente novamente.',0)end
 local s=sessions[pl]or{};sessions[pl]=s;s.favorites=r;return{favorites=r,value=args.value}
end
function M.Purchase(pl,args)
 local v=item(args,true);local ok=pcall(function()if v.ItemType=='Bundle'then Market:PromptBundlePurchase(pl,v.Id)else Market:PromptPurchase(pl,v.Id)end end)
 if not ok then error('O Roblox não abriu a compra deste item.',0)end;return true
end
function M.Feed(pl,args)
 local s=sessions[pl]or{};sessions[pl]=s;local now=os.time()
 if os.clock()-(s.last or-10)<.8 then error('Aguarde um instante antes de atualizar.',0)end;s.last=os.clock()
 local query=tostring(args.search or''):lower():sub(1,60);local group=tostring(args.group or'Todos')
 if not table.find({'Todos','Roupas','Roupas 2D','Roupas 3D','Acessórios','Corpo','Emotes','Favoritos'},group)then error('Filtro inválido.',0)end
 if args.next~=true or not s.feed or s.feed.query~=query or s.feed.group~=group then
  local pivot=.5+(rank(pl.UserId+math.floor(now/300))%2147483647)
  s.feed={query=query,group=group,at=now,pivot=pivot,wrap=false,after={sortKey=pivot},pending={},seen={},history={}}
 end
 if group=='Favoritos'then
  local out={};local fav=favorites(pl);local at=args.next==true and(s.favoriteAt or 1)or 1
  for i=at,math.min(#fav,at+M.PageSize-1)do local kind,id=fav[i]:match('^(%a+):(%d+)$')
   if id then local ok,it=pcall(item,{id=id,kind=kind},false,true);if ok and tonumber(it.Price)and it.Price>0 and(query==''or it.Name:lower():find(query,1,true)or tostring(it.Id)==query)then out[#out+1]={item=it,key=fav[i],favorite=true}end end
  end
  s.favoriteAt=at+M.PageSize;return{items=out,finished=s.favoriteAt>#fav,free=true,duration=M.Duration}
 end
 local f=s.feed;local out={};local fav=favorites(pl);local tries=0
 while #out<M.PageSize and tries<4 and not f.finished do
  if #f.pending==0 then
   local ok,rows=pcall(function()return index:GetRangeAsync(Enum.SortDirection.Ascending,100,f.after,f.wrap and{sortKey=f.pivot}or nil)end)
   if not ok then error('A vitrine não respondeu. Seus envios continuam salvos; tente atualizar.',0)end
   tries=tries+1
   if #rows==0 then
    if f.wrap then f.finished=true else f.wrap=true;f.after={sortKey=-1};end
   else f.pending=rows;local last=rows[#rows];f.after={key=last.key,sortKey=last.sortKey}end
  end
  while #f.pending>0 and #out<M.PageSize do
   local row=table.remove(f.pending,1);local r=row.value
   if r and r.active and r.ready and r.expires>now and not f.seen[r.key]then
    f.seen[r.key]=true;f.history[#f.history+1]=r.key;if #f.history>600 then f.seen[table.remove(f.history,1)]=nil end;local it=r.item;local classic=it.AssetType=='TShirt'or it.AssetType=='Shirt'or it.AssetType=='Pants'
    if it.Price and it.Price>0 and not it.unavailable and(group=='Todos'or group==it.group or group=='Roupas 2D'and classic or group=='Roupas 3D'and it.group=='Roupas'and not classic or group=='Favoritos'and table.find(fav,r.key))and(query==''or it.Name:lower():find(query,1,true)or tostring(it.Id)==query)then
     out[#out+1]={item=it,key=r.key,expires=r.expires,favorite=table.find(fav,r.key)~=nil}
    end
   end
  end
 end
 local ok,first=pcall(function()return index:GetRangeAsync(Enum.SortDirection.Ascending,100)end)
 local eligible=false;if ok then for _,row in ipairs(first)do local r=row.value;if r and r.active and r.ready and r.expires>now and r.item and tonumber(r.item.Price)and r.item.Price>0 then eligible=true;break end end end
 return{items=out,finished=f.finished==true,duration=M.Duration,free=true,emptyGlobal=ok and not eligible,paidOnly=true,version=M.Version}
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
return M
