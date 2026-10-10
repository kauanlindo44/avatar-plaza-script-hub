-- 09I5_ASSISTANT_QUESTIONNAIRE | ModuleScript | ReplicatedStorage | V56
-- Escolhas no fluxo da conversa, com orçamento e confirmação explícitos.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local M={}
function M.Build(U,onConfirm)
 local Q={Options={count=1,format='2D',keep=true,budget=100,tool='Criar',scope='Tudo',pieceBudget=100000},Plan='Normal'}
 Q.Shade=D.Frame(U.Chat,{Name='LookQuestionnaire',BackgroundColor3=C.panel,Visible=false,Size=UDim2.new(1,-6,0,330)})
 Q.Root=Q.Shade
 Q.Title=D.Text(Q.Root,'Vamos ajustar seu pedido',{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-68,0,44),TextSize=17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 Q.Close=D.IconButton(Q.Root,'CloseQuestionnaire','close','Voltar',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-4,0,4),Size=UDim2.fromOffset(48,48)})
 Q.Fields=D.New('Frame',{Position=UDim2.fromOffset(8,56),BackgroundTransparency=1},Q.Root)
 Q.Format=D.Button(Q.Fields,'Roupa: clássica 2D',{TextSize=13})
 Q.Keep=D.Button(Q.Fields,'Manter minhas peças',{TextSize=13})
 Q.Count=D.Button(Q.Fields,'1 look',{TextSize=13})
 Q.BudgetHost=D.New('Frame',{BackgroundTransparency=1},Q.Fields)
 Q.Budget=D.Box(Q.BudgetHost,'Robux para peças novas',{Text='100',Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,0,0,44),TextSize=13})
 Q.BudgetLabel=D.Text(Q.BudgetHost,'Orçamento • Robux',{Size=UDim2.new(1,0,0,18),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
 Q.Scope=D.Button(Q.Fields,'Alterar: look todo',{TextSize=13})
 Q.Body=D.Button(Q.Fields,'Corpo: manter atual',{TextSize=13})
 Q.Tool=D.Button(Q.Fields,'Criar novos looks',{TextSize=13})
 Q.Color=D.Box(Q.Fields,'Cor desejada (opcional)',{TextSize=13})
 Q.Piece=D.Box(Q.Fields,'Máximo por peça (Pro)',{Text='',TextSize=13})
 Q.Confirm=D.Button(Q.Root,'Confirmar e criar',{Position=UDim2.new(0,8,1,-52),Size=UDim2.new(1,-16,0,44),BackgroundColor3=C.orange,TextColor3=C.bg})
 Q.Format.Activated:Connect(function()Q.Options.format=Q.Options.format=='2D'and'3D'or'2D';Q.Format.Text=Q.Options.format=='2D'and'Roupa: clássica 2D'or'Roupa: camadas 3D'end)
 Q.Keep.Activated:Connect(function()Q.Options.keep=not Q.Options.keep;Q.Keep.Text=Q.Options.keep and'Manter minhas peças'or'Trocar roupas e acessórios'end)
 Q.Count.Activated:Connect(function()Q.Options.count=Q.Options.count%Config.Plans[Q.Plan].count+1;Q.Count.Text=Q.Options.count..(Q.Options.count==1 and' look'or' variações do pedido')end)
 local scope=1;local scopes={'Tudo','Cabelo','Roupas','Acessórios','Corpo'}
 Q.Scope.Activated:Connect(function()
  scope=scope%#scopes+1;Q.Options.scope=scopes[scope];Q.Scope.Text='Alterar: '..(scope==1 and'look todo'or scopes[scope])
  if scope~=1 then Q.Options.keep=true;Q.Keep.Text='Preservar outras peças'else Q.Keep.Text=Q.Options.keep and'Manter minhas peças'or'Trocar roupas e acessórios'end
 end)
 local tool=1;Q.Tool.Activated:Connect(function()if Q.Plan~='Pro'then return end;tool=tool%#Config.Tools+1;Q.Options.tool=Config.Tools[tool][1];Q.Tool.Text=Config.Tools[tool][2]end)
 Q.Body.Activated:Connect(function()Q.Options.body=not Q.Options.body;Q.Body.Text=Q.Options.body and'Corpo: buscar no catálogo'or'Corpo: manter atual'end)
 Q.Close.Activated:Connect(function()Q.Shade.Visible=false end)
 Q.Confirm.Activated:Connect(function()
  local n=tonumber(Q.Budget.Text);if not n or n~=n or n<0 or n>100000 then Q.Budget.Text='100';Q.Title.Text='Use um orçamento de 0 a 100.000 Robux';return end
  Q.Options.budget=math.floor(n);Q.Options.color=Q.Color.Text:sub(1,24);Q.Options.pieceBudget=tonumber(Q.Piece.Text)or 100000
  Q.Shade.Visible=false;onConfirm(Q.Options)
 end)
 function Q.Layout()
  local rw=math.max(240,U.Chat.AbsoluteSize.X-10);local cols=rw>=650 and 3 or 2
  local controls={Q.Format,Q.Keep,Q.Count,Q.BudgetHost,Q.Scope,Q.Body}
  if Q.Plan=='Pro'then controls[#controls+1]=Q.Tool;controls[#controls+1]=Q.Color;controls[#controls+1]=Q.Piece end
  local rows=math.ceil(#controls/cols);local cw=(rw-16-(cols-1)*6)/cols;local rh=112+rows*68
  Q.Shade.Size=UDim2.new(1,-6,0,rh);Bounds.Rect(Q.Fields,8,56,rw-16,rows*68)
  for i,b in ipairs(controls)do Bounds.Rect(b,(i-1)%cols*(cw+6),math.floor((i-1)/cols)*68,cw,b==Q.BudgetHost and 62 or 62)end
  Q.Tool.Visible=Q.Plan=='Pro';Q.Color.Visible=Q.Plan=='Pro';Q.Piece.Visible=Q.Plan=='Pro'
 end
 function Q.Open(plan)
  Q.Plan=Config.Plans[plan]and plan or'Normal';Q.Options.count=math.min(Q.Options.count,Config.Plans[Q.Plan].count);Q.Count.Text=Q.Options.count..' look(s)'
  if Q.Plan~='Pro'then tool=1;Q.Options.tool='Criar';Q.Tool.Text='Criar novos looks'end
  Q.Title.Text='Vamos ajustar seu pedido';Q.Shade.LayoutOrder=U.NextOrder();Q.Shade.Visible=true;U.Welcome.Visible=false;Q.Layout();U.ScrollBottom()
 end
 U.Chat:GetPropertyChangedSignal('AbsoluteSize'):Connect(Q.Layout);return Q
end
return M
