-- 07M1_MUSIC_UI | ModuleScript | ReplicatedStorage | V56
-- Player pequeno; os favoritos abrem no mesmo popup, sem painel vazio.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Music');if old then old:Destroy()end
 local U={SavedOpen=false};U.Gui=D.New('ScreenGui',{Name='ACP_Music',ResetOnSpawn=false,DisplayOrder=190,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.Frame(U.Gui,{Name='MusicPopup',Visible=false,BackgroundColor3=C.panel,ZIndex=10})
 U.Title=D.Text(U.Root,'Sua música',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=20,Font=Enum.Font.GothamBold,ZIndex=11})
 U.Close=D.IconButton(U.Root,'CloseMusic','close','Fechar música',{Size=UDim2.fromOffset(48,48),ZIndex=30})
 U.Track=D.Text(U.Root,'Informe um áudio para começar.',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,ZIndex=11,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
 U.ID=D.Box(U.Root,'ID ou link de áudio Roblox',{TextSize=13,ZIndex=11});U.Load=D.Button(U.Root,'Carregar',{TextSize=12,ZIndex=12})
 U.Play=D.Button(U.Root,'Ouvir',{TextSize=13,ZIndex=12});U.Reload=D.Button(U.Root,'Recarregar',{TextSize=12,ZIndex=12});U.Keep=D.Button(U.Root,'Salvar',{TextSize=12,ZIndex=12})
 U.Minus=D.Button(U.Root,'−',{TextSize=22,ZIndex=12});U.Volume=D.Button(U.Root,'40% • silenciar',{TextSize=12,ZIndex=12});U.Plus=D.Button(U.Root,'+',{TextSize=22,ZIndex=12})
 U.Favorites=D.Button(U.Root,'Salvos',{TextSize=12,ZIndex=12})
 U.List=D.Scroll(U.Root,{Name='SavedMusic',Visible=false,ZIndex=11,ScrollBarThickness=3});D.New('UIListLayout',{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},U.List)
 U.Status=D.Text(U.Root,'Som pessoal • volume independente',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
 local safe=Bounds.Bind(U.Gui)
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local ah=h-it-ib;local short=ah<330 and aw>=500
  local rw=math.min(short and 560 or 396,aw-12);local rh=math.min(U.SavedOpen and not short and 370 or short and 224 or 260,ah-12)
  Bounds.Rect(U.Root,w-ir-rw-6,it+6,rw,rh);Bounds.Rect(U.Title,10,4,rw-72,44);Bounds.Rect(U.Close,rw-54,4,48,48)
  Bounds.Rect(U.Track,8,52,rw-16,22)
  if short then
   local left=U.SavedOpen and math.floor((rw-24)*.60)or rw-16;local x=left+16;local right=rw-x-8
   Bounds.Rect(U.ID,8,78,left-92,44);Bounds.Rect(U.Load,left-78,78,86,44)
   local cw=(left-12)/3
   for i,b in ipairs({U.Play,U.Reload,U.Keep})do Bounds.Rect(b,8+(i-1)*(cw+6),128,cw,44)end
   Bounds.Rect(U.Minus,8,178,44,44);Bounds.Rect(U.Plus,left-36,178,44,44)
   Bounds.Rect(U.Volume,58,178,math.max(44,left-150),44);Bounds.Rect(U.Favorites,U.SavedOpen and left-86 or rw-144,4,88,44)
   U.Title.Size=UDim2.fromOffset(U.SavedOpen and left-106 or rw-162,44)
   Bounds.Rect(U.List,x,78,right,rh-86);Bounds.Rect(U.Status,x,4,math.max(44,right-48),68)
   if not U.SavedOpen then Bounds.Rect(U.Track,8,52,rw*.40,22);Bounds.Rect(U.Status,rw*.40+16,50,rw*.60-24,26)end
   U.Status.Visible=true
  else
   Bounds.Rect(U.ID,8,78,rw-108,44);Bounds.Rect(U.Load,rw-94,78,86,44)
   local cw=(rw-28)/3
   for i,b in ipairs({U.Play,U.Reload,U.Keep})do Bounds.Rect(b,8+(i-1)*(cw+6),128,cw,44)end
   Bounds.Rect(U.Minus,8,178,44,44);Bounds.Rect(U.Plus,rw-52,178,44,44);Bounds.Rect(U.Volume,58,178,rw-116,44)
   Bounds.Rect(U.Favorites,rw-144,4,86,44);Bounds.Rect(U.Title,10,4,rw-162,44)
   Bounds.Rect(U.List,8,228,rw-16,math.max(1,rh-264));Bounds.Rect(U.Status,8,rh-32,rw-16,28);U.Status.Visible=true
  end
  U.List.Visible=U.SavedOpen;U.Favorites.Text=U.SavedOpen and'Voltar'or'Salvos'
 end
 U.Favorites.Activated:Connect(function()U.SavedOpen=not U.SavedOpen;U.Layout()end)
 safe.Watch(U.Layout);return U
end
return M
