-- 09I21_LOOK_CONTRACT | ModuleScript | ReplicatedStorage | V72 (NOVO)
-- Contrato único: escolhas confirmadas, tipos exatos e esforço verificável no servidor.
local Rep=game:GetService('ReplicatedStorage');local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local M={Version='V72',BatchSize=5}
M.Efforts={{id='Padrao',name='Padrão',pages=2,attempts=12,seconds=42,variants=1},
 {id='Alto',name='Alto',pages=3,attempts=20,seconds=55,variants=2},
 {id='Extra',name='Extra alto',pages=4,attempts=30,seconds=70,variants=3},
 {id='Extremo',name='Extremo alto',pages=5,attempts=40,seconds=85,variants=4,paid=true},
 {id='Max',name='Max',pages=6,attempts=55,seconds=100,variants=5,paid=true}}
M.Slots={
 top={{id='auto',name='Escolher por mim'},{id='Shirt',name='Camisa clássica'},{id='TShirt',name='Camiseta clássica'},{id='ShirtAccessory',name='Camisa · em camadas'},{id='TShirtAccessory',name='Camiseta · em camadas'},{id='JacketAccessory',name='Jaqueta'},{id='SweaterAccessory',name='Suéter'}},
 bottom={{id='auto',name='Escolher por mim'},{id='Pants',name='Calça clássica'},{id='PantsAccessory',name='Calça · em camadas'},{id='ShortsAccessory',name='Shorts'},{id='DressSkirtAccessory',name='Saia / vestido'}},
 hair={{id='auto',name='Escolher por mim'},{id='required',name='Obrigatório'},{id='keep',name='Manter o meu'},{id='none',name='Não incluir'}},
}
function M.Number(value,default,max)
 local n=tonumber(value);if not n or n~=n or n==math.huge or n==-math.huge then return default end
 return math.clamp(math.floor(n),0,max or 100000)
end
function M.Effort(value,plan)
 for _,v in ipairs(M.Efforts)do if v.id==value and(not v.paid or plan~='Normal')then return v end end;return M.Efforts[1]
end
function M.Options(raw,plan)
 raw=type(raw)=='table'and raw or{};plan=Config.Plans[plan]and plan or'Normal'
 local p={};local modes={keep=true,blank=true,bundle=true,search=true}
 p.bodyMode=modes[raw.bodyMode]and raw.bodyMode or(raw.body==true and'search'or'keep')
 p.bodyId=M.Number(raw.bodyId,0,9007199254740991);p.invalidId=raw.bodyId~=nil and tonumber(raw.bodyId)~=p.bodyId;p.bodyName=tostring(raw.bodyName or''):sub(1,100)
 p.bodyQuery=tostring(raw.bodyQuery or''):gsub('[%c<>]',''):sub(1,80)
 p.bodyRequired=p.bodyMode=='bundle'or p.bodyMode=='search';p.body=p.bodyRequired
 p.baseRig=raw.baseRig=='R6'and'R6'or'R15';p.effort=M.Effort(raw.effort,plan).id
 p.query=tostring(raw.query or''):gsub('[%c<>]',''):sub(1,100)
 p.topType='auto';p.bottomType='auto';p.hairMode='auto';p.fixed={};p.pieceQueries={}
 for _,slot in ipairs({'top','bottom','hair'})do p.fixed[slot]=M.Number(type(raw.fixed)=='table'and raw.fixed[slot],0,9007199254740991);if type(raw.fixed)=='table'and raw.fixed[slot]~=nil and tonumber(raw.fixed[slot])~=p.fixed[slot]then p.invalidId=true end;p.pieceQueries[slot]=tostring(type(raw.pieceQueries)=='table'and raw.pieceQueries[slot]or''):gsub('[%c<>]',''):sub(1,80)end
 for _,pair in ipairs({{'top','topType'},{'bottom','bottomType'},{'hair','hairMode'}})do
  for _,choice in ipairs(M.Slots[pair[1]])do if raw[pair[2]]==choice.id then p[pair[2]]=choice.id end end
 end
 p.requestedCount=math.max(1,M.Number(raw.requestedCount or raw.count,1,2147483647))
 if plan~='Pro'then p.requestedCount=math.min(p.requestedCount,Config.Plans[plan].count)end
 p.count=math.min(M.BatchSize,p.requestedCount);p.confirmed=raw.confirmed==true
 return p
end
function M.Check(opts)
 if opts.invalidId then return nil,'O ID obrigatório precisa ser um número inteiro válido.'end
 local wantsHair=opts.hairMode=='required'or opts.fixed.hair>0 or opts.pieceQueries.hair~='';for _,v in ipairs(opts.required or{})do if v=='HairAccessory'then wantsHair=true end end
 for _,v in ipairs(opts.excluded or{})do if v=='HairAccessory'and wantsHair then return nil,'O cabelo é obrigatório e também foi excluído. Revise as opções.'end end
 if wantsHair and(opts.hairMode=='keep'or opts.hairMode=='none')then return nil,'Revise as opções contraditórias de cabelo.'end
 for _,slot in ipairs({'top','bottom','hair'})do if opts.fixed[slot]>0 or opts.pieceQueries[slot]~=''or slot=='hair'and wantsHair then local scope=opts.scope or'Tudo';if scope~='Tudo'and scope~=(slot=='hair'and'Cabelo'or'Roupas')then return nil,'A peça obrigatória está fora do escopo escolhido. Revise Estilo e Opções avançadas.'end end end
 if opts.hairMode=='keep'and(opts.fixed.hair>0 or opts.pieceQueries.hair~='')then return nil,'Manter meu cabelo conflita com a peça obrigatória de cabelo.'end
 if opts.scope=='Corpo'and opts.bodyMode=='keep'then return nil,'Escolha qual corpo deseja usar na etapa Base.'end
 if opts.hairMode=='none'and(opts.fixed.hair>0 or opts.pieceQueries.hair~='')then return nil,'O cabelo obrigatório conflita com Não incluir cabelo.'end
 if opts.bodyMode=='bundle'and opts.bodyId<=0 then return nil,'Escolha o corpo antes de confirmar.'end
 if opts.bodyMode=='search'then return nil,'Confirme o corpo na lista de miniaturas; a busca não pode escolher outro por você.'end
 if opts.baseRig=='R6'and(opts.topType:find('Accessory')or opts.bottomType:find('Accessory')or opts.format=='3D')and opts.bodyMode=='blank'then return nil,'Roupas em camadas precisam da base R15. Escolha R15 ou roupas clássicas.'end
 return true
end
function M.Types(opts,slot)
 local chosen=opts[slot=='top'and'topType'or'bottomType']
 if chosen and chosen~='auto'then return{chosen}end
 if slot=='top'then return opts.format=='3D'and{'ShirtAccessory','TShirtAccessory','SweaterAccessory','JacketAccessory'}or{'Shirt'}end
 return opts.format=='3D'and{'PantsAccessory','ShortsAccessory','DressSkirtAccessory'}or{'Pants'}
end
function M.Name(slot,id)
 for _,v in ipairs(M.Slots[slot]or{})do if v.id==id then return v.name end end;return tostring(id or'Escolher por mim')
end
function M.Summary(p)
 local body=p.bodyMode=='bundle'and((p.bodyName~=''and p.bodyName or'Corpo # '..p.bodyId)..' 🔒')or p.bodyMode=='blank'and('Do zero · '..(p.baseRig or'R15'))or p.bodyMode=='search'and'Escolher corpo antes de criar'or'Manter meu corpo'
 return body..'\n'..M.Name('top',p.topType)..' + '..M.Name('bottom',p.bottomType)..' · '..M.Name('hair',p.hairMode)..'\n'..tostring(p.requestedCount or p.count or 1)..' look(s) · até '..tostring(p.budget or 100)..' Robux CADA'
end
return M
