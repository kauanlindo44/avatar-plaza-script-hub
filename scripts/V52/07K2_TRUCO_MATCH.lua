-- 07K2_TRUCO_MATCH | ModuleScript | ServerScriptService | V46
local Rep=game:GetService("ReplicatedStorage")
local R=require(Rep:WaitForChild("07K0_TRUCO_RULES"))
local AI=require(Rep:WaitForChild("07K1_TRUCO_AI"))
local Http=game:GetService("HttpService")
local Deck=require(Rep:WaitForChild("07K14_DECK_OPTIONS"))
local M={}
function M.Pace(room,s,now,completed)
 s.botAt=now+(room.training and 2.8 or 2.1)
 if completed then s.pauseUntil=now+3.2 end
end
function M.Deadline(s,now)
 if s.variant=="Goiano"and s.phase=="dealing"then s.dealEndsAt=s.dealEndsAt or now+10;return s.dealEndsAt end
 s.dealEndsAt=nil;return now+30
end
function M.New(room)
 local s=R.New(room.variant,math.random(4));s.id=Http:GenerateGUID(false);s.startedAt=os.clock();s.deadline=os.clock()+30
 s.deckOptions=room.deck or Deck.Clean(nil,room.variant,true)
 R.Begin(s,Deck.Deck(s.deckOptions,function(n)return math.random(n)end),false);return s
end
function M.Action(s,seat,action,arg,extra)
 if action=="play"then return R.Play(s,seat,arg,extra==true)
 elseif action=="raise"then return R.Raise(s,seat)
 elseif action=="respond"then return R.Respond(s,seat,arg)
 elseif action=="special"then return R.Special(s,seat,arg==true)
 elseif action=="cut"then return R.Cut(s,seat,arg)
 elseif action=="deal"then return R.Deal(s,seat,arg)
 elseif action=="report"then return R.Report(s,seat)
 elseif action=="run"and s.phase=="play"and s.turn==seat then return R.Award(s,3-R.Team(seat),s.value,"A dupla correu")end
 return false,"Ação inválida para esta fase."
end
function M.Expected(s)
 if s.phase=="cut"then return(s.dealer+2)%4+1
 elseif s.phase=="dealing"then return s.dealer
 elseif s.phase=="special"then return s.specialTeam
 elseif s.phase=="raise"then return 3-s.pending.team
 elseif s.phase=="play"then return s.turn end
end
function M.Step(room,now)
 local s=room.match;if not s or s.phase=="finished"then return false end
 if s.pauseUntil and now<s.pauseUntil then return false end
 if s.phase=="between"then
  if not s.nextHand then s.nextHand=now+3.5;return false end
  if now<s.nextHand then return false end
  s.nextHand=nil;s.dealer=R.Next(s.dealer);R.Begin(s,Deck.Deck(s.deckOptions,function(n)return math.random(n)end),false);s.deadline=M.Deadline(s,now);M.Pace(room,s,now,false);return true
 end
 local expected=M.Expected(s);local teamPhase=s.phase=="special"or s.phase=="raise"
 local actor
 for seat=1,4 do if(teamPhase and R.Team(seat)==expected or not teamPhase and seat==expected)and room.players[seat]and room.players[seat].UserId<0 then actor=seat;break end end
 if actor and not s.botAt then M.Pace(room,s,now,false);return false end
 if actor and now>=s.botAt then
  local action,arg=AI.Choose(R.View(s,actor),room.difficulty);local before=s.revision
  local tricks=#s.tricks;M.Action(s,actor,action,arg)
  M.Pace(room,s,now,#s.tricks~=tricks or s.phase=="between")
  if s.revision~=before then s.deadline=M.Deadline(s,now);return true end
 end
 if now>s.deadline then
  if s.phase=="cut"then R.Cut(s,expected,20)
  elseif s.phase=="dealing"then R.Deal(s,s.dealer,s.dealSide or"top")
  elseif s.phase=="special"then R.Special(s,expected,false)
  elseif s.phase=="raise"then R.Respond(s,expected,"run")
  else R.Play(s,s.turn,1,false)end
  s.deadline=M.Deadline(s,now);return true
 end
 return false
end
function M.View(room,seat)
 local v=R.View(room.match,seat);v.code=room.code;v.tableName=room.table.Name;v.manual=room.manual;v.training=room.training;v.players={}
 for i=1,4 do local pl=room.players[i];v.players[i]={uid=pl.UserId,name=pl.DisplayName or pl.Name}end
 v.deckInfo={mode=room.deck and room.deck.mode or"Full",custom=room.deck and room.deck.custom or false};v.vaza=#room.match.tricks
 v.remaining=math.max(0,math.ceil(room.match.deadline-os.clock()));return v
end
return M
