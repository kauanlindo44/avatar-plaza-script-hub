-- 07G5_CHAT_COMMANDS | ModuleScript | ReplicatedStorage | V75 (SUBSTITUIR)
-- Lista única para o chat e Configurações; somente ações pessoais.
return {
 {alias='/fly',key='fly',value=true,description='Voar com o joystick; pulo sobe, câmera inclinada dirige.'},
 {alias='/unfly',key='fly',value=false,description='Pousar e voltar ao movimento normal.'},
 {alias='/speed',key='speed',value=28,argument='16–32',description='Alterar sua velocidade. Exemplo: /speed 28.'},
 {alias='/walk',key='speed',value=16,description='Restaurar a velocidade normal.'},
 {alias='/jump',key='jump',value=72,argument='50–80',description='Alterar seu pulo. Exemplo: /jump 72.'},
 {alias='/unjump',key='jump',value=50,description='Restaurar o pulo normal.'},
 {alias='/size',key='size',value=1.1,argument='0.9–1.15',description='Mudar apenas seu tamanho. Exemplo: /size 1.1.'},
 {alias='/unsize',key='size',value=1,description='Restaurar seu tamanho normal.'},
 {alias='/normal',key='reset',description='Parar voo e restaurar movimento/tamanho.'},
 {alias='/fov',key='camera',value=70,argument='60–90',description='Ajustar sua câmera. Exemplo: /fov 80.'},
 {alias='/catalog',key='open',value='Catalog',description='Abrir o catálogo de avatares.'},
 {alias='/photo',key='open',value='Photo',description='Abrir o Photo Mode.'},
 {alias='/music',key='open',value='Music',description='Abrir o player de música.'},
 {alias='/commands',key='help',description='Abrir a janela com a lista de comandos.'}
}
