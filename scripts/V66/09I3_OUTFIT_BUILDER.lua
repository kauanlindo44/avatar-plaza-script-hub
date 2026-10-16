-- 09I3_OUTFIT_BUILDER | ModuleScript | ServerScriptService | V66 (SUBSTITUIR)
-- A IA sugere palavras; IDs, tipos e preços vêm exclusivamente do Roblox.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Market=game:GetService('MarketplaceService')
local Load=require(Rep:WaitForChild('08B4_AVATAR_LOAD'));local B={Version='V66',Protocol=2};local cache={}
local function number(v,lo,hi,default)local n=tonumber(v);if not n or n~=n then n=default end;return math.clamp(math.floor(n),lo,hi)end
function B.Options(raw,plan)
 raw=type(raw)=='table'and raw or{};local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
 local mode=tostring(raw.tool or'Criar');local permitted={Criar=true,Cores=true,Temas=true,Lote=true,['Econômico']=true,['Inventário']=true}
 if not permitted[mode]or mode~='Criar'and plan~='Pro'then mode='Criar'end
 local t={budget=number(raw.budget,0,100000,100),count=number(raw.count,1,C.Plans[plan].count,1),format=raw.format=='3D'and'3D'or'2D',keep=raw.keep~=false,tool=mode,color=tostring(raw.color or''):sub(1,24),body=raw.body==true,pieceBudget=number(raw.pieceBudget,0,100000,100000)}
 local selected=require(Rep:WaitForChild('09I8_AVATAR_STYLES')).Get(raw.style);t.style=selected and selected.id or nil
 local scopes={Tudo=true,Cabelo=true,Roupas=true,['Acessórios']=true,Corpo=true};t.scope=scopes[raw.scope]and raw.scope or'Tudo'
 if t.scope~='Tudo'then t.keep=true;t.body=t.scope=='Corpo'end
 if mode=='Econômico'then t.budget=math.min(t.budget,55)end
 return t
end
local function search(word,kinds,limit)
 local key=word..':'..table.concat(kinds,',')..':'..limit;local c=cache[key];if c and os.clock()-c.time<90 then return c.rows end
 local params=CatalogSearchParams.new();params.SearchKeyword=word
 if kinds[1]=='BUNDLE'then params.BundleTypes={Enum.BundleType.BodyParts}else
  local types={};for _,kind in ipairs(kinds)do local v=Enum.AvatarAssetType[kind];if v then types[#types+1]=v end end;params.AssetTypes=types
 end
 params.IncludeOffSale=false;params.MinPrice=0;params.MaxPrice=limit;params.Limit=30;params.SortType=Enum.CatalogSortType.Relevance
 local ok,pages=pcall(function()return Avatar:SearchCatalogAsync(params)end);if not ok then return nil,'O catálogo Roblox não respondeu. Recarregue.'end
 local read,rows=pcall(function()return pages:GetCurrentPage()end);if not read then return nil,'Os itens não carregaram.'end
 local out={};local seen={};for _,row in ipairs(rows)do local id=tonumber(row.Id)
  if id and id>0 and id%1==0 and not seen[id]and A.ItemType(row)==(kinds[1]=='BUNDLE'and'Bundle'or'Asset')then seen[id]=true;out[#out+1]=row end
 end
 cache[key]={time=os.clock(),rows=out};local n=0;for _ in pairs(cache)do n=n+1 end;if n>80 then cache={}end;return out
end
local function price(row)local v=A.Price(row);return v~=nil and v>=0 and math.floor(v)or nil end
local function ranked(rows,keyword,opts)
 local copy=A.Copy(rows);local tokens={};for token in keyword:lower():gmatch('%w+')do if #token>2 then tokens[#tokens+1]=token end end
 local function score(r)
  local name=tostring(r.Name or''):lower();local n=0;for _,token in ipairs(tokens)do if name:find(token,1,true)then n=n+4 end end
  if opts.color~=''and name:find(opts.color:lower(),1,true)then n=n+5 end
  if opts.economy then n=n-math.min(1000,price(r)or 1000)/100 end;return n
 end
 table.sort(copy,function(a,b)local x,y=score(a),score(b);if x==y then return(price(a)or math.huge)<(price(b)or math.huge)end;return x>y end);return copy
end
local function owned(pl,id)local ok,v=pcall(function()return Market:PlayerOwnsAssetAsync(pl,id)end);return ok and v==true end
function B.Build(pl,keyword,opts,base,progress,alive)
 local body,why=A.Clean(base);if not body then return nil,why end
 keyword=tostring(keyword or''):gsub('[%c<>]',''):sub(1,70);if keyword==''then keyword='casual'end
 local groups={{opts.format=='3D'and'ShirtAccessory'or'Shirt'},{opts.format=='3D'and'PantsAccessory'or'Pants'},{'HairAccessory'},{'Hat','FaceAccessory'}}
 local requireClothes=opts.scope=='Tudo'or opts.scope=='Roupas'
 if opts.scope=='Cabelo'then groups={groups[3]}elseif opts.scope=='Roupas'then groups={groups[1],groups[2]}elseif opts.scope=='Acessórios'then groups={groups[4]}elseif opts.scope=='Corpo'then groups={}end
 local pools={};local per=math.min(opts.budget,opts.pieceBudget);local bundles
 if opts.body then local rows,e=search(keyword,{'BUNDLE'},per);if not rows then return nil,e end;bundles=rows end
 for i,kinds in ipairs(groups)do
  if not alive()then return nil,'Solicitação cancelada.'end
  progress(20+i*12,'Buscando peças reais · '..i..' / '..#groups)
  local word=keyword;if opts.tool=='Cores'and opts.color~=''then word=word..' '..opts.color end
  local rows,e=search(word,kinds,per);if not rows then return nil,e end;pools[i]=rows
 end
 local results,signatures={},{}
 for variation=1,opts.count do
  if not alive()then return nil,'Solicitação cancelada.'end
  local candidate=A.Copy(body);if not opts.keep then candidate.accessories={};candidate.props.Shirt=0;candidate.props.Pants=0;candidate.props.GraphicTShirt=0 end
  if opts.scope=='Cabelo'or opts.scope=='Roupas'or opts.scope=='Acessórios'then
   local kinds=opts.scope=='Cabelo'and{Hair=true}or opts.scope=='Roupas'and{Shirt=true,Pants=true,Jacket=true,Sweater=true,Shorts=true,DressSkirt=true,TShirt=true}or{Hat=true,Face=true}
   for i=#candidate.accessories,1,-1 do if kinds[candidate.accessories[i].type]then table.remove(candidate.accessories,i)end end
   if opts.scope=='Roupas'then candidate.props.Shirt=0;candidate.props.Pants=0;candidate.props.GraphicTShirt=0 end
  end
  local items,total,remaining={},0,opts.budget;local pickedIds={};local missing={}
  local modifier=''
  if opts.tool=='Cores'then modifier=opts.color~=''and opts.color or({'black','white','purple','red','gray'})[variation]
  elseif opts.tool=='Temas'then modifier=({'gothic','streetwear','soft','punk','retro'})[variation]end
  local clothingReserve=0;for j=1,requireClothes and math.min(2,#pools)or 0 do local cheapest=math.huge;for _,v in ipairs(pools[j])do local c=price(v);if c and c<=opts.pieceBudget then cheapest=math.min(cheapest,c)end end;if cheapest<math.huge then clothingReserve=clothingReserve+cheapest end end
  if bundles and #bundles>0 then
   local item=bundles[(variation-1)%#bundles+1];local packed=A.BundleBody(item,candidate);local cost=price(item)
   if packed and cost and cost<=remaining-clothingReserve then candidate=packed;total=cost;remaining=remaining-cost;items[#items+1]={Id=item.Id,Name=item.Name,Price=cost,ItemType='Bundle'}end
  end
  for group,rows in ipairs(pools)do
   if modifier~=''then
    local matches,e=search(keyword..' '..modifier,groups[group],per);if not matches then return nil,e end;rows=matches
   end
   if opts.tool=='Econômico'then opts.economy=true end;rows=ranked(rows,keyword,opts)
   local pick
   for offset=0,#rows-1 do local r=rows[(variation-1+offset)%#rows+1];local p=price(r)
    local reserve=0;for j=group+1,requireClothes and math.min(2,#pools)or group do local cheapest=math.huge;for _,later in ipairs(pools[j])do local c=price(later);if c and c<=opts.pieceBudget then cheapest=math.min(cheapest,c)end end;if cheapest<math.huge then reserve=reserve+cheapest end end
    if p and not pickedIds[r.Id]and p<=remaining-reserve and p<=opts.pieceBudget and(opts.tool~='Inventário'or owned(pl,r.Id))then pick=r;break end
   end
   if pick then
    -- Unpack/Add repassa tipo de acessório e camadas; nada de aplicar IDs como partes de corpo.
    local added=A.Add(candidate,pick)
    if added then candidate=added;pickedIds[pick.Id]=true;local p=price(pick);items[#items+1]={Id=pick.Id,Name=tostring(pick.Name or'Item'),Price=p,ItemType='Asset',AssetType=pick.AssetType};total=total+p;remaining=remaining-p end
   else missing[#missing+1]=groups[group][1]end
  end
  local top=(tonumber(candidate.props.Shirt)or 0)>0;local bottom=(tonumber(candidate.props.Pants)or 0)>0
  for _,v in ipairs(candidate.accessories or{})do
   if v.type=='Shirt'or v.type=='TShirt'or v.type=='Sweater'or v.type=='Jacket'then top=true end
   if v.type=='Pants'or v.type=='Shorts'or v.type=='DressSkirt'then bottom=true end
  end
  local complete=top and bottom
  if #items>0 and(not requireClothes or complete)then
   progress(86,'Conferindo preços e aparência…')
   local freshTotal=0;local confirmed=true
   for _,it in ipairs(items)do
    local ok,details=pcall(function()return Avatar:GetItemDetailsAsync(it.Id,it.ItemType=='Bundle'and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset)end)
    local p=ok and details and price(details)
    if not p or p>opts.pieceBudget then confirmed=false;break end
    freshTotal=freshTotal+p;it.Price=p
   end
   if freshTotal>opts.budget then confirmed=false end
   local rig='R15';local h=pl.Character and pl.Character:FindFirstChildOfClass('Humanoid')
   if opts.format=='2D'and not A.BodyRequiresR15(candidate)and h and h.RigType==Enum.HumanoidRigType.R6 then rig='R6'end
   if confirmed then
    local description=A.Unpack(candidate);local model,why=Load.Create(description,rig,{alive=alive});description:Destroy()
    if not model then confirmed=false else model:Destroy()end
   end
   if confirmed then
   total=freshTotal
   local ids={};for _,r in ipairs(items)do ids[#ids+1]=tostring(r.Id)end;table.sort(ids);local signature=table.concat(ids,',')
   if not signatures[signature]then signatures[signature]=true;results[#results+1]={name=keyword..(modifier~=''and(' • '..modifier)or'')..' · '..(#results+1),body=candidate,rig=rig,items=items,total=total,budget=opts.budget,missing=missing,complete=complete,kept=opts.keep,verified=true}end
   end
  end
  progress(72+math.floor(variation/opts.count*24),'Validando combinações · '..variation..' / '..opts.count)
 end
 if #results==0 then return nil,(requireClothes and'Não encontrei camisa e calça compatíveis dentro desse orçamento.'or'Não encontrei peças compatíveis nesta seleção.')..' Tente outro estilo ou orçamento; nenhum look foi aplicado.'end
 return results
end
return B
