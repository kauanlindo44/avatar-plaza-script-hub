-- 07P0_STUDIO_PRESETS | ModuleScript | ReplicatedStorage | V58 (SUBSTITUIR)
-- Cenários em blocos, pensados para roupa, retrato, dança e vídeo.
local M={}
M.Backgrounds={
 {id='STUDIO',name='Estúdio Editorial',use='Look e detalhes',a=Color3.fromRGB(215,208,220),b=Color3.fromRGB(236,230,219),accent=Color3.fromRGB(184,158,203)},
 {id='SKY',name='Céu de Algodão',use='Vídeo claro',a=Color3.fromRGB(184,215,240),b=Color3.fromRGB(219,233,242),accent=Color3.fromRGB(247,244,231)},
 {id='RUNWAY',name='Passarela',use='Mostrar o outfit',a=Color3.fromRGB(95,88,116),b=Color3.fromRGB(163,159,183),accent=Color3.fromRGB(234,206,156)},
 {id='GARDEN',name='Jardim de Outono',use='Vídeo acolhedor',a=Color3.fromRGB(184,203,183),b=Color3.fromRGB(217,214,190),accent=Color3.fromRGB(228,178,117)},
 {id='URBAN',name='Rua Criativa',use='Emotes e dança',a=Color3.fromRGB(162,178,196),b=Color3.fromRGB(204,199,191),accent=Color3.fromRGB(227,174,145)},
 {id='HALLOWEEN',name='Salem',use='Halloween em vídeo',dark=true,a=Color3.fromRGB(36,31,54),b=Color3.fromRGB(62,55,67),accent=Color3.fromRGB(247,155,62)},
 {id='GRAPHITE',name='Grafite',use='Roupa em destaque',dark=true,a=Color3.fromRGB(39,43,49),b=Color3.fromRGB(61,65,70),accent=Color3.fromRGB(208,215,227)},
 {id='NEON',name='Rua Neon',use='Dança e vídeo urbano',dark=true,a=Color3.fromRGB(30,39,56),b=Color3.fromRGB(46,51,64),accent=Color3.fromRGB(98,187,201)},
 {id='ROOFTOP',name='Terraço',use='Retrato noturno',dark=true,a=Color3.fromRGB(32,40,64),b=Color3.fromRGB(66,69,81),accent=Color3.fromRGB(169,185,224)},
 {id='LIBRARY',name='Biblioteca',use='Looks góticos',dark=true,a=Color3.fromRGB(44,34,47),b=Color3.fromRGB(67,49,48),accent=Color3.fromRGB(209,174,112)}
}
M.Lights={
 {id='BRIGHT',name='Claro',ambient=Color3.fromRGB(222,230,240),light=Color3.fromRGB(255,255,255),dir=Vector3.new(-.5,-1,-.4)},
 {id='SOFT',name='Suave',ambient=Color3.fromRGB(197,206,222),light=Color3.fromRGB(248,250,255),dir=Vector3.new(-.5,-1,-.4)},
 {id='WARM',name='Quente',ambient=Color3.fromRGB(207,200,188),light=Color3.fromRGB(255,232,210),dir=Vector3.new(-.7,-1,-.4)},
 {id='COOL',name='Frio',ambient=Color3.fromRGB(181,204,225),light=Color3.fromRGB(224,239,255),dir=Vector3.new(.7,-1,-.6)}
}
M.Frames={{id='FULL',name='Corpo inteiro'},{id='MEDIUM',name='Meio corpo'},{id='FACE',name='Rosto'}}
M.Motions={{id='STATIC',name='Parado'},{id='ORBIT',name='Orbitar câmera'},{id='AVATAR',name='Girar avatar'},{id='ZOOM',name='Zoom suave'},{id='PAN',name='Travelling lateral'}}
M.Durations={5,10,15,30};M.FeaturedEmotes={}
return M
