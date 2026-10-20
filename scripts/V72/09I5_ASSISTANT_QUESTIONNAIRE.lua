-- 09I5_ASSISTANT_QUESTIONNAIRE | ModuleScript | ReplicatedStorage | V72 (SUBSTITUIR)
-- Pedido em quatro etapas, corpo visual obrigatório e resumo editável antes de buscar.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Choice=require(Rep:WaitForChild('07UI_CHOICE_LIST'));local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'));local Plan=require(Rep:WaitForChild('09I12_REQUEST_PLAN'))
local Contract=require(Rep:WaitForChild('09I21_LOOK_CONTRACT'));local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local A=require(Rep:WaitForChild('08B_AVATAR_DATA'))
local State=require(Rep:WaitForChild('08D_SKIN_STATE'));local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local Skin=require(Rep:WaitForChild('09I20_ASSISTANT_APPEARANCE'));local C=Skin.Colors;local M={}
function M.Build(U,onConfirm,call)
 local Q={Options={},Plan='Normal',Advanced=false,Step=1,Steps={},PreviewToken=0};local groups={}
 Q.Shade=D.Frame(U.Root,{Name='LookQuestionnaire',Visible=false,BackgroundColor3=C.paper,ZIndex=70});Q.Root=Q.Shade
 Q.Title=D.Text(Q.Root,'Vamos montar seu pedido',{TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 Q.Close=D.IconButton(Q.Root,'CloseLookRequest','close','Voltar à conversa',{ZIndex=78})
 Q.Hint=D.Text(Q.Root,'',{TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 Q.Stage=D.Frame(Q.Root,{Name='RequestBodyStage',BackgroundColor3=Color3.fromRGB(60,64,72),ZIndex=72});Q.Stage:SetAttribute('ACP_KeepAppearance',true)
 Q.View=D.New('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=73},Q.Stage)
 Q.BodyName=D.Text(Q.Stage,'Seu corpo atual',{Position=UDim2.new(0,8,1,-48),Size=UDim2.new(1,-16,0,44),TextSize=12,ZIndex=74});Q.BodyName:SetAttribute('ACP_KeepAppearance',true);Q.BodyName.TextColor3=Color3.new(1,1,1)
 Q.Fields=D.Scroll(Q.Root,{Name='RequestChoices',BackgroundTransparency=1,ZIndex=72,ScrollBarThickness=3})
 local function button(name,text,step)
  local b=D.Button(Q.Fields,text,{Name=name,TextSize=14,ZIndex=73});groups[b]=step;return b
 end
 Q.Current=button('KeepCurrentBody','Meu corpo atual',1);Q.Blank=button('StartBlankBody','Começar do zero',1);Q.Body=button('ChooseExactBody','Escolher outro corpo…',1)
 Q.Rig=button('ChooseBaseRig','Base R15 ▾',1)
 Q.Style=button('ChooseStyle','Estilo ▾',2);Q.Query=D.Box(Q.Fields,'Descreva o estilo com suas palavras',{Text='',TextSize=14,MultiLine=true,TextWrapped=true,ZIndex=73});groups[Q.Query]=2
 Q.Scope=button('ChooseScope','Criar look completo ▾',2);Q.Format=button('ChooseFormat','Roupa clássica ▾',2)
 Q.Budget=D.Box(Q.Fields,'Robux por look',{Text='100',TextSize=15,ZIndex=73});groups[Q.Budget]=3
 Q.BudgetList=button('ChooseBudget','Escolher orçamento ▾',3);Q.Color=button('ChooseColor','Cor livre ▾',3);Q.Count=button('ChooseCount','Quantidade ▾',3)
 Q.CustomCount=D.Box(Q.Fields,'Quantidade de looks · Pro',{Text='10',TextSize=15,ZIndex=73});groups[Q.CustomCount]=3
 Q.Effort=button('ChooseEffort','Esforço · Padrão ▾',3)
 Q.More=button('AdvancedRequestOptions','Opções avançadas ▾',4)
 Q.Top=button('ExactTopType','Parte de cima ▾',5);Q.Bottom=button('ExactBottomType','Parte de baixo ▾',5);Q.Hair=button('HairRequirement','Cabelo ▾',5)
 Q.Exclude=button('ExcludedAccessories','Não incluir ▾',5)
 Q.Piece=D.Box(Q.Fields,'Máximo por peça · opcional',{Text='',TextSize=14,ZIndex=73});groups[Q.Piece]=5
 Q.Tool=button('AssistantTool','Modo · Criar ▾',5)
 Q.Fixed={};Q.PieceQueries={};for _,v in ipairs({{'top','cima'},{'bottom','baixo'},{'hair','cabelo'}})do local box=D.Box(Q.Fields,'ID obrigatório · '..v[2],{Text='',TextSize=13,ZIndex=73});Q.Fixed[v[1]]=box;groups[box]=5;local query=D.Box(Q.Fields,'Pesquisar só '..v[2]..' · opcional',{Text='',TextSize=13,ZIndex=73});Q.PieceQueries[v[1]]=query;groups[query]=5 end
 Q.Summary=D.Text(Q.Root,'',{Name='ConfirmedRequestSummary',TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=73})
 Q.Note=D.Text(Q.Root,'',{TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=74})
 Q.Prev=D.Button(Q.Root,'Voltar',{TextSize=13,ZIndex=75});Q.Next=D.Button(Q.Root,'Continuar',{TextSize=14,ZIndex=75});Q.Confirm=D.Button(Q.Root,'Confirmar e criar',{TextSize=14,ZIndex=75});Q.Confirm:SetAttribute('ACP_Primary',true)
 Q.Choices=Choice.Build(Q.Root)
 local function preview(body,rig,label)
  if body then Preview.Mount(Q.View,body,rig or'R15',{drag=true,compact=false,failed=function(e)Q.Note.Text=e end})end;Q.BodyName.Text=label or'Seu corpo atual'
 end
 local function blank()
  local desc=Instance.new('HumanoidDescription');desc.UseAvatarSettings=false;local body=A.Pack(desc);desc:Destroy();return body
 end
 local function update()
  local p=Q.Options;p.budget=tonumber(Q.Budget.Text)or 100
  p.requestedCount=Q.CustomCount.Visible and tonumber(Q.CustomCount.Text)or p.requestedCount or p.count or 1
  p.count=math.min(5,p.requestedCount or 1);Q.Summary.Text=Contract.Summary(p);Q.Body.Text=p.bodyMode=='bundle'and('Corpo: '..p.bodyName..' 🔒')or'Escolher outro corpo…'
  Q.Style.Text='Estilo · '..(Styles.Get(p.style)and Styles.Get(p.style).name or'minha descrição')..' ▾'
  Q.Scope.Text=p.scope=='Tudo'and'Criar look completo ▾'or('Mudar '..p.scope..' ▾');Q.Format.Text=p.format=='3D'and'Roupa em camadas ▾'or'Roupa clássica ▾'
  Q.Count.Text='Quantidade · '..tostring(p.requestedCount or 1)..' ▾';Q.Color.Text='Cor · '..(p.color~=''and p.color or'livre')..' ▾';Q.Rig.Text='Base '..(p.baseRig or'R15')..' ▾'
  Q.Effort.Text='Esforço · '..Contract.Effort(p.effort,Q.Plan).name..' ▾';Q.Top.Text='Cima · '..Contract.Name('top',p.topType)..' ▾';Q.Bottom.Text='Baixo · '..Contract.Name('bottom',p.bottomType)..' ▾';Q.Hair.Text='Cabelo · '..Contract.Name('hair',p.hairMode)..' ▾'
  Q.Exclude.Text='Não incluir · '..#(p.excluded or{})..' tipo(s) ▾';Q.Tool.Text='Modo · '..(p.tool or'Criar')..' ▾'
  Q.Current:SetAttribute('ACP_Primary',p.bodyMode=='keep');Q.Blank:SetAttribute('ACP_Primary',p.bodyMode=='blank')
 end
 Q.BodyChooser=require(Rep:WaitForChild('09I22_BODY_CHOOSER')).Build(Q.Root,function(args)return call and call('body.catalog',args)end,function(data)
  Q.Options.bodyMode='bundle';Q.Options.bodyId=data.id;Q.Options.bodyName=data.name;Q.Options.body=true;Q.SelectedBody=data.body;preview(data.body,data.rig,data.name..' 🔒');Q.Note.Text='Corpo confirmado. A busca deverá usar este mesmo corpo.';update()
 end)
 Q.Current.Activated:Connect(function()Q.Options.bodyMode='keep';Q.Options.bodyId=0;Q.SelectedBody=nil;preview(State.Current,State.Rig,'Seu corpo atual');update()end)
 Q.Blank.Activated:Connect(function()Q.Options.bodyMode='blank';Q.Options.bodyId=0;Q.SelectedBody=nil;preview(blank(),Q.Options.baseRig,'Base limpa · '..Q.Options.baseRig);update()end)
 Q.Body.Activated:Connect(function()Q.BodyChooser.Open(Q.Options.bodyQuery or'')end)
 local function choose(b,title,values,key)
  b.Activated:Connect(function()Q.Choices.Open(title,values,tostring(Q.Options[key]or''),function(v)Q.Options[key]=v.id;update();Q.Layout()end)end)
 end
 choose(Q.Rig,'Base de criação',{{id='R15',name='R15 · articulado'},{id='R6',name='R6 · clássico'}},'baseRig')
 function Q.OpenStyles()
  Q.Step=2;Q.Layout();local rows={{id='',name='Usar minha descrição'}};for _,v in ipairs(Styles.Styles)do rows[#rows+1]=v end
  Q.Choices.Open('Estilo',rows,Q.Options.style or'',function(v)Q.Options.style=v.id~=''and v.id or nil;Q.Options.styleEdited=v.id~='';if v.id~=''then Q.Query.Text=v.query end;update()end)
 end
 function Q.OpenBudget()
  Q.Step=3;Q.Layout();local rows={};for _,n in ipairs({0,25,55,100,250,500,1000,2500})do rows[#rows+1]={id=tostring(n),name=n==0 and'Grátis'or('Até '..n..' Robux por look')}end
  Q.Choices.Open('Orçamento de CADA look',rows,Q.Budget.Text,function(v)Q.Budget.Text=v.id;update()end)
 end
 Q.Style.Activated:Connect(Q.OpenStyles);Q.BudgetList.Activated:Connect(Q.OpenBudget)
 choose(Q.Scope,'O que mudar?',{{id='Tudo',name='Look completo'},{id='Cabelo',name='Somente cabelo'},{id='Roupas',name='Somente roupas'},{id='Acessórios',name='Somente acessórios'},{id='Corpo',name='Somente corpo'}},'scope')
 choose(Q.Format,'Roupas',{{id='2D',name='Clássicas'},{id='3D',name='Em camadas'}},'format')
 local colors={{id='',name='Cor livre'}};for _,v in ipairs(Plan.Colors)do colors[#colors+1]={id=v[2],name=v[1]}end;choose(Q.Color,'Cor obrigatória das peças',colors,'color')
 for _,entry in ipairs({{Q.Top,'top','topType'},{Q.Bottom,'bottom','bottomType'},{Q.Hair,'hair','hairMode'}})do choose(entry[1],'Tipo exato · '..entry[2],Contract.Slots[entry[2]],entry[3])end
 Q.Count.Activated:Connect(function()
  local rows={};for n=1,math.min(5,Config.Plans[Q.Plan].count)do rows[#rows+1]={id=tostring(n),name=n..' look(s)'}end
  if Q.Plan=='Pro'then rows[#rows+1]={id='custom',name='Digitar quantidade · em lotes de 5',note='Cada lote aparece antes de buscar o próximo.'}end
  Q.Choices.Open('Variações do mesmo pedido',rows,tostring(Q.Options.requestedCount),function(v)Q.Options.customCount=v.id=='custom';if v.id~='custom'then Q.Options.requestedCount=tonumber(v.id)end;Q.Layout();update();if v.id=='custom'then Q.CustomCount:CaptureFocus()end end)
 end)
 Q.Effort.Activated:Connect(function()
  local rows={};for _,v in ipairs(Contract.Efforts)do rows[#rows+1]={id=v.id,name=v.name,note=v.paid and'Plus e Pro · mais comparações e revisão'or'Busca e verificação do pedido'}end
  Q.Choices.Open('Esforço da busca',rows,Q.Options.effort,function(v)local effort=Contract.Effort(v.id,Q.Plan);if effort.id~=v.id then Q.Note.Text='Esse esforço está disponível nos planos Plus e Pro.';return end;Q.Options.effort=v.id;update()end)
 end)
 Q.Exclude.Activated:Connect(function()
  local rows={{id='clear',name='Limpar exclusões'}};local seen={};for _,v in ipairs(Plan.Pieces)do if not seen[v[2]]then seen[v[2]]=true;rows[#rows+1]={id=v[2],name=(table.find(Q.Options.excluded,v[2])and'✓ 'or'')..v[1]}end end
  Q.Choices.Open('Não incluir',rows,nil,function(v)if v.id=='clear'then Q.Options.excluded={}else local i=table.find(Q.Options.excluded,v.id);if i then table.remove(Q.Options.excluded,i)else Q.Options.excluded[#Q.Options.excluded+1]=v.id end end;update()end)
 end)
 Q.Tool.Activated:Connect(function()local rows={};for _,v in ipairs(Config.Tools)do if v[1]=='Criar'or Q.Plan=='Pro'then rows[#rows+1]={id=v[1],name=v[2]}end end;Q.Choices.Open('Ferramenta',rows,Q.Options.tool,function(v)Q.Options.tool=v.id;update()end)end)
 for i,name in ipairs({'Base','Estilo','Limites','Conferir'})do
  local b=D.Button(Q.Root,i..' · '..name,{Name='RequestStep'..i,TextSize=12,ZIndex=74});Q.Steps[i]=b;b.Activated:Connect(function()Q.Step=i;Q.Layout()end)
 end
 function Q.Layout()
  local il,it,ir,ib,w,h=U.Safe.Read();local keyboard=false;pcall(function()local input=game:GetService('UserInputService');local pos=input.OnScreenKeyboardPosition;if input.OnScreenKeyboardVisible and pos and pos.Y>it+100 then h=math.min(h,pos.Y-4);ib=0;keyboard=true end end);Bounds.Rect(Q.Shade,il+6,it+6,w-il-ir-12,h-it-ib-12);local pw,ph=Q.Shade.AbsoluteSize.X,Q.Shade.AbsoluteSize.Y
  Q.Title.Visible=not keyboard;Bounds.Rect(Q.Title,12,0,pw-78,44);Bounds.Rect(Q.Close,pw-56,0,48,48)
  for i,b in ipairs(Q.Steps)do b.Visible=not keyboard;Bounds.Rect(b,10+(i-1)*(pw-20)/4,48,(pw-20)/4-4,44);b:SetAttribute('ACP_Primary',i==Q.Step)end
  Q.Hint.Text=({'Confirme o corpo que será usado. A escolha não será trocada.','Descreva o visual e escolha o que pretende alterar.','Orçamento por look, quantidade e profundidade da busca.','Confira as escolhas. Toque em uma etapa para editar.'})[Q.Step]
  Q.Hint.Visible=not keyboard and ph>=330;Bounds.Rect(Q.Hint,12,94,pw-24,32)
  local top=keyboard and 6 or Q.Hint.Visible and 134 or 98;local bottom=ph-(not keyboard and ph>=330 and 144 or 72);local sw=pw>=660 and math.min(300,pw*.32)or 0;Q.Stage.Visible=sw>0
  Bounds.Rect(Q.Stage,10,top,math.max(1,sw-16),math.max(1,ph-top-74));local x=sw+10;local fw=pw-x-(keyboard and 66 or 12)
  Bounds.Rect(Q.Fields,x,top,fw,math.max(44,bottom-top));local controls={}
  for b,step in pairs(groups)do local show=step==Q.Step or step==5 and Q.Step==4 and Q.Advanced
   if b==Q.CustomCount then show=show and Q.Plan=='Pro'and Q.Options.customCount==true end
   if b==Q.Rig then show=show and Q.Options.bodyMode=='blank'end;b.Visible=show
  end
  local order={Q.Current,Q.Blank,Q.Body,Q.Rig,Q.Style,Q.Query,Q.Scope,Q.Format,Q.Budget,Q.BudgetList,Q.Color,Q.Count,Q.CustomCount,Q.Effort,Q.More,Q.Top,Q.Bottom,Q.Hair,Q.Exclude,Q.Piece,Q.Tool}
  for _,slot in ipairs({'top','bottom','hair'})do order[#order+1]=Q.Fixed[slot];order[#order+1]=Q.PieceQueries[slot]end
  for _,b in ipairs(order)do if b.Visible then controls[#controls+1]=b end end
  local cols=fw>=650 and 3 or fw>=360 and 2 or 1;local cw=(fw-(cols-1)*8)/cols;local rowHeight=56
  for i,b in ipairs(controls)do Bounds.Rect(b,(i-1)%cols*(cw+8),math.floor((i-1)/cols)*(rowHeight+8),cw,rowHeight)end
  Q.Fields.CanvasSize=UDim2.fromOffset(0,math.ceil(#controls/cols)*(rowHeight+8));Q.Fields.ScrollingEnabled=true
  Bounds.Rect(Q.Summary,x,ph-140,fw,76);Q.Summary.Visible=not keyboard and ph>=330;Q.Note.Visible=not keyboard;Bounds.Rect(Q.Note,x,ph-66,fw,20)
  Q.Prev.Visible=Q.Step>1;Bounds.Rect(Q.Prev,10,ph-46,92,44);Q.Next.Visible=Q.Step<4;Q.Confirm.Visible=Q.Step==4
  Bounds.Rect(Q.Next,Q.Step==1 and 10 or 110,ph-46,pw-(Q.Step==1 and 20 or 120),44);Bounds.Rect(Q.Confirm,110,ph-46,pw-120,44)
  if Q.Step==1 then Q.Confirm.Visible=false end
  Q.More.Text=Q.Advanced and'Opções avançadas ▴'or'Opções avançadas ▾'
 end
 Q.More.Activated:Connect(function()Q.Advanced=not Q.Advanced;Q.Layout()end)
 Q.Prev.Activated:Connect(function()Q.Step=math.max(1,Q.Step-1);Q.Layout()end)
 Q.Next.Activated:Connect(function()if Q.Step==1 and Q.Options.bodyMode=='search'then Q.BodyChooser.Open(Q.Options.bodyQuery);return end;Q.Step=math.min(4,Q.Step+1);update();Q.Layout()end)
 function Q.CloseGuide()Q.Choices.Hide();Q.BodyChooser.Hide();Q.Shade.Visible=false;Preview.Unmount(Q.View);U.Guiding=false;U.Layout()end
 function Q.Reset()Q.Options={};Q.Advanced=false;Q.Step=1;Q.CloseGuide()end
 Q.Close.Activated:Connect(Q.CloseGuide)
 Q.Confirm.Activated:Connect(function()
  local p=Q.Options;local budget=tonumber(Q.Budget.Text);local piece=Q.Piece.Text==''and 100000 or tonumber(Q.Piece.Text);local n=tonumber(p.customCount and Q.CustomCount.Text or p.requestedCount)
  if not budget or budget~=budget or budget<0 or budget>100000 or not piece or piece~=piece or piece<0 or piece>100000 or not n or n~=n or n<1 or n>2147483647 then Q.Note.Text='Confira os valores de orçamento e quantidade.';return end
  p.fixed={};p.pieceQueries={};for _,slot in ipairs({'top','bottom','hair'})do local value=Q.Fixed[slot].Text;local id=value==''and 0 or tonumber(value);if not id or id%1~=0 or id<0 then Q.Note.Text='Confira o ID obrigatório de '..slot;return end;p.fixed[slot]=id;p.pieceQueries[slot]=Q.PieceQueries[slot].Text end
  p.budget=math.floor(budget);p.pieceBudget=math.floor(piece);p.requestedCount=math.floor(n);p.count=math.min(5,p.requestedCount);p.query=Q.Query.Text;local valid,why=Contract.Check(p)
  if not valid then Q.Note.Text=why;return end;p.confirmed=true;local out=A.Copy(p);Q.CloseGuide();onConfirm(out)
 end)
 for _,box in ipairs({Q.Budget,Q.CustomCount})do box.FocusLost:Connect(update)end
 function Q.Open(plan,raw)
  Q.Plan=Config.Plans[plan]and plan or'Normal';Q.Step=1;Q.Advanced=false;Q.SelectedBody=nil;local parsed=Plan.Parse(raw or U.Input.Text)
  local p=Contract.Options(parsed,Q.Plan);for _,key in ipairs({'scope','format','color','style','query','excluded','required','budget'})do if parsed[key]~=nil then p[key]=parsed[key]end end
  p.scope=p.scope or'Tudo';p.format=p.format or'2D';p.color=p.color or'';p.excluded=p.excluded or{};p.required=p.required or{};p.tool='Criar';p.effort=Contract.Effort(U.Gui.Parent:GetAttribute('ACP_AssistantEffort'),Q.Plan).id;Q.Options=p
  for _,slot in ipairs({'top','bottom','hair'})do Q.Fixed[slot].Text='';Q.PieceQueries[slot].Text=''end
  Q.CustomCount.Text=tostring(p.requestedCount or 1);Q.Budget.Text=tostring(p.budget or 100);Q.Piece.Text='';Q.Query.Text=p.query or'';Q.Note.Text='';U.Guiding=true;U.Layout();Q.Shade.Visible=true;Q.Layout();preview(State.Current,State.Rig,'Seu corpo atual');update()
  if p.bodyId>0 then Q.BodyChooser.Open(tostring(p.bodyId))end
 end
 U.Root:GetPropertyChangedSignal('AbsoluteSize'):Connect(Q.Layout);U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then Q.CloseGuide()end end);Skin.Bind(Q.Root);return Q
end
return M
