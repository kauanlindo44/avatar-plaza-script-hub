-- 09I23_REQUEST_PROGRESS | ModuleScript | ReplicatedStorage | V72 (NOVO)
-- Etapas vêm dos eventos reais do servidor; concluir exige validação nativa.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local M={}
function M.Build(U)
 local P={Rows={},Order={}};U.Progress.TextYAlignment=Enum.TextYAlignment.Top
 U.ProgressTrack.Visible=false
 P.Stop=D.Button(U.Composer,'■',{Name='StopLookRequest',TextSize=18,Visible=false,ZIndex=86});P.Stop:SetAttribute('ACP_Primary',true)
 function P.Layout()P.Stop.Position=U.Send.Position;P.Stop.Size=U.Send.Size end
 function P.Busy(value)P.Stop.Visible=value;U.Send.Visible=not value;P.Layout()end
 function P.Reset()
  for _,v in pairs(P.Rows)do v:Destroy()end;P.Rows={};P.Order={};U.Progress.Size=UDim2.new(1,-6,0,44);U.Progress.Text='Preparando seu pedido…'
 end
 function P.Update(data)
  U.Progress.Text=tostring(data.label or'Buscando…');local part=data.stage
  if type(part)=='table'and type(part.part)=='string'then
   local key=part.part;local row=P.Rows[key]
   if not row then row=D.Text(U.Progress,'',{Position=UDim2.fromOffset(4,40+#P.Order*26),Size=UDim2.new(1,-8,0,24),TextSize=13,TextXAlignment=Enum.TextXAlignment.Left});P.Rows[key]=row;P.Order[#P.Order+1]=key end
   row.Text=(part.state=='done'and'✓  'or part.state=='skipped'and'–  'or'◌  ')..tostring(data.label or key);row:SetAttribute('ACP_Muted',part.state~='done')
  end
  U.Progress.Size=UDim2.new(1,-6,0,48+#P.Order*26);U.ScrollBottom()
 end
 P.Stop.Activated:Connect(function()if U.OnCancelRequest then U.OnCancelRequest()end end)
 U.Composer:GetPropertyChangedSignal('AbsoluteSize'):Connect(P.Layout);P.Layout();return P
end
return M
