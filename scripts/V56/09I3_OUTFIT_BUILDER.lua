-- 09I3_OUTFIT_BUILDER | ModuleScript | ServerScriptService | V56
-- A IA sugere palavras; IDs, tipos e preços vêm exclusivamente do Roblox.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Market=game:GetService('MarketplaceService')
local B={};local cache={}
local function number(v,lo,hi,default)local n=tonumber(v);if not n or n~=n then n=default end;return math.clamp(math.floor(n),lo,hi)end
function B.Options(raw,plan)
 raw=type(raw)=='table'and raw or{};local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
 local mode=tostring(raw.tool or'Criar');local permitted={Criar=true,Cores=true,Temas=true,Lote=true,['Econômico']=true,['Inventário']=true}
 if not permitted[mode]or mode~='Criar'and plan~='Pro'then mode='Criar'end
 local t={budget=number(raw.budget,0,100000,100),count=number(raw.count,1,C.Plans[plan].count,1),format=raw.format=='3D'and'3D'or'2D',keep=raw.keep~=false,tool=mode,color=tostring(raw.color or''):sub(1,24),body=raw.body==true,pieceBudget=number(raw.pieceBudget,0,100000,100000)}
 local scopes={Tudo=true,Cabelo=true,Roupas=true,['Acessórios']=true,Corpo=true};t.scope=scopes[raw.scope]and raw.scope or'Tudo'
 if t.scope~='Tudo'then t.keep=true;t.body=t.scope=='Corpo'end
 if mode=='Econômico'then t.budget=math.min(t.budget,55)end
 return t
end
local function search(word,kinds,limit)
 local key=word..':'..table.concat(kinds,',')..':'..limit;local c=cache[key];if c and os.clock()-c.time<90 then return c.rows end
 local params=CatalogSearchParams.new();params.SearchKeyword=word;params.AssetTypes={};if kinds[1]=='BUNDLE'then params.BundleTypes={Enum.BundleType.BodyParts}else for _,kind in ipairs(kinds)do params.AssetTypes[#params.AssetTypes+1]=Enum.AvatarAssetType[kind]end end
 params.IncludeOffSale=false;params.MinPrice=0;params.MaxPrice=limit;params.Limit=30;params.SortType=Enum.CatalogSortType.Relevance
 local ok,pages=pcall(function()return Avatar:SearchCatalogAsync(params)end);if not ok then return nil,'O catálogo Roblox não respondeu. Recarregue.'end
 local read,rows=pcall(function()return pages:GetCurrentPage()end);if not read then return nil,'Os itens não carregaram.'end
 local out={};local seen={};for _,row in ipairs(rows)do local id=tonumber(row.Id)
  if id and id>0 and id%1==0 and not seen[id]and A.ItemType(row)==(kinds[1]=='BUNDLE'and'Bundle'or'Asset')then seen[id]=true;out[#out+1]=row end
 end
 cache[key]={time=os.clock(),rows=out};local n=0;for _ in pairs(cache)do n=n+1 end;if n>80 then cache={}end;return out
end
local function price(row)local v=A.Price(row);return v~=nil and v>=0 and math.floor(v)or nil end
local function owned(pl,id)local ok,v=pcall(function()return Market:PlayerOwnsAssetAsync(pl,id)end);return ok and v==true end
function B.Build(pl,keyword,opts,base,progress,alive)
 local body,why=A.Clean(base);if not body then return nil,why end
 keyword=tostring(keyword or''):gsub('[%c<>]',''):sub(1,70);if keyword==''then keyword='casual'end
 local groups={{'HairAccessory'},{opts.format=='3D'and'ShirtAccessory'or'Shirt'},{opts.format=='3D'and'PantsAccessory'or'Pants'},{'Hat','FaceAccessory'}}
 if opts.scope=='Cabelo'then groups={groups[1]}elseif opts.scope=='Roupas'then groups={groups[2],groups[3]}elseif opts.scope=='Acessórios'then groups={groups[4]}elseif opts.scope=='Corpo'then groups={}end
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
  local items,total,remaining={},0,opts.budget
  local modifier=''
  if opts.tool=='Cores'then modifier=opts.color~=''and opts.color or({'black','white','purple','red','gray'})[variation]
  elseif opts.tool=='Temas'then modifier=({'gothic','streetwear','soft','punk','retro'})[variation]end
  if bundles and #bundles>0 then
   local item=bundles[(variation-1)%#bundles+1];local packed=A.BundleBody(item,candidate);local cost=price(item)
   if packed and cost and cost<=remaining then candidate=packed;total=cost;remaining=remaining-cost;items[#items+1]={Id=item.Id,Name=item.Name,Price=cost,ItemType='Bundle'}end
  end
  for group,rows in ipairs(pools)do
   if modifier~=''then
    local matches,e=search(keyword..' '..modifier,groups[group],per);if not matches then return nil,e end;rows=matches
   end
   if opts.tool=='Econômico'then rows=A.Copy(rows);table.sort(rows,function(a,b)return(price(a)or math.huge)<(price(b)or math.huge)end)end
   local pick
   for offset=0,#rows-1 do local r=rows[(variation-1+offset)%#rows+1];local p=price(r)
    if p and p<=remaining and p<=opts.pieceBudget and(opts.tool~='Inventário'or owned(pl,r.Id))then pick=r;break end
   end
   if pick then
    -- Unpack/Add repassa tipo de acessório e camadas; nada de aplicar IDs como partes de corpo.
    local added=A.Add(candidate,pick)
    if added then candidate=added;local p=price(pick);items[#items+1]={Id=pick.Id,Name=tostring(pick.Name or'Item'),Price=p,ItemType='Asset',AssetType=pick.AssetType};total=total+p;remaining=remaining-p end
   end
  end
  if #items>0 then
   local ids={};for _,r in ipairs(items)do ids[#ids+1]=tostring(r.Id)end;table.sort(ids);local signature=table.concat(ids,',')
   if not signatures[signature]then signatures[signature]=true;results[#results+1]={name=keyword..(modifier~=''and(' • '..modifier)or'')..' · '..(#results+1),body=candidate,rig='R15',items=items,total=total,budget=opts.budget}end
  end
  progress(72+math.floor(variation/opts.count*24),'Validando combinações · '..variation..' / '..opts.count)
 end
 if #results==0 then return nil,'Não encontrei peças verificadas nesse orçamento. Tente outro estilo ou valor.'end
 return results
end
return B
