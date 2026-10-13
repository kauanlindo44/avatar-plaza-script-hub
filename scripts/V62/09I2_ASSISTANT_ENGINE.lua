-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V62 (SUBSTITUIR)
-- Planejador de looks por pesquisa. Não simula um modelo de linguagem nem inventa IDs.
local Text=game:GetService('TextService');local E={Version='V62',Protocol=2,Available=true,Checked=os.clock(),Language='pt',RetryAt=0}
local styles={{'emo','emo'},{'gótico','gothic'},{'gotico','gothic'},{'goth','gothic'},{'anime','anime'},{'meme','meme'},{'halloween','halloween'},{'y2k','y2k'},{'street','streetwear'},{'fofo','kawaii'},{'kawaii','kawaii'},{'elegante','formal'},{'esportivo','sport'},{'casual','casual'},{'punk','punk'},{'retro','retro'}}
function E.Health()E.Available=true;E.Checked=os.clock();return true end
function E.Summary()return 'Planejador de looks • catálogo Roblox • sem geração de texto externa'end
function E.Ask(pl,raw,context)
 local ok,clean=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForBroadcastAsync()end)
 if not ok or not clean then return nil,'O Roblox não liberou este pedido. Tente uma descrição de estilo.'end
 if clean:match('^%s*#+%s*$')then return nil,'Esse pedido foi filtrado. Descreva outro estilo.'end
 local lower=clean:lower();local keyword
 for _,s in ipairs(styles)do if lower:find(s[1],1,true)then keyword=s[2];break end end
 local color;for _,v in ipairs({{'preto','black'},{'branco','white'},{'roxo','purple'},{'rosa','pink'},{'vermelho','red'},{'azul','blue'},{'verde','green'}})do if lower:find(v[1],1,true)then color=v[2];break end end
 if not keyword and context and context.style then keyword=context.style:match('^([^·]+)')end
 if not keyword then
  keyword=lower:gsub('[%c<>]',''):gsub('cria[r]?',''):gsub('quero',''):gsub('look',''):gsub('skin',''):gsub('roupa',''):gsub('robux',''):gsub('%d+',''):gsub('%s+',' '):match('^%s*(.-)%s*$'):sub(1,48)
 end
 if keyword==''or keyword=='um'or keyword=='uma'then return nil,'Qual estilo você quer? Experimente emo, Halloween, streetwear, fofo ou elegante.'end
 if color and not keyword:find(color,1,true)then keyword=keyword..' '..color end
 return{answer='Vou buscar peças reais para '..keyword..', respeitando o orçamento e o formato que você confirmou.',keyword=keyword,language='pt',free=lower:find('grátis',1,true)~=nil or lower:find('gratis',1,true)~=nil or lower:find('free',1,true)~=nil}
end
function E.Help(raw)
 local s=tostring(raw):lower()
 if s:find('fly',1,true)or s:find('voar',1,true)then return 'Digite /fly no chat para voar e /unfly para pousar. Em partidas, comandos de movimento ficam desativados.'end
 if s:find('foto',1,true)or s:find('photo',1,true)then return 'Abra Photo Mode: Fundos mostra itens da loja para testar ou comprar. Emotes anima a cópia; Pose edita articulações. Foto captura sem interface.'end
 if s:find('patroc',1,true)or s:find('destaq',1,true)then return 'Patrocinar é gratuito: pesquise por nome ou ID, confira o item e publique por 24 horas. Um envio por pessoa; favoritos não dão prioridade.'end
 if s:find('filtro',1,true)then return 'Escolha categoria e subcategoria. Em Filtros, deixe preços vazios para todos ou defina mínimo/máximo; escolha roupas 2D/3D e toque Aplicar filtros.'end
 return 'Posso montar looks com peças do catálogo e explicar Photo Mode, patrocínio, filtros e comandos. Para assuntos gerais, este assistente de looks tem respostas limitadas.'
end
return E
