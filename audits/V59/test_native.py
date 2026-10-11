from test_support import *
ACCOUNTS=module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')
ENGINE=THEME+ACCOUNTS+module('09I2_ASSISTANT_ENGINE')
AI=THEME+DATA+SERVER+ACCOUNTS+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')
case('full_health_uses_the_actual_plain_english_contract',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];RejectLegacyFormat59=true;RejectUnicode58=true
AIText59='Style emo. Choose a black shirt and simple accessories.'
assert(e.Health());local health=NativeCalls59[1]
assert(health.request.UserPrompt=='Suggest one emo avatar style.'and health.request.MaxTokens==240)
local r,why=e.Ask(pl,'Create an emo avatar look');assert(r,why)
assert(r.answer==AIText59 and r.keyword=='emo'and r.language=='en')
local ask=NativeCalls59[2];assert(ask.system==health.system and ask.request.MaxTokens==health.request.MaxTokens)
assert(ask.parent==workspace and ask.temperature==.8 and ask.topP==.6 and ask.seed==7)
assert(not ask.request.ContextToken and not ask.request.JsonSchema and not ask.request.ResponseFormatType)
assert(not ask.system:find('Brazilian Portuguese',1,true)and not ask.system:find('Prefer a JSON',1,true))
assert(health.instance.Parent==nil and ask.instance.Parent==nil)
return 'real adapter instruction changed, probe uses the same full contract, plain native text is preserved; official valid sampling settings and separate requests'
''')
case('manual_reload_compares_reference_without_overwriting_assistant_state',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];local logs={};warn=function(v)logs[#logs+1]=v end
FailAssistant59=true;AIText59='A simple avatar style.'
assert(not e.Health(true));assert(not e.Available and e.Error=='HTTP 400')
assert(e.Last.mode=='HEALTH'and e.Last.stage=='GENERATE')
assert(e.Reference.ok and e.Reference.mode=='REFERENCE')
local ref=NativeCalls59[2];assert(ref.reference and ref.request.MaxTokens==50 and ref.request.UserPrompt=='Tell me something cool.')
assert(e.Summary()=='REFERÊNCIA OK | ASSISTENTE HTTP 400')
assert(logs[1]:find('modo=HEALTH etapa=GENERATE',1,true)and logs[1]:find('HTTP 400 (Bad Request)',1,true))
advance(13);FailAssistant59=false;assert(e.Health(true));assert(e.Available and not e.Error and e.Summary()=='REFERÊNCIA OK | ASSISTENTE OK')
return 'successful official example cannot conceal a failed real prompt; original error and stage survive; recovery repeats both contracts'
''')
case('failure_of_both_native_contracts_stays_unavailable',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];FailAI=true
assert(not e.Health(true));assert(not e.Available and not e.Reference.ok and e.Error=='HTTP 400')
assert(e.Summary()=='REFERÊNCIA HTTP 400 | ASSISTENTE HTTP 400')
local calls=#NativeCalls59;assert(not e.Health());assert(#NativeCalls59==calls)
local r,why=e.Ask(pl,'Help');assert(not r and why:find('pausa'))
FailAI=false;advance(13);assert(e.Health());assert(e.Ask(pl,'Help'))
return 'two real-service failures remain visible; cached recovery pause avoids retries on every status request; later actual success restores availability'
''')
case('reference_failure_does_not_erase_a_valid_assistant_answer',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];FailReference59=true;AIText59='Style Halloween. Use warm colors.'
assert(e.Health(true));assert(e.Available and not e.Error and not e.Reference.ok)
assert(e.Summary()=='REFERÊNCIA HTTP 400 | ASSISTENTE OK')
assert(e.Ask(pl,'Create a Halloween look').answer==AIText59)
return 'reference diagnostic is independent in both directions; assistant availability requires its own valid response'
''')
case('filtered_transport_removes_unsafe_symbols_but_keeps_the_request',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];AIText59='Style emo. A simple black look.'
local r,why=e.Ask(pl,'Faça um look emo com acessórios & calça, por favor!');assert(r,why)
assert(not LastAIRequest.UserPrompt:find('[\128-\255]')and not LastAIRequest.UserPrompt:find('&',1,true))
assert(LastAIRequest.UserPrompt:find('Faca um look emo com acessorios',1,true))
assert(e.Ascii('Ação À É Ó ü Ç')=='Acao A E O u C')
local calls=#NativeCalls59;assert(not e.Ask(pl,'####'));assert(#NativeCalls59==calls)
return 'moderation runs before transport; accents normalize, URL-unsafe symbols are removed, wholly filtered messages never reach the generator'
''')
case('optional_legacy_json_and_plain_custom_keywords_still_work',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];AIText59='fixture'
local r=assert(e.Ask(pl,'Create an avatar'));assert(r.keyword=='emo'and r.answer=='Posso ajudar com estilo de avatar.')
AIText59='Style space pirate. Try a coat and hat.'
r=assert(e.Ask(pl,'Create a space pirate look'));assert(r.keyword=='space pirate'and r.answer==AIText59)
AIText59='Choose a black shirt.';r=assert(e.Ask(pl,'Create an emo look'));assert(r.keyword=='emo')
return 'valid older JSON is accepted without requesting it; plain native style phrase and safe local keyword fallback remain usable'
''')
case('malformed_native_reply_never_becomes_success',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];BadResponse59={GeneratedText='  '}
assert(not e.Health(true));assert(e.Last.stage=='RESPONSE'and not e.Available and not e.Reference.ok)
BadResponse59=false;advance(13);assert(e.Health())
return 'empty or invalid native output fails response validation and recovers only after a real valid reply'
''')
case('native_deadline_destroys_the_timed_out_generator',ENGINE+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];local spawn=task.spawn;local late
task.spawn=function(fn,...)late={fn=fn,args={...}}end
local r,why=e.Ask(pl,'Help');assert(not r and not e.Available and e.Last.stage=='TIMEOUT')
assert(CreatedGenerators59[1].Parent==nil)
task.spawn=spawn;assert(late);late.fn(table.unpack(late.args));assert(not e.Available and e.Last.stage=='TIMEOUT')
advance(13);assert(e.Health())
return 'timeout retains failure, removes its generator and does not convert a late reply into availability'
''')
case('server_reports_contract_diagnostic_and_refunds_failed_requests',AI+src('09I_ASSISTANT_SERVER')+r'''
flush();local e=Modules['09I2_ASSISTANT_ENGINE'];local rpc=rep.ACP_AssistantRemotes.Request;local responses={}
rep.ACP_AssistantRemotes.Progress.FireClient=function(_,player,d)responses[#responses+1]=d end
local function call(a,d)advance(.3);return rpc.OnServerInvoke(pl,a,d or{})end
local before=Modules['09I1_ASSISTANT_ACCOUNTS'].Read(123).quota.used or 0
FailAssistant59=true;local r=call('ask',{text='Create an emo avatar',make=false,request='bad'});assert(r.ok);flush()
local failed=responses[#responses];assert(failed.kind=='error'and failed.available==false and failed.connectionError=='HTTP 400')
assert(failed.error:find('Limite diário devolvido',1,true))
assert(Modules['09I1_ASSISTANT_ACCOUNTS'].Read(123).quota.used==before)
local v=call('status').data;assert(v.language=='en'and not v.available and v.diagnostic:find('ASSISTENTE HTTP 400',1,true))
advance(13);FailAssistant59=false;AIText59='Here is a simple avatar idea.'
for i=1,8 do assert(call('ask',{text='Help',make=false,request='ok'..i}).ok);flush();assert(responses[#responses].kind=='result'and responses[#responses].data.language=='en')end
r=call('ask',{text='Help',make=false});assert(not r.ok and r.error:find('oito',1,true))
assert(not StoreData.ACP_AssistantProfiles_V55.u123.conversation)
return 'HTTP 400 refunds daily/session usage and reaches client with true health; status and real answers declare English compatibility; eight valid independent requests still enforced'
''')
case('paid_plan_requires_full_assistant_health_not_only_reference',AI+src('09I_ASSISTANT_SERVER')+r'''
flush();local e=Modules['09I2_ASSISTANT_ENGINE'];local rpc=rep.ACP_AssistantRemotes.Request
advance(301);FailAssistant59=true;assert(not e.Health(true)and e.Reference.ok)
advance(.3);local r=rpc.OnServerInvoke(pl,'prompt',{plan='Studio'});assert(not r.ok and not LastPrompt)
advance(13);FailAssistant59=false;assert(e.Health(true))
function Services.MarketplaceService:GetProductInfoAsync(id,kind)return{IsForSale=true,PriceInRobux=1}end
advance(.3);r=rpc.OnServerInvoke(pl,'prompt',{plan='Studio'});assert(r.ok and LastPrompt.id==3717699383)
return 'successful reference call cannot unlock plan purchase while actual assistant is failing; existing real product path resumes after health recovery'
''')
HERE.joinpath('native_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
