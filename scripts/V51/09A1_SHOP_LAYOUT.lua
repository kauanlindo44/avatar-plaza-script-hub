-- 09A1_SHOP_LAYOUT | ModuleScript | ReplicatedStorage
-- V51: origem dos insets corrigida, topo livre e prévia sem controles sobre o corpo.
local M={}
local Gui=game:GetService("GuiService")
local Tween=game:GetService("TweenService")
function M.Init(U)
 local wide=true
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
  local rowH=44;local aw=w-12;local cols=aw>=236 and 5 or 3
  local actionH=cols==5 and rowH or rowH*2+4;local minFooter=actionH+72
  local vh=math.max(96,h-top-minFooter-12)
  rect(U.PreviewShell,6,top+4,aw,vh)
  local controls={U.ViewLeft,U.ViewRight,U.ZoomIn,U.ZoomOut};if U.StopEmote.Visible then controls[#controls+1]=U.StopEmote end
  local columns=vh>=#controls*44+4 and 1 or math.ceil(#controls/math.max(1,math.floor(vh/48)))
  local rail=columns*48;rect(U.Viewport,0,0,aw-rail,vh)
  local footerY=top+vh+10;local footer=math.max(minFooter,h-footerY-4)
  rect(U.EditorFooter,6,footerY,aw,footer);U.EditorFooter.CanvasSize=UDim2.fromOffset(0,footer);U.EditorFooter.ScrollingEnabled=false
  rect(U.Actions,0,0,aw,actionH)
  U.ActionGrid.SortOrder=Enum.SortOrder.LayoutOrder;U.ActionGrid.FillDirectionMaxCells=cols;U.ActionGrid.CellPadding=UDim2.fromOffset(4,4);U.ActionGrid.CellSize=UDim2.fromOffset(math.floor((aw-4*(cols-1))/cols),rowH)
  U.BodyToggle.Text="";U.BodyToggle.LayoutOrder=5
  U.Total.Visible=false;rect(U.ItemStrip,0,actionH+6,aw,footer-actionH-6)
  rect(U.PreviewInfo,6,4,44,20);U.PreviewInfo.TextSize=12
  U.HidePreview.Visible=false;U.PreviewToggle.Visible=false
  local rows=math.ceil(#controls/columns);local gap=rows>1 and math.clamp(math.floor((vh-rows*44-4)/(rows-1)),0,4)or 0
  local y=math.max(2,(vh-rows*44-(rows-1)*gap)/2)
  for i,o in ipairs(controls)do
   rect(o,aw-rail+4+((i-1)%columns)*48,y+math.floor((i-1)/columns)*(44+gap),44,44);o.TextSize=20
  end
  rect(U.PreviewError,6,math.max(4,vh*.22),aw-rail-12,math.max(28,math.min(64,vh-90)))
  rect(U.PreviewRetry,8,vh-48,aw-rail-16,44)
  local mw=U.Main.AbsoluteSize.X;local rp=U.Main.Position;local rh=U.Root.AbsoluteSize.Y;local _,_,_,ib=insets()
  local bw=math.min(mw-12,390);local bh=math.min(448,rh-ib-math.max(top,rp.Y.Offset)-12)
  rect(U.BodyWindow,rp.X.Offset+mw-bw-6,math.max(top+4,rh-ib-bh-6),bw,bh)
  for i,btn in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook,U.BodyToggle})do btn.LayoutOrder=i;btn.TextSize=w<300 and 12 or 14;btn.TextWrapped=false end
  local ap=U.Apply:FindFirstChildOfClass("UIPadding");if ap then ap.PaddingLeft=UDim.new(0,2);ap.PaddingRight=UDim.new(0,2)end
 end
 local busy=false
 local function layout()
  if busy then return end;busy=true
  local w,h=U.Root.AbsoluteSize.X,U.Root.AbsoluteSize.Y
  if w<1 or h<1 then busy=false;return end
  local il,it,ir,ib=insets();local usable=w-il-ir
  local portrait=w<h and usable<700;local band=math.min(h-240-ib,math.max(it+240,(h-ib)*.48))
  U.Left.Visible=not wide
  if wide then rect(U.Main,il,0,usable,h-ib)
  elseif portrait then
   rect(U.Left,il,0,usable,band);rect(U.Main,il,band,usable,h-band-ib)
  else
   local lw=math.floor(math.clamp(usable*.32,math.min(248,usable*.45),380))
   rect(U.Left,il,0,lw,h-ib);rect(U.Main,il+lw+2,0,usable-lw-2,h-ib)
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
  U.DetailCreator.Visible=false;U.Favorite.Visible=false
  rect(U.DescriptionScroll,8,82,dw-16,math.max(20,dh-140));U.DescriptionScroll.ScrollingEnabled=false
  U.DetailDescription.TextSize=12;U.DetailDescription.AutomaticSize=Enum.AutomaticSize.None;U.DetailDescription.Size=UDim2.fromScale(1,1);U.DetailDescription.TextTruncate=Enum.TextTruncate.AtEnd
  rect(U.Try,8,dh-52,(dw-22)/2,44);rect(U.Buy,dw/2+3,dh-52,(dw-22)/2,44)
  -- Other utilities keep their dedicated page, with no empty shell behind them.
  local wideY=it+50
  if wide then wideY=heading(U.PageTitle,U.Close,0,it,0,mw)end
  for _,page in ipairs({U.LooksArea,U.CommunityArea,U.StoresArea})do rect(page,0,wideY,mw,mh-wideY)end

  local cw=usable;local cartY=heading(U.CartTitle,U.CartClose,il,it,ir,w);local narrow=cw<600
  U.CartTitle.TextSize=22
  rect(U.CartCount,il+12,cartY,cw-24,narrow and 38 or 24)
  rect(U.CartSelected,il+12,cartY+(narrow and 40 or 26),(cw-30)/2,44);rect(U.CartOutfit,il+18+(cw-30)/2,cartY+(narrow and 40 or 26),(cw-30)/2,44)
  local cy=cartY+(narrow and 92 or 78);local footer=narrow and 108 or 64
  rect(U.CartList,il+12,cy,cw-24,h-ib-cy-footer)
  rect(U.CartTotal,il+12,h-ib-(narrow and 100 or 54),narrow and cw-24 or cw*.42,32);U.CartTotal.TextSize=20
  rect(U.CartClear,narrow and il+12 or w-ir-288,h-ib-52,88,44)
  rect(U.CartBuySelected,narrow and il+106 or w-ir-192,h-ib-52,narrow and cw-118 or 180,44)
  local loaderY=heading(U.LoaderTitle,U.LoaderClose,il,it,ir,w);local viewY=loaderY+52
  rect(U.LoaderQuery,il+12,loaderY,cw-182,40)
  rect(U.LoaderMine,w-ir-164,loaderY,64,40);rect(U.LoaderSearch,w-ir-94,loaderY,82,40)
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
  for _,dialog in ipairs({U.SaveBox,U.PublishBox,U.RigBox})do dialog.Size=UDim2.fromOffset(math.min(384,cw-24),dialog.Size.Y.Offset)end
  U.Toast.Size=UDim2.fromOffset(math.min(520,cw-24),48)
  U.Toast.Position=UDim2.new(.5,(il-ir)/2,1,-ib-8)
  U.LayoutEditor();U.LayoutLooks();U.LayoutLookDetail();busy=false
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
