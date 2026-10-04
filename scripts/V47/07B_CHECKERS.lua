-- 07B_CHECKERS
-- Script | ServerScriptService
-- AVATAR CREATOR PLAZA V27.5
-- Damas brasileiras 4:00: servidor oficial para o tabuleiro 2D premium.

local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Rep=game:GetService("ReplicatedStorage")

local kit=Rep:WaitForChild("PracaKit",30)
if not kit then return end
while not kit:GetAttribute("ActivitiesReady") do task.wait(.1) end

local world=workspace:WaitForChild("PracaAvatar_V2",20)
local district=world and world:FindFirstChild("ChallengeDistrict")
local zone=district and district:FindFirstChild("Damas")
if not zone then warn("07B_CHECKERS: Damas não encontradas");return end

local Visual=require(script.Parent:WaitForChild("07Z_BOARD_VISUALS"))
local Rules=require(script.Parent:WaitForChild("07B0_CHECKERS_RULES"))
local Wins=require(script.Parent:WaitForChild("07W_WINS_SERVICE"))
local event=kit.Remotes:WaitForChild("HubGameUI")

local states={}
local selected={}
local tapGuard={}
local function freshTap(p,t,r,c)
	local now=os.clock();local old=tapGuard[p]
	if old and old.table==t and old.r==r and old.c==c and now-old.time<.28 then return false end
	tapGuard[p]={table=t,r=r,c=c,time=now}
	return true
end
local readyByTable={}

local function safeFire(pl,...)
	if pl and pl.Parent==Players then event:FireClient(pl,...) end
end

local function colorOf(s,p)
	if s.players.W==p then return "W" end
	if s.players.B==p then return "B" end
end

local function seatedPlayers(t)
	return Visual.SeatedPlayers(t)
end

local function isSeatedAt(t,p)
	local n=seatedPlayers(t)
	return n.SeatA==p or n.SeatB==p
end

local function notice(p,m,d)
	safeFire(p,"notice",m,d or 4)
end

local function hints(cur)
	local out={}
	for _,m in ipairs(cur and cur.moves or {}) do
		table.insert(out,{r=m.tr,c=m.tc})
	end
	return out
end

local function tick(s)
 if s.reconnectUntil and os.clock()<s.reconnectUntil then s.lastClock=os.clock();return end
	local now=os.clock()
	local delta=math.max(0,now-(s.lastClock or now))
	s.lastClock=now
	if s.active then
		s.clock[s.game.turn]=math.max(0,s.clock[s.game.turn]-delta)
	end
end

local function send(t,s,msg)
	if not s or not s.active then return end
	tick(s)
	local cur=selected[t]
	local payload={
		tableName=t.Name,
		board=s.game.board,
		selected=cur and {r=cur.r,c=cur.c} or nil,
		hints=hints(cur),
		whiteTime=s.clock.W,
		blackTime=s.clock.B,
		turnText="Turno: "..(s.game.turn=="W" and "CLARAS" or "VERMELHAS"),
		message=msg,
		turn=s.game.turn
	}
	safeFire(s.players.W,"boardState",payload)
	safeFire(s.players.B,"boardState",payload)
end

local function clearSel(t)
	selected[t]=nil
	Visual.ClearHighlights(t)
end

local function status(t,s)
	if not s or not s.active then return end
	local p=s.players[s.game.turn]
	if not p then return end
	local extra=s.game.forced and " • continue a captura" or ""
	Visual.Status(t,"Turno: @"..p.Name.." • "..(s.game.turn=="W" and "CLARAS" or "VERMELHAS")..extra)
	send(t,s,extra~="" and "Captura múltipla obrigatória." or nil)
end

local function render(t,s)
	Visual.RenderCheckers(t,s.game.board,function(p,r,c)
		if states[t]==s and freshTap(p,t,r,c) then s.click(p,r,c) end
	end)
end

local function resetLobby(t,s)
	task.delay(5,function()
		if states[t]~=s then return end
		states[t]=nil
		readyByTable[t]={}
		local pp=t:FindFirstChild("GamePromptPart")
		local prompt=pp and pp:FindFirstChild("GamePrompt")
		if prompt then prompt.Enabled=false end
		Visual.Status(t,"Aguardando jogadores")
		local n=seatedPlayers(t)
		if n.SeatA and n.SeatB then
			if prompt then prompt.Enabled=true end
			Visual.Status(t,"2 jogadores sentados • ambos apertem JOGAR")
		end
	end)
end

local function endGame(t,winner,reason)
	local s=states[t]
	if not s or not s.active then return end
	s.active=false
	clearSel(t)
	Visual.ClearRuntime(t)

	local text
	if winner=="draw" then
        if t:GetAttribute("ACP_Cup")then task.spawn(function()require(script.Parent:WaitForChild("07K13_TOURNAMENT_SERVICE")).Draw(t:GetAttribute("ACP_Cup"),t:GetAttribute("ACP_CupMatch"))end)end
		text="EMPATE • "..tostring(reason or "")
	else
		local p=s.players[winner]
		local loser=s.players[winner=="W" and "B" or "W"]
		if p and p.Parent==Players then
			Wins.RecordMatch("Damas",p,loser,{id=s.matchID,duration=os.clock()-s.startedAt,moves=s.moveCount,cup=t:GetAttribute("ACP_Cup"),cupMatch=t:GetAttribute("ACP_CupMatch")})
			text="VENCEDOR: @"..p.Name.." • "..tostring(reason or "vitória")
			safeFire(p,"result","🏆 Você venceu nas damas! 🔥 "..tostring(p:GetAttribute("HubStreak") or 1),7)
			if loser then safeFire(loser,"result","Partida encerrada • "..tostring(reason or "derrota"),5) end
		else
			text="Partida encerrada"
		end
	end

	Visual.Status(t,text)
	safeFire(s.players.W,"boardClose",{tableName=t.Name})
	safeFire(s.players.B,"boardClose",{tableName=t.Name})
	local f=script.Parent:FindFirstChild("ACP_BoardFinished");if f then f:Fire(t:GetAttribute("ACP_RoomCode"))end
	resetLobby(t,s)
end

local function applyMove(t,s,m)
	if not s.active then return end
	tick(s)
	local ok,mode=Rules.Apply(s.game,m)
	if not ok then return end
	s.moveCount=s.moveCount+1
	s.lastClock=os.clock()
	clearSel(t)
	render(t,s)

	local result,why=Rules.Result(s.game)
	if result then
		endGame(t,result,why)
		return
	end

	if mode=="continue" then
		local f=s.game.forced
		local legal=Rules.Legal(s.game,f.r,f.c)
		selected[t]={r=f.r,c=f.c,moves=legal}
		Visual.Highlight(t,f.r,f.c,Color3.fromRGB(255,211,76))
		for _,x in ipairs(legal) do
			Visual.Highlight(t,x.tr,x.tc,Color3.fromRGB(69,190,236))
		end
	end
	status(t,s)
end

local function choose(t,s,p,r,c)
 if s.reconnectUntil then return end
	if not s.active or not isSeatedAt(t,p) then return end
	r,c=tonumber(r),tonumber(c)
	if not r or not c or r<1 or r>8 or c<1 or c>8 then return end

	local col=colorOf(s,p)
	if col~=s.game.turn then notice(p,"Aguarde seu turno.");return end

	local cur=selected[t]
	local piece=s.game.board[r] and s.game.board[r][c]

	if not cur or (piece and piece.c==col and not s.game.forced) then
		if not piece or piece.c~=col then
			notice(p,"Selecione uma peça sua.")
			return
		end
		local legal=Rules.Legal(s.game,r,c)
		if #legal==0 then
			notice(p,"Essa peça não joga agora. Pode existir captura obrigatória.")
			return
		end
		selected[t]={r=r,c=c,moves=legal}
		Visual.ClearHighlights(t)
		Visual.Highlight(t,r,c,Color3.fromRGB(255,211,76))
		for _,m in ipairs(legal) do
			Visual.Highlight(t,m.tr,m.tc,Color3.fromRGB(69,190,236))
		end
		send(t,s,"Escolha uma casa azul.")
		return
	end

	local chosen=nil
	for _,m in ipairs(cur.moves) do
		if m.tr==r and m.tc==c then chosen=m;break end
	end
	if not chosen then
		if s.game.forced then
			notice(p,"Continue a captura com a mesma peça.")
		else
			Visual.ClearHighlights(t);Visual.Highlight(t,cur.r,cur.c,Color3.fromRGB(255,211,76))
			for _,m in ipairs(cur.moves)do Visual.Highlight(t,m.tr,m.tc,Color3.fromRGB(69,190,236))end
			send(t,s,"Essa casa não vale • toque numa casa AZUL ou em outra peça sua.")
		end
		return
	end
	applyMove(t,s,chosen)
end

local function start(t,a,b)
	local s={
		active=true,matchID=Http:GenerateGUID(false),startedAt=os.clock(),moveCount=0,
		players={W=a,B=b},
		game=Rules.New(),
		clock={W=240,B=240},
		lastClock=os.clock()
	}
	states[t]=s
	if t:GetAttribute("ACP_Cup")then task.spawn(function()require(script.Parent:WaitForChild("07K13_TOURNAMENT_SERVICE")).Begin(t:GetAttribute("ACP_Cup"),t:GetAttribute("ACP_CupMatch"))end)end
	readyByTable[t]={}
	s.click=function(p,r,c) choose(t,s,p,r,c) end

	local pp=t:FindFirstChild("GamePromptPart")
	local prompt=pp and pp:FindFirstChild("GamePrompt")
	if prompt then prompt.Enabled=false end

	Visual.ClearRuntime(t)
	Visual.EnableSquares(t,function(p,r,c) if freshTap(p,t,r,c) then choose(t,s,p,r,c) end end)
	render(t,s)

	safeFire(a,"boardOpen",{game="Damas",tableName=t.Name,side="W",board=s.game.board})
	safeFire(b,"boardOpen",{game="Damas",tableName=t.Name,side="B",board=s.game.board})
	notice(a,"Peças CLARAS • 4:00")
	notice(b,"Peças VERMELHAS • 4:00")
	status(t,s)

	task.spawn(function()
		while states[t]==s and s.active do
			task.wait(.5)
			tick(s)
			if s.clock[s.game.turn]<=0 then
				endGame(t,s.game.turn=="W" and "B" or "W","tempo esgotado")
				break
			end
			send(t,s)
		end
	end)
end

local function markReady(t,p)
	if states[t] or not isSeatedAt(t,p) then return end
	local n=seatedPlayers(t)
	if not n.SeatA or not n.SeatB then
		notice(p,"Espere o segundo jogador sentar.")
		return
	end

	local ready=readyByTable[t] or {}
	readyByTable[t]=ready
	ready[p.UserId]=true
	notice(p,"Pronto! Aguardando o outro jogador.")

	if ready[n.SeatA.UserId] and ready[n.SeatB.UserId] then
		start(t,n.SeatA,n.SeatB)
	else
		Visual.Status(t,"@"..p.Name.." pronto • falta o outro jogador")
	end
end

local function setup(t)
	local pp=t:FindFirstChild("GamePromptPart")
	local prompt=pp and pp:FindFirstChild("GamePrompt")
	if not prompt then warn("07B_CHECKERS: prompt ausente em "..t.Name);return end

	prompt.HoldDuration=0
	prompt.MaxActivationDistance=24
	prompt.RequiresLineOfSight=false
	prompt.ActionText="JOGAR"
	prompt.ObjectText="DAMAS"

	local function refresh()
		if states[t] then
			local s=states[t]
			if s.active then
				local n=seatedPlayers(t)
				if n.SeatA~=s.players.W or n.SeatB~=s.players.B then
                    if t:GetAttribute("ACP_Cup")then if not s.reconnectUntil then s.reconnectUntil=os.clock()+180;task.delay(180,function()if states[t]==s and s.active and s.reconnectUntil then local v=seatedPlayers(t);local w=v.SeatA==s.players.W and"W"or v.SeatB==s.players.B and"B"or"draw";endGame(t,w,"prazo de reconexão encerrado")end end)end;return end
					local winner
					if n.SeatA~=s.players.W and n.SeatB==s.players.B then winner="B"
					elseif n.SeatB~=s.players.B and n.SeatA==s.players.W then winner="W" end
					endGame(t,winner or "draw",winner and "abandono" or "os dois saíram")
				end
                s.reconnectUntil=nil
			end
			return
		end

		readyByTable[t]={}
		local n=seatedPlayers(t)
		if n.SeatA and n.SeatB then
			prompt.Enabled=true
			Visual.Status(t,"2 jogadores sentados • ambos apertem JOGAR")
		elseif n.SeatA or n.SeatB then
			prompt.Enabled=false
			Visual.Status(t,"Aguardando o segundo jogador")
		else
			prompt.Enabled=false
			Visual.Status(t,"Aguardando jogadores")
		end
	end

	t.SeatA:GetPropertyChangedSignal("Occupant"):Connect(refresh)
	t.SeatB:GetPropertyChangedSignal("Occupant"):Connect(refresh)
	prompt.Triggered:Connect(function(p) markReady(t,p) end)
	refresh()
end

for _,t in ipairs(zone:GetChildren()) do
	if t:IsA("Model") and t:GetAttribute("GameType")=="Damas" then setup(t) end
end

event.OnServerEvent:Connect(function(p,action,tableName,a,b)
	local t=zone:FindFirstChild(tostring(tableName))
	if not t then return end

	if action=="readyGame" then
		markReady(t,p)
		return
	end

	local s=states[t]
	if not s then return end

	if action=="boardTap" then
		local r,c=tonumber(a),tonumber(b);if r and c and freshTap(p,t,r,c) then choose(t,s,p,r,c) end
	elseif action=="resignGame" then
		local col=colorOf(s,p)
		if col then endGame(t,col=="W" and "B" or "W","desistência") end
	end
end)

print("AVATAR CREATOR PLAZA V27.5: damas 2D premium prontas")

Players.PlayerRemoving:Connect(function(p) tapGuard[p]=nil end)


script.Parent:WaitForChild("ACP_BoardReconnect").Event:Connect(function(kind,name,pl)if kind~="Damas"then return end;local t=zone:FindFirstChild(name);local s=t and states[t];if not s or not s.active then return end;for col,p in pairs(s.players)do if p.UserId==pl.UserId then s.players[col]=pl;safeFire(pl,"boardOpen",{game=kind,tableName=name,side=col,board=s.game.board,turn=s.game.turn});break end end end)
