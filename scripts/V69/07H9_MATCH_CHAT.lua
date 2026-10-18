-- 07H9_MATCH_CHAT | ModuleScript | ServerScriptService | V69 (NOVO)
-- O servidor define participantes. Texto nunca passa por RemoteEvent/RemoteFunction.
local Players=game:GetService('Players');local Chat=game:GetService('TextChatService')
local Http=game:GetService('HttpService');local M={Version='V69'};local sessions={};local byPlayer={}
local function state(pl,name,status)
 if pl.Parent==Players then pl:SetAttribute('ACP_MatchChat',name);pl:SetAttribute('ACP_MatchChatStatus',status)end
end
local function folder()
 local f=Chat:FindFirstChild('TextChannels')
 if not f then f=Instance.new('Folder');f.Name='TextChannels';f.Parent=Chat end;return f
end
function M.Close(key)
 local s=sessions[key];if not s then return end;sessions[key]=nil;s.closed=true
 for uid,pl in pairs(s.members)do if byPlayer[uid]==s then byPlayer[uid]=nil;state(pl,nil,'A conversa desta partida terminou.')end end
 if s.channel then s.channel:Destroy()end
end
function M.Remove(pl)
 local s=byPlayer[pl.UserId];if not s then return end
 byPlayer[pl.UserId]=nil;s.members[pl.UserId]=nil;state(pl,nil,'Você saiu da conversa da partida.')
 if s.channel then for _,source in ipairs(s.channel:GetChildren())do if source:IsA('TextSource')and source.UserId==pl.UserId then source:Destroy()end end end
 if not next(s.members)then M.Close(s.key)end
end
function M.Open(key,gameName,participants)
 key=tostring(key);if sessions[key]then return sessions[key].name end
 local members,list={},{}
 for _,pl in pairs(participants or{})do if typeof(pl)=='Instance'and pl:IsA('Player')and pl.Parent==Players and pl.UserId>0 and not members[pl.UserId]then
  members[pl.UserId]=pl;list[#list+1]=pl
 end end
 if #list<2 then for _,pl in ipairs(list)do M.Remove(pl);state(pl,nil,'Conversa disponível em partidas com outros jogadores.')end;return nil end
 local name='ACP_Match_'..Http:GenerateGUID(false):gsub('[^%w]','')
 local s={key=key,name=name,members=members,closed=false,game=gameName};sessions[key]=s
 local channel=Instance.new('TextChannel');channel.Name=name;channel:SetAttribute('ACP_PrivateMatch',true);channel:SetAttribute('ACP_Game',gameName);channel.Parent=folder();s.channel=channel
 channel.ShouldDeliverCallback=function(message,receiver)
  -- Nunca espera/yield: o próprio TextChannel verifica bloqueios, privacidade e filtragem.
  local sender=message.TextSource
  if s.closed or sessions[key]~=s or not sender or not receiver then return false end
  local a,b=s.members[sender.UserId],s.members[receiver.UserId]
  return a~=nil and b~=nil and a.Parent==Players and b.Parent==Players and byPlayer[a.UserId]==s and byPlayer[b.UserId]==s
 end
 for _,pl in ipairs(list)do M.Remove(pl);byPlayer[pl.UserId]=s;state(pl,name,'Conectando à conversa privada…')end
 task.spawn(function()
  local host=list[1];local ids={};for i=2,#list do ids[#ids+1]=list[i].UserId end
  local ok,eligible=pcall(function()
   if not Chat:CanUserChatAsync(host.UserId)then return{}end
   return Chat:CanUsersDirectChatAsync(host.UserId,ids)
  end)
  if s.closed or sessions[key]~=s then return end
  if not ok or type(eligible)~='table'or #eligible==0 then
   for _,pl in pairs(s.members)do state(pl,name,'Comunicação indisponível pelas permissões do Roblox.')end;return
  end
  local allowed={[host.UserId]=true};for _,uid in ipairs(eligible)do uid=tonumber(uid);if uid and members[uid]then allowed[uid]=true end end
  local marked=pcall(function()channel:SetDirectChatRequester(host)end)
  if not marked then for _,pl in pairs(s.members)do state(pl,name,'O Roblox não liberou esta conversa privada.')end;return end
  for _,pl in ipairs(list)do
   if s.closed or sessions[key]~=s then return end
   if s.members[pl.UserId]==pl and byPlayer[pl.UserId]==s and allowed[pl.UserId]then
    local added,source=pcall(function()
     if not Chat:CanUserChatAsync(pl.UserId)then return nil end
     for _,old in ipairs(channel:GetChildren())do if old:IsA('TextSource')and old.UserId==pl.UserId then return old end end
     return channel:AddUserAsync(pl.UserId)
    end)
    if s.closed or s.members[pl.UserId]~=pl or byPlayer[pl.UserId]~=s then if source and source.Parent then source:Destroy()end
    elseif added and source then state(pl,name,'Somente participantes desta partida · filtrado pelo Roblox')
    else state(pl,name,'O Roblox não liberou o envio para sua conta.')end
   elseif byPlayer[pl.UserId]==s then state(pl,name,'Suas permissões não permitem conversar com esta mesa.')end
  end
 end)
 return name
end
Players.PlayerRemoving:Connect(M.Remove)
return M
