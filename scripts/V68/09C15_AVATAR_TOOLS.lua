-- 09C15_AVATAR_TOOLS | ModuleScript | ReplicatedStorage | V68 (NOVO)
-- Edição nativa de acessórios, comparação sem aplicar e importação por ID/código.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Choice=require(Rep:WaitForChild('07UI_CHOICE_LIST'));local Refine=require(Rep:WaitForChild('08B8_ACCESSORY_REFINEMENT'));local M={}
function M.Build(ctx)
 local U,S,A=ctx.U,ctx.S,ctx.A;local T={Comparing=false};local selected;local field='position';local axis=2
 U.ToolsButton=D.IconButton(U.PreviewShell,'AvatarToolsButton','settings','Ferramentas do avatar',{ZIndex=15})
 T.Root=D.Frame(U.Root,{Name='AvatarTools',Visible=false,BackgroundColor3=C.panel,ZIndex=84});U.AvatarTools=T.Root;local title=D.Text(T.Root,'Ferramentas do avatar',{TextSize=17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=85})
 local close=D.IconButton(T.Root,'CloseAvatarTools','close','Fechar ferramentas',{ZIndex=90})
 local body=D.Scroll(T.Root,{Name='AvatarToolsList',ZIndex=85,ScrollBarThickness=2});local buttons={}
 local function b(name,text,fn)local o=D.Button(body,text,{Name=name,TextSize=12,ZIndex=86});o.Activated:Connect(fn);buttons[#buttons+1]=o;return o end
 b('UndoAvatar','Desfazer',function()local ok,e=S.Undo();if not ok then ctx.toast(e)end end)
 b('RedoAvatar','Refazer',function()local ok,e=S.Redo();if not ok then ctx.toast(e)end end)
 T.Compare=b('CompareAvatar','Comparar com o original',function()T.Comparing=not T.Comparing;T.Compare.Text=T.Comparing and'Voltar à edição atual'or'Comparar com o original';ctx.compare(T.Comparing)end)
 b('FavoriteItems','Peças favoritas',function()T.Root.Visible=false;ctx.favorites()end)
 local input=D.Box(body,'ID do item ou código de look',{Name='ImportCatalogID',TextSize=12,ZIndex=86});buttons[#buttons+1]=input
 b('ImportAvatarItem','Carregar item / código',function()
  local raw=input.Text:match('^%s*(.-)%s*$');if raw==''then ctx.toast('Digite um ID de item ou código de look.');return end
  task.spawn(function()local id=tonumber(raw)or tonumber(raw:match('/catalog/(%d+)'));local ok,e
   if id then local good,item=pcall(function()return Avatar:GetItemDetailsAsync(id,Enum.AvatarItemType.Asset)end);if good and item then ok,e=S.Try(item)else e='Item não encontrado no Roblox.'end
   else local look,why=ctx.call('Code',{code=raw});if look and look.body then ok,e=S.Set(look.body,false,look.rig)else e=why end end;ctx.toast(ok and'Carregado na edição.'or e)
  end)
 end)
 b('TestScale110','Testar altura +10% · desfazer disponível',function()
  if not S.Current or S.Rig~='R15' then ctx.toast('Esse teste exige um avatar R15 carregado.');return end
  local d=A.Copy(S.Current);d.scales.HeightScale=math.clamp((d.scales.HeightScale or 1)*1.1,.5,1.1);local ok,e=S.Set(d,false,S.Rig,true);ctx.toast(ok and'Altura de teste aplicada. Use Desfazer para comparar.'or e)
 end)
 T.Adjust=D.Frame(U.Root,{Name='AccessoryAdjustments',Visible=false,BackgroundColor3=C.panel,ZIndex=94})
 U.AccessoryAdjustments=T.Adjust
 local adTitle=D.Text(T.Adjust,'Ajustar acessório',{TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=95});local adClose=D.IconButton(T.Adjust,'CloseAccessoryAdjustments','close','Fechar ajuste',{ZIndex=99})
 local choose=D.Button(T.Adjust,'Escolher peça ▾',{TextSize=12,ZIndex=95});local mode=D.Button(T.Adjust,'Mover ▾',{TextSize=12,ZIndex=95});local ax=D.Button(T.Adjust,'Eixo Y ▾',{TextSize=12,ZIndex=95})
 local minus=D.Button(T.Adjust,'−',{TextSize=20,ZIndex=95});local value=D.Box(T.Adjust,'',{Text='0',TextSize=14,ZIndex=95});local plus=D.Button(T.Adjust,'+',{TextSize=20,ZIndex=95})
 local apply=D.Button(T.Adjust,'Aplicar ajuste',{TextSize=13,BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=95});local reset=D.Button(T.Adjust,'Restaurar peça',{TextSize=12,ZIndex=95})
 local note=D.Text(T.Adjust,'Somente acessórios rígidos compatíveis. Os limites vêm do Roblox.',{TextSize=11,TextColor3=C.muted,ZIndex=95})
 local chooser=Choice.Build(T.Adjust);local modeNames={position='Mover',rotation='Girar',scale='Tamanho'}
 local function row()for _,v in ipairs(S.Current and S.Current.accessories or{})do if v.id==selected then return v end end end
 local function update()
  local v=row();local lo,hi;if v then lo,hi=Refine.Bounds(v.type,field)end;local data=v and v[field]or(field=='scale'and{1,1,1}or{0,0,0});value.Text=tostring(data[axis]);mode.Text=modeNames[field]..' ▾';ax.Text='Eixo '..({'X','Y','Z'})[axis]..' ▾'
  choose.Text=v and('Peça # '..v.id..' ▾')or'Escolher peça ▾';note.Text=lo and('Limite '..lo[axis]..' a '..hi[axis]..' • roupa em camadas não é ajustável.')or'Escolha uma peça rígida compatível.';D.SetEnabled(apply,lo~=nil)
 end
 b('RefineAccessory','Mover, girar e ajustar acessórios',function()
  task.spawn(function()local r,e=ctx.call('AccessoryRules');if not r or not Refine.SetRules(r)then ctx.toast(e or'O Roblox não liberou os limites.');return end;T.Adjust.Visible=true;T.Layout();update()end)
 end)
 choose.Activated:Connect(function()local items={};for _,v in ipairs(S.Current and S.Current.accessories or{})do if not v.layer and Refine.Bounds(v.type,'position')then items[#items+1]={id=tostring(v.id),name=v.type..' · # '..v.id}end end
  if #items==0 then ctx.toast('Equipe um acessório rígido compatível primeiro.');return end;chooser.Open('Acessório para ajustar',items,tostring(selected),function(v)selected=tonumber(v.id);update()end)
 end)
 mode.Activated:Connect(function()local items={};for _,f in ipairs({'position','rotation','scale'})do items[#items+1]={id=f,name=modeNames[f]}end;chooser.Open('Tipo de ajuste',items,field,function(v)field=v.id;update()end)end)
 ax.Activated:Connect(function()chooser.Open('Eixo',{{id='1',name='X · horizontal'},{id='2',name='Y · vertical'},{id='3',name='Z · profundidade'}},tostring(axis),function(v)axis=tonumber(v.id);update()end)end)
 local function step(sign)local v=row();local lo,hi;if v then lo,hi=Refine.Bounds(v.type,field)end;if not lo then return end;local n=tonumber(value.Text)or(field=='scale'and 1 or 0);value.Text=tostring(math.clamp(math.floor((n+sign*(field=='rotation'and 1 or .01))*100+.5)/100,lo[axis],hi[axis]))end
 minus.Activated:Connect(function()step(-1)end);plus.Activated:Connect(function()step(1)end)
 apply.Activated:Connect(function()
  local original=row();local n=tonumber(value.Text);if not original or not n or n~=n then ctx.toast('Selecione a peça e um valor válido.');return end
  local lo,hi=Refine.Bounds(original.type,field);if not lo or n<lo[axis]or n>hi[axis]then ctx.toast('Valor fora do limite permitido pelo Roblox.');return end
  local d=A.Copy(S.Current);for _,v in ipairs(d.accessories)do if v.id==selected then v[field]=v[field]or(field=='scale'and{1,1,1}or{0,0,0});if field=='scale'then v[field]={n,n,n}else v[field][axis]=n end end end
  local ok,e=S.Set(d,false,S.Rig,true);ctx.toast(ok and'Ajuste enviado à prévia e ao personagem.'or e)
 end)
 reset.Activated:Connect(function()if not selected or not S.Current then return end;local d=A.Copy(S.Current);for _,v in ipairs(d.accessories)do if v.id==selected then v.position=nil;v.rotation=nil;v.scale=nil end end;S.Set(d,false,S.Rig,true);update()end)
 function T.Layout()
  local il,it,ir,ib,w,h=U.SafeBounds.Read();local pw=math.min(340,w-il-ir-12);local ph=math.min(480,h-it-ib-12);local x=w-ir-pw-6;local y=it+6
  B.Rect(T.Root,x,y,pw,ph);B.Rect(title,10,0,pw-72,48);B.Rect(close,pw-54,0,48,48);B.Rect(body,8,52,pw-16,ph-60)
  for i,o in ipairs(buttons)do B.Rect(o,0,(i-1)*48,pw-20,44)end;body.CanvasSize=UDim2.fromOffset(0,#buttons*48)
  local ah=math.min(350,h-it-ib-12);B.Rect(T.Adjust,x,it+(h-it-ib-ah)/2,pw,ah);B.Rect(adTitle,10,0,pw-72,48);B.Rect(adClose,pw-54,0,48,48)
  B.Rect(choose,10,52,pw-20,44);B.Rect(mode,10,102,(pw-26)/2,44);B.Rect(ax,16+(pw-26)/2,102,(pw-26)/2,44)
  B.Rect(minus,10,152,44,44);B.Rect(value,60,152,pw-120,44);B.Rect(plus,pw-54,152,44,44);B.Rect(note,10,202,pw-20,math.max(22,ah-258))
  B.Rect(reset,10,ah-48,(pw-26)/2,44);B.Rect(apply,16+(pw-26)/2,ah-48,(pw-26)/2,44)
 end
 U.ToolsButton.Activated:Connect(function()T.Root.Visible=not T.Root.Visible;T.Layout()end);close.Activated:Connect(function()T.Root.Visible=false end);adClose.Activated:Connect(function()T.Adjust.Visible=false;chooser.Hide()end)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then T.Root.Visible=false;T.Adjust.Visible=false;chooser.Hide()end end)
 local old=U.Layout;U.Layout=function(...)old(...);T.Layout()end;S.Changed.Event:Connect(function()if T.Comparing then T.Comparing=false;T.Compare.Text='Comparar com o original';ctx.compare(false)end end);return T
end
return M
