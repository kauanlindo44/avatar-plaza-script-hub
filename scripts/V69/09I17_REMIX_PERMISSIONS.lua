-- 09I17_REMIX_PERMISSIONS | ModuleScript | ServerScriptService | V69 (NOVO)
-- Consentimento persistente, autoria do servidor e revogação conferida sem cache local.
local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Budget=require(script.Parent:WaitForChild('09B11_DATA_BUDGET'))
local Store=game:GetService('DataStoreService'):GetDataStore('ACP_RemixSources_V69');local M={Version='V69'}
local function code(raw)
 if type(raw)~='string'then return end;local s=raw:lower():gsub('%s','');if #s==32 and not s:find('[^a-f0-9]')then return s end
end
local function read(key)
 local options=Instance.new('DataStoreGetOptions');options.UseCache=false
 local ok,v,e=Budget.Run('Read',false,function()return Store:GetAsync(key,options)end);options:Destroy()
 if not ok then return nil,e end;return v
end
local function valid(v)return type(v)=='table'and type(v.owner)=='number'and type(v.body)=='table'and type(v.code)=='string'end
function M.Check(raw,viewer)
 local id=code(raw);if not id then return nil,'Código de remix inválido.'end
 local first;local seen={};local depth=0
 while id do
  if seen[id]or depth>=8 then return nil,'A cadeia de autoria deste remix não pôde ser confirmada.'end;seen[id]=true;depth=depth+1
  local row,e=read('r_'..id);if not valid(row)or row.code~=id then return nil,e or'Combinação não encontrada.'end
  if row.parent and not code(row.parent)then return nil,'Cadeia de autoria inválida.'end
  if row.allow~=true and(not first and row.owner~=viewer or first~=nil)then return nil,'O criador não autorizou ou revogou este remix.'end
  if not first then first=row end;id=row.parent and code(row.parent)or nil
 end
 return A.Copy(first)
end
function M.Mine(pl)
 local rows,e=read('u_'..pl.UserId);if rows==nil and e then return nil,e end
 return type(rows)=='table'and rows or{}
end
function M.Create(pl,look,parentCode)
 local body,e=A.Clean(look.body);if not body then return nil,e end
 local parent;if parentCode then parent,e=M.Check(parentCode,pl.UserId);if not parent then return nil,e end end
 local mine,why=M.Mine(pl);if not mine then return nil,why end;if #mine>=20 then return nil,'Você já tem 20 combinações compartilháveis.'end
 local id=Http:GenerateGUID(false):gsub('[^%w]',''):lower()
 local row={code=id,owner=pl.UserId,ownerName=pl.Name,originalId=parent and parent.originalId or pl.UserId,
  originalName=parent and parent.originalName or pl.Name,parent=parent and parent.code or nil,
  contributors=look.contributors and A.Copy(look.contributors)or nil,body=body,rig=look.rig or'R15',name='Combinação compartilhada',allow=false,revision=1,createdAt=os.time()}
 local ok,value,err=Budget.Run('Write',false,function()return Store:UpdateAsync('r_'..id,function(old)if old~=nil then return nil end;return row end)end)
 if not ok or not value then return nil,err or'Não foi possível registrar a combinação.'end
 local listed=false
 local saved,index,reason=Budget.Run('Write',false,function()return Store:UpdateAsync('u_'..pl.UserId,function(old)
  old=type(old)=='table'and old or{};if #old>=20 then return nil end
  old[#old+1]={code=id,allow=false,originalId=row.originalId,originalName=row.originalName,createdAt=row.createdAt};listed=true;return old
 end)end)
 local indexed=false;for _,v in ipairs(type(index)=='table'and index or{})do if v.code==id then indexed=true end end
 if not saved or not listed or not indexed then return nil,reason or'A lista não pôde ser salva. Nenhum compartilhamento foi autorizado.'end
 return row
end
function M.Own(pl,raw)
 local id=code(raw);if not id then return nil,'Código inválido.'end;local row,e=read('r_'..id)
 if not valid(row)or row.owner~=pl.UserId then return nil,e or'Essa combinação não é sua.'end;return A.Copy(row)
end
function M.SetAllowed(pl,raw,enabled)
 local id=code(raw);if not id or type(enabled)~='boolean'then return nil,'Permissão inválida.'end
 local current,e=read('r_'..id);if not valid(current)or current.owner~=pl.UserId then return nil,e or'Você só pode autorizar suas próprias combinações.'end
 if enabled and current.parent then local parent,why=M.Check(current.parent,pl.UserId);if not parent then return nil,why end end
 local denied=false
 local ok,row,why=Budget.Run('Write',false,function()return Store:UpdateAsync('r_'..id,function(v)
  if not valid(v)or v.owner~=pl.UserId then denied=true;return nil end
  v.allow=enabled;v.revision=(v.revision or 0)+1;return v
 end)end)
 if not ok or not row or denied then return nil,why or'Permissão não confirmada.'end
 Budget.Run('Write',false,function()return Store:UpdateAsync('u_'..pl.UserId,function(old)
  if type(old)~='table'then return nil end;for _,v in ipairs(old)do if v.code==id then v.allow=enabled end end;return old
 end)end)
 return A.Copy(row)
end
function M.Provenance(source)
 return{sourceCode=source.code,sourceRevision=source.revision,originalCreatorId=source.originalId,
  originalCreatorName=source.originalName,sourceOwner=source.owner,sourceOwnerName=source.ownerName}
end
function M.Validate(provenance,viewer)
 if not provenance then return true end
 local row,e=M.Check(provenance.sourceCode,viewer);if not row then return nil,e end
 if row.revision~=provenance.sourceRevision then return nil,'A autorização foi alterada. Abra o código novamente antes de continuar.'end
 return true
end
return M
