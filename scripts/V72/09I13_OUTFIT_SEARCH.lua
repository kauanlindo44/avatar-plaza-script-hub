-- 09I13_OUTFIT_SEARCH | ModuleScript | ServerScriptService | V72 (SUBSTITUIR)
-- Pesquisa paginada e limitada; cache compartilhado, sem inventar IDs/preços.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'))
local Plan=require(Rep:WaitForChild('09I12_REQUEST_PLAN'));local S={};local cache={};local jobs={}
local aliases={Hat='Hat',HairAccessory='Hair',FaceAccessory='Face',BackAccessory='Back',NeckAccessory='Neck',FrontAccessory='Front',ShoulderAccessory='Shoulder',WaistAccessory='Waist'}
function S.Kind(row)
 local kind=row.AssetType;if typeof(kind)=='EnumItem'then return kind.Name end;if type(kind)=='table'then kind=kind.Name or kind.Id end
 if type(kind)=='number'then for _,v in ipairs(Enum.AvatarAssetType:GetEnumItems())do if v.Value==kind then return v.Name end end end;return kind
end
function S.Exact(id,kinds,limit,opts)
 local ok,row=pcall(function()return Avatar:GetItemDetailsAsync(id,Enum.AvatarItemType.Asset)end)
 if not ok or not row then return nil,'O Roblox não confirmou a peça obrigatória # '..id end;row.Id=id;local allowed=false;for _,k in ipairs(kinds)do if k==S.Kind(row)then allowed=true end end
 local price=S.Price(row);if not allowed or not price or price>limit or not S.Allowed(row,opts)then return nil,'A peça obrigatória # '..id..' não corresponde ao tipo, cor ou orçamento confirmado.'end;return{row}
end
function S.Price(row)local n=A.Price(row);return n and n>=0 and math.floor(n)or nil end
function S.Allowed(row,opts)
 local raw=row.AssetType;local kind=typeof(raw)=='EnumItem'and raw.Name or type(raw)=='table'and(raw.Name or raw.Id)or raw;if type(kind)=='number'then for _,e in ipairs(Enum.AvatarAssetType:GetEnumItems())do if e.Value==kind then kind=e.Name;break end end end;local name=Styles.Normalize(row.Name or'')
 for _,v in ipairs(opts.excluded or{})do if kind==v or kind==aliases[v]then return false end end
 -- Cores explícitas são requisitos: não troque preto por rosa só para preencher a lista.
 if opts.color and opts.color~=''and opts.strictColor~=false then
  local match=name:find(opts.color,1,true)~=nil
  for _,v in ipairs(Plan.Colors)do if v[2]==opts.color and name:find(v[1],1,true)then match=true end end
  if not match then return false end
 end
 return true
end
function S.Search(word,kinds,limit,opts,alive,deadline,pagesLimit)
 local key=word..':'..table.concat(kinds,',')..':'..limit..':'..(pagesLimit or 2);local now=os.clock();local c=cache[key]
 if c and now-c.time<75 then return A.Copy(c.rows)end
 local waitUntil=math.min(deadline,now+8)
 while jobs[key]and os.clock()<waitUntil and alive()do task.wait(.1)end
 if cache[key]and os.clock()-cache[key].time<75 then return A.Copy(cache[key].rows)end
 if os.clock()>=deadline or not alive()then return{},'Busca interrompida.'end
 jobs[key]=true
 local ok,rows=pcall(function()
  local params=CatalogSearchParams.new();params.SearchKeyword=word;params.IncludeOffSale=false;params.MinPrice=0;params.MaxPrice=limit;params.Limit=30;params.SortType=Enum.CatalogSortType.Relevance
  if kinds[1]=='BUNDLE'then params.BundleTypes={Enum.BundleType.BodyParts}else local t={};for _,k in ipairs(kinds)do local e=Enum.AvatarAssetType[k];if e then t[#t+1]=e end end;params.AssetTypes=t end
  local pages=Avatar:SearchCatalogAsync(params);local result,seen={},{}
  for page=1,pagesLimit or 2 do
   for _,row in ipairs(pages:GetCurrentPage())do local id=tonumber(row.Id);local price=S.Price(row)
    local validKind=kinds[1]=='BUNDLE';for _,kind in ipairs(kinds)do if kind==S.Kind(row)then validKind=true end end
    if validKind and id and id>0 and id%1==0 and not seen[id]and price and price<=limit and A.ItemType(row)==(kinds[1]=='BUNDLE'and'Bundle'or'Asset')then seen[id]=true;result[#result+1]=row end
   end
   if page>=(pagesLimit or 2)or pages.IsFinished~=false or not alive()or os.clock()>=deadline then break end
   local advanced=pcall(function()pages:AdvanceToNextPageAsync()end);if not advanced then break end
  end
  return result
 end)
 jobs[key]=nil;if not ok then return nil,'O catálogo Roblox não respondeu nesta busca. Tente novamente.'end
 cache[key]={time=os.clock(),rows=A.Copy(rows)};local n=0;for _ in pairs(cache)do n=n+1 end;if n>96 then cache={[key]=cache[key]}end
 return rows
end
function S.RequiredQuery(row,word)
 local name=Styles.Normalize(row.Name or'');local ignore={camisa=true,camiseta=true,calca=true,roupa=true,shirt=true,pants=true,accessory=true,['com']=true,['de']=true,['para']=true}
 for term in Styles.Normalize(word):gmatch('%w+')do if #term>2 and not ignore[term]and not name:find(term,1,true)then return false end end;return true
end
local generic={shirt=true,pants=true,black=true,white=true,red=true,blue=true,green=true,roupa=true,camisa=true,calca=true,emo=true,ugc=true,roblox=true,['for']=true,the=true,['and']=true,with=true}
function S.Coordinate(rows,chosen,word,opts,seed)
 local ref={};for _,it in ipairs(chosen or{})do for token in Styles.Normalize(it.Name):gmatch('%w+')do if #token>2 and not generic[token]then ref[token]=true end end end
 local ranked=S.Rank(rows,word,opts,seed);local score={}
 for i,r in ipairs(ranked)do local name=Styles.Normalize(r.Name);local n=0
  for token in pairs(ref)do if name:find(token,1,true)then n=n+12 end end
  local style=Styles.Get(opts.style);if style then for token in style.query:gmatch('%w+')do if name:find(token,1,true)then n=n+8 end end end
  score[r.Id]=n+(#ranked-i)/math.max(1,#ranked)
 end
 table.sort(ranked,function(a,b)return score[a.Id]>score[b.Id]end);return ranked
end
function S.Rank(rows,word,opts,seed)
 local out={};local tokens={};for t in Styles.Normalize(word):gmatch('%w+')do if #t>2 then tokens[#tokens+1]=t end end
 local function score(r)
  local name=Styles.Normalize(r.Name or'');local v=0;for _,t in ipairs(tokens)do if name:find(t,1,true)then v=v+4 end end
  if opts.economy then v=v-math.min(1000,S.Price(r)or 1000)/100 end;return v
 end
 for _,row in ipairs(rows)do if S.Allowed(row,opts)then out[#out+1]=row end end
 table.sort(out,function(a,b)local x,y=score(a),score(b);if x~=y then return x>y end
  local ax=(tonumber(a.Id)*31+seed*17)%997;local bx=(tonumber(b.Id)*31+seed*17)%997;if ax~=bx then return ax<bx end;return a.Id<b.Id end)
 return out
end
return S
