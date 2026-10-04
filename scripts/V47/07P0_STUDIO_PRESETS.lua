-- 07P0_STUDIO_PRESETS | ModuleScript | ReplicatedStorage
-- V47: cinco ambientes originais, com cenografia em camadas e movimento.
local M={}
M.Backgrounds={
 {id="STUDIO",name="Galeria Aurora",a=Color3.fromRGB(137,159,180),b=Color3.fromRGB(219,215,205),accent=Color3.fromRGB(248,210,142)},
 {id="SKY",name="Ilhas Celestes",a=Color3.fromRGB(90,157,214),b=Color3.fromRGB(159,207,215),accent=Color3.fromRGB(239,245,255)},
 {id="SUNSET",name="Costa Dourada",a=Color3.fromRGB(182,106,147),b=Color3.fromRGB(210,153,133),accent=Color3.fromRGB(255,218,149)},
 {id="GARDEN",name="Jardim Sakura",a=Color3.fromRGB(105,154,147),b=Color3.fromRGB(157,187,158),accent=Color3.fromRGB(247,203,219)},
 {id="NIGHT",name="Cidade Prisma",a=Color3.fromRGB(46,57,91),b=Color3.fromRGB(88,100,133),accent=Color3.fromRGB(136,211,238)}
}
M.Lights={
 {id="SOFT",name="Suave",ambient=Color3.fromRGB(197,206,222),light=Color3.fromRGB(248,250,255),dir=Vector3.new(-.5,-1,-.4)},
 {id="BRIGHT",name="Claro",ambient=Color3.fromRGB(222,230,240),light=Color3.fromRGB(255,255,255),dir=Vector3.new(-.5,-1,-.4)},
 {id="WARM",name="Quente",ambient=Color3.fromRGB(207,200,188),light=Color3.fromRGB(255,232,210),dir=Vector3.new(-.7,-1,-.4)},
 {id="COOL",name="Frio",ambient=Color3.fromRGB(181,204,225),light=Color3.fromRGB(224,239,255),dir=Vector3.new(.7,-1,-.6)}
}
M.Frames={{id="FULL",name="Corpo inteiro"},{id="MEDIUM",name="Meio corpo"},{id="FACE",name="Rosto"}}
M.Motions={{id="STATIC",name="Parado"},{id="ORBIT",name="Órbita"}}
M.Durations={5,10,15,30};M.FeaturedEmotes={}
return M
