-- 09A1_SHOP_LAYOUT | ModuleScript | ReplicatedStorage
-- V41: conteudo usa o viewport inteiro, com controles fora das barras nativas.
local M={}
local Gui=game:GetService("GuiService")
function M.Init(U)
 local wide=true
 local function rect(o,x,y,w,h)
  o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
 end
 local function insets()
  local p,s=U.SafeGuide.AbsolutePosition,U.SafeGuide.AbsoluteSize;local v=U.Root.AbsoluteSize
  return p.X,p.Y,math.max(0,v.X-p.X-s.X),math.max(0,v.Y-p.Y-s.Y)
 end
 local function freeTop()
  local ok,r=pcall(function()return Gui.TopbarInset end)
  return ok and r and r.Min and r.Max and r.Max.Y-r.Min.Y>=48 and r or nil
 end
 local function heading(title,close,il,it,ir,w)
  local r=freeTop();local y=it+6;local x=il+12;local endX=w-ir
  local inBar=r and r.Max.X-r.Min.X>=220
  if inBar then x=r.Min.X+6;y=r.Min.Y+4;endX=r.Max.X end
  rect(title,x,y,endX-x-60,40);rect(close,endX-52,y,40,40)
  return inBar and it+6 or y+46
 end
 function U.LayoutEditor()
  local w,h=U.Left.AbsoluteSize.X,U.Left.AbsoluteSize.Y;local _,top=insets();local bottom=0
  local portrait=U.Root.AbsoluteSize.X<640;local short=not portrait and h<520
  local side=portrait or short;local margin=6;local vh,vw,ax,ay,aw,ah
  if side then
   vw=math.floor(w*(portrait and .44 or .54))-8
   vh=h-top-bottom-12
   rect(U.Viewport,6,top+6,vw,vh)
   ax=vw+12;ay=top+6;aw=w-ax-6;ah=short and 156 or 84
   rect(U.Actions,ax,ay,aw,ah)
   U.ActionGrid.FillDirectionMaxCells=short and 1 or 2
   U.ActionGrid.CellPadding=UDim2.fromOffset(4,4)
   U.ActionGrid.CellSize=short and UDim2.new(1,0,.25,-3)or UDim2.new(.5,-2,.5,-2)
   rect(U.BodyToggle,ax,ay+ah+4,aw,40)
   rect(U.Total,ax,ay+ah+48,aw,16)
   rect(U.ItemStrip,ax,ay+ah+68,aw,h-bottom-(ay+ah+74))
  else
   local ahRows=w>=460 and 44 or 84;local footer=ahRows+40+76+24
   vh=h-footer-top-12;vw=w-12
   rect(U.Viewport,6,top+6,vw,vh)
   ax=6;ay=top+vh+12;aw=w-12;ah=ahRows
   rect(U.Actions,ax,ay,aw,ah)
   U.ActionGrid.FillDirectionMaxCells=w>=460 and 4 or 2
   U.ActionGrid.CellPadding=UDim2.fromOffset(4,4)
   U.ActionGrid.CellSize=w>=460 and UDim2.new(.25,-3,1,0)or UDim2.new(.5,-2,.5,-2)
   rect(U.BodyToggle,6,ay+ah+4,w-12,40)
   rect(U.Total,6,ay+ah+48,w-12,16)
   rect(U.ItemStrip,6,ay+ah+68,w-12,math.max(44,h-bottom-ay-ah-74))
  end
  U.PreviewInfo.AnchorPoint=Vector2.zero
  rect(U.PreviewInfo,6,4,math.max(20,vw-60),20)
  U.HidePreview.Visible=false;U.PreviewToggle.Visible=false
  U.ZoomIn.Size=UDim2.fromOffset(32,32);U.ZoomOut.Size=UDim2.fromOffset(32,32)
  U.ZoomIn.Position=UDim2.new(1,-4,0,4)
  U.ZoomOut.Position=UDim2.new(1,-4,0,40)
  U.ViewLeft.Size=UDim2.fromOffset(32,40);U.ViewRight.Size=UDim2.fromOffset(32,40)
  U.BodyToggle.Text=aw<170 and "CONFIGURAR\nCORPO"or"CONFIGURAR CORPO"
  local mw=U.Main.AbsoluteSize.X;local rp=U.Main.Position;local rh=U.Root.AbsoluteSize.Y;local _,_,_,ib=insets()
  local bw=math.min(mw-12,390);local bh=math.min(390,rh-ib-math.max(top,rp.Y.Offset)-12)
  rect(U.BodyWindow,rp.X.Offset+mw-bw-6,rh-ib-bh-6,bw,bh)
  U.StopEmote.AnchorPoint=Vector2.new(.5,1);U.StopEmote.Position=UDim2.new(.5,0,1,-4);U.StopEmote.Size=UDim2.fromOffset(math.min(124,vw-8),32)
  for _,b in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook})do b.TextSize=14;b.TextWrapped=false end
 end
 local busy=false
 local function layout()
  if busy then return end;busy=true
  local w,h=U.Root.AbsoluteSize.X,U.Root.AbsoluteSize.Y
  if w<1 or h<1 then busy=false;return end
  local il,it,ir,ib=insets();local usable=w-il-ir
  local portrait=w<640;local band=math.max(it+226,math.min(h*.43,it+246))
  U.Left.Visible=not wide
  if wide then rect(U.Main,il,0,usable,h-ib)
  elseif portrait then
   rect(U.Left,il,0,usable,band);rect(U.Main,il,band,usable,h-band-ib)
  else
   local lw=math.floor(usable*(h<520 and .38 or .31))
   rect(U.Left,il,0,lw,h-ib);rect(U.Main,il+lw+2,0,usable-lw-2,h-ib)
  end
  local mw,mh=U.Main.AbsoluteSize.X,U.Main.AbsoluteSize.Y
  U.PageTitle.Visible=wide;rect(U.PageTitle,12,it+6,mw-72,40)
  local header=portrait and not wide and 6 or it+6
  local bar=freeTop();local mx=U.Main.Position.X.Offset
  if not wide and not portrait and bar and mx+6>=bar.Min.X and mx+mw-6<=bar.Max.X then header=bar.Min.Y+4 end
  local compact=mw<580;local fixed=compact and 210 or 280
  rect(U.Query,6,header,mw-fixed,40)
  rect(U.SearchGo,mw-fixed+10,header,40,40)
  rect(U.Filter,mw-(compact and 156 or 226),header,compact and 66 or 88,40)
  rect(U.Sort,mw-(compact and 86 or 134),header,compact and 80 or 126,40)
  rect(U.Close,mw-46,header+46,40,40)
  local row=U.Groups.Parent
  rect(row,6,header+46,mw-58,36)
  local subw=math.min(140,math.max(88,mw*.25))
  U.SubToggle.AnchorPoint=Vector2.new(1,0);U.SubToggle.Position=UDim2.new(1,0,0,0);U.SubToggle.Size=UDim2.fromOffset(subw,34)
  U.Groups.Size=UDim2.new(1,-subw-6,1,0)
  local gy=header+88
  rect(U.Grid,6,gy,mw-12,mh-gy-28)
  rect(U.Status,6,mh-24,mw-116,22);U.Status.TextSize=13
  rect(U.More,mw-106,mh-26,100,24)
  rect(U.SubsPopup,6,gy,mw-12,math.min(174,mh-gy-6))
  rect(U.FilterPanel,math.max(6,mw-348),header+46,math.min(342,mw-12),math.min(338,mh-header-52))
  rect(U.Detail,math.max(6,mw-306),header,math.min(300,mw-12),mh-header-6)
  U.Detail.CanvasSize=UDim2.fromOffset(0,404)
  -- Other utilities keep their dedicated page, with no empty shell behind them.
  for _,page in ipairs({U.LooksArea,U.CommunityArea,U.StoresArea})do rect(page,0,it+52,mw,mh-it-52)end
  U.Close.Position=UDim2.fromOffset(mw-46,wide and it+6 or header+46)
  local cw=usable;local cartY=heading(U.CartTitle,U.CartClose,il,it,ir,w);local narrow=cw<600
  U.CartTitle.TextSize=22
  rect(U.CartCount,il+12,cartY,cw-24,narrow and 38 or 24)
  local cy=cartY+(narrow and 44 or 32);local footer=narrow and 108 or 64
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
  local plusY=heading(U.PlusTitle,U.PlusClose,il,it,ir,w)
  rect(U.PlusContent,il+6,plusY+6,cw-12,h-ib-plusY-134)
  rect(U.PlusStatus,il+16,h-ib-122,cw-32,36)
  rect(U.PlusPrice,il+16,h-ib-76,narrow and cw*.5-26 or cw*.60,52)
  rect(U.PlusBuy,narrow and il+cw*.5 or il+cw*.65,h-ib-72,narrow and cw*.5-16 or cw*.35-16,44)
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
 task.defer(layout)
end
return M
