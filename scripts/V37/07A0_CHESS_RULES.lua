-- 07A0_CHESS_RULES
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V37 - cópia cliente das regras para treino contra BOT.
local R={}
local dirsB={{1,1},{1,-1},{-1,1},{-1,-1}}
local dirsR={{1,0},{-1,0},{0,1},{0,-1}}
local function inside(r,c)
	return r>=1 and r<=8 and c>=1 and c<=8
end
local function other(color)
	return color=="W" and "B" or "W"
end
local function copyBoard(board)
	local b={}
	for r=1,8 do
		b[r]={}
		for c=1,8 do
			local p=board[r][c]
			if p then
				b[r][c]={t=p.t,c=p.c}
			end
		end
	end
	return b
end
local function push(out,fr,fc,tr,tc,extra)
	local m={fr=fr,fc=fc,tr=tr,tc=tc}
	if extra then
		for k,v in pairs(extra) do m[k]=v end
	end
	table.insert(out,m)
end
local function ray(board,out,r,c,color,dirs)
	for _,d in ipairs(dirs) do
		local rr=r+d[1]
		local cc=c+d[2]
		while inside(rr,cc) do
			local target=board[rr][cc]
			if not target then
				push(out,r,c,rr,cc)
			else
				if target.c~=color then
					push(out,r,c,rr,cc)
				end
				break
			end
			rr=rr+d[1]
			cc=cc+d[2]
		end
	end
end
local function rawMoves(state,r,c,attacksOnly)
	local board=state.board
	local p=board[r] and board[r][c]
	if not p then return {} end
	local out={}
	local color=p.c
	if p.t=="P" then
		local step=color=="W" and -1 or 1
		local start=color=="W" and 7 or 2
		local nextR=r+step
		for _,dc in ipairs({-1,1}) do
			local rr=r+step
			local cc=c+dc
			if inside(rr,cc) then
				if attacksOnly then
					push(out,r,c,rr,cc)
				else
					local target=board[rr][cc]
					if target and target.c~=color then
						push(out,r,c,rr,cc,{promotion=(rr==1 or rr==8)})
					elseif state.ep
						and state.ep.r==rr
						and state.ep.c==cc then
						push(out,r,c,rr,cc,{
							enPassant=true,
							captureR=state.ep.captureR,
							captureC=state.ep.captureC
						})
					end
				end
			end
		end
		if not attacksOnly and inside(nextR,c)
			and not board[nextR][c] then
			push(out,r,c,nextR,c,{promotion=(nextR==1 or nextR==8)})
			local two=r+step*2
			if r==start and not board[two][c] then
				push(out,r,c,two,c,{doublePawn=true})
			end
		end

	elseif p.t=="N" then
		for _,d in ipairs({
			{2,1},{2,-1},{-2,1},{-2,-1},
			{1,2},{1,-2},{-1,2},{-1,-2}
		}) do
			local rr=r+d[1]
			local cc=c+d[2]
			if inside(rr,cc) then
				local target=board[rr][cc]
				if not target or target.c~=color then
					push(out,r,c,rr,cc)
				end
			end
		end
	elseif p.t=="B" then
		ray(board,out,r,c,color,dirsB)
	elseif p.t=="R" then
		ray(board,out,r,c,color,dirsR)
	elseif p.t=="Q" then
		ray(board,out,r,c,color,dirsB)
		ray(board,out,r,c,color,dirsR)
	elseif p.t=="K" then
		for dr=-1,1 do
			for dc=-1,1 do
				if not (dr==0 and dc==0) then
					local rr=r+dr
					local cc=c+dc
					if inside(rr,cc) then
						local target=board[rr][cc]
						if not target or target.c~=color then
							push(out,r,c,rr,cc)
						end
					end
				end
			end
		end
	end
	return out
end
local function kingPos(board,color)
	for r=1,8 do
		for c=1,8 do
			local p=board[r][c]
			if p and p.c==color and p.t=="K" then
				return r,c
			end
		end
	end
end
function R.IsAttacked(state,r,c,byColor)
	for rr=1,8 do
		for cc=1,8 do
			local p=state.board[rr][cc]
			if p and p.c==byColor then
				for _,m in ipairs(rawMoves(state,rr,cc,true)) do
					if m.tr==r and m.tc==c then
						return true
					end
				end
			end
		end
	end
	return false
end
function R.InCheck(state,color)
	local r,c=kingPos(state.board,color)
	if not r then return true end
	return R.IsAttacked(state,r,c,other(color))
end
local function simulate(state,move)
	local nextState={
		board=copyBoard(state.board),
		turn=state.turn,
		castle=state.castle,
		ep=state.ep
	}
	local p=nextState.board[move.fr][move.fc]
	nextState.board[move.fr][move.fc]=nil
	nextState.board[move.tr][move.tc]=p
	if move.enPassant then
		nextState.board[move.captureR][move.captureC]=nil
	end
	if move.castle=="K" then
		local row=p.c=="W" and 8 or 1
		nextState.board[row][6]=nextState.board[row][8]
		nextState.board[row][8]=nil
	elseif move.castle=="Q" then
		local row=p.c=="W" and 8 or 1
		nextState.board[row][4]=nextState.board[row][1]
		nextState.board[row][1]=nil
	end
	return nextState
end

local function castleMoves(state,r,c)
	local p=state.board[r][c]
	if not p or p.t~="K" then return {} end
	local color=p.c
	local row=color=="W" and 8 or 1
	if r~=row or c~=5 then return {} end
	local rights=state.castle[color]
	if not rights or R.InCheck(state,color) then return {} end
	local enemy=other(color)
	local out={}
	if rights.K
		and not state.board[row][6]
		and not state.board[row][7] then
		local rook=state.board[row][8]
		if rook and rook.c==color and rook.t=="R"
			and not R.IsAttacked(state,row,6,enemy)
			and not R.IsAttacked(state,row,7,enemy) then
			push(out,row,5,row,7,{castle="K"})
		end
	end
	if rights.Q
		and not state.board[row][2]
		and not state.board[row][3]
		and not state.board[row][4] then
		local rook=state.board[row][1]
		if rook and rook.c==color and rook.t=="R"
			and not R.IsAttacked(state,row,4,enemy)
			and not R.IsAttacked(state,row,3,enemy) then
			push(out,row,5,row,3,{castle="Q"})
		end
	end
	return out
end
function R.Legal(state,r,c)
	local p=state.board[r] and state.board[r][c]
	if not p or p.c~=state.turn then return {} end
	local candidates=rawMoves(state,r,c,false)
	if p.t=="K" then
		for _,m in ipairs(castleMoves(state,r,c)) do
			table.insert(candidates,m)
		end
	end
	local legal={}
	for _,m in ipairs(candidates) do
		local sim=simulate(state,m)
		if not R.InCheck(sim,p.c) then
			table.insert(legal,m)
		end
	end
	return legal
end
local function hash(state)
	local s={}
	for r=1,8 do
		for c=1,8 do
			local p=state.board[r][c]
			s[#s+1]=p and (p.c..p.t) or ".."
		end
	end
	s[#s+1]=state.turn
	s[#s+1]=state.castle.W.K and "K" or "-"
	s[#s+1]=state.castle.W.Q and "Q" or "-"
	s[#s+1]=state.castle.B.K and "k" or "-"
	s[#s+1]=state.castle.B.Q and "q" or "-"
	s[#s+1]=state.ep and (state.ep.r..":"..state.ep.c) or "-"
	return table.concat(s,"|")
end
function R.New()
	local board={}
	for r=1,8 do board[r]={} end
	local back={"R","N","B","Q","K","B","N","R"}
	for c=1,8 do
		board[1][c]={t=back[c],c="B"}
		board[2][c]={t="P",c="B"}
		board[7][c]={t="P",c="W"}
		board[8][c]={t=back[c],c="W"}
	end
	local state={
		board=board,
		turn="W",
		castle={
			W={K=true,Q=true},
			B={K=true,Q=true}
		},
		ep=nil,
		halfmove=0,
		repetition={}
	}
	state.repetition[hash(state)]=1
	return state
end
function R.Apply(state,move,promotion)
	local board=state.board
	local p=board[move.fr][move.fc]
	if not p then return false end
	local captured=board[move.tr][move.tc]
	if p.t=="K" then
		state.castle[p.c].K=false
		state.castle[p.c].Q=false
	elseif p.t=="R" then
		local row=p.c=="W" and 8 or 1
		if move.fr==row and move.fc==1 then state.castle[p.c].Q=false end
		if move.fr==row and move.fc==8 then state.castle[p.c].K=false end
	end

	if captured and captured.t=="R" then
		local row=captured.c=="W" and 8 or 1
		if move.tr==row and move.tc==1 then state.castle[captured.c].Q=false end
		if move.tr==row and move.tc==8 then state.castle[captured.c].K=false end
	end
	board[move.fr][move.fc]=nil
	board[move.tr][move.tc]=p
	if move.enPassant then
		captured=board[move.captureR][move.captureC]
		board[move.captureR][move.captureC]=nil
	end
	if move.castle=="K" then
		local row=p.c=="W" and 8 or 1
		board[row][6]=board[row][8]
		board[row][8]=nil
	elseif move.castle=="Q" then
		local row=p.c=="W" and 8 or 1
		board[row][4]=board[row][1]
		board[row][1]=nil
	end
	state.ep=nil
	if p.t=="P" and math.abs(move.tr-move.fr)==2 then
		state.ep={
			r=(move.tr+move.fr)/2,
			c=move.fc,
			captureR=move.tr,
			captureC=move.tc
		}
	end
	if p.t=="P" and (move.tr==1 or move.tr==8) then
		local allowed={Q=true,R=true,B=true,N=true}
		p.t=allowed[promotion] and promotion or "Q"
	end
	if p.t=="P" or captured then
		state.halfmove=0
	else
		state.halfmove=state.halfmove+1
	end
	state.turn=other(state.turn)
	local h=hash(state)
	state.repetition[h]=(state.repetition[h] or 0)+1
	return true
end
local function insufficient(state)
	local minors={}
	for r=1,8 do
		for c=1,8 do
			local p=state.board[r][c]
			if p and p.t~="K" then
				if p.t=="P" or p.t=="Q" or p.t=="R" then
					return false
				end
				table.insert(minors,{p=p,r=r,c=c})
			end
		end
	end
	if #minors==0 then return true end
	if #minors==1 then return true end
	if #minors==2
		and minors[1].p.t=="B"
		and minors[2].p.t=="B" then
		return ((minors[1].r+minors[1].c)%2)
			==((minors[2].r+minors[2].c)%2)
	end
	return false
end
function R.CanClaimDraw(state)
	if state.halfmove>=100 then return true,"Regra dos 50 lances" end
	if (state.repetition[hash(state)] or 0)>=3 then return true,"Tripla repetição" end
	return false
end
function R.Result(state)
	if state.halfmove>=150 then return "draw","Regra dos 75 lances" end
	if (state.repetition[hash(state)] or 0)>=5 then return "draw","Quíntupla repetição" end
	if insufficient(state) then return "draw","Material insuficiente" end
	local hasMove=false
	for r=1,8 do
		for c=1,8 do
			local p=state.board[r][c]
			if p and p.c==state.turn and #R.Legal(state,r,c)>0 then hasMove=true;break end
		end
		if hasMove then break end
	end
	if hasMove then return nil end
	if R.InCheck(state,state.turn) then return other(state.turn),"Xeque-mate" end
	return "draw","Afogamento"
end
return R
