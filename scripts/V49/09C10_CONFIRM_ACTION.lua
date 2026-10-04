-- 09C10_CONFIRM_ACTION | ModuleScript | ReplicatedStorage | V44
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local M={}
function M.Build(gui)
 local root=D.New("Frame",{Name="ConfirmRestore",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.3,Visible=false,Active=true,ZIndex=130},gui)
 local panel=D.Frame(root,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.85,0,0,180),ZIndex=131})
 local size=D.New("UISizeConstraint",{MaxSize=Vector2.new(520,180)},panel)
 local title=D.Text(panel,"",{Position=UDim2.fromOffset(12,10),Size=UDim2.new(1,-76,0,58),TextSize=20,Font=Enum.Font.GothamBold,ZIndex=132})
 local close=D.IconButton(panel,"CloseRestore","close","Cancelar restauração",{Position=UDim2.new(1,-56,0,6),Size=UDim2.fromOffset(48,48),ZIndex=140})
 local cancel=D.Button(panel,"Continuar editando",{Position=UDim2.fromOffset(12,104),Size=UDim2.new(.55,-18,0,52),ZIndex=132})
 local yes=D.Button(panel,"Restaurar",{Position=UDim2.new(.55,0,0,104),Size=UDim2.new(.45,-12,0,52),BackgroundColor3=D.Colors.green,TextColor3=D.Colors.bg,ZIndex=132})
 local callback
 local function hide()root.Visible=false;callback=nil end
 close.Activated:Connect(hide);cancel.Activated:Connect(hide);yes.Activated:Connect(function()local fn=callback;hide();if fn then fn()end end)
 return function(message,fn)title.Text=message;callback=fn;root.Visible=true end
end
return M
