-- 07H10_MATCH_CHAT_UI | ModuleScript | ReplicatedStorage | V69 (NOVO)
-- Interface privada por partida; exibe somente mensagens confirmadas pelo TextChatService.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players')
local Chat=game:GetService('TextChatService');local UIS=game:GetService('UserInputService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={}
function M.Build(root,button)
 local pl=Players.LocalPlayer;local gui=root:FindFirstAncestorOfClass('ScreenGui');local safe=Bounds.Bind(gui)
 local U={Unread=0,Rows={},Seen={},Open=false,Channel=nil,Connections={},Alive=true}
 U.Panel=D.Frame(root,{Name='PrivateMatchConversation',BackgroundColor3=C.panel,Visible=false,ZIndex=90});D.Stroke(U.Panel,C.green,.25)
 U.Title=D.Text(U.Panel,'Conversa da partida',{Position=UDim2.fromOffset(12,6),Size=UDim2.new(1,-72,0,32),Font=Enum.Font.GothamBold,TextSize=16,ZIndex=91})
 U.Close=D.IconButton(U.Panel,'CloseMatchChat','close','Fechar conversa',{Position=UDim2.new(1,-50,0,2),Size=UDim2.fromOffset(44,44),ZIndex=93})
 U.Status=D.Text(U.Panel,'',{TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=91})
 U.Log=D.Scroll(U.Panel,{Name='FilteredMessages',ScrollBarThickness=3,ZIndex=91})
 D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Log)
 U.Input=D.Box(U.Panel,'Mensagem para esta partida…',{Name='MatchChatInput',TextSize=15,ZIndex=92})
 U.Send=D.IconButton(U.Panel,'SendMatchMessage','send','Enviar para participantes',{BackgroundColor3=C.green,TextColor3=C.bg,Size=UDim2.fromOffset(44,44),ZIndex=93})
 U.Help=D.Text(U.Panel,'Denúncias: menu Roblox > Denunciar',{TextSize=12,TextColor3=C.muted,ZIndex=91})
 local channelConnections={};local sentAt=-10;local sending=false;local currentName
 local function disconnect()for _,c in ipairs(channelConnections)do c:Disconnect()end;channelConnections={}end
 local function clear()for _,r in ipairs(U.Rows)do r:Destroy()end;U.Rows={};U.Seen={};U.Unread=0 end
 local function source()
  if not U.Channel then return end
  for _,s in ipairs(U.Channel:GetChildren())do if s:IsA('TextSource')and s.UserId==pl.UserId then return s end end
 end
 local function readiness()
  local s=source();local permitted=s~=nil and s.CanSend==true and U.Channel.Parent~=nil
  D.SetEnabled(U.Send,permitted and not sending);U.Input.TextEditable=permitted
  U.Status.Text=U.Channel and tostring(pl:GetAttribute('ACP_MatchChatStatus')or'Conversa privada da partida.')or'Conversa disponível em partidas com outros jogadores.'
 end
 function U.Layout()
  if not U.Alive then return end
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local pw=math.min(340,aw-12);local top=it+54;local bottom=h-ib-8
  local ok,show,pos=pcall(function()return UIS.OnScreenKeyboardVisible,UIS.OnScreenKeyboardPosition end)
  if ok and show and pos and pos.Y>it+100 then top=it+4;bottom=math.min(bottom,pos.Y-6)end
  local ph=math.max(92,math.min(w>h and h-it-ib-66 or 420,bottom-top))
  Bounds.Rect(U.Panel,w-ir-pw-6,math.max(top,bottom-ph),pw,ph)
  local small=ph<220;U.Status.Visible=not small;U.Help.Visible=not small
  Bounds.Rect(U.Status,12,42,pw-24,34);Bounds.Rect(U.Log,10,small and 48 or 80,pw-20,math.max(4,ph-(small and 108 or 158)))
  local inputY=ph-(small and 52 or 74);Bounds.Rect(U.Input,10,inputY,pw-70,44);Bounds.Rect(U.Send,pw-54,inputY,44,44);Bounds.Rect(U.Help,10,ph-25,pw-20,20)
 end
 local function receive(message)
  if not U.Alive or not U.Channel or message.TextChannel~=U.Channel or message.Status~=Enum.TextChatMessageStatus.Success or not message.TextSource then return end
  local id=message.MessageId;if id and id~=''and U.Seen[id]then return end
  if id and id~=''then U.Seen[id]=true end
  local who=Players:GetPlayerByUserId(message.TextSource.UserId);if not who then return end
  local own=who==pl;local row=D.Frame(U.Log,{Name='ConfirmedMatchMessage',Size=UDim2.new(1,-6,0,66),LayoutOrder=#U.Rows+1,BackgroundColor3=own and C.soft or C.card,ZIndex=92})
  D.Text(row,own and'Você'or who.DisplayName,{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-20,0,20),TextColor3=own and C.green or C.blue,TextSize=13,Font=Enum.Font.GothamBold,RichText=false,ZIndex=93})
  local label=D.Text(row,message.Text,{Position=UDim2.fromOffset(10,26),Size=UDim2.new(1,-20,0,34),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextSize=15,RichText=false,ZIndex=93})
  local function fit()local height=math.max(24,label.TextBounds.Y+4);label.Size=UDim2.new(1,-20,0,height);row.Size=UDim2.new(1,-6,0,height+30)end
  label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit);U.Serial=(U.Serial or 0)+1;row.LayoutOrder=U.Serial;row:SetAttribute('MessageKey',id);U.Rows[#U.Rows+1]=row
  while #U.Rows>60 do local old=table.remove(U.Rows,1);local key=old:GetAttribute('MessageKey');if key then U.Seen[key]=nil end;old:Destroy()end
  if not U.Open and not own then U.Unread=U.Unread+1;button.Text='Conversa ('..U.Unread..')'end
  task.defer(function()if U.Alive then U.Log.CanvasPosition=Vector2.new(0,math.max(0,U.Log.AbsoluteCanvasSize.Y-U.Log.AbsoluteWindowSize.Y))end end)
 end
 local function bind()
  local name=pl:GetAttribute('ACP_MatchChat');local candidate=name and Chat:FindFirstChild(name,true);local expected=root:GetAttribute('ACP_ChatGameType')
  if root:GetAttribute('ACP_ChatBot')or candidate and expected and candidate:GetAttribute('ACP_Game')~=expected then name=nil end
  if currentName~=name then currentName=name;disconnect();clear();U.Channel=nil;U.Input.Text='';button.Text='Conversa'end
  if not U.Channel and name then
   local ch=Chat:FindFirstChild(name,true)
   if ch and ch:IsA('TextChannel')and ch:GetAttribute('ACP_PrivateMatch')==true then
    U.Channel=ch;channelConnections[#channelConnections+1]=ch.MessageReceived:Connect(receive)
    local own=source();if own then channelConnections[#channelConnections+1]=own:GetPropertyChangedSignal('CanSend'):Connect(readiness)end
    channelConnections[#channelConnections+1]=ch.ChildAdded:Connect(function(o)if o:IsA('TextSource')and o.UserId==pl.UserId then channelConnections[#channelConnections+1]=o:GetPropertyChangedSignal('CanSend'):Connect(readiness)end;readiness()end)
    channelConnections[#channelConnections+1]=ch.ChildRemoved:Connect(readiness)
    channelConnections[#channelConnections+1]=ch.Destroying:Connect(function()U.Channel=nil;clear();readiness()end)
   end
  end
  readiness()
 end
 local function send()
  if sending then return end;local text=U.Input.Text
  if text:match('^%s*$')then return end
  local length=utf8.len(text);if not length or length>200 then U.Status.Text='Use até 200 caracteres por mensagem.';return end
  local ch=U.Channel;local s=source();if not ch or not s or not s.CanSend then readiness();return end
  if os.clock()-sentAt<1 then return end;sentAt=os.clock();sending=true;readiness()
  task.spawn(function()
   local ok,response=pcall(function()return ch:SendAsync(text)end)
   if not U.Alive then return end;sending=false
   if U.Channel==ch then
    if ok and response and response.Status==Enum.TextChatMessageStatus.Success then if U.Input.Text==text then U.Input.Text=''end;readiness()
    else readiness();U.Status.Text='O Roblox não enviou. Confira as permissões ou tente novamente.'end
   end
  end)
 end
 U.Send.Activated:Connect(send);U.Input.FocusLost:Connect(function(enter)if enter then send()end end)
 button.Text='Conversa';button.Activated:Connect(function()U.Open=not U.Open;U.Panel.Visible=U.Open;U.Unread=0;button.Text='Conversa';bind();U.Layout()end)
 U.Close.Activated:Connect(function()U.Open=false;U.Panel.Visible=false end)
 U.Connections[#U.Connections+1]=pl:GetAttributeChangedSignal('ACP_MatchChat'):Connect(bind)
 U.Connections[#U.Connections+1]=root:GetAttributeChangedSignal('ACP_ChatGameType'):Connect(bind)
 U.Connections[#U.Connections+1]=root:GetAttributeChangedSignal('ACP_ChatBot'):Connect(bind)
 U.Connections[#U.Connections+1]=pl:GetAttributeChangedSignal('ACP_MatchChatStatus'):Connect(readiness)
 U.Connections[#U.Connections+1]=Chat.DescendantAdded:Connect(function(o)if o:IsA('TextChannel')then bind()end end)
 U.Connections[#U.Connections+1]=root:GetPropertyChangedSignal('Visible'):Connect(function()if not root.Visible then U.Open=false;U.Panel.Visible=false end end)
 pcall(function()U.Connections[#U.Connections+1]=UIS:GetPropertyChangedSignal('OnScreenKeyboardVisible'):Connect(U.Layout)end)
 root.Destroying:Connect(function()U.Alive=false;disconnect();for _,c in ipairs(U.Connections)do c:Disconnect()end end)
 safe.Watch(U.Layout);bind();U.Layout();U.Receive=receive;U.Bind=bind;U.SendMessage=send;return U
end
return M
