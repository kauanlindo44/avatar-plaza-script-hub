-- 07H8_PLAY_SESSION | ModuleScript | ReplicatedStorage | V63 (NOVO)
-- Pequenas metas da sessão a partir de jogadas reais. Sem mexer em regras/ranking.
local M={Version='V63'}
function M.New(kind,side)
 local S={kind=kind,side=side or'W',moves=0,captures=0,complete=false,milestones={}}
 local previous;local handCount;local phase;local trickCount=0
 local function award(key,label)
  if S.milestones[key]then return end;S.milestones[key]=label;if S.OnMilestone then S.OnMilestone(label)end
 end
 local function update()
  if S.moves>=4 then award('moves','Ritmo de jogo · quatro jogadas concluídas')end
  if S.captures>=1 then award('capture',kind=='Truco'and'Primeira vaza da sua dupla!'or'Primeira captura da partida!')end
 end
 function S.Board(board)
  if type(board)~='table'then return end
  local own,enemy,positions=0,0,{}
  for r=1,8 do for c=1,8 do local p=board[r]and board[r][c]
   if type(p)=='table'then
    if p.c==S.side then own=own+1;positions[#positions+1]=r..':'..c..':'..tostring(p.t or p.k)else enemy=enemy+1 end
   end
  end end
  local signature=table.concat(positions,',')
  if previous then
   if own==previous.own and signature~=previous.signature then S.moves=S.moves+1 end
   S.captures=S.captures+math.max(0,previous.enemy-enemy)
  end
  previous={own=own,enemy=enemy,signature=signature};update()
 end
 function S.Truco(v,team)
  if phase=='finished'and v.phase~='finished'then S.moves=0;S.captures=0;S.complete=false;S.milestones={};handCount=nil;trickCount=0 end
  local count=#(v.hand or{})
  if phase=='play'and(v.phase=='play'or v.phase=='between')and handCount and count<handCount then S.moves=S.moves+handCount-count end
  if #(v.tricks or{})<trickCount then trickCount=0 end
  for i=trickCount+1,#(v.tricks or{})do local trick=v.tricks[i];if trick==team or type(trick)=='table'and trick.team==team then S.captures=S.captures+1 end end
  trickCount=#(v.tricks or{});handCount=count;phase=v.phase;update()
  if v.phase=='finished'then S.Finish()end
 end
 function S.Finish()
  if S.complete then return end;S.complete=true;award('complete','Partida concluída · pronto para a revanche')
 end
 function S.Caption()
  if S.moves<4 then return'Meta da sessão: '..S.moves..' / 4 jogadas'end
  if S.captures<1 then return kind=='Truco'and'Próxima meta: vencer uma vaza'or'Próxima meta: uma captura'end
  return S.complete and'Metas da partida concluídas'or'Próxima meta: concluir a partida'
 end
 function S.Summary()
  return'Sua partida: '..S.moves..' jogadas • '..S.captures..(kind=='Truco'and' vazas da dupla'or' capturas')..(S.complete and' • concluída'or'')
 end
 return S
end
return M
