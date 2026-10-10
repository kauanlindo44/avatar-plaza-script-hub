-- 09I1_ASSISTANT_ACCOUNTS | ModuleScript | ServerScriptService | V55 (NOVO)
-- UpdateAsync em cada concessão; perfil não contém mensagens nem credenciais.
local Rep=game:GetService('ReplicatedStorage')
local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local DS=game:GetService('DataStoreService'):GetDataStore('ACP_AssistantProfiles_V55')
local A={};local cache={}
local function clean(d)
 if type(d)~='table'then d={}end
 for _,k in ipairs({'expiry','receipts','members','invites','collections','prefs','quota'})do if type(d[k])~='table'then d[k]={}end end
 return d
end
function A.Read(id)
 local ok,d=pcall(function()return DS:GetAsync('u'..id)end)
 if not ok then return nil,'O perfil não carregou. Recarregue.'end
 d=clean(d);cache[id]=d;return d
end
function A.Update(id,fn)
 local errorText,value;local ok,d=pcall(function()return DS:UpdateAsync('u'..id,function(old)
  local nextValue=clean(old);local worked,why,out=fn(nextValue);errorText=why;value=out
  if not worked then return nil end;return nextValue
 end)end)
 if not ok then return nil,'Não foi possível salvar. Tente novamente.'end
 if not d then return nil,errorText or'Operação recusada.'end
 cache[id]=d;return value or true
end
local function tier(d)
 local now=os.time();if(tonumber(d.expiry.Pro)or 0)>now then return 'Pro',d.expiry.Pro end
 if(tonumber(d.expiry.Studio)or 0)>now then return 'Studio',d.expiry.Studio end
 return 'Normal',0
end
function A.View(id)
 local d,e=A.Read(id);if not d then return nil,e end;local plan,expiry=tier(d);local owner=id
 local shared=tonumber(d.sharedOwner)
 if shared and shared~=id then
  local od,why=A.Read(shared);if not od then return nil,why end
  local t,x=tier(od);if od.members[tostring(id)]==true and C.Plans[t].count>C.Plans[plan].count then plan,expiry,owner=t,x,shared end
 end
 local invitations={};for uid,v in pairs(d.invites)do if type(v)=='table'and(v.untilTime or 0)>os.time()then invitations[#invitations+1]={owner=tonumber(uid),expires=v.untilTime}end end
 local members={};for uid in pairs(d.members)do members[#members+1]=tonumber(uid)end;table.sort(members)
 return {plan=plan,expires=expiry,owner=owner,count=C.Plans[plan].count,daily=C.Plans[plan].daily,members=members,invites=invitations,collections=d.collections,prefs=d.prefs,sharedOwner=shared}
end
function A.Receipt(r,plan)
 if not C.Plans[plan]or not C.Plans[plan].product then return nil end
 return A.Update(r.PlayerId,function(d)
  local key=tostring(r.PurchaseId);if d.receipts[key]then return true end
  local now=os.time();local start=math.max(now,tonumber(d.expiry[plan])or 0)
  if plan=='Studio'then start=math.max(start,tonumber(d.expiry.Pro)or 0)end
  d.expiry[plan]=start+C.Seconds;d.receipts[key]={product=r.ProductId,time=now};return true
 end)
end
function A.Reserve(id)
 local v,e=A.View(id);if not v then return nil,e end;local day=math.floor(os.time()/86400)
 local ok,why=A.Update(v.owner,function(d)
  if d.quota.day~=day then d.quota={day=day,used=0}end
  if(d.quota.used or 0)>=v.daily then return false,'O limite diário compartilhado terminou. Volte amanhã.'end
  d.quota.used=(d.quota.used or 0)+1;return true
 end)
 return ok and v or nil,why
end
function A.Refund(owner)
 return A.Update(owner,function(d)if d.quota.day==math.floor(os.time()/86400)then d.quota.used=math.max(0,(d.quota.used or 0)-1)end;return true end)
end
local function friends(pl,id)local ok,v=pcall(function()return pl:IsFriendsWithAsync(id)end);return ok and v end
function A.Invite(pl,id)
 id=tonumber(id);if not id or id%1~=0 or id<1 or id==pl.UserId or not friends(pl,id)then return nil,'Escolha um amigo Roblox verdadeiro.'end
 local d,e=A.Read(pl.UserId);if not d then return nil,e end
 if tier(d)=='Normal'then return nil,'Convites precisam de um plano ativo do titular.'end
 local n=0;for _ in pairs(d.members)do n=n+1 end;if n>=C.MaxFriends and not d.members[tostring(id)]then return nil,'São até três amigos.'end
 return A.Update(id,function(v)v.invites[tostring(pl.UserId)]={untilTime=os.time()+604800};return true end)
end
function A.Accept(pl,owner)
 owner=tonumber(owner);if not owner or owner<1 or owner%1~=0 or not friends(pl,owner)then return nil,'Convite inválido ou amizade não confirmada.'end
 local d,e=A.Read(pl.UserId);if not d then return nil,e end
 local invitation=d.invites[tostring(owner)];if not invitation or invitation.untilTime<=os.time()then return nil,'Convite expirado.'end
 local ok,why=A.Update(owner,function(v)
  if tier(v)=='Normal'then return false,'O plano do titular expirou.'end
  local n=0;for _ in pairs(v.members)do n=n+1 end;if n>=C.MaxFriends and not v.members[tostring(pl.UserId)]then return false,'O grupo já tem três amigos.'end
  v.members[tostring(pl.UserId)]=true;return true
 end)
 if not ok then return nil,why end
 return A.Update(pl.UserId,function(v)
  if not v.invites[tostring(owner)]or v.invites[tostring(owner)].untilTime<=os.time()then return false,'Convite expirado.'end
  v.sharedOwner=owner;v.invites[tostring(owner)]=nil;return true
 end)
end
function A.Revoke(pl,id)return A.Update(pl.UserId,function(d)d.members[tostring(tonumber(id)or 0)]=nil;return true end)end
function A.Leave(pl)return A.Update(pl.UserId,function(d)d.sharedOwner=nil;return true end)end
function A.Decline(pl,id)return A.Update(pl.UserId,function(d)d.invites[tostring(tonumber(id)or 0)]=nil;return true end)end
function A.Preference(id,key,value)
 if key~='theme'and key~='motion'and key~='share'then return nil,'Preferência inválida.'end
 if key=='theme'and value~='Halloween'and value~='Neutro'then return nil,'Tema inválido.'end
 if(key=='motion'or key=='share')and type(value)~='boolean'then return nil,'Valor inválido.'end
 return A.Update(id,function(d)d.prefs[key]=value;return true end)
end
function A.Collection(id,look,folder)
 folder=tostring(folder or'Favoritos'):sub(1,30);local guid=game:GetService('HttpService'):GenerateGUID(false)
 return A.Update(id,function(d)
  if #d.collections>=60 then return false,'Exclua uma coleção para liberar espaço.'end
  local parent
  for i=#d.collections,1,-1 do if d.collections[i].folder==folder and d.collections[i].name==look.name then parent=d.collections[i].id;break end end
  d.collections[#d.collections+1]={id=guid,folder=folder,name=look.name,body=look.body,rig=look.rig,items=look.items,total=look.total,parent=parent};return true,nil,guid
 end)
end
function A.Delete(id,key)return A.Update(id,function(d)for i,v in ipairs(d.collections)do if v.id==key then table.remove(d.collections,i);return true end end;return false,'Look não encontrado.'end)end
function A.SharedCollections(pl,owner)
 local v,e=A.View(pl.UserId);if not v then return nil,e end
 owner=tonumber(owner);if owner~=v.owner or owner==pl.UserId then return nil,'Abra as coleções do seu grupo.'end
 local d,why=A.Read(owner);if not d then return nil,why end
 if d.prefs.share~=true then return nil,'O titular ainda não compartilhou suas coleções.'end
 local rows={};for _,look in ipairs(d.collections)do local item={};for k,value in pairs(look)do item[k]=value end;item.sharedOwner=owner;rows[#rows+1]=item end
 return rows
end
return A
