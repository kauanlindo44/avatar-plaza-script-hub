-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V58 (SUBSTITUIR)
-- TextGenerator nativo: sonda simples, transporte ASCII e formato tolerante.
local Http=game:GetService('HttpService');local Text=game:GetService('TextService')
local Diag=require(game:GetService('ReplicatedStorage'):WaitForChild('08B5_AVATAR_DIAGNOSTICS'))
local E={Available=false,Checked=0,Busy=false,RetryAt=0};local sequence=0
local prompt='You are Avatar Plaza, a brief avatar style and game help assistant. Each request is independent. Answer in Brazilian Portuguese using ASCII characters only, without accents or emoji. Be appropriate for all ages. Never request personal data, passwords, money or Robux. Never invent asset IDs, prices, web searches or guarantees. Do not encourage commercial transactions. Prefer a JSON object with answer (up to 600 characters) and keyword (a short English catalog style phrase). Plain text is acceptable. Output ASCII only. Do not use tools or URLs.'
local folds={['á']='a',['à']='a',['â']='a',['ã']='a',['ä']='a',['Á']='A',['À']='A',['Â']='A',['Ã']='A',['Ä']='A',['é']='e',['è']='e',['ê']='e',['ë']='e',['É']='E',['È']='E',['Ê']='E',['Ë']='E',['í']='i',['ì']='i',['î']='i',['ï']='i',['Í']='I',['Ì']='I',['Î']='I',['Ï']='I',['ó']='o',['ò']='o',['ô']='o',['õ']='o',['ö']='o',['Ó']='O',['Ò']='O',['Ô']='O',['Õ']='O',['Ö']='O',['ú']='u',['ù']='u',['û']='u',['ü']='u',['Ú']='U',['Ù']='U',['Û']='U',['Ü']='U',['ç']='c',['Ç']='C',['ñ']='n',['Ñ']='N'}
function E.Ascii(value)
 local s=tostring(value or'');for from,to in pairs(folds)do s=s:gsub(from,to)end
 return s:gsub('[\128-\255]',' '):gsub('[%c]',' '):gsub('%s+',' '):sub(1,1600)
end
local function keyword(raw)
 local s=E.Ascii(raw):lower()
 for _,pair in ipairs({{'halow','halloween'},{'hallow','halloween'},{'emo','emo'},{'gotic','gothic'},{'gratis','free casual'},{'gratuit','free casual'},{'meme','meme'},{'anime','anime'},{'fof','cute'},{'esport','sport'},{'class','classic'},{'urbano','streetwear'}})do if s:find(pair[1],1,true)then return pair[2]end end
 return 'casual'
end
local function fail(stage,id,cause)
 E.Available=false;E.Checked=os.clock();E.RetryAt=os.clock()+8
 local original=tostring(cause);local http=original:match('HTTP%s+(%d+)');local code=http and('HTTP '..http)or stage
 E.Error=code;E.Last={stage=stage,id=id,code=code}
 warn('[IA V58] etapa='..stage..' pedido='..id..' codigo='..code..' origem=TextGenerator.GenerateTextAsync erro='..original)
 return nil,'IA Roblox: '..code..'. Use Recarregar IA em alguns segundos. O erro original está no Output do servidor.'
end
local function generate(input,health)
 sequence=sequence+1;local id=sequence
 local made,g=pcall(function()
  local obj=Instance.new('TextGenerator');obj.SystemPrompt=health and'Use ASCII only. Reply READY.'or prompt;obj.Parent=script;return obj
 end)
 if not made then return fail('CREATE',id,g)end
 local done,ok,response=false,false,nil
 task.spawn(function()
  -- Não força JsonSchema/ResponseFormatType: os betas têm contratos diferentes.
  ok,response=pcall(function()return g:GenerateTextAsync({UserPrompt=E.Ascii(input),MaxTokens=health and 64 or 500})end)
  pcall(function()g:Destroy()end);done=true
 end)
 local deadline=os.clock()+18;while not done and os.clock()<deadline do task.wait(.05)end
 if not done then return fail('TIMEOUT',id,'18 second deadline exceeded')end
 if not ok then return fail('GENERATE',id,response)end
 if type(response)~='table'or type(response.GeneratedText)~='string'or response.GeneratedText:match('^%s*$')then return fail('RESPONSE',id,'Missing GeneratedText')end
 E.Available=true;E.Checked=os.clock();E.Error=nil;E.RetryAt=0;E.Last={stage='READY',id=id}
 if health then return {answer='READY',keyword='casual'}end
 local raw=response.GeneratedText;local decoded,data=pcall(function()return Http:JSONDecode(raw:match('{.*}')or raw)end)
 -- Texto nativo válido continua utilizável mesmo se o modelo ignorar o JSON.
 local answer=decoded and type(data)=='table'and type(data.answer)=='string'and data.answer or raw
 local term=decoded and type(data)=='table'and type(data.keyword)=='string'and data.keyword or keyword(input)
 if answer:match('^%s*$')then answer=raw end
 return {answer=Diag.Cut(answer,600),keyword=Diag.Cut(E.Ascii(term):gsub('[<>]',''),70)}
end
function E.Health(force)
 if E.Busy then return E.Available end
 local ttl=E.Available and 300 or 12
 if not force and E.Checked>0 and os.clock()-E.Checked<ttl then return E.Available end
 E.Busy=true;local r=generate('Reply READY.',true);E.Busy=false;return r~=nil
end
function E.Ask(pl,raw,context)
 if type(raw)~='string'or #raw<1 or #raw>1200 then return nil,'Escreva uma mensagem de até 1.200 caracteres.'end
 if os.clock()<E.RetryAt then return nil,'A IA Roblox pediu uma pausa. Tente novamente em alguns segundos.'end
 local ok,filtered=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForUserAsync(pl.UserId)end)
 if not ok then return nil,'A mensagem não pôde ser verificada. Tente novamente.'end
 if type(context)=='table'then filtered='Independent style request. Reference style: '..E.Ascii(context.style)..'. Change: '..E.Ascii(context.scope)..'. Player request: '..filtered end
 return generate(filtered,false)
end
return E
