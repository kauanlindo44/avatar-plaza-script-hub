-- 07M2_AUDIO_LIBRARY | ModuleScript | ServerScriptService | V61 (NOVO)
-- Busca nativa de músicas do Creator Store; não promete todo áudio nem acesso a privados.
local Assets=game:GetService('AssetService');local Players=game:GetService('Players');local M={}
local sessions={};local defaults={};local cachedAt=-1000;local defaultsFinished=false
local function query(raw)
 local p=Instance.new('AudioSearchParams');p.SearchKeyword=tostring(raw or''):sub(1,80)
 p.AudioSubType=Enum.AudioSubType.Music;if p.SearchKeyword=='lofi'then p.MinDuration=45;p.MaxDuration=600 end
 local ok,pages=pcall(function()return Assets:SearchAudioAsync(p)end);p:Destroy()
 if not ok then return nil,'A biblioteca Roblox não respondeu. Toque em Atualizar.'end;return pages
end
local function read(pages)
 local ok,rows=pcall(function()return pages:GetCurrentPage()end)
 if not ok then return nil,'As músicas não carregaram.'end
 local out,seen={},{};for _,v in ipairs(rows)do local id=tonumber(v.Id or v.AssetId)
  if id and id>0 and not seen[id]and #out<24 then seen[id]=true;out[#out+1]={id=id,name=tostring(v.Title or v.Name or'Áudio Roblox'):sub(1,100),artist=tostring(v.Artist or''):sub(1,80),duration=tonumber(v.Duration)}end
 end;return out
end
function M.Search(pl,args)
 local text=tostring(args.search or''):match('^%s*(.-)%s*$'):sub(1,80);if text==''then text='lofi'end
 local s=sessions[pl]or{};sessions[pl]=s
 if s.busy then return nil,'Sua busca ainda está carregando.'end
 if os.clock()-(s.last or-10)<1 then return nil,'Aguarde um instante para buscar.'end;s.last=os.clock();s.busy=true
 local ok,data,e=pcall(function()
  if text=='lofi'and not args.next and #defaults>0 and os.clock()-cachedAt<600 then s.pages=nil;s.query=text;return{items=table.clone(defaults),finished=defaultsFinished,cached=true}end
  if args.next and s.pages and s.query==text then
   if s.pages.IsFinished then return{items={},finished=true}end;s.pages:AdvanceToNextPageAsync()
  else local pages,why=query(text);if not pages then return nil,why end;s.pages=pages;s.query=text;if args.next and text=='lofi'and #defaults>0 and not pages.IsFinished then pages:AdvanceToNextPageAsync()end end
  local rows,why=read(s.pages);if not rows then return nil,why end
  if text=='lofi'and not args.next then defaults=rows;cachedAt=os.clock();defaultsFinished=s.pages.IsFinished end
  return{items=rows,finished=s.pages.IsFinished,updatedAt=os.time()}
 end);s.busy=false
 if not ok then return nil,'Não foi possível consultar a biblioteca Roblox.'end;return data,e
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
return M
