-- 09I10_CHAT_NAV | ModuleScript | ReplicatedStorage | V72 (SUBSTITUIR)
-- Barra lateral com busca/histórico e compartilhamento explícito de uma cópia textual.
local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors
local M={Version='V72'}
function M.Build(U,call,notice)
 local N={Rows={},Messages={},Title='Nova conversa'};local token=0;local replay=false;local current=Http:GenerateGUID(false);local renderer;local archivedCurrent=false
 N.Search=D.Box(U.Tabs,'Pesquisar conversas',{Name='SearchConversations',TextSize=12,ZIndex=57});N.List=D.Scroll(U.Tabs,{Name='ConversationHistory',ScrollBarThickness=2,ZIndex=57});D.New('UIListLayout',{Padding=UDim.new(0,4)},N.List)
 N.Archived=D.Button(U.Tabs,'Conversas arquivadas',{Name='ArchivedConversations',TextSize=11,ZIndex=57});N.ShowArchived=false
 local shade=D.New('TextButton',{Name='ShareConversationShade',Text='',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=.12,Visible=false,Active=true,ZIndex=120},U.Root)
 local panel=D.Frame(shade,{Name='ShareConversationPanel',BackgroundColor3=C.panel,ZIndex=121})
 local title=D.Text(panel,'Compartilhar conversa',{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-76,0,44),TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=122})
 local close=D.IconButton(panel,'CloseShareConversation','close','Fechar',{Position=UDim2.new(1,-54,0,2),Size=UDim2.fromOffset(48,48),ZIndex=125})
 local body=D.Scroll(panel,{Position=UDim2.fromOffset(10,54),Size=UDim2.new(1,-20,1,-64),ZIndex=122});D.New('UIListLayout',{Padding=UDim.new(0,8)},body)
 local note=D.Text(body,'Cria uma cópia pública das últimas oito mensagens, filtrada pelo Roblox, válida por sete dias. Sua conta Roblox e seus outros chats continuam privados.',{Size=UDim2.new(1,-4,0,80),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=123,LayoutOrder=1})
 local create=D.Button(body,'Criar código público',{Size=UDim2.new(1,-4,0,44),ZIndex=123,LayoutOrder=2})
 local code=D.Box(body,'O código aparece aqui',{Text='',Size=UDim2.new(1,-4,0,44),ClearTextOnFocus=false,ZIndex=123,LayoutOrder=3})
 local selectCode=D.Button(body,'Selecionar código para copiar',{Size=UDim2.new(1,-4,0,44),ZIndex=123,LayoutOrder=4})
 local openCode=D.Button(body,'Abrir um código CH-',{Size=UDim2.new(1,-4,0,44),ZIndex=123,LayoutOrder=5})
 function N.Layout()
  local w,h=U.Tabs.AbsoluteSize.X,U.Tabs.AbsoluteSize.Y
  local short=h<420;N.Search.Visible=true;N.List.Visible=true;B.Rect(N.Search,8,54,w-16,44);N.Archived.Visible=not short;B.Rect(N.Archived,8,102,w-16,44);local y=short and 104 or 152;B.Rect(N.List,8,y,w-16,math.max(44,h-y-(h>=460 and 256 or h>=270 and 106 or 56)))
  local il,it,ir,ib,sw,sh=U.Safe.Read();local pw=math.min(480,sw-il-ir-12);local ph=math.min(410,sh-it-ib-12)
  B.Rect(panel,il+(sw-il-ir-pw)/2,it+(sh-it-ib-ph)/2,pw,ph)
 end
 function N.Save(done)
  if #N.Messages==0 then if done then done()end;return end
  local messages={};for i=math.max(1,#N.Messages-15),#N.Messages do messages[#messages+1]={role=N.Messages[i].role,text=N.Messages[i].text}end
  local id,caption=current,N.Title;task.spawn(function()
   local data,e=call('chat.save',{id=id,title=caption,messages=messages,archived=archivedCurrent});if not data then notice(e)else
    local found;for _,row in ipairs(N.Rows)do if row.id==id then row.title=caption;row.updated=os.time();found=true end end;if not found then table.insert(N.Rows,1,{id=id,title=caption,updated=os.time()})end;renderer()
   end;if done then done(data)end
  end)
 end
 local function restore(row)
  if U.OnSwitchConversation then U.OnSwitchConversation()end
  token=token+1;replay=true;U.ClearConversation();N.Messages=row.messages or{};current=row.id or Http:GenerateGUID(false);N.Title=row.title or'Conversa compartilhada';archivedCurrent=row.archived==true
  for _,v in ipairs(N.Messages)do U.Add(v.text,v.role=='user')end;replay=false;U.Select('Conversa');U.MenuOpen=false;U.Layout();notice(row.shared and'Cópia compartilhada aberta. Mensagens novas ficam privadas.'or'Conversa aberta.')
 end
 function N.Open(row)
  N.Save();task.spawn(function()local data,e=call('chat.read',{id=row.id});if not data then notice(e);return end;restore(data)end)
 end
 renderer=function()
  for _,v in ipairs(N.List:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end
  local query=N.Search.Text:lower()
  for _,row in ipairs(N.Rows)do if(row.archived==true)==N.ShowArchived and(query==''or tostring(row.title):lower():find(query,1,true))then
   local frame=D.New('Frame',{Size=UDim2.new(1,-4,0,44),BackgroundTransparency=1,ZIndex=58},N.List)
   local b=D.Button(frame,row.title,{Size=UDim2.new(1,-46,1,0),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=59});b.Activated:Connect(function()N.Open(row)end)
   local more=D.Button(frame,'…',{Position=UDim2.new(1,-44,0,0),Size=UDim2.fromOffset(44,44),TextSize=20,ZIndex=59})
   more.Activated:Connect(function()
    local old=U.Body:FindFirstChild('ManageConversation');if old then old:Destroy()end
    local menu=D.Frame(U.Body,{Name='ManageConversation',Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,0,208),ZIndex=105,BackgroundColor3=C.panel})
    local rename=D.Box(menu,'Nome da conversa',{Text=row.title,Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-72,0,44),ZIndex=106});D.IconButton(menu,'CloseConversationMenu','close','Fechar',{Position=UDim2.new(1,-56,0,6),Size=UDim2.fromOffset(48,48),ZIndex=109}).Activated:Connect(function()menu:Destroy()end)
    for i,caption in ipairs({'Renomear',row.archived and'Desarquivar'or'Arquivar','Excluir'})do
     local button=D.Button(menu,caption,{Position=UDim2.fromOffset(8,58+(i-1)*48),Size=UDim2.new(1,-16,0,44),ZIndex=106});local armed=false
     button.Activated:Connect(function()if i==3 and not armed then armed=true;button.Text='Confirmar exclusão';return end
      task.spawn(function()
       local data,e=call('chat.read',{id=row.id});if not data then notice(e);return end
       local ok,why;if i==3 then ok,why=call('chat.delete',{id=row.id})else data.title=i==1 and rename.Text or data.title;data.archived=i==2 and not row.archived or row.archived;ok,why=call('chat.save',data)end
       if not ok then notice(why);return end
       if row.id==current then if i==3 then token=token+1;N.Messages={};N.Title='Nova conversa';current=Http:GenerateGUID(false);archivedCurrent=false;U.ClearConversation();if U.OnSwitchConversation then U.OnSwitchConversation()end elseif i==1 then N.Title=data.title elseif i==2 then archivedCurrent=data.archived end end
       menu:Destroy();N.Refresh()
      end)
     end)
    end
   end)
  end end
 end
 function N.Refresh()task.spawn(function()local data,e=call('chat.list');if type(data)=='table'then N.Rows=data.items or{};renderer()else notice(e or'Histórico indisponível; a conversa continua aberta.')end end)end
 local add=U.Add;U.Add=function(text,user)
  local block=add(text,user);if not replay then N.Messages[#N.Messages+1]={role=user and'user'or'assistant',text=tostring(text):sub(1,1200)};if #N.Messages>32 then table.remove(N.Messages,1)end;if user and N.Title=='Nova conversa'then N.Title=tostring(text):gsub('[%c]',' '):sub(1,44)end
   token=token+1;local mine=token;task.delay(3,function()if mine==token then N.Save()end end)
  end;return block
 end
 U.BeforeNewChat=function()N.Save();token=token+1;N.Messages={};N.Title='Nova conversa';current=Http:GenerateGUID(false);archivedCurrent=false end
 function N.OpenShare()shade.Visible=true;N.Layout();code.Text='';note.Text='Compartilha somente as últimas oito mensagens filtradas, por sete dias. Seus outros chats e sua conta Roblox ficam privados.'end
 U.OpenShare=N.OpenShare;U.Share.Activated:Connect(N.OpenShare)
 create.Activated:Connect(function()N.Save(function(saved)if not saved then return end;task.spawn(function()local data,e=call('chat.share',{id=current,confirm=true});if data then code.Text=data.code;note.Text='Código criado. Selecione e copie para compartilhar. Ele não dá acesso à sua conta.'else notice(e)end end)end)end)
 selectCode.Activated:Connect(function()code:CaptureFocus();code.CursorPosition=#code.Text+1;code.SelectionStart=1 end)
 openCode.Activated:Connect(function()N.Save();task.spawn(function()local data,e=call('chat.code',{code=code.Text});if not data then notice(e);return end;shade.Visible=false;restore(data)end)end)
 close.Activated:Connect(function()shade.Visible=false end);N.Search:GetPropertyChangedSignal('Text'):Connect(renderer);N.Archived.Activated:Connect(function()N.ShowArchived=not N.ShowArchived;N.Archived.Text=N.ShowArchived and'Voltar aos chats'or'Conversas arquivadas';renderer()end)
 U.Tabs:GetPropertyChangedSignal('AbsoluteSize'):Connect(N.Layout);U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if U.Root.Visible then N.Refresh()else shade.Visible=false;N.Save()end end)
 U.OpenArchived=function()N.ShowArchived=true;N.Archived.Text='Voltar aos chats';renderer();N.Refresh()end
 N.Layout();return N
end
return M
