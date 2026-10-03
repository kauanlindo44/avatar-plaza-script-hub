-- 07K7_CARD_STYLES | ModuleScript | ReplicatedStorage | V44
-- Arte geométrica original; identidade da carta permanece legível em todos os visuais.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local C=require(Rep:WaitForChild("07K6_CARD_CATALOG"))
local M={};local symbols={D="♦",S="♠",H="♥",C="♣"}
local function rgb(v)return Color3.fromRGB(v[1],v[2],v[3])end
function M.Render(parent,card,style,props,custom)
 local s=C.Styles[style]or C.Styles.Zenith;props=props or{}
 props.Name=props.Name or"PlayingCard";props.BackgroundColor3=rgb(s.colors[1]);props.BorderSizePixel=0;props.ClipsDescendants=true
 local root=D.New("Frame",props,parent);D.Round(root,8);D.Stroke(root,rgb(s.colors[2]),.08,2)
 local z=root.ZIndex+1
 if style=="Custom"and custom and custom.image and custom.image>0 then
  local zoom=math.clamp(custom.zoom or 1,1,2)
  D.New("ImageLabel",{Name="CustomArtwork",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5+(custom.x or 0),.5+(custom.y or 0)),
   Size=UDim2.fromScale(zoom,zoom),BackgroundTransparency=1,Image="rbxassetid://"..custom.image,ScaleType=Enum.ScaleType.Crop,ZIndex=z},root)
 else
  for i=1,9 do
   local orbit=s.motif=="orbit";local diamond=s.motif=="diamond"or s.motif=="crest"
   local f=D.New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.16+i*.06,.11+i*.065),
    BackgroundTransparency=1,BorderSizePixel=0,Rotation=diamond and 45 or orbit and i*13 or i%2==0 and 0 or 25,ZIndex=z},root)
   D.Round(f,orbit and 100 or 3);D.Stroke(f,rgb(s.colors[2]),.30+i*.055,1)
  end
  D.Text(root,s.motif=="crown"and"♛"or s.motif=="wings"and"✦"or s.motif=="star"and"✧"or"◇",{
   AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.64,.55),TextScaled=true,
   TextColor3=rgb(s.colors[2]),Font=Enum.Font.GothamBold,ZIndex=z+1})
 end
 if card and not card.hidden and not card.covered then
  local face=D.New("Frame",{Name="CardFace",Position=UDim2.fromScale(.07,.05),Size=UDim2.fromScale(.86,.90),BackgroundColor3=Color3.fromRGB(247,244,232),BorderSizePixel=0,ZIndex=z+2},root);D.Round(face,6)
  local color=(card.suit=="D"or card.suit=="H")and Color3.fromRGB(163,38,60)or Color3.fromRGB(25,33,44)
  local symbol=symbols[card.suit]or"?";local rank=tostring(card.rank or"?")
  D.Text(face,rank.."\n"..symbol,{Position=UDim2.fromScale(.04,.02),Size=UDim2.fromScale(.30,.32),TextScaled=true,TextColor3=color,ZIndex=z+3})
  D.Text(face,symbol,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.53),Size=UDim2.fromScale(.64,.55),TextScaled=true,TextColor3=color,ZIndex=z+3})
  D.Text(face,rank.."\n"..symbol,{AnchorPoint=Vector2.new(1,1),Position=UDim2.fromScale(.96,.98),Size=UDim2.fromScale(.30,.32),Rotation=180,TextScaled=true,TextColor3=color,ZIndex=z+3})
 end
 return root
end
function M.Surface(part,card,style,custom)
 local gui=Instance.new("SurfaceGui");gui.Name="ACP_CardFace";gui.Face=Enum.NormalId.Top;gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(280,400);gui.LightInfluence=0;gui.Parent=part
 M.Render(gui,card,style,{Size=UDim2.fromScale(1,1)},custom);return gui
end
return M
