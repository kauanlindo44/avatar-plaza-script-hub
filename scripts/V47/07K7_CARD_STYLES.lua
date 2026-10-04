-- 07K7_CARD_STYLES | ModuleScript | ReplicatedStorage | V47
-- Frente e verso próprios: metal, vitral e gravuras. Rank e naipe nunca ficam cobertos.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local C=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local M={};local symbols={D="♦",S="♠",H="♥",C="♣"}
local ivory=Color3.fromRGB(251,247,236)
local function rgb(v)return Color3.fromRGB(v[1],v[2],v[3])end
local function ornament(parent,s,z,style)
 local accent=rgb(s.colors[2]);local motif=s.motif
 if motif=="grid"then for i=1,6 do
  D.New("Frame",{Position=UDim2.fromScale(i/7,0),Size=UDim2.new(0,2,1,0),BackgroundColor3=accent,BackgroundTransparency=.72,BorderSizePixel=0,ZIndex=z},parent)
  D.New("Frame",{Position=UDim2.fromScale(0,i/7),Size=UDim2.new(1,0,0,2),BackgroundColor3=accent,BackgroundTransparency=.72,BorderSizePixel=0,ZIndex=z},parent)
 end elseif motif=="wings"or motif=="crest"then for side=-1,1,2 do for i=1,4 do
  D.New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5+side*(.14+i*.045),.44+i*.07),Size=UDim2.fromScale(.33-i*.04,.025),Rotation=side*(-35+i*8),BackgroundColor3=accent,BackgroundTransparency=.25,BorderSizePixel=0,ZIndex=z},parent)
 end end end
 for i=1,5 do
  local orbit=motif=="orbit";local diamond=motif=="diamond"or motif=="crest"
  local f=D.New("Frame",{Name="Engraving"..i,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
   Size=UDim2.fromScale(.22+i*.13,.16+i*.14),BackgroundTransparency=1,BorderSizePixel=0,
   Rotation=diamond and 45 or orbit and i*16 or motif=="grid"and 0 or i*8,ZIndex=z},parent)
  D.Round(f,orbit and 100 or motif=="grid"and 2 or 6);D.Stroke(f,accent,.35+i*.07,style=="Classic"and 1 or 2)
 end
 for _,x in ipairs({.03,.97})do
  D.New("Frame",{Position=UDim2.fromScale(x,.04),Size=UDim2.fromScale(.012,.92),BackgroundColor3=accent,BackgroundTransparency=.18,BorderSizePixel=0,ZIndex=z},parent)
 end
 if motif=="crown"then
  for i=1,5 do D.New("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.fromScale(.22+i*.09,.55),Size=UDim2.fromScale(.065,i%2==1 and .24 or .17),Rotation=(i-3)*8,BackgroundColor3=accent,BorderSizePixel=0,ZIndex=z},parent)end
 elseif motif=="star"then
  for i=1,8 do D.New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.72,.016),Rotation=i*22.5,BackgroundColor3=accent,BackgroundTransparency=.35,BorderSizePixel=0,ZIndex=z},parent)end
 elseif style=="Zenith"then
  for i=1,16 do local f=D.New("Frame",{Position=UDim2.fromScale(.10+(i*37%79)/100,.1+(i*23%79)/100),Size=UDim2.fromOffset(i%3+2,i%3+2),BackgroundColor3=accent,BorderSizePixel=0,ZIndex=z},parent);D.Round(f,10)end
 elseif style=="Vesper"then
  for i=1,8 do D.New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.48,.006),Rotation=i*45,BackgroundColor3=ivory,BackgroundTransparency=.35,BorderSizePixel=0,ZIndex=z},parent)end
 end
end
function M.Render(parent,card,style,props,custom)
 local s=C.Styles[style]or C.Styles.Zenith;props=props or{}
 props.Name=props.Name or"PlayingCard";props.BackgroundColor3=rgb(s.colors[1]);props.BorderSizePixel=0;props.ClipsDescendants=true
 local root=D.New("Frame",props,parent);D.Round(root,12);D.Stroke(root,rgb(s.colors[2]),.06,2)
 root:SetAttribute("CardStyle",style);root:SetAttribute("FaceIdentityProtected",true)
 local z=root.ZIndex+1;local base,accent=rgb(s.colors[1]),rgb(s.colors[2])
 D.New("UIGradient",{Rotation=style=="Hex"and 135 or 55,Color=ColorSequence.new({
  ColorSequenceKeypoint.new(0,base:Lerp(accent,.28)),ColorSequenceKeypoint.new(.45,base),ColorSequenceKeypoint.new(1,base:Lerp(accent,.20))})},root)
 ornament(root,s,z,style)
 local face=card and not card.hidden and not card.covered
 if style=="Custom"and custom and tonumber(custom.image)and custom.image>0 then
  local zoom=math.clamp(custom.zoom or 1,1,2)
  D.New("ImageLabel",{Name="CustomArtwork",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5+(custom.x or 0),.5+(custom.y or 0)),
   Size=UDim2.fromScale(zoom,zoom),BackgroundTransparency=1,Image=custom.thumb and("rbxthumb://type=Asset&id="..custom.image.."&w=420&h=420")or("rbxassetid://"..((tonumber(custom.texture)or 0)>0 and custom.texture or custom.image)),ImageColor3=Color3.new(1,1,1),ScaleType=Enum.ScaleType.Crop,Active=false,ZIndex=z+1},root)
 end
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
   Size=UDim2.fromScale(.61,.41),BackgroundColor3=ivory,BorderSizePixel=0,ZIndex=z+3},panel)
  D.Round(medallion,style=="Hex"and 4 or 100);D.Stroke(medallion,accent,0,2)
  D.Text(medallion,symbol,{Name="Suit",Size=UDim2.fromScale(1,.9),TextScaled=true,TextColor3=color,Font=Enum.Font.GothamBold,ZIndex=z+4})
  D.Text(panel,rank,{Name="FaceRank",Position=UDim2.fromScale(.31,.73),Size=UDim2.fromScale(.38,.16),TextScaled=true,TextColor3=style=="Classic"and color or accent,Font=Enum.Font.GothamBold,ZIndex=z+4})
  local count=tonumber(rank)
  if count and count>=2 and count<=7 and style~="Custom"then
   medallion.Visible=false;local pair=math.floor(count/2)
   for i=1,pair*2 do local row=math.floor((i-1)/2);local x=i%2==1 and .37 or .63;local y=pair==1 and .48 or .28+row*.40/(pair-1)
    local pip=D.New("Frame",{Name="SuitPip"..i,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(.19,.13),BackgroundColor3=ivory,BorderSizePixel=0,ZIndex=z+3},panel);D.Round(pip,5)
    D.Text(pip,symbol,{Size=UDim2.fromScale(1,1),TextScaled=true,TextColor3=color,Font=Enum.Font.GothamBold,ZIndex=z+4})
   end
   if count%2==1 then local pip=D.New("Frame",{Name="OddSuitPip",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.48),Size=UDim2.fromScale(.18,.13),BackgroundColor3=ivory,BorderSizePixel=0,ZIndex=z+3},panel);D.Round(pip,5);D.Text(pip,symbol,{Size=UDim2.fromScale(1,1),TextScaled=true,TextColor3=color,ZIndex=z+4})end
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
 return root
end
function M.RenderBox(parent,key,props)
 local box=C.Collection(key)or C.Collections[1];local s=C.Styles[box.skins[1]];props=props or{}
 props.Name="CollectionBox";props.BackgroundTransparency=1;props.ClipsDescendants=false
 local root=D.New("Frame",props,parent);local z=root.ZIndex+1;local base,accent=rgb(s.colors[1]),rgb(s.colors[2])
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
 local s=C.Styles[style]or C.Styles.Zenith;part.Color=rgb(s.colors[1])
 local glass=style=="Vesper"or style=="Zenith"
 part.Material=style=="Classic"and Enum.Material.SmoothPlastic or glass and Enum.Material.Glass or Enum.Material.Metal
 part.Reflectance=style=="Classic"and 0 or .12
 local gui=Instance.new("SurfaceGui");gui.Name="ACP_CardFace";gui.Face=face or Enum.NormalId.Top
 gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(280,400);gui.LightInfluence=0;gui.Parent=part
 M.Render(gui,card,style,{Size=UDim2.fromScale(1,1)},custom);return gui
end
return M
