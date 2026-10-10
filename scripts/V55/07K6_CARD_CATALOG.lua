-- 07K6_CARD_CATALOG | ModuleScript | ReplicatedStorage | V55
-- Criações originais. Cosméticos não modificam ranks, naipes ou probabilidades.
local C={}
C.DirectPurchasesOnly=true
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
 Salem=3717699522,Onyx=3716298994,Vesper=3716299051,Hex=3716299236,
 Aurum=3716300186,Valor=3716300285,Aether=3716300668,Nova=3716300484}
C.HalloweenEnds=1793664000 -- Oferta até 02/11/2026 23:59 UTC; quem adquiriu mantém.
function C.Available(style)return style~="Salem"or os.time()<C.HalloweenEnds end
C.Styles={
 Salem={name="Salem",collection="Halloween",coins=900,suggestedRobux=10,colors={{246,238,218},{153,80,33}},motif="pumpkin",limited=true},
 Classic={name="Clássico",collection="Classic",coins=0,colors={{243,237,225},{34,48,50}},motif="lines"},
 Onyx={name="Onyx",collection="Nox",coins=500,suggestedRobux=15,colors={{240,238,231},{46,52,64}},motif="diamond"},
 Vesper={name="Veyra",collection="Nox",coins=500,suggestedRobux=15,colors={{245,236,241},{119,84,145}},motif="orbit"},
 Hex={name="Nyxar",collection="Nox",coins=500,suggestedRobux=15,colors={{231,239,228},{51,102,72}},motif="grid"},
 Regent={name="Regent",collection="Reign",coins=1200,suggestedRobux=35,colors={{247,229,218},{139,44,48}},motif="crown"},
 Aurum={name="Aurum",collection="Reign",coins=1200,suggestedRobux=35,colors={{248,240,208},{141,98,27}},motif="diamond"},
 Valor={name="Valor",collection="Reign",coins=1200,suggestedRobux=35,colors={{231,240,245},{52,87,140}},motif="crest"},
 Zenith={name="Zenith",collection="Eclipse",coins=2500,suggestedRobux=65,colors={{232,237,246},{44,60,111}},motif="orbit"},
 Aether={name="Vaelis",collection="Eclipse",coins=2500,suggestedRobux=65,colors={{240,229,242},{128,82,137}},motif="wings"},
 Nova={name="Nova",collection="Eclipse",coins=2500,suggestedRobux=65,colors={{251,235,218},{171,80,43}},motif="star"},
}
C.Designs={Salem="Edição Halloween · papel creme e abóboras · visual permanente",Classic="Papel marfim · leitura clássica",Onyx="Facetas de obsidiana · contraste",Vesper="Lua e órbitas · tema noturno",Hex="Trevo jade · gravura botânica",Regent="Coroa rubi · ornamentos simétricos",Aurum="Art déco dourado · gravura",Valor="Escudo azul · heráldica",Zenith="Noite azul · estrelas gravadas",Aether="Plumas violeta · traço delicado",Nova="Sol terracota · impressão quente",Custom="Sua imagem · enquadramento livre"}
function C.Name(style)return style=="Custom"and"Ateliê"or C.Styles[style]and C.Styles[style].name or tostring(style)end
function C.Collection(id)for _,v in ipairs(C.Collections)do if v.id==id then return v end end end
function C.PassFor(style)for id,s in pairs(C.Passes)do if s==style then return id end end end
function C.Covered(data,style)
 local s=C.Styles[style];local box=s and C.Collection(s.collection);if not box then return false end
 local remaining=0;for _,key in ipairs(box.skins)do if not data.owned[key]then remaining=remaining+1 end end
 return remaining<=(data.boxes[box.id]or 0)
end
return C
