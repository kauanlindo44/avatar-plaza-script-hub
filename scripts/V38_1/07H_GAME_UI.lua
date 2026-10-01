-- 07H_GAME_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V38 - Game Club 2D premium.
-- Xadrez e Damas usam peças 2D desenhadas com UI; Batata mantém modo online e treino local.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",30);if not kit then return end
local rem=kit:WaitForChild("Remotes");local event=rem:WaitForChild("HubGameUI");local request=rem:WaitForChild("GameRoomRequest");local push=rem:WaitForChild("GameRoomPush")
local function safeRules(name)local o=Rep:FindFirstChild(name);if not o then return nil end;local ok,r=pcall(require,o);return ok and r or nil end
local Chess=safeRules("07A0_CHESS_RULES");local Checkers=safeRules("07B0_CHECKERS_RULES")
for _,n in ipairs({"HubGameGui","GameClubGui"})do local x=pg:FindFirstChild(n);if x then x:Destroy()end end

local gui=Instance.new("ScreenGui"); gui.Name="GameClubGui"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=120;
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=pg
local C={bg=Color3.fromRGB(15,16,19),panel=Color3.fromRGB(25,27,32),card=Color3.fromRGB(37,40,47),soft=Color3.fromRGB(56,60,69),white=Color3.fromRGB(246,247,249),
muted=Color3.fromRGB(172,177,186),green=Color3.fromRGB(75,200,120),blue=Color3.fromRGB(78,146,207),red=Color3.fromRGB(214,73,87),gold=Color3.fromRGB(228,183,
78),purple=Color3.fromRGB(131,102,197),sq1=Color3.fromRGB(221,218,207),sq2=Color3.fromRGB(88,94,104),blackPiece=Color3.fromRGB(24,26,31)}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,th)local s=Instance.new("UIStroke");s.Color=col or Color3.fromRGB(82,87,98);s.Transparency=t or .55;s.Thickness=th or 1;s.Parent=o;return s end
local function text(p,s,pos,size,fs,col,font)local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Position=pos; t.Size=size; t.Text=s; t.TextColor3=col or C.white;
t.Font=font or Enum.Font.GothamBold; t.TextSize=fs or 10; t.TextWrapped=true; t.Parent=p; return t end
local function btn(p,s,pos,size,col)local b=Instance.new("TextButton"); b.Position=pos; b.Size=size; b.BackgroundColor3=col or C.card; b.BorderSizePixel=0; b.Text=s;
b.TextColor3=C.white; b.Font=Enum.Font.GothamBold; b.TextSize=9; b.TextWrapped=true; b.AutoButtonColor=true; b.Parent=p; round(b,9); stroke(b,nil,.72); return b end
local function call(action,arg)local ok,r=pcall(function()return request:InvokeServer(action,arg)end); if not ok then return nil,"Servidor indisponível."end;
if not r or r.ok~=true then return nil,r and r.error or"Falha na sala."end; return r end
local hidden={};
local function hideExternal(on)for _,n in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","ACP_PhotoMode","PlazaProgressGui",
"ACP_TitlesGui"})do local g=pg:FindFirstChild(n);
if g then if on then if hidden[g]==nil then hidden[g]=g.Enabled end; g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g]; hidden[g]=nil end end end end

local shade=Instance.new("Frame"); shade.Size=UDim2.fromScale(1,1); shade.BackgroundColor3=Color3.new(0,0,0); shade.BackgroundTransparency=.16; shade.Visible=false;
shade.Parent=gui
local toast=text(gui,"",UDim2.new(.5,-210,0,20),UDim2.fromOffset(420,48),10,C.white); toast.BackgroundTransparency=.08; toast.BackgroundColor3=C.panel; toast.Visible=false;
toast.ZIndex=200; round(toast,11); stroke(toast,C.green,.48)
local toastToken=0; local function notify(msg,sec)toastToken=toastToken+1; local t=toastToken; toast.Text=tostring(msg or""); toast.Visible=true;
task.delay(sec or 3,function()if t==toastToken then toast.Visible=false end end)end

-- GAME CLUB FULLSCREEN
local club=Instance.new("Frame"); club.AnchorPoint=Vector2.new(.5,.5); club.Position=UDim2.fromScale(.5,.5); club.Size=UDim2.fromOffset(920,520); club.BackgroundColor3=C.bg;
club.BorderSizePixel=0; club.Visible=false; club.Parent=gui; round(club,16); stroke(club,nil,.3,2)
local clubScale=Instance.new("UIScale");clubScale.Parent=club
text(club,"GAME CLUB",UDim2.fromOffset(22,14),UDim2.new(1,-90,0,30),18,C.white,Enum.Font.GothamBlack)
text(club,"Partidas 2D, sala privada e treino contra bot.",UDim2.fromOffset(22,43),UDim2.new(1,-100,0,18),8,C.muted)
local close=btn(club,"X",UDim2.new(1,-54,0,12),UDim2.fromOffset(40,34),C.soft)
local tabs=Instance.new("Frame");tabs.Position=UDim2.fromOffset(22,78);tabs.Size=UDim2.new(1,-44,0,48);tabs.BackgroundTransparency=1;tabs.Parent=club
local tabsLayout=Instance.new("UIGridLayout"); tabsLayout.CellSize=UDim2.new(1/3,-8,1,0); tabsLayout.CellPadding=UDim2.fromOffset(12,0); tabsLayout.FillDirectionMaxCells=3;
tabsLayout.Parent=tabs
local selected="Xadrez";local gameBtns={}
for _,g in ipairs({"Xadrez","Damas","Batata"})do local label=g=="Batata"and"BATATA ENVENENADA"or string.upper(g);
local b=btn(tabs,label,UDim2.new(),UDim2.new(1,0,1,0),g==selected and C.green or C.card); gameBtns[g]=b end
local hero=Instance.new("Frame"); hero.Position=UDim2.fromOffset(22,142); hero.Size=UDim2.fromOffset(394,350); hero.BackgroundColor3=C.panel; hero.BorderSizePixel=0;
hero.Parent=club; round(hero,12); stroke(hero,nil,.62)
local heroTitle=text(hero,"XADREZ",UDim2.fromOffset(18,16),UDim2.new(1,-36,0,27),15,C.white,Enum.Font.GothamBlack)
local heroDesc=text(hero,"Tabuleiro 2D claro e competitivo.",UDim2.fromOffset(18,46),UDim2.new(1,-36,0,36),8,C.muted)
local preview=Instance.new("Frame"); preview.Position=UDim2.fromOffset(18,96); preview.Size=UDim2.new(1,-36,0,190); preview.BackgroundColor3=Color3.fromRGB(20,27,28);
preview.BorderSizePixel=0; preview.Parent=hero; round(preview,10)
for r=1,6 do for c=1,6 do local sq=Instance.new("Frame"); sq.Position=UDim2.new((c-1)/6,0,(r-1)/6,0); sq.Size=UDim2.new(1/6,1,1/6,1);
sq.BackgroundColor3=(r+c)%2==0 and C.sq1 or C.sq2; sq.BorderSizePixel=0; sq.Parent=preview end end
local roomStats=text(hero,"ONLINE carregando...",UDim2.fromOffset(18,300),UDim2.new(1,-36,0,32),8,C.muted)
local modes=Instance.new("Frame"); modes.Position=UDim2.fromOffset(432,142); modes.Size=UDim2.new(1,-454,0,350); modes.BackgroundColor3=C.panel; modes.BorderSizePixel=0;
modes.Parent=club; round(modes,12); stroke(modes,nil,.62)
text(modes,"COMO QUER JOGAR?",UDim2.fromOffset(16,12),UDim2.new(1,-32,0,24),10,C.white,Enum.Font.GothamBlack)
local quick=btn(modes,"PARTIDA RAPIDA ONLINE",UDim2.fromOffset(16,48),UDim2.new(1,-32,0,42),C.green)
text(modes,"SALA PRIVADA",UDim2.fromOffset(16,102),UDim2.new(1,-32,0,18),7,C.muted)
local create=btn(modes,"CRIAR SALA",UDim2.fromOffset(16,126),UDim2.fromOffset(128,38),C.blue)
local code=Instance.new("TextBox"); code.Position=UDim2.fromOffset(152,126); code.Size=UDim2.new(1,-288,0,38); code.BackgroundColor3=C.card; code.BorderSizePixel=0;
code.PlaceholderText="CODIGO"; code.PlaceholderColor3=C.muted; code.Text=""; code.TextColor3=C.white; code.Font=Enum.Font.GothamBold; code.TextSize=10;
code.ClearTextOnFocus=false; code.Parent=modes; round(code,9); stroke(code,nil,.7)
local join=btn(modes,"ENTRAR",UDim2.new(1,-128,0,126),UDim2.fromOffset(112,38),C.purple)
text(modes,"TREINO CONTRA BOT",UDim2.fromOffset(16,178),UDim2.new(1,-32,0,18),7,C.muted)
local diff="MEDIO";local diffBtns={}
for i,d in ipairs({"FACIL","MEDIO","DIFICIL"})do local b=btn(modes,d,UDim2.new((i-1)/3,16+(i-1)*2,0,204),UDim2.new(1/3,-14,0,34),d==diff and C.gold or C.card);
diffBtns[d]=b end
local bot=btn(modes,"JOGAR CONTRA BOT",UDim2.fromOffset(16,248),UDim2.new(1,-32,0,40),C.gold)
local roomStatus=text(modes,"",UDim2.fromOffset(16,298),UDim2.new(1,-32,0,20),8,C.white)
local cancel=btn(modes,"CANCELAR ESPERA",UDim2.fromOffset(16,320),UDim2.new(1,-32,0,24),C.red);cancel.Visible=false
local descriptions={Xadrez="Tabuleiro 2D claro e competitivo.",Damas="Damas 2D com jogadas destacadas.",Batata="Batata Envenenada em interface 2D."}
local function paintMenus()for g,b in pairs(gameBtns)do b.BackgroundColor3=g==selected and C.green or C.card end;
for d,b in pairs(diffBtns)do b.BackgroundColor3=d==diff and C.gold or C.card end; heroTitle.Text=selected=="Batata"and"BATATA ENVENENADA"or string.upper(selected);
heroDesc.Text=descriptions[selected]end
for g,b in pairs(gameBtns)do b.Activated:Connect(function()selected=g;roomStatus.Text="";paintMenus()end)end
for d,b in pairs(diffBtns)do b.Activated:Connect(function()diff=d;paintMenus()end)end
local function stats()local r=call("stats",{});
if r and r.waiting then roomStats.Text=string.format("ONLINE  Xadrez %d  |  Damas %d  |  Batata %d",r.waiting.Xadrez or 0,r.waiting.Damas or 0,r.waiting.Batata or 0)end end
local function openClub()shade.Visible=true;club.Visible=true;hideExternal(true);cancel.Visible=false;roomStatus.Text="";stats();paintMenus()end
local function closeClub()if cancel.Visible then call("cancel",{})end;club.Visible=false;shade.Visible=false;hideExternal(false)end
close.Activated:Connect(closeClub)
quick.Activated:Connect(function()local r,e=call("quick",selected); if not r then roomStatus.Text=e; return end;
roomStatus.Text=r.matched and"Adversario encontrado."or("Aguardando jogador - codigo "..tostring(r.code)); cancel.Visible=not r.matched end)
create.Activated:Connect(function()local r,e=call("create",selected); if not r then roomStatus.Text=e; return end; code.Text=tostring(r.code or"");
roomStatus.Text="Sala criada. Envie o codigo ao amigo."; cancel.Visible=true end)
join.Activated:Connect(function()local r,e=call("join",code.Text); if not r then roomStatus.Text=e; return end; roomStatus.Text="Entrando na sala "..tostring(r.code);
cancel.Visible=false end)
cancel.Activated:Connect(function()call("cancel",{});cancel.Visible=false;roomStatus.Text="Espera cancelada.";stats()end)
local openNonce=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;
pg:GetAttributeChangedSignal("ACP_OpenGamesNonce"):Connect(function()local n=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0; if n~=openNonce then openNonce=n;
openClub()end end)

-- TABULEIRO 2D
local board=Instance.new("Frame"); board.AnchorPoint=Vector2.new(.5,.5); board.Position=UDim2.fromScale(.5,.5); board.Size=UDim2.fromOffset(920,520);
board.BackgroundColor3=C.bg; board.BorderSizePixel=0; board.Visible=false; board.Parent=gui; round(board,16); stroke(board,nil,.25,2)
local boardScale=Instance.new("UIScale");boardScale.Parent=board
local title=text(board,"XADREZ",UDim2.fromOffset(18,12),UDim2.new(1,-90,0,28),17,C.white,Enum.Font.GothamBlack)
local message=text(board,"",UDim2.fromOffset(18,42),UDim2.new(1,-36,0,24),9,C.muted)
local grid=Instance.new("Frame"); grid.Position=UDim2.fromOffset(22,82); grid.Size=UDim2.fromOffset(416,416); grid.BackgroundColor3=C.panel; grid.BorderSizePixel=0;
grid.Parent=board; stroke(grid,Color3.fromRGB(120,125,134),.25,2)
local side=Instance.new("Frame"); side.Position=UDim2.fromOffset(458,82); side.Size=UDim2.fromOffset(440,416); side.BackgroundColor3=C.panel; side.BorderSizePixel=0;
side.Parent=board; round(side,11)
local info=text(side,"",UDim2.fromOffset(12,12),UDim2.new(1,-24,0,50),9,C.white);
local clock=text(side,"",UDim2.fromOffset(12,68),UDim2.new(1,-24,0,56),11,C.white,Enum.Font.GothamBlack)
local turnBadge=text(side,"SUA VEZ",UDim2.fromOffset(12,132),UDim2.new(1,-24,0,30),9,C.white); turnBadge.BackgroundTransparency=0; turnBadge.BackgroundColor3=C.green;
round(turnBadge,8)
local claim=btn(side,"PEDIR EMPATE",UDim2.new(0,12,1,-138),UDim2.new(1,-24,0,34),C.card)
local resign=btn(side,"DESISTIR",UDim2.new(0,12,1,-96),UDim2.new(1,-24,0,34),C.red)
local minimize=btn(side,"MINIMIZAR",UDim2.new(0,12,1,-54),UDim2.new(1,-24,0,34),C.soft)
local mini=btn(gui,"VOLTAR À PARTIDA",UDim2.new(1,-194,1,-58),UDim2.fromOffset(176,40),C.blue);mini.Visible=false

local function rect(p,name,pos,size,col,r,z)local f=Instance.new("Frame"); f.Name=name; f.Position=pos; f.Size=size; f.BackgroundColor3=col; f.BorderSizePixel=0;
f.ZIndex=z or 3; f.Parent=p; if r then round(f,r)end; return f end
local function pieceIcon(cell,p,game)
 local old=cell:FindFirstChild("PieceIcon");if old then old:Destroy()end;if not p then return end
 local icon=Instance.new("Frame"); icon.Name="PieceIcon"; icon.AnchorPoint=Vector2.new(.5,.5); icon.Position=UDim2.fromScale(.5,.5); icon.Size=UDim2.fromScale(.72,.72);
 icon.BackgroundTransparency=1; icon.ZIndex=4; icon.Parent=cell
 local col=p.c=="W"and Color3.fromRGB(247,244,234)or C.blackPiece;local edge=p.c=="W"and Color3.fromRGB(66,69,75)or Color3.fromRGB(232,233,235)
 if game=="Damas"then local disc=rect(icon,"Disc",UDim2.fromScale(.12,.12),UDim2.fromScale(.76,.76),col,99,5); stroke(disc,edge,.18,2);
 rect(disc,"Inset",UDim2.fromScale(.20,.20),UDim2.fromScale(.60,.60),p.c=="W"and Color3.fromRGB(223,217,199)or Color3.fromRGB(52,55,61),99,6);
 if p.k then local k=text(disc,"K",UDim2.fromScale(0,0),UDim2.fromScale(1,1),13,edge,Enum.Font.GothamBlack); k.ZIndex=7 end; return end
 local t=tostring(p.t or"P")
 local base=rect(icon,"Base",UDim2.fromScale(.18,.75),UDim2.fromScale(.64,.15),col,4,5);stroke(base,edge,.35,1)
 if t=="P"then rect(icon,"Body",UDim2.fromScale(.38,.40),UDim2.fromScale(.24,.38),col,5,5);rect(icon,"Head",UDim2.fromScale(.34,.12),UDim2.fromScale(.32,.32),col,99,5)
 elseif t=="R"then rect(icon,"Body",UDim2.fromScale(.32,.34),UDim2.fromScale(.36,.42),col,3,5);
 local top=rect(icon,"Top",UDim2.fromScale(.23,.22),UDim2.fromScale(.54,.20),col,3,5);
 for i=0,2 do rect(top,"Tooth"..i,UDim2.fromScale(i*.38,0),UDim2.fromScale(.24,.42),col,1,6)end
 elseif t=="B"then rect(icon,"Body",UDim2.fromScale(.38,.40),UDim2.fromScale(.24,.36),col,5,5);
 local h=rect(icon,"Head",UDim2.fromScale(.35,.11),UDim2.fromScale(.30,.31),col,99,5); stroke(h,edge,.35,1)
 elseif t=="N"then rect(icon,"Body",UDim2.fromScale(.34,.39),UDim2.fromScale(.34,.38),col,5,5); rect(icon,"Neck",UDim2.fromScale(.30,.18),UDim2.fromScale(.40,.31),col,8,5);
 rect(icon,"Snout",UDim2.fromScale(.18,.29),UDim2.fromScale(.31,.16),col,6,5); rect(icon,"Ear",UDim2.fromScale(.53,.12),UDim2.fromScale(.12,.18),col,4,5)
 elseif t=="Q"then rect(icon,"Body",UDim2.fromScale(.38,.42),UDim2.fromScale(.24,.35),col,5,5);
 for i=0,2 do rect(icon,"Crown"..i,UDim2.fromScale(.20+i*.24,.10+(i%2)*.05),UDim2.fromScale(.18,.18),col,99,5)end
 elseif t=="K"then rect(icon,"Body",UDim2.fromScale(.38,.42),UDim2.fromScale(.24,.36),col,5,5); rect(icon,"CrossV",UDim2.fromScale(.46,.08),UDim2.fromScale(.10,.27),col,2,5);
 rect(icon,"CrossH",UDim2.fromScale(.36,.14),UDim2.fromScale(.30,.09),col,2,5)
 end
end

local cells={}; for vr=1,8 do cells[vr]={}; for vc=1,8 do local b=Instance.new("TextButton"); b.Position=UDim2.fromOffset((vc-1)*52,(vr-1)*52); b.Size=UDim2.fromOffset(52,52);
b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false; b.BackgroundColor3=(vr+vc)%2==0 and C.sq1 or C.sq2; b.Parent=grid; cells[vr][vc]=b;
local co=text(b,"",UDim2.new(0,2,1,-12),UDim2.new(1,-4,0,10),6,Color3.fromRGB(135,140,148)); co.Name="Coord"; co.TextXAlignment=Enum.TextXAlignment.Right; co.ZIndex=8 end end
local potato=Instance.new("Frame"); potato.Position=UDim2.fromOffset(22,104); potato.Size=UDim2.fromOffset(416,300); potato.BackgroundTransparency=1; potato.Visible=false;
potato.Parent=board
local potatoBtns={}; for i=1,10 do local r=math.floor((i-1)/5); local c=(i-1)%5; local b=btn(potato,"?",UDim2.fromOffset(c*81,r*146),UDim2.fromOffset(73,132),C.gold);
b.TextSize=20; potatoBtns[i]=b end
local promo=Instance.new("Frame"); promo.AnchorPoint=Vector2.new(.5,.5); promo.Position=UDim2.fromScale(.5,.5); promo.Size=UDim2.fromOffset(350,110);
promo.BackgroundColor3=C.panel; promo.Visible=false; promo.ZIndex=180; promo.Parent=gui; round(promo,12); stroke(promo,nil,.35,2);
text(promo,"PROMOVER PEÃO",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,24),11,C.white)
local current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};local botState=nil;local activeTable=nil;local potatoActive=false
for i,piece in ipairs({"Q","R","B","N"})do local b=btn(promo,piece,UDim2.fromOffset(13+(i-1)*83,46),UDim2.fromOffset(74,46),C.blue);
b.Activated:Connect(function()promo.Visible=false; if current.tableName then event:FireServer("promotionChoice",current.tableName,piece)end end)end
local function key(r,c)return r..":"..c end
local function actual(vr,vc,sideName)if sideName=="B"then return 9-vr,9-vc end;return vr,vc end
local function fmt(v)v=math.max(0,math.floor(tonumber(v)or 0));return string.format("%d:%02d",math.floor(v/60),v%60)end
local function draw(state,game,viewSide,sel,hints)
 if not state or not state.board then return end
 for vr=1,8 do for vc=1,8 do local r,c=actual(vr,vc,viewSide); local cell=cells[vr][vc]; local p=state.board[r]and state.board[r][c];
 local base=(vr+vc)%2==0 and C.sq1 or C.sq2; cell.BackgroundColor3=hints and hints[key(r,c)]and C.green or(sel and sel.r==r and sel.c==c and C.blue or base);
 pieceIcon(cell,p,game); local co=cell:FindFirstChild("Coord"); if co then co.Text=(vr==8 or vc==1)and(string.char(96+c)..tostring(9-r))or"" end end end
end
local function redrawOnline()draw(current,current.game,current.side,current.selected,current.hints); info.Text="VOCÊ: "..(current.side=="W"and"CLARAS"or"ESCURAS");
turnBadge.Text=current.turn==current.side and"SUA VEZ"or"AGUARDE"; turnBadge.BackgroundColor3=current.turn==current.side and C.green or C.soft end

-- BOT local usa as regras do projeto quando as cópias em ReplicatedStorage existem.
local function allMoves(rules,state)local out={}; for r=1,8 do for c=1,8 do local ok,moves=pcall(rules.Legal,state,r,c);
if ok then for _,m in ipairs(moves or{})do table.insert(out,m)end end end end; return out end
local values={P=1,N=3,B=3,R=5,Q=9,K=40}
local function score(bs,m)local capture=bs.state.board[m.tr]and bs.state.board[m.tr][m.tc]; local s=0; if bs.game=="Xadrez"then s=capture and(values[capture.t]or 1)*10 or 0;
s=s+(4.5-math.abs(4.5-m.tc))+(4.5-math.abs(4.5-m.tr)); if m.tr==8 or m.tr==1 then s=s+5 end else s=m.capture and 12 or 0; if m.tr==8 then s=s+5 end end;
return s+math.random()*1.4 end
local function chooseBot(bs)local moves=allMoves(bs.rules,bs.state); if #moves==0 then return nil end; if bs.diff=="FACIL"then return moves[math.random(1,#moves)]end;
table.sort(moves,function(a,b)return score(bs,a)>score(bs,b)end); if bs.diff=="MEDIO"and #moves>2 then return moves[math.random(1,math.min(3,#moves))]end; return moves[1]end
local function botResult()if not botState or botState.game=="Batata"then return false end; local who,why=botState.rules.Result(botState.state);
if not who then return false end; botState.finished=true; local msg=who=="draw"and("EMPATE • "..tostring(why or""))or who=="W"and"VOCÊ VENCEU"or"BOT VENCEU"; message.Text=msg;
notify(msg,5); return true end
local function redrawBot()if not botState then return end; grid.Visible=botState.game~="Batata"; potato.Visible=botState.game=="Batata"; claim.Visible=false;
minimize.Visible=false; clock.Text="TREINO\n"..botState.diff; info.Text=botState.game=="Batata"and"Escolha com cuidado"or"VOCÊ: CLARAS\nBOT: ESCURAS"; turnBadge.Text="TREINO";
turnBadge.BackgroundColor3=C.gold; if botState.game~="Batata"then draw(botState.state,botState.game,"W",botState.selected,botState.hints)end end
local function botTurn()if not botState or botState.finished or botState.game=="Batata"or botResult()then return end;
task.delay(.35,function()while botState and botState.state.turn=="B"do local m=chooseBot(botState); if not m then break end; botState.rules.Apply(botState.state,m,"Q");
redrawBot(); if botResult()then return end; task.wait(.18)end; if botState then message.Text="Sua vez."end end)end
local function startPotato()local poisons={}; local n=diff=="FACIL"and 1 or diff=="MEDIO"and 2 or 3; while n>0 do local i=math.random(1,10);
if not poisons[i]then poisons[i]=true; n=n-1 end end; botState.poisons=poisons; botState.remaining={}; for i=1,10 do botState.remaining[i]=true; potatoBtns[i].Text="?";
potatoBtns[i].BackgroundColor3=C.gold end; message.Text="Sua vez • escolha uma batata."; redrawBot()end
local function botPotatoPick()if not botState then return end; local a={}; for i=1,10 do if botState.remaining[i]then table.insert(a,i)end end;
if #a==0 then message.Text="EMPATE"; return end; local i=a[math.random(1,#a)]; botState.remaining[i]=nil; potatoBtns[i].Text="BOT"; potatoBtns[i].BackgroundColor3=C.soft;
if botState.poisons[i]then botState.finished=true; message.Text="BOT PEGOU A ENVENENADA • VOCÊ VENCEU"; notify(message.Text,5)else message.Text="Seguro • sua vez."end end
for i,b in ipairs(potatoBtns)do b.Activated:Connect(function()if not botState or botState.finished or botState.game~="Batata"or not botState.remaining[i]then return end;
botState.remaining[i]=nil; b.Text="VOCÊ"; b.BackgroundColor3=C.blue; if botState.poisons[i]then botState.finished=true; message.Text="ENVENENADA • BOT VENCEU";
notify(message.Text,5); return end; message.Text="Seguro • BOT escolhendo..."; task.delay(.45,botPotatoPick)end)end
local function startBot()
 if selected~="Batata"and not(selected=="Xadrez"and Chess or selected=="Damas"and Checkers)then notify("Instale as cópias das regras em ReplicatedStorage para usar BOT.",5);
 return end
 club.Visible=false;shade.Visible=true;board.Visible=true;hideExternal(true);resign.Text="SAIR DO TREINO";title.Text=string.upper(selected).." • BOT "..diff
 if selected=="Batata"then botState={game="Batata",diff=diff};startPotato();return end
 local rules=selected=="Xadrez"and Chess or Checkers;botState={game=selected,diff=diff,rules=rules,state=rules.New(),selected=nil,hints={}};message.Text="Sua vez.";redrawBot()
end
bot.Activated:Connect(startBot)
local function botTap(r,c)if not botState or botState.finished or botState.game=="Batata"or botState.state.turn~="W"then return end; local st=botState.state;
local p=st.board[r]and st.board[r][c]; if botState.selected and botState.hints[key(r,c)]then local moves=botState.rules.Legal(st,botState.selected.r,botState.selected.c);
for _,m in ipairs(moves or{})do if m.tr==r and m.tc==c then botState.rules.Apply(st,m,"Q"); break end end; botState.selected=nil; botState.hints={}; redrawBot();
if not botResult()then botTurn()end; return end; botState.selected=nil; botState.hints={}; if p and p.c=="W"then botState.selected={r=r,c=c};
for _,m in ipairs(botState.rules.Legal(st,r,c)or{})do botState.hints[key(m.tr,m.tc)]=true end end; redrawBot()end
for vr=1,8 do for vc=1,8 do cells[vr][vc].Activated:Connect(function()local sideName=botState and"W"or current.side; local r,c=actual(vr,vc,sideName);
if botState then botTap(r,c)elseif current.game then event:FireServer("boardTap",current.tableName,r,c)end end)end end

local function endBot()botState=nil; potato.Visible=false; grid.Visible=true; board.Visible=false; shade.Visible=true; club.Visible=true; resign.Text="DESISTIR";
minimize.Visible=true; hideExternal(true)end
claim.Activated:Connect(function()if not botState and current.game=="Xadrez"then event:FireServer("claimDraw",current.tableName)end end)
resign.Activated:Connect(function()if botState then endBot()elseif current.game then event:FireServer("resignGame",current.tableName)end end)
minimize.Activated:Connect(function()board.Visible=false; shade.Visible=false; mini.Visible=current.game~=nil end);
mini.Activated:Connect(function()if current.game then shade.Visible=true; board.Visible=true; mini.Visible=false end end)
local function releaseRoom()pcall(function()request:InvokeServer("leave")end); activeTable=nil; potatoActive=false;
current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"}; board.Visible=false; mini.Visible=false; promo.Visible=false; shade.Visible=false;
hideExternal(false)end
push.OnClientEvent:Connect(function(action,data)if action=="matched"then club.Visible=false; shade.Visible=false; cancel.Visible=false; activeTable=data and data.tableName;
hideExternal(true); notify("Partida encontrada • "..tostring(data and data.game or"jogo"),2.5)elseif action=="roomClosed"then releaseRoom()end end)
event.OnClientEvent:Connect(function(action,data,b)
 if action=="notice"or action=="result"then message.Text=tostring(data or"");notify(data,b or(action=="result"and 6 or 3));return end
 if action=="boardOpen"and type(data)=="table"then current.game=data.game; current.tableName=data.tableName; current.side=data.side or"W"; current.board=data.board;
 current.hints={}; current.turn=data.turn or"W"; title.Text=string.upper(tostring(data.game or"JOGO")); claim.Visible=current.game=="Xadrez"; resign.Text="DESISTIR";
 minimize.Visible=true; grid.Visible=true; potato.Visible=false; shade.Visible=true; board.Visible=true; mini.Visible=false; hideExternal(true); redrawOnline()
 elseif action=="boardState"and type(data)=="table"and data.tableName==current.tableName then current.board=data.board or current.board; current.selected=data.selected;
 current.hints={}; for _,m in ipairs(data.hints or{})do current.hints[key(m.r,m.c)]=true end; current.turn=data.turn or current.turn;
 message.Text=tostring(data.message or data.turnText or""); clock.Text="CLARAS "..fmt(data.whiteTime).."\nESCURAS "..fmt(data.blackTime); redrawOnline()
 elseif action=="promotion"then promo.Visible=true elseif action=="boardClose"and(type(data)~="table"or data.tableName==current.tableName)then releaseRoom()
 elseif action=="potatoOpen"and type(data)=="table"then activeTable=data.tableName; potatoActive=true; hideExternal(true); title.Text="BATATA ENVENENADA"; grid.Visible=false;
 potato.Visible=true; shade.Visible=true; board.Visible=true; club.Visible=false; for _,pb in ipairs(potatoBtns)do pb.Text="?"; pb.BackgroundColor3=C.gold end;
 notify("Batata Envenenada 2D iniciada.",3)
 elseif action=="potatoState"and type(data)=="table"and data.tableName==activeTable then message.Text=tostring(data.message or"Escolha uma batata.");
 turnBadge.Text=data.isTurn and"SUA VEZ"or"AGUARDE"; turnBadge.BackgroundColor3=data.isTurn and C.green or C.soft; notify(message.Text,2)
 elseif action=="potatoClose"and(type(data)~="table"or data.tableName==activeTable)then releaseRoom()end
end)
local function bindChar(char)local hum=char:WaitForChild("Humanoid",10); if not hum then return end;
hum.Seated:Connect(function(active,seat)if active and seat then local t=seat.Parent;
if t and t:IsA("Model")and t:GetAttribute("GameType")and t:GetAttribute("ACP_RoomCode")then activeTable=t.Name;
task.delay(.15,function()if seat.Occupant==hum then event:FireServer("readyGame",t.Name)end end)end end end)end
pl.CharacterAdded:Connect(bindChar);if pl.Character then task.defer(bindChar,pl.Character)end
local function adapt()local vp=workspace.CurrentCamera.ViewportSize; clubScale.Scale=math.min(1.28,(vp.X-20)/920,(vp.Y-20)/520);
boardScale.Scale=math.min(1.28,(vp.X-20)/920,(vp.Y-20)/520)end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt);task.defer(adapt)


print("AVATAR PLAZA V38.1: Game Club fullscreen 2D carregado")
