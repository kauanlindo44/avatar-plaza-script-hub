-- 07P0_STUDIO_PRESETS | ModuleScript | ReplicatedStorage
-- V43: cinco cenarios para fotos com contraste equilibrado.
local M={}
M.Backgrounds={
 {id="STUDIO",name="Estúdio editorial",a=Color3.fromRGB(124,137,159),b=Color3.fromRGB(170,182,199),accent=Color3.fromRGB(221,231,247)},
 {id="SKY",name="Nuvens de verão",a=Color3.fromRGB(91,160,214),b=Color3.fromRGB(150,198,222),accent=Color3.fromRGB(230,244,248)},
 {id="SUNSET",name="Horizonte solar",a=Color3.fromRGB(180,114,140),b=Color3.fromRGB(225,170,135),accent=Color3.fromRGB(255,223,171)},
 {id="GARDEN",name="Jardim de luz",a=Color3.fromRGB(99,147,132),b=Color3.fromRGB(156,185,156),accent=Color3.fromRGB(215,231,190)},
 {id="NIGHT",name="Portal neon",a=Color3.fromRGB(63,71,115),b=Color3.fromRGB(103,104,148),accent=Color3.fromRGB(187,197,249)}
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
