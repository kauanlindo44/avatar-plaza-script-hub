-- 07K1_TRUCO_AI | ModuleScript | ReplicatedStorage | V44
-- Recebe só visão pública + mão própria. Não acessa cartas dos adversários.
local R=require(script.Parent:WaitForChild("07K0_TRUCO_RULES"))
local AI={}
local function power(v,c)return R.Power(c,v.variant,v.vira)end
local function random(n,rng)return rng and rng(n)or math.random(n)end
function AI.Choose(v,level,rng)
 level=level or"Médio";local easy=level=="Fácil";local hard=level=="Difícil";local own=R.Team(v.seat)
 if v.phase=="cut"then return"cut",20 end
 if v.phase=="dealing"then return"deal","top"end
 local strength=0;for _,c in ipairs(v.hand)do strength=strength+math.max(0,power(v,c))/24 end
 if v.phase=="special"then return"special",easy and random(2,rng)==1 or strength>.62 end
 if v.phase=="raise"then
  if easy then return"respond",random(3,rng)==1 and"run"or"accept"end
  local threshold=v.pending.value>=9 and 1.05 or .56
  if strength<threshold then return"respond","run"end
  if hard and strength>1.55 and v.pending.value<12 then return"respond","raise"end
  return"respond","accept"
 end
 if easy or v.iron then return"play",random(math.max(1,#v.hand),rng)end
 if not v.specialTeam and v.nextRaise and v.raiseOwner~=own and strength>(hard and 1.32 or 1.75)then return"raise"end
 local seen={};for _,c in ipairs(v.hand)do seen[c.id]=true end
 for _,p in ipairs(v.used or{})do if not p.card.covered then seen[p.card.id]=true end end
 if v.vira then seen[v.vira.id]=true end
 local unseen={};for _,c in ipairs(R.Deck())do if not seen[c.id]then table.insert(unseen,c)end end
 local bestTable=-2;local tableTeam=nil
 for _,p in ipairs(v.tableCards or{})do local n=power(v,p.card);if n>bestTable then bestTable=n;tableTeam=R.Team(p.seat)elseif n==bestTable then tableTeam=nil end end
 local selected=1;local score=-math.huge
 for i,c in ipairs(v.hand)do
  local n=power(v,c);local value=tableTeam==own and -n or(n>bestTable and 32-n or -n-16)
  if #v.tableCards==0 then value=n end
  if hard and #unseen>0 then
   local wins=0;local samples=96
   for _=1,samples do
    local strongest=bestTable
    for _=1,math.max(0,3-#v.tableCards)do local other=unseen[random(#unseen,rng)];strongest=math.max(strongest,power(v,other))end
    if n>strongest or tableTeam==own and bestTable==strongest then wins=wins+1 end
   end
   value=value+wins/samples*18
  end
  if value>score then score=value;selected=i end
 end
 return"play",selected
end
return AI
