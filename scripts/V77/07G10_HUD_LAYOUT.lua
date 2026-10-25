-- 07G10_HUD_LAYOUT | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- Posições da referência, com reflow para toque, recortes e controles nativos.
local M={Version='V77'}
function M.Resolve(il,it,ir,ib,w,h,touch,compact,bar)
 local aw,ah=w-il-ir,h-it-ib
 local r={Hidden={},Version='V77',Reference='gameplay 00:02.5'}
 local portrait=w<=h or aw<560
 local cell=ah>=400 and aw>=800 and 48 or 44
 local gap=8;local step=cell+gap
 local side=math.clamp(math.floor(aw*.079),80,104)
 local center=il+aw/2
 local top=it+8
 r.TopCatalog={center-150,top,144,44};r.TopStores={center+6,top,144,44}
 local mid=it+math.max(70,math.floor(ah*.33))
 r.Community={il+12,mid,side,44};r.Loader={il+12,mid+50,side,44}
 r.Looks={w-ir-side-12,mid,side,44};r.Emotes={w-ir-side-12,mid+50,side,44}
 local bx=bar and bar.X or il+250
 local by=bar and bar.Y or math.max(0,it-56)
 local br=bar and bar.Right or w-ir
 local bh=bar and bar.Bottom-by or 52
 local toolbarY=by+math.max(4,(bh-44)/2)
 local toolbarX=math.max(il+8,bx+4)
 r.HideUI={toolbarX,toolbarY,44,44}
 r.AvatarTools={toolbarX+50,toolbarY,44,44}
 r.Undo={toolbarX+100,toolbarY,44,44};r.Redo={toolbarX+150,toolbarY,44,44}
 for i,name in ipairs({'TopMusic','Cart','RemoveItems'})do r[name]={w-ir-12-(4-i)*step,toolbarY,cell,cell}end
 local bottom=h-ib-cell-10
 local lx=il+12;local rx=w-ir-12-3*cell-2*gap
 -- As reservas só se aplicam às telas de toque; o vídeo não revela sua geometria.
 if touch then lx=il+math.min(154,aw*.15);rx=rx-150 end
 for i,name in ipairs({'NewAvatar','CurrentlyWearing','SaveRoblox','RestoreAvatar'})do r[name]={lx+(i-1)*step,bottom,cell,cell}end
 for i,name in ipairs({'Effects','Photo','Cfg'})do r[name]={rx+(i-1)*step,bottom,cell,cell}end
 for _,name in ipairs({'Body','Games','Commands'})do r[name]={il+8,it+8,44,44};r.Hidden[name]=true end
 if portrait then
  r.TopCatalog={center-134,it+8,128,44};r.TopStores={center+6,it+8,128,44}
  local my=it+62
  r.HideUI={il+8,my,44,44};r.AvatarTools={il+58,my,44,44}
  r.Undo={il+108,my,44,44};r.Redo={il+158,my,44,44}
  r.TopMusic={w-ir-152,my,44,44};r.Cart={w-ir-102,my,44,44};r.RemoveItems={w-ir-52,my,44,44}
  for _,name in ipairs({'Undo','Redo','NewAvatar','CurrentlyWearing','SaveRoblox','RestoreAvatar','Effects'})do r.Hidden[name]=true end
  r.Community[2]=it+118;r.Loader[2]=it+168;r.Looks[2]=it+118;r.Emotes[2]=it+168
  r.Photo={w-ir-106,it+220,44,44};r.Cfg={w-ir-56,it+220,44,44}
 elseif ah<330 or touch and aw<850 then
  for _,name in ipairs({'NewAvatar','CurrentlyWearing','SaveRoblox','RestoreAvatar','Effects'})do r.Hidden[name]=true end
  r.Photo={w-ir-114,it+62,44,44};r.Cfg={w-ir-62,it+62,44,44}
  local sy=it+114;r.Community[2]=sy;r.Looks[2]=sy;r.Loader[2]=sy+50;r.Emotes[2]=sy+50
 end
 if touch then
  local limit=h-ib-150
  for _,name in ipairs({'Community','Loader','Looks','Emotes'})do if r[name][2]+r[name][4]>limit then r.Hidden[name]=true end end
 end
 if compact then for _,name in ipairs({'Undo','Redo'})do r.Hidden[name]=true end end
 if toolbarX+194>math.min(br-4,r.TopMusic[1]-8)then r.Hidden.Undo=true;r.Hidden.Redo=true end
 return r
end
function M.Symbol(D,button,kind)
 if kind=='undo'or kind=='redo'then local i=D.Icon(button,'reset',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(25,25),IconColor=button.TextColor3});i.Rotation=kind=='undo'and 180 or 0;return i end
 if kind=='hide'then
  local root=D.New('Frame',{Name='Icon_eye',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,Active=false},button)
  local lid=D.New('Frame',{Position=UDim2.fromOffset(1,6),Size=UDim2.fromOffset(24,14),BackgroundTransparency=1,Active=false},root);D.Round(lid,99);D.Stroke(lid,button.TextColor3,0,2)
  local pupil=D.New('Frame',{Position=UDim2.fromOffset(9,9),Size=UDim2.fromOffset(8,8),BackgroundColor3=button.TextColor3,BorderSizePixel=0,Active=false},root);D.Round(pupil,99);return root
 end
 if kind~='dice'and kind~='sparkles'and kind~='commands'then return D.Icon(button,kind,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(26,26),IconColor=button.TextColor3,ZIndex=button.ZIndex+1})end
 local root=D.New('Frame',{Name='Icon_'..kind,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,Active=false,ZIndex=button.ZIndex+1},button)
 local function box(x,y,w,h,angle)
  local p=D.New('Frame',{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Rotation=angle or 0,BackgroundColor3=button.TextColor3,BorderSizePixel=0,Active=false,ZIndex=root.ZIndex+1},root);D.Round(p,2);return p
 end
 if kind=='dice'then
  local f=box(2,2,22,22,12);f.BackgroundTransparency=1;D.Stroke(f,button.TextColor3,0,2)
  for _,p in ipairs({{7,7},{16,7},{11,11},{7,16},{16,16}})do box(p[1],p[2],3,3)end
 elseif kind=='commands'then
  local f=box(4,1,18,24,-6);f.BackgroundTransparency=1;D.Stroke(f,button.TextColor3,0,2)
  for i=0,2 do box(8,6+i*6,11,2)end
 else
  for _,p in ipairs({{12,2,3,22},{3,11,21,3},{3,2,2,8},{0,5,8,2}})do box(table.unpack(p))end
 end
 return root
end
return M
