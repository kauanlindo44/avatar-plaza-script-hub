-- 07K11_GAMES_PROGRESS | ModuleScript | ServerScriptService | V44
-- Só partidas PvP validadas. Treino, carteada irregular e partidas curtas não premiam.
local DS=game:GetService("DataStoreService")
local I=require(script.Parent:WaitForChild("07K8_CARD_INVENTORY"))
local results=DS:GetDataStore("ACP_Results_V44")
local names={};local P={};local event=Instance.new("BindableEvent");P.Completed=event.Event
function P.Week(now)return math.floor(((now or os.time())-345600)/604800)end
local function ranking(game,week)return DS:GetOrderedDataStore("ACP_Rank_V44_"..game.."_"..week)end
function P.TeamKey(a,b)if a>b then a,b=b,a end;return tostring(a)..":"..tostring(b)end
function P.Record(game,id,winners,losers,context)
 context=context or{};if game~="Xadrez"and game~="Damas"and game~="Truco"then return false end
 if #winners==0 or #losers==0 then return false end
 for _,uid in ipairs(winners)do if uid<=0 then return false end end;for _,uid in ipairs(losers)do if uid<=0 then return false end end
 local eligible=not context.training and not context.irregular and(context.duration or 0)>=45 and(context.moves or 0)>=8
 -- Resultados de torneio incluem desistências válidas, mas não moedas nesses casos.
 if context.cup then event:Fire(game,id,winners,losers,context)end
 if not eligible then return false end
 local first=false;local week=P.Week()
 local ok,d=pcall(function()return results:UpdateAsync(id,function(old)
  first=false;if old then return old end;first=true;return {game=game,week=week,winners=winners,losers=losers,awards={},rank=false}
 end)end)
 if not ok or not d then return false end
 -- Ranking usa um recibo por partida no perfil do qualificado; repetir o evento não duplica.
 local key=game=="Truco"and P.TeamKey(winners[1],winners[2])or tostring(winners[1])
 local rankLedger=DS:GetDataStore("ACP_RankLedger_V44_"..game.."_"..week)
 local total
 local saved=pcall(function()local ledger=rankLedger:UpdateAsync(key,function(old)
  old=old or{wins=0,matches={}}
  if not old.matches[id]then old.matches[id]=true;old.wins=old.wins+1 end;return old
 end);total=ledger.wins end)
 if saved then pcall(function()ranking(game,week):UpdateAsync(key,function(old)return math.max(old or 0,total)end)end)end
 for _,uid in ipairs(winners)do I.Reward(uid,id,true,losers)end
 for _,uid in ipairs(losers)do I.Reward(uid,id,false,winners)end
 event:Fire(game,id,winners,losers,context);return true
end
function P.Top(gameName,count,week)
 local ok,pages=pcall(function()return ranking(gameName,week or P.Week()):GetSortedAsync(false,math.clamp(count or 10,1,100))end)
 if not ok then return nil,"Classificação temporariamente indisponível."end
 local rows=pages:GetCurrentPage();local missing={};local seen={}
 for _,r in ipairs(rows)do for uid in tostring(r.key):gmatch("%d+")do uid=tonumber(uid);if not names[uid]and not seen[uid]then missing[#missing+1]=uid;seen[uid]=true end end end
 for offset=1,#missing,100 do local ids={};for i=offset,math.min(#missing,offset+99)do ids[#ids+1]=missing[i]end
  local got,infos=pcall(function()return game:GetService("UserService"):GetUserInfosByUserIdsAsync(ids)end);if got then for _,u in ipairs(infos)do names[u.Id]=u.Username end end
 end
 for _,r in ipairs(rows)do local labels={};for uid in tostring(r.key):gmatch("%d+")do labels[#labels+1]=names[tonumber(uid)]and("@"..names[tonumber(uid)])or"Jogador"end;r.label=table.concat(labels," + ")end
 return rows
end
return P
