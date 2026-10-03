from test_support import *
RULES=module('07K0_TRUCO_RULES')+"R=Modules['07K0_TRUCO_RULES']\n"+module('07K1_TRUCO_AI')+"AI=Modules['07K1_TRUCO_AI']\n"
CATALOG=module('07K6_CARD_CATALOG')+"C=Modules['07K6_CARD_CATALOG']\n"
INVENTORY=CATALOG+module('07K8_CARD_INVENTORY')+"I=Modules['07K8_CARD_INVENTORY']\n"
PROGRESS=INVENTORY+module('07K11_GAMES_PROGRESS')+"P=Modules['07K11_GAMES_PROGRESS']\n"
CUPS=PROGRESS+module('07K13_TOURNAMENT_SERVICE')+"T=Modules['07K13_TOURNAMENT_SERVICE']\n"
case('truco_real_rank_profiles_and_private_cards',RULES+r'''
local deck=R.Deck();assert(#deck==40);local ids={};for _,c in ipairs(deck)do assert(not ids[c.id]);ids[c.id]=true end
local function card(rank,suit)return{rank=rank,suit=suit,id=rank..suit}end
for _,variant in ipairs({'Paulista','Goiano'})do
 local vira=card('3','D');assert(R.Power(card('4','C'),variant,vira)>R.Power(card('4','H'),variant,vira))
 assert(R.Power(card('4','D'),variant,vira)>R.Power(card('3','C'),variant,vira))
end
assert(R.Power(card('4','C'),'Mineiro')>R.Power(card('7','H'),'Mineiro'))
assert(R.Power(card('7','H'),'Mineiro')>R.Power(card('A','S'),'Mineiro'))
assert(R.Power(card('A','S'),'Mineiro')>R.Power(card('7','D'),'Mineiro'))
assert(R.Power(card('7','D'),'Mineiro')>R.Power(card('3','S'),'Mineiro'))
for variant,p in pairs(R.Profiles)do
 local s=R.New(variant,4);assert(R.Begin(s,R.Deck(),false));assert(s.value==p.base and s.phase=='play')
 for seat=1,4 do assert(#s.hands[seat]==3);local v=R.View(s,seat);assert(#v.hand==3 and not v.hands and not v.deck and not v.partner)end
 assert(not R.Play(s,2,1));assert(not R.Play(s,1,1,true))
 assert(R.Raise(s,1));assert(s.pending.value==p.raises[1]);assert(not R.Respond(s,3,'accept'));assert(R.Respond(s,2,'accept'));assert(s.value==p.raises[1])
 assert(not R.Raise(s,1));assert(R.Play(s,1,1));assert(R.Raise(s,2));assert(s.pending.value==p.raises[2]);assert(R.Respond(s,3,'run'));assert(s.score[2]==p.raises[1])
 s=R.New(variant,4);s.score[1]=p.special;assert(R.Begin(s,R.Deck(),false));assert(s.phase=='special'and s.value==p.specialValue)
 assert(R.View(s,1).partner and not R.View(s,2).partner);assert(not R.Special(s,2,true));assert(R.Special(s,3,false));assert(s.score[2]==p.base)
 s=R.New(variant,4);s.score={p.special,p.special};R.Begin(s,R.Deck(),false);local v=R.View(s,1);assert(v.iron and v.hand[1].hidden and not v.hand[1].rank and not v.partner);assert(not R.Raise(s,1))
end
local s=R.New('Paulista',4);R.Begin(s,R.Deck(),false);s.tricks={1};assert(R.Play(s,1,1,true));local v=R.View(s,2)
assert(v.tableCards[1].card.covered and not v.tableCards[1].card.id and not v.used[1].card.rank)
return '40 unique cards; three real profiles, legal raises, team decisions, special hands and sanitized public covered cards'
''')
case('truco_manual_audit_proof_and_goiano_ties',RULES+r'''
local s=R.New('Paulista',4);R.Begin(s,R.Deck(),true);assert(s.phase=='cut');assert(not R.Cut(s,1,20));assert(R.Cut(s,3,20))
assert(R.Deal(s,4,'bottom'));assert(not R.Report(s,4));local score=s.score[1];assert(not R.Report(s,1));assert(s.score[1]==score and s.phase=='dealing')
assert(R.Deal(s,4,'bottom'));assert(not s.fraud);assert(R.Deal(s,4,'middle'));assert(s.fraud and s.irregular);assert(R.Report(s,3));assert(s.phase=='finished'and s.winner==1)
local function c(rank,suit)return{rank=rank,suit=suit,id=rank..suit}end
s=R.New('Goiano',4);R.Begin(s,R.Deck(),false);s.vira=c('4','D')
s.hands={{c('3','D'),c('3','S'),c('2','S')},{c('3','H'),c('3','C'),c('2','H')},{c('Q','D'),c('J','D'),c('A','D')},{c('Q','H'),c('J','H'),c('A','H')}}
for _=1,4 do assert(R.Play(s,s.turn,1,false))end;assert(s.tricks[1]==0)
for _=1,4 do assert(R.Play(s,s.turn,1,false))end;assert(s.tricks[2]==0 and s.activeSeats[1]and s.activeSeats[2]and not s.activeSeats[3])
assert(R.Play(s,1,1,false));assert(s.turn==2);assert(R.Play(s,2,1,false));assert(s.phase=='between'and s.last.points==0)
return 'legal top/bottom, first-origin lock, proof before penalty, no false accusation points, Goiano tied seats only and no-point redeal'
''')
case('truco_bot_complete_games_all_variants_levels',RULES+r'''
math.randomseed(44003);local total=0;local raised={};local decisions={}
for variant in pairs(R.Profiles)do for _,level in ipairs({'Fácil','Médio','Difícil'})do for gameIndex=1,8 do
 local s=R.New(variant,math.random(4));local steps=0
 while s.phase~='finished'and steps<2000 do
  if s.phase=='between'then s.dealer=R.Next(s.dealer);R.Begin(s,R.Deck(math.random),false)end
  local seat=s.phase=='special'and s.specialTeam or s.phase=='raise'and 3-s.pending.team or s.turn
  local view=R.View(s,seat);assert(not view.deck and not view.hands)
  local act,arg=AI.Choose(view,level);if act=='raise'then raised[level]=(raised[level]or 0)+1 end
  local ok
  if act=='play'then ok=R.Play(s,seat,arg,false)elseif act=='special'then ok=R.Special(s,seat,arg)elseif act=='raise'then ok=R.Raise(s,seat)elseif act=='respond'then ok=R.Respond(s,seat,arg)end
  assert(ok,'illegal bot decision '..variant..' '..level..' '..act);steps=steps+1
 end
 assert(s.phase=='finished'and s.score[s.winner]==12,'stalled full match');total=total+1
end end end
assert(not raised['Fácil']and raised['Médio']and raised['Difícil'])
return total..' complete matches; levels make distinct decisions, only own/public cards, no invalid turns or infinite raises'
''')
case('goiano_total_dealing_deadline',RULES+module('07K2_TRUCO_MATCH')+r'''
local match=Modules['07K2_TRUCO_MATCH'];local s=R.New('Goiano',4);R.Begin(s,R.Deck(),true);assert(s.phase=='cut');R.Cut(s,3,20);assert(s.phase=='dealing')
assert(match.Deadline(s,100)==110);R.Deal(s,s.dealer,'top');assert(match.Deadline(s,108)==110,'deal deadline restarted for each group')
while s.phase=='dealing'do R.Deal(s,s.dealer,'top')end;assert(match.Deadline(s,112)==142)
return 'Goiano distribution shares a total 10-second deadline; normal decisions retain 30 seconds'
''')
case('inventory_atomic_choice_duplicates_failure_and_receipts',INVENTORY+r'''
assert(I.Load(123));assert(I.View(123).coins==0 and I.View(123).privacy.allowCopy==false)
assert(not I.Equip(123,'Zenith'));assert(not I.BuyCoins(123,'box','Eclipse',1))
assert(I.Transact(123,function(d)d.coins=10000;return true end));assert(I.BuyCoins(123,'box','Nox',3))
local before=I.View(123);assert(before.coins==8500);assert(not I.BuyCoins(123,'box','Nox',1))
assert(not I.BuyCoins(123,'style','Onyx',1));assert(I.View(123).coins==8500 and not I.View(123).owned.Onyx,'covered style caused a redundant coin purchase')
assert(not I.OpenChoices(123,'Nox',{'Onyx','Onyx'}));assert(I.View(123).boxes.Nox==3)
StoreRetry=true;local result=I.OpenChoices(123,'Nox',{'Onyx','Hex'});assert(result.quantity==2 and #result.styles==2)
assert(I.View(123).boxes.Nox==1);assert(not I.OpenChoice(123,'Nox','Onyx',1));assert(I.Equip(123,'Onyx'))
assert(not I.SetCustom(123,{image=10}));assert(I.GrantPass(123,1951234105));assert(I.SetCustom(123,{image=10,zoom=99,x=1,y=-1}));assert(I.View(123).custom.zoom==2 and I.View(123).custom.x==.5)
local receipt={PurchaseId='paid-A',ProductId=999,PlayerId=123};assert(I.Receipt(receipt,'Eclipse'));assert(I.Receipt(receipt,'Eclipse'));assert(I.View(123).boxes.Eclipse==1)
FailStores=true;assert(not I.BuyCoins(123,'style','Aurum',1));assert(not I.Receipt({PurchaseId='paid-B',PlayerId=123},'Eclipse'));assert(I.View(123).coins==8500)
FailStores=false;assert(I.Receipt({PurchaseId='paid-B',PlayerId=123},'Eclipse'));assert(I.View(123).boxes.Eclipse==2)
for _,box in ipairs(C.Collections)do for _,style in ipairs(box.skins)do assert(C.Styles[style].coins==box.coins and C.Styles[style].suggestedRobux==box.suggestedRobux)end end
return 'atomic persistent choices, no duplicate consumption, cap on unnecessary boxes, fail-closed coins, bounded custom editor and receipt retry grants once'
''')
case('commerce_native_price_policy_fail_closed_and_callback',INVENTORY+module('07K10_CARD_COMMERCE')+r'''
local commerce=Modules['07K10_CARD_COMMERCE'];assert(I.Load(pl.UserId))
onProduct=function(id)return{Name='Native product',PriceInRobux=2,IsForSale=true}end
local store=commerce.Store(pl);assert(store.passes['1951234105'].price==2 and store.products.Nox.id==0 and not store.products.Nox.sale)
assert(commerce.Prompt(pl,'pass',1951234105));assert(LastPrompt.id==1951234105);advance(3);assert(not commerce.Prompt(pl,'product','Nox'))
local covered={UserId=789};assert(I.Load(789));assert(I.Transact(789,function(d)d.coins=10000;return true end));assert(I.BuyCoins(789,'box','Reign',3))
assert(not commerce.Prompt(covered,'pass',1962433436));assert(not commerce.Prompt(covered,'product','Aurum'));assert(LastPrompt.id==1951234105,'covered choices still opened an unnecessary Robux prompt')
assert(not commerce.PaidRandomAllowed(pl));RestrictRandom=true;assert(not commerce.PaidRandomAllowed(pl));FailPolicy=true;assert(not commerce.PaidRandomAllowed(pl))
local market=Services.MarketplaceService;local callback
setmetatable(market,{__index=function(_,k)if k=='ProcessReceipt'then error('write-only callback')end end,__newindex=function(t,k,v)if k=='ProcessReceipt'then callback=v else rawset(t,k,v)end end})
commerce.Start();assert(callback);assert(callback({ProductId=999,PlayerId=123,PurchaseId='unknown'})==Enum.ProductPurchaseDecision.NotProcessedYet)
C.Products.Eclipse=123456;assert(callback({ProductId=123456,PlayerId=123,PurchaseId='paid-real'})==Enum.ProductPurchaseDecision.PurchaseGranted)
assert(callback({ProductId=123456,PlayerId=123,PurchaseId='paid-real'})==Enum.ProductPurchaseDecision.PurchaseGranted);assert(I.View(123).boxes.Eclipse==1)
OwnedPasses[1962433436]=true;commerce.RefreshPasses(pl);assert(I.View(123).owned.Regent)
return 'uses actual 2 Robux, zero product IDs disabled, covered choices prevent redundant prompts, permanent pass ownership verified, random blocked on every policy outcome and write-only receipt registration'
''')
case('progress_reward_and_weekly_rank_deduplication',PROGRESS+r'''
I.Load(1);I.Load(2);local context={duration=120,moves=20}
assert(P.Record('Xadrez','real-1',{1},{2},context));assert(P.Record('Xadrez','real-1',{1},{2},context))
assert(I.View(1).coins==100 and I.View(2).coins==35);local top=P.Top('Xadrez',10);assert(#top==1 and top[1].value==1 and top[1].label=='@User1')
assert(not P.Record('Xadrez','bot',{1},{-2},context));assert(not P.Record('Truco','fraud',{1,3},{2,4},{duration=120,moves=20,irregular=true}))
assert(P.Record('Truco','team',{3,1},{4,2},context));local rank=P.Top('Truco',10);assert(rank[1].key=='1:3'and rank[1].label=='@User1 + @User3')
for i=1,20 do P.Record('Xadrez','repeat-'..i,{1},{2},context)end;assert(I.View(1).coins<=600)
return 'validated PvP only; one reward/rank per match, team ranking, no bots or irregular results, bounded repeat-opponent coins'
''')
case('tournaments_consent_checkin_ten_seeds_and_rematches',CUPS+r'''
local epoch=os.time;local clock=epoch();local week=P.Week(clock);local start=345600+week*604800+5*86400+22*3600
clock=start-3*86400;os.time=function()return clock end
local rankings={};for i=1,12 do rankings[i]={key=tostring(i),value=100-i}end
P.Top=function()return rankings end
local snapshot=T.Snapshot('Xadrez',week,clock);assert(#snapshot.entries==12 and snapshot.entries[10].status=='invited'and snapshot.entries[11].status=='reserve')
local function player(id)return{UserId=id,SetAttribute=function()end}end
assert(T.Answer(player(11),snapshot.id,true));assert(T.Answer(player(12),snapshot.id,true))
for i=1,10 do assert(T.Answer(player(i),snapshot.id,true))end
assert(not T.Checkin(player(1),snapshot.id));clock=start-600
for i=1,9 do assert(T.Checkin(player(i),snapshot.id))end
local store=Services.MemoryStoreService:GetHashMap('ACP_CupPresence_V44');store:SetAsync('11',{time=clock,job='job-B'},90)
clock=start-240;store:SetAsync('11',{time=clock,job='job-B'},90);assert(not T.Checkin(player(10),snapshot.id));T.Tick()
local c=StoreData.ACP_WeeklyCups_V44[snapshot.id];assert(c.phase=='playing'and #c.matches==2 and #c.advance==6)
local found=false;for _,e in ipairs(c.entries)do if e.key=='11'then found=e.status=='qualified'end end;assert(found,'online accepted reserve was not used')
clock=start+1;local hostAlive=true;T.Start(function(_,entry)return{code='TEST'}end,function()return hostAlive end);T.Tick();c=StoreData.ACP_WeeklyCups_V44[snapshot.id];local m=c.matches[1];assert(m.status=='ready')
assert(T.Match(player(m.players[1]),c.id,m.id));assert(not T.Match(player(999),c.id,m.id));assert(T.Begin(c.id,m.id));clock=clock+1200;T.Tick()
c=StoreData.ACP_WeeklyCups_V44[snapshot.id];assert(c.matches[1].status=='playing','active match expired at 10m')
local oldID=m.id;hostAlive=false;clock=clock+200;T.Tick();c=StoreData.ACP_WeeklyCups_V44[snapshot.id];m=c.matches[1]
assert(m.id~=oldID and m.restarts==1,'lost host did not create a new authorized match')
T.Result('Xadrez','stale-game',{m.players[1]},{m.players[2]},{cup=c.id,cupMatch=oldID});assert(StoreData.ACP_WeeklyCups_V44[c.id].matches[1].status~='finished','old host result accepted')
hostAlive=true;clock=clock+1;T.Tick();assert(T.Begin(c.id,m.id))
assert(T.Draw(c.id,m.id));c=StoreData.ACP_WeeklyCups_V44[snapshot.id];assert(c.matches[1].status=='pending'and c.matches[1].rematches==1)
clock=clock+20;T.Tick();c=StoreData.ACP_WeeklyCups_V44[snapshot.id];m=c.matches[1];T.Begin(c.id,m.id);T.Result('Xadrez','game',{m.players[1]},{m.players[2]},{cup=c.id,cupMatch=m.id})
assert(StoreData.ACP_WeeklyCups_V44[c.id].matches[1].status=='finished')
os.time=epoch;return 'top 10 + reserves, opt-in deadlines, bounded check-in, accepted online replacement, six byes, authorization, active match not expired and draw rematch'
''')
HERE.joinpath('games_commerce_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('GAMES/COMMERCE',len(results),'PASS')
