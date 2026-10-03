-- 07W_WINS_SERVICE
-- ModuleScript | ServerScriptService
-- AVATAR CREATOR PLAZA V24 - vitórias + sequência geral + rankings + Top 3 protegido.
local DS=game:GetService("DataStoreService")
local Players=game:GetService("Players")
local store=DS:GetDataStore("AvatarPlaza_HubStats_V2")
local chessStreakOrder=DS:GetOrderedDataStore("AvatarPlaza_ChessStreak_V2")
local checkStreakOrder=DS:GetOrderedDataStore("AvatarPlaza_CheckersStreak_V2")
local chessWinsOrder=DS:GetOrderedDataStore("AvatarPlaza_ChessWins_V23")
local checkWinsOrder=DS:GetOrderedDataStore("AvatarPlaza_CheckersWins_V23")
local potatoWinsOrder=DS:GetOrderedDataStore("AvatarPlaza_PotatoWins_V23")
local W={};local state={};local startedBoards=false;local nameCache={};local rankTokens={}
local function fresh()return{total=0,streak=0,bestStreak=0,chessWins=0,chessStreak=0,chessBest=0,checkWins=0,checkStreak=0,checkBest=0,potatoWins=0,fashionWins=0}end
local function clean(v)local d=fresh();if type(v)=="table"then for k in pairs(d)do d[k]=math.max(0,math.floor(tonumber(v[k])or 0))end elseif type(v)=="number"then d.total=math.max(0,math.floor(v))end;return d end
local function leader(pl)local f=pl:FindFirstChild("leaderstats")or Instance.new("Folder");f.Name="leaderstats";f.Parent=pl;local wins=f:FindFirstChild("Vitorias")or Instance.new("IntValue");wins.Name="Vitorias";wins.Parent=f;return wins end
local function attrs(pl,d)leader(pl).Value=d.total;pl:SetAttribute("HubWins",d.total);pl:SetAttribute("HubStreak",d.streak);pl:SetAttribute("HubBestStreak",d.bestStreak);pl:SetAttribute("ChessWins",d.chessWins);pl:SetAttribute("ChessStreak",d.chessStreak);pl:SetAttribute("ChessBestStreak",d.chessBest);pl:SetAttribute("CheckersWins",d.checkWins);pl:SetAttribute("CheckersStreak",d.checkStreak);pl:SetAttribute("CheckersBestStreak",d.checkBest);pl:SetAttribute("PotatoWins",d.potatoWins);pl:SetAttribute("FashionWins",d.fashionWins)end
local function setOrders(pl,d)pcall(function()chessWinsOrder:SetAsync(tostring(pl.UserId),d.chessWins)end);pcall(function()checkWinsOrder:SetAsync(tostring(pl.UserId),d.checkWins)end);pcall(function()potatoWinsOrder:SetAsync(tostring(pl.UserId),d.potatoWins)end)end
local function load(pl)if state[pl]then return state[pl]end;local ok,v=pcall(function()return store:GetAsync("u_"..pl.UserId)end);local d=ok and clean(v)or fresh();state[pl]=d;attrs(pl,d);pl:SetAttribute("WinsPersistent",ok);if ok then task.spawn(setOrders,pl,d)end;return d end
local function save(pl)local d=state[pl];if not d or pl:GetAttribute("WinsPersistent")~=true then return false end;local copy=clean(d);local ok=pcall(function()store:SetAsync("u_"..pl.UserId,copy)end);if ok then setOrders(pl,copy)end;return ok end
local function mutate(pl,fn)if not pl or pl.Parent~=Players then return end;local d=load(pl);fn(d);attrs(pl,d);task.spawn(save,pl);return d end
function W.Get(pl)return load(pl)end
function W.AddWin(pl,source)local src=string.lower(tostring(source or""));local d=mutate(pl,function(x)x.total=x.total+1;x.streak=x.streak+1;x.bestStreak=math.max(x.bestStreak,x.streak);if src:find("batata",1,true)then x.potatoWins=x.potatoWins+1 elseif src:find("fashion",1,true)then x.fashionWins=x.fashionWins+1 elseif src:find("xadrez",1,true)then x.chessWins=x.chessWins+1 elseif src:find("dama",1,true)then x.checkWins=x.checkWins+1 end end);if pl then pl:SetAttribute("LastWinSource",tostring(source or"Desafio"))end;return d and d.total or 0 end
function W.RecordLoss(pl)if pl and pl.Parent==Players then mutate(pl,function(x)x.streak=0 end)end end
function W.RecordMatch(game,winner,loser,context)
 if context and winner and loser then task.spawn(function()local m=script.Parent:FindFirstChild("07K11_GAMES_PROGRESS");if m then require(m).Record(game,context.id,{winner.UserId},{loser.UserId},context)end end)end
 if game~="Xadrez"and game~="Damas"then return end
 if winner and winner.Parent==Players then local d=mutate(winner,function(x)x.total=x.total+1;x.streak=x.streak+1;x.bestStreak=math.max(x.bestStreak,x.streak);if game=="Xadrez"then x.chessWins=x.chessWins+1;x.chessStreak=x.chessStreak+1;x.chessBest=math.max(x.chessBest,x.chessStreak)else x.checkWins=x.checkWins+1;x.checkStreak=x.checkStreak+1;x.checkBest=math.max(x.checkBest,x.checkStreak)end end);if game=="Xadrez"then pcall(function()chessStreakOrder:SetAsync(tostring(winner.UserId),d.chessStreak)end)else pcall(function()checkStreakOrder:SetAsync(tostring(winner.UserId),d.checkStreak)end)end;winner:SetAttribute("LastWinSource",game)end
 if loser and loser~=winner and loser.Parent==Players then local d=mutate(loser,function(x)x.streak=0;if game=="Xadrez"then x.chessStreak=0 else x.checkStreak=0 end end);if game=="Xadrez"then pcall(function()chessStreakOrder:SetAsync(tostring(loser.UserId),d.chessStreak)end)else pcall(function()checkStreakOrder:SetAsync(tostring(loser.UserId),d.checkStreak)end)end end
end

function W.SetupPlayer(pl)load(pl)end
local function userName(uid)if nameCache[uid]then return nameCache[uid]end;local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);n=ok and n or("User"..uid);nameCache[uid]=n;return n end
local function district()local world=workspace:FindFirstChild("PracaAvatar_V2");return world and world:FindFirstChild("ChallengeDistrict")end
local function zoneFor(name)local d=district();if not d then return nil end;if name=="ChessStreakBoard"then return d:FindFirstChild("Xadrez")elseif name=="CheckersStreakBoard"then return d:FindFirstChild("Damas")else return d:FindFirstChild("Batata")end end
local function boardLabel(name)local z=zoneFor(name);local b=z and z:FindFirstChild(name);local g=b and b:FindFirstChild("LeaderboardGui");return g and g:FindFirstChild("Entries")end
local function readOrder(order,limit)local ok,p=pcall(function()return order:GetSortedAsync(false,limit or 8)end);if not ok or not p then return nil end;local out={};for _,e in ipairs(p:GetCurrentPage())do local uid=tonumber(e.key);local wins=math.floor(tonumber(e.value)or 0);if uid and wins>0 then table.insert(out,{uid=uid,wins=wins})end end;return out end
local function renderBoard(order,name)local label=boardLabel(name);if not label then return end;local entries=readOrder(order,8);if not entries then label.Text="Ranking indisponível no teste.";return end;local lines={};for rank,e in ipairs(entries)do table.insert(lines,string.format("%d. @%s  •  %d vitórias",rank,userName(e.uid),e.wins))end;label.Text=#lines>0 and table.concat(lines,"\n")or"Sem vitórias registradas ainda.\nVença para aparecer aqui." end
local function token(folder,rank)local t=rankTokens[folder];if not t then t={};rankTokens[folder]=t end;t[rank]=(t[rank]or 0)+1;return t[rank]end
local function validToken(folder,rank,n)return folder.Parent~=nil and rankTokens[folder]and rankTokens[folder][rank]==n end
local function labelFor(folder,rank)local a=folder:FindFirstChild("Rank"..rank.."Anchor");local g=a and a:FindFirstChild("RankLabel");return a,g and g:FindFirstChildOfClass("TextLabel")end
local function destroyRank(folder,rank)for _,v in ipairs(folder:GetChildren())do if v.Name=="Rank"..rank.."Avatar"then v:Destroy()end end end
local function clearRank(folder,rank)local n=token(folder,rank);destroyRank(folder,rank);local _,label=labelFor(folder,rank);if label then label.Text="#"..rank.." • aguardando ranking"end;return n end
local function mountRank(folder,rank,uid,wins)
 local anchor,label=labelFor(folder,rank);if not anchor then return end;local mine=token(folder,rank);destroyRank(folder,rank);local uname=userName(uid);if label then label.Text="#"..rank.." • @"..uname.."\n"..wins.." vitórias\ncarregando avatar..."end
 task.spawn(function()
  local ok,model=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
  if not validToken(folder,rank,mine)then if ok and model then model:Destroy()end return end
  if not ok or not model then if label and label.Parent then label.Text="#"..rank.." • @"..uname.."\n"..wins.." vitórias\navatar indisponível"end;return end
  model.Name="Rank"..rank.."Avatar";for _,v in ipairs(model:GetDescendants())do if v:IsA("BasePart")then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false elseif v:IsA("Script")or v:IsA("LocalScript")then v:Destroy()end end
  if not validToken(folder,rank,mine)then model:Destroy();return end;model.Parent=folder
  local cf,size=model:GetBoundingBox();local pivot=model:GetPivot();local feetOffset=math.max(1,pivot.Position.Y-(cf.Position.Y-size.Y/2));model:PivotTo(CFrame.new(anchor.Position+Vector3.new(0,feetOffset,0))*CFrame.Angles(0,math.pi,0))
  if label and label.Parent and validToken(folder,rank,mine)then label.Text="#"..rank.." • @"..uname.."\n"..wins.." vitórias"end
 end)
end
local function renderTop3(order,zoneName)local d=district();local z=d and d:FindFirstChild(zoneName);local folder=z and z:FindFirstChild("Top3Display");if not folder then return end;local entries=readOrder(order,3);if not entries then for rank=1,3 do clearRank(folder,rank)end;return end;for rank=1,3 do local e=entries[rank];if e then mountRank(folder,rank,e.uid,e.wins)else clearRank(folder,rank)end end end
local function refreshAll()renderBoard(chessWinsOrder,"ChessStreakBoard");renderBoard(checkWinsOrder,"CheckersStreakBoard");renderBoard(potatoWinsOrder,"PoisonPotatoBoard");renderTop3(chessWinsOrder,"Xadrez");renderTop3(checkWinsOrder,"Damas");renderTop3(potatoWinsOrder,"Batata")end
local function startBoards()if startedBoards then return end;startedBoards=true;task.spawn(function()task.wait(5);while true do refreshAll();task.wait(60)end end)end
Players.PlayerAdded:Connect(load);for _,p in ipairs(Players:GetPlayers())do task.spawn(load,p)end
Players.PlayerRemoving:Connect(function(p)save(p);state[p]=nil end);game:BindToClose(function()for p in pairs(state)do save(p)end end);startBoards()
return W
