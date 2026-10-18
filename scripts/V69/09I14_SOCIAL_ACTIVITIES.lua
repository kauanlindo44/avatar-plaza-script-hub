-- 09I14_SOCIAL_ACTIVITIES | ModuleScript | ServerScriptService | V69 (NOVO)
-- Sessões consentidas; decisões estruturadas, pesquisa existente, nenhum texto-chat por remotes.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Http=game:GetService('HttpService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Rules=require(Rep:WaitForChild('09I15_ACTIVITY_RULES'))
local Runtime=require(script.Parent:WaitForChild('09B5_AVATAR_RUNTIME'));local Builder=require(script.Parent:WaitForChild('09I3_OUTFIT_BUILDER'))
local Accounts=require(script.Parent:WaitForChild('09I1_ASSISTANT_ACCOUNTS'));local Consent=require(script.Parent:WaitForChild('09I17_REMIX_PERMISSIONS'))
local Quote=require(script.Parent:WaitForChild('09B6_CART_RESOLVER'));local M={Version='V69'}
local rooms,byPlayer,invites,jobs,inviteTimes={},{},{},{},{};local activeJobs=0;local event;local applied={}
local top={Shirt=true,TShirt=true,Jacket=true,Sweater=true};local bottom={Pants=true,Shorts=true,DressSkirt=true,LeftShoe=true,RightShoe=true}
local function emit(pl,data)if event and pl.Parent==Players then event:FireClient(pl,data)end end
local function room(pl)local s=byPlayer[pl.UserId];if s and rooms[s.id]==s then return s end end
local function signature(body)local ids={};for _,v in ipairs(A.Entries(body))do ids[#ids+1]=v.Slot..':'..v.Id end;table.sort(ids);return table.concat(ids,',')end
local function snapshot(pl)
 local ok,h,desc=pcall(Runtime.Description,pl);if not ok then return nil,'Seu avatar ainda está carregando.'end
 local body=A.Pack(desc);desc:Destroy();local clean,e=A.Clean(body);if not clean then return nil,e end
 local look={name='Look em colaboração',body=clean,rig=h.RigType==Enum.HumanoidRigType.R6 and'R6'or'R15',items={},verified=false,pricePending=true}
 local prior=applied[pl.UserId];if prior and prior.signature==signature(clean)then look.remix=A.Copy(prior.remix)end;return look
end
local function view(s)
 local members={};for uid,p in pairs(s.members)do members[#members+1]={uid=uid,name=p.DisplayName,style=s.styles[uid]or s.settings.style,ready=s.results[uid]~=nil,remixAllowed=s.remixVotes and s.remixVotes[uid]==true}end
 table.sort(members,function(a,b)return a.uid<b.uid end)
 local results={};for uid,look in pairs(s.results)do results[#results+1]={uid=uid,name=s.members[uid]and s.members[uid].DisplayName or'Participante',look=A.Copy(look)}end;table.sort(results,function(a,b)return a.uid<b.uid end)
 return{id=s.id,kind=s.kind,owner=s.owner,settings=A.Copy(s.settings),members=members,results=results,look=s.look and A.Copy(s.look),revision=s.revision,
  steps=s.kind=='shoot'and Rules.Rehearsal(s.settings)or nil,source=s.source and{code=s.source.code,originalId=s.source.originalId,originalName=s.source.originalName,ownerName=s.source.ownerName}or nil}
end
local function broadcast(s)for _,p in pairs(s.members)do emit(p,{kind='state',session=view(s)})end end
function M.Status(pl)
 local rows={};for id,v in pairs(invites[pl.UserId]or{})do local s=rooms[id]
  if s and v.expires>os.time()then rows[#rows+1]={id=id,kind=s.kind,owner=v.owner,ownerName=v.ownerName,expires=v.expires}end
 end
 local players={};for _,p in ipairs(Players:GetPlayers())do if p~=pl then players[#players+1]={uid=p.UserId,name=p.DisplayName}end end
 return{session=room(pl)and view(room(pl)),invites=rows,players=players}
end
function M.Leave(pl)
 local s=room(pl);if not s then return true end;byPlayer[pl.UserId]=nil;s.members[pl.UserId]=nil;s.results[pl.UserId]=nil;s.revision=s.revision+1
 if jobs[pl.UserId]then jobs[pl.UserId].cancel=true end
 if s.owner==pl.UserId then
  rooms[s.id]=nil;for uid,p in pairs(s.members)do byPlayer[uid]=nil;if jobs[uid]then jobs[uid].cancel=true end;emit(p,{kind='closed',message='O criador encerrou a atividade. Seus looks já guardados continuam em Salvos.'})end
 else broadcast(s)end;return true
end
function M.Create(pl,data)
 local rule=Rules.Activity(data.kind);if not rule then return nil,'Atividade inválida.'end
 local look,e=snapshot(pl);if not look then return nil,e end
 local source
 if rule.id=='remix'and data.code and data.code~=''then
  source,e=Consent.Check(data.code,pl.UserId);if not source then return nil,e end
  look={name='Remix autorizado',body=A.Copy(source.body),rig=source.rig,items={},pricePending=true,remix=Consent.Provenance(source)}
 end
 M.Leave(pl);local settings=Rules.Settings(data)
 local s={id=Http:GenerateGUID(false),owner=pl.UserId,kind=rule.id,settings=settings,members={[pl.UserId]=pl},styles={[pl.UserId]=settings.style},results={},look=look,source=source,remixVotes={},contributors={[pl.UserId]=pl.DisplayName},revision=1,expires=os.time()+1800}
 rooms[s.id]=s;byPlayer[pl.UserId]=s;broadcast(s);return view(s)
end
function M.Invite(pl,data)
 local s=room(pl);local uid=tonumber(data.uid);local target=uid and Players:GetPlayerByUserId(uid)
 if not s or s.owner~=pl.UserId or not target or target==pl or s.members[uid]then return nil,'Escolha uma pessoa deste servidor para convidar.'end
 local count=0;for _ in pairs(s.members)do count=count+1 end;if count>=Rules.Activity(s.kind).max then return nil,'A atividade já está completa.'end
 local key=pl.UserId..':'..uid;if os.clock()-(inviteTimes[key]or-100)<60 then return nil,'Aguarde um minuto antes de convidar a mesma pessoa novamente.'end;inviteTimes[key]=os.clock()
 invites[uid]=invites[uid]or{};invites[uid][s.id]={owner=pl.UserId,ownerName=pl.DisplayName,expires=os.time()+180}
 emit(target,{kind='invite',id=s.id,activity=s.kind,ownerName=pl.DisplayName});return true
end
function M.Answer(pl,data)
 local invitation=invites[pl.UserId]and invites[pl.UserId][data.id];local s=rooms[data.id]
 if not invitation or invitation.expires<=os.time()or not s then return nil,'Convite expirado.'end
 invites[pl.UserId][data.id]=nil;if data.accept~=true then return true end
 local n=0;for _ in pairs(s.members)do n=n+1 end;if n>=Rules.Activity(s.kind).max then return nil,'A atividade já está completa.'end
 M.Leave(pl);s.members[pl.UserId]=pl;s.styles[pl.UserId]=s.settings.style;byPlayer[pl.UserId]=s;s.revision=s.revision+1;broadcast(s);return view(s)
end
function M.Configure(pl,data)
 local s=room(pl);if not s then return nil,'Crie ou aceite uma atividade.'end
 local settings=Rules.Settings(data)
 if s.owner==pl.UserId then s.settings=settings elseif s.kind~='duo'then return nil,'Somente o criador altera estas opções.'end
 s.styles[pl.UserId]=settings.style;s.revision=s.revision+1;broadcast(s);return view(s)
end
local function quoteClothes(pl,body)
 local rows={};for _,v in ipairs(A.Entries(body))do
  local slot=v.Slot;if slot=='Shirt'or slot=='Pants'or slot=='GraphicTShirt'or not table.find(A.Props,slot)and slot~='Emote'then rows[#rows+1]={id=v.Id,kind='Asset'}end
 end
 local total,items=0,{};for _,r in ipairs(Quote.Quote(pl,rows))do
  if r.price==nil then return nil,'Não foi possível confirmar o preço de uma peça. A contribuição não foi aplicada.'end
  total=total+r.price;items[#items+1]={Id=r.id,Name=r.name or'Item',Price=r.price,ItemType='Asset'}
 end;return total,items
end
function M.Contribute(pl,data)
 local s=room(pl);if not s or s.kind~='collab'then return nil,'Abra um look em colaboração.'end
 local own,e=snapshot(pl);if not own then return nil,e end
 local permitted,reason=Consent.Validate(s.look.remix,pl.UserId);if not permitted then return nil,reason end
 if own.remix and(not s.look.remix or own.remix.sourceCode~=s.look.remix.sourceCode)then return nil,'Use Remix autorizado para manter o crédito desta combinação.'end
 local lineage=s.look.remix and A.Copy(s.look.remix);local d=A.Copy(s.look.body);local slot=data.slot
 local function matches(t)return slot=='top'and top[t]or slot=='bottom'and bottom[t]or slot=='hair'and t=='Hair'or slot=='accessories'and not top[t]and not bottom[t]and t~='Hair'end
 if not table.find({'top','bottom','hair','accessories'},slot)then return nil,'Parte inválida.'end
 if slot=='top'then d.props.Shirt=own.body.props.Shirt;d.props.GraphicTShirt=own.body.props.GraphicTShirt elseif slot=='bottom'then d.props.Pants=own.body.props.Pants end
 for i=#d.accessories,1,-1 do if matches(d.accessories[i].type)then table.remove(d.accessories,i)end end
 for _,v in ipairs(own.body.accessories)do if matches(v.type)then d.accessories[#d.accessories+1]=A.Copy(v)end end
 local clean,why=A.Clean(d);if not clean then return nil,why end;local revision=s.revision
 local total,items=quoteClothes(pl,clean);if not total then return nil,items end
 if room(pl)~=s or s.revision~=revision then return nil,'A composição mudou. Envie a contribuição novamente.'end
 if total>s.settings.budget then return nil,'Roupas e acessórios somam '..total..' Robux; o limite da atividade é '..s.settings.budget..'.'end
 s.look={name='Look em colaboração',body=clean,rig=own.rig,items=items,total=total,verified=false,pricePending=false,priceScope='Roupas e acessórios; corpo atual preservado',activity='collab',remix=lineage,contributors={}}
 s.contributors[pl.UserId]=pl.DisplayName;for uid,name in pairs(s.contributors)do s.look.contributors[#s.look.contributors+1]={id=uid,name=name}end;s.remixVotes={}
 s.revision=s.revision+1;broadcast(s);return view(s)
end
local function current(pl)
 local s=room(pl);if not s then return end
 return(s.kind=='collab'or s.kind=='remix')and s.look or s.results[pl.UserId],s
end
function M.Generate(pl)
 local s=room(pl);if not s or s.kind=='shoot'then return nil,'Escolha uma atividade de criação.'end
 if(s.kind=='collab'or s.kind=='remix')and s.owner~=pl.UserId then return nil,'O criador solicita a base; todos podem enviar contribuições.'end
 if jobs[pl.UserId]or activeJobs>=3 then return nil,'Aguarde a pesquisa em andamento.'end
 local base,e=snapshot(pl);if not base then return nil,e end
 if s.kind=='remix'and not s.source then return nil,'Abra primeiro um código autorizado.'end
 if s.look.remix then local ok,why=Consent.Validate(s.look.remix,pl.UserId);if not ok then return nil,why end end
 if s.kind=='collab'or s.source then base=s.look end
 local access,why=Accounts.Reserve(pl.UserId);if not access then return nil,why end
 local token={session=s,cancel=false,revision=s.revision};jobs[pl.UserId]=token;activeJobs=activeJobs+1
 local settings=A.Copy(s.settings);settings.style=s.styles[pl.UserId]or settings.style;local prompt=Rules.Prompt(settings)
 local started=os.clock();local settled=false
 local function alive()return not token.cancel and jobs[pl.UserId]==token and room(pl)==s and s.revision==token.revision and pl.Parent==Players and os.clock()-started<48 end
 local function finish(look,errorText)
  if settled then return end;if look and not alive()then look=nil;errorText='A atividade mudou; solicite outra combinação.'end;settled=true;activeJobs=math.max(0,activeJobs-1);if jobs[pl.UserId]==token then jobs[pl.UserId]=nil end
  if not look then Accounts.Refund(access.owner,access.temporary);emit(pl,{kind='error',message=errorText or'Pesquisa cancelada; limite devolvido.'});return end
  if s.kind=='collab'then s.contributors={[pl.UserId]=pl.DisplayName};s.remixVotes={}end
  if s.kind=='collab'or s.kind=='remix'then s.look=look else s.results[pl.UserId]=look end
  emit(pl,{kind='progress',percent=100,message='Combinação pronta. Confira antes de aplicar.'});broadcast(s)
 end
 task.delay(49,function()if not settled then token.cancel=true;finish(nil,'A pesquisa demorou; limite devolvido.')end end)
 task.spawn(function()
  local ok,look,err=pcall(function()
   local opts=Builder.Options({budget=settings.budget,count=1,format=settings.format,color=prompt.color,scope='Tudo',confirmed=true,style=settings.style,styleEdited=true},access.plan);opts.plan=access.plan
   if s.kind=='remix'then opts.scope='Roupas';opts.keep=true end
   local rows,reason=Builder.Build(pl,prompt.keyword,opts,base.body,function(percent,label)if alive()then emit(pl,{kind='progress',percent=percent,message=label})end end,alive)
   if not rows then return nil,reason end;if not alive()then return nil,'As opções mudaram durante a pesquisa. Tente novamente.'end
   local result=rows[1];if s.kind=='duo'then for uid,other in pairs(s.results)do if uid~=pl.UserId and signature(other.body)==signature(result.body)then return nil,'Essa combinação já foi recebida pela dupla. Tente outra variação ou estilo.'end end end;result.activity=s.kind;result.name=Rules.Activity(s.kind).name..' · '..prompt.label
   if base.remix then local permitted,why=Consent.Validate(base.remix,pl.UserId);if not permitted then return nil,why end;result.remix=A.Copy(base.remix)end
   if s.kind=='collab'then result.contributors={{id=pl.UserId,name=pl.DisplayName}}end
   return result
  end)
  if not ok then warn('[Activities V69] '..tostring(look));finish(nil,'O catálogo não concluiu a pesquisa; limite devolvido.')else finish(look,err)end
 end)
 return{started=true}
end
function M.Save(pl)
 local look=current(pl);if not look then return nil,'Gere ou componha um look primeiro.'end
 local allowed,e=Consent.Validate(look.remix,pl.UserId);if not allowed then return nil,e end
 return Accounts.Collection(pl.UserId,look,'Atividades')
end
function M.Apply(pl)
 local look=current(pl);if not look then return nil,'Gere ou componha um look primeiro.'end
 local allowed,e=Consent.Validate(look.remix,pl.UserId);if not allowed then return nil,e end
 local desc=A.Unpack(look.body);local ok,result=pcall(Runtime.Apply,pl,desc,look.rig);desc:Destroy()
 if not ok then return nil,'O avatar não pôde ser aplicado. Veja o diagnóstico no Output.'end
 applied[pl.UserId]=look.remix and{signature=signature(look.body),remix=A.Copy(look.remix)}or nil;return result
end
function M.VoteRemix(pl,data)
 local s=room(pl);if not s or s.kind~='collab'or not s.contributors[pl.UserId]or type(data.allow)~='boolean'then return nil,'Somente colaboradores autorizam esta composição.'end
 s.remixVotes[pl.UserId]=data.allow;broadcast(s);return view(s)
end
function M.Publish(pl)
 local look,s=current(pl)
 if s and s.kind=='collab'then
  if s.owner~=pl.UserId then return nil,'O criador compartilha a composição após a autorização dos colaboradores.'end
  for uid in pairs(s.contributors)do if s.remixVotes[uid]~=true then return nil,'Cada colaborador precisa autorizar esta versão em Mais opções > Autorizar remix.'end end
 end;if not look then local e;look,e=snapshot(pl);if not look then return nil,e end end
 local allowed,e=Consent.Validate(look.remix,pl.UserId);if not allowed then return nil,e end
 return Consent.Create(pl,look,look.remix and look.remix.sourceCode)
end
function M.Bind(push)
 event=push;Players.PlayerRemoving:Connect(function(pl)M.Leave(pl);invites[pl.UserId]=nil;applied[pl.UserId]=nil end)
 task.spawn(function()while event.Parent do task.wait(30);for _,s in pairs(rooms)do if os.time()>=s.expires then local owner=s.members[s.owner];if owner then M.Leave(owner)end end end end end)
end
M.Consent=Consent;M.Current=current
return M
