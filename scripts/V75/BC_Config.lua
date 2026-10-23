-- BC_Config | ModuleScript | ReplicatedStorage | V75 (SUBSTITUIR)
-- Parâmetros da V1 aprovada; sorteio, vida, dano e cronômetros pertencem ao servidor.
local C={Version=1,MinPlayers=2,MaxPlayers=8,Intermission=12,Countdown=5,Duration=150,Training=90,Results=10,
 FirstButton=4,NextButton=8,ButtonTimeout=15,PromptDistance=5,PressDistance=6,Size=128,Width=128,Depth=88,Center=Vector3.new(0,6000,0),
 Health=100,Speed=16,Slow=9,Fast=24,PressPoints=1,KillPoints=2,WinPoints=5,SnapshotInterval=.25}
C.ButtonPositions={{22,0},{-22,0},{0,22},{0,-22},{20,20},{20,-20},{-20,20},{-20,-20}}
C.Spawns={{-36,-36},{0,-38},{36,-36},{38,0},{36,36},{0,38},{-36,36},{-38,0}}
C.PushDistance=6;C.PushCooldown=3;C.PushSpeed=25;C.PushLift=7;C.FallDepth=16
C.Audio={Explosion='rbxassetid://9125615451',Foam='rbxassetid://9125615451'}
C.CueVolume=.18
C.Palette={Floor=Color3.fromRGB(104,167,83),Surface=Color3.fromRGB(226,236,239),Ink=Color3.fromRGB(31,47,64),
 Cyan=Color3.fromRGB(39,196,255),Gold=Color3.fromRGB(255,206,75),Danger=Color3.fromRGB(255,94,108),Violet=Color3.fromRGB(155,125,255)}
C.Effects={
 {id='E01',name='Blaster de energia',weight=14,desc='3 disparos · 35 de dano · 12 s',duration=12},
 {id='E02',name='Bomba de espuma',weight=8,desc='1 lançamento · 45 de dano · também pode atingir você',duration=10},
 {id='E03',name='Bomba Nuclear',weight=4,target=true,nuclear=true,desc='Um adversário marcado · 4 s para a explosão'},
 {id='E04',name='Congelamento',weight=12,target=true,desc='Um adversário sem andar por 3 s',duration=3},
 {id='E05',name='Supervelocidade',weight=12,desc='Velocidade 24 por 9 s',duration=9},
 {id='E06',name='Escudo de proteção',weight=10,desc='Bloqueia um dano ou bomba nuclear · 12 s',duration=12},
 {id='E07',name='Troca de posições',weight=10,target=true,desc='Troca segura com um adversário · proteção de 0,75 s'},
 {id='E08',name='Superpulo',weight=8,desc='Salto 1,8× por 8 s',duration=8},
 {id='E09',name='Onda de impacto',weight=8,target=true,desc='Empurra adversários próximos · sem dano'},
 {id='E10',name='Botão traiçoeiro',weight=6,desc='Sua velocidade cai para 9 por 5 s',duration=5},
 {id='E11',name='Cura surpresa',weight=4,desc='Recupere até 50 de vida, no máximo 100'},
 {id='E12',name='Apagão',weight=4,desc='Visibilidade reduzida por 5 s · interface legível',duration=5}}
return C
