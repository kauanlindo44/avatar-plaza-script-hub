-- 09C19_EDITOR_UTILITIES | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
-- Histórico deste jogo, interface limpa e câmera livre local com restauração.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Input=game:GetService('UserInputService');local Run=game:GetService('RunService')
local Camera=require(Rep:WaitForChild('07G13_FREE_CAMERA'))
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors;local M={}
function M.Build(ctx)
 local U,S=ctx.U,ctx.S;local pg=Players.LocalPlayer:WaitForChild('PlayerGui');local W={};local safe=U.SafeBounds;local hidden={};local camera=Camera.Build(pg,safe,ctx.toast)
 local gui=D.New('ScreenGui',{Name='ACP_EditorUtilities',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=240,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 W.Restore=D.Button(gui,'Mostrar interface',{Name='RestorePlazaUI',Visible=false,TextSize=12,ZIndex=5})
 W.History=D.Frame(gui,{Name='CatalogPurchaseHistory',Visible=false,BackgroundColor3=C.panel,ZIndex=120})
 local title=D.Text(W.History,'Compras neste jogo',{TextSize=19,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=121});local close=D.IconButton(W.History,'ClosePurchaseHistory','close','Fechar histórico',{ZIndex=125})
 local note=D.Text(W.History,'Somente compras de itens confirmadas a partir da V72. Não é o histórico completo da sua conta.',{TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=121})
 local list=D.Scroll(W.History,{Name='PurchaseHistoryList',ScrollBarThickness=3,ZIndex=121});D.New('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},list)
 local refresh=D.Button(W.History,'Recarregar',{TextSize=12,ZIndex=122})
 function W.Layout()
  local il,it,ir,ib,w,h=safe.Read();B.Rect(W.Restore,w-ir-154,it+6,148,44);  local pw=math.min(580,w-il-ir-12);local ph=math.min(540,h-it-ib-12);B.Rect(W.History,il+(w-il-ir-pw)/2,it+(h-it-ib-ph)/2,pw,ph)
  B.Rect(title,12,2,pw-78,44);B.Rect(close,pw-56,0,48,48);B.Rect(note,12,50,pw-24,40);B.Rect(list,12,96,pw-24,ph-154);B.Rect(refresh,12,ph-50,pw-24,44)
 end
 local function restore()for g,on in pairs(hidden)do if g.Parent then g.Enabled=on end end;hidden={};W.Restore.Visible=false end
 function W.Clean()if W.Restore.Visible then restore();return end;for _,g in ipairs(pg:GetChildren())do if g:IsA('ScreenGui')and g~=gui then hidden[g]=g.Enabled;g.Enabled=false end end;W.Restore.Visible=true;W.Layout()end
 function W.StopCamera()camera.Stop()end
 function W.Camera()if ctx.close then ctx.close()else U.Root.Visible=false end;camera.Start()end
 function W.Purchases()
  W.History.Visible=true;W.Layout();note.Text='Consultando compras confirmadas neste jogo…'
  task.spawn(function()local r,e=ctx.call('PurchaseHistory');if not W.History.Visible then return end;if not r then note.Text=e;return end
   for _,o in ipairs(list:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
   for i,row in ipairs(r.rows or{})do local b=D.Button(list,'Item # '..row.id,{Size=UDim2.new(1,-4,0,70),LayoutOrder=i,TextSize=13,ZIndex=122});D.New('ImageLabel',{Image=ctx.A.Thumbnail({Id=row.id,ItemType=row.kind},150),Size=UDim2.fromOffset(64,64),Position=UDim2.fromOffset(3,3),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=123},b);b.TextXAlignment=Enum.TextXAlignment.Right
    b.Activated:Connect(function()task.spawn(function()local ok,it=pcall(function()return game:GetService('AvatarEditorService'):GetItemDetailsAsync(row.id,row.kind=='Bundle'and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset)end);if ok then W.History.Visible=false;ctx.showItem(it)else ctx.toast('O Roblox não retornou esse item.')end end)end)
   end;note.Text=r.retry and'Armazenamento ocupado. Toque em Recarregar.'or #r.rows==0 and'Nenhuma compra confirmada aqui desde a V72.'or'Compras nesta experiência · até 80 registros. Não inclui toda a conta.'
  end)
 end
 W.Restore.Activated:Connect(restore);close.Activated:Connect(function()W.History.Visible=false end);refresh.Activated:Connect(W.Purchases)
 local function stop()W.StopCamera();restore()end
 pg:GetAttributeChangedSignal('ACP_OpenPhotoNonce'):Connect(stop);pg:GetAttributeChangedSignal('ACP_OpenGamesNonce'):Connect(stop);Players.LocalPlayer.CharacterAdded:Connect(stop)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if U.Root.Visible and camera.Active then W.StopCamera()end end)
 safe.Watch(W.Layout);return W
end
return M
