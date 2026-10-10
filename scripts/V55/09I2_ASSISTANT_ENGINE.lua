-- 09I2_ASSISTANT_ENGINE | ModuleScript | ServerScriptService | V55 (NOVO)
-- TextGenerator real do Roblox. Não transmite ContextToken nem salva conversa.
local Http=game:GetService('HttpService');local Text=game:GetService('TextService')
local E={Available=false,Checked=0,Busy=false};local generator
local prompt='Você é a IA do Avatar Plaza, assistente breve de estilo e ajuda sobre avatar, Photo Mode, música, xadrez, dama e truco. Responda em português, de modo apropriado a todas as idades. Nunca peça dados pessoais, senhas, pagamento ou Robux. Não invente IDs, preços, resultados de pesquisa na internet ou garantias. Não incentive transações comerciais. Cada pergunta é independente. Retorne somente JSON com answer (até 600 caracteres), keyword (termo curto de estilo para o catálogo, sem links ou IDs).'
local function create()
 if generator then return generator end
 local ok,g=pcall(function()local obj=Instance.new('TextGenerator');obj.SystemPrompt=prompt;obj.Temperature=.5;obj.TopP=.8;obj.Parent=script;return obj end)
 if ok then generator=g end;return generator
end
local function generate(text)
 local g=create();if not g then return nil,'A geração de texto não está disponível neste projeto Roblox.'end
 local done=false;local ok,response
 task.spawn(function()ok,response=pcall(function()return g:GenerateTextAsync({UserPrompt=text,MaxTokens=500})end);done=true end)
 local deadline=os.clock()+18;while not done and os.clock()<deadline do task.wait(.05)end
 if not done then E.Available=false;return nil,'A IA demorou para responder. Tente novamente.'end
 if not ok or type(response)~='table'or type(response.GeneratedText)~='string'then E.Available=false;return nil,'O serviço de IA do Roblox não respondeu. Tente novamente.'end
 local raw=response.GeneratedText;local decoded,data=pcall(function()return Http:JSONDecode(raw:match('{.*}')or raw)end)
 if not decoded or type(data)~='table'or type(data.answer)~='string'then return nil,'A IA retornou uma resposta incompleta. Tente novamente.'end
 E.Available=true;E.Checked=os.clock();return {answer=data.answer:sub(1,600),keyword=tostring(data.keyword or''):gsub('[%c<>]',''):sub(1,70)}
end
function E.Health(force)
 if E.Busy then return E.Available end
 if not force and E.Checked>0 and os.clock()-E.Checked<300 then return E.Available end
 E.Busy=true;local r=generate('Confirme brevemente que ajuda com estilo de avatar.');E.Checked=os.clock();E.Busy=false;return r~=nil and E.Available
end
function E.Ask(pl,raw)
 if type(raw)~='string'or #raw<1 or #raw>1200 then return nil,'Escreva uma mensagem de até 1.200 caracteres.'end
 local ok,filtered=pcall(function()return Text:FilterStringAsync(raw,pl.UserId):GetNonChatStringForUserAsync(pl.UserId)end)
 if not ok then return nil,'A mensagem não pôde ser verificada. Tente novamente.'end
 return generate(filtered)
end
return E
