-- 07G10_HUD_LAYOUT | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
-- Controles maiores: 56 px no PC, 52 no celular e 48 em paisagem baixa.
local M={Version='V78'}
function M.Resolve(il,it,ir,ib,w,h,touch,compact,bar)
 local aw,ah=w-il-ir,h-it-ib;local portrait=aw<600 or w<=h
 local cell=ah<340 and 48 or touch and 52 or 56;local gap=8;local step=cell+gap
 local r={Hidden={},Version='V78'};local center=il+aw/2;local top=it+8
 local tab=math.min(180,(aw-28)/2)
 r.TopCatalog={center-tab-6,top,tab,cell};r.TopStores={center+6,top,tab,cell}
 local toolbarX=math.max(il+8,bar and bar.X+4 or il+250)
 local toolbarY=bar and bar.Y+math.max(0,(bar.Bottom-bar.Y-cell)/2)or math.max(0,it-cell-4)
 r.HideUI={toolbarX,toolbarY,cell,cell};r.AvatarTools={toolbarX+step,toolbarY,cell,cell}
 r.Undo={toolbarX+2*step,toolbarY,cell,cell};r.Redo={toolbarX+3*step,toolbarY,cell,cell}
 for i,name in ipairs({'TopMusic','Cart','RemoveItems'})do r[name]={w-ir-8-(4-i)*step+gap,toolbarY,cell,cell}end
 local side=math.clamp(math.floor(aw*.11),108,152);local mid=it+math.max(cell+20,math.floor(ah*.32))
 for i,name in ipairs({'Community','Loader','Assistant'})do r[name]={il+8,mid+(i-1)*(cell+6),side,cell}end
 for i,name in ipairs({'Looks','Emotes','Games'})do r[name]={w-ir-side-8,mid+(i-1)*(cell+6),side,cell}end
 local bottom=h-ib-cell-10;local lx=il+8;local rx=w-ir-8-3*cell-2*gap
 for i,name in ipairs({'NewAvatar','CurrentlyWearing','SaveRoblox','RestoreAvatar'})do r[name]={lx+(i-1)*step,bottom,cell,cell}end
 for i,name in ipairs({'Effects','Photo','Cfg'})do r[name]={rx+(i-1)*step,bottom,cell,cell}end
 for _,name in ipairs({'Body','Commands'})do r[name]={il+8,it+8,cell,cell};r.Hidden[name]=true end
 if portrait then
  local y=top+cell+8
  r.HideUI={il+8,y,cell,cell};r.AvatarTools={il+8+step,y,cell,cell}
  for i,name in ipairs({'TopMusic','Cart','RemoveItems'})do r[name]={w-ir-8-(4-i)*step+gap,y,cell,cell}end
  local sy=y+cell+16
  for i,name in ipairs({'Community','Loader','Assistant'})do r[name][2]=sy+(i-1)*(cell+6)end
  for i,name in ipairs({'Looks','Emotes','Games'})do r[name][2]=sy+(i-1)*(cell+6)end
  local py=sy+3*(cell+6)+8
  if py+cell>h-ib-8 then py=sy+cell+8;for _,name in ipairs({'Loader','Assistant','Emotes','Games'})do r.Hidden[name]=true end end
  r.Photo={w-ir-8-2*cell-gap,py,cell,cell};r.Cfg={w-ir-8-cell,py,cell,cell}
 end
 if touch or portrait then
  for _,name in ipairs({'Undo','Redo','NewAvatar','CurrentlyWearing','SaveRoblox','RestoreAvatar','Effects'})do r.Hidden[name]=true end
 end
 if not portrait and(touch or ah<390)then
  r.Photo={w-ir-8-2*cell-gap,top+cell+8,cell,cell};r.Cfg={w-ir-8-cell,top+cell+8,cell,cell}
  for i,name in ipairs({'Community','Loader','Assistant'})do r[name][2]=top+2*cell+16+(i-1)*(cell+6)end
  for i,name in ipairs({'Looks','Emotes','Games'})do r[name][2]=top+2*cell+16+(i-1)*(cell+6)end
  for _,name in ipairs({'NewAvatar','CurrentlyWearing','SaveRoblox','RestoreAvatar','Effects'})do r.Hidden[name]=true end
 end
 if touch then
  local limit=h-ib-158
  for _,name in ipairs({'Community','Loader','Assistant','Looks','Emotes','Games','Photo','Cfg'})do
   if r[name][2]+r[name][4]>limit then r.Hidden[name]=true end
  end
 end
 if compact then r.Hidden.Undo=true;r.Hidden.Redo=true end
 if r.Redo[1]+cell+8>r.TopMusic[1]then r.Hidden.Undo=true;r.Hidden.Redo=true end
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
