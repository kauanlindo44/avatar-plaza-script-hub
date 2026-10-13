-- 09C3_CATALOG_FILTERS | ModuleScript | ReplicatedStorage | V61 (NOVO)
-- Campos com legenda, seleções explícitas e validação de preços antes de pesquisar.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={}
function M.Build(U)
 local panel=U.FilterPanel;local C=U.Colors
 for _,v in ipairs(panel:GetChildren())do if v:IsA('TextLabel')then v.Visible=false end end
 local title=D.Text(panel,'Filtros do catálogo',{TextSize=17,Font=Enum.Font.GothamBold,ZIndex=66,TextXAlignment=Enum.TextXAlignment.Left})
 local body=D.Scroll(panel,{Name='CatalogFilterFields',ZIndex=66,AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=3})
 local labels={};local fields={U.Min,U.Max,U.Creator,U.CreatorType,U.LimAll,U.LimOnly,U.LimNo,U.FormAll,U.FormClassic,U.Form3D,U.OffSale}
 for _,o in ipairs(fields)do o.Parent=body;o.ZIndex=67;o.AnchorPoint=Vector2.zero;o.TextSize=12 end
 U.Form2D.Visible=false
 for i,text in ipairs({'Preço em Robux • deixe vazio para todos','Criador • nome exato, opcional','Disponibilidade dos itens','Formato das roupas'})do labels[i]=D.Text(body,text,{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=67})end
 U.Min.PlaceholderText='Mínimo: 0';U.Max.PlaceholderText='Máximo: sem limite';U.Creator.PlaceholderText='Nome do criador'
 U.FormAll.Text='Todas';U.FormClassic.Text='Clássicas 2D';U.Form3D.Text='Roupas 3D';U.LimAll.Text='Todos';U.LimOnly.Text='Limited';U.LimNo.Text='Sem limited'
 U.ClearFilter.Text='Limpar';U.ApplyFilter.Text='Aplicar filtros'
 local F={}
 function F.Validate()
  local lo=U.Min.Text:match('^%s*(.-)%s*$');local hi=U.Max.Text:match('^%s*(.-)%s*$')
  for _,v in ipairs({lo,hi})do local n=tonumber(v);if v~=''and(not n or n~=n or n<0 or n>1000000 or n%1~=0)then return nil,'Use um preço inteiro de 0 a 1.000.000 Robux.'end end
  if lo~=''and hi~=''and tonumber(lo)>tonumber(hi)then return nil,'O máximo precisa ser igual ou maior que o mínimo.'end
  return true
 end
 function F.Layout()
  local w,h=panel.AbsoluteSize.X,panel.AbsoluteSize.Y;if w<1 or h<1 then return end
  B.Rect(title,10,2,w-72,44);B.Rect(U.CloseFilter,w-54,0,48,48);U.CloseFilter.AnchorPoint=Vector2.zero
  B.Rect(body,8,52,w-16,math.max(44,h-112));body.CanvasSize=UDim2.fromOffset(0,352)
  local bw=w-16;for i,label in ipairs(labels)do B.Rect(label,2,(i-1)*76,bw-4,24)end
  B.Rect(U.Min,0,26,(bw-6)/2,44);B.Rect(U.Max,(bw+6)/2,26,(bw-6)/2,44)
  B.Rect(U.Creator,0,102,bw-112,44);B.Rect(U.CreatorType,bw-106,102,106,44)
  for i,o in ipairs({U.LimAll,U.LimOnly,U.LimNo})do B.Rect(o,(i-1)*(bw+6)/3,178,(bw-12)/3,44)end
  for i,o in ipairs({U.FormAll,U.FormClassic,U.Form3D})do B.Rect(o,(i-1)*(bw+6)/3,254,(bw-12)/3,44)end
  B.Rect(U.OffSale,0,304,bw,44)
  for _,o in ipairs({U.ClearFilter,U.ApplyFilter})do o.AnchorPoint=Vector2.zero end
  B.Rect(U.ClearFilter,8,h-52,(w-22)/3,44);B.Rect(U.ApplyFilter,14+(w-22)/3,h-52,(w-22)*2/3,44)
 end
 panel:GetPropertyChangedSignal('AbsoluteSize'):Connect(F.Layout);F.Layout();return F
end
return M
