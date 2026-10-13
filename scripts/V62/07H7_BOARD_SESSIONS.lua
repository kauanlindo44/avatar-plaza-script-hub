-- 07H7_BOARD_SESSIONS | ModuleScript | ServerScriptService | V62 (NOVO)
-- Autoridade de xadrez/damas 2D. Sem assentos, modelos de peças ou teleporte.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Run=game:GetService('RunService');local Http=game:GetService('HttpService')
local Chess=require(script.Parent:WaitForChild('07A0_CHESS_RULES'));local Checkers=require(script.Parent:WaitForChild('07B0_CHECKERS_RULES'))
local Wins=require(script.Parent:WaitForChild('07W_WINS_SERVICE'));local M={Version='V62'};local states,byPlayer={},{};local bound=false;local event
M.Finished=Instance.new('BindableEvent')
local function send(pl,action,data)if pl and pl.Parent==Players and event then event:FireClient(pl,action,data)end end
function M.Board(board)
 local out={};for r=1,8 do out[r]={};for c=1,8 do local p=board[r]and board[r][c];out[r][c]=p and{c=p.c,t=p.t or'',k=p.k==true}or false end end;return out
end
local function side(s,pl)return s.players.W==pl and'W'or s.players.B==pl and'B'or nil end
local function clock(s)
 local now=os.clock();if s.active then local color=s.state.turn;s.clock[color]=math.max(0,s.clock[color]-(now-s.last))end;s.last=now
end
local function snapshot(s,pl)
 local selected=s.selected;local hints={};if selected and s.players[s.state.turn]==pl then for _,m in ipairs(selected.moves)do hints[#hints+1]={r=m.tr,c=m.tc}end end
 return{protocol=2,tableName=s.name,code=s.code,game=s.game,side=side(s,pl),board=M.Board(s.state.board),turn=s.state.turn,revision=s.revision,selected=selected and{r=selected.r,c=selected.c}or nil,hints=hints,whiteTime=s.clock.W,blackTime=s.clock.B,turnText=s.state.forced and'Continue a captura obrigatória'or(s.state.turn=='W'and'Vez das claras'or'Vez das escuras')}
end
local function broadcast(s)for _,pl in pairs(s.players)do send(pl,'boardState',snapshot(s,pl))end end
local function tournament(s,action)
 if not s.cup then return end;task.spawn(function()local ok,e=pcall(function()require(script.Parent:WaitForChild('07K13_TOURNAMENT_SERVICE'))[action](s.cup,s.cupMatch)end);if not ok then warn('[Board V62] torneio '..tostring(e))end end)
end
local function finish(s,winner,reason)
 if not s or not s.active then return end;clock(s);s.active=false;s.selected=nil;s.promotion=nil
 local summary={id=s.id,game=s.game,winner=winner,reason=reason,board=M.Board(s.state.board),moves=s.moves,seconds=os.clock()-s.started,winnerUID=winner~='draw'and s.players[winner]and s.players[winner].UserId or nil,canRematch=not s.cup}
 for _,pl in pairs(s.players)do byPlayer[pl]=nil;send(pl,'boardClose',{tableName=s.name,finished=true,summary=summary})end
 if winner=='draw'then tournament(s,'Draw')else local won=s.players[winner];local lost=s.players[winner=='W'and'B'or'W'];if won and won.Parent==Players then local ok,e=pcall(Wins.RecordMatch,s.game,won,lost,{id=s.id,duration=summary.seconds,moves=s.moves,cup=s.cup,cupMatch=s.cupMatch});if not ok then warn('[Board V62] resultado '..tostring(e))end end end
 states[s.code]=nil;M.Finished:Fire(s.code,summary)
end
local function apply(s,move,promotion)
 if not s.active then return end;clock(s);local mover=s.state.turn
 if s.clock[mover]<=0 then finish(s,mover=='W'and'B'or'W','Tempo esgotado');return end
 local ok,e=s.rules.Apply(s.state,move,promotion);if not ok then send(s.players[mover],'notice',e or'Lance inválido.');return end
 s.moves=s.moves+1;s.revision=s.revision+1;s.promotion=nil;s.selected=nil;s.last=os.clock()
 if s.state.turn~=mover then s.clock[mover]=math.min(599,s.clock[mover]+3)end
 local result,reason=s.rules.Result(s.state);if result then finish(s,result,reason)else broadcast(s)end
end
local function cell(v)v=tonumber(v);return v and v%1==0 and v>=1 and v<=8 and v end
function M.Action(pl,action,name,r,c,revision)
 local s=byPlayer[pl];if not s or not s.active or s.name~=name then return false end
 if action=='syncBoard'then send(pl,'boardState',snapshot(s,pl));return true end
 if action=='resignGame'then finish(s,side(s,pl)=='W'and'B'or'W','Desistência');return true end
 if action=='claimDraw'and s.game=='Xadrez'and side(s,pl)==s.state.turn and s.rules.CanClaimDraw(s.state)then finish(s,'draw','Empate solicitado');return true end
 if action=='promotionChoice'then local pending=s.promotion;if pending and pending.player==pl and table.find({'Q','R','B','N'},r)then apply(s,pending.move,r);return true end;return false end
 if action~='boardTap'then return false end
 local now=os.clock()
 clock(s);if s.clock[s.state.turn]<=0 then finish(s,s.state.turn=='W'and'B'or'W','Tempo esgotado');return false end
 if revision and revision~=s.revision then send(pl,'boardState',snapshot(s,pl));return false end
 if side(s,pl)~=s.state.turn or s.promotion then return false end;r,c=cell(r),cell(c);if not r or not c then return false end
 if s.lastTap and s.lastTap.player==pl and now-s.lastTap.at<.08 then return false end;s.lastTap={player=pl,at=now}
 local piece=s.state.board[r][c]
 if s.selected and(not piece or piece.c~=s.state.turn)then
  for _,move in ipairs(s.selected.moves)do if move.tr==r and move.tc==c then
   local moving=s.state.board[move.fr][move.fc]
   if s.game=='Xadrez'and moving.t=='P'and(r==1 or r==8)then
    local pending={player=pl,move=move};s.promotion=pending;send(pl,'promotion',s.name)
    task.delay(15,function()if s.active and s.promotion==pending then apply(s,move,'Q')end end)
   else apply(s,move)end;return true
  end end
 end
 if not piece or piece.c~=s.state.turn then return false end
 local moves=s.rules.Legal(s.state,r,c);if #moves==0 then send(pl,'notice','Esta peça não tem lance legal.');return false end
 s.selected={r=r,c=c,moves=moves};broadcast(s);return true
end
function M.Open(room,ps)
 if #ps~=2 or byPlayer[ps[1]]or byPlayer[ps[2]]or ps[1]==ps[2]then return nil,'Jogadores indisponíveis.'end
 local rules=room.game=='Xadrez'and Chess or room.game=='Damas'and Checkers;if not rules then return nil,'Jogo inválido.'end
 local s={code=room.code,name=room.game..'_'..room.code,game=room.game,rules=rules,state=rules.New(),players={W=ps[1],B=ps[2]},clock={W=300,B=300},last=os.clock(),started=os.clock(),moves=0,revision=0,active=true,id=Http:GenerateGUID(false),cup=room.cup,cupMatch=room.cupMatch}
 states[s.code]=s;for _,pl in pairs(s.players)do byPlayer[pl]=s;send(pl,'boardOpen',snapshot(s,pl))end;tournament(s,'Begin');broadcast(s);return s.name
end
function M.Leave(pl)local s=byPlayer[pl];if s then finish(s,side(s,pl)=='W'and'B'or'W','Jogador saiu')end end
function M.Bind()
 if bound then return end;bound=true;local kit=Rep:WaitForChild('PracaKit');local rem=kit:WaitForChild('Remotes');event=rem:FindFirstChild('HubGameUI')or Instance.new('RemoteEvent');event.Name='HubGameUI';event.Parent=rem;event:SetAttribute('Version','V62')
 event.OnServerEvent:Connect(M.Action);local elapsed=0
 Run.Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed<.25 then return end;elapsed=0
  for _,s in pairs(states)do clock(s);if s.clock[s.state.turn]<=0 then finish(s,s.state.turn=='W'and'B'or'W','Tempo esgotado')else broadcast(s)end end
 end)
end
return M
