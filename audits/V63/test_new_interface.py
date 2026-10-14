from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
case('music_all_named_actions_fit_safe_popup_and_library',THEME+module('07M1_MUSIC_UI')+r'''
local u=Modules['07M1_MUSIC_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout()
 inside(u.Root,u.Gui)
 for _,b in ipairs({u.Close,u.Minimize,u.Favorites,u.Mute,u.Load,u.Reload,u.Play,u.Previous,u.Next,u.Keep,u.Enqueue,u.DiscoverTab,u.QueueTab,u.SavedTab,u.Search,u.More})do
  inside(b,b.Parent);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,b.Name..':'..b.AbsoluteSize.X)
 end
 assert(not intersects(u.Play,u.Keep)and not intersects(u.Next,u.Keep)and not intersects(u.VolumeSlider.Root,u.Seek.Root))
 assert(u.Library.Visible and u.List.AbsoluteSize.Y>=44)
end
u.Minimize.Activated:Fire();assert(u.Mini and not u.Content.Visible);u.Minimize.Activated:Fire();assert(not u.Mini)
return 'six safe geometries keep every transport, save, queue, search and library control clickable without fullscreen, overlaps or an empty library pane'
''')
case('destinations_only_own_seed_publish_preview_join_and_saved_preferences',THEME+module('09C12_DESTINATION_BROWSER')+r'''
local D=Modules['07UI_DESIGN_SYSTEM'];local area=D.New('Frame',{Size=UDim2.fromScale(1,1)},pg);local actions={};local submitted=false
local function api(a,d)
 actions[#actions+1]={a=a,d=d}
 if a=='DestinationFeed'then return{items={{key=d.kind..':91',permanent=true,item={Id=91,ItemType=d.kind,Name='Verified destination',description='Native details',image='rbxassetid://501'}}},finished=true}
 elseif a=='DestinationCheck'then return{Id=tonumber(d.id),ItemType=d.kind,Name='Validated',description='Native validated details',image='rbxassetid://501'}
 elseif a=='DestinationStatus'then return{nextAllowed=TIME60}
 elseif a=='DestinationReaction'then return{value=d.value}
 elseif a=='DestinationSubmit'then submitted=true;return{ready=true}
 elseif a=='DestinationPlay'then return d.confirm and{teleporting=true}or{confirm=true,name='Game',id=d.id}end
end
local u=Modules['09C12_DESTINATION_BROWSER'].Build(area,{call=api,toast=function()end});u.Open('Game');flush()
assert(#u.Items==1 and not u.Items[1].temporary);named(area,'Destination_91').Activated:Fire();flush();assert(named(area,'DestinationShade').Visible)
named(area,'NativeDestinationAction').Activated:Fire();flush();assert(named(area,'NativeDestinationAction').Text=='Entrar agora')
named(area,'CloseDestination').Activated:Fire();u.Open('Community');flush();named(area,'Destination_91').Activated:Fire();flush()
named(area,'NativeDestinationAction').Activated:Fire();flush();assert(GroupPrompt63==91)
named(area,'CloseDestination').Activated:Fire();u.Publish.Activated:Fire();flush();named(area,'DestinationID').Text='https://www.roblox.com/communities/92';named(area,'DestinationID').GetPropertyChangedSignal(named(area,'DestinationID'),'Text'):Fire()
local check;for _,v in ipairs(named(area,'DestinationDetails'):GetChildren())do if v.Text=='Conferir'then check=v end end;check.Activated:Fire();flush()
local publish;for _,v in ipairs(named(area,'DestinationDetails'):GetChildren())do if v.Text=='Publicar 24 h grátis'then publish=v end end;assert(publish.Active);publish.Activated:Fire();flush();assert(submitted)
return 'actual browser previews native data, requires a second explicit game entry click, opens the native group prompt and validates a link before publishing; no temporary destinations are fabricated'
''')
case('assistant_keyboard_retry_and_menu_keep_composer_clear',THEME+module('09I4_ASSISTANT_UI')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 u.Health('Normal',false,false)
 for _,b in ipairs({u.Connection,u.Send,u.Menu,u.Close})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 assert(not intersects(u.Send,u.Connection));assert(not intersects(u.Input,u.Connection));assert(not intersects(u.Sponsor,u.Close))
 u.Menu.Activated:Fire();assert(u.Tabs.Visible);u.Menu.Activated:Fire()
end
u.Health('Normal',true,false);local block=u.Add('Look testado',true);assert(block and not u.Welcome.Visible);u.ClearConversation();assert(u.Welcome.Visible)
return 'connection recovery, sidebar, message composer and chat reset stay usable across portrait/landscape/desktop without version-label gates or input overlap'
''')
HERE.joinpath('new_interface_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
