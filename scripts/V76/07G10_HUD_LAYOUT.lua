-- 07G10_HUD_LAYOUT | ModuleScript | ReplicatedStorage | V76 (CRIAR)
-- Posições da referência, com reflow para toque, recortes e controles nativos.
local M={Version='V76'}
function M.Resolve(il,it,ir,ib,w,h,touch,compact)
 local aw,ah=w-il-ir,h-it-ib;local r={};local gap=6;local cell=44;local narrow=w<=h or aw<480
 local side=math.clamp(math.floor(aw*.22),88,compact and 112 or 126)
 local start=il+(aw-242)/2
 r.TopCatalog={start,it+4,136,44};r.TopStores={start+142,it+4,100,44}
 local shortTouch=touch and not narrow and ah<420
 local mid=it+math.max(64,math.min(ah*.35,ah-126))
 if shortTouch then mid=it+4 end
 if narrow then mid=it+64 end
 for i,name in ipairs({'Community','Emotes'})do r[name]={il+8,mid+(i-1)*50,side,44}end
 for i,name in ipairs({'Looks','Loader'})do r[name]={w-ir-side-8,mid+(i-1)*50,side,44}end
 local left={'Effects','Body','CurrentlyWearing','RestoreAvatar'}
 local right={'Games','Photo','Commands','Cfg'}
 for group,names in ipairs({left,right})do
  for i,name in ipairs(names)do
   local x,y
   if narrow then
    x=group==1 and il+8+(i-1)%2*50 or w-ir-102+(i-1)%2*50
    y=it+170+math.floor((i-1)/2)*50
   elseif touch and ah<420 then
    x=group==1 and il+8+(i-1)%2*50 or w-ir-102+(i-1)%2*50;y=it+4+math.floor((i-1)/2)*50
   else
    x=group==1 and il+8+(i-1)*50 or w-ir-202+(i-1)*50
    y=h-ib-(touch and 202 or 52)
   end
   r[name]={x,y,cell,cell}
  end
 end
 r.Hidden={}
 if shortTouch then for _,name in ipairs({'Effects','Body','CurrentlyWearing','RestoreAvatar','Looks','Loader'})do r.Hidden[name]=true end end
 r.AvatarTools={il+(aw-44)/2,h-ib-(touch and aw<360 and 210 or 52),44,44}
 return r
end
function M.Symbol(D,button,kind)
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
