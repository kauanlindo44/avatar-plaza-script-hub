-- 09B4_CURATED_LOOKS | ModuleScript | ServerScriptService | V46
-- Avatares atuais de jogadores reais. Nenhuma skin é montada com peças aleatórias.
local Players=game:GetService("Players")
local Avatar=game:GetService("AvatarEditorService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Meta=require(script.Parent:WaitForChild("09B2_COSPLAY_METADATA"))
local Discovery=require(script.Parent:WaitForChild("09B1_AVATAR_DISCOVERY"))
local M={};local cache,order,prices,priceOrder={},{},{},{};local bundles,bundleOrder={},{};local last,busy={},{}
local bodySlots={Head=true,Torso=true,RightArm=true,LeftArm=true,LeftLeg=true,RightLeg=true,LeftShoe=true,RightShoe=true}
local function norm(s)return tostring(s or""):lower():gsub("[%p%c]"," "):gsub("%s+"," "):match("^%s*(.-)%s*$")end
local function put(map,list,key,value,max)
 if not map[key]then table.insert(list,key)end;map[key]={value=value,at=os.clock()}
 while #list>max do map[table.remove(list,1)]=nil end
end
function M.Budget(n)
 if n==nil then return"unknown"end
 if n==0 then return"free"elseif n<=55 then return"1_55"elseif n<=150 then return"56_150"elseif n<=300 then return"151_300"elseif n<=600 then return"301_600"else return"601_plus"end
end
local function visualEntries(body)
 local out={};for _,e in ipairs(A.Entries(body))do if not e.Slot:find("Animation",1,true)and e.Slot~="Emote"then table.insert(out,e)end end;return out
end
local function signature(body)
 local ids={};for _,e in ipairs(visualEntries(body))do table.insert(ids,e.Id)end;table.sort(ids)
 local parts={};for _,id in ipairs(ids)do table.insert(parts,tostring(id))end
 for _,key in ipairs({"HeadColor","TorsoColor","LeftArmColor","RightArmColor","LeftLegColor","RightLegColor"})do
  local c=body.colors and body.colors[key];if c then for _,n in ipairs(c)do table.insert(parts,tostring(math.floor(n*255+.5)))end end
 end
 return table.concat(parts,":")
end
local function meaningful(body)
 local entries=visualEntries(body);local clothes=0
 for _,e in ipairs(entries)do if e.Slot=="Shirt"or e.Slot=="Pants"or e.Slot=="GraphicTShirt"then clothes=clothes+1 end end
 return #entries>=2 and(clothes>=2 or #(body.accessories or{})>=1 or(tonumber(body.props.Head)or 0)>0)
end
local function itemInfo(ids)
 local missing={};local out={}
 for _,id in ipairs(ids)do local old=prices[id]
  if old and os.clock()-old.at<180 then out[id]=old.value else table.insert(missing,id)end
 end
 for first=1,#missing,50 do local batch={};for i=first,math.min(first+49,#missing)do table.insert(batch,missing[i])end
  local ok,items=pcall(function()return Avatar:GetBatchItemDetailsAsync(batch,Enum.AvatarItemType.Asset)end)
  if ok and type(items)=="table"then for _,item in ipairs(items)do
   local id=tonumber(item.Id);if id then out[id]=item;put(prices,priceOrder,id,item,1200)end
  end end
 end
 return out
end
local function price(item)
 if not item or item.PriceStatus=="Off Sale"or item.PriceStatus=="No Resellers"then return nil end
 local n=A.Price(item);if item.PriceStatus=="Free"then n=0 end
 return type(n)=="number"and n==n and n>=0 and n<math.huge and n or nil
end
local function bundleOptions(id)
 local old=bundles[id];if old and os.clock()-old.at<180 then return old.value end
 local ok,pages=pcall(function()return Avatar:GetBundlesByAssetIdAsync(id,10)end);local rows={}
 if ok and pages then local success,data=pcall(function()return pages:GetCurrentPage()end);if success then rows=data end end
 put(bundles,bundleOrder,id,rows,256);return rows
end
local function outfitPrice(entries,details)
 local total=0;local pending={};local covered={};local chosen={}
 for _,e in ipairs(entries)do local n=price(details[e.Id]);if n~=nil then total=total+n else table.insert(pending,e)end end
 for _,e in ipairs(pending)do if not covered[e.Id]and bodySlots[e.Slot]then
  local best,cost
  for _,bundle in ipairs(bundleOptions(e.Id))do local n=price(bundle)
   if n and(not cost or n<cost)then best,cost=bundle,n end
  end
  if best then
   if not chosen[best.Id]then total=total+cost;chosen[best.Id]=true end
   for _,item in ipairs(best.BundledItems or{})do local id=tonumber(item.Id);if id then covered[id]=true end end
  end
 end end
 for _,e in ipairs(pending)do if not covered[e.Id]then return nil end end
 return total
end
local function build(pl,args)
 local index=args.page;local query=tostring(args.search or""):sub(1,40):match("^%s*(.-)%s*$");local exact=args.exact==true
 local selected={};local seen={};local ids,known={},{};local finished=false;local attempts=0
 for step=0,1 do
  local ok,candidates=pcall(function()return Discovery.Page(pl,{page=exact and index or index*2+step,search=exact and query or""})end)
  if not ok then if #selected==0 then error(candidates)else break end end
  finished=candidates.finished==true
  local jobs={}
  for _,candidate in ipairs(candidates.items or{})do
   local owner=tonumber(candidate.owner)
   if owner and owner>1 and norm(candidate.sourceUsername)~="roblox"and attempts<32 then attempts=attempts+1;table.insert(jobs,candidate)end
  end
  local nextJob,done=1,0;local loaded={};local workers=math.min(4,#jobs)
  for _=1,workers do task.spawn(function()
   while nextJob<=#jobs do local n=nextJob;nextJob=nextJob+1;local candidate=jobs[n]
    local ok,r=pcall(function()return Discovery.Load(pl,{id=candidate.owner})end)
    if ok and r and r.body and meaningful(r.body)then r.thumbnail=candidate.thumbnail;loaded[n]=r end
   end;done=done+1
  end)end
  while done<workers do task.wait(.04)end
  for n=1,#jobs do local r=loaded[n]
   if r and #selected<24 then local key=signature(r.body)
    if not seen[key]then seen[key]=true;r.signature=key;table.insert(selected,r)
     for _,e in ipairs(visualEntries(r.body))do if not known[e.Id]then known[e.Id]=true;table.insert(ids,e.Id)end end
    end
   end
  end
  if #selected>=16 or exact or finished then break end
 end
 local details=itemInfo(ids);local out={}
 for _,r in ipairs(selected)do
  local visual=visualEntries(r.body);local total=outfitPrice(visual,details);local unknown=total==nil;local clothing={};local count=0
  for _,e in ipairs(visual)do local d=details[e.Id];count=count+1
   if d and(e.Slot=="Shirt"or e.Slot=="Pants")then table.insert(clothing,{id=e.Id,slot=e.Slot,name=d.Name})end
  end
  local reference=Meta.Match(clothing);r.character=reference;r.name=reference and(reference.name.." • Cosplay")or"Look de jogador"
  if not reference then
   local words={};for _,e in ipairs(visual)do local d=details[e.Id];if d then table.insert(words,norm(d.Name))end end;local names=table.concat(words," ")
   local styles={{"Meme",{"meme","troll","bacon","banana","frog","pombo"}},{"Emo",{"emo","goth","scene","punk"}},{"Fofo",{"cute","kawaii","pastel"}},{"Streetwear",{"street","y2k","oversized","hoodie"}}}
   for _,style in ipairs(styles)do for _,word in ipairs(style[2])do if names:find(word,1,true)then r.name=style[1].." · look de jogador";break end end;if r.name~="Look de jogador"then break end end
  end
  r.total=not unknown and total or nil;r.budget=M.Budget(r.total);r.itemCount=count;r.checkedAt=os.time();r.source="Roblox"
  r.basis="Avatar atual do jogador e itens consultados no Roblox";r.publisher="CAETANOYX";r.username="CAETANOYX"
  local budget=args.budget;local accepts=budget=="free"and r.budget=="free"or budget=="paid"and not unknown and total>0 or budget~="free"and budget~="paid"
  local found=query==""or exact or norm(r.name):find(norm(query),1,true)or norm(r.sourceUsername):find(norm(query),1,true)
  if accepts and found then table.insert(out,r)end
 end
 return{items=out,finished=finished,page=index}
end
function M.Page(pl,args)
 args=type(args)=="table"and args or{};local index=tonumber(args.page)or 0
 if index~=index or index%1~=0 or index<0 or index>=10000 then error("Página inválida.")end
 local budget=args.budget;if budget~="free"and budget~="paid"then budget="all"end
 local query=tostring(args.search or""):sub(1,40);local exact=args.exact==true
 local key=index..":"..norm(query)..":"..budget..":"..tostring(exact)..(index==0 and(":"..pl.UserId)or"")
 local old=cache[key];if old and os.clock()-old.at<180 then return A.Copy(old.value)end
 if busy[pl]then error("Sua busca ainda está carregando.")end
 if os.clock()-(last[pl]or -100)<.7 then error("Aguarde um instante antes de atualizar.")end
 last[pl]=os.clock();busy[pl]=true
 local ok,result=pcall(build,pl,{page=index,search=query,budget=budget,exact=exact});busy[pl]=nil
 if not ok then error(result)end
 result.finished=result.finished or index==9999;put(cache,order,key,result,64);return A.Copy(result)
end
Players.PlayerRemoving:Connect(function(pl)last[pl]=nil;busy[pl]=nil end)
return M
