-- 09C7_COMMUNITY_FEED | ModuleScript | ReplicatedStorage | V47
-- Lista real: primeiro lote, Carregar mais e janela de até 100 looks; 50 slots reciclados.
local Rep=game:GetService("ReplicatedStorage")
local Preview=require(Rep:WaitForChild("09C6_AVATAR_PREVIEW"))
local M={}
function M.Init(ctx)
 local U,A,call,toast=ctx.U,ctx.A,ctx.call,ctx.toast
 local F={Pool={},Rows={},Seen={},History={},Pending={},Page=0,Mode="JOGADORES",Revision=0,Loading=false,Finished=false,NoMore=false,Evicted=0}
 local grid=U.CommunityGrid;local old=grid:FindFirstChildOfClass("UIGridLayout");if old then old:Destroy()end
 grid.AutomaticCanvasSize=Enum.AutomaticSize.None;grid.CanvasSize=UDim2.new();grid.ScrollBarThickness=4
 local gap,cols,cw,ch=6,5,140,174;local queued=false;local render,request
 local function release(slot)if slot.record then Preview.Unmount(slot.view)end;slot.record=nil;slot.root.Visible=false;slot.image.Image=""end
 local function enqueue()if queued then return end;queued=true;task.defer(function()queued=false;render()end)end
 for i=1,50 do
  local c=U.Button(grid,"",{Name="CommunitySlot_"..i,BackgroundColor3=U.Colors.card,Visible=false})
  local padding=c:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
  local image=U.New("ImageLabel",{BackgroundColor3=Color3.fromRGB(139,149,167),BorderSizePixel=0,ScaleType=Enum.ScaleType.Fit,Active=false},c);U.Round(image,8)
  local view=U.New("ViewportFrame",{Visible=false,BackgroundColor3=image.BackgroundColor3,BorderSizePixel=0,Active=false},c);U.Round(view,8)
  local name=U.Text(c,"",{TextSize=13,Font=Enum.Font.GothamBold,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Active=false})
  local author=U.Text(c,"",{TextSize=12,TextColor3=U.Colors.muted,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,Active=false})
  local slot={root=c,image=image,view=view,name=name,author=author};F.Pool[i]=slot;c.Activated:Connect(function()if slot.record then ctx.show(slot.record)end end)
 end
 local function accept(r)
  if not r.body or r.source=="Roblox"and(not tonumber(r.owner)or r.owner<=1)then return 0 end
  local key=r.signature or r.id;if not key or F.Seen[key]then return 0 end
  F.Seen[key]=true;table.insert(F.History,key);while #F.History>600 do F.Seen[table.remove(F.History,1)]=nil end
  table.insert(F.Rows,r)
  while #F.Rows>100 do for _=1,10 do local gone=table.remove(F.Rows,1);F.Evicted=F.Evicted+1 end
   grid.CanvasPosition=Vector2.new(0,math.max(0,grid.CanvasPosition.Y-10/cols*(ch+gap)))
  end;return 1
 end
 request=function(initial)
  if F.Loading or F.Finished and #F.Pending==0 or U.LookDetail.Visible then return end
  local mine=F.Revision;F.Loading=true;local target=initial and 50 or #F.Rows+10;local attempts=0;U.ComMore.Text="Carregando…"
  task.spawn(function()
   local added=0;local failure=nil
   repeat
    while #F.Pending>0 and(initial and #F.Rows<target or not initial and added<10)do added=added+accept(table.remove(F.Pending,1))end
    F.Finished=F.NoMore and #F.Pending==0
    if F.Finished then break end
    if(initial and #F.Rows>=target or not initial and added>=10)then break end
    local result,err;local native=F.Mode=="JOGADORES"or F.Mode=="ROBUX"or F.Mode=="GRÁTIS"
    local query=tostring(U.ComSearch.Text or"")
    if native then result,err=call("CuratedPage",{page=F.Page,search=query,budget=F.Mode=="GRÁTIS"and"free"or F.Mode=="ROBUX"and"paid"or"all",exact=query:sub(1,1)=="@"or tonumber(query)~=nil})
    else result,err=call("Feed",{next=F.Page>0,search=query})end
    if mine~=F.Revision then return end
    if not result then failure="Não carregou agora. Toque em Carregar mais para tentar novamente.";break end
    if result.retry and #(result.items or{})==0 then failure=result.message or"Os avatares demoraram a responder. Tente novamente.";break end
    for _,r in ipairs(result.items or{})do table.insert(F.Pending,r)end
    while #F.Pending>0 and(initial and #F.Rows<target or not initial and added<10)do added=added+accept(table.remove(F.Pending,1))end
    F.Page=F.Page+1;F.NoMore=result.finished==true;F.Finished=F.NoMore and #F.Pending==0;attempts=attempts+1;render()
    if F.Finished or(initial and #F.Rows>=target or not initial and added>=10)or attempts>=8 then break end
    task.wait(.9)
   until false
   if mine~=F.Revision then return end;F.Loading=false;U.ComMore.Text="Carregar mais"
   if failure then U.CommunityStatus.Text=failure
   elseif #F.Rows==0 then U.CommunityStatus.Text="Nenhum look nesta busca. Tente @jogador ou outra categoria."
   elseif attempts>0 then U.CommunityStatus.Text=F.Mode=="GRÁTIS"and"Looks gratuitos · preços confirmados"or F.Mode=="ROBUX"and"Looks com Robux · preços confirmados"or"Avatares atuais de jogadores · itens reais"end
   render()
  end)
 end
 render=function()
  if not U.Root.Visible or not U.CommunityArea.Visible then for _,slot in ipairs(F.Pool)do release(slot)end;return end
  local w,h=grid.AbsoluteSize.X,grid.AbsoluteWindowSize.Y;if w<1 or h<1 then return end
  cols=math.clamp(math.floor((w+gap)/132),2,5);cw=math.floor((w-6-gap*(cols-1))/cols)
  local rows=h>=282 and 3 or 2;ch=math.max(48,math.floor((h-gap*(rows-1))/rows));local step=ch+gap
  grid.CanvasSize=UDim2.fromOffset(0,math.ceil(#F.Rows/cols)*step)
  local first=math.max(0,math.floor(grid.CanvasPosition.Y/step)-1)*cols;local count=math.min(50,(math.ceil(h/step)+2)*cols)
  for i,slot in ipairs(F.Pool)do local index=first+i;local r=i<=count and F.Rows[index]
   if not r then release(slot)
   else
    slot.root.Position=UDim2.fromOffset((index-1)%cols*(cw+gap),math.floor((index-1)/cols)*step);slot.root.Size=UDim2.fromOffset(cw,ch);slot.root.Visible=true
    if ch<100 and cw>=128 or ch<132 and cw>=150 then local size=ch-6;slot.image.Position=UDim2.fromOffset(2,3);slot.image.Size=UDim2.fromOffset(size,size)
     slot.name.Position=UDim2.fromOffset(size+6,4);slot.name.Size=UDim2.fromOffset(cw-size-10,ch-28);slot.name.TextWrapped=true
     slot.author.Position=UDim2.fromOffset(size+6,ch-24);slot.author.Size=UDim2.fromOffset(cw-size-10,20)
    else
     slot.image.Position=UDim2.fromOffset(2,2);slot.image.Size=UDim2.new(1,-4,1,-45)
     slot.name.Position=UDim2.new(0,6,1,-42);slot.name.Size=UDim2.new(1,-12,0,20);slot.name.TextWrapped=false
     slot.author.Position=UDim2.new(0,6,1,-22);slot.author.Size=UDim2.new(1,-12,0,18)
    end
    slot.view.Position=slot.image.Position;slot.view.Size=slot.image.Size
    if slot.record~=r then Preview.Unmount(slot.view);slot.record=r;slot.name.Text=tostring(r.name or"Look de jogador")
     slot.author.Text=r.total~=nil and(r.total==0 and"GRÁTIS"or r.total.." Robux")or"Ver itens"
     slot.image.Visible=r.source=="Roblox";slot.view.Visible=r.source~="Roblox"
     if r.source=="Roblox"then slot.image.Image=r.thumbnail or("rbxthumb://type=Avatar&id="..r.owner.."&w=420&h=420")elseif r.body then Preview.Mount(slot.view,r.body,r.rig,{zoom=1})end
    end
   end
  end
  U.ComMore.Visible=true;U.ComMore.Text=F.Loading and"Carregando…"or F.Finished and"Fim da lista"or"Carregar mais";U.ComMore.Active=not F.Loading and not F.Finished
 end
 function F.Open(mode)
  F.Revision=F.Revision+1;F.Mode=mode or F.Mode;F.Rows={};F.Seen={};F.History={};F.Pending={};F.Page=0;F.Loading=false;F.Finished=false;F.NoMore=false;F.Evicted=0
  for _,slot in ipairs(F.Pool)do release(slot)end;F.Layout();grid.CanvasPosition=Vector2.zero
  U.CommunityStatus.Text="Buscando avatares de jogadores…"
  for name,b in pairs(U.ComTabButtons)do b.BackgroundColor3=name==F.Mode and U.Colors.soft or U.Colors.card end
  if tostring(U.ComSearch.Text):upper():match("^AP[-]")then local mine=F.Revision;task.spawn(function()local r,e=call("Code",{code=U.ComSearch.Text});if mine==F.Revision then if r then ctx.show(r)else toast(e)end end end);return end
  request(true)
 end
 function F.Named(id,name)for _,r in ipairs(F.Rows)do if r.id==id then r.name=name end end;for _,slot in ipairs(F.Pool)do if slot.record and slot.record.id==id then slot.name.Text=name end end end
 function F.Layout()
  local parent=grid.Parent;local w,h=parent.AbsoluteSize.X,parent.AbsoluteSize.Y;local compact=w>=620 and h<360
  local header=compact and 50 or 90;local cm=U.ComSearch.Parent;cm.Position=UDim2.fromOffset(0,0);cm.Size=UDim2.fromOffset(w,header);cm.BackgroundTransparency=1
  U.ComSearch.PlaceholderText="Estilo, personagem, @jogador ou ID";U.ComMyOutfits.Visible=false
  U.ComSearch.AnchorPoint=Vector2.zero;U.ComSearchGo.AnchorPoint=Vector2.zero;U.ComRefresh.AnchorPoint=Vector2.zero
  U.ComSearch.Position=UDim2.fromOffset(6,4);U.ComSearch.Size=UDim2.fromOffset(w-118,40)
  U.ComSearchGo.Position=UDim2.fromOffset(w-106,4);U.ComSearchGo.Size=UDim2.fromOffset(54,40)
  U.ComRefresh.Position=UDim2.fromOffset(w-48,4);U.ComRefresh.Size=UDim2.fromOffset(42,40);U.ComRefresh.Text="↻"
  local tabs=U.ComTabButtons.JOGADORES.Parent;local old=tabs:FindFirstChildOfClass("UIListLayout");if old then old:Destroy()end
  tabs.AutomaticCanvasSize=Enum.AutomaticSize.None;tabs.ScrollingEnabled=false;tabs.Position=UDim2.fromOffset(6,50);tabs.Size=UDim2.fromOffset(w-12,40);local tw=w-12
  if compact then local sw=w*.42;U.ComSearch.Size=UDim2.fromOffset(sw-110,44);U.ComSearchGo.Position=UDim2.fromOffset(sw-98,4);U.ComRefresh.Position=UDim2.fromOffset(sw-46,4);tabs.Position=UDim2.fromOffset(sw+4,4);tw=w-sw-10;tabs.Size=UDim2.fromOffset(tw,44)end
  for i,name in ipairs({"JOGADORES","ROBUX","GRÁTIS","PUBLICADOS"})do local b=U.ComTabButtons[name];b.Position=UDim2.fromOffset((i-1)*(tw+4)/4,0);b.Size=UDim2.fromOffset((tw-12)/4,40);b.TextSize=w<480 and 10 or 12 end
  grid.Position=UDim2.fromOffset(6,header);grid.Size=UDim2.fromOffset(w-12,math.max(96,h-header-48))
  U.CommunityStatus.AnchorPoint=Vector2.zero;U.CommunityStatus.Position=UDim2.fromOffset(6,h-46);U.CommunityStatus.Size=UDim2.fromOffset(w-154,42);U.CommunityStatus.TextSize=11;U.CommunityStatus.TextWrapped=true
  U.ComMore.AnchorPoint=Vector2.zero;U.ComMore.Position=UDim2.fromOffset(w-144,h-46);U.ComMore.Size=UDim2.fromOffset(138,44);U.ComMore.TextSize=12;enqueue()
 end
 U.ComMore.Activated:Connect(function()request(false)end)
 U.ComSearch.FocusLost:Connect(function(enter)if enter then F.Open()end end);U.ComSearchGo.Activated:Connect(function()F.Open()end);U.ComRefresh.Activated:Connect(function()F.Open()end)
 for name,b in pairs(U.ComTabButtons)do b.Activated:Connect(function()U.ComSearch.Text="";F.Open(name)end)end
 for _,property in ipairs({"CanvasPosition","AbsoluteSize"})do grid:GetPropertyChangedSignal(property):Connect(enqueue)end
 for _,o in ipairs({U.Root,U.CommunityArea,U.LookDetail})do o:GetPropertyChangedSignal("Visible"):Connect(enqueue)end
 grid.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(F.Layout);F.Layout();return F
end
return M
