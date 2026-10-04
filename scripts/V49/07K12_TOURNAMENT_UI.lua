-- 07K12_TOURNAMENT_UI | ModuleScript | ReplicatedStorage | V46
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={}
local function date(t)return os.date("!%d/%m • %H:%M",t-3*3600).." Brasília"end
function M.Build(gui,call,toast,join)
 local U={Game="Truco",Tab="Convites",Inbox={}};local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="WeeklyTournaments",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false},gui)
 U.Title=D.Text(U.Root,"Torneios semanais",{Font=Enum.Font.GothamBold,TextSize=24,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,"CloseTournaments","close","Fechar torneios",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 U.Note=D.Text(U.Root,"Entrada gratuita • prêmio: título • 10 jogadores ou 10 duplas",{TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Tabs=D.New("Frame",{BackgroundTransparency=1},U.Root);local buttons={}
 for i,key in ipairs({"Convites","Xadrez","Damas","Truco"})do local b=D.Button(U.Tabs,key,{});buttons[i]=b
  b.Activated:Connect(function()U.Tab=key;if key~="Convites"then U.Game=key end;U.Render()end)
 end
 U.List=D.Scroll(U.Root,{Name="TournamentEntries"});D.New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.List)
 local function clear()for _,v in ipairs(U.List:GetChildren())do if v:IsA("GuiObject")then v:Destroy()end end end
 function U.SetInbox(data)U.Inbox=data or{};if U.Root.Visible and U.Tab=="Convites"then U.Render()end end
 function U.Render()
  clear();for _,b in ipairs(buttons)do b.BackgroundColor3=b.Text==U.Tab and C.soft or C.card end
  if U.Tab=="Convites"then
   if #U.Inbox==0 then D.Text(U.List,"Os convites aparecem aqui quando a classificação semanal for fechada.\nResponda em até 48 horas; o check-in abre 15 minutos antes.",{Size=UDim2.new(1,-8,0,92),TextColor3=C.muted})end
   for _,invite in ipairs(U.Inbox)do
    local row=D.Frame(U.List,{Size=UDim2.new(1,-8,0,148),BackgroundColor3=C.panel})
    D.Text(row,invite.game.." • "..date(invite.start),{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,28),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
    D.Text(row,invite.answered=="yes"and(invite.status=="reserve"and"Reserva confirmada • "or"Participação confirmada • ")..(invite.checked and"check-in realizado"or"faça check-in entre 15 e 5 minutos antes")or invite.status=="Prazo encerrado"and"Prazo encerrado"or"Responda até "..date(invite.deadline),{
     Position=UDim2.fromOffset(12,42),Size=UDim2.new(1,-24,0,44),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
    local yes=D.Button(row,invite.match and"Entrar na partida"or invite.canCheckin and"Fazer check-in"or"Confirmar participação",{Position=UDim2.fromOffset(12,96),Size=UDim2.new(.65,-18,0,44),BackgroundColor3=C.green,TextColor3=C.bg})
    local no=D.Button(row,"Recusar convite",{Position=UDim2.new(.65,0,0,96),Size=UDim2.new(.35,-12,0,44)})
    D.SetEnabled(yes,invite.match~=nil or invite.canCheckin or invite.canAnswer);D.SetEnabled(no,invite.canAnswer==true)
    yes.Activated:Connect(function()
     if invite.match then join(invite);return end
     local d,e=call(invite.canCheckin and"checkin"or"answer",{id=invite.id,accept=true});toast(d and(invite.canCheckin and"Check-in realizado."or"Participação confirmada.")or e)
     local inbox=call("inbox");if inbox then U.Inbox=inbox;U.Render()end
    end)
    no.Activated:Connect(function()local d,e=call("answer",{id=invite.id,accept=false});toast(d and"Convite recusado."or e);local inbox=call("inbox");if inbox then U.Inbox=inbox;U.Render()end end)
   end
  else
   local rows,e=call("rank",{game=U.Game});if not rows then toast(e);return end
   D.Text(U.List,U.Game.." • vitórias PvP válidas desta semana",{Size=UDim2.new(1,-8,0,36),TextColor3=C.muted})
   if #rows==0 then D.Text(U.List,"A classificação começa com partidas PvP concluídas. Partidas contra bots não contam.",{Size=UDim2.new(1,-8,0,70),TextColor3=C.muted})end
   for i,v in ipairs(rows)do
    D.Text(U.List,string.format("%02d   %s   •   %d vitórias",i,tostring(v.label or"Jogador"),v.value),{
     Name="Rank_"..i,Size=UDim2.new(1,-8,0,48),BackgroundColor3=C.panel,BackgroundTransparency=0,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=i})
   end
  end
 end
 function U.Show()U.Root.Visible=true;local inbox,e=call("inbox");if inbox then U.Inbox=inbox else toast(e)end;U.Render()end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local y=safe.Heading(U.Title,U.Close);local aw=w-il-ir
  Bounds.Rect(U.Note,il+10,y,aw-20,38);Bounds.Rect(U.Tabs,il+8,y+44,aw-16,44)
  for i,b in ipairs(buttons)do Bounds.Rect(b,(i-1)*(aw-12)/4,0,(aw-28)/4,44)end
  Bounds.Rect(U.List,il+8,y+96,aw-16,h-ib-y-104)
 end
 U.Close.Activated:Connect(function()U.Root.Visible=false;if U.OnClose then U.OnClose()end end);safe.Watch(U.Layout);return U
end
return M
