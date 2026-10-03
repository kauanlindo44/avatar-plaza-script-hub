-- 07K8_CARD_INVENTORY | ModuleScript | ServerScriptService | V44
-- Toda alteração persistente usa UpdateAsync; falha de armazenamento bloqueia compras.
local DS=game:GetService("DataStoreService")
local Rep=game:GetService("ReplicatedStorage")
local C=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local store=DS:GetDataStore("ACP_CardInventory_V44")
local I={};local cache={};local changed=Instance.new("BindableEvent");I.Changed=changed.Event
local function fresh()
 return {version=0,coins=0,owned={Classic=true},equipped="Classic",boxes={},receipts={},rewards={},ateliers=false,
 custom={image=0,zoom=1,x=0,y=0},privacy={allowCopy=false},view="mine",daily={day=0,total=0,opponents={}}}
end
local function normalize(d)
 if type(d)~="table"then d=fresh()end
 local f=fresh();for k,v in pairs(f)do if d[k]==nil or type(d[k])~=type(v)then d[k]=v end end
 d.owned.Classic=true;return d
end
local function publish(id,d)
 if not cache[id]or d.version>=cache[id].version then cache[id]=d;changed:Fire(id)end
end
function I.Transact(id,fn)
 local result,err;local ok,d=pcall(function()
  return store:UpdateAsync("u"..id,function(old)
   local v=normalize(old);result=nil;err=nil
   local accepted,reason,value=fn(v)
   if not accepted then err=reason;return nil end
   v.version=v.version+1;result=value or true;return v
  end)
 end)
 if not ok then return nil,"Armazenamento indisponível. Tente novamente; nada foi cobrado em moedas."end
 if not d then return nil,err or"Operação recusada."end
 publish(id,d);return result
end
function I.Load(id)
 local ok,d=pcall(function()return store:GetAsync("u"..id)end)
 if not ok then return nil,"Inventário temporariamente indisponível."end
 d=normalize(d);publish(id,d);return I.View(id)
end
function I.View(id)
 local d=cache[id];if not d then return nil end
 local out={coins=d.coins,owned={},equipped=d.equipped,boxes={},ateliers=d.ateliers,custom=d.custom,
 privacy=d.privacy,view=d.view,version=d.version,randomEnabled=false}
 for k,v in pairs(d.owned)do out.owned[k]=v end
 for k,v in pairs(d.boxes)do out.boxes[k]=v end
 return out
end
function I.GrantPass(id,pass)
 local style=C.Passes[pass]
 if pass~=C.CustomPass and not style then return nil,"Passe desconhecido."end
 local d=I.Load(id);if not d then return nil,"Inventário indisponível."end
 if style and d.owned[style]or pass==C.CustomPass and d.ateliers then return true end
 return I.Transact(id,function(d)if style then d.owned[style]=true else d.ateliers=true end;return true end)
end
function I.BuyCoins(id,kind,key,quantity)
 quantity=tonumber(quantity)or 1
 if quantity%1~=0 or quantity<1 or quantity>10 then return nil,"Escolha de 1 a 10 unidades."end
 local collection=C.Collection(key);local style=C.Styles[key]
 if kind=="box"and collection then
 return I.Transact(id,function(d)
   local available=0;for _,s in ipairs(collection.skins)do if not d.owned[s]then available=available+1 end end
   if quantity+(d.boxes[key]or 0)>available then return false,"Compre apenas as caixas dos visuais que ainda não possui."end
   local cost=collection.coins*quantity;if d.coins<cost then return false,"Moedas insuficientes."end
   d.coins=d.coins-cost;d.boxes[key]=(d.boxes[key]or 0)+quantity;return true
  end)
 elseif kind=="style"and style and key~="Classic"then
  return I.Transact(id,function(d)
   if d.owned[key]then return false,"Este visual já está no inventário."end
   if d.coins<style.coins then return false,"Moedas insuficientes."end
   d.coins=d.coins-style.coins;d.owned[key]=true;return true
  end)
 end
 return nil,"Compra inválida."
end
function I.OpenChoice(id,key,style,quantity)
 local box=C.Collection(key);quantity=tonumber(quantity)or 1
 if not box or quantity%1~=0 or quantity<1 or quantity>10 then return nil,"Caixa inválida."end
 local valid=false;for _,s in ipairs(box.skins)do if s==style then valid=true end end
 if not valid then return nil,"Escolha um visual desta coleção."end
 return I.Transact(id,function(d)
  if d.owned[style]then return false,"Você já possui este visual. Escolha outro."end
  -- Uma escolha concede um visual permanente; nunca consumir caixas duplicadas.
  if quantity~=1 then return false,"Abra uma caixa por visual para evitar duplicatas."end
  if(d.boxes[key]or 0)<quantity then return false,"Nenhuma caixa disponível."end
  d.boxes[key]=d.boxes[key]-quantity;d.owned[style]=true;return true,nil,{style=style,collection=key,quantity=1}
 end)
end
function I.OpenChoices(id,key,styles)
 local box=C.Collection(key)
 if not box or type(styles)~="table"or #styles<1 or #styles>3 then return nil,"Escolha de um a três visuais."end
 local seen={};for _,style in ipairs(styles)do
  local valid=false;for _,s in ipairs(box.skins)do if s==style then valid=true end end
  if not valid or seen[style]then return nil,"Escolha visuais distintos desta coleção."end;seen[style]=true
 end
 return I.Transact(id,function(d)
  if(d.boxes[key]or 0)<#styles then return false,"Caixas insuficientes para estas escolhas."end
  for _,style in ipairs(styles)do if d.owned[style]then return false,"Um dos visuais já foi adquirido. Revise as escolhas."end end
  d.boxes[key]=d.boxes[key]-#styles;for _,style in ipairs(styles)do d.owned[style]=true end
  return true,nil,{styles=styles,collection=key,quantity=#styles}
 end)
end
function I.Equip(id,style)
 return I.Transact(id,function(d)
  if style=="Custom"and not d.ateliers or style~="Custom"and not d.owned[style]then return false,"Visual não adquirido."end
  d.equipped=style;return true
 end)
end
function I.SetCustom(id,data)
 local image=tonumber(data.image);if not image or image<=0 or image%1~=0 then return nil,"Informe um ID de imagem aprovado pelo Roblox."end
 local function number(v,lo,hi,default)local n=tonumber(v);if not n or n~=n then n=default end;return math.clamp(n,lo,hi)end
 return I.Transact(id,function(d)
  if not d.ateliers then return false,"O Ateliê requer o passe permanente."end
  local zoom=number(data.zoom,1,2,1);local limit=(zoom-1)/2
  d.custom={image=image,zoom=zoom,x=number(data.x,-limit,limit,0),y=number(data.y,-limit,limit,0)};return true
 end)
end
function I.Settings(id,data)
 return I.Transact(id,function(d)
  if type(data.allowCopy)=="boolean"then d.privacy.allowCopy=data.allowCopy end
  if data.view=="mine"or data.view=="players"or data.view=="classic"then d.view=data.view end
  return true
 end)
end
function I.Receipt(receipt,key)
 local collection=C.Collection(key);local style=C.Styles[key]
 if not collection and not style then return nil,"Produto sem benefício."end
 return I.Transact(receipt.PlayerId,function(d)
  local purchase=tostring(receipt.PurchaseId);if d.receipts[purchase]then return true end
  if collection then d.boxes[key]=(d.boxes[key]or 0)+1 else d.owned[key]=true end
  d.receipts[purchase]=true;return true
 end)
end
function I.Reward(id,match,won,opponents)
 return I.Transact(id,function(d)
  if d.rewards[match]then return true,nil,0 end
  local day=math.floor(os.time()/86400)
  if d.daily.day~=day then d.daily={day=day,total=0,opponents={}}end
  local keys={};for _,uid in ipairs(opponents)do table.insert(keys,tostring(uid))end;table.sort(keys);local key=table.concat(keys,"-")
  local repeats=d.daily.opponents[key]or 0;local amount=repeats<5 and math.min(won and 100 or 35,math.max(0,1200-d.daily.total))or 0
  d.daily.opponents[key]=repeats+1;d.daily.total=d.daily.total+amount;d.coins=d.coins+amount;d.rewards[match]=day
  for k,t in pairs(d.rewards)do if t<day-14 then d.rewards[k]=nil end end
  return true,nil,amount
 end)
end
return I
