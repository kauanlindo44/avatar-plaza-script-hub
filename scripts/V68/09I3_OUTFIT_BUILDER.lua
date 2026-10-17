-- 09I3_OUTFIT_BUILDER | ModuleScript | ServerScriptService | V68 (SUBSTITUIR)
-- Roupa primeiro, restrições explícitas, novas combinações e validação nativa com recuperação.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService');local Market=game:GetService('MarketplaceService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Load=require(Rep:WaitForChild('08B4_AVATAR_LOAD'))
local Search=require(script.Parent:WaitForChild('09I13_OUTFIT_SEARCH'));local Accounts=require(script.Parent:WaitForChild('09I1_ASSISTANT_ACCOUNTS'))
local Plan=require(Rep:WaitForChild('09I12_REQUEST_PLAN'));local B={Version='V68',Protocol=2};local serial=0
local function num(v,lo,hi,d)local n=tonumber(v);if not n or n~=n then n=d end;return math.clamp(math.floor(n),lo,hi)end
local kinds={Hat=true,HairAccessory=true,FaceAccessory=true,BackAccessory=true,NeckAccessory=true,FrontAccessory=true,ShoulderAccessory=true,WaistAccessory=true}
local function list(raw)local out,seen={},{};if type(raw)=='table'then for _,v in ipairs(raw)do if kinds[v]and not seen[v]then seen[v]=true;out[#out+1]=v end;if #out>=8 then break end end end;return out end
function B.Options(raw,plan)
 raw=type(raw)=='table'and raw or{};local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));plan=C.Plans[plan]and plan or'Normal'
 local mode=tostring(raw.tool or'Criar');local permitted={Criar=true,Cores=true,Temas=true,Lote=true,['Econômico']=true,['Inventário']=true}
 if not permitted[mode]or mode~='Criar'and plan~='Pro'then mode='Criar'end
 local scopes={Tudo=true,Cabelo=true,Roupas=true,['Acessórios']=true,Corpo=true};local scope=scopes[raw.scope]and raw.scope or'Tudo'
 local t={budget=num(raw.budget,0,100000,100),count=num(raw.count,1,C.Plans[plan].count,1),format=raw.format=='3D'and'3D'or'2D',keep=scope~='Tudo',tool=mode,color=Plan.Color(raw.color),body=raw.body==true,pieceBudget=num(raw.pieceBudget,0,100000,100000),scope=scope,confirmed=raw.confirmed==true,styleEdited=raw.styleEdited==true,excluded=list(raw.excluded),required=list(raw.required),strictColor=true}
 local selected=require(Rep:WaitForChild('09I8_AVATAR_STYLES')).Get(raw.style);t.style=selected and selected.id or nil
 if scope~='Tudo'then t.body=scope=='Corpo'end;if mode=='Econômico'then t.budget=math.min(t.budget,55);t.economy=true end;return t
end
local clothing={Shirt=true,Pants=true,Jacket=true,Sweater=true,Shorts=true,DressSkirt=true,TShirt=true,LeftShoe=true,RightShoe=true}
local aliases={HairAccessory='Hair',FaceAccessory='Face',BackAccessory='Back',NeckAccessory='Neck',FrontAccessory='Front',ShoulderAccessory='Shoulder',WaistAccessory='Waist',Hat='Hat'}
local function cleared(base,opts)
 local d=A.Copy(base)
 if opts.scope=='Tudo'then d.accessories={};d.props.Shirt=0;d.props.Pants=0;d.props.GraphicTShirt=0
 elseif opts.scope=='Roupas'then d.props.Shirt=0;d.props.Pants=0;d.props.GraphicTShirt=0 end
 for i=#d.accessories,1,-1 do local v=d.accessories[i];local remove=opts.scope=='Cabelo'and v.type=='Hair'or opts.scope=='Roupas'and clothing[v.type]or opts.scope=='Acessórios'and not clothing[v.type]and v.type~='Hair'
  for _,kind in ipairs(opts.excluded)do if v.type==(aliases[kind]or kind)then remove=true end end;if remove then table.remove(d.accessories,i)end
 end;return d
end
local function complete(d)
 local top=(d.props.Shirt or 0)>0;local bottom=(d.props.Pants or 0)>0
 for _,v in ipairs(d.accessories)do
  if v.type=='Shirt'or v.type=='TShirt'or v.type=='Jacket'or v.type=='Sweater'then top=true end
  if v.type=='Pants'or v.type=='Shorts'or v.type=='DressSkirt'then bottom=true end
 end;return top and bottom,top,bottom
end
local function signature(items)local ids={};for _,v in ipairs(items)do ids[#ids+1]=tostring(v.Id)end;table.sort(ids);return table.concat(ids,',')end
function B.Build(pl,keyword,opts,base,progress,alive)
 local body,why=A.Clean(base);if not body then return nil,why end
 opts=B.Options(opts,opts.plan or'Pro');keyword=tostring(keyword or'casual'):gsub('[%c<>]',''):sub(1,70);if keyword==''then keyword='casual'end
 serial=serial+1;local seed=serial*37+(pl.UserId or 0)%997;local deadline=os.clock()+42
 local requireClothes=opts.scope=='Tudo'or opts.scope=='Roupas';local groups={}
 local function group(types,required,label)groups[#groups+1]={types=types,required=required,label=label}end
 if requireClothes then
  group(opts.format=='3D'and{'ShirtAccessory','TShirtAccessory','SweaterAccessory','JacketAccessory'}or{'Shirt'},true,'parte de cima')
  group(opts.format=='3D'and{'PantsAccessory','ShortsAccessory','DressSkirtAccessory'}or{'Pants'},true,'parte de baixo')
 end
 local excluded,required={},{};for _,v in ipairs(opts.excluded)do excluded[v]=true end;for _,v in ipairs(opts.required)do if not excluded[v]then required[v]=true end end
 if(opts.scope=='Tudo'or opts.scope=='Cabelo')and not excluded.HairAccessory then group({'HairAccessory'},opts.scope=='Cabelo'or required.HairAccessory,'cabelo');required.HairAccessory=nil end
 if(opts.scope=='Tudo'or opts.scope=='Acessórios')and not excluded.Hat and not required.Hat then group({'Hat','FaceAccessory','NeckAccessory'},false,'acessório')end
 for kind in pairs(required)do group({kind},true,kind)end
 local per=math.min(opts.budget,opts.pieceBudget);local pools={};local failed={};local calls=0
 local function fetch(word,g)
  if not alive()or os.clock()>=deadline then return{}end;calls=calls+1
  local rows,e=Search.Search(word,g.types,per,opts,alive,deadline,g.required and 3 or 2);if not rows then failed[#failed+1]=e;return{}end
  return Search.Rank(rows,keyword,opts,seed)
 end
 for i,g in ipairs(groups)do
  progress(12+math.floor(i/math.max(1,#groups)*36),'Pesquisando '..g.label..' · '..i..'/'..#groups)
  pools[i]=fetch(keyword,g)
  if #pools[i]==0 and g.required then
   local fallback=keyword;if opts.color~=''then fallback=keyword:gsub(opts.color,''):gsub('%s+',' ')end
   if fallback~=keyword and #fallback>=3 then pools[i]=fetch(fallback,g)end
  end
  if #pools[i]==0 and g.required then return nil,'Não encontrei '..g.label..' compatível com o estilo, cor e orçamento confirmados. Ajuste esse campo; nenhum look foi aplicado.'end
 end
 local bundles;if opts.body then bundles=Search.Search(keyword,{'BUNDLE'},per,opts,alive,deadline,2)or{}end
 local prior=Accounts.Novelty and Accounts.Novelty(pl.UserId)or{};local signatures={};for _,v in ipairs(prior)do signatures[v]=true end
 local results,newSigs={},{};local invalid={};local rejected={};local lastFailure;local validationAttempts=0
 local function cheapest(index)
  local best=math.huge;for _,r in ipairs(pools[index])do if not invalid[r.Id]then local p=Search.Price(r);if p and p<=opts.pieceBudget then best=math.min(best,p)end end end;return best
 end
 for attempt=1,math.min(24,opts.count*5+4)do
  if #results>=opts.count or not alive()or os.clock()>=deadline then break end
  local candidate=cleared(body,opts);local items,total,picked={},0,{};local valid=true
  local reserve=0;for i,g in ipairs(groups)do if g.required then reserve=reserve+cheapest(i)end end
  if bundles and #bundles>0 then
   local it=bundles[(seed+attempt-1)%#bundles+1];local p=Search.Price(it);local packed=p and p<=opts.budget-reserve and A.BundleBody(it,candidate)
   if packed then candidate=packed;total=p;items[#items+1]={Id=it.Id,Name=it.Name,Price=p,ItemType='Bundle'}end
  end
  for i,g in ipairs(groups)do
   local later=0;local optional=0;for j=i+1,#groups do local c=cheapest(j);if groups[j].required then later=later+c elseif c<math.huge then optional=optional+c end end
   local rows=pools[i];local selected
   for pass=1,2 do for offset=0,#rows-1 do
    local row=rows[((attempt-1)*(i*2-1)+offset)%#rows+1];local p=Search.Price(row)
    if p and not invalid[row.Id]and not picked[row.Id]and p<=opts.pieceBudget and total+p+later+(pass==1 and optional or 0)<=opts.budget then
     local owned=true;if opts.tool=='Inventário'then local ok,v=pcall(Market.PlayerOwnsAssetAsync,Market,pl,row.Id);owned=ok and v==true end
     if owned then local d,e=A.Add(candidate,row);if d then candidate=d;selected=row;break else invalid[row.Id]=true;lastFailure=e end end
    end
   end
   if selected then break end end
   if selected then local p=Search.Price(selected);items[#items+1]={Id=selected.Id,Name=selected.Name,Price=p,ItemType='Asset',AssetType=selected.AssetType};picked[selected.Id]=true;total=total+p
   elseif g.required then valid=false;lastFailure='Faltou '..g.label;break end
  end
  local dressed=complete(candidate);local sig=signature(items)
  if valid and #items>0 and(not requireClothes or dressed)and not signatures[sig]and not rejected[sig]then
   validationAttempts=validationAttempts+1;progress(62+math.floor(#results/math.max(1,opts.count)*30),'Conferindo look completo, preços e avatar…')
   local fresh=0
   for _,it in ipairs(items)do
    if not alive()or os.clock()>=deadline then valid=false;break end
    local ok,detail=pcall(function()return Avatar:GetItemDetailsAsync(it.Id,it.ItemType=='Bundle'and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset)end)
    local price=ok and detail and Search.Price(detail)
    if not price or price>opts.pieceBudget or detail.IsPurchasable==false then valid=false;invalid[it.Id]=true;lastFailure='Uma peça mudou de preço ou ficou indisponível.';break end
    it.Price=price;fresh=fresh+price
   end
   if fresh>opts.budget then valid=false;lastFailure='O preço das peças mudou; buscando outra combinação.'end
   local rig='R15';local h=pl.Character and pl.Character:FindFirstChildOfClass('Humanoid');if opts.format=='2D'and not A.BodyRequiresR15(candidate)and h and h.RigType==Enum.HumanoidRigType.R6 then rig='R6'end
   if valid then
    local desc=A.Unpack(candidate);local model,e=Load.Create(desc,rig,{alive=alive});desc:Destroy()
    if not model then valid=false;lastFailure=e;rejected[sig]=true;local bad=tonumber(tostring(e):match('item #?%s*(%d+)'));if bad then invalid[bad]=true end else model:Destroy()end
   end
   if valid then signatures[sig]=true;newSigs[#newSigs+1]=sig;results[#results+1]={name=keyword..' · '..(#results+1),body=candidate,rig=rig,items=items,total=fresh,budget=opts.budget,missing={},complete=not requireClothes or dressed,kept=opts.keep,verified=true,scope=opts.scope,signature=sig}
   elseif validationAttempts>=math.max(4,opts.count*2)then break end
  end
 end
 if #results==0 then return nil,(lastFailure or(#prior>0 and'As combinações disponíveis já foram mostradas com estas restrições.'or'Não encontrei um look completo dentro destes limites.'))..' Tente outra cor, estilo ou orçamento. Nenhum look foi aplicado.'end
 if Accounts.Remember then Accounts.Remember(pl.UserId,newSigs)end;return results
end
return B
