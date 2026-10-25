-- 09I4_ASSISTANT_UI | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- Conversa ampla, campo central, trilho estreito e histórico recolhível; APIs existentes preservadas.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local UIS=game:GetService('UserInputService')
local Skin=require(Rep:WaitForChild('09I20_ASSISTANT_APPEARANCE'));local C=Skin.Colors;local M={Version='V77'}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Assistant');if old then old:Destroy()end
 local U={Tab='Conversa',Cards={},MenuOpen=false,Available=false,Language='pt',Persistent={},ConversationEmpty=true,Alive=true};local order=1
 U.Gui=D.New('ScreenGui',{Name='ACP_Assistant',ResetOnSpawn=false,DisplayOrder=185,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Gui.Destroying:Connect(function()U.Alive=false end)
 U.Root=D.New('Frame',{Name='AssistantRoot',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.paper},U.Gui);U.Root.BackgroundTransparency=1;U.Window=D.Frame(U.Root,{Name='AssistantWindow',BackgroundColor3=C.paper});U.Root:SetAttribute('V56_NoTheme',true);local accent=U.Root:FindFirstChild('HalloweenSceneAccent');if accent then accent:Destroy()end
 U.Rail=D.New('Frame',{Name='AssistantIconRail',BackgroundColor3=C.panel},U.Root)
 U.Tabs=D.Scroll(U.Root,{Name='AssistantSidebar',BackgroundColor3=C.panel,BackgroundTransparency=0,Visible=false,ZIndex=55,AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=2});U.TabButtons={}
 U.Menu=D.IconButton(U.Root,'AssistantMenu','menu','Histórico e navegação',{ZIndex=80})
 U.Title=D.Text(U.Root,'Assistente',{TextSize=17,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,'CloseAssistant','close','Voltar à praça',{ZIndex=80})
 U.Share=D.IconButton(U.Root,'ShareConversation','people','Compartilhar conversa',{ZIndex=81})
 U.Plan=D.Text(U.Root,'',{TextSize=12});U.Plan.Visible=false
 U.Sponsor=D.Button(U.Rail,'',{Name='SponsorTab',TextSize=13,ZIndex=56});D.Icon(U.Sponsor,'catalog',{Position=UDim2.fromOffset(10,10),Size=UDim2.fromOffset(24,24)})
 U.NewChat=D.Button(U.Rail,'',{Name='NewConversation',TextSize=14,ZIndex=56})
 U.Activities=D.Button(U.Rail,'',{Name='OpenCreativeActivities',TextSize=14,ZIndex=56})
 U.Activities.Activated:Connect(function()pg:SetAttribute('ACP_OpenActivitiesNonce',(pg:GetAttribute('ACP_OpenActivitiesNonce')or 0)+1)end)
 local names={Conversa='Conversa',Looks='Looks',Salvos='Looks salvos',Perfil='Conta e configurações'}
 for _,key in ipairs({'Conversa','Looks','Salvos','Perfil'})do U.TabButtons[key]=D.Button(U.Root,names[key],{Name='AssistantPage_'..key,TextSize=14,ZIndex=56})end
 for _,entry in ipairs({{U.NewChat,'catalog'},{U.Activities,'people'},{U.TabButtons.Salvos,'save'},{U.TabButtons.Perfil,'settings'}})do
  local icon=D.Icon(entry[1],entry[2],{Position=UDim2.fromOffset(10,10),Size=UDim2.fromOffset(24,24)});icon.Name='RailGlyph'
 end
 U.Upgrade=D.Button(U.Tabs,'Conferir Plus e Pro',{Name='AssistantUpgrade',TextSize=12,ZIndex=56})
 U.SideHint=D.Text(U.Tabs,'',{TextSize=12});U.SideHint.Visible=false
 U.Body=D.New('Frame',{Name='AssistantBody',BackgroundTransparency=1},U.Root)
 U.Chat=D.Scroll(U.Body,{Name='PrivateConversation',Size=UDim2.fromScale(1,1),ScrollBarThickness=3})
 U.ChatList=D.New('UIListLayout',{Padding=UDim.new(0,18),SortOrder=Enum.SortOrder.LayoutOrder},U.Chat)
 U.Welcome=D.New('Frame',{Name='AssistantWelcome',BackgroundTransparency=1,Visible=true},U.Root)
 U.Hero=D.Icon(U.Welcome,'avatarphoto',{Size=UDim2.fromOffset(32,32)});U.Hero.Visible=false;U.Steps={}
 U.Heading=D.Text(U.Welcome,'Como posso ajudar, '..tostring(pl.DisplayName or pl.Name)..'?',{TextSize=27,TextColor3=C.ink})
 U.Intro=D.Text(U.Welcome,'Monte um look, ajuste suas peças ou explore a praça.',{TextSize=14,TextColor3=C.muted});U.Intro:SetAttribute('ACP_Muted',true)
 U.Suggestions={};local suggestions={{'Montar um look do meu estilo','Quero criar um look','styles'},{'Definir meu orçamento','Quero criar um look','budget'},{'Trocar algumas peças','Quero trocar só o cabelo','form'},{'Entender uma função do jogo','Como usar o jogo?','help'},{'Criar um look com amigos','','activities'}}
 for i,entry in ipairs(suggestions)do
  local b=D.Button(U.Root,'›  '..entry[1],{Name='AssistantSuggestion'..i,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextSize=14,Font=Enum.Font.Gotham,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd});b:SetAttribute('ACP_Plain',true);U.Suggestions[i]=b
  local stroke=b:FindFirstChildOfClass('UIStroke');if stroke then stroke.Transparency=1 end
  b.Activated:Connect(function()U.Input.Text=entry[2];if U.OnCategory then U.OnCategory(entry[3],entry[2])elseif U.OnSuggest then U.OnSuggest(entry[3]~='help')end end)
 end
 U.Results=D.New('Frame',{Name='GeneratedLooks',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Saved=D.New('Frame',{Name='SavedCollections',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Profile=D.Scroll(U.Body,{Name='AssistantProfile',Visible=false,ScrollBarThickness=3});U.ProfileList=D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Profile)
 U.Composer=D.Frame(U.Root,{Name='MessageComposer',BackgroundColor3=C.paper});D.Round(U.Composer,28);D.Stroke(U.Composer,C.line,.15)
 U.Make=D.Button(U.Composer,'+',{Name='CreateLookFromComposer',TextSize=26,BackgroundTransparency=1})
 U.Help=D.Button(U.Composer,'?',{Name='AssistantHelp',TextSize=19,BackgroundTransparency=1})
 U.Input=D.Box(U.Composer,'Descreva o look que você quer…',{Name='AssistantMessage',TextSize=16,MultiLine=true,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1})
 local inputStroke=U.Input:FindFirstChildOfClass('UIStroke');if inputStroke then inputStroke.Enabled=false end
 U.Send=D.IconButton(U.Composer,'SendMessage','send','Enviar pedido',{Size=UDim2.fromOffset(44,44)});U.Send:SetAttribute('ACP_Primary',true);D.Round(U.Send,24)
 U.Notice=D.Text(U.Root,'',{TextSize=12,TextColor3=C.muted,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false});U.Notice:SetAttribute('ACP_Muted',true)
 U.Progress=D.Text(U.Chat,'',{Name='AssistantProgress',Size=UDim2.new(1,-6,0,44),TextSize=14,Visible=false,LayoutOrder=999998})
 U.ProgressTrack=D.Frame(U.Progress,{Name='BuildProgressTrack',Position=UDim2.new(0,8,1,-5),Size=UDim2.new(1,-16,0,3),BackgroundColor3=C.card})
 U.ProgressFill=D.Frame(U.ProgressTrack,{Size=UDim2.fromScale(0,1),BackgroundColor3=C.blue});U.ProgressFill:SetAttribute('ACP_KeepAppearance',true)
 U.Connection=D.Button(U.Root,'Reconectar',{TextSize=13,Visible=false,ZIndex=85})
 U.SettingsShade=D.New('TextButton',{Name='AssistantSettingsShade',Text='',Size=UDim2.fromScale(1,1),BackgroundColor3=C.ink,BackgroundTransparency=.55,Visible=false,Active=true,ZIndex=112},U.Root);U.SettingsShade:SetAttribute('ACP_KeepAppearance',true)
 U.SettingsWindow=D.Frame(U.SettingsShade,{Name='AssistantSettingsWindow',BackgroundColor3=C.paper,ZIndex=113})
 U.SettingsTitle=D.Text(U.SettingsWindow,'Configurações',{Position=UDim2.fromOffset(16,6),Size=UDim2.new(1,-80,0,44),TextSize=21,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=114})
 U.SettingsClose=D.IconButton(U.SettingsWindow,'CloseAssistantSettings','close','Voltar à conversa',{Position=UDim2.new(1,-54,0,4),Size=UDim2.fromOffset(48,48),ZIndex=117})
 U.Profile.Parent=U.SettingsWindow;U.Profile.Position=UDim2.fromOffset(12,58);U.Profile.Size=UDim2.new(1,-24,1,-70);U.Profile.ZIndex=114
 Skin.Bind(U.SettingsWindow);U.SettingsClose.Activated:Connect(function()U.SettingsShade.Visible=false;U.Profile.Visible=false end)
 local nativeSafe=Bounds.Bind(U.Gui);local safe={Watch=nativeSafe.Watch}
 safe.Read=function()
  local il,it,ir,ib,w,h=nativeSafe.Read();local aw=w-il-ir
  local width=aw>=900 and math.min(620,aw*.44)or aw>=560 and math.min(540,aw*.58)or aw-16
  return w-ir-width-8,it,ir+8,ib,w,h
 end
 safe.Topbar=function()local il,it,ir,ib,w,h=safe.Read();return{X=il,Y=it,Right=w-ir,Bottom=it}end
 U.Safe=safe
 function U.KeepInChat(o)U.Persistent[o]=true end
 function U.NextOrder()order=order+1;return order end
 function U.ScrollBottom()task.defer(function()U.Chat.CanvasPosition=Vector2.new(0,math.max(0,U.Chat.AbsoluteCanvasSize.Y-U.Chat.AbsoluteWindowSize.Y))end)end
 function U.Add(value,user)
  U.ConversationEmpty=false;U.Welcome.Visible=false
  local host=D.New('Frame',{Name=user and'YourMessageRow'or'AIResponseRow',Size=UDim2.new(1,-6,0,90),BackgroundTransparency=1,LayoutOrder=U.NextOrder()},U.Chat)
  local block=D.Frame(host,{Name=user and'YourMessage'or'AIResponse',AnchorPoint=Vector2.new(user and 1 or 0,0),Position=UDim2.fromScale(user and 1 or 0,0),Size=UDim2.new(user and .80 or 1,0,1,0),BackgroundColor3=C.card,BackgroundTransparency=user and 0 or 1})
  local label=D.Text(block,value,{Position=UDim2.fromOffset(14,10),Size=UDim2.new(1,-28,0,60),TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,RichText=false})
  local function fit()local bh=math.max(32,label.TextBounds.Y+8);label.Size=UDim2.new(1,-28,0,bh);host.Size=UDim2.new(1,-6,0,bh+20)end
  label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit);U.Layout();U.ScrollBottom();return block
 end
 function U.ClearConversation()
  for _,o in ipairs(U.Chat:GetChildren())do if o:IsA('GuiObject')and o~=U.Progress and not U.Persistent[o]then o:Destroy()end end
  order=1;U.ConversationEmpty=true;U.Welcome.Visible=true;U.Progress.Visible=false;U.Chat.CanvasPosition=Vector2.zero;U.Layout()
 end
 function U.Ad(block,data,onOpen)
  if not data or data.hidden then return end
  local box=D.Frame(U.Chat,{Name='FirstPartyAdvertisement',Size=UDim2.new(1,-6,0,72),LayoutOrder=U.NextOrder(),BackgroundColor3=C.panel})
  D.New('ImageLabel',{Position=UDim2.fromOffset(8,6),Size=UDim2.fromOffset(58,58),BackgroundTransparency=1,Image='rbxthumb://type=Asset&id='..data.id..'&w=150&h=150',ScaleType=Enum.ScaleType.Fit},box)
  D.Text(box,data.label,{Position=UDim2.fromOffset(76,4),Size=UDim2.new(1,-148,0,20),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
  D.Text(box,data.name,{Position=UDim2.fromOffset(76,26),Size=UDim2.new(1,-148,0,36),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})
  D.Button(box,'Ver',{Position=UDim2.new(1,-66,0,14),Size=UDim2.fromOffset(58,44),TextSize=14}).Activated:Connect(onOpen)
 end
 function U.SetAppearance(mode)U.Root:SetAttribute('AssistantDark',mode=='Escuro');U.SettingsWindow:SetAttribute('AssistantDark',mode=='Escuro')end
 function U.Health(plan,available,checking)
  U.Available=available==true;U.Plan.Text=tostring(require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG')).Labels[plan]or'Gratuito');U.Plan.Visible=false
  U.Connection.Visible=not available and not checking;U.Layout()
 end
 function U.Select(name)
  if not U.Alive then return end
  local settings=name=='Perfil';U.SettingsShade.Visible=settings;U.Profile.Visible=settings
  if not settings then U.Tab=name end
  U.Chat.Visible=U.Tab=='Conversa';U.Results.Visible=U.Tab=='Looks';U.Saved.Visible=U.Tab=='Salvos'
  for key,b in pairs(U.TabButtons)do b:SetAttribute('ACP_Primary',false);b.BackgroundTransparency=(key=='Conversa'or key=='Looks')and(key==U.Tab and 0 or .6)or 1 end
  if not U.Desktop then U.MenuOpen=false end;U.Layout()
 end
 function U.Layout()
  if not U.Alive or not U.Gui.Parent or not U.Root.Parent then return end
  local il,it,ir,ib,w,h=safe.Read();if w<=0 or h<=0 then return end
  local aw=w-il-ir;Bounds.Rect(U.Window,il,it,aw,h-it-ib);local top=it+6;local bottom=h-ib-8;local bar=safe.Topbar();local hy=it+6;local header=48
  if w>h and bar.Right-bar.X>=350 and bar.Bottom-bar.Y>=48 then hy=bar.Y+2;header=0 end
  top=top+header;local keyboard=false
  pcall(function()local pos=UIS.OnScreenKeyboardPosition;keyboard=UIS.OnScreenKeyboardVisible and pos and pos.Y>top+70;if keyboard then bottom=math.min(bottom,pos.Y-6)end end)
  U.Desktop=aw>=900 and w>h;if U.DefaultMenuSet==nil then U.DefaultMenuSet=true;U.MenuOpen=U.Desktop end;local rail=aw>=620 and 56 or 0;local side=U.Desktop and U.MenuOpen and math.min(248,aw*.27)or rail;U.SideWidth=math.min(248,aw-56)
  Bounds.Rect(U.Rail,il,top,rail,math.max(1,bottom-top));U.Rail.Visible=rail>0 and not U.MenuOpen
  Bounds.Rect(U.Menu,il+6,it+4,44,44);Bounds.Rect(U.Close,w-ir-54,hy,48,48);Bounds.Rect(U.Share,w-ir-104,hy+2,44,44)
  local headerX=header==0 and math.max(bar.X+8,il+62)or il+62;local middle=headerX+(w-ir-114-headerX)/2
  Bounds.Rect(U.TabButtons.Conversa,middle-100,hy+2,96,44);Bounds.Rect(U.TabButtons.Looks,middle+2,hy+2,96,44)
  U.Title.Visible=false;U.Plan.Visible=false
  U.Tabs.Visible=U.MenuOpen==true;Bounds.Rect(U.Tabs,il+4,top,U.SideWidth,math.max(70,bottom-top));U.Tabs.CanvasSize=UDim2.fromOffset(0,math.max(340,bottom-top));U.Tabs.ScrollingEnabled=bottom-top<360
  local menuRows={{U.NewChat,'Nova conversa'},{U.TabButtons.Salvos,'Looks salvos'},{U.Activities,'Criar com amigos'},{U.Sponsor,'Patrocinar'},{U.TabButtons.Perfil,'Configurações'}}
  for i,entry in ipairs(menuRows)do
   local b=entry[1];b.Parent=U.MenuOpen and U.Tabs or U.Rail;b.Visible=U.MenuOpen or rail>0;b.Text=U.MenuOpen and(i==5 and('Conta · '..(U.Plan.Text~=''and U.Plan.Text or'Gratuito'))or entry[2])or''
   local glyph=b:FindFirstChild('RailGlyph')or b:FindFirstChild('Icon_catalog');if glyph then glyph.Visible=not U.MenuOpen end
   local by=i==1 and 4 or i==5 and math.max(4,bottom-top-48)or math.max(52,bottom-top-96-(5-i)*48);if U.MenuOpen then b.Visible=i==1 or i==5 or bottom-top>=460 end;Bounds.Rect(b,U.MenuOpen and 8 or 6,by,U.MenuOpen and U.SideWidth-16 or 44,44)
  end
  U.Upgrade.Visible=U.MenuOpen and bottom-top>=270;Bounds.Rect(U.Upgrade,8,math.max(52,bottom-top-98),U.SideWidth-16,44)
  local x=il+side+12;local width=w-ir-x-12;local chat=U.Tab=='Conversa';local cw=chat and math.min(820,width)or width;local cx=x+(width-cw)/2
  local welcome=chat and U.ConversationEmpty and not U.Guiding;local ah=bottom-top;local suggestions=not keyboard and ah>=310
  local cy=welcome and top+math.max(78,ah*.37)or bottom-66
  if welcome and suggestions then cy=math.min(cy,bottom-218)end;cy=math.max(top+40,cy)
  Bounds.Rect(U.Body,cx,top,cw,math.max(1,(chat and not U.Guiding and not welcome and cy-12 or bottom)-top))
  U.Composer.Visible=chat and not U.Guiding;Bounds.Rect(U.Composer,cx,cy,cw,60)
  U.Input.PlaceholderText=cw<440 and'Descreva seu look…'or'Descreva o look que você quer…';Bounds.Rect(U.Make,6,8,44,44);Bounds.Rect(U.Input,50,7,math.max(40,cw-146),46);Bounds.Rect(U.Help,cw-94,8,44,44);Bounds.Rect(U.Send,cw-48,8,44,44)
  U.Welcome.Visible=welcome;Bounds.Rect(U.Welcome,cx,math.max(top,cy-82),cw,76);Bounds.Rect(U.Heading,4,0,cw-8,42);U.Heading.TextSize=cw<440 and 21 or 27
  Bounds.Rect(U.Intro,8,44,cw-16,26);U.Intro.Visible=not keyboard
  for i,b in ipairs(U.Suggestions)do b.Visible=welcome and suggestions and i<=3;Bounds.Rect(b,cx+8,cy+72+(i-1)*44,cw-16,44)end
  Bounds.Rect(U.Notice,cx+4,bottom-20,cw-8,18);U.Notice.Visible=not U.Guiding and not welcome
  if U.Connection.Visible then Bounds.Rect(U.Connection,cx+math.max(0,cw-122),top,122,44)end
  local pw,ph=math.min(700,aw-16),math.min(540,h-it-ib-16);Bounds.Rect(U.SettingsWindow,il+(aw-pw)/2,it+(h-it-ib-ph)/2,pw,ph)
  if U.OnLayout then U.OnLayout(cw,U.Body.AbsoluteSize.Y)end
 end
 U.Menu.Activated:Connect(function()U.MenuOpen=not U.MenuOpen;U.Layout()end)
 pcall(function()UIS:GetPropertyChangedSignal('OnScreenKeyboardVisible'):Connect(U.Layout);UIS:GetPropertyChangedSignal('OnScreenKeyboardPosition'):Connect(U.Layout)end)
 Skin.Bind(U.Root);safe.Watch(U.Layout);return U
end
return M
