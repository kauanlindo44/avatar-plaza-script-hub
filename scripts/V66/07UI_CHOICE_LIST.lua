-- 07UI_CHOICE_LIST | ModuleScript | ReplicatedStorage | V66 (NOVO)
-- Lista pesquisável com rádio e descrição; teclado e fechamento sempre acessíveis.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors;local M={}
function M.Build(parent)
 local P={};local rows={};local callback;local choices={};local selected;local renderer
 P.Root=D.Frame(parent,{Name='ChoiceList',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false,ZIndex=100})
 P.Title=D.Text(P.Root,'Escolher',{Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=101})
 P.Close=D.IconButton(P.Root,'CloseChoiceList','close','Voltar às opções',{ZIndex=105})
 P.Search=D.Box(P.Root,'Pesquisar na lista',{TextSize=13,ZIndex=101});P.List=D.Scroll(P.Root,{Name='ChoiceRows',ScrollBarThickness=3,ZIndex=101})
 D.New('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},P.List)
 function P.Layout()
  local w,h=parent.AbsoluteSize.X,parent.AbsoluteSize.Y;B.Rect(P.Title,10,2,w-74,44);B.Rect(P.Close,w-56,2,48,48)
  B.Rect(P.Search,10,52,w-20,44);B.Rect(P.List,10,102,w-20,math.max(1,h-110))
 end
 function P.Hide()P.Root.Visible=false;P.Search:ReleaseFocus()end
 renderer=function()
  for _,r in ipairs(rows)do r:Destroy()end;rows={};local query=P.Search.Text:lower()
  for i,v in ipairs(choices)do local hay=(v.name..' '..(v.note or'')..' '..(v.group or'')):lower()
   if query==''or hay:find(query,1,true)then
    local b=D.Button(P.List,'',{Name='Choice_'..tostring(v.id),Size=UDim2.new(1,-4,0,68),LayoutOrder=i,BackgroundColor3=selected==v.id and C.soft or C.card,ZIndex=102})
    D.Text(b,selected==v.id and'●'or'○',{Position=UDim2.fromOffset(6,8),Size=UDim2.fromOffset(30,44),TextSize=22,TextColor3=selected==v.id and C.orange or C.muted,ZIndex=103})
    D.Text(b,v.name,{Position=UDim2.fromOffset(42,5),Size=UDim2.new(1,-52,0,25),TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=103})
    D.Text(b,v.note or'',{Position=UDim2.fromOffset(42,30),Size=UDim2.new(1,-52,0,32),TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=103})
    b.Activated:Connect(function()selected=v.id;P.Hide();if callback then callback(v)end end);rows[#rows+1]=b
   end
  end
  if #rows==0 then rows[1]=D.Text(P.List,'Nenhuma opção encontrada. Tente outra palavra.',{Size=UDim2.new(1,-4,0,60),TextSize=13,ZIndex=102})end
 end
 function P.Open(title,list,value,onChoose)
  choices=list or{};selected=value;callback=onChoose;P.Title.Text=title;P.Search.Text='';P.List.CanvasPosition=Vector2.zero;renderer();P.Layout();P.Root.Visible=true
 end
 P.Search:GetPropertyChangedSignal('Text'):Connect(function()if P.Root.Visible then renderer()end end);P.Close.Activated:Connect(P.Hide)
 parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(P.Layout);return P
end
return M
