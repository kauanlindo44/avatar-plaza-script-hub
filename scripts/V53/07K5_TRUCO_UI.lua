-- 07K5_TRUCO_UI | ModuleScript | ReplicatedStorage | V53 (SUBSTITUIR)
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local R=require(Rep:WaitForChild("07K0_TRUCO_RULES"))
local Table=require(Rep:WaitForChild("07K15_TRUCO_TABLE"))
local U={}
function U.Build(gui,action)
 local V={};local state;local safe=Bounds.Bind(gui)
 V.Root=D.New("Frame",{Name="TrucoMatch",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(10,17,14),BackgroundTransparency=0,Visible=false},gui)
 V.Title=D.Text(V.Root,"Truco",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=.12,BackgroundColor3=C.panel})
 V.Close=D.IconButton(V.Root,"LeaveTruco","close","Sair da mesa",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 V.Score=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.08,TextSize=18,Font=Enum.Font.GothamBold,ZIndex=5})
 V.Status=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.12,TextSize=14,ZIndex=5})
 V.Hand=D.New("Frame",{Name="PrivateHand",BackgroundTransparency=1,ZIndex=8},V.Root)
 local tableView=Table.Build(V.Root);V.TableArea=tableView.Root;V.TableCards=tableView.Cards;V.HandCards={}
 V.CardChoices=D.New("Frame",{Name="ChooseAnyCard",BackgroundTransparency=1,ZIndex=10},V.Root);V.CardButtons={}
 local function playOwned(i)
  if not state or V.Dialog.Visible or state.phase~="play"or state.turn~=state.seat or not state.hand[i]then return end
  action("play",i,V.Covered==true)
 end
 V.PlayOwned=playOwned
 for i=1,3 do local b=D.Button(V.CardChoices,"",{Name="ChooseCard"..i,TextSize=13,ZIndex=12});V.CardButtons[i]=b
  b.Activated:Connect(function()playOwned(i)end)
 end
 V.Controls=D.New("Frame",{Name="TurnControls",BackgroundTransparency=1,ZIndex=10},V.Root)
 V.Raise=D.Button(V.Controls,"Truco",{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=12})
 V.Cover=D.Button(V.Controls,"Carta aberta",{ZIndex=12});V.Run=D.Button(V.Controls,"Correr",{TextColor3=C.red,ZIndex=12})
 V.Shouts=D.Button(V.Controls,"Gritos",{ZIndex=12})
 V.Dialog=D.Frame(V.Root,{Name="TableDecision",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.45),BackgroundColor3=C.panel,Visible=false,ZIndex=20})
 V.Message=D.Text(V.Dialog,"",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,48),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=21})
 V.Options=D.New("Frame",{Position=UDim2.fromOffset(10,62),Size=UDim2.new(1,-20,1,-72),BackgroundTransparency=1,ZIndex=21},V.Dialog)
 local covered=false;local options={};local shouts=false
 local function clear(p)for _,o in ipairs(p:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end end
 local function option(label,fn,color)
  local b=D.Button(V.Options,label,{BackgroundColor3=color or C.card,ZIndex=22});b.Activated:Connect(fn);table.insert(options,b)
 end
 function V.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local top=safe.Heading(V.Title,V.Close);local bar=safe.Topbar();local useBar=aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48
  if useBar then top=it+4 end;local ah=h-ib-top-8
  local titleW=math.min(184,aw*.31);Bounds.Rect(V.Title,il+8,it+4,titleW,48);V.Title.TextSize=aw<480 and 14 or 18;V.Title.TextWrapped=false
  Bounds.Rect(V.Score,il+titleW+12,it+4,aw-titleW-76,48);V.Score.TextSize=aw<480 and 12 or 18
  if useBar then local width=bar.Right-bar.X;Bounds.Rect(V.Title,bar.X+4,bar.Y+4,164,44);Bounds.Rect(V.Score,bar.X+176,bar.Y+4,width-236,44);V.Score.TextSize=width<580 and 13 or 16;Bounds.Rect(V.Close,bar.Right-52,bar.Y+4,48,48)end
  local wide=aw>=520;local statusH=ah<280 and 0 or 26;V.Status.Visible=statusH>0
  local controlsY=h-ib-52;local available=controlsY-top-statusH-8
  local handH=math.max(64,math.min(144,available*.28));local tableH=math.max(70,available-handH-8)
  Bounds.Rect(V.Status,il+8,top,aw-16,22);V.Status.TextSize=aw<480 and 11 or 13
  Bounds.Rect(V.TableArea,il+8,top+statusH,aw-16,tableH)
  local handY=controlsY-handH-4;local hw=math.min(aw-16,math.max(220,handH*2.2));local hx=il+(aw-hw)/2
  local cardW=math.min((hw-18)/3,handH*.70);local cardH=cardW/.70;local total=cardW*3+12
  Bounds.Rect(V.Hand,hx,handY,hw,cardH);V.CardChoices.Visible=false
  for i,c in ipairs(V.HandCards)do Bounds.Rect(c,(hw-total)/2+(i-1)*(cardW+6),0,cardW,cardH);c.Rotation=(i-2)*3 end
  Bounds.Rect(V.Controls,il+8,controlsY,aw-16,44)
  for i,b in ipairs({V.Raise,V.Cover,V.Run,V.Shouts})do Bounds.Rect(b,(i-1)*(aw-10)/4,0,(aw-34)/4,44);b.TextSize=aw<480 and 11 or 13 end
  local pw=math.min(540,aw-16);local ph=math.min(226,h-it-ib-16);Bounds.Rect(V.Dialog,il+(aw-pw)/2,it+(h-it-ib-ph)/2,pw,ph)
  local cols=#options>3 and 2 or math.max(1,#options);local cw=(pw-20-(cols-1)*6)/cols
  for i,b in ipairs(options)do Bounds.Rect(b,(i-1)%cols*(cw+6),math.floor((i-1)/cols)*48,cw,44)end
  tableView.Layout()
 end
 function V.Update(v,inventory)
  state=v;V.ReceivedAt=os.clock();V.DecisionActive=false;V.Inventory=inventory;shouts=false;V.Root.Visible=true;V.Dialog.Visible=false;clear(V.Options);options={};clear(V.Hand);V.HandCards={};tableView.Update(v,inventory)
  V.Shouts.Text=v.manual and v.phase=="play"and #v.tricks==0 and #v.tableCards==0 and R.Team(v.seat)~=R.Team(v.dealer)and"Conferir"or"Como jogar"
  local team=R.Team(v.seat);V.Title.Text="Truco · "..v.variant
  V.Score.Text="SUA DUPLA  "..v.score[team].." : "..v.score[3-team].."  RIVAIS"
  V.Status.Text=v.phase=="play"and(v.turn==v.seat and"Sua vez · toque em qualquer uma das três cartas"or"Vez de "..v.players[v.turn].name)or"Acompanhe a mesa"
  for i,b in ipairs(V.CardButtons)do local c=v.hand[i];b.Visible=c~=nil;b.Text=c and(c.hidden and"Carta "..i or i.." · "..c.rank..(({S="♠",H="♥",D="♦",C="♣"})[c.suit]or""))or"";D.SetEnabled(b,c~=nil and v.phase=="play"and v.turn==v.seat)end
  local style=inventory and inventory.equipped or"Classic";local custom=inventory and inventory.custom
  if inventory and inventory.view=="classic"then style="Classic"end
  V.Hand.Visible=true
  for i,c in ipairs(v.hand)do
   local frame=Cards.Render(V.Hand,c,style,{Name="OwnedCard"..i,ZIndex=8},custom);V.HandCards[i]=frame
   local hit=D.Button(frame,"",{Name="PlayCard",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=18})
   hit.AutoButtonColor=false;D.SetEnabled(hit,v.phase=="play"and v.turn==v.seat);hit.Activated:Connect(function()playOwned(i)end)
  end
  D.SetEnabled(V.Raise,v.phase=="play"and v.turn==v.seat and v.nextRaise~=nil and not v.iron and not v.specialTeam and v.raiseOwner~=team)
  V.Raise.Text=v.nextRaise and R.CallName(v.nextRaise)or"DOZE";D.SetEnabled(V.Run,v.phase=="play"and v.turn==v.seat)
  D.SetEnabled(V.Cover,v.phase=="play"and #v.tricks>0);if #v.tricks==0 then covered=false;V.Cover.Text="Carta aberta"end;V.Covered=covered
  V.Run.Text=v.phase=="finished"and"Sair"or"Correr"
  if v.phase=="finished"then V.Raise.Text="Revanche";D.SetEnabled(V.Raise,not v.cup);D.SetEnabled(V.Run,true);V.Status.Text=(v.rematchCount or 0).." confirmações para revanche"end
  if v.phase=="raise"and v.pending.team~=team then
   V.DecisionActive=true
   V.Dialog.Visible=true;V.DecisionLabel=R.CallName(v.pending.value).." · mão vale "..v.pending.value;V.Message.Text=V.DecisionLabel.." · "..v.remaining.."s"
   option("Aceitar",function()action("respond","accept")end,C.green);option("Correr",function()action("respond","run")end)
   for _,value in ipairs(R.Profiles[v.variant].raises)do if value>v.pending.value then option(R.CallName(value),function()action("respond","raise")end);break end end
  elseif v.phase=="special"and v.specialTeam==team then
   V.Dialog.Visible=true;V.Message.Text="Mão de "..R.Profiles[v.variant].special.." • confira sua dupla"
   option("Jogar",function()action("special",true)end,C.green);option("Correr",function()action("special",false)end)
   if v.partner then V.Status.Text="Parceiro: "..table.concat((function()local s={};for _,c in ipairs(v.partner)do table.insert(s,c.rank..c.suit)end;return s end)(),"  ")end
  elseif v.phase=="cut"then
   V.Status.Text="Corte seco: aguarde o jogador à esquerda do carteador"
   if v.seat==(v.dealer+2)%4+1 then V.Dialog.Visible=true;V.Message.Text="Cortar o baralho"
    option("Um terço",function()action("cut",13)end);option("Ao meio",function()action("cut",20)end,C.green);option("Dois terços",function()action("cut",27)end)
   end
  elseif v.phase=="dealing"then
   V.Status.Text=v.players[v.dealer].name.." distribui • "..v.dealCount.." / 4 grupos"
   V.Dialog.Visible=true;V.Message.Text=v.seat==v.dealer and"Distribuir três cartas juntas"or"Observe a origem das cartas"
   if v.seat==v.dealer then
    option("Por cima",function()action("deal","top")end,C.green);option("Por baixo",function()action("deal","bottom")end)
    option("Pelo meio • infração",function()action("deal","middle")end,C.red)
   else option("Conferir carteada",function()action("report")end)end
  elseif v.phase=="finished"then
   V.Dialog.Visible=true;V.Message.Text=v.winner==team and"Sua dupla venceu!"or"Partida encerrada"
   if not v.cup then option("Revanche",function()action("rematch")end,C.green)end
   V.Status.Text=v.last and v.last.reason or"Fim da partida";option("Voltar aos jogos",function()if V.OnLeave then V.OnLeave()end end,C.green)
  elseif v.phase=="between"then V.Status.Text=v.last and(v.last.team and"Dupla "..v.last.team.." ganhou "..v.last.points.." ponto(s)"or"Empate • nova carteada")or"Preparando mão"end
  V.Layout()
 end
 V.Raise.Activated:Connect(function()action(state and state.phase=="finished"and"rematch"or"raise")end);V.Run.Activated:Connect(function()if state and state.phase=="finished"then if V.OnLeave then V.OnLeave()end else action("run")end end)
 V.Cover.Activated:Connect(function()covered=not covered;V.Covered=covered;V.Cover.Text=covered and"Carta coberta"or"Carta aberta"end)
 function V.Tick()
  if not state or not V.DecisionActive or not V.Dialog.Visible then return end
  local left=math.max(0,math.ceil((state.remaining or 0)-(os.clock()-V.ReceivedAt)))
  V.Message.Text=V.DecisionLabel.." · "..left.."s"..(left==0 and " · tempo encerrado"or "")
  if left==0 then for _,b in ipairs(options)do D.SetEnabled(b,false)end end
 end
 V.Shouts.Activated:Connect(function()
  if not state then return end;if state.manual and state.phase=="play"and #state.tricks==0 and #state.tableCards==0 and R.Team(state.seat)~=R.Team(state.dealer)then action("report");return end;shouts=not shouts;V.Dialog.Visible=shouts;clear(V.Options);options={}
  V.DecisionActive=false;V.Message.Text="Escolha uma carta · peça TRUCO para aumentar a mão"
  if V.Raise.Active then option(R.CallName(state.nextRaise),function()action("raise");V.Dialog.Visible=false end,C.green)end
  if state.phase=="raise"and state.pending.team~=R.Team(state.seat)then option("ACEITO!",function()action("respond","accept")end);option("CORRER",function()action("respond","run")end)end
  option("Voltar à mesa",function()V.Update(state,V.Inventory)end)
  V.Layout()
 end)
 V.Close.Activated:Connect(function()
  if not state or state.phase=="finished"then if V.OnLeave then V.OnLeave()end;return end
  V.DecisionActive=false;V.Dialog.Visible=true;clear(V.Options);options={};V.Message.Text="Sair encerra sua partida. Deseja desistir?"
  option("Continuar",function()V.Update(state,V.Inventory)end,C.green);option("Desistir",function()if V.OnLeave then V.OnLeave()end end,C.red);V.Layout()
 end);safe.Watch(V.Layout);return V
end
return U
