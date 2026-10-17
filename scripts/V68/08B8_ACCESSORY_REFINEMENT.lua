-- 08B8_ACCESSORY_REFINEMENT | ModuleScript | ReplicatedStorage | V68 (NOVO)
-- Usa AccessoryDescription; roupas em camadas não aceitam esses offsets.
local Avatar=game:GetService('AvatarEditorService');local M={Version='V68'};local rules;local updated=-1000;local loading=false
local rigid={Hat=true,Hair=true,Face=true,Neck=true,Shoulder=true,Front=true,Back=true}
local names={Hat='Hat',Hair='HairAccessory',Face='FaceAccessory',Neck='NeckAccessory',Shoulder='ShoulderAccessory',Front='FrontAccessory',Back='BackAccessory'}
local fields={position='Position',rotation='Rotation',scale='Scale'};local axes={'X','Y','Z'}
function M.SetRules(data)if type(data)=='table'and type(data.AccessoryRefinementLowerBounds)=='table'and type(data.AccessoryRefinementUpperBounds)=='table'then rules=data;updated=os.clock();return true end;return false end
function M.LoadRules()
 if rules and os.clock()-updated<300 then return rules end
 if loading then local deadline=os.clock()+8;while loading and os.clock()<deadline do task.wait(.1)end;return rules end
 loading=true;local ok,data=pcall(function()return Avatar:GetAvatarRulesAsync()end);loading=false;if ok then M.SetRules(data)end
 return rules,not rules and'O Roblox não liberou os limites de ajuste. Tente novamente.'or nil
end
function M.Bounds(kind,field)
 if not rigid[kind]then return end
 local f=fields[field];if not f then return end;local key=names[kind];local lower=rules and rules.AccessoryRefinementLowerBounds;local upper=rules and rules.AccessoryRefinementUpperBounds
 local lo=lower and(lower[key]or lower[kind]);local hi=upper and(upper[key]or upper[kind]);lo=lo and lo[f];hi=hi and hi[f]
 if not lo or not hi then return end
 local a,b={},{};for i,axis in ipairs(axes)do local k=axis..f;a[i]=tonumber(lo[k]or lo[axis]);b[i]=tonumber(hi[k]or hi[axis]);if not a[i]or not b[i]then return end end;return a,b
end
local function cleanVector(raw,field)
 if raw==nil then return end;if type(raw)~='table'or #raw~=3 then return false end
 local out={};for i=1,3 do local n=raw[i];local limit=field=='rotation'and 180 or field=='scale'and 3 or 2
  if type(n)~='number'or n~=n or math.abs(n)>limit or field=='scale'and n<=0 then return false end;out[i]=math.floor(n*100+.5)/100 end;return out
end
function M.Clean(row)
 local out={};local any=false
 for field in pairs(fields)do if row[field]~=nil then
  local v=cleanVector(row[field],field);if v==false or row.layer or not rigid[row.type]then return nil,'Ajuste de acessório inválido ou não permitido para essa peça.'end
  if v then local lo,hi=M.Bounds(row.type,field);if lo then for i=1,3 do if v[i]<lo[i]-.001 or v[i]>hi[i]+.001 then return nil,'O ajuste ultrapassa os limites do Roblox.'end end end;out[field]=v;any=true end
 end end;return out,any
end
function M.Pack(desc,d)
 local by={};for _,v in ipairs(d.accessories)do by[v.id]=v end
 for _,v in ipairs(desc:GetChildren())do if v:IsA('AccessoryDescription')and not v.IsLayered and by[v.AssetId]and rigid[by[v.AssetId].type]then
  local row=by[v.AssetId];for field,property in pairs(fields)do local vector=v[property];if vector then row[field]={vector.X,vector.Y,vector.Z}end end
 end end
end
function M.Restore(desc,d)
 local by={};for _,v in ipairs(d.accessories)do by[v.id]=v end
 for _,v in ipairs(desc:GetChildren())do if v:IsA('AccessoryDescription')then local row=by[v.AssetId]
  if row and not v.IsLayered then for field,property in pairs(fields)do local values=row[field];if values then v[property]=Vector3.new(values[1],values[2],values[3])end end end
 end end
end
function M.Key(row)
 local s='';local adjusted=false;for _,field in ipairs({'position','rotation','scale'})do local default=field=='scale'and 1 or 0;local v=row[field]or{default,default,default};for i=1,3 do if math.abs(v[i]-default)>.005 then adjusted=true end;s=s..':'..string.format('%.2f',v[i])end end;return adjusted and s or''
end
function M.Matches(expected,actual)
 local wanted={accessories={}};for _,v in ipairs(expected:GetAccessories(true))do wanted.accessories[#wanted.accessories+1]={id=v.AssetId,type=v.AccessoryType.Name}end;M.Pack(expected,wanted)
 local found={accessories={}};for _,v in ipairs(actual:GetAccessories(true))do found.accessories[#found.accessories+1]={id=v.AssetId,type=v.AccessoryType.Name}end;M.Pack(actual,found)
 local by={};for _,v in ipairs(found.accessories)do by[v.id]=v end
 for _,v in ipairs(wanted.accessories)do if M.Key(v)~=M.Key(by[v.id]or{})then return false,'O Roblox não confirmou o ajuste do acessório # '..v.id..'.'end end;return true
end
return M
