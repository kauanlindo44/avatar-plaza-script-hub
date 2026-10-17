-- 09I11_CONVERSATIONS | ModuleScript | ServerScriptService | V67 (NOVO)
-- Histórico privado por UserId. Compartilhar só cria uma cópia textual filtrada após confirmação.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Http=game:GetService('HttpService');local Text=game:GetService('TextService')
local Accounts=require(script.Parent:WaitForChild('09I1_ASSISTANT_ACCOUNTS'))
local Shares=game:GetService('DataStoreService'):GetDataStore('ACP_ChatShares_V67');local M={Version='V67'};local states={};local shareAt={}
local function copy(value)if type(value)~='table'then return value end;local out={};for k,v in pairs(value)do out[k]=copy(v)end;return out end
local function load(pl)
 local s=states[pl];if s then return s end
 local d,e=Accounts.Read(pl.UserId);if not d then return nil,e end
 s={threads=type(d.chatThreads)=='table'and copy(d.chatThreads)or{},deleted={},revision=0};states[pl]=s;return s
end
local function flush(pl,s)
 if not s.dirty or s.saving then return end;s.saving=true;local revision=s.revision;local snapshot=copy(s.threads);local deleted=copy(s.deleted)
 local ok,e=Accounts.Update(pl.UserId,function(d)
  local merged=type(d.chatThreads)=='table'and d.chatThreads or{}
  for id,v in pairs(snapshot)do if not merged[id]or(v.updated or 0)>=(merged[id].updated or 0)then merged[id]=v end end
  for id,at in pairs(deleted)do if not merged[id]or(merged[id].updated or 0)<=at then merged[id]=nil end end
  local list={};for _,v in pairs(merged)do list[#list+1]=v end;table.sort(list,function(a,b)return(a.updated or 0)>(b.updated or 0)end)
  d.chatThreads={};for i=1,math.min(20,#list)do d.chatThreads[list[i].id]=list[i]end;return true
 end)
 s.saving=false;if ok and revision==s.revision then s.dirty=false end
 if not ok then warn('[IA V67] CHAT_SAVE | '..pl.UserId..' | '..tostring(e))end;return ok,e
end
local function changed(pl,s)
 s.dirty=true;s.revision=s.revision+1;if s.queued then return end;s.queued=true
 task.delay(20,function()s.queued=false;flush(pl,s)end)
end
local function messages(raw)
 if type(raw)~='table'then return nil end;local out={}
 for i=math.max(1,#raw-15),#raw do local v=raw[i]
  if type(v)=='table'and(v.role=='user'or v.role=='assistant')and type(v.text)=='string'then out[#out+1]={role=v.role,text=v.text:sub(1,1200)}end
 end;return out
end
local function identifier(raw)return type(raw)=='string'and #raw<=64 and raw:match('^[%w%-]+$')and raw end
function M.Handle(pl,action,args)
 local s,e=load(pl);if not s then return nil,e or'O histórico não carregou; a conversa atual continua disponível.'end
 if action=='chat.list'then
  local out={};for _,v in pairs(s.threads)do out[#out+1]={id=v.id,title=v.title,archived=v.archived==true,updated=v.updated,count=#(v.messages or{})}end
  table.sort(out,function(a,b)return a.updated>b.updated end);return{items=out,persistent=not s.dirty}
 elseif action=='chat.read'then local id=identifier(args.id);local v=id and s.threads[id];return v and copy(v)or nil,v and nil or'Conversa não encontrada na sua conta.'
 elseif action=='chat.save'then
  local id=identifier(args.id)or Http:GenerateGUID(false);local rows=messages(args.messages);if not rows then return nil,'Conversa inválida.'end
  local count=0;for _ in pairs(s.threads)do count=count+1 end;if not s.threads[id]and count>=20 then return nil,'Há 20 conversas guardadas. Exclua uma para salvar outra.'end
  local old=s.threads[id];local title=tostring(args.title or old and old.title or'Nova conversa'):gsub('[%c]',' '):sub(1,50)
  s.threads[id]={id=id,title=title,messages=rows,archived=args.archived==true,updated=os.time()};s.deleted[id]=nil;changed(pl,s)
  return{id=id,title=title,pending=true}
 elseif action=='chat.delete'then local id=identifier(args.id);if not id or not s.threads[id]then return nil,'Conversa não encontrada.'end;s.threads[id]=nil;s.deleted[id]=os.time();changed(pl,s);return true
 elseif action=='chat.share'then
  if args.confirm~=true then return nil,'Confirme a criação da cópia pública.'end
  if os.clock()-(shareAt[pl]or-100)<30 then return nil,'Aguarde 30 segundos antes de compartilhar novamente.'end
  local id=identifier(args.id);local v=id and s.threads[id];if not v then return nil,'Salve a conversa antes de compartilhar.'end
  local out={};for i=math.max(1,#v.messages-7),#v.messages do local row=v.messages[i]
   local ok,result=pcall(function()return Text:FilterStringAsync(row.text:sub(1,800),pl.UserId):GetNonChatStringForBroadcastAsync()end)
   if not ok then return nil,'O Roblox não confirmou o filtro. Nenhum código foi publicado.'end;out[#out+1]={role=row.role,text=result}
  end
  local code='CH-'..Http:GenerateGUID(false):gsub('%-',''):sub(1,12):upper();local record={title='Conversa compartilhada',messages=out,expires=os.time()+604800}
  local ok=pcall(function()Shares:SetAsync(code,record)end);if not ok then return nil,'O código não foi salvo. Tente novamente.'end;shareAt[pl]=os.clock();return{code=code,expires=record.expires}
 elseif action=='chat.code'then
  local code=tostring(args.code or''):upper();if not code:match('^CH%-%x%x%x%x%x%x%x%x%x%x%x%x$')then return nil,'Use o código CH- com 12 caracteres.'end
  local ok,v=pcall(function()return Shares:GetAsync(code)end);if not ok or type(v)~='table'or(v.expires or 0)<=os.time()then return nil,'Código indisponível ou expirado.'end
  return{title=v.title,messages=copy(v.messages),shared=true}
 end;return nil,'Ação de conversa inválida.'
end
Players.PlayerRemoving:Connect(function(pl)local s=states[pl];if s then flush(pl,s)end;states[pl]=nil;shareAt[pl]=nil end)
game:BindToClose(function()for pl,s in pairs(states)do flush(pl,s)end end)
return M
