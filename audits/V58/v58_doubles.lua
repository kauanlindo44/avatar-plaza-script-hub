-- Deterministic transport/audio doubles, not actual Roblox services.
local construct58=Instance.new
Instance.new=function(kind)
 local o=construct58(kind)
 if kind=='Sound'then o.TimePosition=0;o.TimeLength=120;o.Ended=Signal();o.Loaded=Signal()
 elseif kind=='TextGenerator'then
  function o:GenerateTextAsync(r)
   LastAISystem=self.SystemPrompt;LastAIRequest=deep(r)
   if RejectUnicode58 then assert(not r.UserPrompt:find('[\128-\255]'),'HTTP 400 non ASCII user prompt');assert(not self.SystemPrompt:find('[\128-\255]'),'HTTP 400 non ASCII instructions')end
   if FailAI then error('HTTP 400 (Bad Request) native fixture')end
   return {GeneratedText=AIText58 or'fixture',ContextToken='not-stored'}
  end
 end;return o
end
