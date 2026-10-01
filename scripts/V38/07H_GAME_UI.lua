-- 07H_GAME_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V38 - Game Club 2D premium.
-- Xadrez e Damas usam peças 2D desenhadas com UI; Batata mantém modo online e treino local.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",30);if not kit then return end
local rem=kit:WaitForChild("Remotes");local event=rem:WaitForChild("HubGameUI");local request=rem:WaitForChild("GameRoomRequest");local push=rem:WaitForChild("GameRoomPush")
local function safeRules(name)local o=Rep:FindFirstChild(name);if not o then return nil end;local ok,r=pcall(require,o);return ok and r or nil end
local Chess=safeRules("07A0_CHESS_RULES");local Checkers=safeRules("07B0_CHECKERS_RULES")
for _,n in ipairs({"HubGameGui","GameClubGui"})do local x=pg:FindFirstChild(n);if x then x:Destroy()end end

local gui=Instance.new("ScreenGui");gui.Name="GameClubGui";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=120;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local C={bg=Color3.fromRGB(15,16,19),panel=Color3.fromRGB(25,27,32),card=Color3.fromRGB(37,40,47),soft=Color3.fromRGB(56,60,69),white=Color3.fromRGB(246,247,249),muted=Color3.fromRGB(172,177,186),green=Color3.fromRGB(75,200,120),blue=Color3.fromRGB(78,146,207),red=Color3.fromRGB(214,73,87),gold=Color3.fromRGB(228,183,78),purple=Color3.fromRGB(131,102,197),sq1=Color3.fromRGB(221,218,207),sq2=Color3.fromRGB(88,94,104),blackPiece=Color3.fromRGB(24,26,31)}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,th)local s=Instance.new("UIStroke");s.Color=col or Color3.fromRGB(82,87,98);s.Transparency=t or .55;s.Thickness=th or 1;s.Parent=o;return s end
local function text(p,s,pos,size,fs,col,font)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=s;t.TextColor3=col or C.white;t.Font=font or Enum.Font.GothamBold;t.TextSize=fs or 10;t.TextWrapped=true;t.Parent=p;return t end
local function btn(p,s,pos,size,col)local b=Instance.new("TextButton");b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.Text=s;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.TextWrapped=true;b.AutoButtonColor=true;b.Parent=p;round(b,9);stroke(b,nil,.72);return b end
local function call(action,arg)local ok,r=pcall(function()return request:InvokeServer(action,arg)end);if not ok then return nil,"Servidor indisponível."end;if not r or r.ok~=true then return nil,r and r.error or"Falha na sala."end;return r end
local hidden={};local function hideExternal(on)for _,n in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","ACP_PhotoMode","PlazaProgressGui","ACP_TitlesGui"})do local g=pg:FindFirstChild(n);if g then if on then if hidden[g]==nil then hidden[g]=g.Enabled end;g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end end end end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.16;shade.Visible=false;shade.Parent=gui
local toast=text(gui,"",UDim2.new(.5,-210,0,20),UDim2.fromOffset(420,48),10,C.white);toast.BackgroundTransparency=.08;toast.BackgroundColor3=C.panel;toast.Visible=false;toast.ZIndex=200;round(toast,11);stroke(toast,C.green,.48)
local toastToken=0;local function notify(msg,sec)toastToken=toastToken+1;local t=toastToken;toast.Text=tostring(msg or"");toast.Visible=true;task.delay(sec or 3,function()if t==toastToken then toast.Visible=false end end)end

-- GAME CLUB
local club=Instance.new("Frame");club.AnchorPoint=Vector2.new(.5,.5);club.Position=UDim2.fromScale(.5,.5);club.Size=UDim2.fromOffset(700,470);club.BackgroundColor3=C.bg;club.BorderSizePixel=0;club.Visible=false;club.Parent=gui;round(club,16);stroke(club,nil,.3,2)
local clubScale=Instance.new("UIScale");clubScale.Parent=club
text(club,"GAME CLUB",UDim2.fromOffset(20,14),UDim2.new(1,-90,0,30),18,C.white,Enum.Font.GothamBlack)
text(club,"Escolha o jogo e depois como quer jogar.",UDim2.fromOffset(20,43),UDim2.new(1,-90,0,18),8,C.muted)
local close=btn(club,"X",UDim2.new(1,-54,0,12),UDim2.fromOffset(40,34),C.soft)
local left=Instance.new("Frame");left.Position=UDim2.fromOffset(18,78);left.Size=UDim2.fromOffset(205,372);left.BackgroundColor3=C.panel;left.BorderSizePixel=0;left.Parent=club;round(left,12)
local right=Instance.new("Frame");right.Position=UDim2.fromOffset(235,78);right.Size=UDim2.new(1,-253,0,372);right.BackgroundColor3=C.panel;right.BorderSizePixel=0;right.Parent=club;round(right,12)
text(left,"JOGO",UDim2.fromOffset(12,9),UDim2.new(1,-24,0,20),8,C.muted)
local gameList=Instance.new("Frame");gameList.Position=UDim2.fromOffset(10,38);gameList.Size=UDim2.new(1,-20,0,190);gameList.BackgroundTransparency=1;gameList.Parent=left
local gl=Instance.new("UIListLayout");gl.Padding=UDim.new(0,9);gl.Parent=gameList
local selected="Xadrez";local gameBtns={}
for _,g in ipairs({"Xadrez","Damas","Batata"})do local label=g=="Batata"and"BATATA ENVENENADA"or string.upper(g);local b=btn(gameList,label,UDim2.new(),UDim2.new(1,0,0,52),g==selected and C.green or C.card);gameBtns[g]=b end
local roomStats=text(left,"ONLINE\nXadrez 0 • Dama 0 • Batata 0",UDim2.fromOffset(12,244),UDim2.new(1,-24,0,68),8,C.muted)
text(left,"Partidas online usam as salas ocultas; o mapa principal continua limpo.",UDim2.fromOffset(12,316),UDim2.new(1,-24,0,44),7,C.muted)

text(right,"MODO DE JOGO",UDim2.fromOffset(14,10),UDim2.new(1,-28,0,20),8,C.muted)
local quick=btn(right,"PARTIDA RÁPIDA ONLINE",UDim2.fromOffset(14,40),UDim2.new(1,-28,0,42),C.green)
local bot=btn(right,"TREINAR CONTRA BOT",UDim2.fromOffset(14,90),UDim2.new(1,-28,0,42),C.gold)
text(right,"BOT",UDim2.fromOffset(14,140),UDim2.fromOffset(45,18),7,C.muted)
local diff="MÉDIO";local diffBtns={}
for i,d in ipairs({"FÁCIL","MÉDIO","DIFÍCIL"})do local b=btn(right,d,UDim2.new((i-1)/3,14+(i-1)*2,0,163),UDim2.new(1/3,-14,0,34),d==diff and C.purple or C.card);diffBtns[d]=b end
text(right,"SALA PRIVADA",UDim2.fromOffset(14,210),UDim2.new(1,-28,0,18),7,C.muted)
local create=btn(right,"CRIAR SALA",UDim2.fromOffset(14,234),UDim2.new(.5,-21,0,38),C.blue)
local join=btn(right,"ENTRAR POR CÓDIGO",UDim2.new(.5,7,0,234),UDim2.new(.5,-21,0,38),C.purple)
local code=Instance.new("TextBox");code.Position=UDim2.fromOffset(14,280);code.Size=UDim2.new(1,-28,0,36);code.BackgroundColor3=C.card;code.BorderSizePixel=0;code.PlaceholderText="CÓDIGO DA SALA";code.PlaceholderColor3=C.muted;code.Text="";code.TextColor3=C.white;code.Font=Enum.Font.GothamBold;code.TextSize=10;code.ClearTextOnFocus=false;code.Parent=right;round(code,9);stroke(code,nil,.7)
local roomStatus=text(right,"",UDim2.fromOffset(14,322),UDim2.new(1,-28,0,22),8,C.white)
local cancel=btn(right,"CANCELAR ESPERA",UDim2.fromOffset(14,346),UDim2.new(1,-28,0,28),C.red);cancel.Visible=false
local function paintMenus()for g,b in pairs(gameBtns)do b.BackgroundColor3=g==selected and C.green or C.card end;for d,b in pairs(diffBtns)do b.BackgroundColor3=d==diff and C.purple or C.card end end
for g,b in pairs(gameBtns)do b.Activated:Connect(function()selected=g;roomStatus.Text="";paintMenus()end)end
for d,b in pairs(diffBtns)do b.Activated:Connect(function()diff=d;paintMenus()end)end
local function stats()local r=call("stats",{});if r and r.waiting then roomStats.Text=string.format("ONLINE\nXadrez %d • Dama %d • Batata %d",r.waiting.Xadrez or 0,r.waiting.Damas or 0,r.waiting.Batata or 0)end end
local function openClub()shade.Visible=true;club.Visible=true;hideExternal(true);cancel.Visible=false;roomStatus.Text="";stats()end
local function closeClub()if cancel.Visible then call("cancel",{})end;club.Visible=false;shade.Visible=false;hideExternal(false)end
close.Activated:Connect(closeClub)
quick.Activated:Connect(function()local r,e=call("quick",selected);if not r then roomStatus.Text=e;return end;roomStatus.Text=r.matched and"Adversário encontrado."or("Procurando jogador • código "..tostring(r.code));cancel.Visible=not r.matched end)
create.Activated:Connect(function()local r,e=call("create",selected);if not r then roomStatus.Text=e;return end;code.Text=tostring(r.code or"");roomStatus.Text="Sala pronta • envie o código ao amigo.";cancel.Visible=true end)
join.Activated:Connect(function()local r,e=call("join",code.Text);if not r then roomStatus.Text=e;return end;roomStatus.Text="Entrando na sala "..tostring(r.code);cancel.Visible=false end)
cancel.Activated:Connect(function()call("cancel",{});cancel.Visible=false;roomStatus.Text="Espera cancelada.";stats()end)
local openNonce=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;pg:GetAttributeChangedSignal("ACP_OpenGamesNonce"):Connect(function()local n=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;if n~=openNonce then openNonce=n;openClub()end end)

-- TABULEIRO 2D
local board=Instance.new("Frame");board.AnchorPoint=Vector2.new(.5,.5);board.Position=UDim2.fromScale(.5,.5);board.Size=UDim2.fromOffset(720,570);board.BackgroundColor3=C.bg;board.BorderSizePixel=0;board.Visible=false;board.Parent=gui;round(board,16);stroke(board,nil,.25,2)
local boardScale=Instance.new("UIScale");boardScale.Parent=board
local title=text(board,"XADREZ",UDim2.fromOffset(18,12),UDim2.new(1,-90,0,28),17,C.white,Enum.Font.GothamBlack)
local message=text(board,"",UDim2.fromOffset(18,42),UDim2.new(1,-36,0,24),9,C.muted)
local grid=Instance.new("Frame");grid.Position=UDim2.fromOffset(18,78);grid.Size=UDim2.fromOffset(464,464);grid.BackgroundColor3=C.panel;grid.BorderSizePixel=0;grid.Parent=board;stroke(grid,Color3.fromRGB(120,125,134),.25,2)
local side=Instance.new("Frame");side.Position=UDim2.fromOffset(500,78);side.Size=UDim2.fromOffset(202,464);side.BackgroundColor3=C.panel;side.BorderSizePixel=0;side.Parent=board;round(side,11)
local info=text(side,"",UDim2.fromOffset(12,12),UDim2.new(1,-24,0,50),9,C.white);local clock=text(side,"",UDim2.fromOffset(12,68),UDim2.new(1,-24,0,56),11,C.white,Enum.Font.GothamBlack)
local turnBadge=text(side,"SUA VEZ",UDim2.fromOffset(12,132),UDim2.new(1,-24,0,30),9,C.white);turnBadge.BackgroundTransparency=0;turnBadge.BackgroundColor3=C.green;round(turnBadge,8)
local claim=btn(side,"PEDIR EMPATE",UDim2.new(0,12,1,-138),UDim2.new(1,-24,0,34),C.card)
local resign=btn(side,"DESISTIR",UDim2.new(0,12,1,-96),UDim2.new(1,-24,0,34),C.red)
local minimize=btn(side,"MINIMIZAR",UDim2.new(0,12,1,-54),UDim2.new(1,-24,0,34),C.soft)
local mini=btn(gui,"VOLTAR À PARTIDA",UDim2.new(1,-194,1,-58),UDim2.fromOffset(176,40),C.blue);mini.Visible=false

local function rect(p,name,pos,size,col,r,z)local f=Instance.new("Frame");f.Name=name;f.Position=pos;f.Size=size;f.BackgroundColor3=col;f.BorderSizePixel=0;f.ZIndex=z or 3;f.Parent=p;if r then round(f,r)end;return f end
local function pieceIcon(cell,p,game)
 local old=cell:FindFirstChild("PieceIcon");if old then old:Destroy()end;if not p then return end
 local icon=Instance.new("Frame");icon.Name="PieceIcon";icon.AnchorPoint=Vector2.new(.5,.5);icon.Position=UDim2.fromScale(.5,.5);icon.Size=UDim2.fromScale(.72,.72);icon.BackgroundTransparency=1;icon.ZIndex=4;icon.Parent=cell
 local col=p.c=="W"and Color3.fromRGB(247,244,234)or C.blackPiece;local edge=p.c=="W"and Color3.fromRGB(66,69,75)or Color3.fromRGB(232,233,235)
 if game=="Damas"then local disc=rect(icon,"Disc",UDim2.fromScale(.12,.12),UDim2.fromScale(.76,.76),col,99,5);stroke(disc,edge,.18,2);rect(disc,"Inset",UDim2.fromScale(.20,.20),UDim2.fromScale(.60,.60),p.c=="W"and Color3.fromRGB(223,217,199)or Color3.fromRGB(52,55,61),99,6);if p.k then local k=text(disc,"K",UDim2.fromScale(0,0),UDim2.fromScale(1,1),13,edge,Enum.Font.GothamBlack);k.ZIndex=7 end;return end
 local t=tostring(p.t or"P")
 local base=rect(icon,"Base",UDim2.fromScale(.18,.75),UDim2.fromScale(.64,.15),col,4,5);stroke(base,edge,.35,1)
 if t=="P"then rect(icon,"Body",UDim2.fromScale(.38,.40),UDim2.fromScale(.24,.38),col,5,5);rect(icon,"Head",UDim2.fromScale(.34,.12),UDim2.fromScale(.32,.32),col,99,5)
 elseif t=="R"then rect(icon,"Body",UDim2.fromScale(.32,.34),UDim2.fromScale(.36,.42),col,3,5);local top=rect(icon,"Top",UDim2.fromScale(.23,.22),UDim2.fromScale(.54,.20),col,3,5);for i=0,2 do rect(top,"Tooth"..i,UDim2.fromScale(i*.38,0),UDim2.fromScale(.24,.42),col,1,6)end
 elseif t=="B"then rect(icon,"Body",UDim2.fromScale(.38,.40),UDim2.fromScale(.24,.36),col,5,5);local h=rect(icon,"Head",UDim2.fromScale(.35,.11),UDim2.fromScale(.30,.31),col,99,5);stroke(h,edge,.35,1)
 elseif t=="N"then rect(icon,"Body",UDim2.fromScale(.34,.39),UDim2.fromScale(.34,.38),col,5,5);rect(icon,"Neck",UDim2.fromScale(.30,.18),UDim2.fromScale(.40,.31),col,8,5);rect(icon,"Snout",UDim2.fromScale(.18,.29),UDim2.fromScale(.31,.16),col,6,5);rect(icon,"Ear",UDim2.fromScale(.53,.12),UDim2.fromScale(.12,.18),col,4,5)
 elseif t=="Q"then rect(icon,"Body",UDim2.fromScale(.38,.42),UDim2.fromScale(.24,.35),col,5,5);for i=0,2 do rect(icon,"Crown"..i,UDim2.fromScale(.20+i*.24,.10+(i%2)*.05),UDim2.fromScale(.18,.18),col,99,5)end
 elseif t=="K"then rect(icon,"Body",UDim2.fromScale(.38,.42),UDim2.fromScale(.24,.36),col,5,5);rect(icon,"CrossV",UDim2.fromScale(.46,.08),UDim2.fromScale(.10,.27),col,2,5);rect(icon,"CrossH",UDim2.fromScale(.36,.14),UDim2.fromScale(.30,.09),col,2,5)
 end
end

local cells={};for vr=1,8 do cells[vr]={};for vc=1,8 do local b=Instance.new("TextButton");b.Position=UDim2.fromOffset((vc-1)*58,(vr-1)*58);b.Size=UDim2.fromOffset(58,58);b.BorderSizePixel=0;b.Text="";b.AutoButtonColor=false;b.BackgroundColor3=(vr+vc)%2==0 and C.sq1 or C.sq2;b.Parent=grid;cells[vr][vc]=b;local co=text(b,"",UDim2.new(0,2,1,-12),UDim2.new(1,-4,0,10),6,Color3.fromRGB(135,140,148));co.Name="Coord";co.TextXAlignment=Enum.TextXAlignment.Right;co.ZIndex=8 end end
local potato=Instance.new("Frame");potato.Position=UDim2.fromOffset(18,88);potato.Size=UDim2.fromOffset(464,360);potato.BackgroundTransparency=1;potato.Visible=false;potato.Parent=board
local potatoBtns={};for i=1,10 do local r=math.floor((i-1)/5);local c=(i-1)%5;local b=btn(potato,"?",UDim2.fromOffset(c*90,r*150),UDim2.fromOffset(80,128),C.gold);b.TextSize=20;potatoBtns[i]=b end
local promo=Instance.new("Frame");promo.AnchorPoint=Vector2.new(.5,.5);promo.Position=UDim2.fromScale(.5,.5);promo.Size=UDim2.fromOffset(350,110);promo.BackgroundColor3=C.panel;promo.Visible=false;promo.ZIndex=180;promo.Parent=gui;round(promo,12);stroke(promo,nil,.35,2);text(promo,"PROMOVER PEÃO",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,24),11,C.white)
local current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};local botState=nil;local activeTable=nil;local potatoActive=false
for i,piece in ipairs({"Q","R","B","N"})do local b=btn(promo,piece,UDim2.fromOffset(13+(i-1)*83,46),UDim2.fromOffset(74,46),C.blue);b.Activated:Connect(function()promo.Visible=false;if current.tableName then event:FireServer("promotionChoice",current.tableName,piece)end end)end
local function key(r,c)return r..":"..c end
local function actual(vr,vc,sideName)if sideName=="B"then return 9-vr,9-vc end;return vr,vc end
local function fmt(v)v=math.max(0,math.floor(tonumber(v)or 0));return string.format("%d:%02d",math.floor(v/60),v%60)end
local function draw(state,game,viewSide,sel,hints)
 if not state or not state.board then return end
 for vr=1,8 do for vc=1,8 do local r,c=actual(vr,vc,viewSide);local cell=cells[vr][vc];local p=state.board[r]and state.board[r][c];local base=(vr+vc)%2==0 and C.sq1 or C.sq2;cell.BackgroundColor3=hints and hints[key(r,c)]and C.green or(sel and sel.r==r and sel.c==c and C.blue or base);pieceIcon(cell,p,game);local co=cell:FindFirstChild("Coord");if co then co.Text=(vr==8 or vc==1)and(string.char(96+c)..tostring(9-r))or"" end end end
end
local function redrawOnline()draw(current,current.game,current.side,current.selected,current.hints);info.Text="VOCÊ: "..(current.side=="W"and"CLARAS"or"ESCURAS");turnBadge.Text=current.turn==current.side and"SUA VEZ"or"AGUARDE";turnBadge.BackgroundColor3=current.turn==current.side and C.green or C.soft end

-- BOT local usa as regras do projeto quando as cópias em ReplicatedStorage existem.
local function allMoves(rules,state)local out={};for r=1,8 do for c=1,8 do local ok,moves=pcall(rules.Legal,state,r,c);if ok then for _,m in ipairs(moves or{})do table.insert(out,m)end end end end;return out end
local values={P=1,N=3,B=3,R=5,Q=9,K=40}
local function score(bs,m)local capture=bs.state.board[m.tr]and bs.state.board[m.tr][m.tc];local s=0;if bs.game=="Xadrez"then s=capture and(values[capture.t]or 1)*10 or 0;s=s+(4.5-math.abs(4.5-m.tc))+(4.5-math.abs(4.5-m.tr));if m.tr==8 or m.tr==1 then s=s+5 end else s=m.capture and 12 or 0;if m.tr==8 then s=s+5 end end;return s+math.random()*1.4 end
local function chooseBot(bs)local moves=allMoves(bs.rules,bs.state);if #moves==0 then return nil end;if bs.diff=="FÁCIL"then return moves[math.random(1,#moves)]end;table.sort(moves,function(a,b)return score(bs,a)>score(bs,b)end);if bs.diff=="MÉDIO"and #moves>2 then return moves[math.random(1,math.min(3,#moves))]end;return moves[1]end
local function botResult()if not botState or botState.game=="Batata"then return false end;local who,why=botState.rules.Result(botState.state);if not who then return false end;botState.finished=true;local msg=who=="draw"and("EMPATE • "..tostring(why or""))or who=="W"and"VOCÊ VENCEU"or"BOT VENCEU";message.Text=msg;notify(msg,5);return true end
local function redrawBot()if not botState then return end;grid.Visible=botState.game~="Batata";potato.Visible=botState.game=="Batata";claim.Visible=false;minimize.Visible=false;clock.Text="TREINO\n"..botState.diff;info.Text=botState.game=="Batata"and"Escolha com cuidado"or"VOCÊ: CLARAS\nBOT: ESCURAS";turnBadge.Text="TREINO";turnBadge.BackgroundColor3=C.gold;if botState.game~="Batata"then draw(botState.state,botState.game,"W",botState.selected,botState.hints)end end
local function botTurn()if not botState or botState.finished or botState.game=="Batata"or botResult()then return end;task.delay(.35,function()while botState and botState.state.turn=="B"do local m=chooseBot(botState);if not m then break end;botState.rules.Apply(botState.state,m,"Q");redrawBot();if botResult()then return end;task.wait(.18)end;if botState then message.Text="Sua vez."end end)end
local function startPotato()local poisons={};local n=diff=="FÁCIL"and 1 or diff=="MÉDIO"and 2 or 3;while n>0 do local i=math.random(1,10);if not poisons[i]then poisons[i]=true;n=n-1 end end;botState.poisons=poisons;botState.remaining={};for i=1,10 do botState.remaining[i]=true;potatoBtns[i].Text="?";potatoBtns[i].BackgroundColor3=C.gold end;message.Text="Sua vez • escolha uma batata.";redrawBot()end
local function botPotatoPick()if not botState then return end;local a={};for i=1,10 do if botState.remaining[i]then table.insert(a,i)end end;if #a==0 then message.Text="EMPATE";return end;local i=a[math.random(1,#a)];botState.remaining[i]=nil;potatoBtns[i].Text="BOT";potatoBtns[i].BackgroundColor3=C.soft;if botState.poisons[i]then botState.finished=true;message.Text="BOT PEGOU A ENVENENADA • VOCÊ VENCEU";notify(message.Text,5)else message.Text="Seguro • sua vez."end end
for i,b in ipairs(potatoBtns)do b.Activated:Connect(function()if not botState or botState.finished or botState.game~="Batata"or not botState.remaining[i]then return end;botState.remaining[i]=nil;b.Text="VOCÊ";b.BackgroundColor3=C.blue;if botState.poisons[i]then botState.finished=true;message.Text="ENVENENADA • BOT VENCEU";notify(message.Text,5);return end;message.Text="Seguro • BOT escolhendo...";task.delay(.45,botPotatoPick)end)end
local function startBot()
 if selected~="Batata"and not(selected=="Xadrez"and Chess or selected=="Damas"and Checkers)then notify("Instale as cópias das regras em ReplicatedStorage para usar BOT.",5);return end
 club.Visible=false;shade.Visible=true;board.Visible=true;hideExternal(true);resign.Text="SAIR DO TREINO";title.Text=string.upper(selected).." • BOT "..diff
 if selected=="Batata"then botState={game="Batata",diff=diff};startPotato();return end
 local rules=selected=="Xadrez"and Chess or Checkers;botState={game=selected,diff=diff,rules=rules,state=rules.New(),selected=nil,hints={}};message.Text="Sua vez.";redrawBot()
end
bot.Activated:Connect(startBot)
local function botTap(r,c)if not botState or botState.finished or botState.game=="Batata"or botState.state.turn~="W"then return end;local st=botState.state;local p=st.board[r]and st.board[r][c];if botState.selected and botState.hints[key(r,c)]then local moves=botState.rules.Legal(st,botState.selected.r,botState.selected.c);for _,m in ipairs(moves or{})do if m.tr==r and m.tc==c then botState.rules.Apply(st,m,"Q");break end end;botState.selected=nil;botState.hints={};redrawBot();if not botResult()then botTurn()end;return end;botState.selected=nil;botState.hints={};if p and p.c=="W"then botState.selected={r=r,c=c};for _,m in ipairs(botState.rules.Legal(st,r,c)or{})do botState.hints[key(m.tr,m.tc)]=true end end;redrawBot()end
for vr=1,8 do for vc=1,8 do cells[vr][vc].Activated:Connect(function()local sideName=botState and"W"or current.side;local r,c=actual(vr,vc,sideName);if botState then botTap(r,c)elseif current.game then event:FireServer("boardTap",current.tableName,r,c)end end)end end

local camera=workspace.CurrentCamera;local oldType,oldSubject=nil,nil
local function restoreCamera()if oldType then camera.CameraType=oldType;camera.CameraSubject=oldSubject;oldType=nil;oldSubject=nil end end
local function potatoCamera(tableName)local w=workspace:FindFirstChild("PracaAvatar_V2");local d=w and w:FindFirstChild("ChallengeDistrict");local z=d and d:FindFirstChild("Batata");local t=z and z:FindFirstChild(tostring(tableName));local tray=t and t:FindFirstChild("PotatoTray");if not tray then return end;oldType=camera.CameraType;oldSubject=camera.CameraSubject;camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(tray.Position+Vector3.new(0,10,11),tray.Position+Vector3.new(0,.4,0))end
local function endBot()botState=nil;potato.Visible=false;grid.Visible=true;board.Visible=false;shade.Visible=true;club.Visible=true;resign.Text="DESISTIR";minimize.Visible=true;hideExternal(true)end
claim.Activated:Connect(function()if not botState and current.game=="Xadrez"then event:FireServer("claimDraw",current.tableName)end end)
resign.Activated:Connect(function()if botState then endBot()elseif current.game then event:FireServer("resignGame",current.tableName)end end)
minimize.Activated:Connect(function()board.Visible=false;shade.Visible=false;mini.Visible=current.game~=nil end);mini.Activated:Connect(function()if current.game then shade.Visible=true;board.Visible=true;mini.Visible=false end end)
local function releaseRoom()restoreCamera();pcall(function()request:InvokeServer("leave")end);activeTable=nil;potatoActive=false;current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};board.Visible=false;mini.Visible=false;promo.Visible=false;shade.Visible=false;hideExternal(false)end
push.OnClientEvent:Connect(function(action,data)if action=="matched"then club.Visible=false;shade.Visible=false;cancel.Visible=false;activeTable=data and data.tableName;hideExternal(true);notify("Partida encontrada • "..tostring(data and data.game or"jogo"),2.5)elseif action=="roomClosed"then releaseRoom()end end)
event.OnClientEvent:Connect(function(action,data,b)
 if action=="notice"or action=="result"then message.Text=tostring(data or"");notify(data,b or(action=="result"and 6 or 3));return end
 if action=="boardOpen"and type(data)=="table"then current.game=data.game;current.tableName=data.tableName;current.side=data.side or"W";current.board=data.board;current.hints={};current.turn=data.turn or"W";title.Text=string.upper(tostring(data.game or"JOGO"));claim.Visible=current.game=="Xadrez";resign.Text="DESISTIR";minimize.Visible=true;grid.Visible=true;potato.Visible=false;shade.Visible=true;board.Visible=true;mini.Visible=false;hideExternal(true);redrawOnline()
 elseif action=="boardState"and type(data)=="table"and data.tableName==current.tableName then current.board=data.board or current.board;current.selected=data.selected;current.hints={};for _,m in ipairs(data.hints or{})do current.hints[key(m.r,m.c)]=true end;current.turn=data.turn or current.turn;message.Text=tostring(data.message or data.turnText or"");clock.Text="CLARAS "..fmt(data.whiteTime).."\nESCURAS "..fmt(data.blackTime);redrawOnline()
 elseif action=="promotion"then promo.Visible=true elseif action=="boardClose"and(type(data)~="table"or data.tableName==current.tableName)then releaseRoom()
 elseif action=="potatoOpen"and type(data)=="table"then activeTable=data.tableName;potatoActive=true;hideExternal(true);notify("Batata Envenenada iniciada.",3);task.defer(function()potatoCamera(activeTable)end)
 elseif action=="potatoState"and type(data)=="table"and data.tableName==activeTable then notify(tostring(data.message or"Escolha uma batata."),2)
 elseif action=="potatoClose"and(type(data)~="table"or data.tableName==activeTable)then releaseRoom()end
end)
local function bindChar(char)local hum=char:WaitForChild("Humanoid",10);if not hum then return end;hum.Seated:Connect(function(active,seat)if active and seat then local t=seat.Parent;if t and t:IsA("Model")and t:GetAttribute("GameType")and t:GetAttribute("ACP_RoomCode")then activeTable=t.Name;task.delay(.15,function()if seat.Occupant==hum then event:FireServer("readyGame",t.Name)end end)end end end)end
pl.CharacterAdded:Connect(bindChar);if pl.Character then task.defer(bindChar,pl.Character)end
local function adapt()local vp=workspace.CurrentCamera.ViewportSize;clubScale.Scale=math.min(1,(vp.X-24)/700,(vp.Y-24)/470);boardScale.Scale=math.min(1,(vp.X-24)/720,(vp.Y-24)/570)end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt);task.defer(adapt)
UIS.InputBegan:Connect(function(input,gp)if gp or not potatoActive then return end;if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end;local ray=camera:ViewportPointToRay(input.Position.X,input.Position.Y);local par=RaycastParams.new();par.FilterType=Enum.RaycastFilterType.Exclude;par.FilterDescendantsInstances={pl.Character};local hit=workspace:Raycast(ray.Origin,ray.Direction*500,par);local inst=hit and hit.Instance;if inst and inst:GetAttribute("ACPInputType")=="Potato"then event:FireServer("potatoTap",activeTable,inst:GetAttribute("ACPIndex"))end end)

print("AVATAR PLAZA V38: Game Club 2D premium carregado")
