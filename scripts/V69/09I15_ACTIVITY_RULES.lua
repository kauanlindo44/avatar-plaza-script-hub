-- 09I15_ACTIVITY_RULES | ModuleScript | ReplicatedStorage | V69 (NOVO)
-- Atividades de cocriação guiada pelo planejador local, sem serviço generativo pago.
local Styles=require(game:GetService('ReplicatedStorage'):WaitForChild('09I8_AVATAR_STYLES'))
local M={Version='V69'}
M.Activities={
 {id='collab',name='Look em colaboração',note='Convide até 3 pessoas. Cada uma contribui com peças; o assistente sugere uma base.',icon='people',max=4},
 {id='duo',name='Duplas com personalidade',note='Uma paleta em comum, estilos individuais e dois looks diferentes.',icon='avatar',max=2},
 {id='shoot',name='Ensaio temático',note='Um roteiro de três fotos com enquadramentos e poses para experimentar.',icon='camera',max=4},
 {id='remix',name='Remix autorizado',note='Reinterprete uma combinação compartilhada, com permissão e crédito ao original.',icon='outfits',max=1}}
M.Palettes={{id='free',name='Cores livres',color=''},{id='forest',name='Bosque · verde',color='green'},{id='sea',name='Mar · azul',color='blue'},
 {id='rose',name='Jardim · rosa',color='pink'},{id='ink',name='Contraste · preto',color='black'},{id='light',name='Luz · branco',color='white'},
 {id='autumn',name='Outono · laranja',color='orange'},{id='violet',name='Violeta · roxo',color='purple'}}
function M.Activity(id)for _,v in ipairs(M.Activities)do if v.id==id then return v end end end
function M.Palette(id)for _,v in ipairs(M.Palettes)do if v.id==id then return v end end;return M.Palettes[1]end
function M.Settings(raw)
 raw=type(raw)=='table'and raw or{};local style=Styles.Get(raw.style)or Styles.Get('casual')
 local n=tonumber(raw.budget);if not n or n~=n then n=100 end
 return{style=style.id,budget=math.clamp(math.floor(n),0,100000),palette=M.Palette(raw.palette).id,format=raw.format=='3D'and'3D'or'2D'}
end
function M.Prompt(settings)
 local style=Styles.Get(settings.style);local palette=M.Palette(settings.palette)
 return{keyword=style.query..(palette.color~=''and(' '..palette.color)or''),label=style.name,color=palette.color,
  note=palette.color==''and'Escolha suas cores; mantenha uma peça como ponto de atenção.'or('A cor '..palette.name..' conecta os looks. Cada pessoa mantém seu estilo.')}
end
function M.Rehearsal(settings)
 local style=Styles.Get(settings.style);return{
  {title='1 · Apresentação',text='Mostre o look '..style.name..' de frente. Deixe espaço ao redor e escolha um fundo que contraste com as roupas.',frame='FULL',yaw=0,zoom=1},
  {title='2 · Perfil e detalhes',text='Vire para o lado e mostre a sobreposição das peças. Teste um emote; pause quando encontrar uma pose.',frame='FULL',yaw=55,zoom=1.1},
  {title='3 · Sua assinatura',text='Escolha sua expressão ou pose favorita. Confira cabelo, acessórios e luz; tire a foto quando estiver satisfeito.',frame='FULL',yaw=340,zoom=1.05}}
end
M.Slots={{id='top',name='Parte de cima'},{id='bottom',name='Parte de baixo'},{id='hair',name='Cabelo'},{id='accessories',name='Acessórios'}}
return M
