-- 09C7_COMMUNITY_FEED | ModuleScript | ReplicatedStorage
-- V43: no maximo 50 cards reciclados, prefetch aos 30 e cache limitado para voltar.
local Rep=game:GetService("ReplicatedStorage")
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local M={}
function M.Init(ctx)
 local U,A,call,toast=ctx.U,ctx.A,ctx.call,ctx.toast
 local F={Pool={},Cache={},Count={},Starts={},Codes={},Order={},Highest=-1,End=0,Mode="ROBLOX",Revision=0,Loading=false,Finished=false}
 local grid=U.CommunityGrid;local old=grid:FindFirstChildOfClass("UIGridLayout");if old then old:Destroy()end
 grid.AutomaticCanvasSize=Enum.AutomaticSize.None;grid.CanvasSize=UDim2.new();grid.ScrollBarThickness=4
 local gap,cols,cw,ch=6,5,140,174;local queued=false;local render,request
 local function touch(page)
  for i=#F.Order,1,-1 do if F.Order[i]==page then table.remove(F.Order,i)end end;table.insert(F.Order,page)
  while #F.Order>12 do F.Cache[table.remove(F.Order,1)]=nil end
 end
 local function pageAt(index)
  local lo,hi=0,F.Highest
  while lo<=hi do local mid=math.floor((lo+hi)/2);local start=F.Starts[mid]or 0
   if index<start then hi=mid-1 elseif index>=start+(F.Count[mid]or 0)then lo=mid+1 else return mid,index-start+1 end
  end
  return nil
 end
 local function enqueue()
  if queued then return end;queued=true;task.defer(function()queued=false;render()end)
 end
 local function release(slot)
  if slot.record then Preview.Unmount(slot.view)end;slot.record=nil;slot.root.Visible=false;slot.view.Visible=false;slot.image.Image=""
 end
 for i=1,50 do
  local c=U.Button(grid,"",{Name="CommunitySlot_"..i,BackgroundColor3=U.Colors.card,Visible=false})
  local padding=c:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
  local image=U.New("ImageLabel",{Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,1,-49),BackgroundColor3=Color3.fromRGB(139,149,167),BorderSizePixel=0,ScaleType=Enum.ScaleType.Fit,Active=false},c);U.Round(image,8)
  local view=U.New("ViewportFrame",{Position=image.Position,Size=image.Size,Visible=false,BackgroundColor3=image.BackgroundColor3,BorderSizePixel=0,Active=false},c);U.Round(view,8)
  local name=U.Text(c,"",{Position=UDim2.new(0,6,1,-42),Size=UDim2.new(1,-12,0,20),TextSize=13,Font=Enum.Font.GothamBold,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Active=false})
  local author=U.Text(c,"",{Position=UDim2.new(0,6,1,-22),Size=UDim2.new(1,-12,0,18),TextSize=13,TextColor3=U.Colors.muted,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Active=false})
  local slot={root=c,image=image,view=view,name=name,author=author};F.Pool[i]=slot
  c.Activated:Connect(function()if slot.record then ctx.show(slot.record)end end)
 end
 request=function(page,append)
  if F.Loading or page<0 or U.LookDetail.Visible then return end
  local mine=F.Revision;local mode=F.Mode;local query=tostring(U.ComSearch.Text or"");F.Loading=true
  task.spawn(function()
   if mine~=F.Revision then return end
   local result,err
   if mode=="ROBLOX"then result,err=call("DiscoverPage",{page=page,search=query})
   elseif page<=F.Highest then result,err=call("PublicPage",{codes=F.Codes[page]or{}})
   else result,err=call("Feed",{next=page>0,search=query})end
   if mine~=F.Revision then return end;F.Loading=false
   if not result then U.CommunityStatus.Text=err or"Não foi possível carregar. Use atualizar.";return end
   local rows={}
   for _,r in ipairs(result.items or{})do
    if mode~="LOOK DA SEMANA"or(tonumber(r.updated)or 0)>=os.time()-604800 then table.insert(rows,r)end
   end
   if mode~="ROBLOX"then table.sort(rows,function(a,b)
    local al,bl=tonumber(a.likes)or 0,tonumber(b.likes)or 0
    if mode=="EM ALTA"then
     al=(al+1)/(1+math.max(0,(os.time()-(tonumber(a.updated)or 0))/86400)*.42)
     bl=(bl+1)/(1+math.max(0,(os.time()-(tonumber(b.updated)or 0))/86400)*.42)
    end
    if mode~="NOVOS"and al~=bl then return al>bl end
    return(tonumber(a.updated)or 0)>(tonumber(b.updated)or 0)
   end)end
   F.Cache[page]=rows;touch(page)
   if page>F.Highest then
    F.Highest=page;F.Count[page]=#rows
    if F.Mode~="ROBLOX"then
     local codes={};for _,r in ipairs(rows)do if r.code then table.insert(codes,r.code)end end;F.Codes[page]=codes
    end
    F.Finished=result.finished==true or(F.Mode~="ROBLOX"and page>=511);F.Starts[page]=F.End;F.End=F.End+#rows
   end
   U.CommunityStatus.Text=#rows==0 and F.End==0 and"Nenhum avatar encontrado. Tente outro usuário."or F.Mode=="ROBLOX"and"Explore avatares do Roblox"or"Looks publicados pela comunidade"
   render()
  end)
 end
 render=function()
  if not U.Root.Visible or not U.CommunityArea.Visible then for _,slot in ipairs(F.Pool)do release(slot)end;return end
  local w,h=grid.AbsoluteSize.X,grid.AbsoluteWindowSize.Y;if w<1 or h<1 then return end
  cols=math.clamp(math.floor((w+gap)/126),2,5);cw=math.floor((w-6-gap*(cols-1))/cols)
  ch=math.max(118,math.floor((h-gap*3)/4));local step=ch+gap
  local visibleRows=math.ceil(h/step)+2;local firstRow=math.max(0,math.floor(grid.CanvasPosition.Y/step)-1)
  local count=math.min(50,visibleRows*cols);local needPage=nil
  local total=F.End+(F.Finished and 0 or 50);grid.CanvasSize=UDim2.fromOffset(0,math.ceil(total/cols)*step)
  for i,slot in ipairs(F.Pool)do
   local index=firstRow*cols+i-1
   if i>count or index>=F.End then release(slot)
   else
    local page,n=pageAt(index);local rows=page and F.Cache[page];local r=rows and rows[n]
    if not r then release(slot);needPage=needPage or page
    else
     slot.root.Position=UDim2.fromOffset(index%cols*(cw+gap),math.floor(index/cols)*step);slot.root.Size=UDim2.fromOffset(cw,ch);slot.root.Visible=true
     if slot.record~=r then
      Preview.Unmount(slot.view);slot.record=r;slot.name.Text=tostring(r.name or"Look")
      slot.author.Text=r.source=="Roblox"and("@"..tostring(r.sourceUsername).." • R6/R15")or("@"..tostring(r.username or"").." • "..tostring(r.rig or"R15"))
      slot.image.Visible=r.source=="Roblox";slot.view.Visible=r.source~="Roblox"
      if r.source=="Roblox"then slot.image.Image=r.thumbnail or("rbxthumb://type=Avatar&id="..r.owner.."&w=420&h=420")
      elseif r.body then Preview.Mount(slot.view,r.body,r.rig,{zoom=1})end
     end
    end
   end
  end
  if U.LookDetail.Visible then return end
  if needPage then request(needPage,false)
  elseif not F.Finished and(firstRow*cols+math.ceil(h/step)*cols>=F.End-20)then request(F.Highest+1,true)end
 end
 function F.Open(mode)
  F.Revision=F.Revision+1;F.Mode=mode or F.Mode;F.Cache={};F.Count={};F.Starts={};F.Codes={};F.Order={};F.Highest=-1;F.End=0;F.Loading=false;F.Finished=false
  for _,slot in ipairs(F.Pool)do release(slot)end
  F.Layout()
  grid.CanvasPosition=Vector2.zero;U.ComMore.Visible=false
  U.CommunityStatus.Text="Buscando avatares..."
  for name,b in pairs(U.ComTabButtons)do b.BackgroundColor3=name==F.Mode and U.Colors.soft or U.Colors.card end
  if tostring(U.ComSearch.Text):upper():match("^AP[-]")then
   local mine=F.Revision;task.spawn(function()local r,err=call("Code",{code=U.ComSearch.Text});if mine~=F.Revision then return end;if r then ctx.show(r)else toast(err)end end);return
  end
  request(0,false)
 end
 function F.Named(id,name)
  for _,rows in pairs(F.Cache)do for _,r in ipairs(rows)do if r.id==id then r.name=name end end end
  for _,slot in ipairs(F.Pool)do if slot.record and slot.record.id==id then slot.name.Text=name end end
 end
 function F.Layout()
  local parent=grid.Parent;local w,h=parent.AbsoluteSize.X,parent.AbsoluteSize.Y
  U.ComSearch.PlaceholderText=F.Mode=="ROBLOX"and"@usuário ou ID do Roblox"or"Nome do look ou código"
  U.ComSearch.AnchorPoint=Vector2.zero;U.ComSearch.Position=UDim2.fromOffset(6,4);U.ComSearch.Size=UDim2.fromOffset(w-118,40)
  U.ComSearchGo.AnchorPoint=Vector2.zero;U.ComSearchGo.Position=UDim2.fromOffset(w-106,4);U.ComSearchGo.Size=UDim2.fromOffset(54,40)
  U.ComRefresh.AnchorPoint=Vector2.zero;U.ComRefresh.Position=UDim2.fromOffset(w-48,4);U.ComRefresh.Size=UDim2.fromOffset(42,40);U.ComRefresh.Text="↻"
  local tabs=U.ComTabButtons.ROBLOX.Parent;tabs.Position=UDim2.fromOffset(6,50);tabs.Size=UDim2.fromOffset(w-112,36)
  U.ComMyOutfits.AnchorPoint=Vector2.zero;U.ComMyOutfits.Position=UDim2.fromOffset(w-102,50);U.ComMyOutfits.Size=UDim2.fromOffset(96,36);U.ComMyOutfits.Text="Meus looks"
  grid.Position=UDim2.fromOffset(6,94);grid.Size=UDim2.fromOffset(w-12,h-122)
  U.CommunityStatus.AnchorPoint=Vector2.zero;U.CommunityStatus.Position=UDim2.fromOffset(6,h-24);U.CommunityStatus.Size=UDim2.fromOffset(w-12,22);U.CommunityStatus.TextWrapped=false;U.CommunityStatus.TextTruncate=Enum.TextTruncate.AtEnd
  enqueue()
 end
 U.ComSearch.FocusLost:Connect(function(enter)if enter then F.Open()end end);U.ComSearchGo.Activated:Connect(function()F.Open()end)
 U.ComRefresh.Activated:Connect(function()F.Open()end)
 U.ComMyOutfits.Activated:Connect(function()U.OpenRequest:Fire("Looks")end)
 for name,b in pairs(U.ComTabButtons)do b.Activated:Connect(function()U.ComSearch.Text="";F.Open(name);F.Layout()end)end
 for _,property in ipairs({"CanvasPosition","AbsoluteSize"})do grid:GetPropertyChangedSignal(property):Connect(enqueue)end
 for _,o in ipairs({U.Root,U.CommunityArea,U.LookDetail})do o:GetPropertyChangedSignal("Visible"):Connect(enqueue)end
 grid.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(F.Layout)
 F.Layout();return F
end
return M
