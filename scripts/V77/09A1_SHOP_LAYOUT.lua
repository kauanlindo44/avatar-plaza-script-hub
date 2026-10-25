-- 09A1_SHOP_LAYOUT | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- V51: origem dos insets corrigida, topo livre e prévia sem controles sobre o corpo.
local M={}
local Reference=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_REFERENCE_LAYOUT'))
local Gui=game:GetService("GuiService")
local Tween=game:GetService("TweenService")
function M.Init(U)
 require(game:GetService('ReplicatedStorage'):WaitForChild('09A4_UTILITY_SKIN')).Init(U)
 local D=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_DESIGN_SYSTEM'));local Fx=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_SURFACE_EFFECTS'))
 Fx.Surface(U.Root,Color3.fromRGB(32,33,38),Color3.fromRGB(35,36,41),D.Colors.orange)
 Fx.Surface(U.PreviewShell,Color3.fromRGB(35,36,41),Color3.fromRGB(32,33,38))
 for _,b in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook,U.BodyToggle,U.Filter,U.SubToggle})do Fx.Button(b,D.Colors.orange)end
 U.Main.BackgroundColor3=D.Colors.panel;U.Main.BackgroundTransparency=0;U.Root.BackgroundTransparency=1;U.Left.BackgroundTransparency=1;U.Main.BackgroundTransparency=.05
 local wide=true
 U.SponsorPreviewShade=D.New('TextButton',{Name='SponsorPreviewShade',Text='',Size=UDim2.fromScale(1,1),BackgroundColor3=D.Colors.bg,BackgroundTransparency=.35,Visible=false,ZIndex=84},U.Root)
 U.SponsorPreviewClose=D.IconButton(U.Root,'CloseSponsorPreview','close','Voltar aos itens',{Visible=false,ZIndex=89})
 local function closeSponsorPreview()U.SponsorPreviewOpen=false;U.Layout()end
 U.SponsorPreviewShade.Activated:Connect(closeSponsorPreview);U.SponsorPreviewClose.Activated:Connect(closeSponsorPreview)
 local function rect(o,x,y,w,h)
  o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
 end
 local function insets()
  if U.SafeBounds then return U.SafeBounds.Read()end
  local p,s=U.SafeGuide.AbsolutePosition,U.SafeGuide.AbsoluteSize;local v=U.Root.AbsoluteSize
  return p.X,p.Y,math.max(0,v.X-p.X-s.X),math.max(0,v.Y-p.Y-s.Y)
 end
 local function heading(title,close,il,it,ir,w)
  local x,y,last=il+12,it+4,w-ir-8
  rect(title,x,y,last-x-58,48);rect(close,last-48,y,48,48);close.ZIndex=math.max(close.ZIndex,50)
  return y+54
 end
 function U.LayoutEditor()
  local w,h=U.Left.AbsoluteSize.X,U.Left.AbsoluteSize.Y;local _,top=insets()
  local rowH=44;local aw=w-12;local cols=aw>=220 and 5 or 3;local actionGap=cols==5 and math.clamp((aw-220)/4,0,4)or 4
  local actionH=cols==5 and rowH or rowH*2+4;local minFooter=actionH+72
  local vh=math.max(32,h-top-minFooter-12)
  rect(U.PreviewShell,6,top+4,aw,vh)
  local controls={};if U.ToolsButton then controls[#controls+1]=U.ToolsButton end;if U.StopEmote.Visible then controls[#controls+1]=U.StopEmote end
  local rail=0;rect(U.Viewport,0,0,aw,vh)
  for _,b in ipairs({U.ViewLeft,U.ViewRight,U.ZoomIn,U.ZoomOut})do b.Visible=false end
  local footerY=top+vh+10;local footer=math.max(1,h-footerY-4)
  rect(U.EditorFooter,6,footerY,aw,footer);U.EditorFooter.CanvasSize=UDim2.fromOffset(0,footer);U.EditorFooter.ScrollingEnabled=false
  rect(U.Actions,0,0,aw,actionH)
  U.ActionGrid.SortOrder=Enum.SortOrder.LayoutOrder;U.ActionGrid.FillDirectionMaxCells=cols;U.ActionGrid.CellPadding=UDim2.fromOffset(actionGap,4);U.ActionGrid.CellSize=UDim2.fromOffset(math.floor((aw-actionGap*(cols-1))/cols),rowH)
  U.BodyToggle.Text="";U.BodyToggle.LayoutOrder=5
  U.Total.Visible=false;U.ItemStrip.Visible=true;U.ItemStrip.ZIndex=6
  rect(U.ItemStrip,0,actionH+6,aw,math.max(44,footer-actionH-6));U.ItemStrip.ClipsDescendants=true
  rect(U.PreviewInfo,6,4,44,20);U.PreviewInfo.TextSize=12
  U.HidePreview.Visible=false;U.PreviewToggle.Visible=false
  for i,o in ipairs(controls)do rect(o,aw-48,4+(i-1)*48,44,44);o.TextSize=20 end
  rect(U.PreviewError,6,math.max(4,vh*.22),aw-rail-12,math.max(28,math.min(64,vh-90)))
  rect(U.PreviewRetry,8,vh-48,aw-rail-16,44)
  local mw=U.Main.AbsoluteSize.X;local rp=U.Main.Position;local rh=U.Root.AbsoluteSize.Y;local _,_,_,ib=insets()
  local bw=math.min(mw-12,390);local bh=math.min(448,rh-ib-math.max(top,rp.Y.Offset)-12)
  rect(U.BodyWindow,rp.X.Offset+mw-bw-6,math.max(top+4,rh-ib-bh-6),bw,bh)
  for i,btn in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook,U.BodyToggle})do btn.LayoutOrder=i;btn.TextSize=w<300 and 12 or 14;btn.TextWrapped=false end
  for _,pair in ipairs({{U.Save,'Salvar'},{U.Reset,'Voltar'},{U.BuyLook,'Cesta'},{U.BodyToggle,'Corpo'}})do
   local b=pair[1];b.Text=pair[2];b.TextYAlignment=Enum.TextYAlignment.Bottom;b.TextSize=11
   for _,icon in ipairs(b:GetChildren())do if icon.Name:find('Icon_',1,true)then icon.AnchorPoint=Vector2.new(.5,0);icon.Position=UDim2.new(.5,0,0,2);icon.Size=UDim2.fromOffset(22,22)end end
  end
  U.Apply.Text="Usar";local ap=U.Apply:FindFirstChildOfClass("UIPadding");if ap then ap.PaddingLeft=UDim.new(0,2);ap.PaddingRight=UDim.new(0,2)end
 end
 local busy=false
 local function layout()
  if busy then return end;busy=true
  local w,h=U.Root.AbsoluteSize.X,U.Root.AbsoluteSize.Y
  if w<1 or h<1 then busy=false;return end
  local il,it,ir,ib=insets();local usable=w-il-ir
  local portrait=w<h and usable<700;local band=math.min(h-240-ib,math.max(it+240,(h-ib)*.48))
  local sponsor=U.ActivePage=='Stores';local floating=sponsor and portrait;U.Left.ZIndex=floating and 85 or 1
  U.Left.Visible=floating and U.SponsorPreviewOpen==true or not floating and not wide
  U.SponsorPreviewShade.Visible=floating and U.SponsorPreviewOpen==true;U.SponsorPreviewClose.Visible=U.SponsorPreviewShade.Visible
  if floating then
   rect(U.Main,il,0,usable,h-ib);local pw=math.min(300,usable-12);rect(U.Left,il+(usable-pw)/2,it+50,pw,h-ib-it-56);rect(U.SponsorPreviewClose,il+(usable+pw)/2-48,it+2,48,48)
  elseif wide then rect(U.Main,il,0,usable,h-ib)
  elseif portrait then
   rect(U.Left,il,0,usable,band);rect(U.Main,il,band,usable,h-band-ib)
  else
   local lw=sponsor and math.floor(math.clamp(usable*.25,180,360))or math.floor(math.clamp(usable*.31,math.min(236,usable*.43),420))
   rect(U.Left,il+4,0,lw-4,h-ib);rect(U.Main,il+lw+6,0,usable-lw-10,h-ib)
  end
  local mw,mh=U.Main.AbsoluteSize.X,U.Main.AbsoluteSize.Y
  U.PageTitle.Visible=wide;rect(U.PageTitle,12,it+6,mw-72,40)
  local header=portrait and not wide and 4 or it+4;local start=6
  if not portrait and not wide and U.SafeBounds and U.SafeBounds.Topbar then
   local bar=U.SafeBounds.Topbar();local mx=U.Main.Position.X.Offset
   local x=math.max(6,bar.X-mx+4);local available=math.min(mw-6,bar.Right-mx)-x
   if bar.Bottom-bar.Y>=48 and available>=380 then header=bar.Y+(bar.Bottom-bar.Y-48)/2;start=x end
  end
  local hw=mw-start-6;local compact=hw<580;local fixed=compact and 236 or 296
  rect(U.Query,start,header,hw-fixed,44)
  rect(U.SearchGo,start+hw-fixed+4,header,40,44)
  rect(U.Filter,mw-(compact and 186 or 246),header,compact and 58 or 84,44);U.Filter.TextSize=13
  rect(U.Sort,mw-(compact and 124 or 158),header,compact and 66 or 100,44);U.Sort.TextSize=13
  rect(U.Close,mw-54,header,48,48);U.Close.ZIndex=80
  local row=U.Groups.Parent;local rowY=math.max(header+50,portrait and not wide and 0 or it+4)
  rect(row,6,rowY,mw-12,44)
  local subw=math.min(156,math.max(96,mw*.23))
  U.SubToggle.AnchorPoint=Vector2.new(1,0);U.SubToggle.Position=UDim2.new(1,-70,0,0);U.SubToggle.Size=UDim2.fromOffset(subw,44);U.SubToggle.TextSize=13
  U.Groups.Size=UDim2.new(1,-subw-78,1,0)
  local gy=rowY+48
  rect(U.Grid,6,gy,mw-12,mh-gy-22)
  rect(U.Status,6,mh-20,mw-12,18);U.Status.TextSize=12
  rect(U.More,mw-70,rowY,64,44)
  rect(U.SubsPopup,6,gy,mw-12,math.min(174,mh-gy-6))
  local filterY=math.max(header+48,portrait and not wide and 0 or it+4)
  rect(U.FilterPanel,math.max(6,mw-348),filterY,math.min(342,mw-12),math.min(338,mh-filterY-6))
  rect(U.CloseFilter,U.FilterPanel.Position.X.Offset+U.FilterPanel.Size.X.Offset-56,U.FilterPanel.Position.Y.Offset+4,48,48)
  local dw=math.min(360,mw-12);local dh=math.min(218,h-it-ib-16)
  local dx=math.clamp(tonumber(U.Detail:GetAttribute("AnchorX"))or U.Main.Position.X.Offset+6,il+6,w-ir-dw-6)
  local dy=math.clamp((tonumber(U.Detail:GetAttribute("AnchorY"))or it+56)+6,it+8,h-ib-dh-8)
  rect(U.Detail,dx,dy,dw,dh);rect(U.DetailClose,dw-54,2,48,48)
  rect(U.DetailImage,8,8,66,66);rect(U.DetailName,82,6,dw-144,46);U.DetailName.TextSize=14
  rect(U.DetailPrice,82,52,dw-92,22);U.DetailPrice.TextSize=15
  U.DetailCreator.Visible=false;U.Favorite.Visible=true;U.Favorite.Text="+ CARRINHO"
  rect(U.Favorite,8,dh-100,dw-16,44)
  rect(U.DescriptionScroll,8,82,dw-16,math.max(20,dh-188));U.DescriptionScroll.ScrollingEnabled=false
  U.DetailDescription.TextSize=12;U.DetailDescription.AutomaticSize=Enum.AutomaticSize.None;U.DetailDescription.Size=UDim2.fromScale(1,1);U.DetailDescription.TextTruncate=Enum.TextTruncate.AtEnd
  rect(U.Try,8,dh-52,(dw-22)/2,44);rect(U.Buy,dw/2+3,dh-52,(dw-22)/2,44)
  -- Other utilities keep their dedicated page, with no empty shell behind them.
  local wideY=portrait and not wide and 4 or it+4
  if not wide and U.ActivePage~='Catalog'then rect(U.Close,mw-54,2,48,48)end
  if wide then
   wideY=heading(U.PageTitle,U.Close,0,it,0,mw)
   local bar=U.SafeBounds and U.SafeBounds.Topbar and U.SafeBounds.Topbar()
   if usable>=520 and bar and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then
    local origin=U.Main.Position.X.Offset
    rect(U.PageTitle,bar.X-origin+8,bar.Y+4,bar.Right-bar.X-72,44);rect(U.Close,bar.Right-origin-56,bar.Y+4,48,48);wideY=it+4
   end
  end
  for _,page in ipairs({U.LooksArea,U.CommunityArea,U.StoresArea})do rect(page,0,wideY,mw,mh-wideY)end
  if sponsor then
   local bar=U.SafeBounds and U.SafeBounds.Topbar();local mx=U.Main.Position.X.Offset;local sy=it+4;local reserve=0
   if bar and bar.Bottom-bar.Y>=48 and mx+6>=bar.X and mw>=284 then sy=bar.Y+2;reserve=56 end
   rect(U.StoresArea,0,sy,mw,mh-sy);U.StoresArea:SetAttribute('TopRightReserved',reserve)
   rect(U.Close,mw-54,reserve>0 and sy or math.max(2,it-52),48,48)
  end

  local cw=usable;local cartY=heading(U.CartTitle,U.CartClose,il,it,ir,w)
  local bar=U.SafeBounds and U.SafeBounds.Topbar and U.SafeBounds.Topbar()
  if usable>=520 and bar and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then
   rect(U.CartTitle,bar.X+8,bar.Y+4,bar.Right-bar.X-72,44);rect(U.CartClose,bar.Right-56,bar.Y+4,48,48);cartY=it+4
  end
  U.CartTitle.TextSize=22
  local side=cw>=520 and w>h;U.CartPreviewToggle.Visible=side
  if side then
   local tx,ty=U.CartClose.Position.X.Offset-102,U.CartClose.Position.Y.Offset
   rect(U.CartPreviewToggle,tx,ty+2,96,44);U.CartTitle.Size=UDim2.fromOffset(math.max(60,tx-U.CartTitle.Position.X.Offset-8),44)
  end
  U.CartPreviewToggle.Text=U.CartPreviewOpen and'Ocultar look'or'Ver look'
  rect(U.CartSelected,il+6,cartY,(cw-18)/2,44);rect(U.CartOutfit,il+12+(cw-18)/2,cartY,(cw-18)/2,44)
  rect(U.CartHint,il+8,cartY+46,cw-16,20)
  local cy=cartY+68;local show=side and U.CartPreviewOpen;local pw=show and math.clamp(math.floor(cw*.23),140,280)or 0
  U.CartPreviewStage.Visible=show;rect(U.CartPreviewStage,il+6,cy,pw,h-ib-cy-6)
  rect(U.CartPreview,4,28,math.max(1,pw-8),U.CartPreviewStage.Size.Y.Offset-32)
  local x=il+6+(show and pw+6 or 0);local rw=cw-12-(show and pw+6 or 0);local compact=rw>=380;local footer=compact and 64 or 100
  rect(U.CartList,x,cy,rw,h-ib-cy-footer-10);rect(U.CartSummary,x,h-ib-footer-4,rw,footer)
  if compact then
   local tw=math.max(120,rw*.33);rect(U.CartCount,8,5,tw-8,22);rect(U.CartTotal,8,29,tw-8,28)
   rect(U.CartClear,tw+6,10,64,44);rect(U.CartRefresh,tw+76,10,44,44);U.CartRefresh.Text='↻'
   rect(U.CartBuySelected,tw+126,10,rw-tw-134,44)
  else
   rect(U.CartCount,8,2,rw-16,22);rect(U.CartTotal,8,24,rw-16,24)
   rect(U.CartClear,8,52,64,44);rect(U.CartRefresh,78,52,44,44);U.CartRefresh.Text='↻';rect(U.CartBuySelected,128,52,rw-136,44)
  end
  U.CartRefresh:SetAttribute('ActionLabel','Atualizar preços e itens que você já possui');U.CartCount.TextSize=12;U.CartTotal.TextSize=16
  local loaderY=heading(U.LoaderTitle,U.LoaderClose,il,it,ir,w);local viewY=loaderY+52
  rect(U.LoaderQuery,il+12,loaderY,cw-182,44)
  rect(U.LoaderMine,w-ir-164,loaderY,64,44);rect(U.LoaderSearch,w-ir-94,loaderY,82,44)
  local available=h-ib-viewY-56
  if w>=640 then
   local thumb=math.max(80,math.min(cw*.44,available));rect(U.LoaderThumb,il+12,viewY,thumb,thumb)
   local rx=il+thumb+28;local rw=w-ir-rx-12
   rect(U.LoaderName,rx,viewY+6,rw,44);rect(U.LoaderStatus,rx,viewY+62,rw,64)
  else
   local thumb=math.max(80,math.min(cw-24,available-108));rect(U.LoaderThumb,(w-thumb)/2,viewY,thumb,thumb)
   rect(U.LoaderName,il+12,viewY+thumb+12,cw-24,36);rect(U.LoaderStatus,il+12,viewY+thumb+52,cw-24,48)
  end
  rect(U.LoaderUseR6,il+12,h-ib-52,(cw-30)/2,44);rect(U.LoaderUse,il+18+(cw-30)/2,h-ib-52,(cw-30)/2,44)
  for _,dialog in ipairs({U.PublishBox,U.RigBox})do dialog.Size=UDim2.fromOffset(math.min(384,cw-24),dialog.Size.Y.Offset)end
  U.LayoutSave(il,it,ir,ib,w,h)
  U.Toast.Size=UDim2.fromOffset(math.min(520,cw-24),48)
  U.Toast.Position=UDim2.new(.5,(il-ir)/2,1,-ib-8)
  Reference.Shop(U,wide);U.LayoutEditor();Reference.Editor(U);U.LayoutLooks();U.LayoutLookDetail();Reference.Utilities(U);busy=false
 end
 function U.SetWide(v)wide=v==true;U.BodyWindow.Visible=false;layout()end
 function U.ShowPreview()wide=false;layout()end
 local function animate(panel)
  if not panel.Visible then return end
  local scale=panel:FindFirstChildOfClass("UIScale")or Instance.new("UIScale");scale.Parent=panel;scale.Scale=.98
  if Gui.ReducedMotionEnabled then scale.Scale=1;return end
  pcall(function()Tween:Create(scale,TweenInfo.new(.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1}):Play()end)
 end
 function U.AnimateMode()animate(U.PreviewShell)end
 for _,panel in ipairs({U.Detail,U.BodyWindow,U.SubsPopup,U.FilterPanel,U.SaveBox,U.PublishBox,U.RigBox})do panel:GetPropertyChangedSignal("Visible"):Connect(function()animate(panel)end)end
 U.Layout=layout
 U.StopEmote:GetPropertyChangedSignal("Visible"):Connect(layout)
 for _,o in ipairs({U.Root,U.Main,U.Left,U.SafeGuide,U.CartPanel,U.Loader,U.PlusPanel})do o:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)end
 U.SafeGuide:GetPropertyChangedSignal("AbsolutePosition"):Connect(layout)
 pcall(function()local c=Gui:GetPropertyChangedSignal("TopbarInset"):Connect(layout);U.Gui.Destroying:Connect(function()c:Disconnect()end)end)
 U.LookDetail:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.LayoutLookDetail)
 U.SavedPreviewPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.LayoutLooks)
 if U.SafeBounds then U.SafeBounds.Watch(layout)else task.defer(layout)end
end
return M
