-- 09B1_AVATAR_DISCOVERY | ModuleScript | ServerScriptService | V48
-- Descricoes reais; nomes opcionais, cache e limite conservador de UserService.
local Players=game:GetService("Players")
local Users=game:GetService("UserService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Cosplay=require(script.Parent:WaitForChild("09B2_COSPLAY_METADATA"))
local M={PageSize=32,MaxPages=20000,Curator="CAETANOYX"}
local pages,avatars,perPlayer={},{},{}
local pageOrder,avatarOrder={},{}
local tokens,refill=100,os.clock();local names,nameOrder,friendCache,friendOrder={},{},{},{};local inFlight=0
local nameWindow,nameCount,nameCooldown= os.clock(),0,0;local nameBusy=false
local function uid(v)local n=tonumber(v);return n and n==n and n>1 and n<=9007199254740991 and n%1==0 and n or nil end
local function trim(v)return tostring(v or""):match("^%s*(.-)%s*$"):gsub("^@",""):sub(1,40)end
local function reserve()
 local deadline=os.clock()+4
 repeat
  local now=os.clock();tokens=math.min(100,tokens+(now-refill)*2);refill=now
  if tokens>=1 then tokens=tokens-1;return true end
  task.wait(.15)
 until os.clock()>=deadline
 return false
end
local function cachePut(cache,order,key,value,max)
 if not cache[key]then table.insert(order,key)end;cache[key]={value=value,at=os.clock()}
 while #order>max do cache[table.remove(order,1)]=nil end
end
local function get(cache,key,ttl)local e=cache[key];return e and os.clock()-e.at<ttl and e.value or nil end
local function remember(id,name)
 if uid(id)and type(name)=="string"and name~=""then cachePut(names,nameOrder,id,name,800)end
end
local function friends(seed,page)
 local key=seed..":"..page;local old=get(friendCache,key,240);if old then return old end
 local ok,rows=pcall(function()
  local list=Players:GetFriendsAsync(seed)
  for _=1,math.min(page,4)do if list.IsFinished then return{}end;list:AdvanceToNextPageAsync()end
  return list:GetCurrentPage()
 end)
 local ids={}
 if ok and type(rows)=="table"then for _,r in ipairs(rows)do local id=uid(r.Id);if id then table.insert(ids,id);remember(id,r.Username)end end end
 if ok then cachePut(friendCache,friendOrder,key,ids,40)elseif friendCache[key]then return friendCache[key].value end
 return ids
end
local function authorize(pl,id)
 local p=perPlayer[pl];if not p then p={ids={},order={},last=-100};perPlayer[pl]=p end
 if not p.ids[id]then p.ids[id]=true;table.insert(p.order,id)end
 while #p.order>800 do p.ids[table.remove(p.order,1)]=nil end
end
local function lookup(ids)
 local now=os.clock();if now-nameWindow>=60 then nameWindow=now;nameCount=0 end
 local missing={};local seen={}
 for _,id in ipairs(ids)do if not get(names,id,600)and not seen[id]and #missing<32 then seen[id]=true;table.insert(missing,id)end end
 if #missing==0 then return false end
 -- Roblox documenta 250 resultados/minuto. Reservamos no maximo 180 IDs/minuto.
 if nameBusy or now<nameCooldown or nameCount+#missing>180 then return true end
 nameBusy=true;nameCount=nameCount+#missing
 local ok,rows=pcall(function()return Users:GetUserInfosByUserIdsAsync(missing)end);nameBusy=false
 if ok and type(rows)=="table"then for _,r in ipairs(rows)do remember(r.Id,r.Username)end;return false end
 nameCooldown=now+60;return true
end
function M.Page(pl,args)
 args=type(args)=="table"and args or{};local index=tonumber(args.page)or 0
 if index~=index or index%1~=0 or index<0 or index>=M.MaxPages then error("Página inválida.",0)end
 local query=trim(args.search);local key=index..":"..query:lower()..(query==""and(":"..pl.UserId)or"")
 local cached=get(pages,key,240)
 if cached then for _,r in ipairs(cached.items)do authorize(pl,r.owner)end;return A.Copy(cached)end
 local p=perPlayer[pl]or{ids={},order={},last=-100};perPlayer[pl]=p
 if os.clock()-p.last<.45 then task.wait(.45-(os.clock()-p.last))end;p.last=os.clock()
 local ids,seen={},{}
 local function add(id)id=uid(id);if id and not seen[id]and #ids<M.PageSize then seen[id]=true;table.insert(ids,id)end end
 if query~=""then
  if index>0 then return{items={},finished=true}end
  local id=uid(query)
  if not id then local ok,n=pcall(function()return Players:GetUserIdFromNameAsync(query)end);if not ok then error("Usuário não encontrado. Use o @ ou ID do Roblox.",0)end;id=uid(n);remember(id,query)end
  if not id then error("Use o @ ou ID de um jogador.",0)end;add(id)
 else
  if index==0 then
   add(pl.UserId);remember(pl.UserId,pl.Name)
   for _,player in ipairs(Players:GetPlayers())do add(player.UserId);remember(player.UserId,player.Name)end
  end
  local roots=friends(pl.UserId,0);local branch=index%3
  local seed=branch==0 and pl.UserId or branch==1 and 4129514489 or roots[math.floor(index/3)%math.max(1,#roots)+1]or pl.UserId
  for _,id in ipairs(friends(seed,math.floor(index/3)%5))do add(id)end
  local start=index*80;for i=1,80 do add(1000000+((start+i)*4001+19876319)%4000000000)end
 end
 local degraded=lookup(ids);local out={}
 for _,id in ipairs(ids)do
  local name=get(names,id,600)
  if name~="Roblox"then
   authorize(pl,id);table.insert(out,{id="roblox:"..id,owner=id,sourceUsername=name,username=M.Curator,publisher=M.Curator,name="Look de jogador",rig="R15",source="Roblox",thumbnail="rbxthumb://type=Avatar&id="..id.."&w=420&h=420"})
  end
 end
 local result={items=out,finished=query~=""or index==M.MaxPages-1,page=index,degraded=degraded}
 cachePut(pages,pageOrder,key,result,96);return A.Copy(result)
end
function M.Load(pl,args)
 local id=uid(args.id);local p=perPlayer[pl]
 if not id or not p or not p.ids[id]then error("Reabra esse look na Comunidade para carregar o avatar.",0)end
 local cached=get(avatars,id,90);if cached then return A.Copy(cached)end
 while inFlight>=4 do task.wait(.04)end
 if not reserve()then error("A Comunidade está ocupada. Tente novamente em instantes.",0)end
 inFlight=inFlight+1
 local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(id)end)
 if not ok then
  local err=tostring(desc):lower();local temporary=err:find("429",1,true)or err:find("503",1,true)or err:find("timeout",1,true)or err:find("timed out",1,true)or err:find("too many",1,true)
  if temporary then task.wait(.8+(id%5)*.15);ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(id)end)end
 end
 if not ok or not desc then
  local player=Players:GetPlayerByUserId(id);local hum=player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if hum then ok,desc=pcall(function()return hum:GetAppliedDescription()end)end
 end
 inFlight=inFlight-1
 if not ok or not desc then error("Esse avatar não está disponível no Roblox.",0)end
 local packed,body=pcall(A.Pack,desc);desc:Destroy();if not packed or not body then error("Esse avatar não carregou. Tente outro look.",0)end
 local record={id="roblox:"..id,owner=id,sourceUsername=get(names,id,600),username=M.Curator,publisher=M.Curator,source="Roblox",body=body,rig="R15",name="Look de jogador",checkedAt=os.time()}
 cachePut(avatars,avatarOrder,id,record,180);return A.Copy(record)
end
function M.Research(pl,args)
 local record=M.Load(pl,args);local items={}
 for _,slot in ipairs({"Shirt","Pants"})do local id=record.body.props[slot]
  if id and id>0 then local ok,data=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
   if ok and data then table.insert(items,{id=id,slot=slot,name=data.Name,price=data.PriceInRobux,creator=data.Creator and data.Creator.Name})end
  end
 end
 local reference=Cosplay.Match(items);return{name=reference and(reference.name.." • Cosplay")or record.name,character=reference,checkedAt=os.time()}
end
Players.PlayerRemoving:Connect(function(pl)perPlayer[pl]=nil end)
return M
