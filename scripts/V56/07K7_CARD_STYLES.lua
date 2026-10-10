-- 07K7_CARD_STYLES | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Frente de papel e temas em gravura; verso temático. Rank e naipe nunca ficam cobertos.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local C=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local M={};local symbols={D="♦",S="♠",H="♥",C="♣"}
local ivory=Color3.fromRGB(251,247,236)
local function rgb(v)return Color3.fromRGB(v[1],v[2],v[3])end
local function ornament(parent,s,z,style)
 local accent=rgb(s.colors[2]);local base=rgb(s.colors[1])
 local function bar(name,x,y,w,h,angle,color,alpha)
  return D.New("Frame",{Name=name,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(w,h),Rotation=angle or 0,BackgroundColor3=color or accent,BackgroundTransparency=alpha or 0,BorderSizePixel=0,Active=false,ZIndex=z},parent)
 end
 local function ring(name,x,y,w,h,thickness)
  local f=bar(name,x,y,w,h,0,accent,1);D.Round(f,100);D.Stroke(f,accent,.20,thickness or 2);return f
 end
 local border=bar("FoilBorder",.5,.5,.90,.94,0,accent,1);D.Round(border,8);D.Stroke(border,accent,.25,1)
 if style=="Classic"then return end
 parent:SetAttribute("EditionArtwork",style)
 if style=="Onyx"then
  for i=1,5 do bar("OnyxEngraving",.5,.16+i*.11,.84,.006,0,accent,.68)end
  for _,x in ipairs({.08,.92})do bar("OnyxRail",x,.5,.012,.82,0,accent,.25)end
  local crest=bar("OnyxCrest",.5,.5,.36,.25,45,accent,1);D.Stroke(crest,accent,.28,1)
 elseif style=="Vesper"then
  for i=1,4 do ring("AstralOrbit",.5,.5,.20+i*.17,.12+i*.19,1)end
  local moon=bar("VeyraMoon",.5,.35,.37,.25,0,accent,.12);D.Round(moon,100)
  local eclipse=bar("MoonShadow",.59,.31,.34,.24,0,base,0);D.Round(eclipse,100)
 elseif style=="Salem"then
  for _,x in ipairs({.18,.82})do for _,y in ipairs({.22,.78})do
   for _,dx in ipairs({-.038,0,.038})do local pumpkin=bar("SalemPumpkin",x+dx,y,.105,.14,0,Color3.fromRGB(218,131,57),.12);D.Round(pumpkin,100)end
   bar("PumpkinStem",x,y-.09,.025,.045,-12,Color3.fromRGB(63,93,60),.12)
   for _,side in ipairs({-.037,.037})do bar('PumpkinEye',x+side,y-.012,.023,.018,45,Color3.fromRGB(76,45,33),0)end
   bar('PumpkinSmile',x,y+.030,.070,.012,0,Color3.fromRGB(76,45,33),0)
  end end
  for i=1,5 do local x=i%2==0 and .10 or .90;local y=.18+i*.10
   bar("AutumnVine",x,y,.10,.008,i%2==0 and 25 or -25,accent,.50);local leaf=bar('SalemLeaf',x,y,.044,.036,45,accent,.34);D.Round(leaf,30)
  end
 elseif style=="Hex"then
  for _,x in ipairs({.14,.86})do
   bar('BotanicalStem',x,.5,.008,.76,0,accent,.50)
   for i=1,6 do local leaf=bar('JadeLeaf',x+(i%2==0 and .04 or-.04),.12+i*.11,.12,.033,i%2==0 and-35 or 35,accent,.32);D.Round(leaf,30)end
  end
 elseif style=="Regent"then
  for i=1,7 do bar("RegalRay",.5,.42,.65,.017,(i-4)*16,accent,.45)end
  for i=1,5 do bar("CrownPoint",.23+i*.09,.35,.075,.20-math.abs(i-3)*.03,(i-3)*9,accent,.05)end
  bar("RoyalBase",.5,.44,.53,.035,0,accent,.05)
 elseif style=="Aurum"then
  for i=1,12 do bar("DecoSunray",.5,.5,.80,.008,i*15,accent,.58)end
  for i=1,3 do local f=bar("DecoFrame",.5,.5,.45+i*.12,.40+i*.15,45,accent,1);D.Stroke(f,accent,.2,2)end
 elseif style=="Valor"then
  for side=-1,1,2 do for i=1,5 do bar("ShieldPlume",.5+side*(.12+i*.045),.34+i*.065,.30-i*.025,.027,side*(-35+i*6),accent,.18)end end
  local shield=bar("ValorShield",.5,.5,.44,.35,45,accent,.16);D.Round(shield,6)
 elseif style=="Zenith"then
  for i=1,5 do ring("CelestialLens",.5,.5,.18+i*.14,.11+i*.16,1)end
  for i=1,18 do local f=bar("ZenithStar",.08+(i*37%85)/100,.08+(i*29%85)/100,.017+i%3*.01,.011+i%3*.006,45,accent,.05);D.Round(f,4)end
 elseif style=="Aether"then
  for side=-1,1,2 do for i=1,8 do bar("VaelisFeather",.5+side*(.05+i*.033),.30+i*.05,.29-i*.012,.022,side*(-50+i*5),accent,.14+i*.04)end end
  ring("VaelisHalo",.5,.29,.25,.15,2)
 elseif style=="Nova"then
  for i=1,16 do bar("NovaBurst",.5,.5,.72,.009,i*22.5,accent,.70)end
  for i=1,5 do bar("SolarHorizon",.5,.48+i*.055,.70-i*.045,.018,0,accent,.15+i*.08)end
 end
 for _,p in ipairs({{.08,.08},{.92,.08},{.08,.92},{.92,.92}})do bar("CornerGem",p[1],p[2],.03,.021,45,ivory,.15)end
end
function M.Render(parent,card,style,props,custom)
 local s=C.Styles[style]or C.Styles.Classic;props=props or{}
 local showing=card and not card.hidden and not card.covered
 if not showing and style~="Custom"then local copy={colors={{35,39,48},s.colors[2]}};s=copy end
 props.Name=props.Name or"PlayingCard";props.BackgroundColor3=rgb(s.colors[1]);props.BorderSizePixel=0;props.ClipsDescendants=true
 local root=D.New("Frame",props,parent);D.Round(root,12);D.Stroke(root,rgb(s.colors[2]),.06,2)
 root:SetAttribute('V56_PreserveArt',true);root:SetAttribute("ArtworkVersion","V56");root:SetAttribute("TraditionalPaperFace",showing==true)
 root:SetAttribute("CardStyle",style);root:SetAttribute("FaceIdentityProtected",true)
 local z=root.ZIndex+1;local base,accent=rgb(s.colors[1]),rgb(s.colors[2])
 D.New("UIGradient",{Rotation=style=="Hex"and 135 or 55,Color=ColorSequence.new({
  ColorSequenceKeypoint.new(0,base:Lerp(accent,.28)),ColorSequenceKeypoint.new(.45,base),ColorSequenceKeypoint.new(1,base:Lerp(accent,.20))})},root)
 ornament(root,s,z,style)
 local face=card and not card.hidden and not card.covered
 if style=="Custom"and custom and tonumber(custom.image)and custom.image>0 then
  local zoom=math.clamp(custom.zoom or 1,1,4)
  D.New("ImageLabel",{Name="CustomArtwork",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5+(custom.x or 0),.5+(custom.y or 0)),
   Size=UDim2.fromScale(zoom,zoom),BackgroundTransparency=1,Image=custom.thumb and("rbxthumb://type=Asset&id="..custom.image.."&w=420&h=420")or("rbxassetid://"..((tonumber(custom.texture)or 0)>0 and custom.texture or custom.image)),Rotation=custom.rotation or 0,ImageColor3=Color3.new(custom.brightness or 1,custom.brightness or 1,custom.brightness or 1),ScaleType=Enum.ScaleType.Crop,Active=false,ZIndex=z+1},root)
 end
 local art=root:FindFirstChild("CustomArtwork")
 if art and custom.layout=="Inset"then art.Size=UDim2.fromScale(.76*(custom.zoom or 1),.66*(custom.zoom or 1));D.Round(art,8)
 elseif art and custom.layout=="Banner"then art.Size=UDim2.fromScale(custom.zoom or 1,.54*(custom.zoom or 1))end
 if face then
  local panel=D.New("Frame",{Name="CardFace",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=z+2},root)
  local color=(card.suit=="D"or card.suit=="H")and Color3.fromRGB(174,29,53)or Color3.fromRGB(22,30,43)
  local symbol=symbols[card.suit]or"?";local rank=tostring(card.rank or"?")
  for i,p in ipairs({{.03,.025,0},{.97,.975,180}})do
   local tag=D.New("Frame",{Name="IdentityCorner"..i,AnchorPoint=Vector2.new(i==1 and 0 or 1,i==1 and 0 or 1),
    Position=UDim2.fromScale(p[1],p[2]),Size=UDim2.fromScale(.29,.28),BackgroundColor3=ivory,BorderSizePixel=0,Rotation=p[3],ZIndex=z+5},panel);D.Round(tag,5)
   D.Text(tag,rank.."\n"..symbol,{Name="RankAndSuit",Size=UDim2.fromScale(1,1),TextScaled=true,Font=Enum.Font.GothamBold,TextColor3=color,ZIndex=z+6})
  end
  local medallion=D.New("Frame",{Name="SuitMedallion",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
   Size=UDim2.fromScale(.61,.41),BackgroundColor3=ivory,BackgroundTransparency=.03,BorderSizePixel=0,ZIndex=z+3},panel)
  D.Round(medallion,style=="Hex"and 4 or 100);D.Stroke(medallion,accent,0,2)
  D.Text(medallion,symbol,{Name="Suit",Size=UDim2.fromScale(1,.9),TextScaled=true,TextColor3=color,Font=Enum.Font.GothamBold,ZIndex=z+4})
  D.Text(panel,rank,{Name="FaceRank",Position=UDim2.fromScale(.31,.73),Size=UDim2.fromScale(.38,.16),TextScaled=true,TextColor3=style=="Classic"and color or accent,Font=Enum.Font.GothamBold,ZIndex=z+4})
  local count=tonumber(rank)
  if count and count>=2 and count<=10 and style~="Custom"then
   medallion.Visible=false;panel.FaceRank.Visible=false
   local field=D.New("Frame",{Name="PipField",Position=UDim2.fromScale(.21,.24),Size=UDim2.fromScale(.58,.53),BackgroundColor3=ivory,BackgroundTransparency=.04,BorderSizePixel=0,ZIndex=z+3},panel);D.Round(field,8);D.Stroke(field,accent,.35,1)
   local pair=math.floor(count/2)
   for i=1,pair*2 do local row=math.floor((i-1)/2);local x=i%2==1 and .28 or .72;local y=pair==1 and .5 or .15+row*.70/(pair-1)
    D.Text(field,symbol,{Name="SuitPip"..i,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(.30,.20),BackgroundTransparency=1,TextScaled=true,TextColor3=color,Font=Enum.Font.GothamBold,ZIndex=z+4})
   end
   if count%2==1 then D.Text(field,symbol,{Name="OddSuitPip",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.28,.20),TextScaled=true,TextColor3=color,ZIndex=z+4})end
  elseif style~="Custom"and(rank=="K"or rank=="Q"or rank=="J")then
   medallion.Position=UDim2.fromScale(.5,.56);medallion.Size=UDim2.fromScale(.5,.29)
   D.Text(panel,rank=="K"and"♛"or rank=="Q"and"♕"or"⚜",{Name="CourtPortrait",Position=UDim2.fromScale(.25,.22),Size=UDim2.fromScale(.5,.27),TextScaled=true,TextColor3=accent,Font=Enum.Font.GothamBold,ZIndex=z+4})
  end
  if style=="Custom"then medallion.Size=UDim2.fromScale(.28,.19);medallion.Position=UDim2.fromScale(.5,.86);panel.FaceRank.Visible=false end
  root:SetAttribute("Suit",card.suit);root:SetAttribute("Rank",rank)
 else
  local seal=style=="Regent"and"♛"or style=="Aether"and"✦"or style=="Nova"and"✧"or style=="Valor"and"⚜"or"◇"
  if style~="Custom"then D.Text(root,seal,{Name="DeckSeal",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.65,.55),TextScaled=true,TextColor3=accent,Font=Enum.Font.GothamBold,ZIndex=z+2})end
 end
 local function readable()
  local face=root:FindFirstChild("CardFace");if not face then return end
  local small=root.AbsoluteSize.X<48;local corner=face:FindFirstChild("IdentityCorner1")
  if corner then corner.Size=small and UDim2.fromScale(.82,.84)or UDim2.fromScale(.29,.28);corner.Position=small and UDim2.fromScale(.09,.08)or UDim2.fromScale(.03,.025)end
  for _,key in ipairs({"IdentityCorner2","PipField","SuitMedallion","CourtPortrait","FaceRank"})do local o=face:FindFirstChild(key)
   if o then if o:GetAttribute("NormalVisible")==nil then o:SetAttribute("NormalVisible",o.Visible)end;o.Visible=not small and o:GetAttribute("NormalVisible")end
  end
 end
 root:GetPropertyChangedSignal("AbsoluteSize"):Connect(readable);readable()
 return root
end
function M.RenderBox(parent,key,props)
 local box=C.Collection(key)or C.Collections[1];local s=C.Styles[box.skins[1]];props=props or{}
 props.Name="CollectionBox";props.BackgroundTransparency=1;props.ClipsDescendants=false
 local root=D.New("Frame",props,parent);local z=root.ZIndex+1;local base,accent=rgb(s.colors[1]),rgb(s.colors[2])
 root:SetAttribute('V56_PreserveArt',true)
 root:SetAttribute("IsCollectionBox",true);root:SetAttribute("Collection",box.id)
 local shadow=D.New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.89),Size=UDim2.fromScale(.84,.12),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.55,BorderSizePixel=0,ZIndex=z},root);D.Round(shadow,30)
 local body=D.Frame(root,{Name="BoxBody",Position=UDim2.fromScale(.10,.31),Size=UDim2.fromScale(.80,.55),BackgroundColor3=base,ZIndex=z+1});D.Stroke(body,accent,.12,2)
 D.New("UIGradient",{Color=ColorSequence.new(base:Lerp(accent,.28),base),Rotation=40},body)
 local side=D.Frame(root,{Position=UDim2.fromScale(.76,.26),Size=UDim2.fromScale(.15,.54),BackgroundColor3=base:Lerp(Color3.new(0,0,0),.30),Rotation=-4,ZIndex=z+1})
 D.Stroke(side,accent,.3,1)
 local lid=D.Frame(root,{Name="BoxLid",Position=UDim2.fromScale(.065,.23),Size=UDim2.fromScale(.86,.15),BackgroundColor3=accent:Lerp(base,.46),ZIndex=z+3});D.Stroke(lid,accent,.05,2)
 D.New("Frame",{Position=UDim2.fromScale(.475,.04),Size=UDim2.fromScale(.055,.82),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=z+4},root)
 local seal=D.Frame(root,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.50),Size=UDim2.fromScale(.18,.22),BackgroundColor3=base,Rotation=45,ZIndex=z+5});D.Stroke(seal,accent,0,2)
 D.Text(root,"CAIXA",{Position=UDim2.fromScale(.15,.63),Size=UDim2.fromScale(.70,.14),TextScaled=true,TextColor3=accent,Font=Enum.Font.GothamBold,Active=false,ZIndex=z+6})
 for i=1,3 do
  local chip=D.Frame(root,{Position=UDim2.fromScale(.16+(i-1)*.25,.08),Size=UDim2.fromScale(.18,.10),BackgroundColor3=rgb(C.Styles[box.skins[i]].colors[2]),Rotation=(i-2)*8,ZIndex=z})
  D.New("Frame",{Position=UDim2.fromScale(.10,.43),Size=UDim2.fromScale(.8,.08),BackgroundColor3=base,BorderSizePixel=0,ZIndex=z+1},chip)
 end
 return root
end
function M.Surface(part,card,style,custom,face)
 local s=C.Styles[style]or C.Styles.Classic;part.Color=rgb(s.colors[1])
 local glass=style=="Vesper"or style=="Zenith"
 part.Material=Enum.Material.SmoothPlastic
 part.Reflectance=0
 local gui=Instance.new("SurfaceGui");gui.Name="ACP_CardFace";gui.Face=face or Enum.NormalId.Top
 gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(280,400);gui.LightInfluence=0;gui.Parent=part
 M.Render(gui,card,style,{Size=UDim2.fromScale(1,1)},custom);return gui
end
return M
