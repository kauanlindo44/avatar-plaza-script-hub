-- 09I4_ASSISTANT_UI | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Conversa principal, menu recolhível, criação guiada na conversa e teclado móvel.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local UIS=game:GetService('UserInputService')
local C=D.Colors;local M={}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Assistant');if old then old:Destroy()end
 local U={Tab='Conversa',Cards={},MenuOpen=false,Available=false};local order=1
 U.Gui=D.New('ScreenGui',{Name='ACP_Assistant',ResetOnSpawn=false,DisplayOrder=185,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.New('Frame',{Name='AssistantRoot',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.bg},U.Gui)
 U.Title=D.Text(U.Root,'Avatar IA',{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Plan=D.Text(U.Root,'Conectando…',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
 U.Close=D.IconButton(U.Root,'CloseAssistant','close','Fechar IA',{ZIndex=80})
 U.Menu=D.IconButton(U.Root,'AssistantMenu','menu','Abrir menu',{ZIndex=80})
 U.Tabs=D.Frame(U.Root,{Name='AssistantSidebar',BackgroundColor3=C.panel,Visible=false,ZIndex=55});U.TabButtons={}
 local names={Conversa='Conversa',Looks='Últimos looks',Salvos='Looks salvos',Perfil='Planos e configurações'}
 for _,name in ipairs({'Conversa','Looks','Salvos','Perfil'})do U.TabButtons[name]=D.Button(U.Tabs,names[name],{TextSize=13,ZIndex=56})end
 U.SideHint=D.Text(U.Tabs,'Crie, experimente e guarde.\nCada pessoa usa sua própria conta Roblox.',{TextColor3=C.muted,TextSize=12,ZIndex=56})
 U.Body=D.New('Frame',{Name='AssistantBody',BackgroundTransparency=1},U.Root)
 U.Chat=D.Scroll(U.Body,{Name='PrivateConversation',Size=UDim2.fromScale(1,1),ScrollBarThickness=3})
 U.ChatList=D.New('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},U.Chat)
 U.Welcome=D.New('Frame',{Name='AssistantWelcome',Size=UDim2.new(1,-6,0,178),BackgroundTransparency=1,LayoutOrder=0},U.Chat)
 U.Heading=D.Text(U.Welcome,'Qual look vamos criar?',{Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,0,40),Font=Enum.Font.GothamBold,TextSize=25})
 U.Intro=D.Text(U.Welcome,'Escolha uma ideia ou escreva seu pedido.',{Position=UDim2.fromOffset(4,46),Size=UDim2.new(1,-8,0,26),TextSize=13,TextColor3=C.muted})
 U.Suggestions={}
 for i,entry in ipairs({{'Look emo','Crie um look emo'},{'Look grátis','Crie um look com itens gratuitos'},{'Halloween','Crie um look de Halloween'},{'Ajuda com o jogo','Como uso o Photo Mode?'}})do
  local b=D.Button(U.Welcome,entry[1],{TextSize=13});U.Suggestions[i]=b
  b.Activated:Connect(function()U.Input.Text=entry[2];if U.OnSuggest then U.OnSuggest(i~=4)end end)
 end
 U.Results=D.New('Frame',{Name='GeneratedLooks',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Saved=D.New('Frame',{Name='SavedCollections',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Profile=D.Scroll(U.Body,{Name='AssistantProfile',Size=UDim2.fromScale(1,1),Visible=false,ScrollBarThickness=3})
 U.ProfileList=D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Profile)
 U.Composer=D.Frame(U.Root,{Name='MessageComposer',BackgroundColor3=C.panel})
 U.Input=D.Box(U.Composer,'Descreva seu look…',{TextSize=14,MultiLine=true,TextWrapped=true})
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
  local block=D.Frame(U.Chat,{Name=user and'YourMessage'or'AIResponse',Size=UDim2.new(user and .82 or 1,-6,0,90),BackgroundColor3=user and C.soft or C.panel,LayoutOrder=U.NextOrder()})
  local label=D.Text(block,value,{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-24,0,56),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
  D.Text(block,user and'Você'or'Avatar IA',{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,20),TextSize=11,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  local function fit()local h=math.max(40,label.TextBounds.Y+10);label.Size=UDim2.new(1,-24,0,h);block.Size=UDim2.new(user and .82 or 1,-6,0,h+32)end
  label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit);U.ScrollBottom();return block
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
  U.Available=available==true;U.Plan.Text=tostring(plan or'Normal')..' • '..(checking and'conectando'or available and'online'or'indisponível')
  U.Plan.TextColor3=available and C.green or checking and C.muted or C.orange
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
  Bounds.Rect(U.Menu,headerX,y,44,44);Bounds.Rect(U.Title,headerX+52,y,math.max(60,w-ir-headerX-248),44)
  Bounds.Rect(U.Close,w-ir-54,y,48,48);Bounds.Rect(U.Plan,w-ir-190,y,128,44)
  local top=math.max(it+4,y+50);local bottom=h-ib
  local ok,visible,pos=pcall(function()return UIS.OnScreenKeyboardVisible,UIS.OnScreenKeyboardPosition end)
  if ok and visible and pos and pos.Y>top+120 then bottom=math.min(bottom,pos.Y-4)end
  local chat=U.Tab=='Conversa';local side=aw>=1100 and w>h
  U.Tabs.Visible=side or U.MenuOpen;local sw=math.min(208,aw-16)
  local sideH=math.max(104,bottom-top-8);Bounds.Rect(U.Tabs,il+6,top,sw,sideH);local sideCols=sideH<216 and 2 or 1
  local bw=(sw-16-(sideCols-1)*6)/sideCols
  for i,name in ipairs({'Conversa','Looks','Salvos','Perfil'})do Bounds.Rect(U.TabButtons[name],8+(i-1)%sideCols*(bw+6),8+math.floor((i-1)/sideCols)*50,bw,44)end
  Bounds.Rect(U.SideHint,12,216,sw-24,76);U.SideHint.Visible=bottom-top>=300
  local left=side and il+sw+18 or il+8;local mw=w-ir-left-8;local maxw=math.min(mw,920);local x=left+(mw-maxw)/2
  local footer=chat and 78 or 24;local modeH=chat and 48 or 0;local bh=math.max(40,bottom-top-footer-modeH)
  Bounds.Rect(U.Body,x,top,maxw,bh);U.Composer.Visible=chat;U.Make.Visible=chat;U.Help.Visible=chat
  Bounds.Rect(U.Make,x,bottom-footer-modeH,108,44);Bounds.Rect(U.Help,x+114,bottom-footer-modeH,108,44)
  Bounds.Rect(U.Composer,x,bottom-76,maxw,54);Bounds.Rect(U.Input,5,5,maxw-62,44);Bounds.Rect(U.Send,maxw-52,5,44,44)
  Bounds.Rect(U.Notice,x,bottom-20,maxw,18);Bounds.Rect(U.Connection,x+math.max(0,maxw-126),bottom-footer-modeH,126,44)
  if U.Connection.Visible and maxw<370 then
   Bounds.Rect(U.Make,x,bottom-footer-modeH,86,44);Bounds.Rect(U.Help,x+92,bottom-footer-modeH,86,44);Bounds.Rect(U.Connection,x+maxw-112,bottom-footer-modeH,112,44)
  end
  local cols=maxw>=480 and 4 or 2;local cw=(maxw-6*(cols-1))/cols
  for i,b in ipairs(U.Suggestions)do Bounds.Rect(b,(i-1)%cols*(cw+6),80+math.floor((i-1)/cols)*50,cw,44)end
  U.Welcome.Size=UDim2.new(1,-6,0,maxw>=480 and 132 or 182);U.Heading.TextSize=maxw<400 and 22 or 25
  if U.OnLayout then U.OnLayout(maxw,bh)end
 end
 U.Menu.Activated:Connect(function()U.MenuOpen=not U.MenuOpen;U.Layout()end)
 pcall(function()UIS:GetPropertyChangedSignal('OnScreenKeyboardVisible'):Connect(U.Layout);UIS:GetPropertyChangedSignal('OnScreenKeyboardPosition'):Connect(U.Layout)end)
 safe.Watch(U.Layout);return U
end
return M
