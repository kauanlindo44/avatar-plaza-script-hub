-- 09B_SHOP_SERVER
-- Script | ServerScriptService
-- AVATAR PLAZA V39 - skins R6/R15 + Comunidade + carrinho/bulk purchase oficial.
local DS=game:GetService("DataStoreService")
local TextService=game:GetService("TextService")
local Http=game:GetService("HttpService")
local Rep=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Market=game:GetService("MarketplaceService")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Community=require(script.Parent:WaitForChild("08L_COMMUNITY"))
local store=DS:GetDataStore("AvatarShop08_Private_v1")
local session,busy={},{}
local remotes=Rep:FindFirstChild("LMShop_Remotes");if remotes then remotes:Destroy()end
remotes=Instance.new("Folder");remotes.Name="LMShop_Remotes";remotes.Parent=Rep
local rpc=Instance.new("RemoteFunction");rpc.Name="Request";rpc.Parent=remotes
local function normRig(v)return tostring(v)=="R6"and"R6"or"R15"end
local function defaultData()return{version=1,skins={}}end
local function normalize(d)
 if type(d)~="table"or d.version~=1 or type(d.skins)~="table"then d=defaultData()end
 for _,s in ipairs(d.skins)do s.rig=normRig(s.rig)end;return d
end
local function load(pl)
 local ok,data=pcall(function()return store:GetAsync("u_"..pl.UserId)end);if ok then data=normalize(data or defaultData());session[pl]=data;return data,true end
 session[pl]=normalize(session[pl]or defaultData());return session[pl],false
end
local function update(pl,fn)
 local ok,data=pcall(function()return store:UpdateAsync("u_"..pl.UserId,function(old)return fn(normalize(old or defaultData()))end)end)
 if ok and data then session[pl]=normalize(data);return session[pl],true end
 local d=fn(normalize(session[pl]or defaultData()));session[pl]=normalize(d);return session[pl],false
end
local function filterName(pl,name)
 name=tostring(name or""):match("^%s*(.-)%s*$");if name==""then name="Meu Look"end;name=name:sub(1,40)
 local ok,r=pcall(function()return TextService:FilterStringAsync(name,pl.UserId):GetNonChatStringForBroadcastAsync()end);return ok and r or"Meu Look"
end
local function findSkin(pl,id)local d=load(pl);for _,s in ipairs(d.skins)do if s.id==id then return s end end end
Community.SetResolver(findSkin)
local handlers={}
handlers.List=function(pl)local d,p=load(pl);return{skins=d.skins,persistent=p}end
handlers.Save=function(pl,args)
 local clean,err=A.Clean(args.body);if not clean then error(err)end
 local skin={id=Http:GenerateGUID(false),name=filterName(pl,args.name),body=clean,rig=normRig(args.rig),updated=os.time()}
 local d,p=update(pl,function(old)if #old.skins>=A.MaxSaved then error("Limite de "..A.MaxSaved.." skins salvas.")end;table.insert(old.skins,1,skin);return old end)
 return{skin=skin,skins=d.skins,persistent=p}
end

handlers.Update=function(pl,args)
 local id=tostring(args.id or"");if not findSkin(pl,id)then error("Skin não encontrada.")end
 local filteredName=args.name and filterName(pl,args.name)or nil
 local clean=nil;if args.body then local err;clean,err=A.Clean(args.body);if not clean then error(err)end end
 local d,p=update(pl,function(old)
  for _,skin in ipairs(old.skins)do if skin.id==id then if clean then skin.body=clean end;if filteredName then skin.name=filteredName end;if args.rig then skin.rig=normRig(args.rig)end;skin.updated=os.time()end end;return old
 end)
 local skin=findSkin(pl,id);if skin and skin.publicCode then pcall(function()Community.Publish(pl,{id=id})end)end
 return{skin=skin,skins=d.skins,persistent=p}
end
handlers.Delete=function(pl,args)
 local id=tostring(args.id or"");if not findSkin(pl,id)then error("Skin não encontrada.")end;pcall(function()Community.Unpublish(pl,id)end)
 local d,p=update(pl,function(old)for i=#old.skins,1,-1 do if old.skins[i].id==id then table.remove(old.skins,i)end end;return old end);return{skins=d.skins,persistent=p}
end
handlers.Apply=function(pl,args)
 local clean,err=A.Clean(args.body);if not clean then error(err)end
 local hum=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid");if not hum or hum.Health<=0 then error("Seu personagem ainda não está pronto.")end
 local desc=A.Unpack(clean);local ok=pcall(function()hum:ApplyDescriptionResetAsync(desc)end);desc:Destroy();if not ok then error("Não foi possível aplicar essa combinação.")end
 local liveRig=hum.RigType==Enum.HumanoidRigType.R6 and"R6"or"R15";return{applied=true,liveRig=liveRig,wantedRig=normRig(args.rig)}
end
handlers.Publish=function(pl,args)
 local id=tostring(args.id or"");local skin=findSkin(pl,id);if not skin then error("Skin não encontrada.")end;local pub=Community.Publish(pl,{id=id})
 update(pl,function(old)for _,s in ipairs(old.skins)do if s.id==id then s.publicCode=pub.code;s.publicId=pub.id end end;return old end);return pub
end
handlers.Unpublish=function(pl,args)
 local id=tostring(args.id or"");local ok=Community.Unpublish(pl,id);update(pl,function(old)for _,s in ipairs(old.skins)do if s.id==id then s.publicCode=nil;s.publicId=nil end end;return old end);return ok
end
handlers.Favorite=function(pl,args)return Community.Favorite(pl,args)end
handlers.Feed=function(pl,args)return Community.Feed(pl,args)end
handlers.Code=function(pl,args)return Community.ByCode(pl,args)end
handlers.PurchaseItem=function(pl,args)
 local id=tonumber(args.id);if not id or id<=0 then error("Item inválido.")end;local kind=tostring(args.kind or"Asset")
 local ok=pcall(function()if kind=="Bundle"then Market:PromptBundlePurchase(pl,id)else Market:PromptPurchase(pl,id)end end);if not ok then error("Não foi possível abrir essa compra.")end;return true
end
handlers.BulkPurchase=function(pl,args)
 local clean,err=A.Clean(args.body);if not clean then error(err)end;local lines={}
 for _,e in ipairs(A.Entries(clean))do if #lines>=20 then break end;table.insert(lines,{Type=Enum.MarketplaceProductType.AvatarAsset,Id=tostring(e.Id)})end
 if #lines==0 then error("Nenhum item para comprar.")end;local ok=pcall(function()Market:PromptBulkPurchase(pl,lines,{})end);if not ok then error("Não foi possível abrir a compra da skin.")end
 return{count=#lines,remaining=math.max(0,#A.Entries(clean)-#lines)}
end
handlers.CartPurchase=function(pl,args)
 if type(args.items)~="table"or #args.items>20 then error("Selecione de 1 a 20 itens por compra.")end
 local lines,seen={},{}
 for _,v in ipairs(type(args.items)=="table"and args.items or{})do
  local id=tonumber(v.id);local kind=tostring(v.kind or"Asset");local key=kind..":"..tostring(id)
  if not id or id~=id or id<=0 or id>9007199254740991 or id%1~=0 or(kind~="Asset"and kind~="Bundle")then error("Item inválido no carrinho.")end
  if not seen[key] then
   seen[key]=true;table.insert(lines,{Type=kind=="Bundle"and Enum.MarketplaceProductType.AvatarBundle or Enum.MarketplaceProductType.AvatarAsset,Id=tostring(math.floor(id))})
  end
 end
 if #lines==0 then error("Carrinho vazio.")end
 local ok=pcall(function()Market:PromptBulkPurchase(pl,lines,{})end);if not ok then error("Não foi possível abrir o carrinho de compra.")end
 return{count=#lines}
end
rpc.OnServerInvoke=function(pl,action,args)
 if type(action)~="string"or not handlers[action]or type(args)~="table"then return{ok=false,error="Pedido inválido."}end;if busy[pl]then return{ok=false,error="Aguarde a operação anterior."}end
 busy[pl]=true;local ok,result=pcall(handlers[action],pl,args);busy[pl]=nil;if not ok then local msg=tostring(result):gsub("^.-:%d+: ","");warn("AVATAR CREATOR PLAZA "..action..": "..msg);return{ok=false,error=msg:sub(1,220)}end;return{ok=true,data=result}
end
Players.PlayerRemoving:Connect(function(pl)session[pl]=nil;busy[pl]=nil end)
print("AVATAR PLAZA V39: shop server + carrinho oficial pronto")

