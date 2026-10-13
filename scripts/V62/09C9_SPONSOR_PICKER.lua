-- 09C9_SPONSOR_PICKER | ModuleScript | ReplicatedStorage | V62 (SUBSTITUIR)
-- Pesquisa de nome/ID com exemplos nativos; confirmação continua sendo do servidor.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService')
local Design=require(Rep:WaitForChild('09C10_SPONSOR_DESIGN'))
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={}
function M.Build(shade,ctx,onChoose)
 local A=ctx.A;local host=D.Frame(shade,{Name='SponsorSearch',BackgroundColor3=D.Colors.panel,ZIndex=80})
 local query=D.Box(host,'Buscar roupa, acessório ou ID',{Name='SponsorSearchQuery',ZIndex=81})
 local go=D.Button(host,'Buscar',{ZIndex=81});local kind=D.Button(host,'Roupas 2D',{ZIndex=81})
 local close=D.IconButton(host,'CloseSponsorSearch','close','Voltar',{ZIndex=85})
 local rows=D.Scroll(host,{Name='SponsorResults',ZIndex=81});local grid=D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(6,6)},rows)
 local state={ticket=0,kind=1};local groups={'Roupas 2D','Roupas 3D','Acessórios','Corpo','Emotes'}
 local status=D.Text(host,'Exemplos do catálogo Roblox',{TextSize=12,TextColor3=D.Colors.muted,ZIndex=81})
 local function layout()
  local w,h=shade.AbsoluteSize.X,shade.AbsoluteSize.Y;B.Rect(host,6,6,w-12,h-12)
  local pw,ph=host.AbsoluteSize.X,host.AbsoluteSize.Y;B.Rect(close,pw-54,0,48,48)
  B.Rect(query,6,52,pw-188,44);B.Rect(go,pw-176,52,76,44);B.Rect(kind,pw-94,52,88,44)
  B.Rect(rows,6,102,pw-12,math.max(44,ph-134));B.Rect(status,6,ph-28,pw-66,22)
  local cols=math.clamp(math.floor((pw+6)/110),2,7);grid.FillDirectionMaxCells=cols;grid.CellSize=UDim2.fromOffset((pw-12-(cols-1)*6)/cols,math.max(80,math.floor((ph-140)/2)))
 end
 local function search()
  state.ticket=state.ticket+1;local mine=state.ticket;status.Text='Buscando no Roblox…'
  task.spawn(function()
   local p=Design.Params(groups[state.kind],query.Text)
   local ok,data=pcall(function()return Avatar:SearchCatalogAsync(p):GetCurrentPage()end)
   if mine~=state.ticket or not host.Parent then return end
   for _,o in ipairs(rows:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
   if not ok then status.Text='O catálogo não respondeu. Toque em Buscar para tentar novamente.';return end
   for i,it in ipairs(data or{})do if i>60 then break end;if Design.Paid(A,it)then
    local b=D.Button(rows,'',{LayoutOrder=i,ZIndex=82});local image=D.New('ImageLabel',{Name='CandidateImage',Size=UDim2.new(1,-4,1,-26),Position=UDim2.fromOffset(2,2),BackgroundTransparency=1,Image=A.Thumbnail(it,420),ScaleType=Enum.ScaleType.Fit,Active=false,ZIndex=83},b)
    D.Text(b,tostring(A.Price(it))..' Robux • '..tostring(it.Name or'Item'),{Position=UDim2.new(0,4,1,-24),Size=UDim2.new(1,-8,0,22),TextSize=11,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,Active=false,ZIndex=83})
    b.Activated:Connect(function()host.Visible=false;onChoose(it)end)
   end end
   status.Text=#(data or{})==0 and'Nenhum item. Tente outro nome ou filtro.'or'Toque para conferir • somente itens com preço em Robux';layout()
  end)
 end
 go.Activated:Connect(search);query.FocusLost:Connect(function(enter)if enter then search()end end)
 kind.Activated:Connect(function()state.kind=state.kind%#groups+1;kind.Text=groups[state.kind];search()end)
 close.Activated:Connect(function()state.ticket=state.ticket+1;host.Visible=false end);shade:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 function state.Open()host.Visible=true;layout();search()end
 layout();host.Visible=false;return state
end
return M
