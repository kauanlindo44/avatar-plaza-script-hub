-- 07P0_STUDIO_PRESETS | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Cenários em blocos, pensados para roupa, retrato, dança e vídeo.
local M={}
M.Backgrounds={
 {id='STUDIO',name='Estúdio Editorial',use='Look e detalhes',a=Color3.fromRGB(215,208,220),b=Color3.fromRGB(236,230,219),accent=Color3.fromRGB(184,158,203)},
 {id='SKY',name='Céu de Algodão',use='Vídeo claro',a=Color3.fromRGB(184,215,240),b=Color3.fromRGB(219,233,242),accent=Color3.fromRGB(247,244,231)},
 {id='RUNWAY',name='Passarela',use='Mostrar o outfit',a=Color3.fromRGB(95,88,116),b=Color3.fromRGB(163,159,183),accent=Color3.fromRGB(234,206,156)},
 {id='GARDEN',name='Jardim de Outono',use='Vídeo acolhedor',a=Color3.fromRGB(184,203,183),b=Color3.fromRGB(217,214,190),accent=Color3.fromRGB(228,178,117)},
 {id='URBAN',name='Rua Criativa',use='Emotes e dança',a=Color3.fromRGB(162,178,196),b=Color3.fromRGB(204,199,191),accent=Color3.fromRGB(227,174,145)},
 {id='HALLOWEEN',name='Salem — Halloween',use='Vídeo de Halloween',a=Color3.fromRGB(134,119,157),b=Color3.fromRGB(207,181,151),accent=Color3.fromRGB(248,179,87)}
}
M.Lights={
 {id='BRIGHT',name='Claro',ambient=Color3.fromRGB(222,230,240),light=Color3.fromRGB(255,255,255),dir=Vector3.new(-.5,-1,-.4)},
 {id='SOFT',name='Suave',ambient=Color3.fromRGB(197,206,222),light=Color3.fromRGB(248,250,255),dir=Vector3.new(-.5,-1,-.4)},
 {id='WARM',name='Quente',ambient=Color3.fromRGB(207,200,188),light=Color3.fromRGB(255,232,210),dir=Vector3.new(-.7,-1,-.4)},
 {id='COOL',name='Frio',ambient=Color3.fromRGB(181,204,225),light=Color3.fromRGB(224,239,255),dir=Vector3.new(.7,-1,-.6)}
}
M.Frames={{id='FULL',name='Corpo inteiro'},{id='MEDIUM',name='Meio corpo'},{id='FACE',name='Rosto'}}
M.Motions={{id='STATIC',name='Parado'},{id='ORBIT',name='Girar avatar'}}
M.Durations={5,10,15,30};M.FeaturedEmotes={}
return M
