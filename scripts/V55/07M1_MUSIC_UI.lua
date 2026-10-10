-- 07M1_MUSIC_UI | ModuleScript | ReplicatedStorage | V55 (NOVO)
-- Popup compacto: não cobre a tela inteira nem muda a música de outros jogadores.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Music');if old then old:Destroy()end
 local U={};U.Gui=D.New('ScreenGui',{Name='ACP_Music',ResetOnSpawn=false,DisplayOrder=190,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.Frame(U.Gui,{Name='MusicPopup',Visible=false,BackgroundColor3=C.panel,ZIndex=10})
 U.Title=D.Text(U.Root,'Música',{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-72,0,44),TextXAlignment=Enum.TextXAlignment.Left,TextSize=20,Font=Enum.Font.GothamBold,ZIndex=11})
 U.Close=D.IconButton(U.Root,'CloseMusic','close','Fechar música',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-4,0,4),Size=UDim2.fromOffset(48,48),ZIndex=30})
 U.Track=D.Text(U.Root,'Escolha uma música ou informe o ID.',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,ZIndex=11,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
 U.ID=D.Box(U.Root,'ID ou link de áudio Roblox',{TextSize=13,ZIndex=11});U.Load=D.Button(U.Root,'Carregar',{TextSize=12,ZIndex=12})
 U.Play=D.Button(U.Root,'▶',{TextSize=20,ZIndex=12});U.Reload=D.Button(U.Root,'↻',{TextSize=22,ZIndex=12});U.Keep=D.Button(U.Root,'Salvar música',{TextSize=12,ZIndex=12})
 U.Minus=D.Button(U.Root,'−',{TextSize=22,ZIndex=12});U.Volume=D.Button(U.Root,'40% • silenciar',{TextSize=12,ZIndex=12});U.Plus=D.Button(U.Root,'+',{TextSize=22,ZIndex=12})
 U.List=D.Scroll(U.Root,{Name='SavedMusic',ZIndex=11,ScrollBarThickness=3});D.New('UIListLayout',{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},U.List)
 U.Status=D.Text(U.Root,'Som pessoal • volume independente',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
 local safe=Bounds.Bind(U.Gui)
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local short=h-it-ib<290 and w-il-ir>=480
  local rw=math.min(short and 620 or 420,w-il-ir-12);local rh=math.min(short and 232 or 390,h-it-ib-12);local packed=rh<310
  Bounds.Rect(U.Root,w-ir-rw-6,it+6,rw,rh)
  Bounds.Rect(U.Track,8,52,rw-16,24);Bounds.Rect(U.ID,8,80,rw-108,44);Bounds.Rect(U.Load,rw-94,80,86,44)
  Bounds.Rect(U.Play,8,130,44,44);Bounds.Rect(U.Reload,58,130,44,44);Bounds.Rect(U.Keep,108,130,rw-116,44)
  Bounds.Rect(U.Minus,8,180,44,44);Bounds.Rect(U.Plus,rw-52,180,44,44);Bounds.Rect(U.Volume,58,180,rw-116,44)
  Bounds.Rect(U.List,8,230,rw-16,math.max(1,rh-266));Bounds.Rect(U.Status,8,rh-30,rw-16,26)
  if packed then
   U.Title.TextSize=16;Bounds.Rect(U.Track,8,52,rw-16,18);Bounds.Rect(U.ID,8,72,rw-108,44);Bounds.Rect(U.Load,rw-94,72,86,44)
   Bounds.Rect(U.Play,8,122,44,44);Bounds.Rect(U.Reload,58,122,44,44);Bounds.Rect(U.Keep,108,122,rw-116,44)
   Bounds.Rect(U.Minus,8,172,44,44);Bounds.Rect(U.Plus,rw-52,172,44,44);Bounds.Rect(U.Volume,58,172,rw-116,44)
   Bounds.Rect(U.List,8,222,rw-16,math.max(1,rh-254));Bounds.Rect(U.Status,8,rh-28,rw-16,24)
  end
  if short then
   local left=math.floor((rw-22)*.56);local right=rw-left-22;local x=left+14
   Bounds.Rect(U.Track,x,8,right-52,36)
   Bounds.Rect(U.ID,8,58,left-98,44);Bounds.Rect(U.Load,left-84,58,84,44)
   Bounds.Rect(U.Play,8,108,44,44);Bounds.Rect(U.Reload,58,108,44,44);Bounds.Rect(U.Keep,108,108,left-108,44)
   Bounds.Rect(U.Minus,x,58,44,44);Bounds.Rect(U.Plus,rw-52,58,44,44);Bounds.Rect(U.Volume,x+50,58,right-100,44)
   Bounds.Rect(U.List,x,108,right,math.max(1,rh-142));Bounds.Rect(U.Status,8,rh-28,rw-16,24)
  end
 end
 safe.Watch(U.Layout);return U
end
return M
