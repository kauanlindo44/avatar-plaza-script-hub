-- 09I_ASSISTANT_SERVER | Script | ServerScriptService | V55 (NOVO)
-- Conversas breves e privadas. Apenas looks/planos/preferências persistem.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Market=game:GetService('MarketplaceService')
local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local Accounts=require(script.Parent:WaitForChild('09I1_ASSISTANT_ACCOUNTS'))
local Engine=require(script.Parent:WaitForChild('09I2_ASSISTANT_ENGINE'));local Builder=require(script.Parent:WaitForChild('09I3_OUTFIT_BUILDER'))
local Runtime=require(script.Parent:WaitForChild('09B5_AVATAR_RUNTIME'));local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local Text=game:GetService('TextService');local sessions={};local globalActive=0;local lastRequest={};local healthStarted=false;local lastManual=-30
local folder=Rep:FindFirstChild('ACP_AssistantRemotes')or Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=Rep
local rpc=folder:FindFirstChild('Request')or Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local events=folder:FindFirstChild('Progress')or Instance.new('RemoteEvent');events.Name='Progress';events.Parent=folder
local function session(pl)if not sessions[pl]then sessions[pl]={messages=0,token=0,looks={}}end;return sessions[pl]end
local function reply(data,e)return{ok=data~=nil and data~=false,data=data,error=e}end
local function filtered(pl,text)
 local ok,v=pcall(function()return Text:FilterStringAsync(text,pl.UserId):GetNonChatStringForBroadcastAsync()end);return ok and v or nil
end
local function status(pl,args)
 local v,e=Accounts.View(pl.UserId);if not v then return nil,e end
 v.available=Engine.Available;v.disclosure=C.Disclosure;v.messagesLeft=math.max(0,C.MaxMessages-session(pl).messages)
 local force=args and args.retry==true and os.clock()-lastManual>12
 if not healthStarted and(force or Engine.Checked==0 or os.clock()-Engine.Checked>300)then
  if force then lastManual=os.clock()end
  healthStarted=true;task.spawn(function()Engine.Health(force);healthStarted=false;if pl.Parent then events:FireClient(pl,{kind='health',available=Engine.Available})end end)
 end
 return v
end
local function ad(pl)
 local v,e=Accounts.View(pl.UserId);if not v then return nil,e end;if v.plan=='Pro'then return {hidden=true}end
 local ok,info=pcall(function()return Market:GetProductInfoAsync(C.AdAsset,Enum.InfoType.Asset)end)
 local creator=ok and info and info.Creator
 if not creator or tonumber(creator.CreatorTargetId or creator.Id)~=C.AdOwner or tostring(creator.CreatorType)~='User'or not info.IsForSale then return {hidden=true,reason='Publicidade indisponível.'}end
 return {id=C.AdAsset,name=info.Name,price=info.PriceInRobux,label='Publicidade — minha coleção'}
end
local function start(pl,args)
 local s=session(pl);if s.busy then return nil,'Aguarde a solicitação atual.'end
 if s.messages>=C.MaxMessages then return nil,'As oito interações desta sessão terminaram. Seus looks continuam disponíveis.'end
 if type(args.text)~='string'or #args.text<1 or #args.text>1200 then return nil,'Digite uma mensagem de até 1.200 caracteres.'end
 if globalActive>=3 then return nil,'A IA está ocupada. Tente em instantes.'end
 if not Engine.Available then return nil,'IA Roblox indisponível. Recarregue a conexão; os planos ficam bloqueados.'end
 local account,e=Accounts.Reserve(pl.UserId);if not account then return nil,e end
 s.busy=true;s.token=s.token+1;local token=s.token;s.messages=s.messages+1;globalActive=globalActive+1
 local opts=Builder.Options(args.options,account.plan);local mine=tostring(args.request or token):sub(1,80)
 local function alive()return pl.Parent~=nil and sessions[pl]==s and s.token==token end
 local function progress(value,label)if alive()then events:FireClient(pl,{request=mine,kind='progress',percent=value,label=label})end end
 local settled=false
 local function finish(data,errorText)
  if settled then return end;settled=true;globalActive=math.max(0,globalActive-1);s.busy=false
  if not data then
   local refunded=Accounts.Refund(account.owner);s.messages=math.max(0,s.messages-1)
   errorText=(errorText or'Não foi possível concluir.')..(refunded and' Limite diário devolvido.'or' O armazenamento não confirmou a devolução do limite; recarregue o perfil.')
  end
  if alive()then events:FireClient(pl,{request=mine,kind=data and'result'or'error',data=data,error=errorText})end
 end
 task.delay(55,function()if not settled then finish(nil,'A solicitação demorou.');if s.token==token then s.token=s.token+1 end end end)
 task.spawn(function()
  local ok,data,errorText=pcall(function()
   progress(5,'Entendendo seu pedido…');local answer,why=Engine.Ask(pl,args.text);if not answer then return nil,why end
   if not alive()then return nil,'Solicitação cancelada.'end
   local looks={}
   if args.make~=false then
    local h,desc=Runtime.Description(pl);local body=A.Pack(desc);desc:Destroy()
    if opts.tool=='Lote'or opts.tool=='Econômico'or opts.tool=='Cores'or opts.tool=='Temas'then local index=tonumber(args.baseIndex)or 1;local old=s.looks[index];if old then body=old.body end end
    local found,reason=Builder.Build(pl,answer.keyword,opts,body,progress,alive);if not found then return nil,reason end;looks=found
   end
   if not alive()then return nil,'Solicitação cancelada.'end
   s.looks=looks;progress(100,'Pronto')
   return {answer=answer.answer,looks=looks,plan=account.plan,count=#looks,requested=opts.count,disclosure=C.Disclosure}
  end)
  if not ok then warn('[V55] Assistente: '..tostring(data));errorText='Não foi possível concluir.';data=nil end
  finish(data,errorText)
 end)
 return {request=mine}
end
local handlers={status=status,ad=ad}
handlers.ask=start
handlers.cancel=function(pl)local s=session(pl);s.token=s.token+1;return true end
handlers.invite=function(pl,d)return Accounts.Invite(pl,d.id)end
handlers.accept=function(pl,d)return Accounts.Accept(pl,d.id)end
handlers.decline=function(pl,d)return Accounts.Decline(pl,d.id)end
handlers.revoke=function(pl,d)return Accounts.Revoke(pl,d.id)end
handlers.leave=function(pl)return Accounts.Leave(pl)end
handlers.pref=function(pl,d)return Accounts.Preference(pl.UserId,d.key,d.value)end
handlers.delete=function(pl,d)return Accounts.Delete(pl.UserId,tostring(d.id))end
handlers.shared=function(pl,d)return Accounts.SharedCollections(pl,d.id)end
handlers.copyshared=function(pl,d)
 local rows,e=Accounts.SharedCollections(pl,d.owner);if not rows then return nil,e end
 for _,look in ipairs(rows)do if look.id==d.id then return Accounts.Collection(pl.UserId,look,'Grupo')end end
 return nil,'Esse look compartilhado não está mais disponível.'
end
handlers.save=function(pl,d)
 local s=session(pl);local look=s.looks[tonumber(d.index)or 0];if not look then return nil,'Look indisponível. Gere uma nova combinação.'end
 local v,e=Accounts.View(pl.UserId);if not v then return nil,e end
 local folder='Favoritos';if v.plan=='Pro'then folder=filtered(pl,tostring(d.folder or'Favoritos'):sub(1,30))or'Favoritos'end
 local saved=A.Copy(look);if d.body then local body,why=A.Clean(d.body);if not body then return nil,why end;saved.body=body end
 return Accounts.Collection(pl.UserId,saved,folder)
end
handlers.prompt=function(pl,d)
 if not Engine.Health()then return nil,'Compra bloqueada: a IA real ainda não está disponível.'end
 local plan=C.Plans[d.plan];if not plan or not plan.product then return nil,'Plano inválido.'end
 local v,e=Accounts.View(pl.UserId);if not v then return nil,e end
 local ok,p=pcall(function()return Market:GetProductInfoAsync(plan.product,Enum.InfoType.Product)end)
 if not ok or not p or not p.IsForSale or type(p.PriceInRobux)~='number'then return nil,'O Roblox não confirmou este produto.'end
 local worked=pcall(function()Market:PromptProductPurchase(pl,plan.product)end);return worked or nil,worked and nil or'O Roblox não abriu a compra.'
end
rpc.OnServerInvoke=function(pl,action,args)
 if type(action)~='string'or not handlers[action]or args~=nil and type(args)~='table'then return reply(nil,'Pedido inválido.')end
 local now=os.clock();if lastRequest[pl]and now-lastRequest[pl]<.25 then return reply(nil,'Aguarde um instante.')end;lastRequest[pl]=now
 local ok,data,e=pcall(handlers[action],pl,args or{});if not ok then warn('[V55] IA '..action..': '..tostring(data));return reply(nil,'O serviço não respondeu. Tente novamente.')end
 return reply(data,e)
end
Players.PlayerRemoving:Connect(function(pl)local s=sessions[pl];if s then s.token=s.token+1 end;sessions[pl]=nil;lastRequest[pl]=nil end)
task.spawn(Engine.Health)
