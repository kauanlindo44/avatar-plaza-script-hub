-- 09I5_ASSISTANT_QUESTIONNAIRE | ModuleScript | ReplicatedStorage | V55 (NOVO)
-- Enquete curta com confirmação, orçamento e formato de roupas.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local M={}
function M.Build(U,onConfirm)
 local safe=Bounds.Bind(U.Gui)
 local Q={Options={count=1,format='2D',keep=true,budget=100,tool='Criar',pieceBudget=100000},Plan='Normal'}
 Q.Shade=D.New('Frame',{Name='QuestionnaireShade',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=.12,Visible=false,Active=true,ZIndex=90},U.Root)
 Q.Root=D.Frame(Q.Shade,{Name='LookQuestionnaire',BackgroundColor3=C.panel,ZIndex=91})
 Q.Title=D.Text(Q.Root,'Antes de criar…',{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-70,0,44),TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92})
 Q.Close=D.IconButton(Q.Root,'CloseQuestionnaire','close','Voltar',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-4,0,4),Size=UDim2.fromOffset(48,48),ZIndex=94})
 Q.Fields=D.New('Frame',{Position=UDim2.fromOffset(8,56),BackgroundTransparency=1,ZIndex=92},Q.Root)
 Q.Format=D.Button(Q.Fields,'Roupa: clássica 2D',{ZIndex=93,TextSize=13})
 Q.Keep=D.Button(Q.Fields,'Manter minhas peças',{ZIndex=93,TextSize=13})
 Q.Count=D.Button(Q.Fields,'1 look',{ZIndex=93,TextSize=13})
 Q.Budget=D.Box(Q.Fields,'Orçamento das peças novas',{Text='100',ZIndex=93,TextSize=13})
 Q.BudgetLabel=D.Text(Q.Fields,'Orçamento • Robux',{ZIndex=94,TextSize=11,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left});Q.BudgetLabel.TextSize=11
 Q.Tool=D.Button(Q.Fields,'Criar novos looks',{ZIndex=93,TextSize=13})
 Q.Color=D.Box(Q.Fields,'Cor desejada (opcional)',{ZIndex=93,TextSize=13})
 Q.Piece=D.Box(Q.Fields,'Máximo por peça (Pro)',{Text='',ZIndex=93,TextSize=13})
 Q.Body=D.Button(Q.Fields,'Corpo: manter atual',{ZIndex=93,TextSize=13})
 Q.Confirm=D.Button(Q.Root,'Confirmar e criar',{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,44),BackgroundColor3=C.orange,TextColor3=C.bg,ZIndex=94})
 Q.Format.Activated:Connect(function()Q.Options.format=Q.Options.format=='2D'and'3D'or'2D';Q.Format.Text=Q.Options.format=='2D'and'Roupa: clássica 2D'or'Roupa: camadas 3D'end)
 Q.Keep.Activated:Connect(function()Q.Options.keep=not Q.Options.keep;Q.Keep.Text=Q.Options.keep and'Manter minhas peças'or'Trocar roupas e acessórios'end)
 Q.Count.Activated:Connect(function()Q.Options.count=Q.Options.count%Config.Plans[Q.Plan].count+1;Q.Count.Text=Q.Options.count..(Q.Options.count==1 and' look'or' variações do mesmo pedido')end)
 local tool=1;Q.Tool.Activated:Connect(function()if Q.Plan~='Pro'then return end;tool=tool%#Config.Tools+1;Q.Options.tool=Config.Tools[tool][1];Q.Tool.Text=Config.Tools[tool][2]end)
 Q.Body.Activated:Connect(function()Q.Options.body=not Q.Options.body;Q.Body.Text=Q.Options.body and'Corpo: buscar no catálogo'or'Corpo: manter atual'end)
 Q.Close.Activated:Connect(function()Q.Shade.Visible=false end)
 Q.Confirm.Activated:Connect(function()
  local n=tonumber(Q.Budget.Text);if not n or n~=n or n<0 or n>100000 then Q.Budget.Text='100';return end
  Q.Options.budget=math.floor(n);Q.Options.color=Q.Color.Text:sub(1,24);Q.Options.pieceBudget=tonumber(Q.Piece.Text)or 100000
  Q.Shade.Visible=false;onConfirm(Q.Options)
 end)
 function Q.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local ah=h-it-ib
  local rw=math.min(650,aw-12);local rh=math.min(390,ah-12);Bounds.Rect(Q.Root,il+(aw-rw)/2,it+(ah-rh)/2,rw,rh)
  local cols=rh<310 and rw>=460 and 4 or 2;local rows=math.ceil(8/cols)
  local cw=(rw-16-(cols-1)*6)/cols;local rowh=(rh-116-(rows-1)*6)/rows;Bounds.Rect(Q.Fields,8,56,rw-16,rh-116)
  for i,b in ipairs({Q.Format,Q.Keep,Q.Count,Q.Budget,Q.Tool,Q.Color,Q.Piece,Q.Body})do Bounds.Rect(b,(i-1)%cols*(cw+6),math.floor((i-1)/cols)*(rowh+6),cw,rowh)end
  local bx=3%cols*(cw+6);local by=math.floor(3/cols)*(rowh+6);local labelH=math.max(12,rowh-44)
  Bounds.Rect(Q.BudgetLabel,bx+4,by,cw-8,labelH);Bounds.Rect(Q.Budget,bx,by+labelH,cw,rowh-labelH)
 end
 function Q.Open(plan)
  Q.Plan=plan or'Normal';Q.Options.count=math.min(Q.Options.count,Config.Plans[Q.Plan].count);Q.Count.Text=Q.Options.count..' look(s)'
  if Q.Plan~='Pro'then tool=1;Q.Options.tool='Criar';Q.Tool.Text='Criar novos looks'end
  Q.Shade.Visible=true;Q.Tool.Active=Q.Plan=='Pro';Q.Piece.Visible=Q.Plan=='Pro';Q.Layout()
 end
 Q.Shade:GetPropertyChangedSignal('AbsoluteSize'):Connect(Q.Layout);return Q
end
return M
