-- 09B9_GLOBAL_LOOKS | ModuleScript | ServerScriptService | V61 (NOVO)
-- Descoberta pública persistente; fila retoma snapshots, sem carregar tudo no cliente.
local DS=game:GetService('DataStoreService');local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Http=game:GetService('HttpService')
local store=DS:GetDataStore('ACP_GlobalLooks_V61');local seeds=DS:GetOrderedDataStore('ACP_GlobalLookSeeds_V61')
local M={};local sessions,jobs,cache,seeding={},{},{},{};local started=false;local describe;local nextWrite=0;local pumpPages,pumpRows,pumpAt
local function valid(n)n=tonumber(n);return n and n==n and n%1==0 and n>1 and n<9007199254740991 and n end
local function canonical(t)
 if type(t)~='table'then return type(t)..':'..tostring(t)end
 local keys={};for k in pairs(t)do keys[#keys+1]=k end;table.sort(keys,function(a,b)return tostring(a)<tostring(b)end)
 local out={};for _,k in ipairs(keys)do out[#out+1]=tostring(k)..'='..canonical(t[k])end;return '{'..table.concat(out,';')..'}'
end
function M.Code(body)
 local b=A.Copy(body);b.emotes={};for key in pairs(b.props)do if key:find('Animation',1,true)then b.props[key]=nil end end
 table.sort(b.accessories,function(a,b)return a.id==b.id and tostring(a.type)<tostring(b.type)or a.id<b.id end)
 local text=canonical(b);local x,y=5381,7919
 for i=1,#text do local byte=text:byte(i);x=(x*65599+byte)%2147483647;y=(y*48271+byte)%2147483629 end
 return string.format('LK-%08X%08X',x,y),text
end
function M.Save(owner,body,rig)
 local clean,why=A.Clean(body);if not clean then return nil,why end
 if #A.Entries(clean)==0 then return nil,'Avatar sem itens verificáveis.'end
 local code,signature=M.Code(clean);local record={id=code,code=code,owner=owner,name='Look de jogador',body=clean,rig=rig or'R15',source='Archive',signature=signature,checkedAt=os.time()}
 if describe then local ok,value=pcall(describe,record);if ok and value then record=value end end
 local ok,saved=pcall(function()return store:UpdateAsync('look_'..code,function(old)
  if old then if old.signature~=signature then error('Colisão de código; aparência anterior preservada.')end;old.total=record.total;old.budget=record.budget;old.priceCheckedAt=os.time();return old end
  return record
 end)end)
 if not ok or not saved then return nil,'A gravação global não confirmou. A fila tentará novamente.'end
 cache[code]=saved;return A.Copy(saved)
end
function M.Get(code)
 if type(code)~='string'or not code:match('^LK%-%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$')then return nil,'Código inválido.'end
 if cache[code]then return A.Copy(cache[code])end
 local ok,r=pcall(function()return store:GetAsync('look_'..code)end)
 if not ok then return nil,'O arquivo de looks não respondeu.'end;if not r then return nil,'Código não encontrado.'end;cache[code]=r;return A.Copy(r)
end
function M.AddSeed(owner,ids)
 local now=os.time();local ok,saved=pcall(function()return store:UpdateAsync('seed_'..owner,function(old)
  old=type(old)=='table'and old or{ids={},cursor=1,meta={}};old.ids=old.ids or{};old.meta=old.meta or{};local seen={}
  for _,id in ipairs(old.ids)do seen[id]=true end
  for _,id in ipairs(ids)do id=valid(id);if id and not seen[id]and #old.ids<10001 then seen[id]=true;old.ids[#old.ids+1]=id end end
  old.updatedAt=now;old.owner=owner;return old
 end)end)
 if not ok or not saved then return nil,'Os jogadores descobertos ainda não foram registrados.'end
 local indexed=pcall(function()seeds:SetAsync(tostring(owner),owner)end)
 if not indexed then return nil,'Registro salvo; o índice global ainda precisa de recuperação.'end
 jobs[owner]=saved;return saved
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
  local saved,e=M.AddSeed(pl.UserId,ids);seeding[pl.UserId]=nil
  if not saved then warn('[Community V61] registro pendente: '..tostring(e));task.delay(30,function()if pl.Parent then M.Seed(pl)end end)
  elseif not ok then task.delay(30,function()if pl.Parent then M.Seed(pl)end end)end
 end)
end
local function checkpoint(job)
 local ok,saved=pcall(function()return store:UpdateAsync('seed_'..job.owner,function(old)
  if not old then return nil end
  old.cursor=math.max(tonumber(old.cursor)or 1,job.cursor);old.meta=old.meta or{}
  for k,v in pairs(job.meta or{})do old.meta[k]=v end;return old
 end)end)
 if ok and saved then job.changed=0;return true end;return false
end
local function trimJobs(keep)
 local count=0;for _ in pairs(jobs)do count=count+1 end
 if count<=32 then return end
 for owner,job in pairs(jobs)do if count>32 and job~=keep and((job.changed or 0)==0 or checkpoint(job))then jobs[owner]=nil;count=count-1 end end
end
function M.Pump()
 if os.clock()<nextWrite then return false end;nextWrite=os.clock()+3
 trimJobs()
 local chosen;for _,job in pairs(jobs)do if job.cursor<=#job.ids then chosen=job;break end end
 if not chosen then
  local reads,visited=0,0
  while reads<3 and visited<50 and not chosen do
   if not pumpRows or pumpAt>#pumpRows then
    local ok,rows=pcall(function()
     if not pumpPages or pumpPages.IsFinished then pumpPages=seeds:GetSortedAsync(true,50)else pumpPages:AdvanceToNextPageAsync()end
     return pumpPages:GetCurrentPage()
    end)
    if not ok or #rows==0 then pumpRows=nil;break end;pumpRows=rows;pumpAt=1
   end
   local row=pumpRows[pumpAt];pumpAt=pumpAt+1;visited=visited+1;local id=valid(row.key);local job=id and jobs[id]
   if id and not job then reads=reads+1;local ok,value=pcall(function()return store:GetAsync('seed_'..id)end);if ok then job=value;jobs[id]=job end end
   if job and job.cursor<=#job.ids then chosen=job end
  end
  trimJobs(chosen)
 end
 if not chosen then return false end
 local id=chosen.ids[chosen.cursor];local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(id)end)
 if not ok or not desc then
  local errorText=tostring(desc):lower();if errorText:find('429',1,true)or errorText:find('503',1,true)then nextWrite=os.clock()+30;return false end
  chosen.failures=(chosen.failures or 0)+1;if chosen.failures>=3 then chosen.failures=0;chosen.cursor=chosen.cursor+1;checkpoint(chosen)end;return false
 end;chosen.failures=0
 local body=A.Pack(desc);desc:Destroy();local saved,e=M.Save(id,body,'R15')
 if not saved then if #A.Entries(body)>0 then return false end else chosen.meta[tostring(id)]={code=saved.code,signature=saved.code,total=saved.total,rig=saved.rig}end
 chosen.cursor=chosen.cursor+1;chosen.changed=(chosen.changed or 0)+1
 if chosen.changed>=8 or chosen.cursor>#chosen.ids then checkpoint(chosen)end
 if chosen.cursor>#chosen.ids and not Players:GetPlayerByUserId(chosen.owner)then jobs[chosen.owner]=nil end
 local count=0;for _ in pairs(cache)do count=count+1 end;if count>512 then cache={}end
 return true
end
function M.BindDescribe(fn)describe=fn end
function M.Page(pl,args)
 local index=tonumber(args.page)or 0;local mode=args.budget or'all';local key=mode..':'..tostring(args.min or'')..':'..tostring(args.max or'')
 local s=sessions[pl]
 if not s or index==0 or s.key~=key then
  local ok,p=pcall(function()return seeds:GetSortedAsync(true,50)end)
  s={key=key,pages=ok and p or nil,seen={},finished=not ok,localSeed=jobs[pl.UserId]};sessions[pl]=s
 end
 local out={};local reads=0;local visited=0
 local function nextSeed()
  if s.localSeed then local job=s.localSeed;s.localSeed=nil;return job end
  while reads<3 do
   if not s.seedRows or s.rowAt>#s.seedRows then
    if s.pageDone or not s.pages then s.finished=true;return nil end
    if s.seedRows then s.pages:AdvanceToNextPageAsync()end
    s.seedRows=s.pages:GetCurrentPage();s.rowAt=1;s.pageDone=s.pages.IsFinished
    if #s.seedRows==0 then s.finished=true;return nil end
   end
   local row=s.seedRows[s.rowAt];s.rowAt=s.rowAt+1;local owner=valid(row.key);local job=owner and jobs[owner]
   if not job and owner then reads=reads+1;local ok,value=pcall(function()return store:GetAsync('seed_'..owner)end);if ok then job=value end end
   if job then return job end
  end
 end
 while #out<45 and visited<1000 do
  if not s.job or s.at>#s.job.ids then s.job=nextSeed();s.at=1;if not s.job then break end end
  local id=s.job.ids[s.at];s.at=s.at+1;visited=visited+1
  local meta=(s.job.meta or{})[tostring(id)]or{};local signature=meta.signature
  if not s.seen[id]and(not signature or not s.seen[signature])then
   s.seen[id]=true;if signature then s.seen[signature]=true end
   local total=meta.total
   local accepts=(mode~='free'or total==0)and(not tonumber(args.min)or total and total>=tonumber(args.min))and(not tonumber(args.max)or total and total<=tonumber(args.max))
   if accepts then out[#out+1]={id='roblox:'..id,code='AV-'..string.format('%.0f',id),snapshotCode=meta.code,owner=id,name='Look de jogador',source='Roblox',thumbnail='rbxthumb://type=Avatar&id='..id..'&w=420&h=420',signature=signature,total=total,rig=meta.rig or'R15'}end
  end
 end
 return{items=out,finished=s.finished and(not s.job or s.at>#s.job.ids),retry=#out==0 and not s.finished,message='As aparências e os preços estão sendo verificados em segundo plano.'}
end
function M.Start()
 if started then return end;started=true
 Players.PlayerAdded:Connect(M.Seed);for _,pl in ipairs(Players:GetPlayers())do M.Seed(pl)end
 local function step()if not started then return end;pcall(M.Pump);task.delay(3,step)end;task.delay(3,step)
 game:BindToClose(function()started=false;for _,job in pairs(jobs)do if(job.changed or 0)>0 then checkpoint(job)end end end)
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
return M
