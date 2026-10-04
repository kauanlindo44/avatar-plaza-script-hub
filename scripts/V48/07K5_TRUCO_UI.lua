-- 07K5_TRUCO_UI | ModuleScript | ReplicatedStorage | V48
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local R=require(Rep:WaitForChild("07K0_TRUCO_RULES"))
local U={}
function U.Build(gui,action)
 local V={};local state;local safe=Bounds.Bind(gui)
 V.Root=D.New("Frame",{Name="TrucoMatch",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(10,17,14),BackgroundTransparency=0,Visible=false},gui)
 V.Title=D.Text(V.Root,"Truco",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=.12,BackgroundColor3=C.panel})
 V.Close=D.IconButton(V.Root,"LeaveTruco","close","Sair da mesa",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 V.Score=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.08,TextSize=18,Font=Enum.Font.GothamBold,ZIndex=5})
 V.Status=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.12,TextSize=14,ZIndex=5})
 V.Hand=D.New("Frame",{Name="PrivateHand",BackgroundTransparency=1,ZIndex=8},V.Root)
 V.TableArea=D.Frame(V.Root,{Name="TableView",BackgroundColor3=Color3.fromRGB(18,64,45),ClipsDescendants=true})
 D.Stroke(V.TableArea,Color3.fromRGB(79,162,110),.32,2);D.New("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(30,82,54),Color3.fromRGB(12,36,26)),Rotation=90},V.TableArea)
 V.TableCards=D.New("Frame",{Name="PublicTableCards",BackgroundTransparency=1},V.TableArea);V.TableSlots={};V.HandCards={};V.TableCaption=D.Text(V.TableArea,"MESA",{TextSize=11,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left})
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
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local ah=h-it-ib;local side=aw>=650
  safe.Heading(V.Title,V.Close);local titleW=math.min(184,aw*.32)
  Bounds.Rect(V.Title,il+8,it+4,titleW,42);V.Title.TextSize=aw<480 and 14 or 20;V.Title.TextWrapped=false
  Bounds.Rect(V.Score,il+titleW+16,it+4,aw-titleW-80,42);V.Score.TextSize=aw<480 and 13 or 18
  Bounds.Rect(V.Status,il+8,it+50,aw-16,22);V.Status.TextSize=aw<480 and 12 or 14
  local top=it+78;local bottom=h-ib-56;local available=math.max(100,bottom-top)
  local tableW=side and math.floor((aw-24)*.54)or aw-16
  local tableH=side and available or math.floor(available*.47)
  Bounds.Rect(V.TableArea,il+8,top,tableW,tableH);Bounds.Rect(V.TableCaption,10,4,tableW-20,18)
  local hx=side and il+tableW+16 or il+8;local hw=side and aw-tableW-24 or aw-16
  local hy=side and top or top+tableH+8;local handH=math.max(42,bottom-hy-50)
  Bounds.Rect(V.Hand,hx,hy,hw,handH);Bounds.Rect(V.CardChoices,hx,hy+handH+6,hw,44)
  local cardH=math.min(handH,hw/3/0.70-8);local cardW=cardH*.70;local total=cardW*3+12
  for i,b in ipairs(V.CardButtons)do Bounds.Rect(b,(i-1)*(hw+6)/3,0,(hw-12)/3,44);b.TextSize=hw<300 and 11 or 13 end
  for i,c in ipairs(V.HandCards)do Bounds.Rect(c,(hw-total)/2+(i-1)*(cardW+6),(handH-cardH)/2,cardW,cardH)end
  Bounds.Rect(V.Controls,il+8,h-ib-50,aw-16,44)
  for i,b in ipairs({V.Raise,V.Cover,V.Run,V.Shouts})do Bounds.Rect(b,(i-1)*(aw-10)/4,0,(aw-28)/4,44);b.TextSize=aw<480 and 12 or 14 end
  local tw,th=tableW-16,tableH-26;Bounds.Rect(V.TableCards,8,24,tw,th)
  local cols=4;local rows=math.ceil(4/cols);local sw=(tw-(cols-1)*6)/cols;local sh=(th-(rows-1)*4)/rows
  for i,slot in ipairs(V.TableSlots)do
   Bounds.Rect(slot.root,(i-1)%cols*(sw+6),math.floor((i-1)/cols)*(sh+4),sw,sh)
   Bounds.Rect(slot.label,0,0,sw,20);slot.label.TextSize=sw<80 and 10 or 12
   local ch=math.min(sh-22,(sw-8)/.70);local cw=ch*.70;Bounds.Rect(slot.card,(sw-cw)/2,22,cw,ch)
  end
  local pw=math.min(540,aw-16);local ph=math.min(226,ah-24);Bounds.Rect(V.Dialog,il+(aw-pw)/2,it+(ah-ph)/2,pw,ph)
  local cols=#options>3 and 2 or math.max(1,#options);local cw=(pw-20-(cols-1)*6)/cols
  for i,b in ipairs(options)do Bounds.Rect(b,(i-1)%cols*(cw+6),math.floor((i-1)/cols)*48,cw,44)end
 end
 local function publicTable(v,inventory)
  clear(V.TableCards);V.TableSlots={};local played={};local cards=#v.tableCards>0 and v.tableCards or v.lastTrick or{}
  for _,p in ipairs(cards)do played[p.seat]=p.card end
  local view=inventory and inventory.view or"mine"
  for i=1,4 do
   local seat=(v.seat+i-2)%4+1;local person=v.players[seat]or{};local turn=v.phase=="play"and v.turn==seat
   local root=D.New("Frame",{Name="Seat"..seat,BackgroundTransparency=1},V.TableCards)
   local label=D.Text(root,(seat==v.seat and"Você"or tostring(person.name or"Jogador")),{Font=Enum.Font.GothamBold,TextColor3=turn and C.green or C.text,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
   local style=view=="players"and(v.styles or{})[seat]or{style=view=="classic"and"Classic"or inventory and inventory.equipped or"Classic",custom=inventory and inventory.custom}
   style=style or{style="Classic"};local card
   if played[seat]then card=Cards.Render(root,played[seat],style.style,{Name="PublicCard"..seat},style.custom)
   else card=D.Frame(root,{Name="EmptyCardSlot",BackgroundTransparency=.75,BackgroundColor3=C.panel});D.Stroke(card,C.green,.75,1)end
   root:SetAttribute("Seat",seat);root:SetAttribute("Team",R.Team(seat));V.TableSlots[i]={root=root,label=label,card=card}
  end
  V.TableCaption.Text=v.vira and("Vira: "..v.vira.rank..(({S="♠",H="♥",D="♦",C="♣"})[v.vira.suit]or""))or("Mão "..tostring(#v.tricks+1).." · "..(v.value or 1).." ponto(s)")
 end
 function V.Update(v,inventory)
  state=v;V.Inventory=inventory;shouts=false;V.Root.Visible=true;V.Dialog.Visible=false;clear(V.Options);options={};clear(V.Hand);V.HandCards={};publicTable(v,inventory)
  V.Shouts.Text=v.manual and v.phase=="play"and #v.tricks==0 and #v.tableCards==0 and R.Team(v.seat)~=R.Team(v.dealer)and"Conferir"or"Gritos"
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
  if v.phase=="raise"and v.pending.team~=team then
   V.Dialog.Visible=true;V.Message.Text=R.CallName(v.pending.value).." · mão vale "..v.pending.value
   option("Aceitar",function()action("respond","accept")end,C.green);option("Correr",function()action("respond","run")end)
   if v.pending.value<12 then option("Aumentar",function()action("respond","raise")end)end
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
   V.Status.Text=v.last and v.last.reason or"Fim da partida";option("Voltar aos jogos",function()if V.OnLeave then V.OnLeave()end end,C.green)
  elseif v.phase=="between"then V.Status.Text=v.last and(v.last.team and"Dupla "..v.last.team.." ganhou "..v.last.points.." ponto(s)"or"Empate • nova carteada")or"Preparando mão"end
  V.Layout()
 end
 V.Raise.Activated:Connect(function()action("raise")end);V.Run.Activated:Connect(function()action("run")end)
 V.Cover.Activated:Connect(function()covered=not covered;V.Covered=covered;V.Cover.Text=covered and"Carta coberta"or"Carta aberta"end)
 V.Shouts.Activated:Connect(function()
  if not state then return end;if state.manual and state.phase=="play"and #state.tricks==0 and #state.tableCards==0 and R.Team(state.seat)~=R.Team(state.dealer)then action("report");return end;shouts=not shouts;V.Dialog.Visible=shouts;clear(V.Options);options={}
  V.Message.Text="Chamadas da partida"
  if V.Raise.Active then option(R.CallName(state.nextRaise),function()action("raise");V.Dialog.Visible=false end,C.green)end
  if state.phase=="raise"and state.pending.team~=R.Team(state.seat)then option("ACEITO!",function()action("respond","accept")end);option("CORRER",function()action("respond","run")end)end
  option("Voltar à mesa",function()V.Update(state,V.Inventory)end)
  V.Layout()
 end)
 V.Close.Activated:Connect(function()
  if not state or state.phase=="finished"then if V.OnLeave then V.OnLeave()end;return end
  V.Dialog.Visible=true;clear(V.Options);options={};V.Message.Text="Sair encerra sua partida. Deseja desistir?"
  option("Continuar",function()V.Update(state,V.Inventory)end,C.green);option("Desistir",function()if V.OnLeave then V.OnLeave()end end,C.red);V.Layout()
 end);safe.Watch(V.Layout);return V
end
return U
