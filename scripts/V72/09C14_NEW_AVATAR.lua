-- 09C14_NEW_AVATAR | ModuleScript | ReplicatedStorage | V72 (SUBSTITUIR)
-- Quatro etapas; só a confirmação altera o avatar e o histórico permite desfazer.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local S=require(Rep:WaitForChild('08D_SKIN_STATE'));local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local C=D.Colors
local M={Version='V72'}
local colors={{'Porcelana',244,220,202},{'Pêssego',232,190,161},{'Mel',201,146,103},{'Caramelo',171,113,75},{'Cacau',113,73,53},{'Ébano',67,46,39},{'Claro',238,238,235},{'Cinza',133,143,153},{'Azul',116,173,215},{'Verde',126,176,132},{'Rosa',219,158,186},{'Amarelo',238,205,102}}
function M.Build(ctx)
 local U=ctx.U;local W={Step=1,Base='R15',Color=3,Hair=0,ScaleDirty={},Scales={HeightScale=1,WidthScale=1,DepthScale=1,HeadScale=1}};local draft;local rig='R15';local gen=0;local groups={{},{},{},{}};local bodyData
 W.Entry=D.Button(U.SavedGridPanel,'Do zero',{Name='CreateAvatarFromZero',TextSize=12});U.NewAvatarEntry=W.Entry
 W.Shade=D.New('TextButton',{Name='NewAvatarShade',Text='',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=.16,Visible=false,Active=true,AutoButtonColor=false,ZIndex=110},U.Root)
 W.Panel=D.Frame(W.Shade,{Name='NewAvatarPanel',BackgroundColor3=C.panel,ZIndex=111})
 W.Title=D.Text(W.Panel,'Criar avatar do zero',{Font=Enum.Font.GothamBold,TextSize=19,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=112})
 W.Close=D.IconButton(W.Panel,'CloseNewAvatar','close','Voltar sem trocar o avatar',{ZIndex=116})
 W.Stage=D.Frame(W.Panel,{Name='NewAvatarStage',BackgroundColor3=Color3.fromRGB(89,96,108),ZIndex=112})
 W.View=D.New('ViewportFrame',{Name='NewAvatarPreview',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=113},W.Stage)
 W.Controls=D.Scroll(W.Panel,{Name='NewAvatarOptions',ScrollBarThickness=2,ZIndex=112});local tabs={}
 W.Note=D.Text(W.Panel,'O look só muda ao confirmar.',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=112})
 W.Back=D.Button(W.Panel,'Voltar',{TextSize=12,ZIndex=114});W.Confirm=D.Button(W.Panel,'Continuar',{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=13,ZIndex=114})
 local function add(step,text,fn,name)local b=D.Button(W.Controls,text,{Name=name or'AvatarChoice',TextSize=12,ZIndex=113});groups[step][#groups[step]+1]=b;b.Activated:Connect(fn);return b end
 local bodyPicker=require(Rep:WaitForChild('09I22_BODY_CHOOSER')).Build(W.Panel,function(args)return ctx.call('BodyCatalog',args)end,function(row)W.Base='BUNDLE';bodyData=row;W.Render()end)
 for _,v in ipairs({{'R15','Clássico R15'},{'R6','Clássico R6'},{'CURRENT','Meu corpo, sem roupas'}})do add(1,v[2],function()W.Base=v[1];W.Render()end,'Base_'..v[1])end
 add(1,'Escolher corpo do catálogo…',function()bodyPicker.Open('')end,'ChooseNativeBody')
 local chips={};for i,row in ipairs(colors)do local b=add(2,row[1],function()W.Color=i;W.Render()end,'Tone_'..i);b.BackgroundColor3=Color3.fromRGB(row[2],row[3],row[4]);b.TextColor3=i<5 and C.bg or C.white;chips[i]=b end
 local hairQuery=D.Box(W.Controls,'Pesquisar cabelo',{Name='HairQuery',TextSize=12,ZIndex=113});groups[3][1]=hairQuery
 local hairGo;local hairRows={};local hairButtons={};local loading=false
 local function clearHair()for _,b in ipairs(hairButtons)do b:Destroy()end;hairButtons={}end
 add(3,'Sem cabelo',function()W.Hair=0;W.Render()end,'NoHair')
 hairGo=add(3,'Buscar cabelos',function()
  if loading then return end;loading=true;gen=gen+1;local mine=gen;hairGo.Text='Buscando…'
  task.spawn(function()
   local ok,rows=pcall(function()local params=CatalogSearchParams.new();params.SearchKeyword=hairQuery.Text;params.AssetTypes={Enum.AvatarAssetType.HairAccessory};params.Limit=30;return Avatar:SearchCatalogAsync(params):GetCurrentPage()end)
   loading=false;if mine~=gen or not W.Shade.Visible then return end;hairGo.Text='Buscar cabelos';clearHair()
   if not ok then W.Note.Text='O Roblox não respondeu. Tente novamente.';return end
   for i,it in ipairs(rows or{})do if i>12 then break end
    local b=D.Button(W.Controls,'',{Name='Hair_'..it.Id,ZIndex=113});D.New('ImageLabel',{Size=UDim2.new(1,0,1,-22),Image=A.Thumbnail(it,420),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=114},b)
    D.Text(b,it.Name,{Position=UDim2.new(0,3,1,-22),Size=UDim2.new(1,-6,0,20),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=114});hairButtons[#hairButtons+1]=b
    b.Activated:Connect(function()W.Hair=it.Id;W.Render()end)
   end;W.Layout()
  end)
 end,'FindHair')
 local valueBoxes={};for _,row in ipairs({{'HeightScale','Altura',.9,1.05},{'WidthScale','Largura',.7,1},{'DepthScale','Profundidade',.7,1},{'HeadScale','Cabeça',.95,1}})do
  local f=D.Frame(W.Controls,{Name=row[1],BackgroundTransparency=1,ZIndex=113});groups[4][#groups[4]+1]=f
  D.Text(f,row[2],{Size=UDim2.new(.45,0,1,0),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=114})
  local minus=D.Button(f,'−',{Position=UDim2.new(.45,0,0,0),Size=UDim2.fromOffset(44,44),ZIndex=114});local plus=D.Button(f,'+',{Position=UDim2.new(1,-44,0,0),Size=UDim2.fromOffset(44,44),ZIndex=114})
  local value=D.Text(f,'1',{Position=UDim2.new(.45,44,0,0),Size=UDim2.new(.55,-88,1,0),TextSize=13,ZIndex=114});valueBoxes[row[1]]=value
  for sign,b in pairs({[-1]=minus,[1]=plus})do b.Activated:Connect(function()if rig=='R6' then W.Note.Text='R6 tem tamanho fixo; escolha R15 para ajustar.';return end;W.ScaleDirty[row[1]]=true;W.Scales[row[1]]=math.clamp(math.floor((W.Scales[row[1]]+sign*.025)*1000+.5)/1000,row[3],row[4]);W.Render()end)end
 end
 function W.Layout()
  local il,it,ir,ib,w,h=U.SafeBounds.Read();local pw=math.min(850,w-il-ir-12);local ph=math.min(630,h-it-ib-12)
  B.Rect(W.Panel,il+(w-il-ir-pw)/2,it+(h-it-ib-ph)/2,pw,ph);B.Rect(W.Title,12,2,pw-82,44);B.Rect(W.Close,pw-56,2,48,48)
  local stageW=pw>=500 and pw*.43 or pw*.34;local bodyH=ph-154
  B.Rect(W.Stage,8,100,stageW-12,math.max(50,bodyH));B.Rect(W.Controls,stageW,100,pw-stageW-8,math.max(50,bodyH))
  for i,b in ipairs(tabs)do B.Rect(b,8+(i-1)*(pw-10)/4,50,(pw-28)/4,44);b.BackgroundColor3=i==W.Step and C.soft or C.card end
  local cw=W.Controls.AbsoluteSize.X;local y=0
  for step,list in ipairs(groups)do for i,o in ipairs(list)do o.Visible=step==W.Step;if o.Visible then
   if step==2 then local cols=cw>=230 and 3 or 2;B.Rect(o,(i-1)%cols*(cw+6)/cols,math.floor((i-1)/cols)*50,(cw-6*(cols-1))/cols,44);y=math.ceil(#list/cols)*50
   else B.Rect(o,0,(i-1)*50,cw-4,44);y=#list*50 end
  end end end
  for i,b in ipairs(hairButtons)do b.Visible=W.Step==3;if b.Visible then local cols=cw>=260 and 3 or 2;B.Rect(b,(i-1)%cols*(cw+6)/cols,154+math.floor((i-1)/cols)*112,(cw-6*(cols-1))/cols,106);y=154+math.ceil(#hairButtons/cols)*112 end end
  W.Controls.CanvasSize=UDim2.fromOffset(0,y);W.Note.Visible=pw>=500;B.Rect(W.Note,8,ph-50,stageW-16,44)
  B.Rect(W.Back,stageW,ph-50,math.min(90,(pw-stageW-20)/2),44);B.Rect(W.Confirm,stageW+math.min(90,(pw-stageW-20)/2)+6,ph-50,pw-stageW-math.min(90,(pw-stageW-20)/2)-14,44)
  W.Back.Active=W.Step>1;W.Confirm.Text=W.Step==4 and'Criar e editar'or'Continuar'
 end
 function W.Render()
  if W.Base=='CURRENT'and S.Current then draft=A.Blank(S.Current);rig=S.Rig
  elseif W.Base=='BUNDLE'and bodyData then draft=A.Blank(bodyData.body);rig='R15'
  else local d=Instance.new('HumanoidDescription');d.UseAvatarSettings=false;d.BodyTypeScale=0;d.ProportionScale=0;draft=A.Pack(d);d:Destroy();rig=W.Base=='R6'and'R6'or'R15' end
  local color=colors[W.Color];for _,key in ipairs(A.Colors)do draft.colors[key]={color[2]/255,color[3]/255,color[4]/255}end
  if W.Hair>0 then draft.accessories[#draft.accessories+1]={id=W.Hair,type='Hair',layer=false,order=0,puff=0}end;if rig=='R15'then for k,v in pairs(W.Scales)do if not W.ScaleDirty[k]then v=draft.scales[k]or 1;W.Scales[k]=v end;draft.scales[k]=v;valueBoxes[k].Text=tostring(v)end end
  for i,b in ipairs(chips)do b.Text=(i==W.Color and'✓ 'or'')..colors[i][1]end
  Preview.Mount(W.View,draft,rig,{drag=true,compact=false});W.Layout()
 end
 for i,name in ipairs({'Corpo','Cor','Cabelo','Tamanho'})do local b=D.Button(W.Panel,i..' · '..name,{Name='AvatarStep_'..i,TextSize=11,ZIndex=113});tabs[i]=b;b.Activated:Connect(function()W.Step=i;W.Controls.CanvasPosition=Vector2.zero;W.Layout()end)end
 function W.Hide()gen=gen+1;loading=false;hairGo.Text='Buscar cabelos';W.Shade.Visible=false;bodyPicker.Hide();Preview.Unmount(W.View)end
 function W.Open()W.ScaleDirty={};W.Step=1;W.Shade.Visible=true;W.Layout();W.Render()end
 W.Entry.Activated:Connect(W.Open);W.Close.Activated:Connect(W.Hide);W.Back.Activated:Connect(function()W.Step=math.max(1,W.Step-1);W.Layout()end)
 W.Confirm.Activated:Connect(function()
  if W.Step<4 then W.Step=W.Step+1;W.Controls.CanvasPosition=Vector2.zero;W.Layout();return end
  if not draft then return end;ctx.call('ClearInspect');local ok,e=S.Set(draft,false,rig);if not ok then ctx.toast(e);return end
  W.Hide();U.OpenRequest:Fire('Catalog');if U.ShowPreview then U.ShowPreview()end;ctx.toast('Avatar criado. Experimente roupas no catálogo; Desfazer recupera o anterior.')
 end)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then W.Hide()end end);U.Root:GetPropertyChangedSignal('AbsoluteSize'):Connect(W.Layout)
 W.Shade.Destroying:Connect(function()gen=gen+1;Preview.Unmount(W.View)end);return W
end
return M
