-- 09C14_NEW_AVATAR | ModuleScript | ReplicatedStorage | V66 (NOVO)
-- Base limpa com confirmação e histórico. Nunca apaga looks guardados.
local Rep=game:GetService('ReplicatedStorage');local Input=game:GetService('UserInputService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local S=require(Rep:WaitForChild('08D_SKIN_STATE'));local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local C=D.Colors
local M={Version='V66'}
local swatches={{'Porcelana',244,220,202},{'Pêssego',232,190,161},{'Mel',201,146,103},{'Caramelo',171,113,75},{'Cacau',113,73,53},{'Ébano',67,46,39},{'Claro',238,238,235},{'Cinza',133,143,153},{'Azul',116,173,215},{'Verde',126,176,132},{'Rosa',219,158,186},{'Amarelo',238,205,102}}
function M.Build(ctx)
 local U=ctx.U;local W={Base='R15',Color=3};local draft;local rig='R15';local generation=0
 W.Entry=D.Button(U.SavedGridPanel,'Do zero',{Name='CreateAvatarFromZero',TextSize=12})
 U.NewAvatarEntry=W.Entry
 W.Shade=D.New('TextButton',{Name='NewAvatarShade',Text='',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=.16,Visible=false,Active=true,AutoButtonColor=false,ZIndex=110},U.Root)
 W.Panel=D.Frame(W.Shade,{Name='NewAvatarPanel',BackgroundColor3=C.panel,ZIndex=111})
 W.Title=D.Text(W.Panel,'Criar avatar do zero',{Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=112})
 W.Close=D.IconButton(W.Panel,'CloseNewAvatar','close','Voltar sem trocar o avatar',{ZIndex=116})
 W.Stage=D.Frame(W.Panel,{Name='NewAvatarStage',BackgroundColor3=Color3.fromRGB(174,185,196),ZIndex=112})
 W.View=D.New('ViewportFrame',{Name='NewAvatarPreview',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=113},W.Stage)
 W.Controls=D.Scroll(W.Panel,{Name='NewAvatarOptions',ScrollBarThickness=2,ZIndex=112})
 D.New('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},W.Controls)
 D.Text(W.Controls,'1 · Escolha uma base',{Size=UDim2.new(1,-4,0,28),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,ZIndex=113})
 local bases={};for i,v in ipairs({{'R15','Clássico R15','Base articulada para roupas e camadas.'},{'R6','Clássico R6','Base de seis partes, sem roupas em camadas.'},{'CURRENT','Corpo atual, sem roupas','Preserva o formato e tira roupa/acessórios.'}})do
  local b=D.Button(W.Controls,v[2],{Name='NewAvatarBase_'..v[1],Size=UDim2.new(1,-4,0,44),LayoutOrder=i+1,TextSize=12,ZIndex=113});bases[v[1]]=b
  b.Activated:Connect(function()W.Base=v[1];W.Render()end)
 end
 D.Text(W.Controls,'2 · Cor do corpo',{Size=UDim2.new(1,-4,0,28),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=5,ZIndex=113})
 local colors=D.New('Frame',{Name='BodyColorChoices',Size=UDim2.new(1,-4,0,194),BackgroundTransparency=1,LayoutOrder=6,ZIndex=113},W.Controls)
 local grid=D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(6,6),CellSize=UDim2.fromOffset(60,44),FillDirectionMaxCells=3,SortOrder=Enum.SortOrder.LayoutOrder},colors)
 local buttons={};for i,row in ipairs(swatches)do local b=D.Button(colors,'',{Name='BodyColor_'..i,BackgroundColor3=Color3.fromRGB(row[2],row[3],row[4]),TextColor3=i<=3 and C.bg or C.white,LayoutOrder=i,TextSize=18,ZIndex=114});buttons[i]=b;b.Activated:Connect(function()W.Color=i;W.Render()end)end
 W.Note=D.Text(W.Panel,'O look atual só muda ao confirmar. Seus looks salvos continuam guardados.',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=112})
 W.Confirm=D.Button(W.Panel,'Criar e editar',{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=13,ZIndex=114})
 function W.Layout()
  local il,it,ir,ib,w,h=U.SafeBounds.Read();local pw=math.min(750,w-il-ir-12);local ph=math.min(570,h-it-ib-12)
  B.Rect(W.Panel,il+(w-il-ir-pw)/2,it+(h-it-ib-ph)/2,pw,ph);B.Rect(W.Title,12,2,pw-82,46);B.Rect(W.Close,pw-56,2,48,48)
  local wide=pw>=480;local stageW=wide and pw*.44 or pw*.38;local bodyH=ph-110
  B.Rect(W.Stage,10,54,stageW-16,math.max(40,bodyH));B.Rect(W.Controls,stageW+2,54,pw-stageW-12,math.max(40,bodyH))
  local cw=W.Controls.AbsoluteSize.X;local cols=cw>=260 and 4 or cw>=165 and 3 or 2;grid.FillDirectionMaxCells=cols;grid.CellSize=UDim2.fromOffset((cw-4-(cols-1)*6)/cols,44);colors.Size=UDim2.new(1,-4,0,math.ceil(#swatches/cols)*50-6)
  W.Note.Visible=ph>=300;B.Rect(W.Note,10,ph-52,pw-180,44);B.Rect(W.Confirm,ph>=300 and pw-162 or 10,ph-50,ph>=300 and 152 or pw-20,44)
 end
 function W.Render()
  generation=generation+1
  if W.Base=='CURRENT'and S.Current then draft=A.Blank(S.Current);rig=S.Rig else
   local d=Instance.new('HumanoidDescription');d.UseAvatarSettings=false;d.BodyTypeScale=0;d.ProportionScale=0;d.HeightScale=1;d.WidthScale=1;d.DepthScale=1;d.HeadScale=1;draft=A.Pack(d);d:Destroy();rig=W.Base=='R6'and'R6'or'R15'
  end
  local color=swatches[W.Color];for _,key in ipairs(A.Colors)do draft.colors[key]={color[2]/255,color[3]/255,color[4]/255}end
  for key,b in pairs(bases)do b.BackgroundColor3=key==W.Base and C.soft or C.card end
  for i,b in ipairs(buttons)do b.Text=i==W.Color and'✓'or''end
  Preview.Mount(W.View,draft,rig,{drag=true,compact=false});W.Confirm.Active=true
 end
 function W.Hide()generation=generation+1;W.Shade.Visible=false;Preview.Unmount(W.View)end
 function W.Open()W.Shade.Visible=true;W.Layout();W.Render()end
 W.Entry.Activated:Connect(W.Open);W.Close.Activated:Connect(W.Hide)
 W.Confirm.Activated:Connect(function()
  if not draft then return end
  ctx.call('ClearInspect');local ok,e=S.Set(draft,false,rig)
  if not ok then ctx.toast(e);return end
  W.Hide();U.OpenRequest:Fire('Catalog');if U.ShowPreview then U.ShowPreview()end;ctx.toast('Base criada. Escolha as roupas no catálogo; Desfazer volta ao look anterior.')
 end)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then W.Hide()end end)
 U.Root:GetPropertyChangedSignal('AbsoluteSize'):Connect(W.Layout)
 local input=Input.InputBegan:Connect(function(io,gp)if not gp and W.Shade.Visible and(io.KeyCode==Enum.KeyCode.Escape or io.KeyCode==Enum.KeyCode.ButtonB)then W.Hide()end end)
 W.Shade.Destroying:Connect(function()input:Disconnect();Preview.Unmount(W.View)end);return W
end
return M
