-- 07K6_CARD_CATALOG | ModuleScript | ReplicatedStorage | V48
-- Criações originais. Cosméticos não modificam ranks, naipes ou probabilidades.
local C={}
C.RandomPurchasesEnabled=false -- Escolha conhecida neste jogo acessível a menores; não há sorteio.
C.CustomPass=1951234105
C.Passes={[1962433436]="Regent",[1966813498]="Zenith"}
C.Collections={
 {id="Nox",coins=500,suggestedRobux=15,skins={"Onyx","Vesper","Hex"}},
 {id="Reign",coins=1200,suggestedRobux=35,skins={"Regent","Aurum","Valor"}},
 {id="Eclipse",coins=2500,suggestedRobux=65,skins={"Zenith","Aether","Nova"}},
}
-- IDs conferidos nas imagens do criador. Éter Visual (3716300364) foi desativado e não é usado.
-- Chaves antigas preservam inventários salvos; os nomes exibidos estão em Styles.
C.Products={Nox=3716296910,Reign=3716298871,Eclipse=3716298939,
 Onyx=3716298994,Vesper=3716299051,Hex=3716299236,
 Aurum=3716300186,Valor=3716300285,Aether=3716300668,Nova=3716300484}
C.Styles={
 Classic={name="Clássico",collection="Classic",coins=0,colors={{243,237,225},{34,48,50}},motif="lines"},
 Onyx={name="Onyx",collection="Nox",coins=500,suggestedRobux=15,colors={{22,27,43},{112,144,180}},motif="diamond"},
 Vesper={name="Veyra",collection="Nox",coins=500,suggestedRobux=15,colors={{36,24,65},{187,137,223}},motif="orbit"},
 Hex={name="Nyxar",collection="Nox",coins=500,suggestedRobux=15,colors={{17,39,40},{84,198,178}},motif="grid"},
 Regent={name="Regent",collection="Reign",coins=1200,suggestedRobux=35,colors={{42,25,37},{238,194,117}},motif="crown"},
 Aurum={name="Aurum",collection="Reign",coins=1200,suggestedRobux=35,colors={{46,36,20},{250,214,124}},motif="diamond"},
 Valor={name="Valor",collection="Reign",coins=1200,suggestedRobux=35,colors={{30,39,60},{187,206,242}},motif="crest"},
 Zenith={name="Zenith",collection="Eclipse",coins=2500,suggestedRobux=65,colors={{18,26,61},{159,221,246}},motif="orbit"},
 Aether={name="Vaelis",collection="Eclipse",coins=2500,suggestedRobux=65,colors={{42,26,71},{235,191,249}},motif="wings"},
 Nova={name="Nova",collection="Eclipse",coins=2500,suggestedRobux=65,colors={{55,22,37},{255,186,155}},motif="star"},
}
function C.Name(style)return style=="Custom"and"Ateliê"or C.Styles[style]and C.Styles[style].name or tostring(style)end
function C.Collection(id)for _,v in ipairs(C.Collections)do if v.id==id then return v end end end
function C.PassFor(style)for id,s in pairs(C.Passes)do if s==style then return id end end end
function C.Covered(data,style)
 local s=C.Styles[style];local box=s and C.Collection(s.collection);if not box then return false end
 local remaining=0;for _,key in ipairs(box.skins)do if not data.owned[key]then remaining=remaining+1 end end
 return remaining<=(data.boxes[box.id]or 0)
end
return C
