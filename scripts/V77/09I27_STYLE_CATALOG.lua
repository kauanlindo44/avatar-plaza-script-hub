-- 09I27_STYLE_CATALOG | ModuleScript | ReplicatedStorage | V77 (CRIAR)
-- Biblioteca editorial local: conceitos de combinação, nunca IDs ou looks verificados.
local Styles=require(game:GetService('ReplicatedStorage'):WaitForChild('09I8_AVATAR_STYLES'))
local M={Version='V77',ConceptsPerStyle=20}
local profiles={
 ['Cotidiano']={'casual','simple','knit','denim'},['Urbano']={'street','denim','oversized','sneaker'},
 ['Futurista']={'tech','cyber','robot','space'},['Retrô']={'vintage','retro','classic','denim'},
 ['Alternativo']={'goth','emo','punk','grunge'},['Fofo']={'cute','pastel','bow','soft'},
 ['Colorido']={'colorful','rainbow','bright','pattern'},['J-fashion']={'ribbon','lace','layered','japanese'},
 ['Elegante']={'formal','classic','suit','ribbon'},['Academia']={'school','knit','vest','classic'},
 ['Natureza']={'flower','leaf','forest','nature'},['Fantasia']={'fantasy','armor','cape','magic'},
 ['Estações']={'season','coat','summer','winter'},['Meme e clássico']={'classic','blocky','funny','roblox'},
 ['Personagens']={'character','costume','matching','themed'}}
local structures={'Conjunto coordenado','Camada sobre base','Peça principal em destaque','Detalhe de contraste','Composição discreta'}
local accents={'Cabelo e roupa','Acessório da cabeça','Detalhe no rosto','Complemento do corpo'}
function M.Concepts(id)
 local style=Styles.Get(id);if not style then return{}end;local out={}
 for a,structure in ipairs(structures)do for b,accent in ipairs(accents)do
  out[#out+1]={key=style.id..':'..a..':'..b,name=style.name..' · '..structure..' · '..accent,
   query=style.query,group=style.group,referenceOnly=true}
 end end
 return out
end
function M.Score(row,id)
 local style=Styles.Get(id);if not style then return 0 end
 local name=Styles.Normalize(row.Name);local score=0
 for token in style.query:gmatch('%w+')do if name:find('%f[%w]'..token..'%f[%W]')then score=score+5 end end
 for _,token in ipairs(profiles[style.group]or{})do if name:find('%f[%w]'..token..'%f[%W]')then score=score+1 end end
 return math.min(score,20)
end
return M
