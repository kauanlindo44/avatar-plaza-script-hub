-- 07M1_MUSIC_UI | ModuleScript | ReplicatedStorage | V69 (SUBSTITUIR)
-- Player flutuante, biblioteca visível e controles nomeados; tamanho limitado à área segura.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Slider=require(Rep:WaitForChild('07UI_SLIDER'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local M={Version='V69'}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Music');if old then old:Destroy()end
 local U={SavedOpen=true,Page='Descobrir',Mini=false};U.Gui=D.New('ScreenGui',{Name='ACP_Music',ResetOnSpawn=false,DisplayOrder=190,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.Frame(U.Gui,{Name='MusicPopup',Visible=false,BackgroundColor3=C.panel,ZIndex=10});Fx.Surface(U.Root,Color3.fromRGB(232,229,244),Color3.fromRGB(232,229,244),C.purple)
 U.Title=D.Text(U.Root,'Música',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=22,Font=Enum.Font.GothamBold,ZIndex=11})
 U.Close=D.IconButton(U.Root,'CloseMusic','close','Fechar música',{ZIndex=30})
 U.Minimize=D.Button(U.Root,'−',{TextSize=24,ZIndex=12});U.Mute=D.Button(U.Root,'Som',{TextSize=12,ZIndex=12})
 U.Favorites=D.Button(U.Root,'Biblioteca',{TextSize=12,ZIndex=12})
 U.Content=D.Scroll(U.Root,{Name='MusicPlayerControls',ZIndex=11,AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=2})
 U.Art=D.Frame(U.Content,{Name='NowPlayingArtwork',BackgroundColor3=Color3.fromRGB(232,229,244)});Fx.Surface(U.Art,Color3.fromRGB(232,229,244),Color3.fromRGB(151,80,45),C.orange)
 D.Icon(U.Art,'music',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.65,.65),IconColor=C.white})
 U.PlayerLabel=D.Text(U.Content,'TOCANDO AGORA',{TextSize=10,TextColor3=C.purple,TextXAlignment=Enum.TextXAlignment.Left})
 U.Track=D.Text(U.Content,'Escolha uma música da biblioteca',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=15,Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
 U.ID=D.Box(U.Content,'Cole ID ou link de áudio Roblox',{TextSize=13});U.Load=D.Button(U.Content,'Carregar',{TextSize=12,BackgroundColor3=Color3.fromRGB(247,228,209)})
 U.Load.BackgroundColor3=Color3.fromRGB(247,228,209)
 U.Reload=D.IconButton(U.Content,'ReloadAudio','reset','Recarregar áudio ou preferências')
 U.Previous=D.Button(U.Content,'‹',{TextSize=24});U.Play=D.Button(U.Content,'Ouvir',{TextSize=13,BackgroundColor3=C.orange,TextColor3=C.bg});U.Next=D.Button(U.Content,'›',{TextSize=24})
 U.Keep=D.Button(U.Content,'Salvar',{TextSize=12});U.Enqueue=D.Button(U.Content,'+ Fila',{TextSize=12})
 U.Seek=Slider.Build(U.Content,'0:00 / 0:00',function(v)if U.OnSeek then U.OnSeek(v)end end,function(v)if U.OnSeekEnd then U.OnSeekEnd(v)end end);U.Seek.Enable(false)
 U.VolumeSlider=Slider.Build(U.Content,'Volume 40%',function(v)if U.OnVolume then U.OnVolume(v)end end,function()if U.OnVolumeEnd then U.OnVolumeEnd()end end)
 U.Status=D.Text(U.Root,'Seu som • volume pessoal',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
 U.Library=D.New('Frame',{Name='MusicLibraryPane',BackgroundTransparency=1,Visible=true,ZIndex=11},U.Root)
 U.SavedTab=D.Button(U.Library,'Salvos',{TextSize=12});U.QueueTab=D.Button(U.Library,'Fila',{TextSize=12});U.DiscoverTab=D.Button(U.Library,'Descobrir',{TextSize=12})
 U.Search=D.IconButton(U.Library,'SearchAudio','search','Pesquisar músicas');U.More=D.Button(U.Library,'Mais',{TextSize=11})
 U.Filter=D.Box(U.Library,'Buscar músicas no Roblox',{TextSize=12});U.List=D.Scroll(U.Library,{Name='MusicLibrary',ScrollBarThickness=3});D.New('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},U.List)
 for _,b in ipairs({U.Load,U.Play,U.Keep,U.Enqueue,U.Favorites,U.Search,U.More})do Fx.Button(b,C.orange)end
 local safe=Bounds.Bind(U.Gui)
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local ah=h-it-ib;if aw<1 or ah<1 then return end
  local dual=U.SavedOpen and aw>=540 and not U.Mini;local rw=math.min(U.Mini and 420 or dual and 940 or 460,aw-12)
  local rh=math.min(U.Mini and 64 or U.SavedOpen and 620 or 380,ah-12);local short=rh<310
  Bounds.Rect(U.Root,il+aw-rw-6,it+6,rw,rh)
  Bounds.Rect(U.Close,rw-54,4,48,48);Bounds.Rect(U.Minimize,rw-102,6,44,44);Bounds.Rect(U.Mute,rw-150,6,44,44)
  Bounds.Rect(U.Favorites,rw-244,6,88,44);Bounds.Rect(U.Title,12,4,math.max(26,rw-262),44);U.Title.TextSize=rw<340 and 16 or 22
  U.Minimize.Text=U.Mini and'+'or'−';U.Favorites.Text=U.SavedOpen and'Só player'or'Biblioteca'
  U.Content.Visible=not U.Mini;U.Library.Visible=U.SavedOpen and not U.Mini;U.Status.Visible=not U.Mini
  local cw=dual and math.max(252,math.min(340,math.floor(rw*.40)))or rw-20;local contentH=U.SavedOpen and not dual and math.min(short and 144 or 216,math.max(100,rh-180))or rh-82
  Bounds.Rect(U.Content,10,56,cw,math.max(0,contentH));local y=short and 36 or 72
  U.Art.Visible=not short;U.PlayerLabel.Visible=not short;U.Track.Visible=true
  Bounds.Rect(U.Art,0,0,60,60);Bounds.Rect(U.PlayerLabel,72,4,cw-76,20);Bounds.Rect(U.Track,short and 0 or 72,short and 0 or 26,short and cw or cw-76,short and 28 or 32)
  Bounds.Rect(U.ID,0,y,cw-132,44);Bounds.Rect(U.Load,cw-126,y,76,44);Bounds.Rect(U.Reload,cw-44,y,44,44)
  local ty=y+50;local playW=(cw-112)/3
  Bounds.Rect(U.Previous,0,ty,44,44);Bounds.Rect(U.Play,50,ty,playW,44);Bounds.Rect(U.Next,56+playW,ty,44,44)
  Bounds.Rect(U.Keep,106+playW,ty,playW,44);Bounds.Rect(U.Enqueue,112+playW*2,ty,playW,44)
  local sy=ty+50;local sliderW=(cw-8)/2;Bounds.Rect(U.Seek.Root,0,sy,sliderW,44);Bounds.Rect(U.VolumeSlider.Root,sliderW+8,sy,sliderW,44)
  U.Content.CanvasSize=UDim2.fromOffset(0,sy+44)
  local lx=dual and cw+22 or 10;local ly=dual and 56 or 62+contentH;local lw=rw-lx-10;local lh=math.max(0,rh-ly-26)
  Bounds.Rect(U.Library,lx,ly,lw,lh);local tw=(lw-12)/3
  for i,b in ipairs({U.DiscoverTab,U.QueueTab,U.SavedTab})do Bounds.Rect(b,(i-1)*(tw+6),0,tw,44)end
  Bounds.Rect(U.Filter,0,50,lw-100,44);Bounds.Rect(U.Search,lw-94,50,44,44);Bounds.Rect(U.More,lw-44,50,44,44)
  Bounds.Rect(U.List,0,100,lw,math.max(0,lh-100));Bounds.Rect(U.Status,10,rh-23,rw-20,20)
  U.Search.Visible=U.Page=='Descobrir';U.More.Visible=U.Page=='Descobrir';U.Filter.PlaceholderText=U.Page=='Descobrir'and'Buscar música no Roblox'or'Filtrar nome ou ID'
  for page,b in pairs({Descobrir=U.DiscoverTab,Fila=U.QueueTab,Salvos=U.SavedTab})do b.BackgroundColor3=U.Page==page and Color3.fromRGB(232,229,244)or C.card end
 end
 U.Favorites.Activated:Connect(function()U.SavedOpen=not U.SavedOpen;U.Mini=false;U.Layout();if U.OnLibrary then U.OnLibrary()end end)
 U.Minimize.Activated:Connect(function()U.Mini=not U.Mini;U.Layout()end)
 for _,entry in ipairs({{U.DiscoverTab,'Descobrir'},{U.SavedTab,'Salvos'},{U.QueueTab,'Fila'}})do entry[1].Activated:Connect(function()U.Page=entry[2];U.Layout();if U.OnLibrary then U.OnLibrary()end end)end
 safe.Watch(U.Layout);return U
end
return M
