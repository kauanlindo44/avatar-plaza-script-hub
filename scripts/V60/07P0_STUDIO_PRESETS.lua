-- 07P0_STUDIO_PRESETS | ModuleScript | ReplicatedStorage | V60 (SUBSTITUIR)
-- Fundos consultados no inventário Roblox; luz/câmera/movimentos preservados.
local M={}
M.Backgrounds={} -- Preenchidos pela consulta nativa; nenhuma imagem inventada.
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
