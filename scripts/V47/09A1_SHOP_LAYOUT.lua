-- 09A1_SHOP_LAYOUT | ModuleScript | ReplicatedStorage
-- V47: area inferior recuperada, duas linhas legiveis e previa mais ampla.
local M={}
local Gui=game:GetService("GuiService")
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
  local short=h<480;local rowH=40;local stripH=short and 46 or 56
  local aw=w-12;local footer=rowH*2+stripH+12;local vh=math.max(100,h-top-footer-12)
  rect(U.Viewport,6,top+4,aw,vh)
  rect(U.EditorFooter,6,top+vh+10,aw,footer);U.EditorFooter.CanvasSize=UDim2.fromOffset(0,footer)
  rect(U.Actions,0,0,aw-4,rowH)
  U.ActionGrid.FillDirectionMaxCells=4;U.ActionGrid.CellPadding=UDim2.fromOffset(4,4);U.ActionGrid.CellSize=UDim2.new(.25,-3,1,0)
  rect(U.BodyToggle,0,rowH+4,aw-4,rowH);U.BodyToggle.Text="Configurar corpo"
  U.Total.Visible=false;rect(U.ItemStrip,0,rowH*2+8,aw,stripH)
  rect(U.PreviewInfo,6,4,math.max(20,aw-60),20)
  U.HidePreview.Visible=false;U.PreviewToggle.Visible=false
  U.ZoomIn.Size=UDim2.fromOffset(36,36);U.ZoomOut.Size=UDim2.fromOffset(36,36)
  U.ZoomIn.AnchorPoint=Vector2.new(.5,1);U.ZoomOut.AnchorPoint=Vector2.new(.5,1)
  U.ZoomIn.Position=UDim2.new(.5,-20,1,-4);U.ZoomOut.Position=UDim2.new(.5,20,1,-4)
  U.ViewLeft.Size=UDim2.fromOffset(36,44);U.ViewRight.Size=UDim2.fromOffset(36,44)
  local mw=U.Main.AbsoluteSize.X;local rp=U.Main.Position;local rh=U.Root.AbsoluteSize.Y;local _,_,_,ib=insets()
  local bw=math.min(mw-12,390);local bh=math.min(448,rh-ib-math.max(top,rp.Y.Offset)-12)
  rect(U.BodyWindow,rp.X.Offset+mw-bw-6,math.max(top+58,rh-ib-bh-6),bw,bh)
  U.StopEmote.AnchorPoint=Vector2.new(.5,1);U.StopEmote.Position=UDim2.new(.5,0,1,-4);U.StopEmote.Size=UDim2.fromOffset(math.min(124,aw-8),32)
  for _,btn in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook})do btn.TextSize=w<300 and 12 or 14;btn.TextWrapped=true end
 end
 local busy=false
 local function layout()
  if busy then return end;busy=true
  local w,h=U.Root.AbsoluteSize.X,U.Root.AbsoluteSize.Y
  if w<1 or h<1 then busy=false;return end
  local il,it,ir,ib=insets();local usable=w-il-ir
  local portrait=w<640;local band=math.min(h-220,math.max(it+300,h*.45))
  U.Left.Visible=not wide
  if wide then rect(U.Main,il,0,usable,h-ib)
  elseif portrait then
   rect(U.Left,il,0,usable,band);rect(U.Main,il,band,usable,h-band-ib)
  else
   local lw=math.floor(usable*(h<520 and .34 or .34))
   rect(U.Left,il,0,lw,h-ib);rect(U.Main,il+lw+2,0,usable-lw-2,h-ib)
  end
  local mw,mh=U.Main.AbsoluteSize.X,U.Main.AbsoluteSize.Y
  U.PageTitle.Visible=wide;rect(U.PageTitle,12,it+6,mw-72,40)
  local header=portrait and not wide and 4 or it+4
  local compact=mw<580;local fixed=compact and 242 or 304
  rect(U.Query,6,header,mw-fixed,44)
  rect(U.SearchGo,mw-fixed+10,header,40,44)
  rect(U.Filter,mw-(compact and 190 or 252),header,compact and 58 or 84,44)
  rect(U.Sort,mw-(compact and 128 or 164),header,compact and 70 or 106,44)
  rect(U.Close,mw-54,header,48,48);U.Close.ZIndex=80
  local row=U.Groups.Parent
  rect(row,6,header+50,mw-12,34)
  local subw=math.min(140,math.max(88,mw*.25))
  U.SubToggle.AnchorPoint=Vector2.new(1,0);U.SubToggle.Position=UDim2.new(1,0,0,0);U.SubToggle.Size=UDim2.fromOffset(subw,34)
  U.Groups.Size=UDim2.new(1,-subw-6,1,0)
  local gy=header+88
  rect(U.Grid,6,gy,mw-12,mh-gy-44)
  rect(U.Status,6,mh-24,mw-116,22);U.Status.TextSize=12
  rect(U.More,mw-106,mh-42,100,40)
  rect(U.SubsPopup,6,gy,mw-12,math.min(174,mh-gy-6))
  rect(U.FilterPanel,math.max(6,mw-348),header+46,math.min(342,mw-12),math.min(338,mh-header-52))
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
  U.LayoutEditor();U.LayoutLooks();U.LayoutLookDetail();busy=false
 end
 function U.SetWide(v)wide=v==true;U.BodyWindow.Visible=false;layout()end
 function U.ShowPreview()wide=false;layout()end
 function U.AnimateMode()end
 U.Layout=layout
 for _,o in ipairs({U.Root,U.Main,U.Left,U.SafeGuide,U.CartPanel,U.Loader,U.PlusPanel})do o:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)end
 U.SafeGuide:GetPropertyChangedSignal("AbsolutePosition"):Connect(layout)
 pcall(function()local c=Gui:GetPropertyChangedSignal("TopbarInset"):Connect(layout);U.Gui.Destroying:Connect(function()c:Disconnect()end)end)
 U.LookDetail:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.LayoutLookDetail)
 U.SavedPreviewPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.LayoutLooks)
 if U.SafeBounds then U.SafeBounds.Watch(layout)else task.defer(layout)end
end
return M
