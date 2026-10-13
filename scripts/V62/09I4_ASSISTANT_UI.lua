-- 09I4_ASSISTANT_UI | ModuleScript | ReplicatedStorage | V62 (SUBSTITUIR)
-- Conversa principal, menu recolhível, criação guiada na conversa e teclado móvel.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local UIS=game:GetService('UserInputService')
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=D.Colors;local M={Version='V62'}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Assistant');if old then old:Destroy()end
 local U={Tab='Conversa',Cards={},MenuOpen=false,Available=false,Language='pt'};local order=1
 U.Gui=D.New('ScreenGui',{Name='ACP_Assistant',ResetOnSpawn=false,DisplayOrder=185,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.New('Frame',{Name='AssistantRoot',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.bg},U.Gui)
 Fx.Surface(U.Root,Color3.fromRGB(20,22,30),Color3.fromRGB(44,30,52),Color3.fromRGB(168,130,226))
 U.Sponsor=D.Button(U.Root,'Patrocinar',{Name='SponsorTab',TextSize=12,ZIndex=80})
 U.Title=D.Text(U.Root,'Estúdio de looks',{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Plan=D.Text(U.Root,'Conectando…',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
 U.Close=D.IconButton(U.Root,'CloseAssistant','close','Fechar IA',{ZIndex=80})
 U.Menu=D.IconButton(U.Root,'AssistantMenu','menu','Abrir menu',{ZIndex=80})
 U.Tabs=D.Frame(U.Root,{Name='AssistantSidebar',BackgroundColor3=C.panel,Visible=false,ZIndex=55});U.TabButtons={}
 U.NewChat=D.Button(U.Tabs,'+ Nova conversa',{Name='NewConversation',TextSize=13,ZIndex=56,BackgroundColor3=C.soft})
 local names={Conversa='Conversa',Looks='Últimos looks',Salvos='Looks salvos',Perfil='Minha conta e preferências'}
 for _,name in ipairs({'Conversa','Looks','Salvos','Perfil'})do U.TabButtons[name]=D.Button(U.Tabs,names[name],{TextSize=13,ZIndex=56})end
 U.SideHint=D.Text(U.Tabs,'Crie, experimente e guarde.\nCada pessoa usa sua própria conta Roblox.',{TextColor3=C.muted,TextSize=12,ZIndex=56})
 U.Body=D.New('Frame',{Name='AssistantBody',BackgroundTransparency=1},U.Root)
 U.Chat=D.Scroll(U.Body,{Name='PrivateConversation',Size=UDim2.fromScale(1,1),ScrollBarThickness=3})
 U.ChatList=D.New('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},U.Chat)
 U.Welcome=D.New('Frame',{Name='AssistantWelcome',Size=UDim2.new(1,-6,0,178),BackgroundColor3=Color3.fromRGB(40,33,49),BackgroundTransparency=.1,LayoutOrder=0},U.Chat)
 D.Round(U.Welcome,16);D.Stroke(U.Welcome,Color3.fromRGB(170,128,213),.66,1)
 U.Heading=D.Text(U.Welcome,'Qual look vamos criar?',{Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,0,40),Font=Enum.Font.GothamBold,TextSize=25})
 U.Intro=D.Text(U.Welcome,'Peças reais, orçamento definido e prévia antes de aplicar.',{Position=UDim2.fromOffset(4,46),Size=UDim2.new(1,-8,0,26),TextSize=13,TextColor3=C.muted})
 U.Suggestions={}
 for i,entry in ipairs({{'Look emo','Quero um look emo'},{'Look grátis','Quero um look grátis'},{'Halloween','Quero um look Halloween'},{'Ajuda com o jogo','Como usar Photo Mode?'}})do
  local b=D.Button(U.Welcome,entry[1],{TextSize=13});U.Suggestions[i]=b
  Fx.Button(b,i==3 and C.orange or Color3.fromRGB(161,133,216))
  b.Activated:Connect(function()U.Input.Text=entry[2];if U.OnSuggest then U.OnSuggest(i~=4)end end)
 end
 U.Results=D.New('Frame',{Name='GeneratedLooks',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Saved=D.New('Frame',{Name='SavedCollections',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Profile=D.Scroll(U.Body,{Name='AssistantProfile',Size=UDim2.fromScale(1,1),Visible=false,ScrollBarThickness=3})
 U.ProfileList=D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Profile)
 U.Composer=D.Frame(U.Root,{Name='MessageComposer',BackgroundColor3=C.panel})
 Fx.Surface(U.Composer,Color3.fromRGB(41,35,49),Color3.fromRGB(26,29,39),C.orange)
 U.Input=D.Box(U.Composer,'Descreva seu look…',{TextSize=14,MultiLine=true,TextWrapped=true})
 U.Input.TextWrapped=true
 U.Send=D.IconButton(U.Composer,'SendMessage','send','Enviar pedido',{BackgroundColor3=C.orange,TextColor3=C.bg})
 U.Make=D.Button(U.Root,'Criar look',{TextSize=12});U.Help=D.Button(U.Root,'Pedir ajuda',{TextSize=12})
 U.Notice=D.Text(U.Root,'',{TextSize=11,TextColor3=C.muted,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left})
 U.Progress=D.Text(U.Chat,'',{Name='AssistantProgress',Size=UDim2.new(1,-6,0,44),TextSize=13,TextColor3=C.orange,Visible=false,LayoutOrder=999998})
 U.Connection=D.Button(U.Root,'Recarregar IA',{TextSize=12,Visible=false})
 local safe=Bounds.Bind(U.Gui)
 function U.NextOrder()order=order+1;return order end
 function U.ScrollBottom()
  task.defer(function()U.Chat.CanvasPosition=Vector2.new(0,math.max(0,U.Chat.AbsoluteCanvasSize.Y-U.Chat.AbsoluteWindowSize.Y))end)
 end
 function U.Add(value,user)
  U.Welcome.Visible=false
  local host=D.New('Frame',{Name=user and'YourMessageRow'or'AIResponseRow',Size=UDim2.new(1,-6,0,90),BackgroundTransparency=1,LayoutOrder=U.NextOrder()},U.Chat)
  local block=D.Frame(host,{Name=user and'YourMessage'or'AIResponse',AnchorPoint=Vector2.new(user and 1 or 0,0),Position=UDim2.fromScale(user and 1 or 0,0),Size=UDim2.new(user and .78 or 1,0,1,0),BackgroundColor3=user and C.soft or C.panel})
  D.Stroke(block,user and C.orange or Color3.fromRGB(162,130,219),.75,1)
  local label=D.Text(block,value,{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-24,0,56),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
  D.Text(block,user and'Você'or(U.Language=='en'and'IA de looks'or'Assistente de looks'),{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,20),TextSize=11,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  local function fit()local h=math.max(40,label.TextBounds.Y+10);label.Size=UDim2.new(1,-24,0,h);host.Size=UDim2.new(1,-6,0,h+34)end
  label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit);U.ScrollBottom();return block
 end
 function U.ClearConversation()
  for _,o in ipairs(U.Chat:GetChildren())do if o:IsA('GuiObject')and o~=U.Welcome and o~=U.Progress then o:Destroy()end end
  order=1;U.Welcome.Visible=true;U.Progress.Visible=false;U.Chat.CanvasPosition=Vector2.new(0,0)
 end
 function U.Ad(block,data,onOpen)
  if not data or data.hidden then return end
  local box=D.Frame(U.Chat,{Name='FirstPartyAdvertisement',Size=UDim2.new(1,-6,0,74),LayoutOrder=U.NextOrder(),BackgroundColor3=C.panel})
  D.New('ImageLabel',{Position=UDim2.fromOffset(6,6),Size=UDim2.fromOffset(62,62),BackgroundTransparency=1,Image='rbxthumb://type=Asset&id='..data.id..'&w=150&h=150',ScaleType=Enum.ScaleType.Fit},box)
  D.Text(box,data.label,{Position=UDim2.fromOffset(78,4),Size=UDim2.new(1,-150,0,20),TextSize=11,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  D.Text(box,data.name,{Position=UDim2.fromOffset(78,25),Size=UDim2.new(1,-150,0,44),TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
  D.Button(box,'Ver',{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.fromOffset(60,44),TextSize=13}).Activated:Connect(onOpen)
 end
 function U.Health(plan,available,checking)
  U.Available=available==true;U.Plan.Text=tostring(plan or'Normal')..' • '..(checking and'conectando'or available and'verificada'or'indisponível')
  U.Plan.TextColor3=available and C.green or checking and C.muted or C.orange
  U.Plan.Visible=available or checking
  U.Connection.Visible=not available and not checking;U.Layout()
 end
 function U.Select(name)
  U.Tab=name;U.Chat.Visible=name=='Conversa';U.Results.Visible=name=='Looks';U.Saved.Visible=name=='Salvos';U.Profile.Visible=name=='Perfil'
  for key,b in pairs(U.TabButtons)do b.BackgroundColor3=key==name and C.orange or C.card;b.TextColor3=key==name and C.bg or C.white end
  U.MenuOpen=false;U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<=0 or h<=0 then return end;local aw=w-il-ir
  local y=it+4;local bar=safe.Topbar();local headerX=il+6
  if aw>=640 and bar.Right-bar.X>=380 and bar.Bottom-bar.Y>=48 then y=bar.Y+4;headerX=bar.X+6 end
  local closeX=w-ir-54;local retryHeader=U.Connection.Visible and closeX-headerX>=430
  local rightStart=retryHeader and closeX-132 or closeX
  Bounds.Rect(U.Menu,headerX,y,44,44);Bounds.Rect(U.Title,headerX+52,y,math.max(60,rightStart-headerX-60),44)
  Bounds.Rect(U.Close,closeX,y,48,48);Bounds.Rect(U.Plan,closeX-126,y,118,44)
  local top=math.max(it+4,y+50);local bottom=h-ib
  local ok,visible,pos=pcall(function()return UIS.OnScreenKeyboardVisible,UIS.OnScreenKeyboardPosition end)
  local keyboard=ok and visible and pos and pos.Y>top+80
  if keyboard then bottom=math.min(bottom,pos.Y-4)end
  local chat=U.Tab=='Conversa';local side=aw>=1100 and w>h
  U.Tabs.Visible=side or U.MenuOpen;local sw=math.min(208,aw-16)
  local sideH=math.max(104,bottom-top-8);Bounds.Rect(U.Tabs,il+6,top,sw,sideH);local sideCols=sideH<216 and 2 or 1
  local bw=(sw-16-(sideCols-1)*6)/sideCols
  local buttons={U.NewChat,U.TabButtons.Conversa,U.TabButtons.Looks,U.TabButtons.Salvos,U.TabButtons.Perfil}
  for i,b in ipairs(buttons)do Bounds.Rect(b,8+(i-1)%sideCols*(bw+6),8+math.floor((i-1)/sideCols)*50,bw,44)end
  Bounds.Rect(U.SideHint,12,262,sw-24,76);U.SideHint.Visible=bottom-top>=344
  local left=side and il+sw+18 or il+8;local maxw=w-ir-left-8;local x=left
  local headerModes=false
  local footer=chat and 78 or 24;local modeH=chat and not keyboard and not headerModes and 48 or 0
  local retryFooter=U.Connection.Visible and not retryHeader
  local retryRow=retryFooter and(modeH==0 or maxw<310)and 48 or 0
  local controlsY=bottom-footer-modeH-retryRow;local bh=math.max(0,controlsY-top)
  Bounds.Rect(U.Body,x,top,maxw,bh);U.Composer.Visible=chat;U.Make.Visible=chat and not keyboard;U.Help.Visible=chat and not keyboard
  if headerModes then
   Bounds.Rect(U.Title,headerX+52,y,100,44);Bounds.Rect(U.Make,headerX+160,y,98,44);Bounds.Rect(U.Help,headerX+264,y,104,44)
  else Bounds.Rect(U.Make,x,controlsY,108,44);Bounds.Rect(U.Help,x+114,controlsY,108,44)end
  Bounds.Rect(U.Composer,x,bottom-76,maxw,54);Bounds.Rect(U.Input,5,5,maxw-62,44);Bounds.Rect(U.Send,maxw-52,5,44,44)
  Bounds.Rect(U.Notice,x,bottom-20,maxw,18)
  if retryHeader then Bounds.Rect(U.Connection,closeX-132,y,126,44)
  else
   local ry=controlsY+(modeH>0 and retryRow>0 and 48 or 0)
   Bounds.Rect(U.Connection,x+maxw-126,ry,126,44)
   if modeH>0 and retryRow==0 then
    Bounds.Rect(U.Make,x,controlsY,86,44);Bounds.Rect(U.Help,x+92,controlsY,86,44);Bounds.Rect(U.Connection,x+maxw-112,ry,112,44)
   end
  end
  Bounds.Rect(U.Sponsor,headerX+52,y,110,44);Bounds.Rect(U.Title,headerX+170,y,math.max(38,rightStart-headerX-178),44);U.Plan.Visible=false
  U.Connection.ZIndex=30
  local cols=maxw>=480 and 4 or 2;local cw=(maxw-6*(cols-1))/cols
  for i,b in ipairs(U.Suggestions)do Bounds.Rect(b,(i-1)%cols*(cw+6),80+math.floor((i-1)/cols)*50,cw,44)end
  U.Welcome.Size=UDim2.new(1,-6,0,maxw>=480 and 140 or 190);U.Heading.TextSize=maxw<400 and 22 or 25
  if U.OnLayout then U.OnLayout(maxw,bh)end
 end
 U.Menu.Activated:Connect(function()U.MenuOpen=not U.MenuOpen;U.Layout()end)
 pcall(function()UIS:GetPropertyChangedSignal('OnScreenKeyboardVisible'):Connect(U.Layout);UIS:GetPropertyChangedSignal('OnScreenKeyboardPosition'):Connect(U.Layout)end)
 safe.Watch(U.Layout);return U
end
return M
