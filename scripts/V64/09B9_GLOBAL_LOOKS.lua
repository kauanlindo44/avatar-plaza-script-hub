-- 09B9_GLOBAL_LOOKS | ModuleScript | ServerScriptService | V64 (SUBSTITUIR)
-- Índice compartilhado e fila com pausa; mesmos dados/códigos da V61 preservados.
local DS=game:GetService('DataStoreService');local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Budget=require(script.Parent:WaitForChild('09B11_DATA_BUDGET'))
local store=DS:GetDataStore('ACP_GlobalLooks_V61');local seeds=DS:GetOrderedDataStore('ACP_GlobalLookSeeds_V61')
local M={Version='V64'};local sessions,jobs,cache,seeding={},{},{},{};local started=false;local describe;local nextWork=0
local index={owners={},seen={},retry=0,complete=false,reading=false};local scanAt=1;local nextScan=0
local function valid(n)n=tonumber(n);return n and n==n and n%1==0 and n>1 and n<9007199254740991 and n end
local function canonical(t)
 if type(t)~='table'then return type(t)..':'..tostring(t)end
 local keys={};for k in pairs(t)do keys[#keys+1]=k end;table.sort(keys,function(a,b)return tostring(a)<tostring(b)end)
 local out={};for _,k in ipairs(keys)do out[#out+1]=tostring(k)..'='..canonical(t[k])end;return'{'..table.concat(out,';')..'}'
end
function M.Code(body)
 local b=A.Copy(body);b.emotes={};for key in pairs(b.props)do if key:find('Animation',1,true)then b.props[key]=nil end end
 table.sort(b.accessories,function(a,b)return a.id==b.id and tostring(a.type)<tostring(b.type)or a.id<b.id end)
 local text=canonical(b);local x,y=5381,7919
 for i=1,#text do local byte=text:byte(i);x=(x*65599+byte)%2147483647;y=(y*48271+byte)%2147483629 end
 return string.format('LK-%08X%08X',x,y),text
end
local function remember(owner)
 if not index.seen[owner]then index.seen[owner]=true;index.owners[#index.owners+1]=owner end
end
local function readIndex()
 if index.reading or os.clock()<index.retry then return false end
 if index.complete and os.clock()<(index.expires or 0)then return true end
 index.reading=true
 local ok,rows=Budget.Run('List',true,function()
  if not index.pages or index.complete then index.pages=seeds:GetSortedAsync(true,50)else index.pages:AdvanceToNextPageAsync()end
  return index.pages:GetCurrentPage()
 end)
 index.reading=false;index.retry=os.clock()+(ok and 20 or 30)
 if not ok then return false end
 for _,row in ipairs(rows or{})do local id=valid(row.key);if id then remember(id)end end
 index.complete=index.pages.IsFinished==true;index.expires=os.clock()+300;return true
end
local function trimJobs(keep)
 local n=0;for _ in pairs(jobs)do n=n+1 end;if n<=64 then return end
 for id,j in pairs(jobs)do if n>64 and j~=keep and(j.changed or 0)==0 and not Players:GetPlayerByUserId(id)then jobs[id]=nil;n=n-1 end end
end
local function getJob(owner,background)
 local j=jobs[owner];if j then return j end
 local ok,value=Budget.Run('Read',background,function()return store:GetAsync('seed_'..owner)end)
 if not ok then return nil end
 if type(value)=='table'and type(value.ids)=='table'then value.cursor=tonumber(value.cursor)or 1;value.meta=value.meta or{};jobs[owner]=value;trimJobs(value);return value end
 return nil
end
function M.Save(owner,body,rig)
 local clean,why=A.Clean(body);if not clean then return nil,why end
 if #A.Entries(clean)==0 then return nil,'Avatar sem itens verificáveis.'end
 local code,signature=M.Code(clean)
 if cache[code]then return A.Copy(cache[code])end
 if not Budget.Can('Write',true)or not Budget.Can('Read',true)then return nil,'Fila pausada para dados pessoais.'end
 local record={id=code,code=code,owner=owner,name='Look de jogador',body=clean,rig=rig or'R15',source='Archive',signature=signature,checkedAt=os.time()}
 if describe then local ok,value=pcall(describe,record);if ok and value then record=value end end
 local ok,saved=Budget.Run('Write',true,function()return store:UpdateAsync('look_'..code,function(old)
  if old then if old.signature~=signature then error('Colisão de código; aparência anterior preservada.')end;if type(record.total)=='number'then old.total=record.total;old.budget=record.budget;old.priceCheckedAt=os.time()end;return old end
  return record
 end)end)
 if not ok or not saved then return nil,'Gravação global pendente; a fila tentará novamente.'end
 local n=0;for _ in pairs(cache)do n=n+1 end;if n>=512 then cache={}end
 cache[code]=saved;return A.Copy(saved)
end
function M.Get(code)
 if type(code)~='string'or not code:match('^LK%-%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$')then return nil,'Código inválido.'end
 if cache[code]then return A.Copy(cache[code])end
 local ok,r=Budget.Run('Read',false,function()return store:GetAsync('look_'..code)end)
 if not ok then return nil,'O arquivo de looks está ocupado. Tente novamente.'end
 if not r then return nil,'Código não encontrado.'end;cache[code]=r;return A.Copy(r)
end
function M.AddSeed(owner,ids)
 local ok,saved=Budget.Run('Write',true,function()return store:UpdateAsync('seed_'..owner,function(old)
  old=type(old)=='table'and old or{ids={},cursor=1,meta={}};old.ids=old.ids or{};old.meta=old.meta or{};local seen={}
  for _,id in ipairs(old.ids)do seen[id]=true end
  for _,id in ipairs(ids)do id=valid(id);if id and not seen[id]and #old.ids<10001 then seen[id]=true;old.ids[#old.ids+1]=id end end
  old.owner=owner;old.updatedAt=os.time();return old
 end)end)
 if not ok or not saved then return nil,'Descoberta pendente no armazenamento.'end
 jobs[owner]=saved;trimJobs(saved)
 -- Só grava no índice uma vez por registro; marca persistente permite recuperar falhas.
 if not saved.indexed then
  local indexed=Budget.Run('OrderedWrite',true,function()return seeds:SetAsync(tostring(owner),owner)end)
  if not indexed then return nil,'Registro salvo; índice pendente.'end;saved.indexed=true;saved.changed=(saved.changed or 0)+1
 end
 remember(owner);return saved
end
function M.Seed(pl)
 if seeding[pl.UserId]then return end;seeding[pl.UserId]=true
 task.spawn(function()
  local ids={pl.UserId};local ok=pcall(function()
   local p=Players:GetFriendsAsync(pl.UserId)
   repeat for _,v in ipairs(p:GetCurrentPage())do local id=valid(v.Id);if id then ids[#ids+1]=id end end
    if p.IsFinished or #ids>=10001 then break end;p:AdvanceToNextPageAsync();task.wait(.15)
   until false
  end)
  local saved=M.AddSeed(pl.UserId,ids);seeding[pl.UserId]=nil
  if not saved or not ok then task.delay(45,function()if pl.Parent then M.Seed(pl)end end)end
 end)
end
local function checkpoint(job,foreground)
 if(job.changed or 0)==0 then return true end
 local ok,saved=Budget.Run('Write',not foreground,function()return store:UpdateAsync('seed_'..job.owner,function(old)
  if not old then return nil end;old.cursor=math.max(tonumber(old.cursor)or 1,job.cursor);old.meta=old.meta or{}
  for k,v in pairs(job.meta or{})do old.meta[k]=v end;old.indexed=job.indexed or old.indexed;return old
 end)end)
 if ok and saved then job.changed=0;return true end;return false
end
function M.Pump()
 if os.clock()<nextWork then return false end;nextWork=os.clock()+4
 if not Budget.Can('Write',true)or not Budget.Can('Read',true)then return false end
 local chosen
 for _,job in pairs(jobs)do
  if job.cursor>#job.ids and(job.changed or 0)>0 then checkpoint(job)end
  if job.cursor<=#job.ids then chosen=job;break end
 end
 if not chosen and os.clock()>=nextScan then
  readIndex();local visited=0
  while scanAt<=#index.owners and visited<4 do local id=index.owners[scanAt];scanAt=scanAt+1;visited=visited+1;local j=getJob(id,true)
   if j and j.cursor<=#j.ids then chosen=j;break end
  end
  if scanAt>#index.owners then scanAt=1;nextScan=os.clock()+120 end
 end
 if not chosen then return false end
 local id=chosen.ids[chosen.cursor];local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(id)end)
 if not ok or not desc then nextWork=os.clock()+15;chosen.failures=(chosen.failures or 0)+1
  if chosen.failures>=3 then chosen.failures=0;chosen.cursor=chosen.cursor+1;chosen.changed=(chosen.changed or 0)+1 end;return false
 end
 chosen.failures=0;local body=A.Pack(desc);desc:Destroy();local saved=M.Save(id,body,'R15')
 if not saved and #A.Entries(body)>0 then return false end
 if saved then chosen.meta[tostring(id)]={code=saved.code,signature=saved.code,total=saved.total,rig=saved.rig}end
 chosen.cursor=chosen.cursor+1;chosen.changed=(chosen.changed or 0)+1
 if chosen.changed>=16 or chosen.cursor>#chosen.ids then checkpoint(chosen)end;return true
end
function M.BindDescribe(fn)describe=fn end
function M.Page(pl,args)
 local page=tonumber(args.page)or 0;local mode=args.budget or'all';local key=mode..':'..tostring(args.min or'')..':'..tostring(args.max or'')
 local s=sessions[pl]
 if not s or page==0 or s.key~=key then
  local owners={};local seen={};local function add(id)if not seen[id]then seen[id]=true;owners[#owners+1]=id end end
  if jobs[pl.UserId]then add(pl.UserId)end;for id in pairs(jobs)do add(id)end
  readIndex();for _,id in ipairs(index.owners)do add(id)end
  s={key=key,owners=owners,ownerAt=1,seen={},indexCount=#index.owners};sessions[pl]=s
 end
 local out={};local reads,visited=0,0;local waiting=false
 while #out<50 and visited<1000 do
  if not s.job or s.at>#s.job.ids then
   s.job=nil
   if s.ownerAt>#s.owners then
    if not index.complete then readIndex();for i=s.indexCount+1,#index.owners do s.owners[#s.owners+1]=index.owners[i]end;s.indexCount=#index.owners end
    if s.ownerAt>#s.owners then waiting=not index.complete;break end
   end
   local owner=s.owners[s.ownerAt];if not jobs[owner]and reads>=2 then waiting=true;break end
   if not jobs[owner]then reads=reads+1 end
   s.job=getJob(owner,true);if not s.job then waiting=true;break end
   s.ownerAt=s.ownerAt+1;s.at=1
  end
  local id=s.job.ids[s.at];s.at=s.at+1;visited=visited+1
  local meta=(s.job.meta or{})[tostring(id)]or{};local signature=meta.signature;local total=meta.total
  if not s.seen[id]and(not signature or not s.seen[signature])then
   s.seen[id]=true;if signature then s.seen[signature]=true end
   if(mode~='free'or total==0)and(not tonumber(args.min)or total and total>=tonumber(args.min))and(not tonumber(args.max)or total and total<=tonumber(args.max))then
    out[#out+1]={id='roblox:'..id,code='AV-'..string.format('%.0f',id),snapshotCode=meta.code,owner=id,name='Look de jogador',source='Roblox',thumbnail='rbxthumb://type=Avatar&id='..id..'&w=420&h=420',signature=signature,total=total,rig=meta.rig or'R15'}
   end
  end
 end
 return{items=out,finished=not waiting and s.ownerAt>#s.owners and(not s.job or s.at>#s.job.ids),retry=#out==0 and waiting,message='Looks anteriores preservados; a consulta será retomada.'}
end
function M.Start()
 if started then return end;started=true
 Players.PlayerAdded:Connect(M.Seed);for _,pl in ipairs(Players:GetPlayers())do M.Seed(pl)end
 local function step()if not started then return end;local ok,e=pcall(M.Pump);if not ok then warn('[Community V64] '..tostring(e))end;task.delay(4,step)end;task.delay(4,step)
 game:BindToClose(function()started=false;for _,j in pairs(jobs)do if(j.changed or 0)>0 then checkpoint(j,true)end end end)
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
return M
