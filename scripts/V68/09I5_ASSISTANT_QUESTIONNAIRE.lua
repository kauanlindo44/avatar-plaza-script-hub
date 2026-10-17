-- 09I5_ASSISTANT_QUESTIONNAIRE | ModuleScript | ReplicatedStorage | V68 (SUBSTITUIR)
-- Campos com listas, resumo editável e opções novas em cada pedido.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'));local Choice=require(Rep:WaitForChild('07UI_CHOICE_LIST'));local Plan=require(Rep:WaitForChild('09I12_REQUEST_PLAN'))
local M={Version='V68'}
function M.Build(U,onConfirm)
 local Q={Options={},Plan='Normal',Advanced=false}
 Q.Shade=D.Frame(U.Body,{Name='LookQuestionnaire',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=Color3.fromRGB(30,31,35),ZIndex=70});Q.Root=Q.Shade
 Q.Title=D.Text(Q.Root,'Confira seu pedido',{TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=71})
 Q.Close=D.IconButton(Q.Root,'CloseQuestionnaire','close','Voltar à conversa',{ZIndex=79})
 Q.Fields=D.Scroll(Q.Root,{Name='LookRequestFields',BackgroundTransparency=1,ScrollBarThickness=2,ZIndex=71,AutomaticCanvasSize=Enum.AutomaticSize.None})
 local function button(name,text)local b=D.Button(Q.Fields,text,{Name=name,TextSize=12,ZIndex=72,TextXAlignment=Enum.TextXAlignment.Left});return b end
 Q.Style=button('ChooseStyle','Estilo ▾');Q.BudgetField=D.New('Frame',{Name='BudgetField',BackgroundTransparency=1,ZIndex=72},Q.Fields)
 Q.Budget=D.Box(Q.BudgetField,'Robux por look',{Text='100',Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,-48,1,0),TextSize=13,ZIndex=72})
 Q.BudgetList=D.Button(Q.BudgetField,'▾',{Name='ChooseBudget',Position=UDim2.new(1,-44,0,0),Size=UDim2.new(0,44,1,0),TextSize=18,ZIndex=73})
 Q.Scope=button('ChooseScope','Alterar ▾');Q.Format=button('ChooseFormat','Roupa ▾');Q.Count=button('ChooseCount','Quantidade ▾');Q.Color=button('ChooseColor','Cor ▾')
 Q.Exclude=button('ChooseExclusions','Não incluir ▾');Q.More=button('AdvancedRequest','Opções avançadas ▾')
 Q.Body=button('ChooseBody','Corpo atual');Q.Tool=button('ChooseTool','Modo criar');Q.Piece=D.Box(Q.Fields,'Máximo por peça · opcional',{Text='',TextSize=12,ZIndex=72})
 Q.Keep=Q.Scope
 Q.Summary=D.Text(Q.Root,'',{Name='ConfirmedRequestSummary',TextSize=12,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 Q.Confirm=D.Button(Q.Root,'Buscar looks completos',{BackgroundColor3=C.orange,TextColor3=C.bg,TextSize=13,ZIndex=74})
 Q.Choices=Choice.Build(Q.Root)
 local function update()
  local p=Q.Options;p.budget=tonumber(Q.Budget.Text)or 100
  local style=Styles.Get(p.style);Q.Style.Text='Estilo · '..(style and style.name or p.query or'minha descrição')..' ▾'
  Q.Scope.Text=p.scope=='Tudo'and'Criar look completo ▾'or('Mudar '..p.scope..' ▾');Q.Format.Text=p.format=='3D'and'Roupa em camadas 3D ▾'or'Roupa clássica 2D ▾'
  Q.Count.Text='Quantidade · '..p.count..' look(s) ▾';Q.Color.Text='Cor · '..(p.color~=''and p.color or'livre')..' ▾'
  Q.Exclude.Text='Não incluir · '..(#p.excluded==0 and'nada marcado'or #p.excluded..' tipo(s)')..' ▾'
  Q.Summary.Text=Plan.Summary(p);Q.Confirm.Text=p.scope=='Tudo'and'Buscar looks completos'or'Buscar peças para alterar'
  Q.Body.Text=p.body and'Corpo · pesquisar novo'or'Corpo · manter atual';Q.Tool.Text='Modo · '..p.tool
 end
 function Q.OpenStyles()
  local items={{id='',name='Usar minha descrição',note='A descrição desta mensagem define a busca.'}};for _,v in ipairs(Styles.Styles)do items[#items+1]=v end
  Q.Choices.Open('Estilo do seu look',items,Q.Options.style or'',function(v)Q.Options.style=v.id~=''and v.id or nil;Q.Options.styleEdited=true;update()end)
 end
 function Q.OpenBudget()
  local rows={};for _,n in ipairs({0,25,55,100,250,500,1000,2500})do rows[#rows+1]={id=tostring(n),name=n==0 and'Grátis'or('Até '..n..' Robux por look'),note='Cada look tem seu próprio limite; não é o total do lote.'}end
  rows[#rows+1]={id='custom',name='Digitar outro valor'};Q.Choices.Open('Orçamento',rows,Q.Budget.Text,function(v)if v.id=='custom'then Q.Budget:CaptureFocus()else Q.Budget.Text=v.id;update()end end)
 end
 local function choose(b,title,values,key)
  b.Activated:Connect(function()local rows={};for _,v in ipairs(values)do rows[#rows+1]=type(v)=='table'and v or{id=v,name=v}end
   Q.Choices.Open(title,rows,tostring(Q.Options[key]),function(v)Q.Options[key]=v.id;Q.Options.keep=Q.Options.scope~='Tudo';update()end)
  end)
 end
 Q.Style.Activated:Connect(Q.OpenStyles);Q.BudgetList.Activated:Connect(Q.OpenBudget)
 choose(Q.Scope,'O que você quer mudar?',{{id='Tudo',name='Criar um look completo',note='Camisa e calça ou camadas; substitui roupas e acessórios.'},{id='Cabelo',name='Somente cabelo',note='Preserva as outras peças.'},{id='Roupas',name='Somente roupas'},{id='Acessórios',name='Somente acessórios'},{id='Corpo',name='Somente corpo'}},'scope')
 choose(Q.Format,'Tipo de roupa',{{id='2D',name='Clássica 2D',note='Camisa e calça clássicas.'},{id='3D',name='Camadas 3D',note='Camisetas, casacos, calças, shorts e saias compatíveis.'}},'format')
 local colors={{id='',name='Cor livre'}};for _,v in ipairs(Plan.Colors)do colors[#colors+1]={id=v[2],name=v[1]}end;choose(Q.Color,'Cor das peças',colors,'color')
 Q.Count.Activated:Connect(function()local rows={};for n=1,Config.Plans[Q.Plan].count do rows[#rows+1]={id=tostring(n),name=n..' look(s)',note='Variações diferentes do mesmo pedido.'}end
  Q.Choices.Open('Quantidade de looks',rows,tostring(Q.Options.count),function(v)Q.Options.count=tonumber(v.id);update()end)
 end)
 Q.Exclude.Activated:Connect(function()
  local rows={{id='clear',name='Limpar exclusões'}};local seen={};for _,v in ipairs(Plan.Pieces)do if not seen[v[2]]then seen[v[2]]=true;local marked=table.find(Q.Options.excluded,v[2])~=nil;rows[#rows+1]={id=v[2],name=(marked and'✓ 'or'')..v[1],note=marked and'Toque para permitir novamente.'or'Toque para excluir este tipo.'}end end
  Q.Choices.Open('Peças que você não quer',rows,nil,function(v)if v.id=='clear'then Q.Options.excluded={}else local i=table.find(Q.Options.excluded,v.id);if i then table.remove(Q.Options.excluded,i)else Q.Options.excluded[#Q.Options.excluded+1]=v.id end end;update()end)
 end)
 Q.More.Activated:Connect(function()Q.Advanced=not Q.Advanced;Q.More.Text=Q.Advanced and'Opções avançadas ▴'or'Opções avançadas ▾';Q.Layout()end)
 Q.Body.Activated:Connect(function()Q.Options.body=not Q.Options.body;update()end)
 Q.Tool.Activated:Connect(function()if Q.Plan~='Pro'then return end;local rows={};for _,v in ipairs(Config.Tools)do rows[#rows+1]={id=v[1],name=v[2]}end;Q.Choices.Open('Modo de busca',rows,Q.Options.tool,function(v)Q.Options.tool=v.id;update()end)end)
 function Q.Reset()Q.Options={};Q.Advanced=false;Q.Choices.Hide();Q.Shade.Visible=false end
 function Q.CloseGuide()Q.Budget:ReleaseFocus(false);Q.Piece:ReleaseFocus(false);Q.Choices.Hide();Q.Shade.Visible=false;U.Guiding=false;U.Layout()end
 Q.Close.Activated:Connect(Q.CloseGuide);Q.Budget:GetPropertyChangedSignal('Text'):Connect(function()if Q.Options.count then update()end end)
 Q.Confirm.Activated:Connect(function()
  local n=tonumber(Q.Budget.Text);local piece=Q.Piece.Text==''and 100000 or tonumber(Q.Piece.Text)
  if not n or n~=n or n<0 or n>100000 or not piece or piece~=piece or piece<0 or piece>100000 then Q.Summary.Text='Digite valores entre 0 e 100.000 Robux.';return end
  Q.Options.budget=math.floor(n);Q.Options.pieceBudget=math.floor(piece);Q.Options.confirmed=true;local out={};for k,v in pairs(Q.Options)do out[k]=v end;Q.CloseGuide();onConfirm(out)
 end)
 function Q.Layout()
  local w,h=U.Body.AbsoluteSize.X,U.Body.AbsoluteSize.Y;if w<1 or h<1 then return end
  local controls={Q.Style,Q.BudgetField,Q.Scope,Q.Format,Q.Count,Q.Color,Q.Exclude,Q.More};for _,b in ipairs(controls)do b.Visible=true end;Q.Title.Visible=true;Q.Summary.Visible=true;Q.Confirm.Visible=true;Q.Fields.ScrollingEnabled=true
  Q.Body.Visible=Q.Advanced;Q.Tool.Visible=Q.Advanced and Q.Plan=='Pro';Q.Piece.Visible=Q.Advanced
  if Q.Advanced then controls[#controls+1]=Q.Body;if Q.Plan=='Pro'then controls[#controls+1]=Q.Tool end;controls[#controls+1]=Q.Piece end
  local UIS=game:GetService('UserInputService');local typing=false;pcall(function()typing=UIS.OnScreenKeyboardVisible==true end)
  if typing and h<200 then
   local focused;pcall(function()focused=UIS:GetFocusedTextBox()end);local selected=focused==Q.Piece and Q.Piece or Q.BudgetField
   for _,b in ipairs(controls)do b.Visible=b==selected end;Q.Body.Visible=false;Q.Tool.Visible=false;Q.Piece.Visible=selected==Q.Piece;Q.Title.Visible=false;Q.Summary.Visible=false
   Bounds.Rect(Q.Close,w-54,0,48,48);Bounds.Rect(Q.Fields,8,0,w-74,48);Bounds.Rect(selected,0,0,w-78,44);Q.Fields.CanvasSize=UDim2.fromOffset(0,44);Q.Fields.ScrollingEnabled=false
   Q.Confirm.Visible=h>=98;Bounds.Rect(Q.Confirm,8,h-44,w-16,44);return
  end
  local cols=w>=480 and 4 or 2;local gap=6;local cw=(w-20-(cols-1)*gap)/cols;local rowh=math.clamp((h-146)/math.ceil(#controls/cols)-gap,44,64)
  Bounds.Rect(Q.Title,10,0,w-72,44);Bounds.Rect(Q.Close,w-54,0,48,48)
  local summaryH=h<340 and 46 or 64;Bounds.Rect(Q.Fields,10,50,w-20,math.max(50,h-summaryH-106))
  for i,b in ipairs(controls)do Bounds.Rect(b,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(rowh+gap),cw,rowh)end
  Q.Fields.CanvasSize=UDim2.fromOffset(0,math.ceil(#controls/cols)*(rowh+gap));Bounds.Rect(Q.Summary,12,h-summaryH-48,w-24,summaryH);Bounds.Rect(Q.Confirm,10,h-44,w-20,44)
 end
 function Q.Open(plan,raw)
  Q.Plan=Config.Plans[plan]and plan or'Normal';Q.Options=Plan.Parse(raw or U.Input.Text);Q.Options.count=math.min(Q.Options.count or 1,Config.Plans[Q.Plan].count);Q.Options.tool='Criar';Q.Options.body=false;Q.Options.color=Q.Options.color or''
  Q.Budget.Text=tostring(Q.Options.budget or 100);Q.Piece.Text='';Q.Advanced=false;Q.More.Text='Opções avançadas ▾';U.Guiding=true;U.Layout();Q.Layout();Q.Shade.Visible=true;update()
 end
 U.Body:GetPropertyChangedSignal('AbsoluteSize'):Connect(Q.Layout);Q.Budget.FocusLost:Connect(function()task.defer(Q.Layout)end);Q.Piece.FocusLost:Connect(function()task.defer(Q.Layout)end);return Q
end
return M
