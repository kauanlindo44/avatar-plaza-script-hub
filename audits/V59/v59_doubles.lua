-- Known-failure fixtures and observations. Never executes the Roblox service.
NativeCalls59={}
CreatedGenerators59={}
Services.Workspace=workspace
local construct59=Instance.new
Instance.new=function(kind)
 local o=construct59(kind)
 if kind=='TextGenerator'then
  CreatedGenerators59[#CreatedGenerators59+1]=o
  local old=o.GenerateTextAsync
  function o:GenerateTextAsync(r)
   local reference=self.SystemPrompt=='You are a helpful NPC in a virtual world.'
   NativeCalls59[#NativeCalls59+1]={request=deep(r),system=self.SystemPrompt,parent=self.Parent,temperature=self.Temperature,topP=self.TopP,seed=self.Seed,instance=self,reference=reference}
   if RejectLegacyFormat59 and(self.SystemPrompt:find('Brazilian Portuguese',1,true)or self.SystemPrompt:find('Prefer a JSON',1,true))then error('HTTP 400 incompatible output instruction fixture')end
   if FailAssistant59 and not reference then error('HTTP 400 (Bad Request) assistant fixture')end
   if FailReference59 and reference then error('HTTP 400 (Bad Request) reference fixture')end
   if BadResponse59 then return BadResponse59 end
   local r=old(self,r);r.GeneratedText=AIText59 or r.GeneratedText;r.Model='native fixture, not Roblox';return r
  end
 end;return o
end
