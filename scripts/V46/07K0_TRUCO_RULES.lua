-- 07K0_TRUCO_RULES | ModuleScript | ReplicatedStorage | V46
-- Perfis documentados: Paulista CAASP/ATB, Mineiro Copag, Goiano APCEF-GO.
-- Pontos são placar esportivo. Não há apostas, fichas ou dinheiro em disputa.
local R={}
function R.CallName(value)return({[3]="TRUCO!",[4]="TRUCO!",[6]="SEIS!",[9]="NOVE!",[10]="DEZ!",[12]="DOZE!"})[value]or"TRUCO!"end
R.Profiles={
 Paulista={name="Paulista",base=1,raises={3,6,9,12},special=11,specialValue=3,dynamic=true,ties="ATB",manual=true},
 Mineiro={name="Mineiro",base=2,raises={4,6,10,12},special=10,specialValue=4,dynamic=false,ties="Copag",manual=false},
 Goiano={name="Goiano",base=1,raises={3,6,9,12},special=11,specialValue=3,dynamic=true,ties="ATB",manual=true},
}
R.Ranks={"4","5","6","7","Q","J","K","A","2","3"}
R.Suits={"D","S","H","C"}
local order={};for i,v in ipairs(R.Ranks)do order[v]=i end
local suits={D=1,S=2,H=3,C=4};local fixed={["4C"]=24,["7H"]=23,["AS"]=22,["7D"]=21}
function R.Team(seat)return seat%2==1 and 1 or 2 end
function R.Next(seat)return seat%4+1 end
function R.Deck(rng)
 local deck={};for _,rank in ipairs(R.Ranks)do for _,suit in ipairs(R.Suits)do table.insert(deck,{rank=rank,suit=suit,id=rank..suit})end end
 if rng then for i=#deck,2,-1 do local j=rng(i);deck[i],deck[j]=deck[j],deck[i]end end
 return deck
end
function R.Power(card,profile,vira)
 if not card or card.covered then return -1 end
 local p=type(profile)=="table"and profile or R.Profiles[profile]
 if not p then return -1 end
 if p.dynamic and vira and order[card.rank]==order[vira.rank]%10+1 then return 20+suits[card.suit]end
 if not p.dynamic and fixed[card.id]then return fixed[card.id]end
 return order[card.rank]or-1
end
function R.New(variant,dealer)
 local p=R.Profiles[variant]or R.Profiles.Paulista
 return {variant=p.name,score={0,0},dealer=dealer or 4,handNumber=0,phase="between",revision=0,plays=0}
end
local function changed(s)s.revision=s.revision+1 end
function R.Award(s,team,points,reason)
 if team then s.score[team]=math.min(12,s.score[team]+points)end
 s.last={team=team,points=team and points or 0,reason=reason}
 s.phase=team and s.score[team]>=12 and"finished"or"between";s.winner=s.phase=="finished"and team or nil
 s.pending=nil;changed(s);return true
end
function R.Begin(s,deck,manual)
 if s.phase~="between"then return false,"A mão anterior ainda está aberta."end
 local p=R.Profiles[s.variant];s.handNumber=s.handNumber+1
 s.deck=deck or R.Deck();s.hands={{},{},{},{}};s.tricks={};s.tableCards={};s.used={};s.audit={};s.fraud=nil;s.activeSeats=nil
 s.handSeat=R.Next(s.dealer);s.turn=s.handSeat;s.lead=s.handSeat;s.value=p.base;s.raiseOwner=nil;s.tieClaim=nil;s.pending=nil
 s.specialTeam=nil;s.iron=s.score[1]==p.special and s.score[2]==p.special
 if not s.iron then for t=1,2 do if s.score[t]==p.special then s.specialTeam=t;s.value=p.specialValue end end end
 s.dealSeat=s.handSeat;s.dealCount=0;s.dealSide=nil;s.vira=nil;s.reports={};s.lastTrick=nil
 s.phase=manual and p.manual and"cut"or"dealing";changed(s)
 if s.phase=="dealing"then for _=1,4 do R.Deal(s,s.dealer,"top")end end
 return true
end
function R.Cut(s,seat,count)
 if s.phase~="cut"or seat~=((s.dealer+2)%4+1)then return false,"O corte é do adversário à esquerda do carteador."end
 count=math.floor(tonumber(count)or 20);if count<1 or count>=#s.deck then return false,"Corte inválido."end
 local out={};for i=count+1,#s.deck do table.insert(out,s.deck[i])end;for i=1,count do table.insert(out,s.deck[i])end
 s.deck=out;s.phase="dealing";changed(s);return true
end
function R.Deal(s,seat,side)
 if s.phase~="dealing"or seat~=s.dealer then return false,"Aguarde sua carteada."end
 if side~="top"and side~="bottom"and side~="middle"then return false,"Origem inválida."end
 if not s.dealSide then s.dealSide=side=="bottom"and"bottom"or"top"end
 local illegal=side=="middle"or side~=s.dealSide
 if illegal then s.fraud={seat=seat,draw=s.dealCount+1,side=side};s.irregular=true end
 table.insert(s.audit,{seat=seat,to=s.dealSeat,side=side,declared=s.dealSide})
 for _=1,3 do
  local index=side=="bottom"and #s.deck or side=="middle"and math.ceil(#s.deck/2)or 1
  table.insert(s.hands[s.dealSeat],table.remove(s.deck,index))
 end
 s.dealCount=s.dealCount+1;s.dealSeat=R.Next(s.dealSeat)
 if s.dealCount==4 then
  s.vira=R.Profiles[s.variant].dynamic and table.remove(s.deck,s.dealSide=="bottom"and #s.deck or 1)or nil
  s.phase=s.specialTeam and"special"or"play"
 end
 changed(s);return true
end
function R.Report(s,seat)
 if s.phase~="dealing"and s.phase~="special"and not(s.phase=="play"and #s.tricks==0 and #s.tableCards==0)then return false,"Conferência encerrada para esta carteada."end
 if R.Team(seat)==R.Team(s.dealer)or s.reports[seat]then return false,"Conferência indisponível."end
 s.reports[seat]=true
 if not s.fraud then return false,"Carteada conferida: nenhuma infração registrada."end
 -- Palmeamento/mudança de origem comprovada: desclassificação desta partida casual.
 local winner=3-R.Team(s.dealer);s.score[winner]=12;s.winner=winner;s.phase="finished"
 s.last={team=winner,points=0,reason="Carteada irregular comprovada pelo registro da mesa"};changed(s);return true
end
function R.Special(s,seat,accept)
 if s.phase~="special"or R.Team(seat)~=s.specialTeam then return false,"A decisão é da dupla na mão especial."end
 if accept then s.phase="play";changed(s);return true end
 return R.Award(s,3-s.specialTeam,R.Profiles[s.variant].base,"Dupla correu na mão especial")
end
function R.NextRaise(s)
 for _,v in ipairs(R.Profiles[s.variant].raises)do if v>s.value then return v end end
end
function R.Raise(s,seat)
 if s.phase~="play"or seat~=s.turn then return false,"Peça no seu turno."end
 if s.specialTeam or s.iron then return false,"Não há aumentos na mão especial."end
 local team=R.Team(seat);if s.raiseOwner==team then return false,"A próxima resposta é da outra dupla."end
 local value=R.NextRaise(s);if not value then return false,"A mão já vale doze."end
 s.pending={team=team,value=value,previous=s.value,resume=s.turn,exposed=#s.tableCards>0};s.phase="raise";changed(s);return true
end
function R.Respond(s,seat,action)
 local q=s.pending;if s.phase~="raise"or not q or R.Team(seat)==q.team then return false,"A resposta é da outra dupla."end
 if action=="run"then return R.Award(s,q.team,q.previous,"A dupla correu")end
 if action~="accept"and action~="raise"then return false,"Resposta inválida."end
 local nextValue;for _,v in ipairs(R.Profiles[s.variant].raises)do if v>q.value then nextValue=v;break end end
 if action=="raise"and not nextValue then return false,"Aceite ou corra: limite de doze."end
 s.value=q.value;s.raiseOwner=q.team;s.tieClaim=R.Profiles[s.variant].ties=="ATB"and(q.exposed and 3-q.team or q.team)or nil
 if action=="accept"then s.phase="play";s.turn=q.resume;s.pending=nil
 else s.pending={team=R.Team(seat),value=nextValue,previous=s.value,resume=q.resume,exposed=q.exposed}end
 changed(s);return true
end
local function handWinner(s)
 local t=s.tricks;local a,b,c=t[1],t[2],t[3]
 if #t==1 then return nil,false end
 if a==0 and b~=0 then return b,true end
 if a~=0 and(b==a or b==0)then return a,true end
 if #t<3 then return nil,false end
 if c~=0 then return c,true end
 if a~=0 then return a,true end
 if s.specialTeam then return 3-s.specialTeam,true end
 return s.tieClaim,true
end
local function nextActive(s,seat)
 for _=1,4 do seat=R.Next(seat);if not s.activeSeats or s.activeSeats[seat]then return seat end end
end
function R.Play(s,seat,index,covered)
 if s.phase~="play"or seat~=s.turn then return false,"Aguarde seu turno."end
 index=tonumber(index);if not index or index%1~=0 or not s.hands[seat][index]then return false,"Carta inválida."end
 if covered and #s.tricks==0 then return false,"A primeira vaza é aberta."end
 local card=table.remove(s.hands[seat],index);card.covered=covered==true
 table.insert(s.tableCards,{seat=seat,card=card});table.insert(s.used,{seat=seat,card=card});s.plays=s.plays+1
 local expected=4;if s.activeSeats then expected=0;for _ in pairs(s.activeSeats)do expected=expected+1 end end
 if #s.tableCards<expected then s.turn=nextActive(s,seat)
 else
  local best=-2;local teams={};local lead=s.lead
  for _,v in ipairs(s.tableCards)do
   local pow=R.Power(v.card,s.variant,s.vira)
   if pow>best then best=pow;teams={[R.Team(v.seat)]=true};lead=v.seat
   elseif pow==best then teams[R.Team(v.seat)]=true end
  end
  local win=teams[1]and teams[2]and 0 or teams[1]and 1 or 2
  table.insert(s.tricks,win);s.lastTrick=s.tableCards;s.tableCards={};s.lead=win==0 and s.lead or lead
  if s.variant=="Goiano"and #s.tricks==2 and s.tricks[1]==0 and win==0 then
   s.activeSeats={};for _,v in ipairs(s.lastTrick)do if R.Power(v.card,s.variant,s.vira)==best then s.activeSeats[v.seat]=true end end
   if not s.activeSeats[s.lead]then s.lead=nextActive(s,(s.lead+2)%4+1)end
  end;s.turn=s.lead
  local winner,done=handWinner(s);if done then return R.Award(s,winner,s.value,"Mão concluída")end
 end
 changed(s);return true
end
local function publicCards(cards)
 local out={};for _,p in ipairs(cards or{})do local c=p.card;table.insert(out,{seat=p.seat,card=c.covered and{covered=true}or{rank=c.rank,suit=c.suit,id=c.id}})end;return out
end
function R.View(s,seat)
 local out={variant=s.variant,score={s.score[1],s.score[2]},phase=s.phase,revision=s.revision,seat=seat,dealer=s.dealer,
 turn=s.turn,value=s.value,handNumber=s.handNumber,vira=s.vira,tableCards=publicCards(s.tableCards),lastTrick=publicCards(s.lastTrick),
 tricks=s.tricks,pending=s.pending,specialTeam=s.specialTeam,iron=s.iron,last=s.last,winner=s.winner,counts={},hand={},used=publicCards(s.used),
 nextRaise=R.NextRaise(s),dealCount=s.dealCount,audit=s.audit,raiseOwner=s.raiseOwner,handSeat=s.handSeat}
 for i=1,4 do out.counts[i]=#s.hands[i]end
 for _,c in ipairs(s.hands[seat])do table.insert(out.hand,s.iron and {hidden=true}or c)end
 if s.specialTeam==R.Team(seat)and s.phase=="special"then out.partner=s.hands[(seat+1)%4+1]end
 return out
end
return R
