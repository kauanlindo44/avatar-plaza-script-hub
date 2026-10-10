-- Missing surface capabilities in deterministic doubles; no native Roblox testing.
function pl:FindFirstChild(name)if name=='PlayerGui'then return pg end end
table.clone=table.clone or function(t)local c={};for k,v in pairs(t)do c[k]=v end;return c end
Services.TextService.FilterStringAsync=function(_,text)return {GetNonChatStringForBroadcastAsync=function()return text end,GetNonChatStringForUserAsync=function()return text end}end
Services.SoundService=Instance.new('Folder');Services.SoundService.Name='SoundService'
local constructor55=Instance.new
Instance.new=function(class)
 local o=constructor55(class)
 if class=='TextGenerator'then
  function o:GenerateTextAsync(r)if FailAI then error('AI offline')end;LastAIRequest=deep(r);return {GeneratedText='fixture',ContextToken='do-not-store',Model='native-fixture'}end
 elseif class=='Sound'then
  o.SoundId='';o.IsLoaded=false;o.IsPlaying=false;o.Volume=.4
  function o:Play()self.IsPlaying=true end;function o:Stop()self.IsPlaying=false end;function o:Pause()self.IsPlaying=false end;function o:Resume()self.IsPlaying=true end
 end
 return o
end
Services.HttpService.JSONDecode=function(_,s)if s=='fixture'then return {answer='Posso ajudar com estilo de avatar.',keyword='emo'}end;error('bad JSON')end
function pl:IsFriendsWithAsync(id)return Friends55 and Friends55[id]==true end
