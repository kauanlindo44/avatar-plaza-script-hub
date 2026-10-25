-- 07H12_SCORE_SHEET | ModuleScript | ReplicatedStorage | V77 (CRIAR)
-- Histórico de coordenadas aceitas; não calcula regras nem autoriza lances.
local M={Version='V77',Limit=120}
function M.Entry(move,side,ply,promotion)
 local function square(r,c)
  if type(r)~='number'or type(c)~='number'or r%1~=0 or c%1~=0 or r<1 or r>8 or c<1 or c>8 then return nil end
  return string.char(96+c)..tostring(9-r)
 end
 if type(move)~='table'then return nil end
 local from,to=square(move.fr,move.fc),square(move.tr,move.tc);if not from or not to then return nil end
 return{ply=ply,side=side,text=from..'–'..to..(promotion and table.find({'Q','R','B','N'},promotion)and('='..promotion)or'')}
end
function M.Append(rows,move,side,ply,promotion)
 local entry=M.Entry(move,side,ply,promotion);if not entry then return false end
 rows[#rows+1]=entry;while #rows>M.Limit do table.remove(rows,1)end;return true
end
function M.Build(parent)
 local D=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_DESIGN_SYSTEM'))
 local U={Key='',Rows={}}
 U.List=D.Scroll(parent,{Name='AcceptedMoveList',ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.None})
 function U.Set(rows)
  local key='';for _,r in ipairs(rows or{})do key=key..tostring(r.ply)..':'..tostring(r.text)..';'end
  if key==U.Key then return end;U.Key=key
  for _,r in ipairs(U.Rows)do r:Destroy()end;U.Rows={}
  for i=math.max(1,#(rows or{})-M.Limit+1),#(rows or{})do
   local entry=rows[i];local index=#U.Rows;local row=D.Text(U.List,tostring(entry.ply)..'.  '..tostring(entry.text):sub(1,32),{Name='AcceptedPly'..tostring(entry.ply),Position=UDim2.fromOffset(8,index*28),Size=UDim2.new(1,-16,0,26),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=index%2==0 and .9 or 1,BackgroundColor3=Color3.fromRGB(183,170,133)})
   U.Rows[#U.Rows+1]=row
  end
  U.List.CanvasSize=UDim2.fromOffset(0,#U.Rows*28)
  U.List.CanvasPosition=Vector2.new(0,math.max(0,#U.Rows*28-U.List.AbsoluteSize.Y))
 end
 return U
end
return M
