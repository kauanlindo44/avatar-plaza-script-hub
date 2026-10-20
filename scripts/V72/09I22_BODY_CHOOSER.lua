-- 09I22_BODY_CHOOSER | ModuleScript | ReplicatedStorage | V72 (NOVO)
-- Seleção visual compartilhada por pedido e criação do zero; o usuário confirma o corpo exato.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local M={}
function M.Build(parent,call,onPick)
 local W={Token=0,Rows={}};local C=D.Colors
 W.Shade=D.Frame(parent,{Name='BodyCatalogShade',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false,ZIndex=135})
 W.Panel=D.Frame(W.Shade,{Name='BodyCatalogPanel',Size=UDim2.fromScale(1,1),BackgroundColor3=C.panel,ZIndex=136})
 W.Title=D.Text(W.Panel,'Escolha o corpo exato',{TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=137})
 W.Close=D.IconButton(W.Panel,'CloseBodyCatalog','close','Voltar ao pedido',{ZIndex=140})
 W.Query=D.Box(W.Panel,'Nome do corpo ou ID do pacote',{TextSize=14,ZIndex=137})
 W.Search=D.Button(W.Panel,'Buscar',{TextSize=13,ZIndex=137});W.Reload=D.Button(W.Panel,'Recarregar',{TextSize=12,ZIndex=137})
 W.Grid=D.Scroll(W.Panel,{Name='BodyCatalogResults',ScrollBarThickness=3,ZIndex=137})
 W.GridLayout=D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder},W.Grid)
 W.Stage=D.Frame(W.Panel,{Name='SelectedBodyStage',BackgroundColor3=C.soft,ZIndex=137})
 W.View=D.New('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=138},W.Stage)
 W.Note=D.Text(W.Panel,'Toque em um corpo para conferir a prévia.',{TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=138})
 W.Confirm=D.Button(W.Panel,'Confirmar este corpo',{TextSize=13,ZIndex=138});D.SetEnabled(W.Confirm,false)
 local function clear()for _,o in ipairs(W.Grid:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end end
 function W.Layout()
  local w,h=parent.AbsoluteSize.X,parent.AbsoluteSize.Y;local gap=8;local pw=math.max(1,w);local ph=math.max(1,h)
  B.Rect(W.Title,12,2,pw-72,44);B.Rect(W.Close,pw-56,0,48,48)
  B.Rect(W.Query,10,50,pw-186,44);B.Rect(W.Search,pw-170,50,70,44);B.Rect(W.Reload,pw-96,50,86,44)
  local left=pw>=500 and math.min(270,pw*.35)or 0;W.Stage.Visible=left>0
  B.Rect(W.Stage,10,102,math.max(1,left-16),math.max(1,ph-170));B.Rect(W.Grid,left+10,102,pw-left-20,math.max(1,ph-170))
  local gw=pw-left-20;local cols=math.max(1,math.floor(gw/145));local cw=(gw-(cols-1)*gap)/cols
  W.GridLayout.FillDirectionMaxCells=cols;W.GridLayout.CellSize=UDim2.fromOffset(cw,math.max(130,math.min(210,(ph-180)/2)))
  B.Rect(W.Note,10,ph-62,pw-210,54);B.Rect(W.Confirm,pw-194,ph-54,184,44)
  if pw<420 then B.Rect(W.Note,10,ph-62,pw-20,18);B.Rect(W.Confirm,10,ph-44,pw-20,44)end
 end
 local function pick(row)
  W.Token=W.Token+1;local mine=W.Token;W.Note.Text='Conferindo o corpo no Roblox…';D.SetEnabled(W.Confirm,false)
  task.spawn(function()local data,e=call({id=row.id});if mine~=W.Token or not W.Shade.Visible then return end
   if not data then W.Note.Text=e or'Corpo indisponível.';return end;W.Selected=data
   W.Note.Text=data.name..' · '..tostring(data.price or'?')..' Robux · escolha obrigatória'
   Preview.Mount(W.View,data.body,data.rig,{drag=true,compact=false});D.SetEnabled(W.Confirm,true)
  end)
 end
 function W.Load()
  W.Token=W.Token+1;local mine=W.Token;local raw=W.Query.Text;local id=tonumber(raw)or tonumber(raw:match('/bundles/(%d+)'))
  if id then pick({id=id});return end
  W.Note.Text='Buscando corpos no Roblox…';clear()
  task.spawn(function()local rows,e=call({query=raw});if mine~=W.Token or not W.Shade.Visible then return end
   if not rows then W.Note.Text=e or'Não foi possível carregar.';return end;W.Rows=rows
   for i,row in ipairs(rows)do
    local card=D.Button(W.Grid,'',{Name='ChooseBody_'..row.id,LayoutOrder=i,ZIndex=138})
    D.New('ImageLabel',{Position=UDim2.fromOffset(3,3),Size=UDim2.new(1,-6,1,-52),BackgroundTransparency=1,Image='rbxthumb://type=BundleThumbnail&id='..row.id..'&w=420&h=420',ScaleType=Enum.ScaleType.Fit,ZIndex=139},card)
    D.Text(card,row.name,{Position=UDim2.new(0,5,1,-47),Size=UDim2.new(1,-10,0,26),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,ZIndex=139})
    D.Text(card,tostring(row.price or'?')..' Robux',{Position=UDim2.new(0,5,1,-23),Size=UDim2.new(1,-10,0,20),TextSize=11,ZIndex=139})
    card.Activated:Connect(function()pick(row)end)
   end;W.Note.Text=#rows==0 and'Nenhum corpo encontrado. Tente outro nome ou ID.'or'Escolha uma miniatura e confirme o corpo.';W.Layout()
  end)
 end
 function W.Hide()W.Token=W.Token+1;W.Shade.Visible=false;Preview.Unmount(W.View)end
 function W.Open(query)W.Selected=nil;D.SetEnabled(W.Confirm,false);W.Shade.Visible=true;W.Query.Text=query or'';W.Layout();W.Load()end
 W.Search.Activated:Connect(W.Load);W.Reload.Activated:Connect(W.Load);W.Query.FocusLost:Connect(function(enter)if enter then W.Load()end end)
 W.Close.Activated:Connect(W.Hide);W.Confirm.Activated:Connect(function()if W.Selected then local selected=W.Selected;W.Hide();onPick(selected)end end)
 parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(W.Layout);W.Shade.Destroying:Connect(function()W.Token=W.Token+1;Preview.Unmount(W.View)end);return W
end
return M
