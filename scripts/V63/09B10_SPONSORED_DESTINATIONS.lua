-- 09B10_SPONSORED_DESTINATIONS | ModuleScript | ServerScriptService | V63 (NOVO)
-- Vitrine voluntária de lugares/comunidades. Metadados nativos, sem anúncio pago.
local DS=game:GetService('DataStoreService');local Market=game:GetService('MarketplaceService');local Groups=game:GetService('GroupService')
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Teleport=game:GetService('TeleportService');local Http=game:GetService('HttpService')
local Messages=game:GetService('MessagingService');local data=DS:GetDataStore('AvatarPlaza_Destinations_v1');local index=game:GetService('MemoryStoreService'):GetSortedMap('AvatarPlaza_Destinations_v1')
local M={Version='V63',Duration=86400,Seeds={Game=83720142132483,Community=546113316}};M.Changed=Instance.new('BindableEvent')
local cache,sessions={},{};local subscription
local function notify()M.Changed:Fire();pcall(function()Messages:PublishAsync('ACP_Destinations_V63',{at=os.time()})end)end
pcall(function()subscription=Messages:SubscribeAsync('ACP_Destinations_V63',function()M.Changed:Fire()end)end)
game:BindToClose(function()if subscription then subscription:Disconnect()end end)
local function identity(args)
 local kind=args.kind;local id=tonumber(args.id)
 if(kind~='Game'and kind~='Community')or not id or id~=id or id%1~=0 or id<1 or id>9007199254740991 then error('Informe o ID de um lugar Roblox ou de uma comunidade.',0)end
 return kind,id,kind..':'..string.format('%.0f',id)
end
local function info(args,fresh)
 local kind,id,key=identity(args);local old=cache[key];if not fresh and old and os.clock()-old.at<180 then return old.item,key end
 local ok,v;local it={Id=id,ItemType=kind}
 if kind=='Game'then
  ok,v=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
  if not ok or type(v)~='table'or tonumber(v.AssetTypeId)~=Enum.AssetType.Place.Value then error('O Roblox não confirmou um lugar jogável nesse ID. Use o número do link /games/.',0)end
  it.Name=tostring(v.Name or'Experiência Roblox');it.description=tostring(v.Description or'');it.image='rbxthumb://type=GameThumbnail&id='..id..'&w=768&h=432'
 else
  ok,v=pcall(function()return Groups:GetGroupInfoAsync(id)end)
  if not ok or type(v)~='table'or not v.Name or tonumber(v.Id or id)~=id then error('O Roblox não confirmou a comunidade. Use o número do link /communities/.',0)end
  it.Name=tostring(v.Name);it.description=tostring(v.Description or'');it.image=tostring(v.EmblemUrl or'');it.notice=type(v.Shout)=='table'and tostring(v.Shout.Body or'')or''
 end
 it.Name=it.Name:sub(1,100);it.description=it.description:sub(1,2000);it.verified=true
 cache[key]={at=os.clock(),item=it};local n=0;for _ in pairs(cache)do n=n+1 end;if n>250 then cache={[key]=cache[key]}end
 return it,key
end
local function read(key)
 local ok,v=pcall(function()return data:GetAsync(key)end);if not ok then error('A vitrine não respondeu. Tente novamente.',0)end;return v
end
local function preferences(pl)
 local s=sessions[pl]or{};sessions[pl]=s
 if not s.prefs then s.prefs=read('p_'..pl.UserId)or{favorites={},likes={}}end
 return s.prefs
end
function M.Check(pl,args)return info(args,true)end
function M.Status(pl,args)
 local kind=args.kind;if kind~='Game'and kind~='Community'then error('Categoria inválida.',0)end
 local r=read('u_'..kind..'_'..pl.UserId);local now=os.time()
 return{item=r and r.active and r.expires>now and r or nil,nextAllowed=r and math.max(now,r.expires)or now,duration=M.Duration}
end
function M.Submit(pl,args)
 local it,key=info(args,true);local kind=it.ItemType;local now=os.time();local userKey='u_'..kind..'_'..pl.UserId;local token=Http:GenerateGUID(false)
 if it.Id==M.Seeds[kind]then error('Esse já é o destaque permanente desta categoria.',0)end
 local ok,r=pcall(function()return data:UpdateAsync(userKey,function(old)
  if old and old.expires>now then return old end
  return{item=it,key=key,owner=pl.UserId,created=now,expires=now+M.Duration,token=token,active=true,ready=false}
 end)end)
 if not ok or not r then error('Não foi possível salvar o destaque.',0)end
 if r.key~=key or not r.active then error('Você já usou o destaque de 24 horas nesta categoria.',0)end
 local claimed,claim=pcall(function()return data:UpdateAsync('a_'..key,function(old)
  if old and old.expires>now and old.owner~=pl.UserId then return old end
  return{owner=pl.UserId,expires=r.expires,token=r.token}
 end)end)
 if not claimed then error('Envio salvo. Reenvie o mesmo ID para concluir.',0)end
 if not claim or claim.owner~=pl.UserId then
  pcall(function()data:UpdateAsync(userKey,function(old)if old and old.token==r.token and not old.ready then old.active=false;old.expires=now end;return old end)end)
  error('Esse já está em destaque. Escolha outro.',0)
 end
 local saved,ready=pcall(function()return data:UpdateAsync(userKey,function(old)if old and old.token==r.token then old.ready=true end;return old end)end)
 if not saved or not ready or not ready.ready or not ready.active then error('Confirmação pendente. Reenvie o mesmo ID.',0)end
 local indexed=pcall(function()index:SetAsync(kind..'_'..pl.UserId,ready,math.max(1,ready.expires-os.time()),ready.created)end)
 if not indexed then error('Envio salvo. Reenvie o mesmo ID para atualizar a vitrine.',0)end
 notify();return ready
end
function M.Withdraw(pl,args)
 local kind=args.kind;if kind~='Game'and kind~='Community'then error('Categoria inválida.',0)end
 local ok,r=pcall(function()return data:UpdateAsync('u_'..kind..'_'..pl.UserId,function(old)if old then old.active=false end;return old end)end)
 if not ok then error('Não foi possível retirar agora.',0)end
 if not pcall(function()index:RemoveAsync(kind..'_'..pl.UserId)end)then error('Retirada salva. Tente novamente para atualizar a vitrine.',0)end
 if r then pcall(function()data:UpdateAsync('a_'..r.key,function(old)if old and old.token==r.token then old.expires=0 end;return old end)end)end
 notify();return true
end
function M.Reaction(pl,args)
 local _,_,key=identity(args);local field=args.action=='like'and'likes'or args.action=='favorite'and'favorites'
 if not field or type(args.value)~='boolean'then error('Preferência inválida.',0)end;info(args,false)
 local ok,r=pcall(function()return data:UpdateAsync('p_'..pl.UserId,function(old)
  old=type(old)=='table'and old or{};local out={};for _,v in ipairs(old[field]or{})do if type(v)=='string'and v~=key and #out<99 then out[#out+1]=v end end
  if args.value then table.insert(out,1,key)end;old[field]=out;return old
 end)end)
 if not ok or not r then error('Sua preferência não foi salva.',0)end
 local s=sessions[pl]or{};sessions[pl]=s;s.prefs=r;return{value=args.value,scope='Vitrine deste jogo'}
end
function M.Feed(pl,args)
 local kind=args.kind;if kind~='Game'and kind~='Community'then error('Categoria inválida.',0)end
 local query=tostring(args.search or''):lower():sub(1,70);local s=sessions[pl]or{};sessions[pl]=s
 if args.next~=true or not s.feed or s.feed.kind~=kind or s.feed.query~=query then s.feed={kind=kind,query=query,after=nil,seen={},seed=false}end
 local f=s.feed;local out={};local prefs=preferences(pl);local now=os.time()
 local function add(r)
  local it=r.item;if not it or it.ItemType~=kind or f.seen[r.key]then return end;f.seen[r.key]=true
  if(query==''or it.Name:lower():find(query,1,true)or tostring(it.Id)==query)and(not args.favorites or table.find(prefs.favorites or{},r.key))then
   out[#out+1]={item=it,key=r.key,owner=r.owner,expires=r.expires,permanent=r.permanent,favorite=table.find(prefs.favorites or{},r.key)~=nil,liked=table.find(prefs.likes or{},r.key)~=nil}
  end
 end
 if not f.seed then
  f.seed=true;local id=M.Seeds[kind];local ok,it=pcall(info,{id=id,kind=kind},false)
  if not ok then it={Id=id,ItemType=kind,Name=kind=='Game'and'Avatar Creator Plaza'or'Comunidade '..id,description='Metadados indisponíveis. Use Recarregar para consultar novamente.',verified=false,image=kind=='Game'and('rbxthumb://type=GameThumbnail&id='..id..'&w=768&h=432')or''}end
  add({item=it,key=kind..':'..id,permanent=true})
 end
 local loops=0;f.pending=f.pending or{}
 while #out<60 and not f.finished and loops<4 do
  if #f.pending==0 then
   loops=loops+1;local ok,rows=pcall(function()return index:GetRangeAsync(Enum.SortDirection.Descending,100,nil,f.after)end)
   if not ok then error('A vitrine não respondeu. Nenhum envio foi apagado.',0)end
   if #rows==0 then f.finished=true;break end
   f.pending=rows;local last=rows[#rows];f.after={key=last.key,sortKey=last.sortKey};f.lastPage=#rows<100
  end
  while #f.pending>0 and #out<60 do local row=table.remove(f.pending,1);local r=row.value
   if r and r.active and r.ready and r.expires>now then add(r)end
  end
  if #f.pending==0 and f.lastPage then f.finished=true end
 end
 return{items=out,finished=f.finished==true,version=M.Version}
end
function M.Play(pl,args)
 local it=info({kind='Game',id=args.id},true)
 if it.Id==game.PlaceId then return{here=true}end
 if pl:GetAttribute('ACP_InGameRoom')or pl:GetAttribute('ACP_BoardWaiting')then error('Finalize ou saia da partida antes de entrar em outra experiência.',0)end
 if args.confirm~=true then return{confirm=true,id=it.Id,name=it.Name}end
 local ok,e=pcall(function()Teleport:TeleportAsync(it.Id,{pl})end)
 if not ok then warn('[V63 Destination] TELEPORT id='..it.Id..' '..tostring(e));error('O Roblox não iniciou a entrada. Teste no jogo publicado e confira a disponibilidade.',0)end
 return{teleporting=true}
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
return M
