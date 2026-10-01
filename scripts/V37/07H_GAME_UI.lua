-- 07H_GAME_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V37 - Game Club completo: online, sala por código e treino contra BOT.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",30);if not kit then return end
local rem=kit:WaitForChild("Remotes");local event=rem:WaitForChild("HubGameUI");local request=rem:WaitForChild("GameRoomRequest");local push=rem:WaitForChild("GameRoomPush")
local Chess=require(Rep:WaitForChild("07A0_CHESS_RULES"));local Checkers=require(Rep:WaitForChild("07B0_CHECKERS_RULES"))
for _,n in ipairs({"HubGameGui","GameClubGui"})do local x=pg:FindFirstChild(n);if x then x:Destroy()end end

local gui=Instance.new("ScreenGui");gui.Name="GameClubGui";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=120;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local C={bg=Color3.fromRGB(15,16,20),card=Color3.fromRGB(35,37,43),soft=Color3.fromRGB(49,52,60),blue=Color3.fromRGB(72,142,201),purple=Color3.fromRGB(111,84,174),green=Color3.fromRGB(68,201,117),red=Color3.fromRGB(218,77,91),gold=Color3.fromRGB(226,174,69),white=Color3.fromRGB(247,248,250),muted=Color3.fromRGB(173,176,184),light=Color3.fromRGB(222,224,226),dark=Color3.fromRGB(69,72,78)}
local function round(o,n)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,n or 10);c.Parent=o endlocal function fit(o)o.TextScaled=false;o.TextWrapped=true end
local function text(p,s,pos,size,fs,col)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=s;t.TextColor3=col or C.white;t.Font=Enum.Font.GothamBold;t.TextSize=fs or 11;t.TextWrapped=true;t.Parent=p;return t end
local function btn(p,s,pos,size,col)local b=Instance.new("TextButton");b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.Text=s;b.TextColor3=C.white;b.Font=Enum.Font.GothamBlack;b.TextSize=10;b.AutoButtonColor=true;b.Parent=p;round(b,9);fit(b,8,16);return b end
local function call(action,a)local ok,r=pcall(function()return request:InvokeServer(action,a)end);if not ok then return nil,"Servidor indisponível."end;if not r or r.ok~=true then return nil,r and r.error or"Falha."end;return r end
local hidden={};local function hideExternal(on)for _,n in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","ACP_PhotoMode","PlazaProgressGui","ACP_TitlesGui"})do local x=pg:FindFirstChild(n);if x then if on then if hidden[x]==nil then hidden[x]=x.Enabled end;x.Enabled=false elseif hidden[x]~=nil then x.Enabled=hidden[x];hidden[x]=nil end end end end
local notice=text(gui,"",UDim2.new(.5,-200,0,24),UDim2.fromOffset(400,46),11,C.white);notice.BackgroundTransparency=.12;notice.BackgroundColor3=C.bg;notice.Visible=false;notice.ZIndex=20;round(notice,10)
local token=0;local function noticeMsg(msg,secs)token=token+1;local mine=token;notice.Text=tostring(msg or"");notice.Visible=true;task.delay(secs or 3,function()if mine==token then notice.Visible=false end end)end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.18;shade.Visible=false;shade.Parent=gui
local club=Instance.new("Frame");club.AnchorPoint=Vector2.new(.5,.5);club.Position=UDim2.fromScale(.5,.5);club.Size=UDim2.fromOffset(620,430);club.BackgroundColor3=C.bg;club.BorderSizePixel=0;club.Visible=false;club.Parent=gui;round(club,14);local clubScale=Instance.new("UIScale");clubScale.Parent=club
text(club,"GAME CLUB",UDim2.fromOffset(18,12),UDim2.new(1,-80,0,28),17,C.white);text(club,"ONLINE • SALA PRIVADA • TREINO CONTRA BOT",UDim2.fromOffset(18,38),UDim2.new(1,-80,0,18),8,C.muted)
local close=btn(club,"X",UDim2.new(1,-52,0,9),UDim2.fromOffset(40,34),C.red)
local selected="Xadrez";local gameBtns={};local y=70
for _,g in ipairs({"Xadrez","Damas","Batata"})do local b=btn(club,string.upper(g=="Batata"and"BATATA ENVENENADA"or g),UDim2.fromOffset(18,y),UDim2.fromOffset(178,48),g==selected and C.green or C.card);gameBtns[g]=b;y=y+58 end
local desc=text(club,"Escolha um jogo e depois o modo.",UDim2.fromOffset(218,70),UDim2.new(1,-236,0,42),10,C.muted)
local quick=btn(club,"PARTIDA RÁPIDA ONLINE",UDim2.fromOffset(218,118),UDim2.new(1,-236,0,40),C.green)
local bot=btn(club,"TREINAR CONTRA BOT",UDim2.fromOffset(218,166),UDim2.new(1,-236,0,40),C.gold)
text(club,"DIFICULDADE DO BOT",UDim2.fromOffset(218,211),UDim2.fromOffset(160,18),7,C.muted)
local diff="MÉDIO";local diffBtns={};for i,d in ipairs({"FÁCIL","MÉDIO","DIFÍCIL"})do local b=btn(club,d,UDim2.fromOffset(218+(i-1)*126,232),UDim2.fromOffset(116,34),d==diff and C.purple or C.card);diffBtns[d]=b end
local create=btn(club,"CRIAR SALA",UDim2.fromOffset(218,278),UDim2.fromOffset(178,40),C.blue);local join=btn(club,"ENTRAR",UDim2.fromOffset(404,278),UDim2.fromOffset(198,40),C.purple)
local codeBox=Instance.new("TextBox");codeBox.Position=UDim2.fromOffset(218,326);codeBox.Size=UDim2.new(1,-236,0,38);codeBox.BackgroundColor3=C.card;codeBox.BorderSizePixel=0;codeBox.PlaceholderText="CÓDIGO DA SALA";codeBox.Text="";codeBox.TextColor3=C.white;codeBox.PlaceholderColor3=C.muted;codeBox.Font=Enum.Font.GothamBold;codeBox.TextSize=11;codeBox.ClearTextOnFocus=false;codeBox.Parent=club;round(codeBox,9);fit(codeBox,8,16)
local roomStatus=text(club,"",UDim2.fromOffset(218,370),UDim2.new(1,-236,0,24),9,C.white);local cancel=btn(club,"CANCELAR ESPERA",UDim2.fromOffset(218,397),UDim2.new(1,-236,0,26),C.red);cancel.Visible=false
local function paint()for g,b in pairs(gameBtns)do b.BackgroundColor3=g==selected and C.green or C.card end;for d,b in pairs(diffBtns)do b.BackgroundColor3=d==diff and C.purple or C.card end end
for g,b in pairs(gameBtns)do b.Activated:Connect(function()selected=g;roomStatus.Text="";paint()end)end;for d,b in pairs(diffBtns)do b.Activated:Connect(function()diff=d;paint()end)end;paint()
local function refreshStats()local r=call("stats");if r and r.waiting then desc.Text=string.format("Aguardando agora: Xadrez %d • Dama %d • Batata %d",r.waiting.Xadrez or 0,r.waiting.Damas or 0,r.waiting.Batata or 0)end end
local function openClub()shade.Visible=true;club.Visible=true;hideExternal(true);cancel.Visible=false;roomStatus.Text="";refreshStats()end
local function closeClub()if cancel.Visible then call("cancel")end;club.Visible=false;shade.Visible=false;hideExternal(false)end
close.Activated:Connect(closeClub);quick.Activated:Connect(function()local r,e=call("quick",selected);if not r then roomStatus.Text=e;return end;roomStatus.Text=r.matched and"Adversário encontrado!"or("Procurando jogador... código "..r.code);cancel.Visible=not r.matched end)
create.Activated:Connect(function()local r,e=call("create",selected);if not r then roomStatus.Text=e;return end;codeBox.Text=r.code;roomStatus.Text="Sala criada: "..r.code.." • envie ao amigo";cancel.Visible=true end)
join.Activated:Connect(function()local r,e=call("join",codeBox.Text);if not r then roomStatus.Text=e;return end;roomStatus.Text="Entrando na sala "..r.code;cancel.Visible=false end);cancel.Activated:Connect(function()call("cancel");cancel.Visible=false;roomStatus.Text="Espera cancelada.";refreshStats()end)
local oldNonce=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;pg:GetAttributeChangedSignal("ACP_OpenGamesNonce"):Connect(function()local n=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;if n~=oldNonce then oldNonce=n;openClub()end end)

local board=Instance.new("Frame");board.AnchorPoint=Vector2.new(.5,.5);board.Position=UDim2.fromScale(.5,.5);board.Size=UDim2.fromOffset(630,520);board.BackgroundColor3=C.bg;board.BorderSizePixel=0;board.Visible=false;board.Parent=gui;round(board,14);local boardScale=Instance.new("UIScale");boardScale.Parent=board
local boardTitle=text(board,"",UDim2.fromOffset(18,12),UDim2.new(1,-100,0,28),16,C.white);local message=text(board,"",UDim2.fromOffset(18,42),UDim2.new(1,-36,0,28),10,C.muted)
local grid=Instance.new("Frame");grid.Position=UDim2.fromOffset(18,78);grid.Size=UDim2.fromOffset(400,400);grid.BackgroundTransparency=1;grid.Parent=board
local cells={};for vr=1,8 do cells[vr]={};for vc=1,8 do local b=btn(grid,"",UDim2.fromOffset((vc-1)*50,(vr-1)*50),UDim2.fromOffset(50,50),(vr+vc)%2==0 and C.light or C.dark);b.TextSize=16;cells[vr][vc]=b end end
local side=text(board,"",UDim2.fromOffset(438,86),UDim2.fromOffset(174,64),10,C.white);local clock=text(board,"",UDim2.fromOffset(438,154),UDim2.fromOffset(174,58),12,C.white)
local claim=btn(board,"PEDIR EMPATE",UDim2.fromOffset(438,225),UDim2.fromOffset(174,38),C.card);local resign=btn(board,"DESISTIR",UDim2.fromOffset(438,272),UDim2.fromOffset(174,38),C.red);local minimize=btn(board,"MINIMIZAR",UDim2.fromOffset(438,319),UDim2.fromOffset(174,38),C.card)
local mini=btn(gui,"VOLTAR AO JOGO",UDim2.new(1,-192,1,-58),UDim2.fromOffset(174,40),C.blue);mini.Visible=false
local promo=Instance.new("Frame");promo.AnchorPoint=Vector2.new(.5,.5);promo.Position=UDim2.fromScale(.5,.5);promo.Size=UDim2.fromOffset(320,100);promo.BackgroundColor3=C.card;promo.Visible=false;promo.Parent=gui;round(promo,12);text(promo,"PROMOVER PARA",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,24),12,C.white)
local current
for i,piece in ipairs({"Q","R","B","N"})do local b=btn(promo,piece,UDim2.fromOffset(12+(i-1)*76,45),UDim2.fromOffset(66,42),C.blue);b.Activated:Connect(function()promo.Visible=false;if current then event:FireServer("promotionChoice",current.tableName,piece)end end)end

local potato=Instance.new("Frame");potato.Position=UDim2.fromOffset(18,90);potato.Size=UDim2.fromOffset(400,250);potato.BackgroundTransparency=1;potato.Visible=false;potato.Parent=board
local potatoBtns={};for i=1,10 do local r=math.floor((i-1)/5);local c=(i-1)%5;local b=btn(potato,tostring(i),UDim2.fromOffset(c*78,r*104),UDim2.fromOffset(70,88),C.gold);potatoBtns[i]=b end

current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};local botState=nil;local activeTable=nil;local potatoActive=false
local camera=workspace.CurrentCamera;local oldCameraType=nil;local oldSubject=nil
local function restoreCamera()if oldCameraType then camera.CameraType=oldCameraType;camera.CameraSubject=oldSubject;oldCameraType=nil;oldSubject=nil end end
local function potatoCamera(tableName)local w=workspace:FindFirstChild("PracaAvatar_V2");local d=w and w:FindFirstChild("ChallengeDistrict");local z=d and d:FindFirstChild("Batata");local t=z and z:FindFirstChild(tostring(tableName));local tray=t and t:FindFirstChild("PotatoTray");if not tray then return end;oldCameraType=camera.CameraType;oldSubject=camera.CameraSubject;camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(tray.Position+Vector3.new(0,10,11),tray.Position+Vector3.new(0,.4,0))end
local function fmt(v)v=math.max(0,math.floor(tonumber(v)or 0));return string.format("%d:%02d",math.floor(v/60),v%60)end
local function key(r,c)return r..":"..c end
local function viewToActual(vr,vc,sideName)if sideName=="B"then return 9-vr,9-vc end;return vr,vc end
local function pieceText(p,game)if not p then return""end;if game=="Damas"then return p.k and"K"or"O"end;return tostring(p.t or"")end
local function drawState(state,game,sideName,selectedMove,hints)
 for vr=1,8 do for vc=1,8 do local r,c=viewToActual(vr,vc,sideName);local p=state.board[r]and state.board[r][c];local b=cells[vr][vc];b.Text=pieceText(p,game);b.TextColor3=p and p.c=="W"and Color3.fromRGB(250,250,250)or Color3.fromRGB(18,18,20);local base=(vr+vc)%2==0 and C.light or C.dark;b.BackgroundColor3=hints[key(r,c)]and C.green or(selectedMove and selectedMove.r==r and selectedMove.c==c and C.blue or base)end end
end
local function redrawOnline()if not current.board then return end;drawState(current,current.game,current.side,current.selected,current.hints);side.Text="Você joga: "..(current.side=="W"and"CLARAS"or"ESCURAS")end

local function allMoves(rules,state)local out={};for r=1,8 do for c=1,8 do for _,m in ipairs(rules.Legal(state,r,c))do table.insert(out,m)end end end;return out end
local val={P=1,N=3,B=3,R=5,Q=9,K=40};local function moveScore(bs,m)
 local p=bs.state.board[m.tr]and bs.state.board[m.tr][m.tc];local score=0
 if bs.game=="Xadrez"then score=p and(val[p.t]or 1)*10 or 0;score=score+(4-math.abs(4.5-m.tc))*.5+(4-math.abs(4.5-m.tr))*.5;if m.tr==8 or m.tr==1 then score=score+4 end
 else score=m.capture and 12 or 0;if m.tr==8 then score=score+4 end end
 return score+math.random()*1.8
end
local function chooseBot(bs)
 local moves=allMoves(bs.rules,bs.state);if #moves==0 then return nil end
 if bs.diff=="FÁCIL"then return moves[math.random(1,#moves)]end
 table.sort(moves,function(a,b)return moveScore(bs,a)>moveScore(bs,b)end)
 if bs.diff=="MÉDIO"and #moves>2 then return moves[math.random(1,math.min(3,#moves))]end
 return moves[1]
end
local function botResult()
 if not botState then return false end;local who,why=botState.rules.Result(botState.state);if not who then return false end
 local msg=who=="draw"and("EMPATE • "..tostring(why or""))or who=="W"and"VOCÊ VENCEU O BOT"or"BOT VENCEU"
 botState.finished=true;message.Text=msg;noticeMsg(msg,5);return true
end
local function redrawBot()
 if not botState then return end;grid.Visible=botState.game~="Batata";potato.Visible=botState.game=="Batata";claim.Visible=false;clock.Text="TREINO\n"..botState.diff;side.Text=botState.game=="Batata"and"Escolha uma batata"or"Você: CLARAS\nBOT: ESCURAS"
 if botState.game~="Batata"then drawState(botState.state,botState.game,"W",botState.selected,botState.hints)end
end
local function botTurn()
 if not botState or botState.finished or botState.game=="Batata"or botResult()then return end
 task.delay(.35,function()
  while botState and botState.state.turn=="B"do local m=chooseBot(botState);if not m then break end;botState.rules.Apply(botState.state,m,"Q");redrawBot();if botResult()then return end;task.wait(.18)end
  if botState then message.Text="Sua vez." end
 end)
end
local function endBot()botState=nil;potato.Visible=false;grid.Visible=true;board.Visible=false;shade.Visible=true;club.Visible=true;resign.Text="DESISTIR";minimize.Visible=true;hideExternal(true)end
local function startPotato()
 local poisons={};local n=diff=="FÁCIL"and 1 or diff=="MÉDIO"and 2 or 3
 while n>0 do local i=math.random(1,10);if not poisons[i]then poisons[i]=true;n=n-1 end end
 botState.poisons=poisons;botState.remaining={};for i=1,10 do botState.remaining[i]=true;potatoBtns[i].Text=tostring(i);potatoBtns[i].BackgroundColor3=C.gold;potatoBtns[i].Active=true end
 message.Text="Sua vez • escolha uma batata.";redrawBot()
end
local function botPotatoPick()
 if not botState then return end;local opts={};for i=1,10 do if botState.remaining[i]then table.insert(opts,i)end end;if #opts==0 then message.Text="EMPATE";return end
 local i=opts[math.random(1,#opts)];botState.remaining[i]=nil;potatoBtns[i].Text="BOT";potatoBtns[i].BackgroundColor3=C.soft
 if botState.poisons[i]then botState.finished=true;message.Text="BOT PEGOU A ENVENENADA • VOCÊ VENCEU";noticeMsg(message.Text,5)else message.Text="BOT passou • sua vez." end
end
for i,b in ipairs(potatoBtns)do b.Activated:Connect(function()
 if not botState or botState.finished or botState.game~="Batata"or not botState.remaining[i]then return end;botState.remaining[i]=nil;b.Text="VOCÊ";b.BackgroundColor3=C.blue
 if botState.poisons[i]then botState.finished=true;message.Text="VOCÊ PEGOU A ENVENENADA • BOT VENCEU";noticeMsg(message.Text,5);return end;message.Text="Seguro. BOT escolhendo...";task.delay(.45,botPotatoPick)
end)end
local function startBot()
 club.Visible=false;shade.Visible=true;board.Visible=true;hideExternal(true);resign.Text="SAIR TREINO";minimize.Visible=false
 if selected=="Batata"then botState={game="Batata",diff=diff};boardTitle.Text="BATATA • BOT "..diff;startPotato();return end
 local rules=selected=="Xadrez"and Chess or Checkers;botState={game=selected,diff=diff,rules=rules,state=rules.New(),selected=nil,hints={}};boardTitle.Text=string.upper(selected).." • BOT "..diff;message.Text="Sua vez.";redrawBot()
end
bot.Activated:Connect(startBot)

local function botTap(r,c)
 if not botState or botState.finished or botState.game=="Batata"or botState.state.turn~="W"then return end
 local st=botState.state;local p=st.board[r]and st.board[r][c]
 if botState.selected and botState.hints[key(r,c)]then local list=botState.rules.Legal(st,botState.selected.r,botState.selected.c);for _,m in ipairs(list)do if m.tr==r and m.tc==c then botState.rules.Apply(st,m,"Q");break end end;botState.selected=nil;botState.hints={};redrawBot();if not botResult()then botTurn()end;return end
 botState.selected=nil;botState.hints={};if p and p.c=="W"then botState.selected={r=r,c=c};for _,m in ipairs(botState.rules.Legal(st,r,c))do botState.hints[key(m.tr,m.tc)]=true end end;redrawBot()
end
for vr=1,8 do for vc=1,8 do cells[vr][vc].Activated:Connect(function()local sideName=botState and"W"or current.side;local r,c=viewToActual(vr,vc,sideName);if botState then botTap(r,c)elseif current.game then event:FireServer("boardTap",current.tableName,r,c)end end)end end
claim.Activated:Connect(function()if not botState and current.game=="Xadrez"then event:FireServer("claimDraw",current.tableName)end end)
resign.Activated:Connect(function()if botState then endBot()elseif current.game then event:FireServer("resignGame",current.tableName)end end);minimize.Activated:Connect(function()board.Visible=false;shade.Visible=false;mini.Visible=current.game~=nil end);mini.Activated:Connect(function()if current.game then shade.Visible=true;board.Visible=true;mini.Visible=false end end)

local function releaseRoom()restoreCamera();pcall(function()request:InvokeServer("leave")end);activeTable=nil;potatoActive=false;current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};board.Visible=false;mini.Visible=false;promo.Visible=false;shade.Visible=false;hideExternal(false)end
push.OnClientEvent:Connect(function(action,data)if action=="matched"then club.Visible=false;shade.Visible=false;cancel.Visible=false;activeTable=data and data.tableName;hideExternal(true);noticeMsg("Partida encontrada • "..tostring(data and data.game or"jogo"),2.5)elseif action=="roomClosed"then releaseRoom()end end)
event.OnClientEvent:Connect(function(action,data,b)
 if action=="notice"or action=="result"then message.Text=tostring(data or"");noticeMsg(data,b or(action=="result"and 6 or 3));return end
 if action=="boardOpen"and type(data)=="table"then current.game=data.game;current.tableName=data.tableName;current.side=data.side or"W";current.board=data.board;current.hints={};boardTitle.Text=tostring(data.game or"JOGO");claim.Visible=current.game=="Xadrez";resign.Text="DESISTIR";minimize.Visible=true;shade.Visible=true;board.Visible=true;mini.Visible=false;grid.Visible=true;potato.Visible=false;hideExternal(true);redrawOnline()
 elseif action=="boardState"and type(data)=="table"and data.tableName==current.tableName then current.board=data.board or current.board;current.selected=data.selected;current.hints={};for _,m in ipairs(data.hints or{})do current.hints[key(m.r,m.c)]=true end;current.turn=data.turn or current.turn;message.Text=tostring(data.message or data.turnText or"");clock.Text="CLARAS "..fmt(data.whiteTime).."\nESCURAS "..fmt(data.blackTime);redrawOnline()
 elseif action=="promotion"then promo.Visible=true elseif action=="boardClose"and(type(data)~="table"or data.tableName==current.tableName)then releaseRoom()
 elseif action=="potatoOpen"and type(data)=="table"then activeTable=data.tableName;potatoActive=true;hideExternal(true);message.Text="Batata Envenenada iniciada.";noticeMsg(message.Text,4);task.defer(function()potatoCamera(activeTable)end)
 elseif action=="potatoState"and type(data)=="table"and data.tableName==activeTable then message.Text=tostring(data.message or"Escolha uma batata.");noticeMsg(message.Text,2)
 elseif action=="potatoClose"and(type(data)~="table"or data.tableName==activeTable)then releaseRoom()end
end)
local function bindChar(char)local hum=char:WaitForChild("Humanoid",10);if not hum then return end;hum.Seated:Connect(function(active,seat)if active and seat then local t=seat.Parent;if t and t:IsA("Model")and t:GetAttribute("GameType")and t:GetAttribute("ACP_RoomCode")then activeTable=t.Name;task.delay(.15,function()if seat.Occupant==hum then event:FireServer("readyGame",t.Name)end end)end end end)end
pl.CharacterAdded:Connect(bindChar);if pl.Character then local ch=pl.Character;task.defer(function()bindChar(ch)end)end
local function adapt()local vp=workspace.CurrentCamera.ViewportSize;clubScale.Scale=math.min(1,(vp.X-24)/620,(vp.Y-24)/430);boardScale.Scale=math.min(1,(vp.X-24)/630,(vp.Y-24)/520)end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt);task.defer(adapt)
UIS.InputBegan:Connect(function(input,gp)if gp or not potatoActive then return end;if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end;local cam=workspace.CurrentCamera;local ray=cam:ViewportPointToRay(input.Position.X,input.Position.Y);local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={pl.Character};local hit=workspace:Raycast(ray.Origin,ray.Direction*500,params);local inst=hit and hit.Instance;if inst and inst:GetAttribute("ACPInputType")=="Potato"then event:FireServer("potatoTap",activeTable,inst:GetAttribute("ACPIndex"))end end)
print("AVATAR PLAZA V37: Game Club online + BOT pronto")
