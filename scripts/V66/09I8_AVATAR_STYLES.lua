-- 09I8_AVATAR_STYLES | ModuleScript | ReplicatedStorage | V66 (NOVO)
-- Vocabulário pesquisável; nomes são referências culturais, não promessa de itens disponíveis.
local M={Version='V66',Styles={}};local index={}
function M.Normalize(text)
 local s=tostring(text or''):lower()
 for a,b in pairs({['á']='a',['à']='a',['â']='a',['ã']='a',['ä']='a',['é']='e',['ê']='e',['í']='i',['ó']='o',['ô']='o',['õ']='o',['ú']='u',['ç']='c'})do s=s:gsub(a,b)end
 return s:gsub('[%c<>]',''):gsub('%s+',' '):match('^%s*(.-)%s*$')
end
local rows={
 {'casual','Casual','casual','Cotidiano','Peças simples para o dia a dia','basico'},
 {'minimal','Minimalista','minimalist','Cotidiano','Poucos elementos e cores combinando','minimalismo'},
 {'mono','Monocromático','monochrome','Cotidiano','Uma cor conduz a combinação','monocromatico'},
 {'comfy','Confortável','comfy cozy','Cotidiano','Moletom, malha e aparência confortável','cozy,confortavel'},
 {'street','Streetwear','streetwear','Urbano','Roupas urbanas e modelagem larga','urbano,street'},
 {'skater','Skater','skater','Urbano','Calças largas e peças de skate','skatista'},
 {'sport','Esportivo','sport','Urbano','Camisetas e conjuntos para esporte','esportivo,esporte'},
 {'athleisure','Athleisure','athleisure','Urbano','Roupa esportiva com peças casuais',''},
 {'tech','Techwear','techwear','Futurista','Camadas funcionais e recortes urbanos','tech wear'},
 {'cyber','Cyberpunk','cyberpunk','Futurista','Tecnologia, contrastes e detalhes neon','cyber punk'},
 {'robot','Robô','robot','Futurista','Corpo e acessórios com tema robótico','robo,robozinho'},
 {'cyborg','Ciborgue','cyborg','Futurista','Partes humanas e detalhes mecânicos','ciborgue'},
 {'space','Espacial','space astronaut','Futurista','Astronauta, estrelas e exploração espacial','espacial,astronauta'},
 {'alien','Alien','alien','Futurista','Cores e formas extraterrestres','alienigena'},
 {'y2k','Y2K','y2k','Retrô','Referências visuais dos anos 2000','anos 2000'},
 {'mcbling','McBling','mcbling','Retrô','Brilho e acessórios dos anos 2000','mc bling'},
 {'vintage','Vintage','vintage','Retrô','Peças com aparência de outras épocas',''},
 {'retro80','Anos 80','80s retro','Retrô','Cores marcantes e silhuetas retrô','anos 80,oitentista'},
 {'retro90','Anos 90','90s retro','Retrô','Jeans, sobreposições e referências noventistas','anos 90,noventista'},
 {'steampunk','Steampunk','steampunk','Retrô','Engrenagens e referências de época','steam punk'},
 {'emo','Emo','emo','Alternativo','Franja, roupas escuras e acessórios',''},
 {'goth','Gótico','gothic','Alternativo','Tons escuros e detalhes góticos','gotico,goth'},
 {'punk','Punk','punk','Alternativo','Recortes, xadrez e peças marcantes',''},
 {'grunge','Grunge','grunge','Alternativo','Jeans, malhas e visual desgastado',''},
 {'softgrunge','Soft grunge','soft grunge','Alternativo','Grunge com contraste mais suave',''},
 {'scene','Scene','scene','Alternativo','Franja volumosa e cores fortes',''},
 {'scenecore','Scenecore','scenecore','Alternativo','Acessórios coloridos e contrastes intensos','scene core'},
 {'alt','Alternativo','alternative alt','Alternativo','Misture referências sem uma regra fixa','alternativo'},
 {'pastelgoth','Pastel goth','pastel goth','Alternativo','Cores pastel com detalhes escuros',''},
 {'soft','Soft','soft pastel','Fofo','Cores claras e peças delicadas','softie'},
 {'kawaii','Kawaii','kawaii','Fofo','Acessórios fofos e combinação alegre','fofo,cute'},
 {'cutecore','Cutecore','cutecore','Fofo','Peças doces e cores suaves','cute core'},
 {'chibi','Chibi','chibi','Fofo','Proporções pequenas e expressão marcante',''},
 {'pastel','Pastel','pastel','Fofo','Paleta clara com contraste delicado',''},
 {'kidcore','Kidcore','kidcore','Colorido','Cores primárias e referências nostálgicas','kid core'},
 {'decora','Decora','decora','Colorido','Presilhas, camadas e acessórios coloridos',''},
 {'clown','Clowncore','clowncore','Colorido','Estampas e acessórios de circo','palhaco'},
 {'harajuku','Harajuku','harajuku','J-fashion','Misturas de moda de rua japonesa',''},
 {'gyaru','Gyaru','gyaru','J-fashion','Cabelo marcante e acessórios coordenados',''},
 {'igari','Igari','igari','J-fashion','Visual suave com detalhes delicados',''},
 {'jirai','Jirai kei','jirai kei','J-fashion','Laços, contraste e peças coordenadas','jirai,jiraikei'},
 {'visualkei','Visual kei','visual kei','J-fashion','Cabelo expressivo e roupas elaboradas','visualkei'},
 {'fairykei','Fairy kei','fairy kei','J-fashion','Pastel e acessórios de fantasia','fairykei'},
 {'coquette','Coquette','coquette','Elegante','Laços, renda e detalhes delicados',''},
 {'dollette','Dollette','dollette','Elegante','Roupas delicadas com aparência de boneca',''},
 {'ballet','Balletcore','balletcore','Elegante','Tons suaves e referências de balé','ballet,balé,bale'},
 {'formal','Formal','formal elegant','Elegante','Peças alinhadas para ocasiões especiais','elegante,social'},
 {'oldmoney','Old money','old money','Elegante','Peças clássicas em cores discretas','oldmoney'},
 {'preppy','Preppy clássico','preppy classic','Elegante','Suéteres, camisas e referências colegiais','preppy classico'},
 {'preppypastel','Preppy pastel','preppy pink','Fofo','Rosa, acessórios e visual bem coordenado','preppy'},
 {'darkacademia','Dark academia','dark academia','Academia','Tons escuros e referências de estudo','academia escura'},
 {'lightacademia','Light academia','light academia','Academia','Malhas e peças claras de inspiração acadêmica','academia clara'},
 {'cottage','Cottagecore','cottagecore','Natureza','Tecidos leves e referências do campo','cottage core'},
 {'fairy','Fairycore','fairycore fairy','Natureza','Fadas, flores e detalhes de fantasia','fairy core,fada'},
 {'fairygrunge','Fairy grunge','fairy grunge','Natureza','Natureza com referências de grunge',''},
 {'goblin','Goblincore','goblincore','Natureza','Verdes, marrons e detalhes da floresta','goblin core'},
 {'forest','Floresta','forest nature','Natureza','Folhas e uma paleta natural','floresta,natureza'},
 {'floral','Floral','floral','Natureza','Flores nas estampas e acessórios','flores'},
 {'anime','Anime','anime','Fantasia','Cabelo, roupas e referências de anime',''},
 {'samurai','Samurai','samurai','Fantasia','Peças inspiradas em guerreiros históricos',''},
 {'ninja','Ninja','ninja','Fantasia','Roupas e acessórios de tema ninja',''},
 {'medieval','Medieval','medieval knight','Fantasia','Armaduras e referências medievais','cavaleiro'},
 {'mage','Mago','wizard mage','Fantasia','Túnicas e acessórios de magia','mago,bruxo'},
 {'elf','Elfo','elf','Fantasia','Orelhas e detalhes de fantasia','elfo,elfa'},
 {'angel','Anjo','angel','Fantasia','Asas e uma paleta luminosa','anjo,angelical'},
 {'demon','Demônio','demon','Fantasia','Chifres e contrastes de fantasia','demonio'},
 {'pirate','Pirata','pirate','Fantasia','Chapéus, casacos e tema de aventura','pirata'},
 {'cowboy','Cowboy','cowboy western','Fantasia','Botas, chapéu e tema western','cowgirl'},
 {'mermaid','Sereia','mermaid','Fantasia','Cores e acessórios de tema marinho','sereia'},
 {'halloween','Halloween','halloween','Estações','Outono, abóboras e detalhes temáticos','haloween,halowem'},
 {'christmas','Natal','christmas','Estações','Conjuntos e acessórios de tema natalino','natal,natalino'},
 {'winter','Inverno','winter','Estações','Casacos, cachecóis e malhas','inverno'},
 {'summer','Verão','summer','Estações','Peças leves e cores de verão','verao'},
 {'beach','Praia','beach','Estações','Óculos e referências de praia','praia'},
 {'autumn','Outono','autumn fall','Estações','Terrosos e camadas de meia estação','outono'},
 {'meme','Meme','meme funny','Meme e clássico','Formas engraçadas e itens inesperados','engracado'},
 {'weird','Weirdcore','weirdcore','Meme e clássico','Combinações surreais e incomuns','weird core'},
 {'dream','Dreamcore','dreamcore','Meme e clássico','Visual onírico e referências surreais','dream core'},
 {'classic','Roblox clássico','classic roblox','Meme e clássico','Peças simples e referências antigas','classico,old roblox'},
 {'noob','Noob','noob','Meme e clássico','Cores e referências do avatar clássico',''},
 {'bacon','Bacon','bacon','Meme e clássico','Combinações com o cabelo clássico',''},
 {'blocky','Blocky','blocky','Meme e clássico','Formas de bloco e acessórios coordenados','blocado'},
 {'animal','Animal','animal','Personagens','Escolha um animal na descrição','furry,anthro'},
 {'cat','Gato','cat','Personagens','Acessórios ou corpo com tema de gato','gato,gatinho'},
 {'dino','Dinossauro','dinosaur','Personagens','Corpo e acessórios de dinossauro','dinossauro'},
 {'artist','Artista','artist','Personagens','Acessórios e peças de tema artístico','artista'},
 {'chef','Chef','chef','Personagens','Peças e acessórios de cozinha','cozinheiro'},
 {'detective','Detetive','detective','Personagens','Casaco e acessórios de investigação','detetive'},
 {'superhero','Super-herói','superhero','Personagens','Capas e peças de tema heroico','super heroi,super-heroi'},
 {'pajama','Pijama','pajama','Cotidiano','Conjuntos confortáveis e acessórios leves','pijama'},
}
for _,r in ipairs(rows)do local s={id=r[1],name=r[2],query=r[3],group=r[4],note=r[5],aliases={r[2],r[3]}};for a in r[6]:gmatch('[^,]+')do s.aliases[#s.aliases+1]=a end;M.Styles[#M.Styles+1]=s;index[s.id]=s end
function M.Get(id)return index[tostring(id)]end
function M.Find(text)
 local s=M.Normalize(text);local best,score
 for _,v in ipairs(M.Styles)do for _,alias in ipairs(v.aliases)do local a=M.Normalize(alias)
  if #a>0 and s:find('%f[%w]'..a:gsub('([^%w%s])','%%%1')..'%f[%W]')and(not score or #a>score)then best,score=v,#a end
 end end;return best
end
function M.Search(text)
 local q=M.Normalize(text);local out={}
 for _,s in ipairs(M.Styles)do local hay=M.Normalize(s.name..' '..s.group..' '..s.query..' '..table.concat(s.aliases,' '));if q==''or hay:find(q,1,true)then out[#out+1]=s end end
 return out
end
return M
