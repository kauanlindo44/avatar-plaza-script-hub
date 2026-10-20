-- 09I_ASSISTANT_SERVER | Script | ServerScriptService | V72 (SUBSTITUIR)
-- Planos existentes restaurados; benefícios somente por recibo oficial, com lotes e cancelamento.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Market=game:GetService('MarketplaceService')
local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local Accounts=require(script.Parent:WaitForChild('09I1_ASSISTANT_ACCOUNTS'))
local Engine=require(script.Parent:WaitForChild('09I2_ASSISTANT_ENGINE'));local Builder=require(script.Parent:WaitForChild('09I3_OUTFIT_BUILDER'))
local Runtime=require(script.Parent:WaitForChild('09B5_AVATAR_RUNTIME'));local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local Conversations=require(script.Parent:WaitForChild('09I11_CONVERSATIONS'))
local Contract=require(Rep:WaitForChild('09I21_LOOK_CONTRACT'));local Bodies=require(script.Parent:WaitForChild('09B14_AVATAR_BASES'));local Batches=require(script.Parent:WaitForChild('09I24_LOOK_BATCHES'))
local Text=game:GetService('TextService');local sessions={};local globalActive=0;local lastRequest={};local healthStarted=false;local lastManual=-30
local folder=Rep:FindFirstChild('ACP_AssistantRemotes')or Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=Rep
local rpc=folder:FindFirstChild('Request')or Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local events=folder:FindFirstChild('Progress')or Instance.new('RemoteEvent');events.Name='Progress';events.Parent=folder
local function session(pl)if not sessions[pl]then sessions[pl]={messages=0,token=0,looks={}}end;return sessions[pl]end
local function reply(data,e)return{version='V72',protocol=2,ok=data~=nil and data~=false,data=data,error=e}end
local function filtered(pl,text)
 local ok,v=pcall(function()return Text:FilterStringAsync(text,pl.UserId):GetNonChatStringForBroadcastAsync()end);return ok and v or nil
end
local function checkHealth(force)
 if healthStarted then return end;healthStarted=true
 task.spawn(function()
  Engine.Health(force);healthStarted=false
  for _,player in ipairs(Players:GetPlayers())do events:FireClient(player,{kind='health',available=Engine.Available,checking=false,language=Engine.Language,diagnostic=Engine.Summary()})end
 end)
end
local function status(pl,args)
 local v,e=Accounts.View(pl.UserId);if not v then return nil,e end
 pl:SetAttribute('ACP_LegacyAIPlan',v.plan~='Normal'and v.plan or nil)
 v.available=Engine.Protocol==2 and Builder.Protocol==2;v.engineVersion=Engine.Version or'antigo';v.checking=false;v.language='pt';v.diagnostic=Engine.Summary();if Engine.Protocol~=2 or Builder.Protocol~=2 then v.connectionError='Instalação incompleta: confira 09I2_ASSISTANT_ENGINE e 09I3_OUTFIT_BUILDER em ServerScriptService.'end;v.disclosure=C.Disclosure;v.messagesLeft=math.max(0,C.MaxMessages-session(pl).messages)
 return v
end
local function ad(pl)return{hidden=true}end
local function start(pl,args,resume)
 if type(args.text)~='string'or #args.text<1 or #args.text>1200 then return nil,'Digite uma mensagem de até 1.200 caracteres.'end
 local confirmed=args.make==true and type(args.options)=='table'and tonumber(args.options.budget)~=nil
 if args.make==false or not confirmed and Engine.IsHelp and Engine.IsHelp(args.text)then
  local request=tostring(args.request or'help'):sub(1,80);local s=session(pl);local answer,topic=Engine.Help(args.text,s.helpTopic);s.helpTopic=topic
  task.defer(function()if pl.Parent then events:FireClient(pl,{request=request,kind='result',data={answer=answer,looks={},count=0,requested=0,language='pt',help=true}})end end)
  return{request=request,help=true}
 end
 if Engine.Protocol~=2 or Builder.Protocol~=2 then warn('[IA V72] INSTALL module=09I2_ASSISTANT_ENGINE location=ServerScriptService expected=protocol2 got='..tostring(Engine.Version or'antigo')..' builder='..tostring(Builder.Version or'antigo'));return nil,'Módulo antigo da IA: substitua 09I2_ASSISTANT_ENGINE no ServerScriptService e reinicie Play. Nenhum limite foi usado.'end
 local access,why=Accounts.View(pl.UserId);if not access then return nil,why end
 local s=session(pl);if s.busy then return nil,'Aguarde a solicitação atual.'end
 if s.messages>=C.MaxMessages then return nil,'Esta sessão atingiu o limite de solicitações. Seus looks continuam disponíveis.'end
 if type(args.text)~='string'or #args.text<1 or #args.text>1200 then return nil,'Digite uma mensagem de até 1.200 caracteres.'end
 if globalActive>=3 then return nil,'A IA está ocupada. Tente em instantes.'end
 if not resume then s.pending=nil;s.jobSeen={}else s.jobSeen=resume.seen or{}end
 local account,e;if resume then account=access else account,e=Accounts.Reserve(pl.UserId)end;if not account then return nil,e end
 s.busy=true;s.token=s.token+1;local token=s.token;if not resume then s.messages=s.messages+1 end;globalActive=globalActive+1
 local opts=Builder.Options(args.options,account.plan);if resume then opts=A.Copy(resume.options);opts.count=math.min(5,resume.target-resume.done)end;local effort=Contract.Effort(opts.effort,account.plan);local mine=tostring(args.request or token):sub(1,80)
 local function alive()return pl.Parent~=nil and sessions[pl]==s and s.token==token end
 local function progress(value,label,stage)if alive()then events:FireClient(pl,{request=mine,kind='progress',percent=value,label=label,stage=stage})end end
 local settled=false
 local finish
 finish=function(data,errorText)
  if settled then return end;settled=true;globalActive=math.max(0,globalActive-1);
  if not data then
   local refunded=not resume and Accounts.Refund(account.owner,account.temporary);if not resume then s.messages=math.max(0,s.messages-1)end
   errorText=(errorText or'Não foi possível concluir.')..(resume and' Os looks anteriores foram mantidos; continuar o lote não usou outro limite.'or refunded and' Limite diário devolvido.'or' O armazenamento não confirmou a devolução do limite; recarregue o perfil.')
  end
  if s.cancel==finish then s.cancel=nil;s.busy=false end
  if alive()then events:FireClient(pl,{request=mine,kind=data and'result'or'error',data=data,error=errorText,available=Engine.Available,connectionError=Engine.Error,language=Engine.Language,diagnostic=Engine.Summary()})end
 end
 s.cancel=finish
 task.delay(effort.seconds+18,function()if not settled then finish(nil,'A solicitação demorou.');if s.token==token then s.token=s.token+1 end end end)
 task.spawn(function()
  local ok,data,errorText=pcall(function()
   local reference=Batches.Find(pl,args.baseKey)or s.looks[tonumber(args.baseIndex)or 1]
   local context=s.context
   progress(5,'Planejando a busca de peças reais…');local answer,why
   if args.make==false then answer={answer=Engine.Help(args.text),language='pt'}else answer,why=Engine.Ask(pl,args.text,context,opts.style,opts)end
   if not answer then return nil,why end
   if answer.scope and not opts.confirmed then opts.scope=answer.scope;opts.keep=opts.scope~='Tudo' end
   if answer.color and answer.color~=''then opts.color=answer.color end
   if answer.cheaper then opts.economy=true end
   if answer.free then opts.budget=0;opts.pieceBudget=0 end
   opts.plan=account.plan
   if not alive()then return nil,'Solicitação cancelada.'end
   local looks={}
   if args.make~=false then
    local ready,h,desc;local untilReady=os.clock()+8
    repeat ready,h,desc=pcall(Runtime.Description,pl);if ready or not alive()then break end;task.wait(.15)until os.clock()>=untilReady
    if not ready then return nil,'Seu avatar ainda está carregando no mapa. Tente em instantes.'end
    local body=A.Pack(desc);desc:Destroy();if resume then body=A.Copy(resume.base)else s.buildBase=A.Copy(body)end
    if reference and(opts.scope~='Tudo'or opts.tool=='Lote'or opts.tool=='Econômico'or opts.tool=='Cores'or opts.tool=='Temas')then body=reference.body end;if not resume then s.buildBase=A.Copy(body)end
    local found,reason=Builder.Build(pl,answer.keyword,opts,body,progress,alive,s.jobSeen);if not found then return nil,reason end;looks=found
   end
   if not alive()then return nil,'Solicitação cancelada.'end
   if #looks>0 then
    local partial=false;for _,look in ipairs(looks)do if #(look.missing or{})>0 then partial=true end end
    if partial then answer.answer=answer.answer..' Confira as peças antes de aplicar.'end
    Batches.Add(pl,looks,resume==nil);s.looks=looks;s.context={keyword=answer.keyword,style=answer.style,styleId=answer.styleId,color=answer.color}end;progress(100,'Pronto')
   local target=resume and resume.target or opts.requestedCount or opts.count;local done=(resume and resume.done or 0)+#looks;local partial=#looks<opts.count
   local batch=resume and resume.id or game:GetService('HttpService'):GenerateGUID(false)
   if account.plan=='Pro'and done<target and not partial then s.pending={id=batch,target=target,done=done,options=A.Copy(opts),base=A.Copy(resume and resume.base or s.buildBase),text=args.text,expires=os.clock()+1800,owner=account.owner,seen=s.jobSeen};else s.pending=nil end
   return {answer=answer.answer,looks=looks,plan=account.plan,count=#looks,requested=opts.count,target=target,completed=done,batch=s.pending and batch or nil,partial=partial,disclosure=C.Disclosure,language=answer.language}
  end)
  if not ok then warn('[IA V72] Assistente: '..tostring(data));errorText='Falha ao concluir o pedido. Recarregue a IA; o erro original foi registrado no Output.';data=nil end
  finish(data,errorText)
 end)
 return {request=mine}
end
local handlers={status=status,ad=ad}
handlers['body.catalog']=function(pl,args)return Bodies.Catalog(pl,args)end
handlers.more=function(pl,args)
 local s=session(pl);local pending=s.pending;local access,e=Accounts.View(pl.UserId)
 if not pending or pending.id~=args.batch or pending.expires<os.clock()then return nil,'Esse pedido de lotes expirou. Faça uma nova solicitação.'end
 if not access or access.plan~='Pro'or access.owner~=pending.owner then s.pending=nil;return nil,e or'O plano Pro precisa estar ativo para continuar os lotes.'end
 return start(pl,{text=pending.text,options=pending.options,request=args.request},pending)
end
for _,name in ipairs({'chat.list','chat.read','chat.save','chat.delete','chat.share','chat.code'})do handlers[name]=function(pl,args)return Conversations.Handle(pl,name,args)end end
handlers.ask=start
handlers.cancel=function(pl)local s=session(pl);s.pending=nil;s.token=s.token+1;if s.cancel then s.cancel(nil,'Solicitação cancelada.')end;return true end
handlers.newchat=function(pl)handlers.cancel(pl);local s=session(pl);s.context=nil;s.looks={};s.helpTopic=nil;s.jobSeen=nil;Batches.Clear(pl);return true end
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
 local s=session(pl);local look=Batches.Find(pl,d.lookKey)or s.looks[tonumber(d.index)or 0];if not look then return nil,'Look indisponível. Gere uma nova combinação.'end
 local v,e=Accounts.View(pl.UserId);if not v then return nil,e end
 local folder='Favoritos';if v.plan=='Pro'then folder=filtered(pl,tostring(d.folder or'Favoritos'):sub(1,30))or'Favoritos'end
 local saved=A.Copy(look);if d.body then local body,why=A.Clean(d.body);if not body then return nil,why end;saved.body=body end
 return Accounts.Collection(pl.UserId,saved,folder)
end
handlers.prompt=function(pl,d)
 local plan=d.plan=='Plus'and'Studio'or d.plan;local spec=C.Plans[plan];if not spec or not spec.product then return nil,'Escolha Plus ou Pro.'end
 local view,e=Accounts.View(pl.UserId);if not view or view.storageAvailable==false then return nil,e or'Carregue o armazenamento antes de comprar.'end
 local ok,info=pcall(function()return Market:GetProductInfoAsync(spec.product,Enum.InfoType.Product)end);if not ok or not info or not info.IsForSale or not tonumber(info.PriceInRobux)then return nil,'O Roblox não confirmou disponibilidade e preço. Recarregue os planos.'end
 local worked=pcall(function()Market:PromptProductPurchase(pl,spec.product)end);return worked and true or nil,not worked and'O Roblox não abriu a compra.'or nil
end
folder:SetAttribute('ServerVersion','V72');folder:SetAttribute('Protocol',2);folder:SetAttribute('EngineVersion',Engine.Version or'antigo')
rpc.OnServerInvoke=function(pl,action,args)
 if type(action)~='string'or not handlers[action]or args~=nil and type(args)~='table'then return reply(nil,'Pedido inválido.')end
 local now=os.clock();local limits=lastRequest[pl]or{};lastRequest[pl]=limits;if limits[action]and now-limits[action]<.25 then return reply(nil,'Aguarde um instante.')end;limits[action]=now
 local ok,data,e=pcall(handlers[action],pl,args or{});if not ok then warn('[IA V72] IA '..action..': '..tostring(data));return reply(nil,'O serviço não respondeu. Tente novamente.')end
 return reply(data,e)
end
Players.PlayerRemoving:Connect(function(pl)local s=sessions[pl];if s then s.token=s.token+1 end;sessions[pl]=nil;Batches.Clear(pl);lastRequest[pl]=nil end)
-- O planejador não depende de TextGenerator nem inicia sondas HTTP.
print('[IA V72] servidor=V72 motor='..tostring(Engine.Version or'antigo')..' protocolo='..tostring(Engine.Protocol or'antigo'))
