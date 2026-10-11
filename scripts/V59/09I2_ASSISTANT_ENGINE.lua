-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V59 (SUBSTITUIR)
-- Compatibilidade em inglês, texto simples e diagnóstico independente do contrato.
local Http=game:GetService('HttpService');local Text=game:GetService('TextService')
local Diag=require(game:GetService('ReplicatedStorage'):WaitForChild('08B5_AVATAR_DIAGNOSTICS'))
local E={Available=false,Checked=0,Busy=false,RetryAt=0,Language='en'};local sequence=0
local prompt='You are Avatar Plaza a brief avatar style and game help assistant. Each request is independent. Reply in English only using plain words numbers spaces commas and periods. Keep the answer under sixty words. For an avatar request start with Style then a short English catalog search phrase and a period. Be appropriate for all ages. Never request personal data or passwords. Never invent asset IDs prices searches or guarantees. Do not encourage commercial transactions. Do not use JSON Markdown emojis URLs or special symbols.'
local referencePrompt='You are a helpful NPC in a virtual world.'
local folds={['á']='a',['à']='a',['â']='a',['ã']='a',['ä']='a',['Á']='A',['À']='A',['Â']='A',['Ã']='A',['Ä']='A',['é']='e',['è']='e',['ê']='e',['ë']='e',['É']='E',['È']='E',['Ê']='E',['Ë']='E',['í']='i',['ì']='i',['î']='i',['ï']='i',['Í']='I',['Ì']='I',['Î']='I',['Ï']='I',['ó']='o',['ò']='o',['ô']='o',['õ']='o',['ö']='o',['Ó']='O',['Ò']='O',['Ô']='O',['Õ']='O',['Ö']='O',['ú']='u',['ù']='u',['û']='u',['ü']='u',['Ú']='U',['Ù']='U',['Û']='U',['Ü']='U',['ç']='c',['Ç']='C',['ñ']='n',['Ñ']='N'}
function E.Ascii(value)
 local s=tostring(value or'');for from,to in pairs(folds)do s=s:gsub(from,to)end
 return s:gsub('[\128-\255]',' '):gsub('[%c]',' '):gsub('%s+',' '):sub(1,1600)
end
function E.Transport(value)
 return E.Ascii(value):gsub('[^%w%s%.,?!%-]',' '):gsub('%s+',' ')
end
local function keyword(raw)
 local s=E.Ascii(raw):lower()
 for _,pair in ipairs({{'halow','halloween'},{'hallow','halloween'},{'emo','emo'},{'gotic','gothic'},{'goth','gothic'},{'gratis','free casual'},{'gratuit','free casual'},{'free','free casual'},{'meme','meme'},{'anime','anime'},{'fof','cute'},{'cute','cute'},{'esport','sport'},{'sport','sport'},{'class','classic'},{'urbano','streetwear'},{'street','streetwear'}})do if s:find(pair[1],1,true)then return pair[2]end end
 return 'casual'
end
local function codeOf(cause)
 local original=tostring(cause);local http=original:match('HTTP%s+(%d+)');return http and('HTTP '..http)or'ERRO NATIVO'
end
local function trace(mode,stage,id,cause)
 warn('[IA V59] modo='..mode..' etapa='..stage..' pedido='..id..' codigo='..codeOf(cause)..' origem=TextGenerator.GenerateTextAsync erro='..tostring(cause))
end
local function native(mode,input)
 sequence=sequence+1;local id=sequence;local obj;local made,g=pcall(function()
  obj=Instance.new('TextGenerator');obj.Parent=game:GetService('Workspace')
  obj.SystemPrompt=mode=='REFERENCE'and referencePrompt or prompt
  obj.Temperature=.8;obj.TopP=.6;obj.Seed=7;return obj
 end)
 local function failed(stage,cause)trace(mode,stage,id,cause);return nil,{stage=stage,id=id,mode=mode,code=codeOf(cause),cause=tostring(cause)}end
 if not made then if obj then pcall(function()obj:Destroy()end)end;return failed('CREATE',g)end
 local done,ok,response=false,false,nil
 task.spawn(function()
  ok,response=pcall(function()return g:GenerateTextAsync({UserPrompt=input,MaxTokens=mode=='REFERENCE'and 50 or 240})end)
  pcall(function()g:Destroy()end);done=true
 end)
 local deadline=os.clock()+18;while not done and os.clock()<deadline do task.wait(.05)end
 if not done then pcall(function()g:Destroy()end);return failed('TIMEOUT','18 second deadline exceeded')end
 if not ok then return failed('GENERATE',response)end
 if type(response)~='table'or type(response.GeneratedText)~='string'or response.GeneratedText:match('^%s*$')then return failed('RESPONSE','Missing GeneratedText')end
 local info={stage='READY',id=id,mode=mode,model=Diag.Cut(tostring(response.Model or'not reported'),80)}
 print('[IA V59] modo='..mode..' etapa=READY pedido='..id..' caracteres='..#response.GeneratedText..' modelo='..info.model)
 return response,info
end
local function record(response,info)
 E.Available=response~=nil;E.Checked=os.clock();E.Last=info
 E.Error=response and nil or info.code;E.RetryAt=response and 0 or os.clock()+8
end
function E.Summary()
 local ref=E.Reference;local actual=E.Last
 return 'REFERÊNCIA '..(ref and(ref.ok and'OK'or ref.code)or'não testada')..' | ASSISTENTE '..(actual and(actual.stage=='READY'and'OK'or actual.code)or'não testado')
end
function E.Health(force)
 if E.Busy then return E.Available end
 local ttl=E.Available and 300 or 12
 if not force and E.Checked>0 and os.clock()-E.Checked<ttl then return E.Available end
 E.Busy=true
 -- A sonda usa a MESMA instrução e limite da solicitação real, sem dados do jogador.
 local response,info=native('HEALTH','Suggest one emo avatar style.');record(response,info)
 if force or not response then
  -- Exemplo oficial isolado: resultado separado, nunca anuncia o assistente online.
  local reference,detail=native('REFERENCE','Tell me something cool.')
  detail.ok=reference~=nil;E.Reference=detail
 end
 E.Busy=false;print('[IA V59] diagnóstico='..E.Summary());return response~=nil
end
function E.Ask(pl,raw,context)
 if type(raw)~='string'or #raw<1 or #raw>1200 then return nil,'Escreva uma mensagem de até 1.200 caracteres.'end
 if os.clock()<E.RetryAt then return nil,'A IA Roblox pediu uma pausa. Tente novamente em alguns segundos.'end
 local ok,filtered=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForUserAsync(pl.UserId)end)
 if not ok then return nil,'A mensagem não pôde ser verificada. Tente novamente.'end
 filtered=E.Transport(filtered)
 if filtered:match('^%s*$')then return nil,'A mensagem não pôde ser enviada após a verificação do Roblox.'end
 if type(context)=='table'then filtered='Independent style request. Reference style '..E.Transport(context.style)..'. Change '..E.Transport(context.scope)..'. Player request '..filtered end
 local response,info=native('ASK',filtered);record(response,info)
 if not response then return nil,'IA Roblox: '..info.code..'. Use Recarregar IA para comparar REFERÊNCIA e ASSISTENTE. O erro original está no Output do servidor.'end
 local rawText=response.GeneratedText;local decoded,data=pcall(function()return Http:JSONDecode(rawText:match('{.*}')or rawText)end)
 -- JSON antigo válido é tolerado, mas nunca solicitado ao modelo.
 local answer=decoded and type(data)=='table'and type(data.answer)=='string'and data.answer or rawText
 local term=decoded and type(data)=='table'and type(data.keyword)=='string'and data.keyword or rawText:match('^%s*[Ss]tyle%s+([%a%d%s%-]+)%.')or keyword(raw)
 if answer:match('^%s*$')then answer=rawText end
 return {answer=Diag.Cut(answer,600),keyword=Diag.Cut(E.Transport(term),70),language='en'}
end
return E
