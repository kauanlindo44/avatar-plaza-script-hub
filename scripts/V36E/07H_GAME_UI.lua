-- 07H_GAME_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V36E - Game Club Studio Lite ligado ao botão JOGOS.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",30);if not kit then return end
local rem=kit:WaitForChild("Remotes")
local event=rem:WaitForChild("HubGameUI")
local request=rem:WaitForChild("GameRoomRequest")
local push=rem:WaitForChild("GameRoomPush")
for _,n in ipairs({"HubGameGui","GameClubGui"})do local x=pg:FindFirstChild(n);if x then x:Destroy()end end

local gui=Instance.new("ScreenGui");gui.Name="GameClubGui";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=120;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local C={bg=Color3.fromRGB(14,15,19),card=Color3.fromRGB(34,36,42),blue=Color3.fromRGB(72,142,201),purple=Color3.fromRGB(111,84,174),green=Color3.fromRGB(68,201,117),red=Color3.fromRGB(218,77,91),white=Color3.fromRGB(247,248,250),muted=Color3.fromRGB(173,176,184),light=Color3.fromRGB(222,224,226),dark=Color3.fromRGB(69,72,78)}
local function round(o,n)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,n or 10);c.Parent=o end
local function text(p,s,pos,size,fs,col)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=s;t.TextColor3=col or C.white;t.Font=Enum.Font.GothamBold;t.TextSize=fs or 11;t.TextWrapped=true;t.Parent=p;return t end
local function btn(p,s,pos,size,col)local b=Instance.new("TextButton");b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.Text=s;b.TextColor3=C.white;b.Font=Enum.Font.GothamBlack;b.TextSize=10;b.AutoButtonColor=false;b.Parent=p;round(b,9);return b end
local function call(action,a)local ok,r=pcall(function()return request:InvokeServer(action,a)end);if not ok then return nil,"Servidor indisponivel."end;if not r or r.ok~=true then return nil,r and r.error or"Falha."end;return r end
local notice=text(gui,"",UDim2.new(.5,-200,0,24),UDim2.fromOffset(400,46),11,C.white);notice.AnchorPoint=Vector2.new(0,0);notice.BackgroundTransparency=.12;notice.BackgroundColor3=C.bg;notice.Visible=false;notice.ZIndex=20;round(notice,10)
local noticeToken=0;local function showNotice(msg,secs)noticeToken=noticeToken+1;local mine=noticeToken;notice.Text=tostring(msg or"");notice.Visible=true;task.delay(secs or 3,function()if mine==noticeToken then notice.Visible=false end end)end
local hidden={}
local function hideExternal(on)
 for _,n in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","ACP_PhotoMode","PlazaProgressGui","ACP_TitlesGui"})do local x=pg:FindFirstChild(n);if x then if on then if hidden[x]==nil then hidden[x]=x.Enabled end;x.Enabled=false elseif hidden[x]~=nil then x.Enabled=hidden[x];hidden[x]=nil end end end
end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.2;shade.Visible=false;shade.Parent=gui
local club=Instance.new("Frame");club.AnchorPoint=Vector2.new(.5,.5);club.Position=UDim2.fromScale(.5,.5);club.Size=UDim2.fromOffset(560,370);club.BackgroundColor3=C.bg;club.BorderSizePixel=0;club.Visible=false;club.Parent=gui;round(club,14);local clubScale=Instance.new("UIScale");clubScale.Parent=club
text(club,"GAME CLUB",UDim2.fromOffset(18,12),UDim2.new(1,-80,0,28),17,C.white)
local close=btn(club,"X",UDim2.new(1,-52,0,9),UDim2.fromOffset(40,34),C.red)
local selected="Xadrez";local gameBtns={};local y=58
for _,g in ipairs({"Xadrez","Damas","Batata"})do local b=btn(club,string.upper(g=="Batata"and"BATATA ENVENENADA"or g),UDim2.fromOffset(18,y),UDim2.fromOffset(170,48),g==selected and C.green or C.card);gameBtns[g]=b;y=y+58 end
local desc=text(club,"Escolha um jogo. Partida rapida procura alguem neste servidor; sala por codigo e ideal para jogar com amigo.",UDim2.fromOffset(210,58),UDim2.new(1,-228,0,60),10,C.muted)
local quick=btn(club,"PARTIDA RAPIDA",UDim2.fromOffset(210,132),UDim2.new(1,-228,0,44),C.green)
local create=btn(club,"CRIAR SALA",UDim2.fromOffset(210,184),UDim2.new(.5,-118,0,44),C.blue)
local join=btn(club,"ENTRAR",UDim2.new(.5,100,0,184),UDim2.new(.5,-118,0,44),C.purple)
local codeBox=Instance.new("TextBox");codeBox.Position=UDim2.fromOffset(210,236);codeBox.Size=UDim2.new(1,-228,0,40);codeBox.BackgroundColor3=C.card;codeBox.BorderSizePixel=0;codeBox.PlaceholderText="CODIGO DA SALA";codeBox.Text="";codeBox.TextColor3=C.white;codeBox.PlaceholderColor3=C.muted;codeBox.Font=Enum.Font.GothamBold;codeBox.TextSize=12;codeBox.ClearTextOnFocus=false;codeBox.Parent=club;round(codeBox,9)
local roomStatus=text(club,"",UDim2.fromOffset(210,286),UDim2.new(1,-228,0,36),11,C.white)
local cancel=btn(club,"CANCELAR ESPERA",UDim2.fromOffset(210,326),UDim2.new(1,-228,0,32),C.red);cancel.Visible=false

local function paintGames()for g,b in pairs(gameBtns)do b.BackgroundColor3=g==selected and C.green or C.card end end
for g,b in pairs(gameBtns)do b.Activated:Connect(function()selected=g;paintGames();roomStatus.Text="" end)end;paintGames()
local function refreshStats()local r=call("stats");if r and r.waiting then desc.Text=string.format("Esperando agora neste servidor: Xadrez %d | Dama %d | Batata %d",r.waiting.Xadrez or 0,r.waiting.Damas or 0,r.waiting.Batata or 0)end end
local function openClub()shade.Visible=true;club.Visible=true;hideExternal(true);cancel.Visible=false;roomStatus.Text="";refreshStats()end
local function closeClub()if cancel.Visible then call("cancel")end;club.Visible=false;shade.Visible=false;hideExternal(false)end
close.Activated:Connect(closeClub)
quick.Activated:Connect(function()local r,e=call("quick",selected);if not r then roomStatus.Text=e;return end;roomStatus.Text=r.matched and"Adversario encontrado!"or("Procurando jogador... codigo "..r.code);cancel.Visible=not r.matched end)
create.Activated:Connect(function()local r,e=call("create",selected);if not r then roomStatus.Text=e;return end;codeBox.Text=r.code;roomStatus.Text="Sala criada: "..r.code.." | envie o codigo ao amigo";cancel.Visible=true end)
join.Activated:Connect(function()local r,e=call("join",codeBox.Text);if not r then roomStatus.Text=e;return end;roomStatus.Text="Entrando na sala "..r.code;cancel.Visible=false end)
cancel.Activated:Connect(function()call("cancel");cancel.Visible=false;roomStatus.Text="Espera cancelada.";refreshStats()end)
local oldNonce=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0
pg:GetAttributeChangedSignal("ACP_OpenGamesNonce"):Connect(function()local n=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;if n~=oldNonce then oldNonce=n;openClub()end end)

local board=Instance.new("Frame");board.AnchorPoint=Vector2.new(.5,.5);board.Position=UDim2.fromScale(.5,.5);board.Size=UDim2.fromOffset(610,510);board.BackgroundColor3=C.bg;board.BorderSizePixel=0;board.Visible=false;board.Parent=gui;round(board,14);local boardScale=Instance.new("UIScale");boardScale.Parent=board
local boardTitle=text(board,"",UDim2.fromOffset(18,12),UDim2.new(1,-100,0,28),16,C.white)
local message=text(board,"",UDim2.fromOffset(18,42),UDim2.new(1,-36,0,28),10,C.muted)
local grid=Instance.new("Frame");grid.Position=UDim2.fromOffset(18,78);grid.Size=UDim2.fromOffset(400,400);grid.BackgroundTransparency=1;grid.Parent=board
local cells={};for vr=1,8 do cells[vr]={};for vc=1,8 do local b=btn(grid,"",UDim2.fromOffset((vc-1)*50,(vr-1)*50),UDim2.fromOffset(50,50),(vr+vc)%2==0 and C.light or C.dark);b.TextSize=16;cells[vr][vc]=b end end
local side=text(board,"",UDim2.fromOffset(438,86),UDim2.fromOffset(154,55),10,C.white)
local clock=text(board,"",UDim2.fromOffset(438,146),UDim2.fromOffset(154,58),12,C.white)
local claim=btn(board,"PEDIR EMPATE",UDim2.fromOffset(438,225),UDim2.fromOffset(154,38),C.card)
local resign=btn(board,"DESISTIR",UDim2.fromOffset(438,272),UDim2.fromOffset(154,38),C.red)
local minimize=btn(board,"MINIMIZAR",UDim2.fromOffset(438,319),UDim2.fromOffset(154,38),C.card)
local mini=btn(gui,"VOLTAR AO JOGO",UDim2.new(1,-172,1,-58),UDim2.fromOffset(154,40),C.blue);mini.Visible=false
local promo=Instance.new("Frame");promo.AnchorPoint=Vector2.new(.5,.5);promo.Position=UDim2.fromScale(.5,.5);promo.Size=UDim2.fromOffset(320,100);promo.BackgroundColor3=C.card;promo.Visible=false;promo.Parent=gui;round(promo,12);text(promo,"PROMOVER PARA",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,24),12,C.white)

local current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};local activeTable=nil;local potatoActive=false
local camera=workspace.CurrentCamera;local oldCameraType=nil;local oldSubject=nil
local function restoreCamera()if oldCameraType then camera.CameraType=oldCameraType;camera.CameraSubject=oldSubject;oldCameraType=nil;oldSubject=nil end end
local function potatoCamera(tableName)
 local w=workspace:FindFirstChild("PracaAvatar_V2");local d=w and w:FindFirstChild("ChallengeDistrict");local z=d and d:FindFirstChild("Batata");local t=z and z:FindFirstChild(tostring(tableName));local tray=t and t:FindFirstChild("PotatoTray");if not tray then return end
 oldCameraType=camera.CameraType;oldSubject=camera.CameraSubject;camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(tray.Position+Vector3.new(0,10,11),tray.Position+Vector3.new(0,.4,0))
end
local function fmt(v)v=math.max(0,math.floor(tonumber(v)or 0));return string.format("%d:%02d",math.floor(v/60),v%60)end
local function viewToActual(vr,vc)if current.side=="B"then return 9-vr,9-vc end;return vr,vc end
local function key(r,c)return r..":"..c end
local function pieceText(p)
 if not p then return""end
 if current.game=="Damas"then return p.k and"K"or"O"end
 return tostring(p.t or"")
end
local function redraw()
 if not current.board then return end
 for vr=1,8 do for vc=1,8 do local r,c=viewToActual(vr,vc);local p=current.board[r]and current.board[r][c];local b=cells[vr][vc];b.Text=pieceText(p);b.TextColor3=p and p.c=="W"and Color3.fromRGB(250,250,250)or Color3.fromRGB(18,18,20);local base=(vr+vc)%2==0 and C.light or C.dark;b.BackgroundColor3=current.hints[key(r,c)]and C.green or(current.selected and current.selected.r==r and current.selected.c==c and C.blue or base)end end
 side.Text="Voce joga: "..(current.side=="W"and(current.game=="Xadrez"and"BRANCAS"or"CLARAS")or(current.game=="Xadrez"and"PRETAS"or"VERMELHAS"))
end
for vr=1,8 do for vc=1,8 do cells[vr][vc].Activated:Connect(function()if not current.game then return end;local r,c=viewToActual(vr,vc);event:FireServer("boardTap",current.tableName,r,c)end)end end
claim.Activated:Connect(function()if current.game=="Xadrez"then event:FireServer("claimDraw",current.tableName)end end)
resign.Activated:Connect(function()if current.game then event:FireServer("resignGame",current.tableName)end end)
minimize.Activated:Connect(function()board.Visible=false;shade.Visible=false;mini.Visible=current.game~=nil end)
mini.Activated:Connect(function()if current.game then shade.Visible=true;board.Visible=true;mini.Visible=false end end)
for i,piece in ipairs({"Q","R","B","N"})do local b=btn(promo,piece,UDim2.fromOffset(12+(i-1)*76,45),UDim2.fromOffset(66,42),C.blue);b.Activated:Connect(function()promo.Visible=false;event:FireServer("promotionChoice",current.tableName,piece)end)end

local function releaseRoom()restoreCamera();pcall(function()request:InvokeServer("leave")end);activeTable=nil;potatoActive=false;current={game=nil,tableName=nil,side="W",board=nil,selected=nil,hints={},turn="W"};board.Visible=false;mini.Visible=false;promo.Visible=false;shade.Visible=false;hideExternal(false)end
push.OnClientEvent:Connect(function(action,data)
 if action=="matched"then club.Visible=false;shade.Visible=false;cancel.Visible=false;activeTable=data and data.tableName;roomStatus.Text="";hideExternal(true);showNotice("Partida encontrada • "..tostring(data and data.game or"jogo"),2.5)
 elseif action=="roomClosed"then releaseRoom()end
end)

event.OnClientEvent:Connect(function(action,data,b)
 if action=="notice"or action=="result"then message.Text=tostring(data or"");showNotice(data,b or(action=="result"and 6 or 3));return end
 if action=="boardOpen"and type(data)=="table"then current.game=data.game;current.tableName=data.tableName;current.side=data.side or"W";current.board=data.board;current.hints={};boardTitle.Text=tostring(data.game or"JOGO");claim.Visible=current.game=="Xadrez";shade.Visible=true;board.Visible=true;mini.Visible=false;hideExternal(true);redraw()
 elseif action=="boardState"and type(data)=="table"and data.tableName==current.tableName then current.board=data.board or current.board;current.selected=data.selected;current.hints={};for _,m in ipairs(data.hints or{})do current.hints[key(m.r,m.c)]=true end;current.turn=data.turn or current.turn;message.Text=tostring(data.message or data.turnText or"");clock.Text="CLARAS "..fmt(data.whiteTime).."\nESCURAS "..fmt(data.blackTime);redraw()
 elseif action=="promotion"then promo.Visible=true
 elseif action=="boardClose"and(type(data)~="table"or data.tableName==current.tableName)then releaseRoom()
 elseif action=="potatoOpen"and type(data)=="table"then activeTable=data.tableName;potatoActive=true;hideExternal(true);message.Text="Batata Envenenada iniciada. Toque nas batatas.";showNotice(message.Text,4);task.defer(function() potatoCamera(activeTable) end)
 elseif action=="potatoState"and type(data)=="table"and data.tableName==activeTable then message.Text=tostring(data.message or"Escolha uma batata.");showNotice(message.Text,2)
 elseif action=="potatoClose"and(type(data)~="table"or data.tableName==activeTable)then releaseRoom()end
end)

local function bindChar(char)local hum=char:WaitForChild("Humanoid",10);if not hum then return end;hum.Seated:Connect(function(active,seat)if active and seat then local t=seat.Parent;if t and t:IsA("Model")and t:GetAttribute("GameType")and t:GetAttribute("ACP_RoomCode")then activeTable=t.Name;task.delay(.15,function()if seat.Occupant==hum then event:FireServer("readyGame",t.Name)end end)end end end)end
pl.CharacterAdded:Connect(bindChar);if pl.Character then local ch=pl.Character;task.defer(function() bindChar(ch) end)end

local function adapt()local vp=workspace.CurrentCamera.ViewportSize;clubScale.Scale=math.min(1,(vp.X-24)/560,(vp.Y-24)/370);boardScale.Scale=math.min(1,(vp.X-24)/610,(vp.Y-24)/510)end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt);task.defer(adapt)

UIS.InputBegan:Connect(function(input,gp)
 if gp or not potatoActive then return end
 if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
 local cam=workspace.CurrentCamera;local ray=cam:ViewportPointToRay(input.Position.X,input.Position.Y);local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={pl.Character}
 local hit=workspace:Raycast(ray.Origin,ray.Direction*500,params);local inst=hit and hit.Instance;if inst and inst:GetAttribute("ACPInputType")=="Potato"then event:FireServer("potatoTap",activeTable,inst:GetAttribute("ACPIndex"))end
end)

print("AVATAR PLAZA V36E: Game Club ligado ao HUD")
