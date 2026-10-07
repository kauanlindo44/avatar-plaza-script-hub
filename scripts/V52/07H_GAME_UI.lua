-- 07H_GAME_UI | LocalScript | StarterPlayer > StarterPlayerScripts
-- V46: controlador dos menus e partidas; regras e remotes existentes preservados.
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
 for _,name in ipairs({"LimitedMarketHUD","CreatorHUD_V2","HubAvatarLauncher","AvatarShop08Gui","AvatarShopLauncherGui","ACP_PhotoMode","PlazaProgressGui","ACP_TitlesGui"})do
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
local trucoRequest=rem:WaitForChild("TrucoRequest")
local function trucoCall(action,data)
 local ok,r=pcall(function()return trucoRequest:InvokeServer(action,data or{})end)
 return ok and r.ok and r.data or nil,ok and r.error or"Truco não respondeu."
end
local function roomCall(action,arg)
 if L.Selected~="Truco"then return call(action,arg)end
 return trucoCall(action=="cancel"and"leave"or action,{variant=L.Variant,manual=false,deck=L.Deck,team=L.Team,code=arg,difficulty=({FACIL="Fácil",MEDIO="Médio",DIFICIL="Difícil"})[L.Difficulty]})
end
local function stats()
 task.spawn(function()local res=call("stats",{});if res and res.waiting and L.Root.Visible then local t=trucoCall("rooms");res.waiting.Truco=t and t.Truco or 0;L.SetCounts(res.waiting)end end)
end
local function restoreCamera()if oldType then camera.CameraType=oldType;camera.CameraSubject=oldSubject;oldType=nil;oldSubject=nil end end
local function openClub()
 if pg:GetAttribute("ACP_TrucoActive")then return end
 if botState or current.game or potatoActive then B.Root.Visible=true;B.Mini.Visible=false;focus(true);return end
 if activeTable then notify("Sua partida está iniciando.");return end
 L.Root.Visible=true;focus(true);stats()
end
L.Close.Activated:Connect(function()
 if L.Busy then return end
 if L.WaitingState then local res,err=roomCall("cancel",{});if not res then L.SetStatus(err,true);return end;L.Reset()end
 L.Root.Visible=false;focus(false)
end)
local function roomAction(action,arg,quick)
 if L.Busy or L.WaitingState or current.game or botState or activeTable then return end
 L.SetBusy(true);L.SetStatus("Conectando à sala...")
 local res,err=roomCall(action,arg);L.SetBusy(false)
 if not res then L.SetStatus(err,true);return end
 if res.teleporting then L.SetTransfer(res.code);return end
 if res.matched then L.SetStatus("Adversário encontrado. Preparando a partida...")else L.SetWaiting(res.code,quick,res.crossServer,res.count);L.SetStatus(quick and"Fila ativa. Aguardando adversário."or"Sua sala está pronta.")end
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
 if L.Busy then return end;L.SetBusy(true);local res,err=roomCall("cancel",{});L.SetBusy(false)
 if not res then L.SetStatus(err,true);return end;L.Reset();L.SetStatus("Espera cancelada.");stats()
end)
L.Inventory.Activated:Connect(function()pg:SetAttribute("ACP_OpenInventoryNonce",(pg:GetAttribute("ACP_OpenInventoryNonce")or 0)+1)end)
L.Cups.Activated:Connect(function()pg:SetAttribute("ACP_OpenCupsNonce",(pg:GetAttribute("ACP_OpenCupsNonce")or 0)+1)end)
local function coins()L.Coins.Text="◉ "..tostring(pg:GetAttribute("ACP_GameCoins")or 0)end
pg:GetAttributeChangedSignal("ACP_GameCoins"):Connect(coins);coins()
pg:GetAttributeChangedSignal("ACP_CupNotifications"):Connect(function()local n=pg:GetAttribute("ACP_CupNotifications")or 0;L.Cups.Text=n>0 and("Convites ("..n..")")or"Convites"end)
pg:GetAttributeChangedSignal("ACP_TrucoWaitingCode"):Connect(function()local code=pg:GetAttribute("ACP_TrucoWaitingCode");if code then L.Selected="Truco";L.SetWaiting(code,false,true,pg:GetAttribute("ACP_TrucoWaitingCount"))else if L.Selected=="Truco"then L.Reset()end end end)
pg:GetAttributeChangedSignal("ACP_TrucoWaitingCount"):Connect(function()local code=pg:GetAttribute("ACP_TrucoWaitingCode");if code then L.SetWaiting(code,false,true,pg:GetAttribute("ACP_TrucoWaitingCount"))end end)
local Bot=require(Rep:WaitForChild("07H4_BOT_ENGINE"))
local function chooseBot(bs)
 return Bot.Choose(bs.rules,bs.state,bs.game,bs.diff,function()return botState==bs and not bs.finished end)
end
local function botResult()
 local bs=botState;if not bs then return false end
 local winner,reason=bs.rules.Result(bs.state);if not winner then return false end;bs.finished=true
 B.Message.Text=winner=="draw"and("Empate • "..tostring(reason or""))or winner=="W"and"Você venceu!"or"O bot venceu."
 B.Resign.Text="Voltar aos jogos";B.SetTurn("PARTIDA ENCERRADA",false);notify(B.Message.Text,5);return true
end
local function redrawBot()
 local bs=botState;if not bs then return end
 B.Grid.Visible=true;B.Potato.Visible=false;B.Claim.Visible=false;B.SetTraining(true,L.Difficulty)
 B.Info.Text="Você: claras  •  Bot: escuras"
 B.Resign.Text=bs.finished and"Voltar aos jogos"or"Sair da partida"
 if not bs.finished then if bs.revealing then B.SetTurn("MEMORIZE AS VERMELHAS",true);return end;local waiting=bs.waitingBot or(bs.state and bs.state.turn=="B");B.SetTurn(waiting and"BOT JOGANDO"or"SUA VEZ",not waiting)end
 if bs then B.Draw(bs.state,bs.game,"W",bs.selected,bs.hints)end
end
local function botTurn()
 local bs=botState;if not bs or bs.finished or botResult()then return end
 task.delay(.35,function()
  while botState==bs and not bs.finished and bs.state.turn=="B"do
   local move=chooseBot(bs);if botState~=bs or bs.finished then return end;if not move then botResult();break end
   bs.rules.Apply(bs.state,move,"Q");redrawBot();if botResult()then return end;task.wait(.18)
  end
  if botState==bs and not bs.finished then B.Message.Text="Sua vez.";redrawBot()end
 end)
end
L.Bot.Activated:Connect(function()
 if L.Busy or current.game or potatoActive or activeTable then return end
 if L.Selected=="Truco"then local d,e=roomCall("training");if not d then L.SetStatus(e,true)end;return end
 if L.WaitingState then local res,err=roomCall("cancel",{});if not res then L.SetStatus(err,true);return end;L.Reset()end
 local game=L.Selected;local rule=game=="Xadrez"and Chess or Checkers
 if not rule then L.SetStatus("As regras deste jogo ainda não estão disponíveis.",true);return end
 L.Root.Visible=false;B.Root.BackgroundTransparency=0;B.Root.Visible=true;B.Confirm.Visible=false;B.Title.Text=game.." • Contra bots";focus(true)
 botState={game=game,diff=L.Difficulty,rules=rule,state=rule.New(),hints={}}
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
 if bs.finished or bs.state.turn~="W"then return end
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
B.Mini.Activated:Connect(function()if botState or current.game or potatoActive then B.Root.Visible=true;B.Mini.Visible=false;focus(true) end end)
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
 end
end)
local nonce=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0
pg:GetAttributeChangedSignal("ACP_OpenGamesNonce"):Connect(function()local v=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0;if v~=nonce then nonce=v;openClub()end end)
local function bindChar(char)
 local hum=char:WaitForChild("Humanoid",10);if not hum then return end
 hum.Seated:Connect(function(on,seat)
  local t=on and seat and seat.Parent
  if t and t:IsA("Model")and(t:GetAttribute("GameType")=="Xadrez"or t:GetAttribute("GameType")=="Damas")and t:GetAttribute("ACP_RoomCode")then activeTable=t.Name;task.delay(.15,function()if seat.Occupant==hum then event:FireServer("readyGame",t.Name)end end)end
 end)
end
pl.CharacterAdded:Connect(bindChar);if pl.Character then task.defer(bindChar,pl.Character)end
task.defer(function()local res,err=call("arrival",{});if not res then notify(err)end end)
print("AVATAR PLAZA V44: jogos profissionais prontos")
