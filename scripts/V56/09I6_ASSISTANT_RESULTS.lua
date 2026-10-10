-- 09I6_ASSISTANT_RESULTS | ModuleScript | ReplicatedStorage | V56
-- Prévia 360°, comparar, aplicar, guardar, versões e coleções sem chat salvo.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'))
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local S=require(Rep:WaitForChild('08D_SKIN_STATE'));local M={}
function M.Build(U,call,notice)
 local R={Rows={},Index=1,SavedRows={},SavedIndex=1,Plan='Normal',InlineViews={}};local dispose={}
 local function build(parent)
  local V={};V.Stage=D.Frame(parent,{Name='LookStudio',BackgroundColor3=Color3.fromRGB(158,177,196)})
  V.View=D.New('ViewportFrame',{Name='Look360',Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,1,-8),BackgroundTransparency=1},V.Stage)
  V.Name=D.Text(parent,'',{TextSize=17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  V.Price=D.Text(parent,'',{TextSize=12,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left})
  V.Items=D.Scroll(parent,{Name='OutfitItems',ScrollBarThickness=3,ScrollingDirection=Enum.ScrollingDirection.Y})
  V.List=D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(6,6),CellSize=UDim2.fromOffset(100,64),SortOrder=Enum.SortOrder.LayoutOrder},V.Items)
  V.Actions=D.New('Frame',{BackgroundTransparency=1},parent)
  V.Apply=D.Button(V.Actions,'Aplicar',{TextSize=13,BackgroundColor3=C.orange,TextColor3=C.bg});V.Save=D.Button(V.Actions,'Guardar',{TextSize=13})
  V.Cart=D.Button(V.Actions,'Carrinho',{TextSize=13});V.Compare=D.Button(V.Actions,'Comparar',{TextSize=13})
  V.Folder=D.Box(parent,'Coleção (Pro)',{Text='Favoritos',TextSize=13})
  V.Pager=D.New('Frame',{BackgroundTransparency=1},parent);V.Prev=D.Button(V.Pager,'‹',{TextSize=26});V.Next=D.Button(V.Pager,'›',{TextSize=26});V.Page=D.Text(V.Pager,'',{TextSize=12})
  V.CompareHost=D.New('Frame',{Name='CompareLooks',BackgroundTransparency=1,Visible=false,ZIndex=30},parent)
  return V
 end
 R.Live=build(U.Results);R.Saved=build(U.Saved)
 local function clear(p)for _,o in ipairs(p:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end end
 local function rows(isSaved)return isSaved and R.SavedRows or R.Rows end
 local function current(isSaved)local list=rows(isSaved);return list[isSaved and R.SavedIndex or R.Index]end
 local function render(V,isSaved)
  local list=rows(isSaved);local index=isSaved and R.SavedIndex or R.Index;index=math.clamp(index,1,math.max(1,#list));if isSaved then R.SavedIndex=index else R.Index=index end
  local row=list[index];Preview.Unmount(V.View);clear(V.Items);V.Page.Text=#list>0 and(index..' / '..#list)or'0 looks'
  V.Name.Text=row and((isSaved and(row.folder..' • ')or'')..row.name..(isSaved and row.parent and' • versão'or''))or'Nenhum look';V.Price.Text=row and('Peças novas: '..tostring(row.total or'?')..' Robux • estimativa')or'Crie um look ou guarde sua combinação favorita.'
  for _,b in ipairs({V.Apply,V.Save,V.Cart,V.Compare})do D.SetEnabled(b,row~=nil)end
  V.Save.Text=isSaved and(row and row.sharedOwner and'Guardar cópia'or'Excluir salvo')or'Guardar';V.Folder.Visible=not isSaved and R.Plan=='Pro'
  if not row then return end
  if(isSaved and U.Saved.Visible or not isSaved and U.Results.Visible)then Preview.Mount(V.View,row.body,row.rig or'R15',{drag=true,zoom=1.06,floor=false,failed=notice})end
  for i,e in ipairs(A.Entries(row.body))do
   local item=D.Frame(V.Items,{Name='Item'..e.Id,LayoutOrder=i,BackgroundColor3=C.panel})
   D.New('ImageLabel',{Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(54,54),BackgroundTransparency=1,Image=A.AssetThumb(e.Id,150),ScaleType=Enum.ScaleType.Fit},item)
   local remove=D.Button(item,'×',{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-2,.5,0),Size=UDim2.fromOffset(44,44),TextSize=20})
   remove.Activated:Connect(function()local nextBody=A.Remove(row.body,e.Id);row.body=nextBody;render(V,isSaved)end)
  end
  R.Layout(U.Body.AbsoluteSize.X,U.Body.AbsoluteSize.Y)
 end
 local function compare(V,isSaved)
  for _,view in ipairs(dispose)do Preview.Unmount(view)end;dispose={};clear(V.CompareHost)
  V.CompareHost.Visible=not V.CompareHost.Visible;if not V.CompareHost.Visible then return end
  local list=rows(isSaved);local count=math.min(#list,R.Plan=='Pro'and 5 or R.Plan=='Studio'and 2 or 1)
  for i=1,count do
   local f=D.Frame(V.CompareHost,{Name='Compare'..i,BackgroundColor3=C.panel,Position=UDim2.new((i-1)/count,3,0,0),Size=UDim2.new(1/count,-6,1,0),ZIndex=31})
   local view=D.New('ViewportFrame',{Position=UDim2.fromOffset(3,3),Size=UDim2.new(1,-6,1,-51),BackgroundColor3=Color3.fromRGB(160,178,197),ZIndex=32},f);dispose[#dispose+1]=view
   Preview.Mount(view,list[i].body,list[i].rig,{drag=true,compact=true,floor=false})
   local b=D.Button(f,'Escolher '..i,{Position=UDim2.new(0,3,1,-48),Size=UDim2.new(1,-6,0,44),TextSize=12,ZIndex=33})
   b.Activated:Connect(function()V.CompareHost.Visible=false;for _,v in ipairs(dispose)do Preview.Unmount(v)end;dispose={};if isSaved then R.SavedIndex=i else R.Index=i end;render(V,isSaved)end)
  end
 end
 for i,V in ipairs({R.Live,R.Saved})do local isSaved=i==2
  V.Prev.Activated:Connect(function()if isSaved then R.SavedIndex=math.max(1,R.SavedIndex-1)else R.Index=math.max(1,R.Index-1)end;render(V,isSaved)end)
  V.Next.Activated:Connect(function()if isSaved then R.SavedIndex=math.min(#R.SavedRows,R.SavedIndex+1)else R.Index=math.min(#R.Rows,R.Index+1)end;render(V,isSaved)end)
  V.Apply.Activated:Connect(function()local row=current(isSaved);if row then local ok,e=S.Set(row.body,false,row.rig);notice(ok and'Aplicando no personagem…'or e)end end)
  V.Save.Activated:Connect(function()
   local row=current(isSaved);if not row then return end
   task.spawn(function()
    local action=isSaved and(row.sharedOwner and'copyshared'or'delete')or'save'
    local d,e=call(action,isSaved and{id=row.id,owner=row.sharedOwner}or{index=R.Index,folder=V.Folder.Text,body=row.body})
    notice(d and(action=='delete'and'Look removido.'or'Look guardado em Salvos.')or e);if d and R.Refresh then R.Refresh()end
   end)
  end)
  V.Cart.Activated:Connect(function()local row=current(isSaved);if not row then return end;local lib=require(Rep:WaitForChild('09C4_OUTFIT_LIBRARY'));U.Root.Visible=false;lib.Open(row.body)end)
  V.Compare.Activated:Connect(function()compare(V,isSaved)end)
 end
 function R.SyncInline()
  for _,entry in ipairs(R.InlineViews)do
   local y=entry.View.AbsolutePosition.Y;local top=U.Chat.AbsolutePosition.Y;local height=U.Chat.AbsoluteSize.Y
   local visible=U.Root.Visible and U.Chat.Visible and entry.View.Parent and y+entry.View.AbsoluteSize.Y>=top-80 and y<=top+height+80
   if visible and not entry.Mounted then entry.Mounted=true;Preview.Mount(entry.View,entry.Row.body,entry.Row.rig,{drag=true,floor=false,compact=true,failed=notice})
   elseif not visible and entry.Mounted then Preview.Unmount(entry.View);entry.Mounted=false end
  end
 end
 function R.ClearInline()
  for _,entry in ipairs(R.InlineViews)do Preview.Unmount(entry.View)end;R.InlineViews={}
  if R.Inline then R.Inline:Destroy();R.Inline=nil end
 end
 function R.Accept(data)
  if #(data.looks or{})==0 then return end
  R.ClearInline();R.Rows=data.looks;R.Plan=data.plan or R.Plan;R.Index=1;R.Live.CompareHost.Visible=false;render(R.Live,false)
  R.Inline=D.New('Frame',{Name='InlineLooks',BackgroundTransparency=1,Size=UDim2.new(1,-6,0,280),LayoutOrder=U.NextOrder()},U.Chat)
  for i,row in ipairs(R.Rows)do
   local card=D.Frame(R.Inline,{Name='CreatedLook'..i,BackgroundColor3=C.panel})
   local view=D.New('ViewportFrame',{Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,1,-114),BackgroundColor3=Color3.fromRGB(187,184,196)},card)
   D.Text(card,row.name,{Position=UDim2.new(0,5,1,-108),Size=UDim2.new(1,-10,0,24),TextSize=13,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
   D.Text(card,'Peças novas: '..tostring(row.total)..' Robux',{Position=UDim2.new(0,5,1,-84),Size=UDim2.new(1,-10,0,30),TextSize=12,TextColor3=C.orange})
   local use=D.Button(card,'Usar',{Position=UDim2.new(0,4,1,-50),Size=UDim2.new(.33,-5,0,44),BackgroundColor3=C.orange,TextColor3=C.bg,TextSize=12})
   local save=D.Button(card,'Salvar',{Position=UDim2.new(.33,2,1,-50),Size=UDim2.new(.33,-5,0,44),TextSize=12})
   local details=D.Button(card,'Ver',{Position=UDim2.new(.66,2,1,-50),Size=UDim2.new(.34,-6,0,44),TextSize=12})
   use.Activated:Connect(function()R.Index=i;local ok,e=S.Set(row.body,false,row.rig);notice(ok and'Aplicando no personagem…'or e)end)
   save.Activated:Connect(function()task.spawn(function()local ok,e=call('save',{index=i,body=row.body});notice(ok and'Look guardado em Looks salvos.'or e);if ok and R.Refresh then R.Refresh()end end)end)
   details.Activated:Connect(function()R.Index=i;R.Hide();U.Select('Looks');R.Resume()end)
   R.InlineViews[#R.InlineViews+1]={Card=card,View=view,Row=row}
  end
  R.Layout(U.Body.AbsoluteSize.X,U.Body.AbsoluteSize.Y);U.ScrollBottom();task.defer(R.SyncInline)
 end
 function R.SetSaved(list)R.SavedRows=list or{};render(R.Saved,true)end
 function R.Layout(w,h)
  if w<=0 or h<=0 then return end
  if R.Inline then
   local width=math.max(240,U.Chat.AbsoluteSize.X-6);local cols=width>=680 and math.min(3,#R.InlineViews)or width>=430 and math.min(2,#R.InlineViews)or 1
   local cw=(width-(cols-1)*8)/math.max(1,cols);local rows=math.ceil(#R.InlineViews/math.max(1,cols))
   R.Inline.Size=UDim2.new(1,-6,0,rows*288-8)
   for i,entry in ipairs(R.InlineViews)do Bounds.Rect(entry.Card,(i-1)%cols*(cw+8),math.floor((i-1)/cols)*288,cw,280)end
  end
  for _,V in ipairs({R.Live,R.Saved})do
   local wide=w>=460 and w>h;local pw=wide and math.floor(w*.44)or w;local ph=wide and h-50 or math.floor(h*.48)
   V.Folder.Visible=V==R.Live and R.Plan=='Pro'and h>=300
   Bounds.Rect(V.Stage,0,0,pw,math.max(36,ph));local x=wide and pw+8 or 0;local y=wide and 0 or ph+6;local rw=wide and w-pw-8 or w
   Bounds.Rect(V.Name,x,y,rw,26);Bounds.Rect(V.Price,x,y+28,rw,22)
   local cols=rw>=400 and 4 or 2;local actionH=cols==4 and 44 or 94
   local footer=actionH+6+(V.Folder.Visible and 50 or 0);local iy=y+54;Bounds.Rect(V.Items,x,iy,rw,math.max(16,h-iy-footer));V.List.FillDirectionMaxCells=math.max(1,math.floor(rw/106))
   local ay=h-actionH;local cw=(rw-(cols-1)*6)/cols;Bounds.Rect(V.Actions,x,ay,rw,actionH);for i,b in ipairs({V.Apply,V.Save,V.Cart,V.Compare})do Bounds.Rect(b,(i-1)%cols*(cw+6),math.floor((i-1)/cols)*50,cw,44)end
   Bounds.Rect(V.Folder,x,ay-50,rw,44)
   local pagerW=wide and pw or math.min(210,w);Bounds.Rect(V.Pager,0,wide and h-44 or ph-44,pagerW,44)
   Bounds.Rect(V.Prev,0,0,44,44);Bounds.Rect(V.Next,pagerW-44,0,44,44);Bounds.Rect(V.Page,48,0,pagerW-96,44)
   Bounds.Rect(V.CompareHost,0,0,w,h)
  end
 end
 function R.Hide()for _,V in ipairs({R.Live,R.Saved})do Preview.Unmount(V.View);V.CompareHost.Visible=false end;for _,v in ipairs(dispose)do Preview.Unmount(v)end;dispose={};for _,entry in ipairs(R.InlineViews)do Preview.Unmount(entry.View);entry.Mounted=false end end
 function R.Resume()if U.Tab=='Looks'then render(R.Live,false)elseif U.Tab=='Salvos'then render(R.Saved,true)else task.defer(R.SyncInline)end end
 U.Chat:GetPropertyChangedSignal('CanvasPosition'):Connect(R.SyncInline);U.Chat:GetPropertyChangedSignal('AbsoluteSize'):Connect(R.SyncInline)
 U.Chat:GetPropertyChangedSignal('Visible'):Connect(R.SyncInline);U.Root:GetPropertyChangedSignal('Visible'):Connect(R.SyncInline)
 return R
end
return M
