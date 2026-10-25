-- 09C20_AVATAR_REMOVAL | ModuleScript | ReplicatedStorage | V77 (CRIAR)
-- Prévia da remoção; somente a confirmação altera a edição atual.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'))
local M={}
local groups={{'All','Todos'},{'Accessories','Acessórios'},{'Hair','Cabelo'},
 {'Classic','Roupas clássicas'},{'Layered','Roupas em camadas'},
 {'Face','Rosto'},{'Body','Partes do corpo'},{'Animations','Animações'}}
local bodySlots={Head=true,Torso=true,LeftArm=true,RightArm=true,LeftLeg=true,RightLeg=true}
local classic={Shirt=true,Pants=true,GraphicTShirt=true}

function M.Filter(A,body,selection)
 local result=A.Copy(body);local all=selection.All==true
 for slot in pairs(result.props or{})do
  if all or selection.Classic and classic[slot]or selection.Face and slot=='Face'
   or selection.Body and bodySlots[slot]or selection.Animations and slot:find('Animation',1,true)then
   result.props[slot]=0
  end
 end
 local accessories={}
 for _,entry in ipairs(result.accessories or{})do
  local hair=entry.type=='Hair'
  local remove=all or hair and selection.Hair or entry.layer and selection.Layered
   or not hair and not entry.layer and selection.Accessories
  if not remove then accessories[#accessories+1]=entry end
 end
 result.accessories=accessories
 return result
end

function M.Build(ctx)
 local U,A,S=ctx.U,ctx.A,ctx.S
 local R={Selected={}};local buttons={};local lastApply=-10
 R.Shade=D.New('Frame',{Name='AvatarRemovalShade',Size=UDim2.fromScale(1,1),
  BackgroundColor3=Color3.fromRGB(23,31,40),BackgroundTransparency=.55,Visible=false,ZIndex=140},U.Gui)
 R.Panel=D.Frame(R.Shade,{Name='AvatarRemovalPanel',BackgroundColor3=Color3.fromRGB(53,63,78),ZIndex=141})
 local title=D.Text(R.Panel,'Remoção de itens',{TextSize=19,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=142})
 local close=D.IconButton(R.Panel,'CloseRemoval','close','Cancelar remoção',{ZIndex=145})
 local list=D.Scroll(R.Panel,{Name='RemovalCategories',ZIndex=142,ScrollBarThickness=3})
 local view=D.New('ViewportFrame',{Name='RemovalPreview',BackgroundColor3=Color3.fromRGB(70,80,96),ZIndex=142},R.Panel)
 local remove=D.Button(R.Panel,'Remover selecionados',{Name='ConfirmRemoval',BackgroundColor3=Color3.fromRGB(231,104,111),TextColor3=Color3.fromRGB(31,30,35),ZIndex=143})
 local note=D.Text(R.Panel,'Confira a prévia. Desfazer recupera sua edição.',{TextSize=12,TextColor3=Color3.fromRGB(220,230,242),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=142})
 function R.Layout()
  local il,it,ir,ib,w,h=U.SafeBounds.Read();local aw,ah=w-il-ir,h-it-ib
  local pw=math.min(388,aw-16);local ph=math.min(350,ah-16)
  B.Rect(R.Panel,il+(aw-pw)/2,it+(ah-ph)/2,pw,ph)
  B.Rect(title,12,2,pw-76,44);B.Rect(close,pw-54,0,48,48)
  local lw=math.floor(pw*.55)
  B.Rect(list,8,50,lw-12,ph-142);list.CanvasSize=UDim2.fromOffset(0,#groups*46)
  B.Rect(view,lw,50,pw-lw-8,ph-142)
  for i,b in ipairs(buttons)do B.Rect(b,0,(i-1)*46,lw-16,44)end
  B.Rect(note,12,ph-84,pw-24,32);B.Rect(remove,12,ph-48,pw-24,44)
 end
 local function refresh()
  if not R.Shade.Visible or not S.Current then return end
  for i,b in ipairs(buttons)do
   local active=R.Selected.All or R.Selected[groups[i][1]]
   b.Text=(active and '☑ 'or '☐ ')..groups[i][2]
   b:SetAttribute('Selected',active==true)
  end
  Preview.Mount(view,M.Filter(A,S.Current,R.Selected),S.Rig,{drag=true,failed=ctx.toast})
 end
 function R.Close()R.Shade.Visible=false;Preview.Unmount(view)end
 function R.Open()
  if not S.Current then ctx.toast('Aguarde seu avatar carregar.');return end
  R.Selected={};R.Shade.Visible=true;R.Layout();refresh()
 end
 for i,definition in ipairs(groups)do
  local key=definition[1]
  local b=D.Button(list,'',{Name='Remove_'..key,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=Color3.fromRGB(63,75,91),ZIndex=143})
  buttons[i]=b
  b.Activated:Connect(function()
   if key~='All'and R.Selected.All then R.Selected.All=nil end
   R.Selected[key]=not R.Selected[key];refresh()
  end)
 end
 remove.Activated:Connect(function()
  if not R.Shade.Visible or not S.Current or os.clock()-lastApply<.4 then return end
  local selected=false;for _,value in pairs(R.Selected)do if value then selected=true;break end end
  if not selected then ctx.toast('Escolha uma categoria antes de remover.');return end
  lastApply=os.clock();local ok,why=S.Set(M.Filter(A,S.Current,R.Selected),false,S.Rig,true)
  if ok then R.Close()else ctx.toast(why or 'Não foi possível remover os itens.')end
 end)
 local bus=U.OpenRequest.Event:Connect(R.Close);local hud=U.HudAction.Event:Connect(R.Close)
 local keyboard=game:GetService('UserInputService').InputBegan:Connect(function(input,gp)if not gp and R.Shade.Visible and(input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB)then R.Close()end end)
 close.Activated:Connect(R.Close)
 local change=S.Changed.Event:Connect(refresh)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then R.Close()end end)
 U.SafeBounds.Watch(R.Layout)
 R.Shade.Destroying:Connect(function()bus:Disconnect();hud:Disconnect();keyboard:Disconnect();change:Disconnect();Preview.Unmount(view)end)
 return R
end
return M
