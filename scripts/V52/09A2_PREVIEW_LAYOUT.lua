-- 09A2_PREVIEW_LAYOUT | ModuleScript | ReplicatedStorage
-- V48: looks maiores e detalhe opaco com itens em grade e controles 360.
local M={}
local function rect(o,x,y,w,h)o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))end
function M.Init(U)
 function U.LayoutLooks()
  local w,h=U.LooksArea.AbsoluteSize.X,U.LooksArea.AbsoluteSize.Y
  local sp,gs=U.SavedPreviewPanel,U.SavedGridPanel;local portrait=w<560 and h>w
  U.SavedPreviewToggle.Visible=false;U.SavedPreviewClose.Visible=false;sp.Visible=true;sp.ZIndex=1
  local pw=portrait and w or math.floor(w*.40);local ph=portrait and math.floor(h*.45)or h
  rect(sp,4,0,pw-8,ph);rect(gs,portrait and 0 or pw,portrait and ph+6 or 0,portrait and w or w-pw,portrait and h-ph-6 or h)
  local gw,gh=gs.AbsoluteSize.X,gs.AbsoluteSize.Y
  U.SavedCount.Position=UDim2.new(1,-8,0,4);U.SavedCount.Size=UDim2.fromOffset(76,28)
  rect(U.OutfitSaveNew,6,34,104,44);rect(U.LookSearch,116,34,gw-122,44)
  rect(U.SavedGrid,4,84,gw-8,math.max(1,gh-88))
  local sw,sh=sp.AbsoluteSize.X,sp.AbsoluteSize.Y;local compact=portrait or sh<390
  local footer=compact and 100 or 146;local vh=math.max(40,sh-footer-38)
  rect(U.SavedPreview,4,2,sw-56,vh);rect(U.OutfitSelected,4,vh+8,sw-8,26);U.OutfitSelected.TextSize=13
  rect(U.SavedItems,4,vh+36,sw-8,compact and 56 or 72)
  local y=vh+36+(compact and 62 or 78);rect(U.OutfitActions,4,y,sw-8,math.max(1,sh-y-4))
  U.OutfitActions.CanvasSize=UDim2.fromOffset(0,144);U.OutfitActions.ScrollBarThickness=3
  for i,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish})do
   rect(b,(i-1)%2*(sw-4)/2,math.floor((i-1)/2)*48,(sw-16)/2,44);b.TextSize=11
  end
  for i,b in ipairs({U.SavedLeft,U.SavedRight,U.SavedZoomIn,U.SavedZoomOut})do
   b.Parent=sp;rect(b,sw-48,2+(i-1)*48,44,44);b.TextSize=20
  end
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
  U.LookCreator.Visible=false;rect(U.LookMeta,x,y,rw,22)
  U.LookCodeBox.Visible=U.LookCodeBox.Text~="SEM CÓDIGO";U.LookCopy.Visible=U.LookCodeBox.Visible
  local metaEnd=y+28
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
