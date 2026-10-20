-- 07M1_MUSIC_UI | ModuleScript | ReplicatedStorage | V72 (SUBSTITUIR)
-- Player compacto; biblioteca e ID/link aparecem por escolha, sem tomar a tela toda.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Slider=require(Rep:WaitForChild('07UI_SLIDER'));local M={Version='V72'}
function M.Build(pl)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Music');if old then old:Destroy()end
 local U={SavedOpen=false,Page='Descobrir',Mini=false,Advanced=false}
 U.Gui=D.New('ScreenGui',{Name='ACP_Music',ResetOnSpawn=false,DisplayOrder=190,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.Frame(U.Gui,{Name='MusicPopup',Visible=false,BackgroundColor3=C.panel,ZIndex=10});D.Stroke(U.Root,C.line,.2)
 U.Title=D.Text(U.Root,'Música',{TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,ZIndex=11})
 U.Close=D.IconButton(U.Root,'CloseMusic','close','Fechar música',{ZIndex=30});U.Minimize=D.Button(U.Root,'−',{TextSize=24,ZIndex=12})
 U.Favorites=D.Button(U.Root,'Biblioteca',{TextSize=13,ZIndex=12});U.Mute=D.Button(U.Root,'Som',{TextSize=13,ZIndex=12})
 U.Source=D.Button(U.Root,'ID / link',{Name='OpenAudioSource',TextSize=13,ZIndex=12})
 U.Content=D.Scroll(U.Root,{Name='MusicPlayerControls',ZIndex=11,AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=2})
 U.Art=D.Frame(U.Content,{Name='NowPlayingArtwork',BackgroundColor3=Color3.fromRGB(81,67,100)});D.Icon(U.Art,'music',{Position=UDim2.fromScale(.2,.2),Size=UDim2.fromScale(.6,.6)})
 U.PlayerLabel=D.Text(U.Content,'TOCANDO AGORA',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Track=D.Text(U.Content,'Som da praça · bossa lounge',{TextSize=15,Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Left})
 U.ID=D.Box(U.Content,'ID ou link de áudio Roblox',{TextSize=14});U.Load=D.Button(U.Content,'Carregar',{TextSize=13})
 U.Reload=D.IconButton(U.Content,'ReloadAudio','reset','Recarregar áudio ou preferências')
 U.Previous=D.Button(U.Content,'‹',{TextSize=25});U.Play=D.Button(U.Content,'Ouvir',{TextSize=14,BackgroundColor3=C.orange,TextColor3=C.ink});U.Next=D.Button(U.Content,'›',{TextSize=25})
 U.Keep=D.Button(U.Content,'Salvar',{TextSize=13});U.Enqueue=D.Button(U.Content,'+ Fila',{TextSize=13})
 U.Seek=Slider.Build(U.Content,'0:00 / 0:00',function(v)if U.OnSeek then U.OnSeek(v)end end,function(v)if U.OnSeekEnd then U.OnSeekEnd(v)end end);U.Seek.Enable(false)
 U.VolumeSlider=Slider.Build(U.Content,'Volume 40%',function(v)if U.OnVolume then U.OnVolume(v)end end,function()if U.OnVolumeEnd then U.OnVolumeEnd()end end)
 U.Status=D.Text(U.Root,'Seu som · volume pessoal',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=11})
 U.Library=D.New('Frame',{Name='MusicLibraryPane',BackgroundTransparency=1,Visible=false,ZIndex=11},U.Root)
 U.SavedTab=D.Button(U.Library,'Salvos',{TextSize=13});U.QueueTab=D.Button(U.Library,'Fila',{TextSize=13});U.DiscoverTab=D.Button(U.Library,'Descobrir',{TextSize=13})
 U.Search=D.IconButton(U.Library,'SearchAudio','search','Pesquisar músicas');U.More=D.Button(U.Library,'Mais',{TextSize=13});U.Filter=D.Box(U.Library,'Buscar músicas',{TextSize=14})
 U.List=D.Scroll(U.Library,{Name='MusicLibrary',ScrollBarThickness=3});D.New('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},U.List)
 local safe=B.Bind(U.Gui)
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw,ah=w-il-ir,h-it-ib;if aw<1 or ah<1 then return end
  local landscape=w>h and ah<400;local libraryOnly=U.SavedOpen and landscape and aw<640 and not U.Mini;local dual=U.SavedOpen and landscape and aw>=640 and not U.Mini
  local rw=math.min(U.Mini and 390 or dual and 640 or 380,aw-12)
  local desired=U.Mini and 64 or U.SavedOpen and 558 or U.Advanced and 340 or 254
  local rh=math.min(desired,ah-12);B.Rect(U.Root,w-ir-rw-6,it+6,rw,rh)
  B.Rect(U.Close,rw-50,6,44,44);B.Rect(U.Minimize,rw-98,6,44,44);B.Rect(U.Favorites,rw-196,6,92,44);B.Rect(U.Title,10,6,math.max(44,rw-212),44)
  U.Favorites.Visible=not U.Mini;U.Source.Visible=not U.Mini;U.Mute.Visible=not U.Mini;U.Content.Visible=not U.Mini;U.Status.Visible=not U.Mini
  U.Library.Visible=U.SavedOpen and not U.Mini;U.Content.Visible=not U.Mini and not libraryOnly;U.Minimize.Text=U.Mini and'+'or'−';U.Favorites.Text=U.SavedOpen and'Player'or'Biblioteca'
  U.Play.Parent=U.Mini and U.Root or U.Content
  if U.Mini then
   U.Title.Text=U.Track.Text;B.Rect(U.Title,10,8,rw-164,44);B.Rect(U.Play,rw-148,8,44,44);return
  end
  U.Title.Text='Música';local cw=dual and 276 or rw-20;local contentH=U.Advanced and 238 or 188
  if U.SavedOpen and not dual and rh<420 then contentH=94 end
  B.Rect(U.Content,10,56,cw,math.min(contentH,math.max(44,rh-96)));U.Content.CanvasSize=UDim2.fromOffset(0,contentH)
  local full=contentH>100;U.Art.Visible=full;U.PlayerLabel.Visible=full
  B.Rect(U.Art,0,0,42,42);B.Rect(U.PlayerLabel,52,0,cw-52,16);B.Rect(U.Track,full and 52 or 0,full and 17 or 0,full and cw-52 or cw,full and 26 or 36)
  local ty=full and 48 or 44;local bw=(cw-24)/5
  for i,b in ipairs({U.Previous,U.Play,U.Next,U.Keep,U.Enqueue})do B.Rect(b,(i-1)*(bw+6),ty,bw,44)end
  U.Seek.Root.Visible=full;U.VolumeSlider.Root.Visible=full
  B.Rect(U.Seek.Root,0,98,(cw-8)/2,44);B.Rect(U.VolumeSlider.Root,(cw+8)/2,98,(cw-8)/2,44)
  U.ID.Visible=U.Advanced and full;U.Load.Visible=U.ID.Visible;U.Reload.Visible=U.ID.Visible
  B.Rect(U.ID,0,146,cw-132,44);B.Rect(U.Load,cw-126,146,76,44);B.Rect(U.Reload,cw-44,146,44,44)
  B.Rect(U.Source,10,rh-42,92,32);U.Source.Size=UDim2.fromOffset(92,44);U.Source.Position=UDim2.fromOffset(10,rh-48)
  B.Rect(U.Mute,108,rh-48,58,44);B.Rect(U.Status,172,rh-44,math.max(20,rw-182),36)
  local lx=dual and cw+22 or 10;local ly=libraryOnly and 52 or dual and 56 or 62+math.min(contentH,math.max(44,rh-96));local lw=rw-lx-10;local lh=math.max(0,rh-ly-(libraryOnly and 48 or 54))
  B.Rect(U.Library,lx,ly,lw,lh);local tw=(lw-12)/3
  for i,b in ipairs({U.DiscoverTab,U.QueueTab,U.SavedTab})do B.Rect(b,(i-1)*(tw+6),0,tw,44)end
  B.Rect(U.Filter,0,50,lw-100,44);B.Rect(U.Search,lw-94,50,44,44);B.Rect(U.More,lw-44,50,44,44);B.Rect(U.List,0,100,lw,math.max(0,lh-100))
  U.Search.Visible=U.Page=='Descobrir';U.More.Visible=U.Search.Visible;U.Filter.PlaceholderText=U.Page=='Descobrir'and'Buscar músicas no Roblox'or'Filtrar nome ou ID'
  for key,b in pairs({Descobrir=U.DiscoverTab,Fila=U.QueueTab,Salvos=U.SavedTab})do b.BackgroundColor3=U.Page==key and Color3.fromRGB(87,65,119)or C.card end
 end
 U.Source.Activated:Connect(function()U.Advanced=not U.Advanced;U.SavedOpen=false;U.Layout()end)
 U.Favorites.Activated:Connect(function()U.SavedOpen=not U.SavedOpen;U.Mini=false;U.Layout();if U.OnLibrary then U.OnLibrary()end end)
 U.Minimize.Activated:Connect(function()U.Mini=not U.Mini;U.Layout()end)
 for _,entry in ipairs({{U.DiscoverTab,'Descobrir'},{U.SavedTab,'Salvos'},{U.QueueTab,'Fila'}})do entry[1].Activated:Connect(function()U.Page=entry[2];U.Layout();if U.OnLibrary then U.OnLibrary()end end)end
 safe.Watch(U.Layout);return U
end
return M
