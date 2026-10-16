-- 09I5_ASSISTANT_QUESTIONNAIRE | ModuleScript | ReplicatedStorage | V66 (SUBSTITUIR)
-- Formulário independente da conversa, opções em grade e confirmação resumida.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'));local Choice=require(Rep:WaitForChild('07UI_CHOICE_LIST'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local M={Version='V66'}
function M.Build(U,onConfirm)
 local Q={Options={count=1,format='2D',keep=true,budget=100,tool='Criar',scope='Tudo',pieceBudget=100000},Plan='Normal'}
 Q.Shade=D.Frame(U.Body,{Name='LookQuestionnaire',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.bg,ZIndex=70});Q.Root=Q.Shade
 Fx.Surface(Q.Root,Color3.fromRGB(32,30,42),Color3.fromRGB(47,33,43),C.orange)
 Q.Title=D.Text(Q.Root,'Personalize seu look',{TextSize=19,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=71})
 Q.Close=D.IconButton(Q.Root,'CloseQuestionnaire','close','Voltar para a conversa',{ZIndex=72})
 Q.Fields=D.New('Frame',{BackgroundTransparency=1,ZIndex=71},Q.Root)
 Q.Format=D.Button(Q.Fields,'Roupa · clássica 2D',{TextSize=12,ZIndex=72});Q.Keep=D.Button(Q.Fields,'Suas peças · manter',{TextSize=12,ZIndex=72})
 Q.Count=D.Button(Q.Fields,'Variações · 1 look',{TextSize=12,ZIndex=72});Q.Scope=D.Button(Q.Fields,'Mudar · look todo',{TextSize=12,ZIndex=72})
 Q.BudgetField=D.New('Frame',{Name='BudgetField',BackgroundTransparency=1,ZIndex=72},Q.Fields)
 Q.Budget=D.Box(Q.BudgetField,'Robux · 0 = grátis',{Text='100',Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,-50,1,0),TextSize=12,ZIndex=72})
 Q.BudgetList=D.Button(Q.BudgetField,'▾',{Name='ChooseBudget',Position=UDim2.new(1,-44,0,0),Size=UDim2.new(0,44,1,0),TextSize=20,ZIndex=72})
 Q.Style=D.Button(Q.Fields,'Estilo · usar descrição ▾',{Name='ChooseStyle',TextSize=12,ZIndex=72})
 Q.Body=D.Button(Q.Fields,'Corpo · manter atual',{TextSize=12,ZIndex=72});Q.Color=D.Box(Q.Fields,'Cor desejada · opcional',{TextSize=12,ZIndex=72})
 Q.Tool=D.Button(Q.Fields,'Modo · criar looks',{TextSize=12,ZIndex=72});Q.Piece=D.Box(Q.Fields,'Máximo por peça · opcional',{Text='',TextSize=12,ZIndex=72})
 Q.Summary=D.Text(Q.Root,'',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 Q.Confirm=D.Button(Q.Root,'Confirmar e buscar peças',{BackgroundColor3=C.orange,TextColor3=C.bg,TextSize=13,ZIndex=72});Fx.Button(Q.Confirm,C.orange)
 Q.Choices=Choice.Build(Q.Root)
 function Q.OpenStyles()
  local choices={{id='',name='Usar minha descrição',note='Escreva livremente o estilo que você procura.'}}
  for _,v in ipairs(Styles.Styles)do choices[#choices+1]=v end
  Q.Choices.Open('Escolha seu estilo',choices,Q.Options.style or'',function(v)Q.Options.style=v.id~=''and v.id or nil;Q.Style.Text='Estilo · '..v.name..' ▾'end)
 end
 Q.Style.Activated:Connect(Q.OpenStyles)
 function Q.OpenBudget()
  local choices={};for _,n in ipairs({0,25,55,100,250,500,1000,2500})do choices[#choices+1]={id=tostring(n),name=n==0 and'Grátis · 0 Robux'or('Até '..n..' Robux'),note=n==0 and'Somente peças com preço confirmado como zero.'or'Orçamento total para peças novas do look.'}end
  choices[#choices+1]={id='custom',name='Outro valor',note='Digite seu limite no campo de orçamento.'}
  Q.Choices.Open('Orçamento para o look',choices,Q.Budget.Text,function(v)if v.id=='custom'then Q.Budget:CaptureFocus()else Q.Budget.Text=v.id end end)
 end
 Q.BudgetList.Activated:Connect(Q.OpenBudget)
 local scopes={'Tudo','Cabelo','Roupas','Acessórios','Corpo'};local si,ti=1,1
 function Q.CloseGuide()Q.Choices.Hide();Q.Shade.Visible=false;U.Guiding=false;U.Layout()end
 local function summary()Q.Summary.Text=Q.Options.count..' look(s) • '..Q.Options.format..' • até '..tostring(tonumber(Q.Budget.Text)or'?')..' Robux para peças novas'end
 Q.Format.Activated:Connect(function()Q.Options.format=Q.Options.format=='2D'and'3D'or'2D';Q.Format.Text=Q.Options.format=='2D'and'Roupa · clássica 2D'or'Roupa · camadas 3D';summary()end)
 Q.Keep.Activated:Connect(function()Q.Options.keep=not Q.Options.keep;Q.Keep.Text=Q.Options.keep and'Suas peças · manter'or'Roupas e acessórios · trocar';summary()end)
 Q.Count.Activated:Connect(function()Q.Options.count=Q.Options.count%Config.Plans[Q.Plan].count+1;Q.Count.Text='Variações · '..Q.Options.count;summary()end)
 Q.Scope.Activated:Connect(function()si=si%#scopes+1;Q.Options.scope=scopes[si];Q.Scope.Text='Mudar · '..(si==1 and'look todo'or scopes[si]);if si~=1 then Q.Options.keep=true;Q.Keep.Text='Outras peças · preservar'end end)
 Q.Body.Activated:Connect(function()Q.Options.body=not Q.Options.body;Q.Body.Text=Q.Options.body and'Corpo · pesquisar novo'or'Corpo · manter atual'end)
 Q.Tool.Activated:Connect(function()if Q.Plan=='Pro'then ti=ti%#Config.Tools+1;Q.Options.tool=Config.Tools[ti][1];Q.Tool.Text='Modo · '..Config.Tools[ti][2]end end)
 Q.Budget:GetPropertyChangedSignal('Text'):Connect(summary);Q.Close.Activated:Connect(Q.CloseGuide)
 Q.Confirm.Activated:Connect(function()
  local n=tonumber(Q.Budget.Text);local piece=Q.Piece.Text==''and 100000 or tonumber(Q.Piece.Text)
  if not n or n~=n or n<0 or n>100000 or not piece or piece~=piece or piece<0 or piece>100000 then Q.Summary.Text='Use valores de 0 a 100.000. Zero busca peças grátis.';return end
  Q.Options.budget=math.floor(n);Q.Options.pieceBudget=math.floor(piece);Q.Options.color=Q.Color.Text:sub(1,24)
  local out={};for k,v in pairs(Q.Options)do out[k]=v end;Q.CloseGuide();onConfirm(out)
 end)
 function Q.Layout()
  local w,h=U.Body.AbsoluteSize.X,U.Body.AbsoluteSize.Y;if w<=0 or h<=0 then return end
  local controls={Q.Style,Q.BudgetField,Q.Format,Q.Keep,Q.Count,Q.Scope,Q.Body,Q.Color}
  if Q.Plan=='Pro'then controls[#controls+1]=Q.Tool;controls[#controls+1]=Q.Piece end
  Q.Tool.Visible=Q.Plan=='Pro';Q.Piece.Visible=Q.Plan=='Pro'
  local cols=w>=550 and 4 or 2;local rows=math.ceil(#controls/cols);local gap=6;local cw=(w-16-(cols-1)*gap)/cols
  local rh=math.max(44,math.min(66,math.floor((h-106-(rows-1)*gap)/rows)))
  Bounds.Rect(Q.Title,8,2,w-68,44);Bounds.Rect(Q.Close,w-52,0,48,48)
  Bounds.Rect(Q.Fields,8,50,w-16,rows*(rh+gap)-gap)
  for i,o in ipairs(controls)do Bounds.Rect(o,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(rh+gap),cw,rh)end
  Bounds.Rect(Q.Summary,10,h-54,w-20,16);Bounds.Rect(Q.Confirm,8,h-44,w-16,44)
 end
 function Q.Open(plan)
  local inferred=Styles.Find(U.Input.Text);if inferred then Q.Options.style=inferred.id;Q.Style.Text='Estilo · '..inferred.name..' ▾'end
  local text=Styles.Normalize(U.Input.Text);local n=tonumber(text:match('ate%s+(%d+)')or text:match('(%d+)%s*robux'));if n and n<=100000 then Q.Budget.Text=tostring(n)elseif text:find('gratis',1,true)then Q.Budget.Text='0'end
  Q.Plan=Config.Plans[plan]and plan or'Normal';Q.Options.count=math.min(Q.Options.count,Config.Plans[Q.Plan].count)
  Q.Count.Text='Variações · '..Q.Options.count;U.Guiding=true;U.Layout();Q.Layout();Q.Shade.Visible=true;summary()
 end
 U.Body:GetPropertyChangedSignal('AbsoluteSize'):Connect(Q.Layout);return Q
end
return M
