-- 09I4_ASSISTANT_UI | ModuleScript | ReplicatedStorage | V64 (SUBSTITUIR)
-- Conversa principal, menu recolhível, criação guiada na conversa e teclado móvel.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local UIS=game:GetService('UserInputService')
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=D.Colors;local M={Version='V64'}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Assistant');if old then old:Destroy()end
 local U={Tab='Conversa',Cards={},MenuOpen=false,Available=false,Language='pt',Persistent={}};local order=1
 U.Gui=D.New('ScreenGui',{Name='ACP_Assistant',ResetOnSpawn=false,DisplayOrder=185,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.New('Frame',{Name='AssistantRoot',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.bg},U.Gui)
 Fx.Surface(U.Root,Color3.fromRGB(20,22,30),Color3.fromRGB(44,30,52),Color3.fromRGB(168,130,226))
 U.Sponsor=D.Button(U.Root,'Patrocinar',{Name='SponsorTab',TextSize=12,ZIndex=80})
 U.Title=D.Text(U.Root,'Assistente de looks',{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Plan=D.Text(U.Root,'Conectando…',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
 U.Close=D.IconButton(U.Root,'CloseAssistant','close','Fechar IA',{ZIndex=80})
 U.Menu=D.IconButton(U.Root,'AssistantMenu','menu','Abrir menu',{ZIndex=80})
 U.Tabs=D.Scroll(U.Root,{Name='AssistantSidebar',BackgroundColor3=C.panel,BackgroundTransparency=0,Visible=false,ZIndex=55,AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,400),ScrollBarThickness=2});U.TabButtons={}
 U.NewChat=D.Button(U.Tabs,'+ Nova conversa',{Name='NewConversation',TextSize=13,ZIndex=56,BackgroundColor3=C.soft})
 local names={Conversa='Conversa',Looks='Últimos looks',Salvos='Looks salvos',Perfil='Minha conta e preferências'}
 for _,name in ipairs({'Conversa','Looks','Salvos','Perfil'})do U.TabButtons[name]=D.Button(U.Tabs,names[name],{TextSize=13,ZIndex=56})end
 U.SideHint=D.Text(U.Tabs,'Seu estúdio pessoal\n\nEscolha o estilo.\nConfira as peças.\nGuarde seus favoritos.',{TextColor3=C.muted,TextSize=12,ZIndex=56})
 U.Body=D.New('Frame',{Name='AssistantBody',BackgroundTransparency=1},U.Root)
 U.Chat=D.Scroll(U.Body,{Name='PrivateConversation',Size=UDim2.fromScale(1,1),ScrollBarThickness=3})
 U.ChatList=D.New('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},U.Chat)
 U.Welcome=D.New('Frame',{Name='AssistantWelcome',Size=UDim2.new(1,-6,0,178),BackgroundColor3=Color3.fromRGB(40,33,49),BackgroundTransparency=.1,LayoutOrder=0},U.Chat)
 D.Round(U.Welcome,16);D.Stroke(U.Welcome,Color3.fromRGB(170,128,213),.66,1)
 U.Hero=D.Icon(U.Welcome,'avatarphoto',{Size=UDim2.fromOffset(46,46),IconColor=C.orange});U.Steps={}
 for i,text in ipairs({'1 · Seu estilo','2 · Seu orçamento','3 · Prévia e peças'})do U.Steps[i]=D.Text(U.Welcome,text,{TextSize=11,TextColor3=C.purple,BackgroundColor3=Color3.fromRGB(45,35,57),BackgroundTransparency=.18});D.Round(U.Steps[i],8)end
 U.Heading=D.Text(U.Welcome,'Seu próximo look começa aqui',{Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,0,40),Font=Enum.Font.GothamBold,TextSize=25})
 U.Intro=D.Text(U.Welcome,'Descreva uma ideia. Escolha as opções e confira o resultado.',{Position=UDim2.fromOffset(4,46),Size=UDim2.new(1,-8,0,26),TextSize=13,TextColor3=C.muted})
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
 U.Input=D.Box(U.Composer,'Ex.: look emo preto até 100 Robux…',{TextSize=14,MultiLine=true,TextWrapped=true})
 U.Input.TextWrapped=true
 U.Send=D.IconButton(U.Composer,'SendMessage','send','Enviar pedido',{BackgroundColor3=C.orange,TextColor3=C.bg})
 U.Make=D.Button(U.Root,'Criar look',{TextSize=12});U.Help=D.Button(U.Root,'Pedir ajuda',{TextSize=12})
 U.Notice=D.Text(U.Root,'',{TextSize=11,TextColor3=C.muted,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left})
 U.Progress=D.Text(U.Chat,'',{Name='AssistantProgress',Size=UDim2.new(1,-6,0,44),TextSize=13,TextColor3=C.orange,Visible=false,LayoutOrder=999998})
 U.ProgressTrack=D.Frame(U.Progress,{Name='BuildProgressTrack',Position=UDim2.new(0,8,1,-5),Size=UDim2.new(1,-16,0,3),BackgroundColor3=C.soft})
 U.ProgressFill=D.Frame(U.ProgressTrack,{Size=UDim2.fromScale(0,1),BackgroundColor3=C.orange})
 U.Connection=D.Button(U.Root,'Recarregar IA',{TextSize=12,Visible=false})
 local safe=Bounds.Bind(U.Gui)
 function U.KeepInChat(o)U.Persistent[o]=true end
 function U.NextOrder()order=order+1;return order end
 function U.ScrollBottom()
  task.defer(function()U.Chat.CanvasPosition=Vector2.new(0,math.max(0,U.Chat.AbsoluteCanvasSize.Y-U.Chat.AbsoluteWindowSize.Y))end)
 end
 function U.Add(value,user)
  U.Welcome.Visible=false
  local host=D.New('Frame',{Name=user and'YourMessageRow'or'AIResponseRow',Size=UDim2.new(1,-6,0,90),BackgroundTransparency=1,LayoutOrder=U.NextOrder()},U.Chat)
  local block=D.Frame(host,{Name=user and'YourMessage'or'AIResponse',AnchorPoint=Vector2.new(user and 1 or 0,0),Position=UDim2.fromScale(user and 1 or 0,0),Size=UDim2.new(user and .78 or 1,0,1,0),BackgroundColor3=user and Color3.fromRGB(54,46,65) or C.bg,BackgroundTransparency=user and .05 or 1})
  if user then D.Stroke(block,C.purple,.82,1)end
  local label=D.Text(block,value,{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-24,0,56),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
  D.Text(block,user and'Você'or(U.Language=='en'and'IA de looks'or'Assistente de looks'),{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,20),TextSize=11,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  local function fit()local h=math.max(40,label.TextBounds.Y+10);label.Size=UDim2.new(1,-24,0,h);host.Size=UDim2.new(1,-6,0,h+34)end
  label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit);U.ScrollBottom();return block
 end
 function U.ClearConversation()
  for _,o in ipairs(U.Chat:GetChildren())do if o:IsA('GuiObject')and o~=U.Welcome and o~=U.Progress and not U.Persistent[o] then o:Destroy()end end
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
  local il,it,ir,ib,w,h=safe.Read();if w<=0 or h<=0 then return end
  local aw=w-il-ir;local bar=safe.Topbar();local headLeft=il;local headRight=w-ir;local headY=it+2;local top=it+52;local bottom=h-ib-4
  if w>h and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then headLeft=bar.X;headRight=bar.Right;headY=bar.Y+2;top=it+4 end
  local headWidth=headRight-headLeft
  local ok,visible,pos=pcall(function()return UIS.OnScreenKeyboardVisible,UIS.OnScreenKeyboardPosition end)
  local keyboard=ok and visible and pos and pos.Y>top+80;if keyboard then bottom=math.min(bottom,pos.Y-4)end
  Bounds.Rect(U.Menu,headLeft+4,headY,44,44);Bounds.Rect(U.Close,headRight-52,headY,48,48)
  Bounds.Rect(U.Sponsor,headLeft+52,headY,headWidth<500 and 84 or 102,44);U.Sponsor.TextSize=12
  local tx=headLeft+(headWidth<500 and 140 or 158);local modeW=headWidth>=620 and 198 or 0
  Bounds.Rect(U.Title,tx,headY,math.max(1,headRight-60-tx-modeW),44);U.Title.TextSize=aw<500 and 15 or 20;U.Title.Text='Estúdio de looks'
  U.Plan.Visible=false;local side=aw>=1100 and w>h;local sw=176
  U.Tabs.Visible=side or U.MenuOpen;Bounds.Rect(U.Tabs,il+4,top,sw,math.max(90,bottom-top))
  for i,b in ipairs({U.NewChat,U.TabButtons.Conversa,U.TabButtons.Looks,U.TabButtons.Salvos,U.TabButtons.Perfil})do Bounds.Rect(b,6,6+(i-1)*48,sw-12,44)end
  Bounds.Rect(U.SideHint,10,252,sw-20,128);U.SideHint.Visible=bottom-top>388
  local x=il+(side and sw+12 or 6);local rw=w-ir-x-6;local chat=U.Tab=='Conversa'
  local footer=U.Guiding and 0 or chat and 72 or 22;U.Notice.Visible=not U.Guiding;local bh=math.max(0,bottom-top-footer)
  Bounds.Rect(U.Body,x,top,rw,bh);U.Composer.Visible=chat and not U.Guiding
  Bounds.Rect(U.Composer,x,bottom-72,rw,52)
  local lowModes=modeW==0 and not keyboard;local inlineW=lowModes and math.min(144,rw*.34)or 0
  Bounds.Rect(U.Input,8+inlineW,4,math.max(40,rw-inlineW-66),44);Bounds.Rect(U.Send,rw-52,4,44,44)
  U.Make.Visible=chat and not U.Guiding and not keyboard;U.Help.Visible=U.Make.Visible
  if modeW>0 then Bounds.Rect(U.Make,headRight-258,headY,94,44);Bounds.Rect(U.Help,headRight-158,headY,94,44)
  else local my=bottom-70;Bounds.Rect(U.Make,x+4,my,inlineW/2-3,44);Bounds.Rect(U.Help,x+inlineW/2+3,my,inlineW/2-3,44);U.Make.TextSize=10;U.Help.TextSize=10 end
  Bounds.Rect(U.Notice,x,bottom-19,rw,18)
  if U.Connection.Visible then Bounds.Rect(U.Connection,x+math.max(0,rw-126),top,126,44);U.Connection.ZIndex=90 end
  local compact=bh<330;local cols=rw>=560 and 4 or 2;local gap=6;local cw=(rw-20-gap*(cols-1))/cols
  local heroH=compact and 62 or 104;U.Hero.Visible=not compact
  Bounds.Rect(U.Hero,14,12,42,42);Bounds.Rect(U.Heading,compact and 12 or 64,6,rw-(compact and 24 or 78),38);U.Heading.TextSize=rw<420 and 18 or 23
  Bounds.Rect(U.Intro,12,compact and 38 or 50,rw-24,24);U.Intro.TextSize=11
  for i,t in ipairs(U.Steps)do t.Visible=not compact;Bounds.Rect(t,12+(i-1)*(rw-24)/3,78,(rw-36)/3,22)end
  for i,b in ipairs(U.Suggestions)do Bounds.Rect(b,10+(i-1)%cols*(cw+gap),heroH+math.floor((i-1)/cols)*48,cw,44);b.TextSize=12 end
  U.Welcome.Size=UDim2.new(1,-6,0,heroH+math.ceil(4/cols)*48+6)
  if U.OnLayout then U.OnLayout(rw,bh)end
 end
 U.Menu.Activated:Connect(function()U.MenuOpen=not U.MenuOpen;U.Layout()end)
 pcall(function()UIS:GetPropertyChangedSignal('OnScreenKeyboardVisible'):Connect(U.Layout);UIS:GetPropertyChangedSignal('OnScreenKeyboardPosition'):Connect(U.Layout)end)
 safe.Watch(U.Layout);return U
end
return M
