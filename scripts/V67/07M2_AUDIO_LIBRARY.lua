-- 07M2_AUDIO_LIBRARY | ModuleScript | ServerScriptService | V67 (SUBSTITUIR)
-- Cache compartilhado e busca fora do RPC: áudio/ID não espera DataStore ou pesquisa.
local Assets=game:GetService('AssetService');local Players=game:GetService('Players');local M={Version='V67'}
local sessions,queries,metadata={},{},{};local active=0;local nextNative=0
M.Changed=Instance.new('BindableEvent')
local function clean(raw)local s=tostring(raw or''):match('^%s*(.-)%s*$'):sub(1,80);return s==''and'calm piano'or s end
local function read(pages)
 local out,seen={},{};for _,v in ipairs(pages:GetCurrentPage()or{})do local id=tonumber(v.Id or v.AssetId)
  if id and id>0 and id%1==0 and not seen[id]and #out<24 then seen[id]=true;local r={id=id,name=tostring(v.Title or v.Name or'Áudio Roblox'):sub(1,100),artist=tostring(v.Artist or''):sub(1,80),duration=tonumber(v.Duration)};out[#out+1]=r;metadata[id]=r;local n=0;for _ in pairs(metadata)do n=n+1 end;if n>512 then for key in pairs(metadata)do if key~=id then metadata[key]=nil;break end end end end
 end;return out
end
local function work(q)
 if q.busy or active>=2 or os.clock()<(q.retryAt or 0)then return end
 q.busy=true;q.generation=(q.generation or 0)+1;local gen=q.generation;active=active+1;local settled=false
 local function finish(err)
  if settled then return end;settled=true;active=math.max(0,active-1);q.busy=false
  if err then q.error='Biblioteca indisponível agora. ID/link continua funcionando.';q.retryAt=os.clock()+30;warn('[Music V62] SEARCH '..tostring(err))else q.error=nil;q.at=os.clock()end
  M.Changed:Fire(q.query)
 end
 task.delay(10,function()if not settled then q.generation=q.generation+1;finish('SEARCH_TIMEOUT')end end)
 task.spawn(function()
  local ok,e=pcall(function()
   local delay=nextNative-os.clock();if delay>0 then task.wait(delay)end;nextNative=os.clock()+1.2
   if gen~=q.generation then return end
   if not q.pages then
    local p=Instance.new('AudioSearchParams');p.SearchKeyword=q.query;p.AudioSubType=Enum.AudioSubType.Music
    local got,value=pcall(function()return Assets:SearchAudioAsync(p)end);p:Destroy();if not got then error(value,0)end
    if gen~=q.generation then return end;q.pages=value;q.page=1
   elseif q.page<q.wanted and not q.pages.IsFinished then q.pages:AdvanceToNextPageAsync();if gen~=q.generation then return end;q.page=q.page+1 end
   q.cache[q.page]={items=read(q.pages),finished=q.pages.IsFinished};q.finished=q.pages.IsFinished
  end)
  if gen~=q.generation then return end;finish(not ok and e or nil)
  if ok and q.page<q.wanted and not q.finished then task.delay(1.3,function()work(q)end)end
 end)
end
function M.Search(pl,args)
 args=type(args)=='table'and args or{};local text=clean(args.search);local s=sessions[pl]or{};sessions[pl]=s
 if s.query~=text then s.query=text;s.page=1 elseif args.next==true and not s.pending then s.page=(s.page or 1)+1 end
 local q=queries[text]
 if not q then
  local count=0;for _ in pairs(queries)do count=count+1 end
  if count>=16 then for k,v in pairs(queries)do if not v.busy then queries[k]=nil;break end end end
  q={query=text,cache={},wanted=1,at=os.clock()};queries[text]=q
 end
 if args.reload==true and os.clock()-(q.reloadedAt or -100)>10 and not q.busy then q.reloadedAt=os.clock();q.retryAt=0;q.error=nil;q.pages=nil;q.page=nil;q.finished=false;q.cache={};q.wanted=1;s.page=1 end
 local page=s.page or 1;local value=q.cache[page]
 if value then
  if page==1 and os.clock()-q.at>=600 and not q.busy then q.pages=nil;q.page=nil;q.finished=false;q.wanted=1;work(q)end
  s.pending=false;return{items=table.clone(value.items),finished=value.finished,cached=true,refreshing=q.busy,error=q.error,query=text,page=page,version=M.Version}
 end
 if q.finished and page>(q.page or 0)then s.pending=false;return{items={},finished=true,query=text,page=page}end
 if q.error and os.clock()<(q.retryAt or 0)then s.pending=false;return nil,q.error end
 q.wanted=math.max(q.wanted,page);s.pending=true;work(q)
 return{items={},pending=true,finished=false,query=text,page=page,version=M.Version}
end
function M.Metadata(id)local r=metadata[tonumber(id)];return r and table.clone(r)end
function M.Warm()
 local q=queries['calm piano'];if not q or(not q.busy and os.clock()-q.at>600)then queries['calm piano']={query='calm piano',cache={},wanted=1,at=os.clock()};q=queries['calm piano'] end;work(q)
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
task.defer(M.Warm)
return M
