-- 08B5_AVATAR_DIAGNOSTICS | ModuleScript | ReplicatedStorage | V56 (NOVO)
-- Etapas, erro nativo preservado e relatório limitado, sem inventar causas.
local Http=game:GetService('HttpService')
local M={};local sequence=0
M.Labels={DESCRIPTION='Preparar descrição',MERGE='Preservar peças atuais',CREATE='Criar avatar nativo',
 STRUCTURE='Conferir corpo',LAYERS='Conferir roupa 3D',CONTENT='Carregar malhas e texturas',
 MAP='Aplicar no mapa',CONFIRM='Confirmar aparência',SAVE='Guardar avatar',ROLLBACK='Restaurar aparência'}
function M.Cut(value,length)
 local s=tostring(value or'');local ok,at=pcall(utf8.offset,s,length+1)
 return ok and at and s:sub(1,at-1)or #s<=length and s or s:sub(1,length):gsub('[\128-\255]+$','')
end
local cut=M.Cut
function M.New(options)
 options=options or{};sequence=sequence+1
 local id;pcall(function()id=Http:GenerateGUID(false)end)
 return {trace=id or('avatar-'..sequence),player=options.player,source=options.source or'08B4_AVATAR_LOAD',
  items=options.items or{},stage='DESCRIPTION',started=os.clock(),quiet=options.quiet==true}
end
function M.Items(body)
 body=type(body)=='table'and body or{};local ids={}
 for _,v in ipairs(type(body.accessories)=='table'and body.accessories or{})do
  if type(v)=='table'and tonumber(v.id)then ids[#ids+1]=tonumber(v.id)end
 end
 for _,k in ipairs({'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg','Shirt','Pants'})do
  local v=type(body.props)=='table'and tonumber(body.props[k]);if v and v>0 then ids[#ids+1]=v end
 end;return ids
end
function M.Mark(ctx,stage,source)
 if not ctx then return end;ctx.stage=stage;ctx.source=source or ctx.source
 if not ctx.quiet then print('[Avatar V56] '..ctx.trace..' | '..stage..' | '..ctx.source)end
end
function M.Public(ctx)
 return {trace=cut(ctx.trace,80),stage=ctx.failedAt or ctx.stage,label=M.Labels[ctx.failedAt or ctx.stage]or ctx.stage,
  source=cut(ctx.source,100),cause=cut(ctx.cause,900),expected=cut(ctx.expected,220),found=cut(ctx.found,220),
  items=ctx.items,elapsed=math.floor((os.clock()-ctx.started)*1000)}
end
function M.Fail(ctx,stage,cause,expected,found)
 ctx=ctx or M.New({quiet=true});ctx.failedAt=stage or ctx.stage;ctx.cause=tostring(cause or'Erro não especificado pelo Roblox.')
 ctx.expected=tostring(expected or'');ctx.found=tostring(found or'');ctx.reported=true
 local report=M.Public(ctx);local ids={};for _,v in ipairs(ctx.items)do ids[#ids+1]=tostring(v)end
 warn('[Avatar V56] FALHA | '..ctx.trace..' | etapa='..report.stage..' | origem='..report.source..
  ' | itens='..table.concat(ids,',')..'\nEsperado: '..ctx.expected..'\nEncontrado: '..ctx.found..'\nErro original: '..ctx.cause)
 local pl=ctx.player
 if pl and pl.Parent then pcall(function()
  pl:SetAttribute('ACP_AvatarFailure',Http:JSONEncode(report))
  pl:SetAttribute('ACP_AvatarError','Falha em '..report.label..'. Código '..cut(ctx.trace,8)..'.')
 end)end
 return 'Falha em '..report.label..': '..cut(ctx.cause,140)..' [código '..cut(ctx.trace,8)..']',report
end
function M.Try(ctx,stage,source,fn)
 M.Mark(ctx,stage,source);local result=table.pack(pcall(fn))
 if not result[1]then local message,detail=M.Fail(ctx,stage,result[2]);return false,message,detail end
 return true,table.unpack(result,2,result.n)
end
function M.Clear(pl)
 if pl and pl.Parent then pl:SetAttribute('ACP_AvatarFailure',nil);pl:SetAttribute('ACP_AvatarError',nil)end
end
return M
