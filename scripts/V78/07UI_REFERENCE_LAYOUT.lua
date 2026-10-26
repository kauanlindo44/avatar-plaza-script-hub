-- 07UI_REFERENCE_LAYOUT | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
-- Medidas da referência em paisagem; controles preservam 44 px em telas menores.
local Rep=game:GetService('ReplicatedStorage')
local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local M={Version='V78'}
function M.ShopRects(il,it,ir,ib,w,h,wide)
 local aw,ah=w-il-ir,h-it-ib;local portrait=aw<560
 local y=it+math.min(24,ah*.055);local height=math.max(100,ah-(y-it)-16)
 if portrait then
  local ph=math.min(196,height*.39)
  return {il+8,y,aw-16,ph},{il+8,y+(wide and 0 or ph+6),aw-16,height-(wide and 0 or ph+6)},portrait
 end
 local lw=math.clamp(aw*.255,196,360)
 local left={il+8,y,lw,height}
 local main=wide and {il+8,y,aw-16,height}or {il+lw+20,y,aw-lw-28,height}
 return left,main,portrait
end
function M.Shop(U,wide)
 local il,it,ir,ib,w,h=U.SafeBounds.Read()
 local floating=U.ActivePage=="Stores"and w-il-ir<560
 local left,main,portrait=M.ShopRects(il,it,ir,ib,w,h,wide or floating)
 if not floating then B.Rect(U.Left,table.unpack(left))end;B.Rect(U.Main,table.unpack(main))
 local mw,mh=main[3],main[4];U.PageTitle.Visible=wide
 B.Rect(U.PageTitle,12,0,mw-82,48);B.Rect(U.Close,mw-56,0,48,48)
 local queryW=math.max(44,mw-294)
 B.Rect(U.Query,6,0,queryW,48);B.Rect(U.SearchGo,queryW+12,0,48,48)
 B.Rect(U.Filter,mw-222,0,72,48);B.Rect(U.Sort,mw-144,0,82,48)
 U.Sort.TextWrapped=false;U.Sort.TextTruncate=Enum.TextTruncate.AtEnd;U.Filter.TextWrapped=false
 B.Rect(U.Groups.Parent,6,54,mw-12,48)
 U.Groups.Size=UDim2.new(1,-164,1,0)
 U.SubToggle.Position=UDim2.new(1,-162,0,0);U.SubToggle.AnchorPoint=Vector2.zero;U.SubToggle.Size=UDim2.fromOffset(104,48)
 B.Rect(U.More,mw-56,54,48,48)
 B.Rect(U.Grid,6,108,mw-12,mh-134);B.Rect(U.Status,6,mh-22,mw-12,20)
 for _,page in ipairs({U.LooksArea,U.CommunityArea,U.StoresArea})do B.Rect(page,0,54,mw,mh-54)end
 U.StoresArea:SetAttribute('TopRightReserved',0)
 local compact=mw<540
 U.Filter.Parent=compact and U.SubsPopup or U.Main;U.Sort.Parent=U.Filter.Parent
 if compact then
  B.Rect(U.Query,6,0,mw-120,48);B.Rect(U.SearchGo,mw-108,0,48,48)
  B.Rect(U.Filter,7,4,(mw-32)/2,48);B.Rect(U.Sort,19+(mw-32)/2,4,(mw-32)/2,48)
  B.Rect(U.SubsPopup,6,108,mw-12,math.max(108,math.min(240,mh-114)))
  B.Rect(U.Subs,7,60,mw-26,math.max(48,U.SubsPopup.AbsoluteSize.Y-68))
 else
  B.Rect(U.Subs,7,7,U.SubsPopup.AbsoluteSize.X-14,U.SubsPopup.AbsoluteSize.Y-14)
 end
end
function M.Editor(U)
 local w,h=U.Left.AbsoluteSize.X,U.Left.AbsoluteSize.Y;local aw=w-12
 local cols=math.clamp(math.floor((aw+4)/52),1,5);local actionsH=math.ceil(5/cols)*52-4
 local vh=math.max(44,h-actionsH-64)
 B.Rect(U.PreviewShell,6,0,aw,vh);B.Rect(U.Viewport,0,0,aw,vh)
 B.Rect(U.EditorFooter,6,vh+4,aw,actionsH+54);U.EditorFooter.CanvasSize=UDim2.fromOffset(0,actionsH+54)
 B.Rect(U.Actions,0,0,aw,actionsH);U.ActionGrid.FillDirectionMaxCells=cols
 U.ActionGrid.CellSize=UDim2.fromOffset(math.max(48,math.floor((aw-4*(cols-1))/cols)),48)
 U.ActionGrid.CellPadding=UDim2.fromOffset(4,4)
 B.Rect(U.ItemStrip,0,actionsH+4,aw,48)
 B.Rect(U.PreviewError,6,math.max(4,vh*.22),aw-12,math.min(64,vh-48))
 B.Rect(U.PreviewRetry,6,vh-50,aw-12,48)
 if U.ToolsButton then B.Rect(U.ToolsButton,aw-50,2,48,48)end
 if U.StopEmote.Visible then B.Rect(U.StopEmote,aw-50,54,48,48)end
end
function M.Utilities(U)
 local il,it,ir,ib,w,h=U.SafeBounds.Read();local aw,ah=w-il-ir,h-it-ib
 local pw,ph=math.min(480,aw-16),math.min(340,ah-16)
 U.Loader.BackgroundColor3=Color3.fromRGB(64,94,112);U.Loader.BackgroundTransparency=.6
 B.Rect(U.LoaderCard,il+(aw-pw)/2,it+(ah-ph)/2,pw,ph)
 B.Rect(U.LoaderTitle,12,2,pw-76,44);B.Rect(U.LoaderClose,pw-54,0,48,48)
 B.Rect(U.LoaderQuery,12,54,pw-182,44);B.Rect(U.LoaderMine,pw-164,54,64,44);B.Rect(U.LoaderSearch,pw-94,54,82,44)
 local thumb=math.max(64,math.min(ph-166,pw*.35))
 B.Rect(U.LoaderThumb,12,106,thumb,thumb)
 B.Rect(U.LoaderName,thumb+24,106,pw-thumb-36,44);U.LoaderName.TextSize=14
 B.Rect(U.LoaderStatus,thumb+24,152,pw-thumb-36,math.max(24,ph-210));U.LoaderStatus.TextSize=12
 B.Rect(U.LoaderUseR6,12,ph-50,(pw-30)/2,44);B.Rect(U.LoaderUse,18+(pw-30)/2,ph-50,(pw-30)/2,44)
end
return M
