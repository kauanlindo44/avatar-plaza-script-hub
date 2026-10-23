-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V75 (SUBSTITUIR)
-- Contexto de estilo e refinamentos; pesquisa real sem chave ou IDs inventados.
local Text=game:GetService('TextService');local E={Version='V75',Protocol=2,Available=true,Checked=os.clock(),Language='pt',RetryAt=0}
local Rep=game:GetService('ReplicatedStorage');local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'));local Guide=require(Rep:WaitForChild('09I9_GAME_GUIDE'))
local Plan=require(Rep:WaitForChild('09I12_REQUEST_PLAN'))
function E.Health()E.Available=true;E.Checked=os.clock();return true end
function E.Summary()return'Planejador de looks • pesquisa Roblox com contexto • sem modelo externo'end
function E.Ask(pl,raw,context,selectedStyle,opts)
 local ok,clean=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForBroadcastAsync()end)
 if not ok or not clean or clean:match('^%s*#+%s*$')then return nil,'O Roblox filtrou esse pedido. Descreva o estilo com outras palavras.'end
 local p=Plan.Parse(clean,context);opts=opts or{}
 local selected=Styles.Get(selectedStyle)
 if selected and(opts.styleEdited or not Styles.Find(clean))then p.query=selected.query;p.style=selected.id;p.styleName=selected.name end
 if opts.confirmed then p.color=opts.color or'';p.scope=opts.scope or p.scope;p.budget=opts.budget;p.count=opts.count;p.format=opts.format;p.excluded=opts.excluded or p.excluded end
 if opts.confirmed and type(opts.query)=='string'and opts.query:match('%S')then local good,value=pcall(function()return Text:FilterStringAsync(opts.query,pl.UserId):GetNonChatStringForBroadcastAsync()end);if not good or not value or value:match('^%s*#+%s*$')then return nil,'O Roblox não confirmou o texto do pedido. Ajuste a descrição.'end;p.query=value end
 for _,color in ipairs(p.excludedColors or{})do if color==p.color then return nil,'A mesma cor foi pedida e excluída. Revise a cor antes de criar.'end end
 local query=p.query or'casual';if p.color and p.color~=''and not query:find(p.color,1,true)then query=query..' '..p.color end
 return{excludedColors=p.excludedColors,answer='Vou buscar '..(p.styleName or p.query)..'. Vou conferir as roupas, os preços e a aparência antes de mostrar os resultados.',keyword=query,style=p.query,styleId=p.style,color=p.color or'',language='pt',free=p.budget==0,scope=p.scope,cheaper=p.cheaper,plan=p}
end
function E.Help(raw,previous)
 local text=Styles.Normalize(raw);local topic=Guide.Find(text)
 local stuck=text:find('nao abre',1,true)or text:find('travou',1,true)
 if stuck and(text:find('%f[%w]ia%f[%W]')or text:find('assistente',1,true))then
  return'Acesse IA de looks na lateral da praça e toque em Reconectar. A conversa abre mesmo quando a consulta de planos está indisponível. Se uma busca parar, use Cancelar e tente novamente; os looks salvos continuam disponíveis.',previous
 elseif stuck and topic then return topic.name..'\n\n'..topic.answer..'\n\nSe a tela não responder, feche-a e abra novamente.',topic.id end
 if text:find('empurr',1,true)then return'No Botão do Caos, chegue a até 6 studs de outro participante, olhe para ele e toque em Empurrar. Espere 3 segundos entre tentativas. Quem cair da plataforma é eliminado. O escudo pode bloquear o empurrão.', 'chaos'end

 if text=='oi'or text=='ola'or text=='hello'or text=='oi tudo bem'or text=='tudo bem'then return'Olá! Posso montar um look com seu orçamento ou explicar as funções da praça. Você prefere criar um estilo ou precisa de ajuda com catálogo, fotos, música ou jogos?',previous end
 if text:find('obrigad',1,true)or text=='valeu'then return'Por nada! Podemos continuar ajustando seu look ou abrir outra função da praça. O que você quer fazer agora?',previous end
 if not topic and previous and(text:find('isso',1,true)or text:find('como faz',1,true)or text:find('e depois',1,true))then for _,v in ipairs(Guide.Topics)do if v.id==previous then topic=v;break end end end
 if topic then return topic.name..'\n\n'..topic.answer,topic.id end
 return'Posso ajudar com looks e com as funções deste jogo. Para uma combinação, diga o estilo, a cor e até quantos Robux pretende usar. Para uma dúvida, diga qual tela você abriu e o que tentou fazer. Exemplos: “streetwear azul até 100 Robux” ou “como testar um emote no catálogo?”.',previous
end
function E.IsHelp(raw)return not Guide.IsLookRequest(raw)end
return E
