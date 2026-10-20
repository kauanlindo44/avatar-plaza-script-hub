-- 09I12_REQUEST_PLAN | ModuleScript | ReplicatedStorage | V72 (SUBSTITUIR)
-- Um contrato compartilhado pelo formulário e pelo servidor; o pedido atual vem primeiro.
local Rep=game:GetService('ReplicatedStorage');local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'))
local M={Version='V72'}
M.Colors={{'preto','black'},{'branco','white'},{'roxo','purple'},{'rosa','pink'},{'vermelho','red'},{'azul','blue'},{'verde','green'},{'laranja','orange'},{'cinza','gray'},{'amarelo','yellow'},{'marrom','brown'},{'bege','beige'},{'dourado','gold'},{'prata','silver'}}
M.Pieces={{'chapeu','Hat'},{'hat','Hat'},{'cabelo','HairAccessory'},{'hair','HairAccessory'},{'oculos','FaceAccessory'},{'asas','BackAccessory'},{'wings','BackAccessory'},{'mochila','BackAccessory'},{'backpack','BackAccessory'}}
local function has(s,w)return s:find('%f[%w]'..w..'%f[%W]')~=nil end
function M.Color(value)
 local s=Styles.Normalize(value or'');local plurals={azul='azuis',marrom='marrons'}
 for _,c in ipairs(M.Colors)do
  local fem=c[1]:sub(-1)=='o'and(c[1]:sub(1,-2)..'a')or c[1]
  if has(s,c[1])or has(s,c[1]..'s')or has(s,fem)or has(s,fem..'s')or has(s,plurals[c[1]]or c[1])or has(s,c[2])then return c[2]end
 end;return''
end
function M.Parse(raw,context)
 local s=Styles.Normalize(raw or'');local style=Styles.Find(s);local p={text=tostring(raw or''),format='2D',scope='Tudo',keep=false,color=M.Color(s),excluded={},required={}}
 p.refine=has(s,'troque')or has(s,'troca')or has(s,'mude')or has(s,'mudar')or has(s,'mais')or has(s,'same')or has(s,'cheaper')
 if style then p.style=style.id;p.query=style.query;p.styleName=style.name
 elseif p.refine and context then p.style=context.styleId;p.query=context.style or context.keyword;p.color=p.color~=''and p.color or context.color end
 p.budget=tonumber(s:match('ate%s+r?%$?%s*(%d+)')or s:match('(%d+)%s*robux')or s:match('budget%s+(%d+)'))
 if has(s,'gratis')or has(s,'free')then p.budget=0 end
 p.count=tonumber(s:match('(%d+)%s*looks?')or s:match('(%d+)%s*outfits?')or s:match('(%d+)%s*skins?'));if p.count then p.count=math.clamp(p.count,1,2147483647)end
 if has(s,'3d')or has(s,'camadas')or has(s,'layered')then p.format='3D'end
 if has(s,'so')or has(s,'only')or p.refine then
  if has(s,'cabelo')or has(s,'hair')then p.scope='Cabelo'
  elseif has(s,'roupas')or has(s,'camisa')or has(s,'calca')or has(s,'clothes')then p.scope='Roupas'
  elseif has(s,'acessorios')or has(s,'accessories')then p.scope='Acessórios'end
 end
 p.bodyMode=(has(s,'corpo')or has(s,'body')or has(s,'bundle'))and'search'or'keep';p.baseRig=has(s,'r6')and'R6'or'R15';p.bodyQuery=s:match('corpo%s+(.+)')or s:match('body%s+(.+)')or'';p.bodyId=tonumber(s:match('/bundles/(%d+)')or s:match('corpo%s+id%s+(%d+)')or s:match('corpo%s+(%d+)'));if p.bodyId then p.bodyMode='bundle'end
 if has(s,'manter meu corpo')or has(s,'corpo atual')or has(s,'nao mude o corpo')or has(s,'nao mudar o corpo')or has(s,'keep my body')then p.bodyMode='keep';p.bodyId=nil end
 if has(s,'do zero')or has(s,'base classica')then p.bodyMode='blank';p.bodyId=nil end
 p.topType=has(s,'camiseta')and(has(s,'classica')and'TShirt'or'TShirtAccessory')or has(s,'camisa')and(has(s,'3d')and'ShirtAccessory'or'Shirt')or'auto';p.bottomType=has(s,'shorts')and'ShortsAccessory'or has(s,'saia')and'DressSkirtAccessory'or'auto'
 p.keep=p.scope~='Tudo';p.cheaper=has(s,'barato')or has(s,'cheaper')
 for _,v in ipairs(M.Pieces)do
  if s:find('sem '..v[1],1,true)or s:find('no '..v[1],1,true)or s:find('without '..v[1],1,true)then p.excluded[#p.excluded+1]=v[2]
  elseif s:find('com '..v[1],1,true)or s:find('with '..v[1],1,true)then p.required[#p.required+1]=v[2]end
 end
 if not p.query then
  local q=s:gsub('%f[%w]sem%s+[%w]+',''):gsub('%f[%w]without%s+[%w]+',''):gsub('%f[%w]ate%s+%d+',''):gsub('%d+','')
  for _,w in ipairs({'quero','crie','criar','faca','uma','um','look','skin','outfit','robux','por','para','favor','completo','completa','make','create','please'})do q=q:gsub('%f[%w]'..w..'%f[%W]',' ')end
  p.query=q:gsub('[%c<>]',''):gsub('%s+',' '):match('^%s*(.-)%s*$'):sub(1,48)
  if #p.query<3 then p.query='casual'end;p.styleName=p.query
 end
 return p
end
function M.Summary(p)
 local style=Styles.Get(p.style);local title=style and style.name or p.query or'Seu estilo'
 local price=tonumber(p.budget)or 100;local scope=p.scope or'Tudo'
 local s=title..(p.color and p.color~=''and(' • '..p.color)or'')..' • '..(p.format or'2D')..'\n'
 s=s..tostring(p.count or 1)..' look(s), até '..price..' Robux '..(scope=='Tudo'and'por look completo'or'para as peças alteradas')
 if scope~='Tudo'then s=s..' • mudar '..scope..', preservar o restante'end
 if #(p.excluded or{})>0 then s=s..'\nSem: '..table.concat(p.excluded,', ')end
 return s
end
return M
