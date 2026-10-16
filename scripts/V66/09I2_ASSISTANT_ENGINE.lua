-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V66 (SUBSTITUIR)
-- Contexto de estilo e refinamentos; pesquisa real sem chave ou IDs inventados.
local Text=game:GetService('TextService');local E={Version='V66',Protocol=2,Available=true,Checked=os.clock(),Language='pt',RetryAt=0}
local Rep=game:GetService('ReplicatedStorage');local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'));local Guide=require(Rep:WaitForChild('09I9_GAME_GUIDE'))
local colors={{'cinza','gray'},{'amarelo','yellow'},{'marrom','brown'},{'bege','beige'},{'dourado','gold'},{'prata','silver'},{'preto','black'},{'black','black'},{'branco','white'},{'white','white'},{'roxo','purple'},{'purple','purple'},{'rosa','pink'},{'pink','pink'},{'vermelho','red'},{'red','red'},{'azul','blue'},{'blue','blue'},{'verde','green'},{'green','green'},{'laranja','orange'},{'orange','orange'}}
local function contains(text,word)return text:find('%f[%w]'..word..'%f[%W]')~=nil end
function E.Health()E.Available=true;E.Checked=os.clock();return true end
function E.Summary()return'Planejador de looks • pesquisa Roblox com contexto • sem modelo externo'end
function E.Ask(pl,raw,context,selectedStyle)
 local ok,clean=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForBroadcastAsync()end)
 if not ok or not clean or clean:match('^%s*#+%s*$')then return nil,'O Roblox filtrou esse pedido. Descreva o estilo com outras palavras.'end
 local lower=Styles.Normalize(clean);local style,color
 local matched=Styles.Get(selectedStyle)or Styles.Find(lower);if matched then style=matched.query end
 for _,s in ipairs(colors)do if contains(lower,s[1])then color=s[2];break end end
 local refine=lower:find('mais',1,true)or lower:find('troca',1,true)or lower:find('mudar',1,true)or lower:find('outro',1,true)or lower:find('same',1,true)or lower:find('cheaper',1,true)
 if not style and context and context.keyword and(refine or color)then style=context.style or context.keyword end
 local free=lower:find('grátis',1,true)or lower:find('gratis',1,true)or lower:find('free',1,true)
 if not style and free then style='casual'end
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
function E.Help(raw)return Guide.Answer(raw)end
function E.IsHelp(raw)return Guide.IsQuestion(raw)end
return E
