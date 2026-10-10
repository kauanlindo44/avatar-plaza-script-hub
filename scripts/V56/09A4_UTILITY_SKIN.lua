-- 09A4_UTILITY_SKIN | ModuleScript | ReplicatedStorage | V56
-- Superfícies de looks/comunidade/carrinho; mantém o editor de catálogo existente.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=Fx.Colors
local M={}
function M.Init(U)
 Fx.Surface(U.CartPanel,C.navy,Color3.fromRGB(45,34,58))
 U.CartSummary=D.Frame(U.CartPanel,{Name='CartCheckout',BackgroundColor3=C.panel,ZIndex=81});Fx.Surface(U.CartSummary,C.panel,Color3.fromRGB(25,52,62),C.jade)
 U.CartCount.Parent=U.CartSummary;U.CartTotal.Parent=U.CartSummary;U.CartClear.Parent=U.CartSummary;U.CartBuySelected.Parent=U.CartSummary
 U.CartRefresh=D.Button(U.CartSummary,'Recarregar',{Name='RefreshQuote',TextSize=12,ZIndex=83})
 U.CartHint=D.Text(U.CartPanel,'Marque os itens que deseja comprar.',{TextSize=12,TextColor3=D.Colors.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
 U.CartPreviewStage=Fx.Stage(U.CartPanel,'CartAvatarStage',81)
 U.CartPreview=D.New('ViewportFrame',{Name='CartAvatar',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=82},U.CartPreviewStage);U.CartPreview:SetAttribute('V54_Stage',true)
 U.CartPreviewLabel=D.Text(U.CartPreviewStage,'Seu look',{Position=UDim2.fromOffset(8,4),Size=UDim2.new(1,-16,0,24),TextColor3=Color3.fromRGB(33,51,70),Font=Enum.Font.GothamBold,TextSize=14,ZIndex=83})
 U.CartSelected.Text='Itens escolhidos';U.CartOutfit.Text='Look completo';U.CartClear.Text='Limpar';U.CartTotal.TextColor3=C.gold
 for _,b in ipairs({U.CartSelected,U.CartOutfit,U.CartClear,U.CartBuySelected,U.CartRefresh,U.CartClose})do Fx.Button(b,C.jade)end
 U.CartBuySelected.BackgroundColor3=C.jade;U.CartBuySelected.TextColor3=C.navy
 Fx.Surface(U.SavedPreviewPanel,C.navy,Color3.fromRGB(30,45,61),C.blue)
 Fx.Surface(U.SavedGridPanel,Color3.fromRGB(37,29,47),Color3.fromRGB(51,38,62),C.violet)
 U.SavedStage=Fx.Stage(U.SavedPreviewPanel,'SavedAvatarStage',2);U.SavedPreview.Parent=U.SavedStage;U.SavedPreview.ZIndex=3
 U.SavedPreview.BackgroundTransparency=1;U.SavedPreview:SetAttribute('V54_Stage',true)
 U.SavedShelfTitle=D.Text(U.SavedGridPanel,'SEUS LOOKS',{Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})
 U.OutfitApply.Text='Usar look';U.OutfitUpdate.Text='Salvar alterações';U.OutfitRestore.Text='Restaurar';U.OutfitBuy.Text='Carrinho';U.OutfitDelete.Text='Excluir';U.OutfitPublish.Text='Publicar';U.OutfitSaveNew.Text='+ Novo look'
 for _,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish,U.OutfitSaveNew,U.SavedLeft,U.SavedRight,U.SavedZoomIn,U.SavedZoomOut})do Fx.Button(b,C.blue)end
 U.OutfitApply.BackgroundColor3=C.jade;U.OutfitApply.TextColor3=C.navy
 U.OutfitUpdate.BackgroundColor3=Color3.fromRGB(103,76,130);U.OutfitUpdate.TextColor3=D.Colors.white
 Fx.Surface(U.SaveBox,C.navy,Color3.fromRGB(37,49,75),C.violet)
 for _,b in ipairs({U.SaveR15,U.SaveR6,U.CancelSave,U.SaveClose})do Fx.Button(b,C.violet)end
 U.SaveR15.BackgroundColor3=C.jade;U.SaveR15.TextColor3=C.navy;U.SaveR15.Text='Salvar · R15';U.SaveR6.Text='Salvar · R6'
 U.SaveStage=Fx.Stage(U.SaveBox,'SaveAvatarStage',91)
 U.SavePreview=D.New('ViewportFrame',{Name='SaveAvatar',BackgroundTransparency=1,BorderSizePixel=0,ZIndex=92},U.SaveStage);U.SavePreview:SetAttribute('V54_Stage',true)
 U.SaveHint=D.Text(U.SaveBox,'Guarde este look para usar quando quiser.',{TextSize=13,TextColor3=D.Colors.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=91})
 for _,o in ipairs(U.SaveBox:GetChildren())do if o:IsA('TextLabel')and o.Text=='Salvar look'then U.SaveHeading=o end end
 local function r(o,x,y,w,h)o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))end
 function U.LayoutSave(il,it,ir,ib,w,h)
  r(U.SaveBox,0,0,w,h);local aw=w-il-ir;local top=it+58
  r(U.SaveHeading,il+8,it+4,aw-72,44);r(U.SaveClose,w-ir-56,it+4,48,48)
  local bar=U.SafeBounds.Topbar()
  if aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then
   r(U.SaveHeading,bar.X+8,bar.Y+4,bar.Right-bar.X-72,44);r(U.SaveClose,bar.Right-56,bar.Y+4,48,48);top=it+4
  end
  local portrait=aw<560 and h>w;local available=h-ib-top-6;local sw=portrait and aw-12 or math.floor(aw*.53)
  local sh=portrait and available-202 or available;r(U.SaveStage,il+6,top,sw,sh);r(U.SavePreview,0,0,sw,sh)
  local x=portrait and il+8 or il+sw+20;local fw=portrait and aw-16 or aw-sw-28;local y=portrait and top+sh+8 or top+math.max(0,(available-194)/2)
  r(U.SaveName,x,y,fw,44);r(U.SaveHint,x,y+50,fw,36)
  r(U.SaveR15,x,y+92,(fw-6)/2,44);r(U.SaveR6,x+(fw+6)/2,y+92,(fw-6)/2,44)
  r(U.CancelSave,x,y+144,fw,44)
 end
 Fx.Surface(U.LookDetail,C.navy,Color3.fromRGB(24,43,53))
 U.LookStage=Fx.Stage(U.LookDetail,'CommunityAvatarStage',83);U.LookPreview.Parent=U.LookStage;U.LookPreview.ZIndex=84
 U.LookPreview.BackgroundTransparency=1;U.LookPreview:SetAttribute('V54_Stage',true)
 for _,b in ipairs({U.LookTry,U.LookBuy,U.LookFav,U.LookClose,U.LookCopy})do Fx.Button(b,C.jade)end
 U.LookTry.BackgroundColor3=C.jade;U.LookTry.TextColor3=C.navy
 for _,b in ipairs(U.LookViews)do Fx.Button(b,C.blue)end
 for _,panel in ipairs({U.SaveBox,U.CartPanel,U.LookDetail})do panel:GetPropertyChangedSignal('Visible'):Connect(function()Fx.Enter(panel)end)end
end
function M.Bind(U,A,S,Preview)
 local function savePreview()
  if not U.SaveBox.Visible then Preview.Unmount(U.SavePreview);return end
  if not S.Current then U.SaveHint.Text='Aguarde o carregamento do avatar.';return end
  local body=A.BodyRequiresR15(S.Current);U.SaveR6.Active=not body;U.SaveR6.TextColor3=body and D.Colors.muted or D.Colors.white
  U.SaveHint.Text=body and'Este corpo usa R15. Salve mantendo suas partes e roupas.'or'Guarde este look para usar quando quiser.'
  Preview.Mount(U.SavePreview,S.Current,S.Rig,{drag=true})
 end
 U.SaveBox:GetPropertyChangedSignal('Visible'):Connect(savePreview)
 S.Changed.Event:Connect(function()if U.SaveBox.Visible then savePreview()end end)
end
return M
