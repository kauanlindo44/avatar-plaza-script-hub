-- 07H4_BOT_ENGINE | ModuleScript | ReplicatedStorage
-- V43: busca minimax com alpha-beta, limites por nivel e cancelamento entre frames.
local M={}
M.Levels={FACIL={depth=0,nodes=1,seconds=.05},MEDIO={depth=2,nodes=1200,seconds=.7},DIFICIL={depth=4,nodes=6500,seconds=1.8}}
local value={P=100,N=320,B=330,R=500,Q=900,K=20000}
local function copy(v)if type(v)~="table"then return v end;local out={};for k,x in pairs(v)do out[k]=copy(x)end;return out end
function M.Legal(rules,state)
 local out={}
 for r=1,8 do for c=1,8 do local p=state.board[r][c]
  if p and p.c==state.turn then for _,m in ipairs(rules.Legal(state,r,c))do table.insert(out,m)end end
 end end
 return out
end
local function order(state,m,kind)
 local p=state.board[m.fr][m.fc];local captured=state.board[m.tr][m.tc]
 if m.capture then captured=state.board[m.cr][m.cc]end
 if m.enPassant then captured=state.board[m.captureR][m.captureC]end
 local gain=kind=="Xadrez"and(captured and value[captured.t]or 0)or(captured and(captured.k and 280 or 100)or 0)
 return gain*10-(captured and(kind=="Xadrez"and value[p.t]or 100)or 0)+(m.promotion and 800 or 0)+(m.castle and 40 or 0)
end
local function ordered(rules,state,kind)
 local out={};for i,m in ipairs(M.Legal(rules,state))do out[i]={m=m,rank=order(state,m,kind),index=i}end
 table.sort(out,function(a,b)if a.rank~=b.rank then return a.rank>b.rank end;return a.index<b.index end)
 return out
end
local function evaluate(state,kind)
 local score=0
 for r=1,8 do for c=1,8 do local p=state.board[r][c];if p then
  local center=7-math.abs(4.5-r)-math.abs(4.5-c);local advance=p.c=="B"and r-2 or 7-r
  local n
  if kind=="Xadrez"then
   n=value[p.t]or 0
   if p.t=="P"then n=n+advance*8+center*3
   elseif p.t=="N"or p.t=="B"then n=n+center*9
   elseif p.t=="K"then n=n+((c==2 or c==7)and 24 or -center*4) end
  else n=(p.k and 285 or 100)+advance*7+center*4 end
  score=score+(p.c=="B"and n or -n)
 end end end
 return score
end
function M.Choose(rules,state,kind,difficulty,alive)
 local level=M.Levels[difficulty]or M.Levels.MEDIO;local options=ordered(rules,state,kind)
 if #options==0 then return nil,{nodes=0,depth=0}end
 if difficulty=="FACIL"then return options[math.random(1,#options)].m,{nodes=1,depth=0}end
 local nodes,finishedDepth=0,0;local stopped=false;local started=os.clock();local lastYield=started
 local nodeLimit=kind=="Damas"and level.nodes*2 or level.nodes
 local maxDepth=kind=="Damas"and level.depth+2 or level.depth
 local function checkpoint()
  nodes=nodes+1
  if alive and not alive()then stopped=true;return false end
  if nodes>nodeLimit or os.clock()-started>level.seconds then stopped=true;return false end
  if nodes%32==0 or os.clock()-lastYield>.012 then task.wait();lastYield=os.clock();if alive and not alive()then stopped=true;return false end end
  return true
 end
 local search
 search=function(st,depth,alpha,beta,ply)
  if not checkpoint()then return 0 end
  local winner=rules.Result(st)
  if winner then return winner=="draw"and 0 or winner=="B"and 100000-ply or -100000+ply end
  if depth<=0 or ply>=24 then return evaluate(st,kind)end
  local moves=ordered(rules,st,kind);local best=st.turn=="B"and -math.huge or math.huge
  for _,entry in ipairs(moves)do
   local nextState=copy(st);rules.Apply(nextState,entry.m,"Q")
   local remaining=depth-(nextState.turn~=st.turn and 1 or 0)
   local n=search(nextState,remaining,alpha,beta,ply+1);if stopped then return 0 end
   if st.turn=="B"then best=math.max(best,n);alpha=math.max(alpha,best)else best=math.min(best,n);beta=math.min(beta,best)end
   if beta<=alpha then break end
  end
  return best
 end
 local chosen=options[1].m
 for depth=1,maxDepth do
  local best,move=-math.huge,nil;local alpha=-math.huge
  for _,entry in ipairs(options)do
   local nextState=copy(state);rules.Apply(nextState,entry.m,"Q")
   local n=search(nextState,depth-(nextState.turn~=state.turn and 1 or 0),alpha,math.huge,1)
   if stopped then break end
   if n>best then best=n;move=entry.m end;alpha=math.max(alpha,best)
  end
  if stopped then break end
  if move then chosen=move;finishedDepth=depth end
  if math.abs(best)>99000 then break end
 end
 if alive and not alive()then return nil,{nodes=nodes,depth=finishedDepth,cancelled=true}end
 return chosen,{nodes=nodes,depth=finishedDepth}
end
function M.PotatoMemory(poisons,difficulty)
 local probability=difficulty=="FACIL"and .25 or difficulty=="DIFICIL"and .95 or .60
 local memory={};for i in pairs(poisons)do if math.random()<probability then memory[i]=true end end;return memory
end
function M.PotatoPick(remaining,memory)
 local safe,all={},{}
 for i=1,10 do if remaining[i]then table.insert(all,i);if not memory[i]then table.insert(safe,i)end end end
 local choices=#safe>0 and safe or all;if #choices==0 then return nil end;return choices[math.random(1,#choices)]
end
return M
