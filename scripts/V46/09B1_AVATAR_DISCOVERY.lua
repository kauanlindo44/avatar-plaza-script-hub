-- 09B1_AVATAR_DISCOVERY | ModuleScript | ServerScriptService
-- V46: um milhao de candidatos reais paginados, metadados em lote e avatar sob demanda.
local Players=game:GetService("Players")
local Users=game:GetService("UserService")
local Market=game:GetService("MarketplaceService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Cosplay=require(script.Parent:WaitForChild("09B2_COSPLAY_METADATA"))
local M={PageSize=50,MaxPages=20000,Curator="CAETANOYX"}
local pages,avatars,perPlayer={},{},{}
local pageOrder,avatarOrder={},{}
local tokens,refill=120,os.clock();local names,nameOrder,friendCache,friendOrder={},{},{},{};local inFlight=0
local function uid(v)local n=tonumber(v);return n and n==n and n>=1 and n<=9007199254740991 and n%1==0 and n or nil end
local function trim(v)return tostring(v or""):match("^%s*(.-)%s*$"):gsub("^@",""):sub(1,40)end
local function reserve()
 local now=os.clock();tokens=math.min(120,tokens+(now-refill)*2);refill=now
 if tokens<1 then error("A Comunidade está ocupada. Tente novamente em instantes.")end;tokens=tokens-1
end
local function cachePut(cache,order,key,value,max)
 if not cache[key]then table.insert(order,key)end;cache[key]={value=value,at=os.clock()}
 while #order>max do cache[table.remove(order,1)]=nil end
end
local function get(cache,key,ttl)local e=cache[key];return e and os.clock()-e.at<ttl and e.value or nil end
local function friends(seed,page)
 local key=seed..":"..page;local old=get(friendCache,key,120);if old then return old end
 local ok,rows=pcall(function()
  local pages=Players:GetFriendsAsync(seed)
  for _=1,math.min(page,4)do if pages.IsFinished then return{}end;pages:AdvanceToNextPageAsync()end
  return pages:GetCurrentPage()
 end)
 local ids={};if ok then for _,r in ipairs(rows)do local id=uid(r.Id);if id then table.insert(ids,id)end end end
 cachePut(friendCache,friendOrder,key,ids,32);return ids
end
local function authorize(pl,id)
 local p=perPlayer[pl];if not p then p={ids={},order={},last=-100};perPlayer[pl]=p end
 if not p.ids[id]then p.ids[id]=true;table.insert(p.order,id)end
 while #p.order>800 do p.ids[table.remove(p.order,1)]=nil end
end
function M.Page(pl,args)
 local index=tonumber(args.page)or 0
 if index~=index or index%1~=0 or index<0 or index>=M.MaxPages then error("Página inválida.")end
 local query=trim(args.search);local key=tostring(index)..":"..query:lower()
 local cached=get(pages,key,300)
 if cached then for _,r in ipairs(cached.items)do authorize(pl,r.owner)end;return A.Copy(cached)end
 local p=perPlayer[pl]or{ids={},order={},last=-100};perPlayer[pl]=p
 if os.clock()-p.last<.65 then error("Aguarde um instante antes de carregar novos looks.")end;p.last=os.clock()
 reserve();local ids={};local seen={}
 local function add(id)if uid(id)and not seen[id]and #ids<100 then seen[id]=true;table.insert(ids,id)end end
 if query~=""then
  if index>0 then return{items={},finished=true}end
  local id=uid(query)
  if not id then local ok,n=pcall(function()return Players:GetUserIdFromNameAsync(query)end);if not ok then error("Usuário não encontrado. Use o @ ou ID do Roblox.")end;id=n end
  add(id)
 else
  if index==0 then add(pl.UserId);for _,player in ipairs(Players:GetPlayers())do add(player.UserId)end end
  local roots=friends(pl.UserId,0);local branch=index%3
  local seed=branch==0 and pl.UserId or branch==1 and 4129514489 or roots[math.floor(index/3)%math.max(1,#roots)+1]or pl.UserId
  for _,id in ipairs(friends(seed,math.floor(index/3)%5))do add(id)end
  local start=index*100
  for i=1,100 do add(1000000+((start+i)*4001+19876319)%4000000000)end
 end
 local ok,info=pcall(function()return Users:GetUserInfosByUserIdsAsync(ids)end)
 if not ok or type(info)~="table"then error("O Roblox não respondeu à Comunidade. Tente novamente.")end
 local byId={};for _,r in ipairs(info)do if uid(r.Id)and type(r.Username)=="string"then byId[r.Id]=r;cachePut(names,nameOrder,r.Id,r.Username,400)end end
 local out={}
 for _,id in ipairs(ids)do local r=byId[id];if r and #out<M.PageSize then
  authorize(pl,id);table.insert(out,{id="roblox:"..id,owner=id,sourceUsername=r.Username,username=M.Curator,publisher=M.Curator,name="Avatar de @"..r.Username,rig="R15",source="Roblox",thumbnail="rbxthumb://type=Avatar&id="..id.."&w=420&h=420"})
 end end
 local result={items=out,finished=query~=""or index==M.MaxPages-1,page=index}
 -- Page zero contains the requesting user's avatar and is not shared across users.
 if query~=""or index>0 then cachePut(pages,pageOrder,key,result,128)end
 return result
end
function M.Load(pl,args)
 local id=uid(args.id);local p=perPlayer[pl]
 if not id or not p or not p.ids[id]then error("Reabra esse look na Comunidade para carregar o avatar.")end
 local cached=get(avatars,id,60);if cached then return A.Copy(cached)end
 while inFlight>=4 do task.wait(.04)end;reserve();inFlight=inFlight+1
 local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(id)end)
 inFlight=inFlight-1
 if not ok or not desc then error("Esse avatar não está disponível no Roblox.")end
 local body=A.Pack(desc);desc:Destroy()
 local owner=get(names,id,300)
 if not owner then local okInfo,infos=pcall(function()return Users:GetUserInfosByUserIdsAsync({id})end);if not okInfo or not infos[1]then error("Não foi possível confirmar o autor desse avatar.")end;owner=infos[1].Username end
 local record={id="roblox:"..id,owner=id,sourceUsername=owner,username=M.Curator,publisher=M.Curator,source="Roblox",body=body,rig="R15",name="Avatar de @"..owner,checkedAt=os.time()}
 cachePut(avatars,avatarOrder,id,record,96);return A.Copy(record)
end
function M.Research(pl,args)
 local record=M.Load(pl,args);local items={}
 for _,slot in ipairs({"Shirt","Pants"})do
  local id=record.body.props[slot]
  if id and id>0 then
   local ok,data=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
   if ok and data then table.insert(items,{id=id,slot=slot,name=data.Name,price=data.PriceInRobux,creator=data.Creator and data.Creator.Name})end
  end
 end
 local reference=Cosplay.Match(items)
 return{name=reference and(reference.name.." • Cosplay")or record.name,character=reference,checkedAt=os.time()}
end
Players.PlayerRemoving:Connect(function(pl)perPlayer[pl]=nil end)
return M
