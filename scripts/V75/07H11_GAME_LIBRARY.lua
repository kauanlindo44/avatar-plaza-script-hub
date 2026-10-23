-- 07H11_GAME_LIBRARY | ModuleScript | ReplicatedStorage | V75 (SUBSTITUIR)
-- Biblioteca expansível das nossas versões de jogos. Regras e controladores preservados.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={}
local entries={
 {key='Botão do Caos',tag='AÇÃO · MULTIJOGADOR',desc='Corra, aperte e sobreviva.',meta='2–8 pessoas · 150 s',color=Color3.fromRGB(255,206,75),kind='chaos'},
 {key='Truco',tag='CARTAS · DUPLAS',desc='Duplas, blefe e uma boa conversa.',meta='Paulista · Mineiro · Goiano',color=Color3.fromRGB(106,173,137),kind='cards'},
 {key='Xadrez',tag='ESTRATÉGIA',desc='Encontre sua próxima boa jogada.',meta='Pessoas ou nossos bots',color=Color3.fromRGB(147,178,215),kind='chess'},
 {key='Damas',tag='ESTRATÉGIA',desc='Uma partida clássica no seu ritmo.',meta='Pessoas ou nossos bots',color=Color3.fromRGB(202,155,123),kind='checkers'}}
function M.Build(U)
 local L={cards={},sideButtons={},home=true};local R=Bounds.Rect;local C=D.Colors
 L.Root=D.Scroll(U.Root,{Name='OurGamesLibrary',BackgroundTransparency=1,AutomaticCanvasSize=Enum.AutomaticSize.None})
 L.Heading=D.Text(L.Root,'Escolha seu próximo jogo',{Font=Enum.Font.GothamBold,TextSize=24,TextXAlignment=Enum.TextXAlignment.Left})
 L.Caption=D.Text(L.Root,'Quatro jogos do Plaza. Escolha uma mesa ou entre na arena.',{TextColor3=C.muted,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left})
 L.Back=D.Button(U.Root,'‹ Todos os nossos jogos',{Name='LibraryBack',TextSize=14,Visible=false})
 L.Sidebar=D.Frame(U.Root,{Name='LibrarySidebar',BackgroundColor3=Color3.fromRGB(43,51,54),Visible=false})
 L.SideHeading=D.Text(L.Sidebar,'ESCOLHA OUTRO JOGO',{TextSize=13,TextColor3=C.muted,Font=Enum.Font.GothamBold})
 function L.Choose(e)
  if U.Busy or U.WaitingState then return end
  if e.kind=='chaos'then if U.OnChaos then U.OnChaos()end else L.home=false;U.SetGame(e.key)end
 end
 local function artwork(parent,e)
  local art=D.Frame(parent,{Name='GameCardArt',BackgroundColor3=e.color:Lerp(Color3.fromRGB(238,241,242),.68)})
  if e.kind=='chaos'then
   D.Frame(art,{Name='ButtonBase',Position=UDim2.fromScale(.22,.65),Size=UDim2.fromScale(.56,.18),BackgroundColor3=Color3.fromRGB(39,49,66)})
   local cap=D.Frame(art,{Name='ChaosButton',Position=UDim2.fromScale(.31,.25),Size=UDim2.fromScale(.38,.46),BackgroundColor3=e.color});D.Stroke(cap,Color3.fromRGB(181,135,38),.3)
   D.Text(cap,'!',{Size=UDim2.fromScale(1,1),TextColor3=C.ink,TextSize=34,Font=Enum.Font.GothamBold})
  elseif e.kind=='cards'then
   local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
   for i,card in ipairs({{rank='A',suit='S'},{rank='K',suit='H'},{rank='7',suit='C'}})do Cards.Render(art,card,'Classic',{Position=UDim2.fromScale(.21+(i-1)*.17,.14+(i-2)^2*.04),Size=UDim2.fromScale(.25,.74),Rotation=(i-2)*10})end
  else
   local board=D.Frame(art,{Position=UDim2.fromScale(.25,.08),Size=UDim2.fromScale(.5,.84),BackgroundColor3=e.color})
   for row=0,3 do for col=0,3 do
    local square=D.New('Frame',{Size=UDim2.fromScale(.25,.25),Position=UDim2.fromScale(col/4,row/4),BorderSizePixel=0,BackgroundColor3=(row+col)%2==0 and Color3.fromRGB(244,232,209)or e.color:Lerp(C.ink,.35)},board)
    if e.kind=='checkers'and(row==0 or row==3)and(row+col)%2==1 then D.Frame(square,{Position=UDim2.fromScale(.15,.15),Size=UDim2.fromScale(.70,.70),BackgroundColor3=row==0 and Color3.fromRGB(235,225,208)or Color3.fromRGB(155,68,61)})
    elseif e.kind=='chess'and row==0 then D.Text(square,col%2==0 and'♜'or'♞',{Size=UDim2.fromScale(1,1),TextColor3=C.ink,TextScaled=true})end
   end end
  end
  return art
 end
 for _,e in ipairs(entries)do
  local b=D.Button(L.Root,'',{Name='Library_'..e.key,BackgroundColor3=e.color:Lerp(Color3.fromRGB(34,47,60),.80),TextColor3=C.white})
  local c={button=b,art=artwork(b,e)}
  c.tag=D.Text(b,e.tag,{TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextSize=12,TextColor3=e.color,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
  c.title=D.Text(b,e.key,{TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
  c.desc=D.Text(b,e.desc,{TextSize=14,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
  c.meta=D.Text(b,e.meta,{TextSize=13,TextColor3=e.color,TextXAlignment=Enum.TextXAlignment.Left});L.cards[#L.cards+1]=c
  b:SetAttribute('OurGame',true);b:SetAttribute('GameKey',e.key)
  b.Activated:Connect(function()L.Choose(e)end)
  local side=D.Button(L.Sidebar,e.key,{Name='Sidebar_'..e.key,TextSize=17,BackgroundColor3=C.card,TextColor3=C.white})
  side:SetAttribute('OurGame',true);side.Activated:Connect(function()L.Choose(e)end);L.sideButtons[#L.sideButtons+1]={root=side,key=e.key,color=e.color}
 end
 L.Back.Activated:Connect(function()if not U.Busy and not U.WaitingState then L.home=true;U.Options.Visible=false;U.Layout()end end)
 function L.Open()L.home=true;U.Options.Visible=false;U.Layout()end
 function L.Layout(il,it,ir,ib,w,h)
  local aw,ah=w-il-ir,h-it-ib
  L.Root.Visible=L.home and not U.WaitingState and not U.Options.Visible
  L.Back.Visible=not L.Root.Visible and not U.Options.Visible;U.Tabs.Visible=false
  local split=not L.home and not U.Options.Visible and aw>=1000 and ah>=520;L.Sidebar.Visible=split
  if split then
   R(L.Sidebar,il+8,U.Hero.Position.Y.Offset,240,U.Hero.Size.Y.Offset);R(L.SideHeading,8,8,224,32)
   local bh=(U.Hero.Size.Y.Offset-74)/4
   for i,b in ipairs(L.sideButtons)do R(b.root,8,50+(i-1)*(bh+8),224,bh);b.root.BackgroundColor3=b.key==U.Selected and b.color:Lerp(C.ink,.62)or C.card;b.root.Text=(b.key==U.Selected and'✓ 'or'')..b.key end
  end
  if L.Root.Visible then U.Hero.Visible=false;U.Status.Visible=false end
  local listTop=U.LibraryBackY or it+54
  R(L.Back,il+12,listTop,math.min(260,aw-24),44)
  local listH=h-ib-listTop-8;R(L.Root,il+8,listTop,aw-16,listH);local pw=aw-16
  R(L.Heading,6,2,pw-12,32);R(L.Caption,6,38,pw-12,40)
  local cols=pw<350 and 1 or 2;local gap=10;local cw=(pw-(cols+1)*gap)/cols
  local rows=math.ceil(#entries/cols);local available=listH-100;local ch=math.min(330,math.max(220,(available-(rows-1)*gap)/rows))
  for i,c in ipairs(L.cards)do
   local x=gap+(i-1)%cols*(cw+gap);local y=88+math.floor((i-1)/cols)*(ch+gap);R(c.button,x,y,cw,ch)
   if cw>=310 then
    local artW=math.floor(cw*.45);local tx=artW+20;local tw=cw-tx-12
    R(c.art,8,8,artW,ch-16);R(c.tag,tx,12,tw,24);R(c.title,tx,40,tw,52)
    R(c.desc,tx,100,tw,math.max(38,ch-160));R(c.meta,tx,ch-48,tw,36)
   else
    local artH=math.max(48,ch-160);R(c.art,8,8,cw-16,artH);R(c.tag,12,artH+12,cw-24,18);R(c.title,12,artH+34,cw-24,42)
    R(c.desc,12,artH+80,cw-24,38);R(c.meta,12,artH+124,cw-24,30)
   end
   c.tag.TextSize=cw<210 and 10 or 12;c.title.TextSize=cw<210 and 18 or 22;c.desc.TextSize=cw<210 and 13 or 14;c.meta.TextSize=cw<210 and 11 or 13
   D.SetEnabled(c.button,not U.Busy and not U.WaitingState)
  end
  L.Root.CanvasSize=UDim2.fromOffset(0,88+rows*(ch+gap)+8)
 end
 return L
end
return M
