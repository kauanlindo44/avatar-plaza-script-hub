-- 07M1_MUSIC_UI | ModuleScript | ReplicatedStorage | V61 (SUBSTITUIR)
-- Player compacto, fila e salvos no mesmo popup; nunca exige tela cheia.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Slider=require(Rep:WaitForChild('07UI_SLIDER'));local M={}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Music');if old then old:Destroy()end
 local U={SavedOpen=true,Page='Descobrir',Mini=false};U.Gui=D.New('ScreenGui',{Name='ACP_Music',ResetOnSpawn=false,DisplayOrder=190,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.Frame(U.Gui,{Name='MusicPopup',Visible=false,BackgroundColor3=C.panel,ZIndex=10})
 U.Title=D.Text(U.Root,'Sua música',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=19,Font=Enum.Font.GothamBold,ZIndex=11})
 U.Close=D.IconButton(U.Root,'CloseMusic','close','Fechar música',{Size=UDim2.fromOffset(48,48),ZIndex=30})
 U.Minimize=D.Button(U.Root,'−',{TextSize=24,ZIndex=12});U.Mute=D.Button(U.Root,'Som',{TextSize=12,ZIndex=12})
 U.Favorites=D.Button(U.Root,'Biblioteca',{TextSize=12,ZIndex=12})
 U.Content=D.New('Frame',{BackgroundTransparency=1,ZIndex=11},U.Root)
 U.Track=D.Text(U.Content,'Carregue um áudio Roblox',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
 U.ID=D.Box(U.Content,'ID ou link de áudio',{TextSize=13});U.Load=D.Button(U.Content,'Carregar',{TextSize=12});U.Reload=D.Button(U.Content,'↻',{TextSize=22});U.Reload:SetAttribute('ActionLabel','Recarregar áudio ou preferências')
 U.Previous=D.Button(U.Content,'‹',{TextSize=24});U.Play=D.Button(U.Content,'Ouvir',{TextSize=13});U.Next=D.Button(U.Content,'›',{TextSize=24});U.Keep=D.Button(U.Content,'Salvar',{TextSize=12});U.Enqueue=D.Button(U.Content,'+ Fila',{TextSize=12})
 U.Seek=Slider.Build(U.Content,'0:00 / 0:00',function(v)if U.OnSeek then U.OnSeek(v)end end,function(v)if U.OnSeekEnd then U.OnSeekEnd(v)end end);U.Seek.Enable(false)
 U.VolumeSlider=Slider.Build(U.Content,'Volume 40%',function(v)if U.OnVolume then U.OnVolume(v)end end,function()if U.OnVolumeEnd then U.OnVolumeEnd()end end)
 U.Status=D.Text(U.Root,'Som pessoal • volume independente',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
 U.Library=D.New('Frame',{BackgroundTransparency=1,Visible=false,ZIndex=11},U.Root)
 U.SavedTab=D.Button(U.Library,'Salvos',{TextSize=12});U.QueueTab=D.Button(U.Library,'Fila',{TextSize=12});U.DiscoverTab=D.Button(U.Library,'Descobrir',{TextSize=12});U.Search=D.Button(U.Library,'Buscar',{TextSize=11});U.More=D.Button(U.Library,'Mais',{TextSize=11})
 U.Filter=D.Box(U.Library,'Procurar nome ou ID',{TextSize=12});U.List=D.Scroll(U.Library,{Name='MusicLibrary',ScrollBarThickness=3});D.New('UIListLayout',{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},U.List)
 local safe=Bounds.Bind(U.Gui)
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local ah=h-it-ib;local short=ah<340 and aw>=550
  local dual=U.SavedOpen and aw>=550 and not U.Mini
  local rw=math.min(U.Mini and 396 or dual and 760 or short and 580 or 408,aw-12)
  local rh=math.min(U.Mini and 64 or short and 260 or U.SavedOpen and 530 or 326,ah-12)
  Bounds.Rect(U.Root,w-ir-rw-6,it+6,rw,rh)
  Bounds.Rect(U.Close,rw-54,4,48,48);Bounds.Rect(U.Minimize,rw-102,6,44,44);Bounds.Rect(U.Mute,rw-150,6,44,44)
  Bounds.Rect(U.Favorites,rw-246,6,90,44);Bounds.Rect(U.Title,10,4,math.max(38,rw-262),44)
  U.Minimize.Text=U.Mini and'+'or'−';U.Favorites.Text=U.SavedOpen and'Fechar lista'or'Biblioteca'
  U.Content.Visible=not U.Mini;U.Library.Visible=U.SavedOpen and not U.Mini;U.Status.Visible=not U.Mini
  local cw=dual and math.floor(rw*.5)-12 or rw-16;Bounds.Rect(U.Content,8,52,cw,rh-80)
  U.Track.Visible=not short
  local y=short and 0 or 24
  Bounds.Rect(U.Track,0,0,cw,20);Bounds.Rect(U.ID,0,y,cw-132,44);Bounds.Rect(U.Load,cw-126,y,76,44);Bounds.Rect(U.Reload,cw-44,y,44,44)
  local bw=(cw-104-12)/3;local transport=y+50
  Bounds.Rect(U.Previous,0,transport,44,44);Bounds.Rect(U.Play,50,transport,bw,44);Bounds.Rect(U.Next,56+bw,transport,44,44)
  Bounds.Rect(U.Keep,106+bw,transport,bw,44);Bounds.Rect(U.Enqueue,112+2*bw,transport,bw,44)
  if short then Bounds.Rect(U.Seek.Root,0,transport+50,cw*.52-3,44);Bounds.Rect(U.VolumeSlider.Root,cw*.52+3,transport+50,cw*.48-3,44)
  else Bounds.Rect(U.Seek.Root,0,transport+50,cw,44);Bounds.Rect(U.VolumeSlider.Root,0,transport+98,cw,44)end
  Bounds.Rect(U.Status,8,rh-24,rw-16,22)
  local lx=dual and cw+22 or 8;local lw=dual and rw-lx-8 or rw-16;local ly=dual and 52 or 274;local lh=rh-ly-30
  if U.SavedOpen and not dual then Bounds.Rect(U.Content,8,52,cw,216)end
  Bounds.Rect(U.Library,lx,ly,lw,lh);local tw=(lw-12)/3;Bounds.Rect(U.DiscoverTab,0,0,tw,44);Bounds.Rect(U.QueueTab,tw+6,0,tw,44);Bounds.Rect(U.SavedTab,(tw+6)*2,0,tw,44)
  Bounds.Rect(U.Filter,0,50,lw-100,44);Bounds.Rect(U.Search,lw-94,50,44,44);Bounds.Rect(U.More,lw-44,50,44,44);Bounds.Rect(U.List,0,100,lw,math.max(44,lh-100))
  U.DiscoverTab.BackgroundColor3=U.Page=='Descobrir'and C.soft or C.card;U.Search.Visible=U.Page=='Descobrir';U.More.Visible=U.Page=='Descobrir';U.Filter.PlaceholderText=U.Page=='Descobrir'and'Buscar música no Roblox'or'Filtrar nome ou ID'
  U.SavedTab.BackgroundColor3=U.Page=='Salvos'and C.soft or C.card;U.QueueTab.BackgroundColor3=U.Page=='Fila'and C.soft or C.card
 end
 U.Favorites.Activated:Connect(function()U.SavedOpen=not U.SavedOpen;U.Mini=false;U.Layout();if U.OnLibrary then U.OnLibrary()end end)
 U.Minimize.Activated:Connect(function()U.Mini=not U.Mini;U.Layout()end)
 for _,entry in ipairs({{U.DiscoverTab,'Descobrir'},{U.SavedTab,'Salvos'},{U.QueueTab,'Fila'}})do entry[1].Activated:Connect(function()U.Page=entry[2];U.Layout();if U.OnLibrary then U.OnLibrary()end end)end
 safe.Watch(U.Layout);return U
end
return M
