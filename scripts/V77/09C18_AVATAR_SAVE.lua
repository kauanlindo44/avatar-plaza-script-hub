-- 09C18_AVATAR_SAVE | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- Salvar no jogo/Roblox, roupa nova, atualmente vestindo e restauração com prévia.
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Avatar=game:GetService('AvatarEditorService');local Market=game:GetService('MarketplaceService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local C={bg=Color3.fromRGB(207,221,233),panel=Color3.fromRGB(231,240,246),soft=Color3.fromRGB(185,212,222),ink=Color3.fromRGB(35,48,65),muted=Color3.fromRGB(76,94,114)};local M={}
function M.Build(ctx)
 local U,A,S=ctx.U,ctx.A,ctx.S;local pl=Players.LocalPlayer;local W={Mode='save'};local serial=0;local restoreBody;local pending
 W.Shade=D.Frame(U.Gui,{Name='AvatarSaveChoices',Size=UDim2.fromScale(1,1),Visible=false,BackgroundColor3=C.bg,BackgroundTransparency=.64,ZIndex=125})
 W.Panel=D.Frame(W.Shade,{Name='AvatarSavePanel',BackgroundColor3=C.panel,ZIndex=126})
 W.Title=D.Text(W.Panel,'Salvar seu avatar',{TextColor3=C.ink,TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=127})
 W.Close=D.IconButton(W.Panel,'CloseAvatarSave','close','Voltar ao editor',{BackgroundColor3=Color3.fromRGB(50,87,119),TextColor3=Color3.new(1,1,1),ZIndex=135})
 W.Stage=D.Frame(W.Panel,{Name='SaveAvatarStage',BackgroundColor3=C.soft,ZIndex=127});W.View=D.New('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=128},W.Stage)
 W.Options=D.Scroll(W.Panel,{Name='AvatarSaveOptions',ScrollBarThickness=3,ZIndex=127});D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},W.Options)
 W.Footer=D.New('Frame',{Name='WearingFooter',BackgroundTransparency=1,Visible=false,ZIndex=129},W.Panel)
 W.Note=D.Text(W.Panel,'',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=128})
 local function option(title,note,order,fn)
  local b=D.Button(W.Options,'',{Name='AvatarSaveChoice'..order,Size=UDim2.new(1,-4,0,86),LayoutOrder=order,BackgroundColor3=order%2==0 and Color3.fromRGB(205,223,218)or Color3.fromRGB(208,221,240),ZIndex=128})
  D.Text(b,title,{Position=UDim2.fromOffset(12,6),Size=UDim2.new(1,-24,0,30),TextColor3=C.ink,TextSize=16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=129})
  D.Text(b,note,{Position=UDim2.fromOffset(12,38),Size=UDim2.new(1,-24,0,38),TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=129});b.Activated:Connect(fn)
  if W.Mode=='wearing'and order<=2 then b.Parent=W.Footer;b.Size=UDim2.new(.5,-3,1,0);b.Position=UDim2.new((order-1)*.5,(order-1)*6,0,0)
   local labels=b:GetChildren();for _,label in ipairs(labels)do if label:IsA('TextLabel')then label.Visible=label.Font==Enum.Font.GothamBold;if label.Visible then label.Position=UDim2.fromOffset(4,2);label.Size=UDim2.new(1,-8,1,-4);label.TextSize=13 end end end
  end
  return b
 end
 local function clear()for _,parent in ipairs({W.Options,W.Footer})do for _,o in ipairs(parent:GetChildren())do o:Destroy()end end end
 function W.Layout()
  local il,it,ir,ib,w,h=U.SafeBounds.Read();local pw=math.min(520,w-il-ir-12);local ph=math.min(360,h-it-ib-12)
  B.Rect(W.Panel,il+(w-il-ir-pw)/2,it+(h-it-ib-ph)/2,pw,ph);B.Rect(W.Title,12,2,pw-76,44);B.Rect(W.Close,pw-56,0,48,48)
  local sw=pw>=540 and pw*.38 or pw*.34;B.Rect(W.Stage,10,54,sw-16,ph-106);B.Rect(W.Options,sw+4,54,pw-sw-14,ph-106);B.Rect(W.Note,12,ph-48,pw-24,42)
  W.Footer.Visible=W.Mode=='wearing';if W.Mode=='wearing'then
   B.Rect(W.Stage,10,54,sw-16,ph-160)
   B.Rect(W.Options,sw+4,54,pw-sw-14,ph-160);B.Rect(W.Footer,10,ph-100,pw-20,44)
   local grid=W.Options:FindFirstChildOfClass('UIGridLayout');if grid then local cols=W.Options.AbsoluteSize.X>=208 and 2 or 1;grid.FillDirectionMaxCells=cols;grid.CellSize=UDim2.fromOffset((W.Options.AbsoluteSize.X-4-(cols-1)*6)/cols,104)end
  end
 end
 function W.Hide()serial=serial+1;W.Shade.Visible=false;Preview.Unmount(W.View)end
 local function native(kind)
  if pending then ctx.toast('Aguarde a confirmação do Roblox.');return end
  local desc=S.Description();if not desc then ctx.toast('Aguarde seu avatar carregar.');return end
  pending={kind=kind,desc=desc};local request=pending
  local ok,e=pcall(function()if kind=='outfit'then Avatar:PromptCreateOutfit(desc,S.Rig=='R6'and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15)else Avatar:PromptSaveAvatar(desc,S.Rig=='R6'and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15)end end)
  if not ok then desc:Destroy();pending=nil;W.Note.Text='O Roblox não abriu o salvamento. Tente novamente.';return end
  W.Note.Text='Confirme no Roblox. O resultado aparecerá quando ele responder.'
  task.delay(35,function()if pending==request then pending=nil;desc:Destroy();ctx.toast('O Roblox ainda não confirmou o salvamento. Confira sua conta antes de repetir.')end end)
 end
 local function completed(kind,result,failure)
  if not pending or pending.kind~=kind then return end;pending.desc:Destroy();pending=nil
  local ok=result==Enum.AvatarPromptResult.Success
  W.Note.Text=ok and(kind=='outfit'and'Nova roupa salva na sua conta Roblox.'or'Avatar da conta Roblox atualizado.')or('O Roblox não confirmou: '..tostring(failure or result)..'. Sua edição foi mantida.')
  ctx.toast(W.Note.Text)
 end
 local saveConnection=Avatar.PromptSaveAvatarCompleted:Connect(function(result)completed('avatar',result)end)
 local outfitConnection=Avatar.PromptCreateOutfitCompleted:Connect(function(result,failure)completed('outfit',result,failure)end)
 local function openBase(mode,title,body,rig)
  serial=serial+1;clear();W.Mode=mode
  if mode=='wearing'then D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},W.Options)else D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},W.Options)end
  W.Panel.BackgroundColor3=mode=='restore'and Color3.fromRGB(245,234,208)or mode=='wearing'and Color3.fromRGB(218,236,229)or C.panel;W.Title.Text=title;W.Note.Text='';W.Shade.Visible=true;W.Layout();Preview.Mount(W.View,body,rig,{drag=true,failed=ctx.toast})
 end
 function W.Open()
  if not S.Current then ctx.toast('Aguarde a prévia.');return end;openBase('save','Onde você quer salvar?',S.Current,S.Rig)
  option('Meus looks do Plaza','Guardar esta combinação neste jogo.',1,function()W.Hide();U.SaveName.Text='';U.SaveR6.Active=not A.BodyRequiresR15(S.Current);U.SaveBox.Visible=true end)
  option('Nova roupa Roblox','Criar uma roupa salva na sua conta.',2,function()native('outfit')end)
  option('Meu avatar Roblox','Atualizar o avatar que sua conta usa.',3,function()native('avatar')end)
  W.Note.Text='Salvar no Roblox depende das permissões e dos itens que você possui.'
 end
 function W.Restore()
  openBase('restore','Restaurar avatar da conta?',S.Current,S.Rig);W.Note.Text='Consultando seu avatar atual no Roblox…';local mine=serial;restoreBody=nil
  local b=option('Restaurar este avatar','Sua edição anterior continua em Desfazer.',1,function()
   if not restoreBody then return end;ctx.call('ClearInspect');local ok,e=S.Set(restoreBody,false,A.BodyRequiresR15(restoreBody)and'R15'or S.Rig);ctx.toast(ok and'Avatar da conta restaurado. Desfazer recupera a edição.'or e);if ok then W.Hide()end
  end);D.SetEnabled(b,false)
  option('Continuar editando','Voltar sem trocar o avatar.',2,W.Hide)
  task.spawn(function()
   local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserIdAsync(pl.UserId)end)
   if mine~=serial or not W.Shade.Visible then if ok and desc then desc:Destroy()end;return end
   if not ok or not desc then W.Note.Text='O Roblox não carregou seu avatar. Feche e tente de novo.';return end
   restoreBody=A.Pack(desc);desc:Destroy();Preview.Mount(W.View,restoreBody,A.BodyRequiresR15(restoreBody)and'R15'or S.Rig,{drag=true});D.SetEnabled(b,true);W.Note.Text='Esta é a aparência atual da sua conta. Confirme para restaurar.'
  end)
 end
 function W.Wearing()
  if not S.Current then ctx.toast('Aguarde o avatar.');return end;openBase('wearing','Atualmente vestindo',S.Current,S.Rig)
  local body=A.Copy(S.Current);local mine=serial
  option('Comprar / conferir o look','Abra os itens e preços no carrinho do outfit.',1,function()W.Hide();ctx.buyBody(body)end)
  option('Salvar esta combinação','Escolher onde guardar seu avatar.',2,W.Open)
  for i,item in ipairs(A.Entries(body))do
   local b=D.Button(W.Options,'',{Name='WearingItem_'..item.Id,Size=UDim2.new(1,-4,0,76),LayoutOrder=i+2,BackgroundColor3=Color3.fromRGB(201,222,217),ZIndex=128})
   D.New('ImageLabel',{Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(50,50),BackgroundTransparency=1,Image=A.AssetThumb(item.Id,150),ScaleType=Enum.ScaleType.Fit,ZIndex=129},b)
   local label=D.Text(b,'Item # '..item.Id,{Position=UDim2.fromOffset(58,4),Size=UDim2.new(1,-62,0,44),TextColor3=C.ink,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=129})
   local price=D.Text(b,'Consultar preço',{Position=UDim2.fromOffset(4,56),Size=UDim2.new(1,-8,0,44),TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=129})
   task.spawn(function()local ok,detail=pcall(function()return Avatar:GetItemDetailsAsync(item.Id,Enum.AvatarItemType.Asset)end);if mine~=serial or not label.Parent then return end;if ok and detail then label.Text=detail.Name;local has,owned=pcall(function()return Market:PlayerOwnsAssetAsync(pl,item.Id)end);if mine~=serial or not price.Parent then return end;price.Text=A.PriceText(detail)..(has and(owned and' · Já possui'or' · Não possui')or' · Posse não confirmada');b.Activated:Connect(function()W.Hide();if ctx.showItem then ctx.showItem(detail)end end)end end)
  end
  W.Note.Text='Toque em uma peça para ver os detalhes. A prévia pode ser girada.';W.Layout()
 end
 local bus=U.OpenRequest.Event:Connect(W.Hide);local hud=U.HudAction.Event:Connect(W.Hide)
 local keyboard=game:GetService('UserInputService').InputBegan:Connect(function(input,gp)if not gp and W.Shade.Visible and(input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB)then W.Hide()end end)
 W.Close.Activated:Connect(W.Hide);U.Root:GetPropertyChangedSignal('AbsoluteSize'):Connect(W.Layout);U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then W.Hide()end end)
 W.Shade.Destroying:Connect(function()bus:Disconnect();hud:Disconnect();keyboard:Disconnect();saveConnection:Disconnect();outfitConnection:Disconnect();if pending then pending.desc:Destroy();pending=nil end;Preview.Unmount(W.View)end);return W
end
return M
