-- 07K5_TRUCO_UI | ModuleScript | ReplicatedStorage | V45
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local R=require(Rep:WaitForChild("07K0_TRUCO_RULES"))
local U={}
function U.Build(gui,action)
 local V={};local safe=Bounds.Bind(gui)
 V.Root=D.New("Frame",{Name="TrucoMatch",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
 V.Title=D.Text(V.Root,"Truco",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=.12,BackgroundColor3=C.panel})
 V.Close=D.IconButton(V.Root,"LeaveTruco","close","Sair da mesa",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 V.Score=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.08,TextSize=18,Font=Enum.Font.GothamBold,ZIndex=5})
 V.Status=D.Text(V.Root,"",{BackgroundColor3=C.panel,BackgroundTransparency=.12,TextSize=14,ZIndex=5})
 V.Hand=D.New("Frame",{Name="PrivateHand",BackgroundTransparency=1,ZIndex=8},V.Root)
 V.Controls=D.New("Frame",{Name="TurnControls",BackgroundTransparency=1,ZIndex=10},V.Root)
 V.Raise=D.Button(V.Controls,"Truco",{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=12})
 V.Cover=D.Button(V.Controls,"Carta aberta",{ZIndex=12});V.Run=D.Button(V.Controls,"Correr",{TextColor3=C.red,ZIndex=12})
 V.Shouts=D.Button(V.Controls,"Gritos",{ZIndex=12})
 V.Dialog=D.Frame(V.Root,{Name="TableDecision",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.45),BackgroundColor3=C.panel,Visible=false,ZIndex=20})
 V.Message=D.Text(V.Dialog,"",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,48),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=21})
 V.Options=D.New("Frame",{Position=UDim2.fromOffset(10,62),Size=UDim2.new(1,-20,1,-72),BackgroundTransparency=1,ZIndex=21},V.Dialog)
 local covered=false;local state;local options={};local shouts=false
 local function clear(p)for _,o in ipairs(p:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end end
 local function option(label,fn,color)
  local b=D.Button(V.Options,label,{BackgroundColor3=color or C.card,ZIndex=22});b.Activated:Connect(fn);table.insert(options,b)
 end
 function V.Layout()
  local il,it,ir,ib,w,h=safe.Read();local y=safe.Heading(V.Title,V.Close);local aw=w-il-ir;local ah=h-ib-y
  Bounds.Rect(V.Score,il+8,y+4,aw-16,32);Bounds.Rect(V.Status,il+8,y+40,aw-16,28)
  local handHeight=math.clamp(ah*.23,72,124);local controlsHeight=44
  Bounds.Rect(V.Hand,il+aw*.20,h-ib-controlsHeight-handHeight-14,aw*.6,handHeight)
  Bounds.Rect(V.Controls,il+8,h-ib-controlsHeight-6,aw-16,controlsHeight)
  local controls={V.Raise,V.Cover,V.Run,V.Shouts};for i,b in ipairs(controls)do Bounds.Rect(b,(i-1)*(aw-12)/4,0,(aw-24)/4,44)end
  local pw=math.min(540,aw-16);local ph=math.min(226,ah-40);V.Dialog.Size=UDim2.fromOffset(pw,ph)
  local cols=#options>3 and 2 or math.max(1,#options);local rows=math.ceil(#options/cols);local cw=(pw-20-(cols-1)*6)/cols
  for i,b in ipairs(options)do Bounds.Rect(b,(i-1)%cols*(cw+6),math.floor((i-1)/cols)*48,cw,44)end
  if V.OnLayout then V.OnLayout()end
 end
 function V.Update(v,inventory)
  state=v;V.Inventory=inventory;shouts=false;V.Root.Visible=true;V.Dialog.Visible=false;clear(V.Options);options={};clear(V.Hand)
  V.Shouts.Text=v.manual and v.phase=="play"and #v.tricks==0 and #v.tableCards==0 and R.Team(v.seat)~=R.Team(v.dealer)and"Conferir"or"Gritos"
  local team=R.Team(v.seat);V.Title.Text="Truco • "..v.variant..(v.training and" • treino"or"")
  V.Score.Text="Sua dupla  "..v.score[team].."  ×  "..v.score[3-team].."  Adversários   •   Mão vale "..v.value
  V.Status.Text=v.phase=="play"and(v.turn==v.seat and"Sua vez • escolha uma carta"or"Vez de "..v.players[v.turn].name)or"Acompanhe a mesa"
  local style=inventory and inventory.equipped or"Classic";local custom=inventory and inventory.custom
  if inventory and inventory.view=="classic"then style="Classic"end
  V.Hand.Visible=not V.WorldHand
  for i,c in ipairs(V.WorldHand and{}or v.hand)do
   local width=math.min(130,V.Hand.AbsoluteSize.X/3-8);local frame=Cards.Render(V.Hand,c,style,{Position=UDim2.new((i-1)/3,4,0,0),Size=UDim2.new(1/3,-8,1,0),ZIndex=8},custom)
   local hit=D.Button(frame,"",{Name="PlayCard",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=18})
   D.SetEnabled(hit,v.phase=="play"and v.turn==v.seat);hit.Activated:Connect(function()action("play",i,covered)end)
  end
  D.SetEnabled(V.Raise,v.phase=="play"and v.turn==v.seat and v.nextRaise~=nil and not v.iron and not v.specialTeam and v.raiseOwner~=team)
  V.Raise.Text=v.nextRaise and("Pedir "..v.nextRaise)or"Limite: 12";D.SetEnabled(V.Run,v.phase=="play"and v.turn==v.seat)
  D.SetEnabled(V.Cover,v.phase=="play"and #v.tricks>0);if #v.tricks==0 then covered=false;V.Cover.Text="Carta aberta"end;V.Covered=covered
  if v.phase=="raise"and v.pending.team~=team then
   V.Dialog.Visible=true;V.Message.Text="A outra dupla pediu "..v.pending.value
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
  V.Message.Text="Expressões da mesa"
  for _,s in ipairs({"Boa jogada!","Vamos nessa!","É nossa vez!","Respeito à mesa"})do option(s,function()if V.OnShout then V.OnShout(s)end;V.Dialog.Visible=false end)end
  V.Layout()
 end)
 V.Close.Activated:Connect(function()
  if not state or state.phase=="finished"then if V.OnLeave then V.OnLeave()end;return end
  V.Dialog.Visible=true;clear(V.Options);options={};V.Message.Text="Sair encerra sua partida. Deseja desistir?"
  option("Continuar",function()V.Update(state,V.Inventory)end,C.green);option("Desistir",function()if V.OnLeave then V.OnLeave()end end,C.red);V.Layout()
 end);safe.Watch(V.Layout);return V
end
return U
