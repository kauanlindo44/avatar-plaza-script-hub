-- 09A2_PREVIEW_LAYOUT | ModuleScript | ReplicatedStorage
-- V43: looks maiores e detalhe opaco com itens em grade e controles 360.
local M={}
local function rect(o,x,y,w,h)o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))end
function M.Init(U)
 function U.LayoutLooks()
  local w,h=U.LooksArea.AbsoluteSize.X,U.LooksArea.AbsoluteSize.Y
  local overlay=w<900 or h<460;local sp,gs=U.SavedPreviewPanel,U.SavedGridPanel
  U.SavedPreviewClose.Visible=overlay;U.SavedPreviewToggle.Visible=overlay
  if overlay then rect(sp,6,6,w-12,h-12);sp.ZIndex=40;rect(gs,0,0,w,h)
  else
   sp.Visible=true;sp.ZIndex=1;local pw=math.clamp(w*.31,280,420)
   rect(sp,6,6,pw,h-12);rect(gs,pw+16,0,w-pw-16,h)
  end
  local gw=gs.AbsoluteSize.X
  U.SavedCount.Position=UDim2.new(1,-8,0,4);U.SavedCount.Size=UDim2.fromOffset(76,28)
  rect(U.OutfitSaveNew,8,36,108,40);rect(U.LookSearch,122,36,gw-(overlay and 226 or 130),40)
  U.SavedPreviewToggle.Position=UDim2.new(1,-96,0,36);U.SavedPreviewToggle.Size=UDim2.fromOffset(88,40)
  rect(U.SavedGrid,6,82,gw-12,h-88)
  local sw,sh=sp.AbsoluteSize.X,sp.AbsoluteSize.Y
  U.SavedPreviewClose.Position=UDim2.new(1,-54,0,6);U.SavedPreviewClose.Size=UDim2.fromOffset(48,48);U.SavedPreviewClose.ZIndex=60
  local short=sh<400 and sw>420;local x=short and math.floor(sw*.57)or 8;local rw=short and sw-x-8 or sw-16
  local ph=short and sh-16 or math.max(110,sh-238)
  rect(U.SavedPreview,8,8,short and x-16 or sw-16,ph)
  local y=short and 60 or ph+14
  rect(U.OutfitSelected,x,y,rw,26);U.OutfitSelected.TextSize=15
  rect(U.SavedItems,x,y+30,rw,56)
  rect(U.OutfitActions,x,y+92,rw,math.max(86,sh-y-100));U.OutfitActions.CanvasSize=UDim2.fromOffset(0,120)
  for i,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish})do
   local n=i-1;rect(b,n%2*(rw+4)/2,math.floor(n/2)*40,(rw-8)/2,36);b.TextSize=13
  end
  for i,b in ipairs({U.SavedLeft,U.SavedRight})do b.Size=UDim2.fromOffset(40,44)end
  U.SavedZoomIn.Size=UDim2.fromOffset(36,36);U.SavedZoomOut.Size=UDim2.fromOffset(36,36);U.SavedZoomIn.AnchorPoint=Vector2.new(.5,1);U.SavedZoomOut.AnchorPoint=Vector2.new(.5,1);U.SavedZoomIn.Position=UDim2.new(.5,-20,1,-4);U.SavedZoomOut.Position=UDim2.new(.5,20,1,-4)
 end
 function U.LayoutLookDetail()
  local w,h=U.Root.AbsoluteSize.X,U.Root.AbsoluteSize.Y;rect(U.LookDetail,0,0,w,h)
  local p,s=U.SafeGuide.AbsolutePosition,U.SafeGuide.AbsoluteSize
  local il,it=p.X,p.Y;local ir,ib=math.max(0,w-p.X-s.X),math.max(0,h-p.Y-s.Y)
  local aw=w-il-ir;local top=it+60;local short=h<540;local portrait=aw<620 and h>aw
  rect(U.LookName,il+12,it+6,aw-76,44);U.LookName.TextSize=20
  rect(U.LookClose,w-ir-60,it+4,48,48);U.LookClose.ZIndex=120
  local previewW=portrait and aw-24 or math.floor(aw*.45)
  local previewH=portrait and math.max(180,(h-top-ib)*.43)or h-top-ib-62
  rect(U.LookPreview,il+12,top,previewW,previewH)
  rect(U.LookRotation,il+12,top+previewH+4,previewW,40)
  local x=portrait and il+12 or il+previewW+24;local rw=portrait and aw-24 or aw-previewW-36
  local y=portrait and top+previewH+48 or top
  rect(U.LookCreator,x,y,rw,36);rect(U.LookMeta,x,y+38,rw,22)
  U.LookCodeBox.Visible=U.LookCodeBox.Text~="SEM CÓDIGO";U.LookCopy.Visible=U.LookCodeBox.Visible
  local metaEnd=y+66
  if U.LookCodeBox.Visible then rect(U.LookCodeBox,x,metaEnd,rw-92,36);rect(U.LookCopy,x+rw-84,metaEnd,84,36);metaEnd=metaEnd+42 end
  rect(U.LookTotal,x,metaEnd,rw,24)
  rect(U.LookItems,x,metaEnd+30,rw,h-ib-metaEnd-92)
  for i,b in ipairs({U.LookTry,U.LookBuy,U.LookFav})do rect(b,x+(i-1)*(rw+6)/3,h-ib-54,(rw-12)/3,44);b.TextSize=13 end
  if U.LookItemLayout then
   local cols=math.max(1,math.floor(rw/(short and 102 or 128)))
   U.LookItemLayout.FillDirectionMaxCells=cols;U.LookItemLayout.CellSize=UDim2.fromOffset(math.floor((rw-6*(cols-1)-4)/cols),short and 94 or 126)
  end
 end
end
return M
