-- 09C19_EDITOR_UTILITIES | ModuleScript | ReplicatedStorage | V72 (NOVO)
-- Histórico deste jogo, interface limpa e câmera livre local com restauração.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Input=game:GetService('UserInputService');local Run=game:GetService('RunService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors;local M={}
function M.Build(ctx)
 local U,S=ctx.U,ctx.S;local pg=Players.LocalPlayer:WaitForChild('PlayerGui');local W={};local safe=U.SafeBounds;local hidden={};local cameraState;local connection;local yaw,pitch=0,0;local pointer,last;local moving={}
 local gui=D.New('ScreenGui',{Name='ACP_EditorUtilities',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=240,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 W.Restore=D.Button(gui,'Mostrar interface',{Name='RestorePlazaUI',Visible=false,TextSize=12,ZIndex=5})
 W.Free=D.Frame(gui,{Name='FreeCameraControls',Visible=false,BackgroundColor3=C.panel,ZIndex=5})
 local exit=D.Button(W.Free,'Sair da câmera',{TextSize=12,ZIndex=6});local touch={}
 for _,v in ipairs({{'F','↑'},{'B','↓'},{'L','←'},{'R','→'},{'U','+'},{'D','−'}})do local b=D.Button(W.Free,v[2],{TextSize=19,ZIndex=6});touch[#touch+1]=b;b.InputBegan:Connect(function(io)if io.UserInputType==Enum.UserInputType.Touch or io.UserInputType==Enum.UserInputType.MouseButton1 then moving[v[1]]=true end end);b.InputEnded:Connect(function()moving[v[1]]=nil end)end
 W.History=D.Frame(U.Root,{Name='CatalogPurchaseHistory',Visible=false,BackgroundColor3=C.panel,ZIndex=120})
 local title=D.Text(W.History,'Compras neste jogo',{TextSize=19,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=121});local close=D.IconButton(W.History,'ClosePurchaseHistory','close','Fechar histórico',{ZIndex=125})
 local note=D.Text(W.History,'Somente compras de itens confirmadas a partir da V72. Não é o histórico completo da sua conta.',{TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=121})
 local list=D.Scroll(W.History,{Name='PurchaseHistoryList',ScrollBarThickness=3,ZIndex=121});D.New('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},list)
 local refresh=D.Button(W.History,'Recarregar',{TextSize=12,ZIndex=122})
 function W.Layout()
  local il,it,ir,ib,w,h=safe.Read();B.Rect(W.Restore,w-ir-154,it+6,148,44);B.Rect(W.Free,il+6,h-ib-106,306,100);B.Rect(exit,4,4,298,44)
  for i,b in ipairs(touch)do B.Rect(b,4+(i-1)*50,52,44,44)end
  local pw=math.min(580,w-il-ir-12);local ph=math.min(540,h-it-ib-12);B.Rect(W.History,il+(w-il-ir-pw)/2,it+(h-it-ib-ph)/2,pw,ph)
  B.Rect(title,12,2,pw-78,44);B.Rect(close,pw-56,0,48,48);B.Rect(note,12,50,pw-24,40);B.Rect(list,12,96,pw-24,ph-154);B.Rect(refresh,12,ph-50,pw-24,44)
 end
 local function restore()for g,on in pairs(hidden)do if g.Parent then g.Enabled=on end end;hidden={};W.Restore.Visible=false end
 function W.Clean()if W.Restore.Visible then restore();return end;for _,g in ipairs(pg:GetChildren())do if g:IsA('ScreenGui')and g~=gui then hidden[g]=g.Enabled;g.Enabled=false end end;W.Restore.Visible=true;W.Layout()end
 function W.StopCamera()
  if connection then connection:Disconnect();connection=nil end;moving={};pointer=nil;W.Free.Visible=false
  local cam=workspace.CurrentCamera;if cameraState and cam then cam.CameraType=cameraState.Type;cam.CameraSubject=cameraState.Subject;cam.CFrame=cameraState.CFrame;cam.FieldOfView=cameraState.FOV end;cameraState=nil
 end
 function W.Camera()
  if cameraState then W.StopCamera();return end
  if pg:GetAttribute('ACP_TrucoActive')or Players.LocalPlayer:GetAttribute('ACP_InGameRoom')then ctx.toast('Termine ou oculte a partida antes de usar a câmera livre.');return end
  local cam=workspace.CurrentCamera;if not cam then return end;cameraState={Type=cam.CameraType,Subject=cam.CameraSubject,CFrame=cam.CFrame,FOV=cam.FieldOfView};local x,y=cam.CFrame:ToOrientation();pitch=x;yaw=y;cam.CameraType=Enum.CameraType.Scriptable;U.Root.Visible=false;W.Free.Visible=true;W.Layout()
  connection=Run.RenderStepped:Connect(function(dt)
   local function key(k)return not Input:GetFocusedTextBox()and Input:IsKeyDown(Enum.KeyCode[k])end
   local v=Vector3.new((moving.R or key('D'))and 1 or 0,(moving.U or key('E'))and 1 or 0,(moving.B or key('S'))and 1 or 0)-Vector3.new((moving.L or key('A'))and 1 or 0,(moving.D or key('Q'))and 1 or 0,(moving.F or key('W'))and 1 or 0)
   if v.Magnitude>1 then v=v.Unit end;local cf=CFrame.new(cam.CFrame.Position)*CFrame.Angles(0,yaw,0)*CFrame.Angles(pitch,0,0);cam.CFrame=CFrame.new(CFrame.Angles(0,yaw,0):VectorToWorldSpace(v)*math.min(dt,.1)*12)*cf
  end)
 end
 function W.Purchases()
  W.History.Visible=true;W.Layout();note.Text='Consultando compras confirmadas neste jogo…'
  task.spawn(function()local r,e=ctx.call('PurchaseHistory');if not W.History.Visible then return end;if not r then note.Text=e;return end
   for _,o in ipairs(list:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
   for i,row in ipairs(r.rows or{})do local b=D.Button(list,'Item # '..row.id,{Size=UDim2.new(1,-4,0,70),LayoutOrder=i,TextSize=13,ZIndex=122});D.New('ImageLabel',{Image=ctx.A.Thumbnail({Id=row.id,ItemType=row.kind},150),Size=UDim2.fromOffset(64,64),Position=UDim2.fromOffset(3,3),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=123},b);b.TextXAlignment=Enum.TextXAlignment.Right
    b.Activated:Connect(function()task.spawn(function()local ok,it=pcall(function()return game:GetService('AvatarEditorService'):GetItemDetailsAsync(row.id,row.kind=='Bundle'and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset)end);if ok then W.History.Visible=false;ctx.showItem(it)else ctx.toast('O Roblox não retornou esse item.')end end)end)
   end;note.Text=r.retry and'Armazenamento ocupado. Toque em Recarregar.'or #r.rows==0 and'Nenhuma compra confirmada aqui desde a V72.'or'Compras nesta experiência · até 80 registros. Não inclui toda a conta.'
  end)
 end
 exit.Activated:Connect(W.StopCamera);W.Restore.Activated:Connect(restore);close.Activated:Connect(function()W.History.Visible=false end);refresh.Activated:Connect(W.Purchases)
 Input.InputBegan:Connect(function(io,gp)
  if io.KeyCode==Enum.KeyCode.Escape and cameraState then W.StopCamera();return end;if not cameraState or gp then return end
  if io.UserInputType==Enum.UserInputType.MouseButton2 or io.UserInputType==Enum.UserInputType.Touch then local a,s=W.Free.AbsolutePosition,W.Free.AbsoluteSize;local p=io.Position;if p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y then return end;pointer=io;last=p end
 end)
 Input.InputChanged:Connect(function(io)if cameraState and pointer and(io==pointer or io.UserInputType==Enum.UserInputType.MouseMovement)then local p=io.Position;yaw=yaw-(p.X-last.X)*.004;pitch=math.clamp(pitch-(p.Y-last.Y)*.004,-1.5,1.5);last=p end end)
 Input.InputEnded:Connect(function(io)if io==pointer or io.UserInputType==Enum.UserInputType.MouseButton2 then pointer=nil end end)
 local function stop()W.StopCamera();restore()end
 pg:GetAttributeChangedSignal('ACP_OpenPhotoNonce'):Connect(stop);pg:GetAttributeChangedSignal('ACP_OpenGamesNonce'):Connect(stop);Players.LocalPlayer.CharacterAdded:Connect(stop)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if U.Root.Visible and cameraState then W.StopCamera()end;if not U.Root.Visible then W.History.Visible=false end end)
 safe.Watch(W.Layout);return W
end
return M
