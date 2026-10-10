-- 09I4_ASSISTANT_UI | ModuleScript | ReplicatedStorage | V55 (NOVO)
-- Área segura inteira; menus contextuais, conversa privada e identidade própria.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors;local M={}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Assistant');if old then old:Destroy()end
 local U={Tab='Conversa',Cards={}}
 U.Gui=D.New('ScreenGui',{Name='ACP_Assistant',ResetOnSpawn=false,DisplayOrder=185,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.New('Frame',{Name='AssistantRoot',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.bg},U.Gui)
 U.Title=D.Text(U.Root,'Avatar IA',{Font=Enum.Font.GothamBold,TextSize=23,TextXAlignment=Enum.TextXAlignment.Left})
 U.Plan=D.Text(U.Root,'Normal',{TextColor3=C.orange,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right})
 U.Close=D.IconButton(U.Root,'CloseAssistant','close','Fechar IA',{ZIndex=80})
 U.Tabs=D.New('Frame',{BackgroundTransparency=1},U.Root);U.TabButtons={}
 for _,name in ipairs({'Conversa','Looks','Salvos','Perfil'})do U.TabButtons[name]=D.Button(U.Tabs,name,{TextSize=13})end
 U.Body=D.New('Frame',{Name='AssistantBody',BackgroundTransparency=1},U.Root)
 U.Chat=D.Scroll(U.Body,{Name='PrivateConversation',Size=UDim2.fromScale(1,1),ScrollBarThickness=3})
 U.ChatList=D.New('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},U.Chat)
 U.Welcome=D.Text(U.Chat,'O que vamos criar hoje?\nPeça um estilo ou tire uma dúvida sobre o jogo.',{Name='Welcome',Size=UDim2.new(1,-6,0,100),Font=Enum.Font.GothamBold,TextSize=22,LayoutOrder=0})
 U.Results=D.New('Frame',{Name='GeneratedLooks',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Saved=D.New('Frame',{Name='SavedCollections',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},U.Body)
 U.Profile=D.Scroll(U.Body,{Name='AssistantProfile',Size=UDim2.fromScale(1,1),Visible=false,ScrollBarThickness=3})
 U.ProfileList=D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Profile)
 U.Composer=D.Frame(U.Root,{Name='MessageComposer',BackgroundColor3=C.panel})
 U.Input=D.Box(U.Composer,'Peça um look ou ajuda com o jogo…',{TextSize=14,MultiLine=true,TextWrapped=true})
 U.Send=D.Button(U.Composer,'↑',{TextSize=23,BackgroundColor3=C.orange,TextColor3=C.bg})
 U.Make=D.Button(U.Composer,'Criar looks',{TextSize=12});U.Help=D.Button(U.Composer,'Perguntar',{TextSize=12})
 U.Notice=D.Text(U.Root,'',{TextSize=11,TextColor3=C.muted,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 U.Progress=D.Text(U.Root,'',{TextSize=13,TextColor3=C.orange,Visible=false})
 local safe=Bounds.Bind(U.Gui);local order=1
 function U.Add(text,user)
  U.Welcome.Visible=false;order=order+1
  local block=D.Frame(U.Chat,{Name=user and'YourMessage'or'AIResponse',Size=UDim2.new(1,-6,0,100),BackgroundColor3=user and C.soft or C.panel,LayoutOrder=order})
  local title=D.Text(block,user and'Você'or'IA • resposta gerada',{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,22),TextSize=11,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  local label=D.Text(block,text,{Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,60),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
  local function fit()local h=math.max(56,label.TextBounds.Y+12);label.Size=UDim2.new(1,-24,0,h);block.Size=UDim2.new(1,-6,0,h+36)end
  label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit)
  task.defer(function()U.Chat.CanvasPosition=Vector2.new(0,math.max(0,U.Chat.AbsoluteCanvasSize.Y-U.Chat.AbsoluteWindowSize.Y))end)
  return block
 end
 function U.Ad(block,data,onOpen)
  if not data or data.hidden then return end
  local box=D.Frame(U.Chat,{Name='FirstPartyAdvertisement',Size=UDim2.new(1,-6,0,76),LayoutOrder=block.LayoutOrder,BackgroundColor3=C.panel})
  D.New('ImageLabel',{Position=UDim2.fromOffset(6,6),Size=UDim2.fromOffset(64,64),BackgroundTransparency=1,Image='rbxthumb://type=Asset&id='..data.id..'&w=150&h=150',ScaleType=Enum.ScaleType.Fit},box)
  D.Text(box,data.label,{Position=UDim2.fromOffset(78,4),Size=UDim2.new(1,-150,0,20),TextSize=11,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  D.Text(box,data.name,{Position=UDim2.fromOffset(78,25),Size=UDim2.new(1,-150,0,44),TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
  local b=D.Button(box,'Ver',{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.fromOffset(60,44),TextSize=13});b.Activated:Connect(onOpen)
 end
 function U.Select(name)
  U.Tab=name;U.Chat.Visible=name=='Conversa';U.Results.Visible=name=='Looks';U.Saved.Visible=name=='Salvos';U.Profile.Visible=name=='Perfil'
  for key,b in pairs(U.TabButtons)do b.BackgroundColor3=key==name and C.orange or C.card;b.TextColor3=key==name and C.bg or C.white end
  U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<=0 or h<=0 then return end;local aw=w-il-ir
  local top=safe.Heading(U.Title,U.Close);local bar=safe.Topbar()
  if aw>=520 and bar.Right-bar.X>=340 and bar.Bottom-bar.Y>=48 then Bounds.Rect(U.Title,bar.X+8,bar.Y+4,bar.Right-bar.X-196,44);Bounds.Rect(U.Close,bar.Right-56,bar.Y+4,48,48);Bounds.Rect(U.Plan,bar.Right-184,bar.Y+4,120,44);top=it+4
  else Bounds.Rect(U.Title,il+8,it+4,aw-196,44);U.Title.TextSize=aw<360 and 16 or 23;Bounds.Rect(U.Plan,w-ir-182,it+4,116,44)end
  Bounds.Rect(U.Tabs,il+6,top,aw-12,44);for i,name in ipairs({'Conversa','Looks','Salvos','Perfil'})do Bounds.Rect(U.TabButtons[name],(i-1)*(aw-6)/4,0,(aw-30)/4,44)end
  local chat=U.Tab=='Conversa';local footer=chat and 134 or 24;local y=top+50;local bh=math.max(44,h-ib-y-footer)
  Bounds.Rect(U.Body,il+6,y,aw-12,bh);U.Composer.Visible=chat
  Bounds.Rect(U.Composer,il+6,h-ib-128,aw-12,104)
  Bounds.Rect(U.Input,4,4,aw-78,44);Bounds.Rect(U.Send,aw-68,4,50,44)
  Bounds.Rect(U.Make,6,54,110,44);Bounds.Rect(U.Help,122,54,94,44)
  Bounds.Rect(U.Notice,il+8,h-ib-22,aw-16,20);Bounds.Rect(U.Progress,il+8,h-ib-80,aw-16,32)
  if U.OnLayout then U.OnLayout(aw-12,bh)end
 end
 safe.Watch(U.Layout);return U
end
return M
