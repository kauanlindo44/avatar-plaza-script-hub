-- 07K5_TRUCO_UI | ModuleScript | ReplicatedStorage | V69 (SUBSTITUIR)
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local R=require(Rep:WaitForChild("07K0_TRUCO_RULES"))
local Table=require(Rep:WaitForChild("07K15_TRUCO_TABLE"))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local F=Fx.Colors
local U={}
function U.Build(gui,action)
 local V={};local state;local goals=require(Rep:WaitForChild('07H8_PLAY_SESSION')).New('Truco');local safe=Bounds.Bind(gui)
 V.Root=D.New("Frame",{Name="TrucoMatch",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(16,18,24),BackgroundTransparency=0,Visible=false},gui)
 Fx.Surface(V.Root,Color3.fromRGB(16,18,24),Color3.fromRGB(31,53,47));V.Root:SetAttribute('ACP_ChatGameType','Truco')
 V.Title=D.Text(V.Root,"Truco",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=.12,BackgroundColor3=C.panel})
 V.Close=D.IconButton(V.Root,"LeaveTruco","close","Sair da mesa",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 V.Score=D.Text(V.Root,"SUA DUPLA\n0 : 0\nRIVAIS",{BackgroundColor3=C.panel,BackgroundTransparency=.08,TextSize=18,Font=Enum.Font.GothamBold,ZIndex=5})
 V.Status=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.12,TextSize=14,ZIndex=5})
 D.Round(V.Score,12);V.Score.BackgroundColor3=Color3.fromRGB(35,39,49);V.Score.TextColor3=Color3.fromRGB(36,52,63)
 V.Title.BackgroundTransparency=1;V.Status.BackgroundTransparency=1;V.Status.TextColor3=Color3.fromRGB(50,100,89)
 V.Hand=D.New("Frame",{Name="PrivateHand",BackgroundTransparency=1,ZIndex=8},V.Root)
 V.Root:SetAttribute('V56_NoTheme',true);local accent=V.Root:FindFirstChild('HalloweenSceneAccent');if accent then accent:Destroy()end
 local tableView=Table.Build(V.Root);V.Hand.Parent=tableView.Root;V.TableView=tableView;V.TableArea=tableView.Root;V.TableCards=tableView.Cards;V.HandCards={}
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
 V.Chat=D.Button(V.Root,"Chat",{Name="OpenTrucoChat",TextSize=12,ZIndex=12});V.Leave=D.Button(V.Root,"Sair da mesa",{Name="LeaveTable",TextSize=12,ZIndex=12})
 V.Dialog=D.Frame(V.Root,{Name="TableDecision",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.45),BackgroundColor3=C.panel,Visible=false,ZIndex=20});Fx.Surface(V.Dialog,F.navy,Color3.fromRGB(31,53,47),F.gold)
 V.Message=D.Text(V.Dialog,"",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,48),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=21})
 V.Options=D.New("Frame",{Position=UDim2.fromOffset(10,62),Size=UDim2.new(1,-20,1,-72),BackgroundTransparency=1,ZIndex=21},V.Dialog)
 V.DecisionTrack=D.Frame(V.Dialog,{Name='DecisionTime',Position=UDim2.new(0,12,1,-12),Size=UDim2.new(1,-24,0,4),BackgroundColor3=Color3.fromRGB(44,66,69),ZIndex=24})
 V.DecisionFill=D.Frame(V.DecisionTrack,{Size=UDim2.fromScale(1,1),BackgroundColor3=F.gold,ZIndex=25})
 V.Moment=D.Frame(V.Root,{Name='TrucoMoment',Visible=false,BackgroundColor3=Color3.fromRGB(33,58,53),BackgroundTransparency=.10,ZIndex=19,Active=false})
 V.MomentLabel=D.Text(V.Moment,'',{Size=UDim2.fromScale(1,1),TextSize=14,Font=Enum.Font.GothamBold,ZIndex=19,Active=false})
 V.TrickProgress=D.New('Frame',{Name='HandTimeline',BackgroundTransparency=1,ZIndex=7},V.Root);V.TrickDots={}
 for i=1,3 do V.TrickDots[i]=D.Text(V.TrickProgress,tostring(i),{TextSize=11,BackgroundColor3=F.panel,BackgroundTransparency=.12,ZIndex=8});D.Round(V.TrickDots[i],8)end
 V.MoreActions=D.Button(V.Controls,'…',{Name='MoreTrucoActions',TextSize=24,ZIndex=12});V.ActionsOpen=false
 V.Secondary=D.Frame(V.Root,{Name='SecondaryTrucoActions',BackgroundColor3=Color3.fromRGB(35,39,49),Visible=false,ZIndex=15});V.Cover.Parent=V.Secondary;V.Run.Parent=V.Secondary;V.Shouts.Parent=V.Root
 V.MoreActions.Activated:Connect(function()V.ActionsOpen=not V.ActionsOpen;V.Secondary.Visible=V.ActionsOpen;V.Layout()end)
 local momentId=0;local lastMoment;local covered=false;local options={};local shouts=false
 local function clear(p)for _,o in ipairs(p:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end end
 local function option(label,fn,color)
  local primary=color==C.green;local b=D.Button(V.Options,label,{BackgroundColor3=primary and Color3.fromRGB(120,195,143) or color or F.panel,TextColor3=color==C.red and C.bg or C.white,ZIndex=22});Fx.Button(b,F.gold);b.Activated:Connect(fn);table.insert(options,b)
 end
 function V.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local top=safe.Heading(V.Title,V.Close);local bar=safe.Topbar();local useBar=aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48
  local hx,hy,hw=il,it+2,aw;if useBar then hx,hy,hw=bar.X,bar.Y+2,bar.Right-bar.X;top=it+4 end
  Bounds.Rect(V.Title,hx+6,hy,math.max(60,hw-112),44);V.Title.TextSize=aw<480 and 14 or 19;Bounds.Rect(V.Close,hx+hw-52,hy,48,48)
  local footer=h-ib-50;local th=math.max(100,footer-top-24);Bounds.Rect(V.Status,il+8,top,aw-130,22);V.Status.TextSize=aw<480 and 10 or 12
  Bounds.Rect(V.TableArea,il+6,top+22,aw-12,th);tableView.Layout();local hand=tableView.HandRect
  if hand then Bounds.Rect(V.Hand,hand.x,hand.y,hand.w,hand.h);local cw=hand.h*.70
   for i,c in ipairs(V.HandCards)do Bounds.Rect(c,(i-1)*cw*.62,math.abs(i-2)*5,cw,hand.h-5);c.Rotation=(i-2)*10 end
  end
  V.CardChoices.Visible=false;Bounds.Rect(V.Score,w-ir-112,top+2,104,68);V.Score.TextSize=aw<480 and 12 or 15
  Bounds.Rect(V.TrickProgress,w-ir-104,top+76,88,20);for i,d in ipairs(V.TrickDots)do Bounds.Rect(d,(i-1)*30,0,26,20)end
  Bounds.Rect(V.Moment,il+(aw-math.min(300,aw-28))/2,top+30,math.min(300,aw-28),28)
  local narrow=aw<430;Bounds.Rect(V.Chat,il+6,footer,narrow and 56 or 88,44);Bounds.Rect(V.Leave,w-ir-(narrow and 70 or 114),footer,narrow and 64 or 108,44)
  V.Chat.Visible=true;V.Leave.Visible=true;V.Leave.Text=narrow and'Sair'or'Sair da mesa'
  Bounds.Rect(V.Controls,il+aw*.5-78,footer,156,44);Bounds.Rect(V.Raise,0,0,106,44);Bounds.Rect(V.MoreActions,112,0,44,44)
  Bounds.Rect(V.Secondary,il+aw*.5-142,footer-54,284,50);Bounds.Rect(V.Cover,4,3,138,44);Bounds.Rect(V.Run,148,3,132,44)
  V.Secondary.Visible=V.ActionsOpen==true and not V.Dialog.Visible;V.Raise.Visible=not state or state.phase=='finished'or state.phase=='play'and state.turn==state.seat
  Bounds.Rect(V.Shouts,il+8,top+28,44,44);V.Shouts.Text='?';V.Shouts.TextSize=20;V.Shouts:SetAttribute('ActionLabel','Como jogar ou conferir a carteada')
  local pw=math.min(500,aw-16);local ph=math.min(230,h-it-ib-16);Bounds.Rect(V.Dialog,il+(aw-pw)/2,it+(h-it-ib-ph)/2,pw,ph)
  local cols=#options>3 and 2 or math.max(1,#options);local width=(pw-20-(cols-1)*6)/cols
  for i,b in ipairs(options)do Bounds.Rect(b,(i-1)%cols*(width+6),math.floor((i-1)/cols)*48,width,44)end
 end
 function V.Update(v,inventory)
  state=v;V.ActionsOpen=false;V.Secondary.Visible=false;V.ReceivedAt=os.clock();V.DecisionActive=false;V.DecisionTrack.Visible=false;V.Inventory=inventory;shouts=false;V.Root.Visible=true;V.Dialog.Visible=false;clear(V.Options);options={};clear(V.Hand);V.HandCards={};tableView.Update(v,inventory)
  V.Shouts.Text=v.manual and v.phase=="play"and #v.tricks==0 and #v.tableCards==0 and R.Team(v.seat)~=R.Team(v.dealer)and"Conferir"or"Como jogar"
  local team=R.Team(v.seat);goals.Truco(v,team)
  for i,d in ipairs(V.TrickDots)do local win=(v.tricks or{})[i];d.Text=win==nil and tostring(i)or win==0 and'='or win==team and'♥'or'×';d.BackgroundColor3=win==nil and F.panel or win==0 and F.navy or win==team and Color3.fromRGB(34,88,66)or Color3.fromRGB(101,66,40);d.TextColor3=win~=nil and win~=0 and C.bg or C.white end
  local key=tostring(v.handNumber)..':'..tostring(#v.tricks)..':'..v.phase
  if key~=lastMoment then
   lastMoment=key;local text
   if v.phase=='raise'then text=R.CallName(v.pending.value)..'! • '..(v.pending.team==team and'Sua dupla'or'Dupla rival')
   elseif v.phase=='between'then text=v.last and(v.last.team==team and'Sua dupla pontuou!'or v.last.team and'Rivais pontuaram'or'Empate • nova mão')
   elseif #v.tableCards==0 and #v.tricks>0 then local win=v.tricks[#v.tricks];text=win==0 and'Vaza empatada'or win==team and'Vaza da sua dupla'or'Vaza dos rivais'end
   if text then momentId=momentId+1;local mine=momentId;V.MomentLabel.Text=text;V.Moment.Visible=true;Fx.Enter(V.Moment);task.delay(v.phase=='raise'and 10 or 3.8,function()if mine==momentId then V.Moment.Visible=false end end)else V.Moment.Visible=false end
  end
  V.Title.Text="Truco · "..v.variant
  V.Score.Text="SUA DUPLA\n"..v.score[team].." : "..v.score[3-team].."\nRIVAIS"
  V.Status.Text=v.phase=="play"and(v.turn==v.seat and"Sua vez · toque em qualquer uma das três cartas"or"Vez de "..v.players[v.turn].name..(R.Team(v.turn)==team and" · sua dupla"or" · adversário"))or"Acompanhe a mesa"
  if v.vira and v.phase=='play'then V.Status.Text=V.Status.Text..' • vira '..v.vira.rank..(({S='♠',H='♥',D='♦',C='♣'})[v.vira.suit]or'')end
  for i,b in ipairs(V.CardButtons)do local c=v.hand[i];b.Visible=c~=nil;b.Text=c and(c.hidden and"Carta "..i or i.." · "..c.rank..(({S="♠",H="♥",D="♦",C="♣"})[c.suit]or""))or"";D.SetEnabled(b,c~=nil and v.phase=="play"and v.turn==v.seat)end
  local style=inventory and inventory.equipped or"Classic";local custom=inventory and inventory.custom
  if inventory and inventory.view=="classic"then style="Classic"end
  V.Hand.Visible=true
  for i,c in ipairs(v.hand)do
   local frame=Cards.Render(V.Hand,c,style,{Name="OwnedCard"..i,ZIndex=8},custom);V.HandCards[i]=frame
   local hit=D.Button(frame,"",{Name="PlayCard",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=18})
   hit.AutoButtonColor=false;Fx.Button(hit,F.jade);D.SetEnabled(hit,v.phase=="play"and v.turn==v.seat);hit.Activated:Connect(function()playOwned(i)end)
  end
  D.SetEnabled(V.Raise,v.phase=="play"and v.turn==v.seat and v.nextRaise~=nil and not v.iron and not v.specialTeam and v.raiseOwner~=team)
  V.Raise.Text=v.nextRaise and R.CallName(v.nextRaise)or"DOZE";V.Raise:SetAttribute("ActionLabel","Aumentar o valor da mão");V.Cover:SetAttribute("ActionLabel","Jogar virada após a primeira vaza");D.SetEnabled(V.Run,v.phase=="play"and v.turn==v.seat)
  D.SetEnabled(V.Cover,v.phase=="play"and v.turn==v.seat and #v.tricks>0);if #v.tricks==0 then covered=false;V.Cover.Text="Carta aberta"end;V.Covered=covered
  V.Run.Text=v.phase=="finished"and"Sair"or"Correr"
  if v.phase=="finished"then V.Raise.Text="Revanche";D.SetEnabled(V.Raise,not v.cup);D.SetEnabled(V.Run,true);V.Status.Text=(v.rematchCount or 0).." confirmações para revanche"end
  if v.phase=="raise"and v.pending.team~=team then
   V.DecisionActive=true;V.DecisionTrack.Visible=true;V.DecisionFill.Size=UDim2.fromScale(1,1)
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
   V.Dialog.Visible=true;V.Message.Text=(v.winner==team and'Sua dupla venceu!'or'Boa partida!')..'\nSessão '..(v.sessionScore or{0,0})[team]..' × '..(v.sessionScore or{0,0})[3-team]
   if not v.cup then option("Revanche",function()action("rematch")end,C.green)end
   V.Status.Text=v.last and v.last.reason or"Fim da partida";option("Voltar aos jogos",function()if V.OnLeave then V.OnLeave()end end,C.green)
  elseif v.phase=="between"then V.Status.Text=v.last and(v.last.team and(v.last.team==team and"Sua dupla"or"A dupla adversária").." ganhou "..v.last.points.." ponto(s)"or"Empate • nova carteada")or"Preparando mão"end
  -- Informações de turno permanecem curtas; sessão e metas ficam no resumo final.
  if v.phase=='finished'then V.Message.Text=V.Message.Text..'\n'..goals.Summary();V.Message.TextSize=13 else V.Message.TextSize=18 end
  V.Layout()
 end
 V.Raise.Activated:Connect(function()action(state and state.phase=="finished"and"rematch"or"raise")end);V.Run.Activated:Connect(function()if state and state.phase=="finished"then if V.OnLeave then V.OnLeave()end else action("run")end end)
 V.Cover.Activated:Connect(function()covered=not covered;V.Covered=covered;V.Cover.Text=covered and"Carta coberta"or"Carta aberta"end)
 function V.Tick()
  if not state or not V.DecisionActive or not V.Dialog.Visible then return end
  local left=math.max(0,math.ceil((state.remaining or 0)-(os.clock()-V.ReceivedAt)))
  V.Message.Text=V.DecisionLabel.." · "..left.."s"..(left==0 and " · tempo encerrado"or "")
  V.DecisionFill.Size=UDim2.fromScale(math.clamp(left/10,0,1),1)
  if left==0 then for _,b in ipairs(options)do D.SetEnabled(b,false)end end
 end
 V.Shouts.Activated:Connect(function()
  if not state then return end;if state.manual and state.phase=="play"and #state.tricks==0 and #state.tableCards==0 and R.Team(state.seat)~=R.Team(state.dealer)then action("report");return end;shouts=not shouts;V.Dialog.Visible=shouts;clear(V.Options);options={}
  V.DecisionActive=false;local profile=R.Profiles[state.variant]
  V.Message.Text='Sua dupla contra dois rivais • ganha quem vence 2 vazas'
  if not V.Raise.Active and state.phase=='play'then
   V.Message.Text=state.turn~=state.seat and'Aguarde sua vez para jogar ou pedir TRUCO'or state.iron and'Mão de ferro: sem TRUCO'or state.specialTeam and'Mão especial: escolha Jogar ou Correr'or'Truco só pode subir após a resposta da outra dupla'
  end
  if profile then option('12 pontos • aumentos '..table.concat(profile.raises,' / '),function()V.Update(state,V.Inventory)end)end
  option('Correr: rivais ganham a mão',function()V.Update(state,V.Inventory)end)
  option('Cobrir: após a primeira vaza',function()V.Update(state,V.Inventory)end)
  if V.Raise.Active then option(R.CallName(state.nextRaise),function()action("raise");V.Dialog.Visible=false end,C.green)end
  if state.phase=="raise"and state.pending.team~=R.Team(state.seat)then option("ACEITO!",function()action("respond","accept")end);option("CORRER",function()action("respond","run")end)end
  option("Voltar à mesa",function()V.Update(state,V.Inventory)end)
  V.Layout()
 end)
 local function confirmLeave()
  if not state or state.phase=="finished"then if V.OnLeave then V.OnLeave()end;return end
  V.DecisionActive=false;V.Dialog.Visible=true;clear(V.Options);options={};V.Message.Text="Sair encerra sua partida. Deseja desistir?"
  option("Continuar",function()V.Update(state,V.Inventory)end,C.green);option("Desistir",function()if V.OnLeave then V.OnLeave()end end,C.red);V.Layout()
 end
 V.Close.Activated:Connect(confirmLeave);V.Leave.Activated:Connect(confirmLeave)
 V.MatchChat=require(Rep:WaitForChild('07H10_MATCH_CHAT_UI')).Build(V.Root,V.Chat)
 for _,b in ipairs({V.Close,V.Raise,V.Cover,V.Run,V.Shouts})do Fx.Button(b,F.jade)end
 V.Raise.BackgroundColor3=Color3.fromRGB(135,204,153);V.Raise.TextColor3=C.white
 V.Dialog:GetPropertyChangedSignal('Visible'):Connect(function()Fx.Enter(V.Dialog)end)
 safe.Watch(V.Layout);return V
end
return U
