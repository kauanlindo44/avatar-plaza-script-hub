-- 09A2_PREVIEW_LAYOUT | ModuleScript | ReplicatedStorage | V56 (SUBSTITUIR)
-- Prévia ampla, prateleira compacta e ações visíveis dentro da área segura.
local M={}
local function rect(o,x,y,w,h)o.AnchorPoint=Vector2.zero;o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))end
function M.Init(U)
 function U.LayoutLooks()
  if not U.SavedStage then return end
  local w,h=U.LooksArea.AbsoluteSize.X,U.LooksArea.AbsoluteSize.Y
  local sp,gs=U.SavedPreviewPanel,U.SavedGridPanel;local portrait=w<560 and h>w
  U.SavedPreviewToggle.Visible=false;U.SavedPreviewClose.Visible=false;sp.Visible=true;sp.ZIndex=1
  local pw=portrait and w or math.floor(w*.42);local ph=portrait and math.min(math.max(190,math.floor(h*.44)),math.max(190,h-286))or h
  rect(sp,4,0,pw-8,ph);rect(gs,portrait and 4 or pw,portrait and ph+6 or 0,portrait and w-8 or w-pw-4,portrait and h-ph-6 or h)
  local gw,gh=gs.AbsoluteSize.X,gs.AbsoluteSize.Y
  local headerY=gh<340 and 4 or 34;U.SavedShelfTitle.Visible=gh>=340;U.SavedCount.Visible=gh>=340
  rect(U.SavedShelfTitle,8,4,gw-98,26);U.SavedCount.AnchorPoint=Vector2.zero;rect(U.SavedCount,gw-88,4,80,26)
  rect(U.OutfitSaveNew,6,headerY,108,44);rect(U.LookSearch,120,headerY,gw-126,44)
  U.OutfitActions.Parent=gs
  local ac=gw>=440 and 6 or gw>=270 and 3 or 2;local ah=math.ceil(6/ac)*48-4
  rect(U.OutfitActions,6,gh-ah-6,gw-12,ah);U.OutfitActions.CanvasSize=UDim2.fromOffset(0,ah);U.OutfitActions.ScrollingEnabled=false
  rect(U.SavedGrid,6,headerY+50,gw-12,gh-ah-headerY-62)
  for i,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish})do
   local bw=(gw-12-4*(ac-1))/ac;rect(b,(i-1)%ac*(bw+4),math.floor((i-1)/ac)*48,bw,44);b.TextSize=bw<120 and 11 or 13;b.TextWrapped=false
   if b==U.OutfitUpdate then b.Text=bw<108 and'Salvar' or'Salvar alterações'end
  end
  local sw,sh=sp.AbsoluteSize.X,sp.AbsoluteSize.Y;local vh=sh-104;local rail=48
  rect(U.SavedStage,4,2,sw-rail-8,vh);rect(U.SavedPreview,0,0,sw-rail-8,vh)
  rect(U.OutfitSelected,6,vh+6,sw-12,24);U.OutfitSelected.TextSize=13;U.OutfitSelected.TextWrapped=false;U.OutfitSelected.TextTruncate=Enum.TextTruncate.AtEnd
  rect(U.SavedItems,4,vh+34,sw-8,66)
  local columns=vh>=192 and 1 or 2;local total=math.ceil(4/columns)*48-4;local y=math.max(0,(vh-total)/2)
  if columns==2 then rail=96;rect(U.SavedStage,4,2,sw-rail-8,vh);rect(U.SavedPreview,0,0,sw-rail-8,vh)end
  for i,b in ipairs({U.SavedLeft,U.SavedRight,U.SavedZoomIn,U.SavedZoomOut})do
   b.Parent=sp;rect(b,sw-rail+((i-1)%columns)*48,y+math.floor((i-1)/columns)*48,44,44);b.TextSize=20
  end
 end
 function U.LayoutLookDetail()
  if not U.LookStage then return end
  local il,it,ir,ib,w,h=U.SafeBounds.Read();rect(U.LookDetail,0,0,w,h)
  local aw=w-il-ir;local top=it+58;local short=h<540;local portrait=aw<620 and h>aw
  rect(U.LookName,il+8,it+4,aw-72,44);U.LookName.TextSize=20;rect(U.LookClose,w-ir-56,it+4,48,48);U.LookClose.ZIndex=120
  local bar=U.SafeBounds.Topbar()
  if aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then
   rect(U.LookName,bar.X+8,bar.Y+4,bar.Right-bar.X-72,44);rect(U.LookClose,bar.Right-56,bar.Y+4,48,48);top=it+4
  end
  local previewW=portrait and aw-12 or math.floor(aw*.43)
  local previewH=portrait and math.max(140,math.floor((h-top-ib)*.43)-48)or h-top-ib-54
  rect(U.LookStage,il+6,top,previewW,previewH);rect(U.LookPreview,0,0,previewW,previewH)
  rect(U.LookRotation,il+6,top+previewH+4,previewW,44)
  local x=portrait and il+6 or il+previewW+12;local rw=portrait and aw-12 or aw-previewW-18
  local y=portrait and top+previewH+54 or top
  U.LookCreator.Visible=false;rect(U.LookMeta,x,y,rw,20)
  U.LookCodeBox.Visible=U.LookCodeBox.Text~='SEM CÓDIGO';U.LookCopy.Visible=U.LookCodeBox.Visible
  local metaEnd=y+24
  if U.LookCodeBox.Visible then rect(U.LookCodeBox,x,metaEnd,rw-98,44);rect(U.LookCopy,x+rw-90,metaEnd,90,44);metaEnd=metaEnd+48 end
  rect(U.LookTotal,x,metaEnd,rw,24);rect(U.LookItems,x,metaEnd+28,rw,h-ib-metaEnd-86)
  for i,b in ipairs({U.LookTry,U.LookBuy,U.LookFav})do rect(b,x+(i-1)*(rw+6)/3,h-ib-54,(rw-12)/3,44);b.TextSize=13 end
  if U.LookItemLayout then
   local cols=math.max(1,math.floor(rw/(short and 108 or 128)))
   U.LookItemLayout.FillDirectionMaxCells=cols;U.LookItemLayout.CellSize=UDim2.fromOffset(math.floor((rw-6*(cols-1)-4)/cols),short and 94 or 126)
  end
 end
end
return M
