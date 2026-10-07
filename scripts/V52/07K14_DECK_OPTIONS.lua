-- 07K14_DECK_OPTIONS | ModuleScript | ReplicatedStorage | V52 (NOVO)
-- Baralhos oficiais separados das mesas personalizadas.
local M={Ranks={"4","5","6","7","8","9","10","Q","J","K","A","2","3"},Suits={"D","S","H","C"}}
local standard={"4","5","6","7","Q","J","K","A","2","3"}
function M.Clean(raw,variant,customAllowed)
 raw=type(raw)=="table"and raw or{}
 local mode=raw.mode or"Full";if mode~="Full"and mode~="Clean"and mode~="Custom"then return nil,"Baralho inválido."end
 if mode=="Custom"and not customAllowed then return nil,"Partida rápida usa baralho cheio ou limpo."end
 local ranks={};local suits={};local seen={}
 if mode=="Custom"then
  if type(raw.ranks)~="table"or #raw.ranks>13 or type(raw.suits)~="table"or #raw.suits>4 then return nil,"Seleção de cartas inválida."end
  for _,key in ipairs(raw.ranks)do if not table.find(M.Ranks,key)or seen[key]then return nil,"Carta inválida ou repetida."end;seen[key]=true end
  for _,key in ipairs(M.Ranks)do if seen[key]then ranks[#ranks+1]=key end end;seen={}
  for _,key in ipairs(raw.suits)do if not table.find(M.Suits,key)or seen[key]then return nil,"Naipe inválido ou repetido."end;seen[key]=true end
  for _,key in ipairs(M.Suits)do if seen[key]then suits[#suits+1]=key end end
 else
  for _,key in ipairs(standard)do if mode=="Full"or table.find({"Q","J","K","A","2","3"},key)then ranks[#ranks+1]=key end end
  suits={"D","S","H","C"}
 end
 if #ranks*#suits<13 then return nil,"Escolha pelo menos 13 cartas para distribuir e virar."end
 -- O limpo mineiro conserva suas quatro manilhas fixas.
 local extra={}
 if variant=="Mineiro"and mode=="Clean"then extra={{rank="4",suit="C"},{rank="7",suit="H"},{rank="7",suit="D"}}end
 local key=mode..":"..table.concat(ranks,",")..":"..table.concat(suits,",")
 return{mode=mode,ranks=ranks,suits=suits,extra=extra,key=key,count=#ranks*#suits+#extra,custom=mode=="Custom"}
end
function M.Deck(options,rng)
 local deck={};for _,rank in ipairs(options.ranks)do for _,suit in ipairs(options.suits)do deck[#deck+1]={rank=rank,suit=suit,id=rank..suit}end end
 for _,c in ipairs(options.extra or{})do deck[#deck+1]={rank=c.rank,suit=c.suit,id=c.rank..c.suit}end
 if rng then for i=#deck,2,-1 do local j=rng(i);deck[i],deck[j]=deck[j],deck[i]end end
 return deck
end
function M.Manilha(vira,options)
 if not vira then return end
 local ranks=options and options.ranks or standard;local i=table.find(ranks,vira.rank)
 return i and ranks[i%#ranks+1]
end
return M
