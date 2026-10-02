-- 07H_GAME_UI | LocalScript | StarterPlayer > StarterPlayerScripts
-- V42: controlador dos menus e partidas; regras e remotes existentes preservados.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",30);if not kit then return end
local rem=kit:WaitForChild("Remotes")
local event=rem:WaitForChild("HubGameUI");local request=rem:WaitForChild("GameRoomRequest");local push=rem:WaitForChild("GameRoomPush")
local function rules(name)local o=Rep:FindFirstChild(name);if not o then return end;local ok,v=pcall(require,o);return ok and v or nil end
local Chess=rules("07A0_CHESS_RULES");local Checkers=rules("07B0_CHECKERS_RULES")
for _,name in ipairs({"HubGameGui","GameClubGui"})do local old=pg:FindFirstChild(name);if old then old:Destroy()end end
local gui=D.New("ScreenGui",{Name="GameClubGui",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,DisplayOrder=120,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local L=require(Rep:WaitForChild("07H1_GAME_LOBBY")).Build(gui)
local B=require(Rep:WaitForChild("07H2_GAME_BOARD")).Build(gui)
local current={game=nil,side="W",hints={}};local botState=nil;local activeTable=nil;local potatoActive=false
local hidden={};local camera=workspace.CurrentCamera;local oldType,oldSubject=nil,nil
local function focus(on)
 for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","ACP_PhotoMode","PlazaProgressGui","ACP_TitlesGui"})do
  local g=pg:FindFirstChild(name);if g then
   if on then if hidden[g]==nil then hidden[g]=g.Enabled end;g.Enabled=false
   elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end
  end
 end
end
local notice=D.Text(gui,"",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,12),Size=UDim2.fromOffset(420,50),BackgroundColor3=C.panel,BackgroundTransparency=0,Visible=false,ZIndex=200});D.Round(notice)
local noticeId=0
local function notify(msg,seconds)
 noticeId=noticeId+1;local id=noticeId;notice.Text=tostring(msg or"");notice.Size=UDim2.fromOffset(math.min(420,gui.AbsoluteSize.X-24),50)
 local ok,bar=pcall(function()return game:GetService("GuiService").TopbarInset end);notice.Position=UDim2.new(.5,0,0,ok and bar and bar.Max.Y+6 or 64);notice.Visible=true
 task.delay(seconds or 3,function()if id==noticeId then notice.Visible=false end end)
end
local function call(action,arg)
 local ok,res=pcall(function()return request:InvokeServer(action,arg)end)
 if not ok then return nil,"O servidor não respondeu. Tente novamente."end
 if not res or not res.ok then return nil,res and res.error or"Não foi possível concluir."end;return res
end
local function stats()
 task.spawn(function()local res=call("stats",{});if res and res.waiting and L.Root.Visible then L.SetCounts(res.waiting)end end)
end
local function restoreCamera()if oldType then camera.CameraType=oldType;camera.CameraSubject=oldSubject;oldType=nil;oldSubject=nil end end
local function potatoCamera(tableName)
 local w=workspace:FindFirstChild("PracaAvatar_V2");local district=w and w:FindFirstChild("ChallengeDistrict");local zone=district and district:FindFirstChild("Batata")
 local t=zone and zone:FindFirstChild(tostring(tableName));local tray=t and t:FindFirstChild("PotatoTray");if not tray then return end
 if not oldType then oldType=camera.CameraType;oldSubject=camera.CameraSubject end
 camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(tray.Position+Vector3.new(0,10,11),tray.Position+Vector3.new(0,.4,0))
end
local function openClub()
 if botState or current.game or potatoActive then B.Root.Visible=true;B.Mini.Visible=false;focus(true);if potatoActive then potatoCamera(activeTable)end;return end
 if activeTable then notify("Sua partida está iniciando.");return end
 L.Root.Visible=true;focus(true);stats()
end
L.Close.Activated:Connect(function()
 if L.Busy then return end
 if L.WaitingState then local res,err=call("cancel",{});if not res then L.SetStatus(err,true);return end;L.Reset()end
 L.Root.Visible=false;focus(false)
end)
local function roomAction(action,arg,quick)
 if L.Busy or L.WaitingState or current.game or botState or activeTable then return end
 L.SetBusy(true);L.SetStatus("Conectando à sala...")
 local res,err=call(action,arg);L.SetBusy(false)
 if not res then L.SetStatus(err,true);return end
 if res.teleporting then L.SetTransfer(res.code);return end
 if res.matched then L.SetStatus("Adversário encontrado. Preparando a partida...")else L.SetWaiting(res.code,quick,res.crossServer);L.SetStatus(quick and"Fila ativa. Aguardando adversário."or"Sua sala está pronta.")end
end
L.Quick.Activated:Connect(function()roomAction("quick",L.Selected,true)end)
L.Create.Activated:Connect(function()roomAction("create",L.Selected,false)end)
local function join()
 local code=string.upper(tostring(L.Code.Text or"")):gsub("%s+","")
 if #code~=4 or code:find("[^A-Z2-9]")then L.SetStatus("Digite um código de quatro letras ou números.",true);return end
 L.Code.Text=code;roomAction("join",code,false)
end
L.Join.Activated:Connect(join);L.Code.FocusLost:Connect(function(enter)if enter then join()end end)
L.Cancel.Activated:Connect(function()
 if L.Busy then return end;L.SetBusy(true);local res,err=call("cancel",{});L.SetBusy(false)
 if not res then L.SetStatus(err,true);return end;L.Reset();L.SetStatus("Espera cancelada.");stats()
end)
local function allMoves(rules,state)local out={};for r=1,8 do for c=1,8 do local ok,moves=pcall(rules.Legal,state,r,c);if ok then for _,m in ipairs(moves or{})do table.insert(out,m)end end end end;return out end
local values={P=1,N=3,B=3,R=5,Q=9,K=40}
local function score(bs,m)local capture=bs.state.board[m.tr]and bs.state.board[m.tr][m.tc];local s=0;if bs.game=="Xadrez"then s=capture and(values[capture.t]or 1)*10 or 0;s=s+(4.5-math.abs(4.5-m.tc))+(4.5-math.abs(4.5-m.tr));if m.tr==8 or m.tr==1 then s=s+5 end else s=m.capture and 12 or 0;
if m.tr==8 then s=s+5 end end;return s+math.random()*1.4 end
local function chooseBot(bs)
 local moves=allMoves(bs.rules,bs.state);if #moves==0 then return nil end
 if bs.diff=="FACIL"then return moves[math.random(1,#moves)]end
 -- Aleatoriedade so ocorre antes do sort: comparador estrito e estavel.
 local ranked={}
 for i,m in ipairs(moves)do ranked[i]={move=m,value=score(bs,m),index=i}end
 table.sort(ranked,function(a,b)
  if a.value~=b.value then return a.value>b.value end
  return a.index<b.index
 end)
 local pick=bs.diff=="MEDIO"and math.random(1,math.min(3,#ranked))or 1
 return ranked[pick].move
end
local function botResult()
 local bs=botState;if not bs or bs.game=="Batata"then return false end
 local winner,reason=bs.rules.Result(bs.state);if not winner then return false end;bs.finished=true
 B.Message.Text=winner=="draw"and("Empate • "..tostring(reason or""))or winner=="W"and"Você venceu!"or"O bot venceu."
 B.Resign.Text="Voltar aos jogos";B.SetTurn("PARTIDA ENCERRADA",false);notify(B.Message.Text,5);return true
end
local function redrawBot()
 local bs=botState;if not bs then return end
 B.Grid.Visible=bs.game~="Batata";B.Potato.Visible=bs.game=="Batata";B.Claim.Visible=false;B.SetTraining(true,L.Difficulty)
 B.Info.Text=bs.game=="Batata"and"Escolha uma batata por turno"or"Você: claras  •  Bot: escuras"
 B.Resign.Text=bs.finished and"Voltar aos jogos"or"Sair do treino"
 if not bs.finished then local waiting=bs.waitingBot or(bs.state and bs.state.turn=="B");B.SetTurn(waiting and"BOT JOGANDO"or"SUA VEZ",not waiting)end
 if bs.game~="Batata"then B.Draw(bs.state,bs.game,"W",bs.selected,bs.hints)end
end
local function botTurn()
 local bs=botState;if not bs or bs.finished or bs.game=="Batata"or botResult()then return end
 task.delay(.35,function()
  while botState==bs and not bs.finished and bs.state.turn=="B"do
   local move=chooseBot(bs);if not move then botResult();break end
   bs.rules.Apply(bs.state,move,"Q");redrawBot();if botResult()then return end;task.wait(.18)
  end
  if botState==bs and not bs.finished then B.Message.Text="Sua vez.";redrawBot()end
 end)
end
local function potatoPickBot(bs)
 if botState~=bs or bs.finished then return end
 local choices={};for i=1,10 do if bs.remaining[i]then table.insert(choices,i)end end
 if #choices==0 then bs.finished=true;B.Message.Text="Empate.";redrawBot();return end
 local i=choices[math.random(1,#choices)];bs.remaining[i]=nil;bs.waitingBot=false
 local b=B.PotatoButtons[i];b.Text="Bot";b.BackgroundColor3=C.soft
 if bs.poisons[i]then bs.finished=true;B.Message.Text="O bot encontrou a envenenada. Você venceu!";B.SetTurn("VOCÊ VENCEU",true)else B.Message.Text="A escolha do bot foi segura. Sua vez."end
 redrawBot()
end
for i,b in ipairs(B.PotatoButtons)do b.Activated:Connect(function()
 local bs=botState;if not bs or bs.game~="Batata"or bs.finished or bs.waitingBot or not bs.remaining[i]then return end
 bs.remaining[i]=nil;b.Text="Você";b.BackgroundColor3=C.blue
 if bs.poisons[i]then bs.finished=true;B.Message.Text="Você encontrou a envenenada. O bot venceu.";B.SetTurn("BOT VENCEU",false);redrawBot();return end
 bs.waitingBot=true;B.Message.Text="Escolha segura. O bot está escolhendo...";redrawBot();task.delay(.45,function()potatoPickBot(bs)end)
end)end
L.Bot.Activated:Connect(function()
 if L.Busy or current.game or potatoActive or activeTable then return end
 if L.WaitingState then local res,err=call("cancel",{});if not res then L.SetStatus(err,true);return end;L.Reset()end
 local game=L.Selected;local rule=game=="Xadrez"and Chess or Checkers
 if game~="Batata"and not rule then L.SetStatus("As regras deste jogo ainda não estão disponíveis.",true);return end
 L.Root.Visible=false;B.Root.BackgroundTransparency=0;B.Root.Visible=true;B.Confirm.Visible=false;B.Title.Text=game=="Batata"and"Batata Envenenada • Treino"or(game.." • Treino");focus(true)
 if game=="Batata"then
  local bs={game=game,diff=L.Difficulty,poisons={},remaining={}};botState=bs
  local n=L.Difficulty=="FACIL"and 1 or L.Difficulty=="MEDIO"and 2 or 3
  while n>0 do local i=math.random(1,10);if not bs.poisons[i]then bs.poisons[i]=true;n=n-1 end end
  for i,b in ipairs(B.PotatoButtons)do bs.remaining[i]=true;b.Text=tostring(i);b.BackgroundColor3=C.card end
 else botState={game=game,diff=L.Difficulty,rules=rule,state=rule.New(),hints={}}end
 B.Message.Text="Sua vez.";redrawBot()
end)
local function endBot()botState=nil;B.Root.Visible=false;B.Mini.Visible=false;B.Confirm.Visible=false;L.Root.Visible=true;L.Reset();stats();focus(true)end
local function redrawOnline()
 B.Draw(current,current.game,current.side,current.selected,current.hints);B.Info.Text=current.side=="W"and"Você joga com as claras"or"Você joga com as escuras"
 B.SetTurn(current.turn==current.side and"SUA VEZ"or"AGUARDE O ADVERSÁRIO",current.turn==current.side)
end
local function tap(row,col)
 local bs=botState
 if not bs then if current.game then event:FireServer("boardTap",current.tableName,row,col)end;return end
 if bs.finished or bs.game=="Batata"or bs.state.turn~="W"then return end
 local st=bs.state
 if bs.selected and bs.hints[row..":"..col]then
  for _,m in ipairs(bs.rules.Legal(st,bs.selected.r,bs.selected.c)or{})do if m.tr==row and m.tc==col then bs.rules.Apply(st,m,"Q");break end end
  bs.selected=nil;bs.hints={};redrawBot();if not botResult()then botTurn()end;return
 end
 bs.selected=nil;bs.hints={};local p=st.board[row]and st.board[row][col]
 if p and p.c=="W"then bs.selected={r=row,c=col};for _,m in ipairs(bs.rules.Legal(st,row,col)or{})do bs.hints[m.tr..":"..m.tc]=true end end;redrawBot()
end
for vr=1,8 do for vc=1,8 do B.Cells[vr][vc].Activated:Connect(function()local row,col=vr,vc;if not botState and current.side=="B"then row,col=9-vr,9-vc end;tap(row,col)end)end end
for piece,b in pairs(B.PromotionButtons)do b.Activated:Connect(function()B.Promotion.Visible=false;if current.tableName then event:FireServer("promotionChoice",current.tableName,piece)end end)end
local function releaseRoom()
 restoreCamera();activeTable=nil;potatoActive=false;current={game=nil,side="W",hints={}};B.Root.Visible=false;B.Mini.Visible=false;B.Promotion.Visible=false;B.Confirm.Visible=false
 B.Root.BackgroundTransparency=0;L.Reset();focus(L.Root.Visible)
end
B.Claim.Activated:Connect(function()if not botState and current.game=="Xadrez"then event:FireServer("claimDraw",current.tableName)end end)
B.Resign.Activated:Connect(function()
 if botState then endBot();return end
 B.ConfirmTitle.Text=potatoActive and"Sair desta sala?"or"Desistir da partida?";B.ConfirmYes.Text=potatoActive and"Sair da sala"or"Desistir";B.ConfirmDescription.Text=potatoActive and"A sala será encerrada para os dois jogadores."or"Seu adversário vence esta partida.";B.Confirm.Visible=true
end)
B.ConfirmNo.Activated:Connect(function()B.Confirm.Visible=false end)
B.ConfirmYes.Activated:Connect(function()
 B.Confirm.Visible=false
 if potatoActive then local res,err=call("leave",{});if res then releaseRoom()else notify(err)end
 elseif current.game then event:FireServer("resignGame",current.tableName)end
end)
B.Minimize.Activated:Connect(function()B.Root.Visible=false;B.Mini.Visible=true;if potatoActive then restoreCamera()end;focus(false)end)
B.Mini.Activated:Connect(function()if botState or current.game or potatoActive then B.Root.Visible=true;B.Mini.Visible=false;focus(true);if potatoActive then potatoCamera(activeTable)end end end)
push.OnClientEvent:Connect(function(action,data)
 if action=="matched"then L.Root.Visible=false;L.Reset();activeTable=data and data.tableName;focus(true);notify("Adversário encontrado. Preparando "..tostring(data and data.game or"a partida").."...")
 elseif action=="roomClosed"then releaseRoom()
 elseif action=="travelFailed"then L.Reset();L.Root.Visible=true;focus(true);L.SetStatus(data and data.error or"Viagem indisponível.",true)end
end)
event.OnClientEvent:Connect(function(action,data,seconds)
 if action=="notice"or action=="result"then B.Message.Text=tostring(data or"");notify(data,seconds or(action=="result"and 6 or 3));return end
 if action=="boardOpen"and type(data)=="table"then
  botState=nil;current={game=data.game,tableName=data.tableName,side=data.side or"W",board=data.board,turn=data.turn or"W",hints={}}
  B.Root.Visible=true;B.Root.BackgroundTransparency=0;B.Mini.Visible=false;B.Potato.Visible=false;B.Grid.Visible=true;B.Claim.Visible=data.game=="Xadrez";B.Resign.Text="Desistir"
  B.Title.Text=tostring(data.game or"Partida");B.WhiteClock.Text="—";B.BlackClock.Text="—";B.SetTraining(false);focus(true);redrawOnline()
 elseif action=="boardState"and type(data)=="table"and data.tableName==current.tableName then
  current.board=data.board or current.board;current.turn=data.turn or current.turn;current.selected=data.selected;current.hints={}
  for _,m in ipairs(data.hints or{})do current.hints[m.r..":"..m.c]=true end
  B.Message.Text=tostring(data.message or data.turnText or"");B.SetTimes(data.whiteTime,data.blackTime);redrawOnline()
 elseif action=="promotion"then B.Promotion.Visible=true
 elseif action=="boardClose"and(type(data)~="table"or data.tableName==current.tableName)then releaseRoom()
 elseif action=="potatoOpen"and type(data)=="table"then
  activeTable=data.tableName;potatoActive=true;botState=nil;B.Title.Text="Batata Envenenada";B.Info.Text="Partida com outro jogador";B.Message.Text="Toque em uma batata na mesa."
  B.Root.Visible=true;B.Root.BackgroundTransparency=1;B.Grid.Visible=false;B.Potato.Visible=false;B.Claim.Visible=false;B.Resign.Text="Sair da sala";B.SetTraining(false);B.ClockRow.Visible=false;B.SetTurn("PARTIDA EM ANDAMENTO",false);focus(true)
  task.defer(function()potatoCamera(activeTable)end)
 elseif action=="potatoState"and type(data)=="table"and data.tableName==activeTable then B.Message.Text=tostring(data.message or"Escolha uma batata.")
 elseif action=="potatoClose"and(type(data)~="table"or data.tableName==activeTable)then releaseRoom()end
end)
local nonce=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0
pg:GetAttributeChangedSignal("ACP_OpenGamesNonce"):Connect(function()local v=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;if v~=nonce then nonce=v;openClub()end end)
local function bindChar(char)
 local hum=char:WaitForChild("Humanoid",10);if not hum then return end
 hum.Seated:Connect(function(on,seat)
  local t=on and seat and seat.Parent
  if t and t:IsA("Model")and t:GetAttribute("GameType")and t:GetAttribute("ACP_RoomCode")then activeTable=t.Name;task.delay(.15,function()if seat.Occupant==hum then event:FireServer("readyGame",t.Name)end end)end
 end)
end
pl.CharacterAdded:Connect(bindChar);if pl.Character then task.defer(bindChar,pl.Character)end
UIS.InputBegan:Connect(function(input,gp)
 if gp or not potatoActive or not B.Root.Visible then return end
 if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
 local ray=camera:ViewportPointToRay(input.Position.X,input.Position.Y);local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={pl.Character}
 local hit=workspace:Raycast(ray.Origin,ray.Direction*500,params);local part=hit and hit.Instance
 if part and part:GetAttribute("ACPInputType")=="Potato"then event:FireServer("potatoTap",activeTable,part:GetAttribute("ACPIndex"))end
end)
task.defer(function()local res,err=call("arrival",{});if not res then notify(err)end end)
print("AVATAR PLAZA V42: jogos profissionais prontos")
