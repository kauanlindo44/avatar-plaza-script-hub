-- Native-contract doubles. No engine rendering, real assets, age bypass or payments.
local close61={};function game:BindToClose(fn)close61[#close61+1]=fn end
Services.MessagingService={PublishAsync=function(_,topic,value)LastPublication61={topic=topic,value=value}end,SubscribeAsync=function(_,topic,fn)return{Disconnect=function()end}end}
Services.TextChatService=Instance.new('Folder')
local ctor61=Instance.new
Instance.new=function(class,parent)
 local o=ctor61(class);if parent then o.Parent=parent end
 if class=='RemoteEvent'then o.OnServerEvent=o.OnServerEvent or Signal()end
 if class=='TextChatCommand'then o.Triggered=Signal()end
 if class=='Sound'then
  o.SoundId='';o.IsLoaded=true;o.IsPlaying=false;o.TimeLength=120;o.TimePosition=0;o.Ended=Signal()
  function o:Stop()self.IsPlaying=false end;function o:Play()self.IsPlaying=true end
  function o:Pause()self.IsPlaying=false end;function o:Resume()self.IsPlaying=true end
 end
 if class=='Humanoid'then o.Seated=o.Seated or Signal()end
 return o
end
Services.SoundService=Instance.new('Folder');Services.RunService.PreSimulation=Signal()
local kit61=Instance.new('Folder');kit61.Name='PracaKit';kit61.Parent=rep
local rem61=Instance.new('Folder');rem61.Name='Remotes';rem61.Parent=kit61
local command61=Instance.new('RemoteEvent');command61.Name='PersonalCommand';command61.Parent=rem61
local shop61=Instance.new('Folder');shop61.Name='LMShop_Remotes';shop61.Parent=rep
local change61=Instance.new('RemoteEvent');change61.Name='HighlightChanged';change61.Parent=shop61
function methods:FireAllClients(...)self.sent=self.sent or{};self.sent[#self.sent+1]={all=true,args={...}}end
local ordered61=Services.DataStoreService.GetOrderedDataStore
function Services.DataStoreService:GetOrderedDataStore(name)
 local s=ordered61(self,name)
 function s:GetSortedAsync(asc,size)
  if FailStores then error('storage unavailable')end
  local rows={};for k,v in pairs(StoreData[name])do rows[#rows+1]={key=k,value=v}end
  table.sort(rows,function(a,b)return asc and a.value<b.value or not asc and a.value>b.value end)
  local index=1;local p={IsFinished=#rows<=size}
  function p:GetCurrentPage()local out={};for i=index,math.min(#rows,index+size-1)do out[#out+1]=deep(rows[i])end;return out end
  function p:AdvanceToNextPageAsync()index=index+size;self.IsFinished=index+size-1>=#rows end
  return p
 end;return s
end
Audio61={};AudioCalls61=0;AudioSearch61={}
function Services.AssetService:SearchAudioAsync(params)
 if FailAudio61 then error('audio search unavailable')end
 assert(params.AudioSubType==Enum.AudioSubType.Music and(params.SearchKeyword~='lofi'or params.MinDuration==45))
 AudioCalls61=AudioCalls61+1;AudioSearch61[#AudioSearch61+1]=params.SearchKeyword
 local i=1;local p={IsFinished=#Audio61<=1}
 function p:GetCurrentPage()return deep(Audio61[i]or{})end
 function p:AdvanceToNextPageAsync()i=i+1;self.IsFinished=i>=#Audio61 end;return p
end
Friends61={}
function Services.Players:GetFriendsAsync(id)
 local pages=Friends61[id]or{{}};local i=1;local p={IsFinished=#pages<=1}
 function p:GetCurrentPage()return deep(pages[i])end
 function p:AdvanceToNextPageAsync()i=i+1;self.IsFinished=i>=#pages end;return p
end
