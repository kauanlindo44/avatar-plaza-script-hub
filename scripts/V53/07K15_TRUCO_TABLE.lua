-- 07K15_TRUCO_TABLE | ModuleScript | ReplicatedStorage | V53 (SUBSTITUIR)
-- Jogadores ao redor; cartas públicas no centro e coleta visual da vaza.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local Tween=game:GetService('TweenService');local Gui=game:GetService('GuiService')
local M={}
function M.Build(parent)
 local T={Players={},Slots={},Generation=0};local N=D.New;local R=Bounds.Rect
 T.Root=N('Frame',{Name='TrucoTableStage',BackgroundTransparency=1,ClipsDescendants=true},parent)
 T.Felt=D.Frame(T.Root,{Name='GreenTable',BackgroundColor3=Color3.fromRGB(17,76,52)});D.Round(T.Felt,100);D.Stroke(T.Felt,Color3.fromRGB(108,153,111),.28,3)
 N('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(37,103,66),Color3.fromRGB(11,50,39)),Rotation=90},T.Felt)
 local ring=N('Frame',{Name='TableInlay',Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,1,-24),BackgroundTransparency=1},T.Felt);D.Round(ring,100);D.Stroke(ring,Color3.fromRGB(149,178,125),.75,1)
 T.Cards=N('Frame',{Name='TrickCards',BackgroundTransparency=1,ZIndex=5},T.Root)
 T.Discard=N('Frame',{Name='DiscardPile',BackgroundTransparency=1,ZIndex=3},T.Root)
 T.DiscardLabel=D.Text(T.Discard,'',{TextColor3=C.muted,TextSize=11,Position=UDim2.fromScale(0,.8),Size=UDim2.fromScale(1,.2),ZIndex=4})
 T.Caption=D.Text(T.Root,'',{TextColor3=Color3.fromRGB(200,226,204),TextSize=12,TextWrapped=false,ZIndex=4})
 for i=1,4 do
  local p=D.Frame(T.Root,{Name='PlayerSeat'..i,BackgroundColor3=Color3.fromRGB(18,30,31),ZIndex=8});D.Stroke(p,C.green,.86,1)
  local thumb=N('ImageLabel',{Name='PlayerAvatar',BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=9},p)
  local name=D.Text(p,'',{Font=Enum.Font.GothamBold,TextSize=12,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=9})
  local back=N('Frame',{Name='OpponentHand',BackgroundTransparency=1,ZIndex=4},T.Root)
  T.Players[i]={root=p,thumb=thumb,label=name,back=back,cards={}}
 end
 local function clear(p)for _,v in ipairs(p:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end end
 function T.Layout()
  local w,h=T.Root.AbsoluteSize.X,T.Root.AbsoluteSize.Y;if w<1 or h<1 then return end
  local badgeH=h<180 and 26 or 38;local badgeW=math.min(152,w*.25);local sideW=math.min(104,w*.19)
  R(T.Felt,sideW*.25,badgeH*.25,w-sideW*.50,h-badgeH*.5)
  local positions={{(w-badgeW)/2,h-badgeH,badgeW},{w-sideW,math.max(badgeH,(h-badgeH)/2),sideW},{(w-badgeW)/2,0,badgeW},{0,math.max(badgeH,(h-badgeH)/2),sideW}}
  for i,p in ipairs(T.Players)do local v=positions[i];R(p.root,v[1],v[2],v[3],badgeH);R(p.thumb,2,2,badgeH-4,badgeH-4);R(p.label,badgeH,2,v[3]-badgeH-4,badgeH-4)
   p.label.TextSize=h<180 and 10 or 12
   local bh=math.min(42,h*.22);local bw=bh*.70;local bx=i==2 and w-sideW-bw*2.5 or i==4 and sideW or(w-bw*2.5)/2
   local by=i==3 and badgeH+2 or i==1 and h-badgeH-bh-2 or(h-bh)/2
   R(p.back,bx,by,bw*2.5,bh)
   for j,c in ipairs(p.cards)do R(c,(j-1)*bw*.55,0,bw,bh)end
  end
  local cw=math.min(w*.12,math.max(14,h*.32));local ch=cw/.70
  local cx,cy=w/2,h/2
  local pos={{cx-cw*.5,cy+ch*.04,0},{cx+cw*.56,cy-ch*.47,8},{cx-cw*.5,cy-ch*1.05,0},{cx-cw*1.55,cy-ch*.47,-8}}
  R(T.Cards,0,0,w,h)
  for i,s in pairs(T.Slots)do
   if h<220 then local rh=math.max(40,h-badgeH*2-6);local rw=math.min(w*.15,rh*.70);local total=rw*4+18
    R(s.card,(w-total)/2+(i-1)*(rw+6),(h-rh)/2,rw,rh);s.card.Rotation=0
   else local p=pos[i];R(s.card,p[1],p[2],cw,ch);s.card.Rotation=p[3]end
  end
  R(T.Discard,w-sideW-52,h-62,48,60)
  R(T.Caption,8,h-badgeH+(badgeH-20)/2,math.max(1,(w-badgeW)/2-16),20);T.Caption.TextSize=h<180 and 10 or 12
 end
 local lastKey;local displayKey;local current;local currentInventory
 local function skin(seat)
  local inv=currentInventory;local mode=inv and inv.view or'mine'
  if mode=='players'then return(current.styles or{})[seat]or{style='Classic'}end
  return{style=mode=='classic'and'Classic'or inv and inv.equipped or'Classic',custom=inv and inv.custom}
 end
 function T.Update(v,inventory)
  current=v;currentInventory=inventory;T.Generation=T.Generation+1;local gen=T.Generation
  for i,p in ipairs(T.Players)do
   local seat=(v.seat+i-2)%4+1;local who=v.players[seat]or{};p.root:SetAttribute('Seat',seat)
   p.label.Text=seat==v.seat and'Você'or tostring(who.name or'Jogador');p.thumb.Image=(who.uid or 0)>0 and('rbxthumb://type=AvatarHeadShot&id='..who.uid..'&w=150&h=150')or''
   local stroke=p.root:FindFirstChildOfClass('UIStroke');if stroke then stroke.Transparency=v.turn==seat and v.phase=='play'and .12 or .86 end
   clear(p.back);p.cards={};local style=skin(seat)
   if seat~=v.seat then for j=1,(v.counts or{})[seat]or 0 do p.cards[j]=Cards.Render(p.back,nil,style.style,{ZIndex=4},style.custom)end end
  end
  local key=tostring(v.handNumber)..':'..tostring(#v.tricks);local complete=#v.tableCards==0 and #(v.lastTrick or{})>0
  local cards=complete and v.lastTrick or v.tableCards
  if complete and key==lastKey then cards={}end
  clear(T.Cards);T.Slots={}
  for _,p in ipairs(cards)do local index=(p.seat-v.seat)%4+1;local style=skin(p.seat)
   T.Slots[index]={card=Cards.Render(T.Cards,p.card,style.style,{ZIndex=5},style.custom)}
  end
  T.Caption.Text=v.vira and('Vira '..v.vira.rank..' '..({S='♠',H='♥',D='♦',C='♣'})[v.vira.suit]..' · vale '..v.value)or('Vaza '..math.min(3,#v.tricks+1)..' · vale '..v.value)
  T.DiscardLabel.Text=#v.tricks>0 and(#v.tricks..' vaza(s)')or''
  T.Layout()
  if complete and key~=lastKey then
   local slots=T.Slots
   task.delay(1.6,function()
    if gen~=T.Generation or not T.Root.Parent then return end;lastKey=key
    for _,s in pairs(slots)do if s.card.Parent then
     if not Gui.ReducedMotionEnabled then pcall(function()Tween:Create(s.card,TweenInfo.new(.35),{Position=UDim2.fromOffset(T.Discard.Position.X.Offset,T.Discard.Position.Y.Offset),Size=UDim2.fromOffset(28,40),Rotation=8}):Play()end)end
    end end
    task.delay(.4,function()if gen==T.Generation then clear(T.Cards);T.Slots={};local old=T.Discard:FindFirstChild('CollectedCards');if old then old:Destroy()end;local c=Cards.Render(T.Discard,nil,'Classic',{Name='CollectedCards',Size=UDim2.new(1,0,.8,0),ZIndex=3});T.DiscardLabel.ZIndex=4 end end)
   end)
  end
 end
 T.Root:GetPropertyChangedSignal('AbsoluteSize'):Connect(T.Layout);return T
end
return M
