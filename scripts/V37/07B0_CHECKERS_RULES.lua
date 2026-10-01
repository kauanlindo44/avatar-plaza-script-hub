-- 07B0_CHECKERS_RULES
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V37 - cópia cliente das regras para treino contra BOT.
-- múltiplas capturas e dama de longo alcance.

local R={}

local dirs={{1,1},{1,-1},{-1,1},{-1,-1}}

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
			if p then b[r][c]={c=p.c,k=p.k==true} end
		end
	end
	return b
end

local function captureMoves(board,r,c)
	local p=board[r] and board[r][c]
	if not p then return {} end
	local out={}

	if not p.k then
		for _,d in ipairs(dirs) do
			local er=r+d[1]
			local ec=c+d[2]
			local tr=r+d[1]*2
			local tc=c+d[2]*2
			local enemy=inside(er,ec) and board[er][ec]

			if inside(tr,tc)
				and enemy
				and enemy.c~=p.c
				and not board[tr][tc] then
				table.insert(out,{
					fr=r,fc=c,tr=tr,tc=tc,
					cr=er,cc=ec,capture=true
				})
			end
		end
	else
		for _,d in ipairs(dirs) do
			local rr=r+d[1]
			local cc=c+d[2]
			local enemy=nil

			while inside(rr,cc) do
				local cell=board[rr][cc]

				if not enemy then
					if cell then
						if cell.c==p.c then break end
						enemy={r=rr,c=cc}
					end
				else
					if cell then break end
					table.insert(out,{
						fr=r,fc=c,tr=rr,tc=cc,
						cr=enemy.r,cc=enemy.c,capture=true
					})
				end

				rr=rr+d[1]
				cc=cc+d[2]
			end
		end

	end

	return out
end

local function applyCopy(board,move)
	local b=copyBoard(board)
	local p=b[move.fr][move.fc]
	b[move.fr][move.fc]=nil
	b[move.tr][move.tc]=p

	if move.capture then
		b[move.cr][move.cc]=nil
	end

	if p and not p.k then
		if (p.c=="W" and move.tr==1)
			or (p.c=="B" and move.tr==8) then
			p.k=true
		end
	end

	return b
end

local function bestCaptureDepth(board,r,c,depth)
	depth=depth or 0
	if depth>12 then return 0 end

	local moves=captureMoves(board,r,c)
	if #moves==0 then return 0 end

	local best=0
	for _,m in ipairs(moves) do
		local b=applyCopy(board,m)
		local score=1+bestCaptureDepth(b,m.tr,m.tc,depth+1)
		if score>best then best=score end
	end
	return best
end

local function annotatedCaptures(board,r,c)
	local out={}
	for _,m in ipairs(captureMoves(board,r,c)) do
		local b=applyCopy(board,m)
		m.depth=1+bestCaptureDepth(b,m.tr,m.tc,0)
		table.insert(out,m)
	end
	return out
end

local function normalMoves(board,r,c)
	local p=board[r] and board[r][c]
	if not p then return {} end
	local out={}

	if p.k then
		for _,d in ipairs(dirs) do
			local rr=r+d[1]
			local cc=c+d[2]

			while inside(rr,cc) and not board[rr][cc] do
				table.insert(out,{fr=r,fc=c,tr=rr,tc=cc})
				rr=rr+d[1]
				cc=cc+d[2]
			end
		end
	else
		local dr=p.c=="W" and -1 or 1
		for _,dc in ipairs({-1,1}) do
			local rr=r+dr
			local cc=c+dc
			if inside(rr,cc) and not board[rr][cc] then
				table.insert(out,{fr=r,fc=c,tr=rr,tc=cc})
			end
		end
	end


	return out
end

function R.New()
	local board={}
	for r=1,8 do board[r]={} end

	for r=1,3 do
		for c=1,8 do
			if (r+c)%2==1 then
				board[r][c]={c="B",k=false}
			end
		end
	end

	for r=6,8 do
		for c=1,8 do
			if (r+c)%2==1 then
				board[r][c]={c="W",k=false}
			end
		end
	end

	return {
		board=board,
		turn="W",
		forced=nil,
		quiet=0
	}
end

function R.Legal(state,r,c)
	local board=state.board
	local p=board[r] and board[r][c]
	if not p or p.c~=state.turn then return {} end

	if state.forced then
		if state.forced.r~=r or state.forced.c~=c then return {} end

		local list=annotatedCaptures(board,r,c)
		local best=0
		for _,m in ipairs(list) do
			if m.depth>best then best=m.depth end
		end

		local out={}
		for _,m in ipairs(list) do
			if m.depth==best then table.insert(out,m) end
		end
		return out
	end

	local all={}
	local globalBest=0

	for rr=1,8 do
		for cc=1,8 do
			local q=board[rr][cc]
			if q and q.c==state.turn then
				for _,m in ipairs(annotatedCaptures(board,rr,cc)) do
					if m.depth>globalBest then globalBest=m.depth end
					table.insert(all,m)
				end
			end
		end
	end

	if globalBest>0 then
		local out={}
		for _,m in ipairs(all) do
			if m.fr==r and m.fc==c and m.depth==globalBest then
				table.insert(out,m)
			end
		end
		return out
	end


	return normalMoves(board,r,c)
end

function R.Apply(state,move)
	local board=state.board
	local p=board[move.fr][move.fc]
	if not p then return false end

	board[move.fr][move.fc]=nil
	board[move.tr][move.tc]=p

	if move.capture then
		board[move.cr][move.cc]=nil
		state.quiet=0
	else
		state.quiet=state.quiet+1
	end

	if not p.k then
		if (p.c=="W" and move.tr==1)
			or (p.c=="B" and move.tr==8) then
			p.k=true
		end
	end

	if move.capture then
		local next=annotatedCaptures(board,move.tr,move.tc)

		if #next>0 then
			state.forced={r=move.tr,c=move.tc}
			return true,"continue"
		end
	end

	state.forced=nil
	state.turn=other(state.turn)
	return true,"turn"
end

local function countPieces(board,color)
	local n=0
	for r=1,8 do
		for c=1,8 do
			local p=board[r][c]
			if p and p.c==color then n=n+1 end
		end
	end
	return n
end

function R.Result(state)
	if state.quiet>=80 then
		return "draw","Empate por sequência sem capturas"
	end

	local current=state.turn
	if countPieces(state.board,current)==0 then
		return other(current),"Sem peças"
	end

	local has=false
	for r=1,8 do
		for c=1,8 do
			if #R.Legal(state,r,c)>0 then
				has=true
				break
			end
		end
		if has then break end
	end

	if not has then
		return other(current),"Sem movimentos legais"
	end

	return nil
end

return R
