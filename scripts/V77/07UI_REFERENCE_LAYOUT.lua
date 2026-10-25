-- 07UI_REFERENCE_LAYOUT | ModuleScript | ReplicatedStorage | V77 (CRIAR)
-- Medidas da referência em paisagem; controles preservam 44 px em telas menores.
local Rep=game:GetService('ReplicatedStorage')
local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local M={Version='V77'}
function M.ShopRects(il,it,ir,ib,w,h,wide)
 local aw,ah=w-il-ir,h-it-ib;local portrait=aw<560
 local y=it+math.min(24,ah*.055);local height=math.max(100,ah-(y-it)-16)
 if portrait then
  local ph=math.min(196,height*.39)
  return {il+8,y,aw-16,ph},{il+8,y+(wide and 0 or ph+6),aw-16,height-(wide and 0 or ph+6)},portrait
 end
 local left={il+aw*.025,y,aw*.275,height}
 local main=wide and {il+aw*.035,y,aw*.93,height}or {il+aw*.325,y,aw*.65,height}
 return left,main,portrait
end
function M.Shop(U,wide)
 local il,it,ir,ib,w,h=U.SafeBounds.Read()
 local floating=U.ActivePage=="Stores"and w-il-ir<560
 local left,main,portrait=M.ShopRects(il,it,ir,ib,w,h,wide or floating)
 if not floating then B.Rect(U.Left,table.unpack(left))end;B.Rect(U.Main,table.unpack(main))
 local mw,mh=main[3],main[4];U.PageTitle.Visible=wide
 B.Rect(U.PageTitle,12,0,mw-76,44);B.Rect(U.Close,mw-50,0,44,44)
 local queryW=math.max(44,mw-244)
 B.Rect(U.Query,6,0,queryW,44);B.Rect(U.SearchGo,queryW+10,0,44,44)
 B.Rect(U.Filter,mw-186,0,58,44);B.Rect(U.Sort,mw-124,0,66,44)
 B.Rect(U.Groups.Parent,6,48,mw-12,44)
 U.Groups.Size=UDim2.new(1,-144,1,0)
 U.SubToggle.Position=UDim2.new(1,-142,0,0);U.SubToggle.AnchorPoint=Vector2.zero;U.SubToggle.Size=UDim2.fromOffset(92,44)
 B.Rect(U.More,mw-50,48,44,44)
 B.Rect(U.Grid,6,96,mw-12,mh-118);B.Rect(U.Status,6,mh-20,mw-12,18)
 for _,page in ipairs({U.LooksArea,U.CommunityArea,U.StoresArea})do B.Rect(page,0,48,mw,mh-48)end
 U.StoresArea:SetAttribute('TopRightReserved',0)
 if portrait then
  -- A segunda linha evita sobrepor a busca e o botão de fechar no retrato.
  B.Rect(U.Query,6,0,mw-108,44);B.Rect(U.SearchGo,mw-98,0,44,44)
  B.Rect(U.Filter,6,48,58,44);B.Rect(U.Sort,68,48,66,44)
  B.Rect(U.Groups.Parent,6,96,mw-12,44);B.Rect(U.Grid,6,144,mw-12,mh-166)
 end
end
function M.Editor(U)
 local w,h=U.Left.AbsoluteSize.X,U.Left.AbsoluteSize.Y;local aw=w-12
 local cols=math.clamp(math.floor((aw+4)/48),1,5);local actionsH=math.ceil(5/cols)*48-4
 local vh=math.max(44,h-actionsH-58)
 B.Rect(U.PreviewShell,6,0,aw,vh);B.Rect(U.Viewport,0,0,aw,vh)
 B.Rect(U.EditorFooter,6,vh+4,aw,actionsH+54);U.EditorFooter.CanvasSize=UDim2.fromOffset(0,actionsH+54)
 B.Rect(U.Actions,0,0,aw,actionsH);U.ActionGrid.FillDirectionMaxCells=cols
 U.ActionGrid.CellSize=UDim2.fromOffset(math.max(44,math.floor((aw-4*(cols-1))/cols)),44)
 U.ActionGrid.CellPadding=UDim2.fromOffset(4,4)
 B.Rect(U.ItemStrip,0,actionsH+4,aw,48)
 B.Rect(U.PreviewError,6,math.max(4,vh*.22),aw-12,math.min(64,vh-48))
 B.Rect(U.PreviewRetry,6,vh-46,aw-12,44)
 if U.ToolsButton then B.Rect(U.ToolsButton,aw-46,2,44,44)end
 if U.StopEmote.Visible then B.Rect(U.StopEmote,aw-46,50,44,44)end
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
