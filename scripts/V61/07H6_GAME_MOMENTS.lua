-- 07H6_GAME_MOMENTS | ModuleScript | ReplicatedStorage | V61 (NOVO)
-- Encerramento mantém o tabuleiro, resumo e revanche por consentimento.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local M={}
function M.Build(parent)
 local safe=B.Bind(parent:FindFirstAncestorOfClass('ScreenGui'));local U={};U.Root=D.Frame(parent,{Name='MatchSummary',Visible=false,BackgroundColor3=D.Colors.panel,ZIndex=120})
 local r=U.Root;U.Title=D.Text(r,'Partida encerrada',{TextSize=22,Font=Enum.Font.GothamBold,ZIndex=121})
 U.Score=D.Text(r,'',{TextSize=20,Font=Enum.Font.GothamBold,TextColor3=D.Colors.gold,ZIndex=121})
 U.Detail=D.Text(r,'',{TextSize=13,TextColor3=D.Colors.muted,ZIndex=121})
 U.Again=D.Button(r,'Revanche',{Name='MatchAgain',BackgroundColor3=D.Colors.green,TextColor3=D.Colors.bg,ZIndex=121})
 U.Review=D.Button(r,'Rever tabuleiro',{Name='MatchReview',ZIndex=121});U.Exit=D.Button(r,'Outro adversário',{Name='MatchNext',ZIndex=121})
 U.Close=D.IconButton(r,'CloseSummary','close','Rever tabuleiro',{ZIndex=125})
 Fx.Surface(r,D.Colors.panel,D.Colors.card,D.Colors.gold);for _,b in ipairs({U.Again,U.Review,U.Exit})do Fx.Button(b,D.Colors.green)end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw,ah=w-il-ir,h-it-ib;local pw=math.min(560,aw-24);local ph=math.min(264,ah-20)
  B.Rect(r,il+(aw-pw)/2,it+(ah-ph)/2,pw,ph);B.Rect(U.Close,pw-54,2,48,48);B.Rect(U.Title,12,4,pw-76,44)
  B.Rect(U.Score,12,52,pw-24,38);B.Rect(U.Detail,12,96,pw-24,math.max(20,ph-158))
  local bw=(pw-36)/3;for i,b in ipairs({U.Again,U.Review,U.Exit})do B.Rect(b,12+(i-1)*(bw+6),ph-52,bw,44);b.TextSize=pw<390 and 11 or 13 end
 end
 function U.SetTicket(t)
  U.Ticket=t;if U.Final and t then U.Score.Text='Sessão: você '..(t.yours or 0)..' × '..(t.theirs or 0)..' '..tostring(t.opponent or'');U.Again.Active=U.Final.canRematch~=false and t.canRematch~=false;U.Again.Text=t.votes and t.votes>0 and('Confirmado '..t.votes..'/2')or'Revanche'end
 end
 function U.Show(data)
  U.Final=data;U.Root.Visible=true;U.Title.Text=data.winner=='draw'and'Empate'or data.won and'Você venceu!'or'Boa partida!'
  U.Detail.Text=tostring(data.reason or'')..' • '..tostring(data.moves or 0)..' jogadas\nO tabuleiro continua disponível para rever.'
  U.Score.Text=data.score or'Sua próxima partida começa quando você escolher.';U.Again.Active=data.canRematch~=false;U.Again.Text='Revanche';U.SetTicket(U.Ticket);U.Layout()
 end
 function U.Clear()U.Root.Visible=false;U.Final=nil;U.Ticket=nil end
 local function review()r.Visible=false;if U.OnReview then U.OnReview()end end
 U.Close.Activated:Connect(review);U.Review.Activated:Connect(review)
 U.Again.Activated:Connect(function()if not U.Again.Active then return end;if U.OnAgain then U.OnAgain()end end)
 U.Exit.Activated:Connect(function()if U.OnExit then U.OnExit()end end)
 parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(U.Layout);U.Layout();return U
end
return M
