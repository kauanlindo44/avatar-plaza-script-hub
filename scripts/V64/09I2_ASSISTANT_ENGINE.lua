-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V64 (SUBSTITUIR)
-- Contexto de estilo e refinamentos; pesquisa real sem chave ou IDs inventados.
local Text=game:GetService('TextService');local E={Version='V64',Protocol=2,Available=true,Checked=os.clock(),Language='pt',RetryAt=0}
local styles={{'emo','emo'},{'gótico','gothic'},{'gotico','gothic'},{'goth','gothic'},{'gothic','gothic'},{'anime','anime'},{'meme','meme'},{'halloween','halloween'},{'y2k','y2k'},{'street','streetwear'},{'streetwear','streetwear'},{'fofo','kawaii'},{'cute','kawaii'},{'kawaii','kawaii'},{'elegante','formal'},{'formal','formal'},{'esportivo','sport'},{'sport','sport'},{'casual','casual'},{'punk','punk'},{'retro','retro'}}
local colors={{'preto','black'},{'black','black'},{'branco','white'},{'white','white'},{'roxo','purple'},{'purple','purple'},{'rosa','pink'},{'pink','pink'},{'vermelho','red'},{'red','red'},{'azul','blue'},{'blue','blue'},{'verde','green'},{'green','green'},{'laranja','orange'},{'orange','orange'}}
local function contains(text,word)return text:find('%f[%w]'..word..'%f[%W]')~=nil end
function E.Health()E.Available=true;E.Checked=os.clock();return true end
function E.Summary()return'Planejador de looks • pesquisa Roblox com contexto • sem modelo externo'end
function E.Ask(pl,raw,context)
 local ok,clean=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForBroadcastAsync()end)
 if not ok or not clean or clean:match('^%s*#+%s*$')then return nil,'O Roblox filtrou esse pedido. Descreva o estilo com outras palavras.'end
 local lower=clean:lower();local style,color
 for _,s in ipairs(styles)do if contains(lower,s[1])then style=s[2];break end end
 for _,s in ipairs(colors)do if contains(lower,s[1])then color=s[2];break end end
 local refine=lower:find('mais',1,true)or lower:find('troca',1,true)or lower:find('mudar',1,true)or lower:find('outro',1,true)or lower:find('same',1,true)or lower:find('cheaper',1,true)
 if not style and context and context.keyword and(refine or color)then style=context.style or context.keyword end
 local free=lower:find('grátis',1,true)or lower:find('gratis',1,true)or lower:find('free',1,true)
 if not style then
  style=lower:gsub('[%c<>]',''):gsub('cria[r]?',''):gsub('quero',''):gsub('look',''):gsub('skin',''):gsub('roupa',''):gsub('robux',''):gsub('%d+',''):gsub('%s+',' '):match('^%s*(.-)%s*$'):sub(1,48)
  if #style<4 or style=='um' or style=='uma'or style=='barato'then return nil,'Qual estilo você quer? Diga, por exemplo, “emo preto”, “meme” ou “fofo”. Confirme 0 Robux para buscar peças grátis.'end
 end
 color=color or(context and refine and context.color)or''
 local keyword=style;if color~=''and not keyword:find(color,1,true)then keyword=keyword..' '..color end
 local scope
 if lower:find('só',1,true)or lower:find('so ',1,true)or lower:find('only',1,true)then
  if lower:find('cabelo',1,true)or lower:find('hair',1,true)then scope='Cabelo'
  elseif lower:find('roupa',1,true)or lower:find('clothes',1,true)then scope='Roupas'
  elseif lower:find('acess',1,true)then scope='Acessórios'end
 end
 return{answer='Vou procurar '..keyword..'. As opções confirmadas definem o orçamento e o que será preservado; você verá as peças e a prévia antes de usar.',keyword=keyword,style=style,color=color,language='pt',free=free~=nil,scope=scope,cheaper=lower:find('barato',1,true)~=nil or lower:find('cheaper',1,true)~=nil}
end
function E.Help(raw)
 local s=tostring(raw):lower()
 if s:find('fly',1,true)or s:find('voar',1,true)then return'Digite /fly no chat para voar e /unfly para pousar. Em partidas, comandos de movimento ficam desativados.'end
 if s:find('foto',1,true)or s:find('photo',1,true)then return'No Photo Mode, Fundos abre a loja para testar ou comprar. Emotes anima a cópia do avatar. Pose edita articulações; Câmera controla o enquadramento. Em Foto, tire a foto e depois salve pela galeria do Roblox.'end
 if s:find('salv',1,true)or s:find('looks',1,true)then return'No Catálogo, toque Salvar e escolha o nome. Abra Meus looks para reencontrar a combinação. Se a leitura estiver pendente, use Recarregar; evite salvar outra cópia enquanto a anterior não for confirmada.'end
 if s:find('truco',1,true)then return'Escolha a variante antes de começar. Cada jogador tem três cartas; você pode escolher qualquer carta da mão. As duplas são marcadas na mesa. TRUCO aumenta o valor da mão; quem recebe o pedido tem dez segundos para aceitar, aumentar ou correr.'end
 if s:find('corpo',1,true)or s:find('camada',1,true)then return'Corpos de pacote e roupas em camadas precisam de R15. Experimente no Catálogo e confira o personagem no mapa. Se falhar, o aviso da aplicação identifica a etapa; o Output tem o diagnóstico por item.'end
 if s:find('patroc',1,true)or s:find('destaq',1,true)then return'Patrocinar é gratuito: pesquise nome ou ID, confira o item pago e publique por 24 horas. Um envio por pessoa; favoritos não dão prioridade.'end
 if s:find('filtro',1,true)then return'Escolha uma categoria e a subcategoria destacada. Em Filtros, deixe preços vazios para todos ou defina mínimo/máximo; escolha roupas 2D/3D e toque Aplicar filtros. Itens pagos aparecem primeiro; grátis têm opção própria.'end
 return'Posso buscar looks por estilo, cor e orçamento e ajudar com catálogo, Meus looks, Photo Mode, Truco, patrocínio e comandos. Experimente “look emo preto” em Criar look ou “como salvar meu look?” em Pedir ajuda.'
end
return E
