-- 07K15_TRUCO_TABLE | ModuleScript | ReplicatedStorage | V76 (SUBSTITUIR)
-- Jogadores ao redor; cartas públicas no centro e coleta visual da vaza.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local F=Fx.Colors
local Tween=game:GetService('TweenService');local Gui=game:GetService('GuiService')
local Audio=require(Rep:WaitForChild('07UI_GAME_AUDIO'));local M={}
function M.Build(parent)
 local T={Players={},Slots={},Generation=0};local N=D.New;local R=Bounds.Rect
 T.Root=N('Frame',{Name='TrucoTableStage',BackgroundTransparency=1,ClipsDescendants=false},parent)
 T.Shadow=D.Frame(T.Root,{Name='TableShadow',BackgroundColor3=Color3.fromRGB(113,140,131),BackgroundTransparency=.12,Active=false,ZIndex=1});D.Round(T.Shadow,180)
 T.Rim=D.Frame(T.Root,{Name='WoodTableRim',BackgroundColor3=Color3.fromRGB(190,163,125),Active=false,ZIndex=2});D.Round(T.Rim,160);Fx.Surface(T.Rim,Color3.fromRGB(218,193,158),Color3.fromRGB(184,154,118),Color3.fromRGB(151,126,94))
 T.Felt=D.Frame(T.Root,{Name='GreenTable',BackgroundColor3=Color3.fromRGB(48,126,96),Active=false,ZIndex=3});D.Round(T.Felt,150);D.Stroke(T.Felt,Color3.fromRGB(124,188,148),.48,2)
 Fx.Surface(T.Felt,Color3.fromRGB(58,143,109),Color3.fromRGB(43,115,91))
 local ring=N('Frame',{Name='TableInlay',Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,1,-24),BackgroundTransparency=1},T.Felt);D.Round(ring,100);D.Stroke(ring,Color3.fromRGB(149,178,125),.75,1)
 local emblem=D.Text(T.Felt,'♠',{Name='FeltEmblem',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.48),Size=UDim2.fromOffset(64,64),TextSize=62,TextColor3=Color3.fromRGB(3,46,26),Active=false,ZIndex=3})
 local center=N('Frame',{Name='FeltCenterLight',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.48,.68),BackgroundColor3=Color3.fromRGB(73,138,94),BackgroundTransparency=.84,BorderSizePixel=0,Active=false},T.Felt);D.Round(center,120)
 for i=1,5 do N('Frame',{Name='FeltThread'..i,Position=UDim2.fromScale(.12,.12+i*.12),Size=UDim2.fromScale(.76,.002),BackgroundColor3=Color3.fromRGB(135,179,138),BackgroundTransparency=.92,BorderSizePixel=0,Active=false},T.Felt)end
 T.Cards=N('Frame',{Name='TrickCards',BackgroundTransparency=1,ZIndex=5},T.Root)
 T.Discard=N('Frame',{Name='DiscardPile',BackgroundTransparency=1,ZIndex=3},T.Root)
 T.DiscardLabel=D.Text(T.Discard,'',{TextColor3=C.muted,TextSize=11,Position=UDim2.fromScale(0,.8),Size=UDim2.fromScale(1,.2),ZIndex=4})
 T.Caption=D.Text(T.Root,'',{TextColor3=Color3.fromRGB(167,223,180),BackgroundColor3=C.panel,BackgroundTransparency=.04,TextSize=12,TextWrapped=false,ZIndex=4});D.Round(T.Caption,5)
 for i=1,4 do
  local p=D.Frame(T.Root,{Name='PlayerSeat'..i,BackgroundTransparency=1,ZIndex=12})
  local thumb=N('ImageLabel',{Name='PlayerAvatar',BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(23,27,34),ScaleType=Enum.ScaleType.Fit,ZIndex=14},p);D.Round(thumb,100);D.Stroke(thumb,Color3.fromRGB(141,181,208),.15,2)
  thumb.ClipsDescendants=true;local fallback=Fx.BotPortrait(thumb,({'Nico','Dante','Lia','Dante'})[i],Color3.fromRGB(66+i*9,96+i*4,121),15);fallback.Size=UDim2.fromScale(1,1);D.Round(fallback,100)
  local relation=D.Text(p,'',{Name='PlayerTeam',TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14})
  local name=D.Text(p,'',{Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=14})
  for _,label in ipairs({relation,name})do label.BackgroundColor3=C.panel;label.BackgroundTransparency=.04;D.Round(label,4)end
  local back=N('Frame',{Name='OpponentHand',BackgroundTransparency=1,ZIndex=4},T.Root)
  T.Players[i]={root=p,thumb=thumb,fallback=fallback,relation=relation,label=name,back=back,cards={}}
 end
 local function clear(p)for _,v in ipairs(p:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end end
 function T.Layout()
  local w,h=T.Root.AbsoluteSize.X,T.Root.AbsoluteSize.Y;if w<1 or h<1 then return end
  local face=math.clamp(h*.18,32,64);local bw=math.clamp(w*.16,80,146);local bh=face+34
  local rx=w*.13;local ry=math.max(18,face*.58);local rw=w*.74;local rh=math.max(60,h*.75)
  R(T.Shadow,rx-3,ry+5,rw+6,rh+4);R(T.Rim,rx,ry,rw,rh);R(T.Felt,rx+9,ry+9,rw-18,rh-18)
  -- UDim radius produces an oval/pill at every screen aspect ratio.
  for _,o in ipairs({T.Shadow,T.Rim,T.Felt})do local corner=o:FindFirstChildOfClass('UICorner');if corner then corner.CornerRadius=UDim.new(.5,0)end end
  local handH=math.clamp(h*.29,58,132);local handW=handH*.7*2.25
  local positions={{math.max(4,w*.5-handW*.5-bw-8),h-bh-2},{w-bw-4,h*.43-bh*.5},{(w-bw)/2,0},{4,h*.43-bh*.5}}
  for i,p in ipairs(T.Players)do
   local pos=positions[i];R(p.root,pos[1],pos[2],bw,bh);R(p.thumb,(bw-face)/2,14,face,face)
   p.thumb.Visible=h>=160;R(p.label,0,0,bw,14);p.label.TextXAlignment=Enum.TextXAlignment.Center;p.label.TextSize=13
   R(p.relation,0,face+16,bw,16);p.relation.Visible=h>=220;p.relation.TextXAlignment=Enum.TextXAlignment.Center;p.relation.TextSize=12
   local ch=math.clamp(h*.16,28,58);local cw=ch*.70;local fanW=cw*1.9
   local x=i==2 and w-bw-fanW-2 or i==4 and bw+6 or(w+bw)/2+8
   local y=i==3 and face*.5+12 or h*.43-ch*.5;R(p.back,x,y,fanW,ch);p.back.Visible=h>=220 and i~=1
   for j,c in ipairs(p.cards)do R(c,(j-1)*cw*.42,math.abs(j-2)*2,cw,ch);c.Rotation=i==2 and -6+(j-1)*6 or i==4 and 6-(j-1)*6 or(j-2)*7 end
  end
  R(T.Cards,0,0,w,h);local handTop=h-handH-3;local ch=math.min(math.clamp(h*.14,28,58),math.max(14,handTop-22));local cw=ch*.70;local slot=math.clamp(w*.085,42,82);local total=slot*4+12
  local placements={{.50,.62},{.64,.535},{.50,.45},{.36,.535}}
  for i,entry in pairs(T.Slots)do
   local pos=placements[i];local cardX=w*pos[1]-cw/2;local cardY=math.min(h*pos[2]-ch/2,handTop-ch-6)
   if h<240 then cardX=w*.5+(i-2.5)*(cw+8)-cw*.5;cardY=math.max(0,handTop-ch-6)end
   R(entry.card,cardX,cardY,cw,ch);entry.card.Rotation=(i-2)*4
   local ownerW=math.max(66,math.min(100,w*.15));R(entry.owner,w*pos[1]-ownerW/2,cardY-17,ownerW,16);entry.owner.TextSize=11;entry.owner.Visible=h>=300
  end
  T.Discard.Visible=h>=230;R(T.Discard,w*.80,h*.67,28,42);T.Caption.Visible=h>=320
  R(T.Caption,w*.27,h*.65,w*.46,18);T.Caption.TextSize=10
  T.HandRect={x=(w-handW)/2,y=h-handH-3,w=handW,h=handH}
 end
 local lastKey;local displayKey;local current;local currentInventory
 local function skin(seat)
  local inv=currentInventory;local mode=inv and inv.view or'mine'
  if mode=='players'then return(current.styles or{})[seat]or{style='Classic'}end
  return{style=mode=='classic'and'Classic'or inv and inv.equipped or'Classic',custom=inv and inv.custom}
 end
 function T.Update(v,inventory)
  current=v;currentInventory=inventory
  for i,p in ipairs(T.Players)do
   local seat=(v.seat+i-2)%4+1;local who=v.players[seat]or{};p.root:SetAttribute('Seat',seat)
   local ally=(seat%2)==(v.seat%2);p.root:SetAttribute('TeamRelation',ally and'ally'or'opponent')
   p.label.Text=seat==v.seat and'Você'or tostring(who.name or'Jogador');p.relation.Text=seat==v.seat and'SUA DUPLA'or ally and'SEU PARCEIRO'or'DUPLA RIVAL';p.relation.TextColor3=ally and Color3.fromRGB(167,223,180)or Color3.fromRGB(206,175,236);p.fallback.Visible=(who.uid or 0)<=0;p.thumb.Image=(who.uid or 0)>0 and('rbxthumb://type=AvatarHeadShot&id='..who.uid..'&w=150&h=150')or''
   local stroke=p.thumb:FindFirstChildOfClass('UIStroke');if stroke then stroke.Color=(seat%2)==(v.seat%2)and Color3.fromRGB(167,223,180)or Color3.fromRGB(206,175,236);stroke.Transparency=v.turn==seat and v.phase=='play'and .12 or .70;stroke.Thickness=v.turn==seat and 2 or 1 end
   clear(p.back);p.cards={};local style=skin(seat)
   if seat~=v.seat then for j=1,(v.counts or{})[seat]or 0 do local c=D.Frame(p.back,{Name='OpponentCard',BackgroundColor3=Color3.fromRGB(30,64,122),ZIndex=4});D.Round(c,4);D.Stroke(c,Color3.fromRGB(211,222,238),.05,1);local motif=D.Text(c,'◆',{Size=UDim2.fromScale(1,1),TextColor3=Color3.fromRGB(93,129,184),TextSize=13,ZIndex=5});p.cards[j]=c end end
  end
  local key=tostring(v.handNumber)..':'..tostring(#v.tricks);local complete=#v.tableCards==0 and #(v.lastTrick or{})>0
  local cards=complete and v.lastTrick or v.tableCards
  if complete and key==lastKey then cards={}end
  local fingerprint=key..':'..tostring(complete)..':'..tostring(v.value)..':'..tostring(inventory and inventory.equipped)..':'..tostring(inventory and inventory.view);for _,c in ipairs(cards)do fingerprint=fingerprint..':'..c.seat..':'..tostring(c.card.rank)..tostring(c.card.suit)end
  if displayKey==fingerprint then T.Layout();return end;displayKey=fingerprint;T.Generation=T.Generation+1;local gen=T.Generation
  local previous=T.Slots;local previousHand=T.HandNumber;T.HandNumber=v.handNumber
  clear(T.Cards);T.Slots={}
  for _,p in ipairs(cards)do local index=(p.seat-v.seat)%4+1;local style=skin(p.seat)
   local who=v.players[p.seat]or{};local ally=(p.seat%2)==(v.seat%2)
   local owner=D.Text(T.Cards,(p.seat==v.seat and'Você'or tostring(who.name or'Jogador'))..(ally and' · dupla'or' · rival'),{Name='PlayedCardOwner',TextColor3=ally and Color3.fromRGB(167,223,180)or Color3.fromRGB(206,175,236),TextSize=12,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=8})
   owner.BackgroundColor3=C.panel;owner.BackgroundTransparency=.04;D.Round(owner,4);owner:SetAttribute('Seat',p.seat);owner:SetAttribute('TeamRelation',ally and'ally'or'opponent')
   T.Slots[index]={card=Cards.Render(T.Cards,p.card,style.style,{ZIndex=5},style.custom),owner=owner}
  end
  T.Caption.Text=v.vira and('Vira '..v.vira.rank..' '..({S='♠',H='♥',D='♦',C='♣'})[v.vira.suit]..' · vale '..v.value)or('Vaza '..math.min(3,#v.tricks+1)..' · vale '..v.value)
  T.DiscardLabel.Text=#v.tricks>0 and(#v.tricks..' vaza(s)')or''
  T.Layout()
  for index,s in pairs(T.Slots)do
   if not complete and(previousHand~=v.handNumber or not previous[index])then
    Audio.Play('move',nil,.13,1.2)
    local target=s.card.Position;local player=T.Players[index];s.card.Position=UDim2.fromOffset(player.root.Position.X.Offset,player.root.Position.Y.Offset)
    Fx.Animate(s.card,{Position=target},.22)
   end
  end
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
