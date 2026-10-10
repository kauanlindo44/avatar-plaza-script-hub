-- Test-only engine surfaces; these do not establish native Roblox compatibility.
Services.RunService.IsServer=function()return SERVER_SIDE==true end
function pl:FindFirstChild(name)if name=='PlayerGui'then return pg elseif name=='PlayerScripts'then return PlayerScripts56 end end
PlayerScripts56=Instance.new('Folder');PlayerScripts56.Name='PlayerScripts';PlayerScripts56.DescendantAdded=Signal();pg.DescendantAdded=Signal()
function pl:WaitForChild(name)return self:FindFirstChild(name)end
local construct56=Instance.new
Instance.new=function(class)
 local o=construct56(class);o.DescendantAdded=Signal();if o:IsA('GuiObject')then o.BackgroundColor3=o.BackgroundColor3 or Color3.fromRGB(163,162,165);o.Selectable=false;o.TextBounds=Vector2.new(100,30) end
 function o:FindFirstAncestorOfClass(kind)local p=self.Parent;while p do if p:IsA(kind)then return p end;p=p.Parent end end
 return o
end

local meta56=getmetatable(pg);local setter56=meta56.__newindex
meta56.__newindex=function(o,k,v)
 local old=o.Parent;setter56(o,k,v)
 if k=='Parent'and v and v~=old then local p=v;while p do if p.DescendantAdded then p.DescendantAdded:Fire(o)end;p=p.Parent end end
end

local json56={};local seq56=0;local decode56=Services.HttpService.JSONDecode
function Services.HttpService:JSONEncode(value)seq56=seq56+1;local key='json-fixture-'..seq56;json56[key]=deep(value);return key end
function Services.HttpService:JSONDecode(value)if json56[value]then return deep(json56[value])end;return decode56(self,value)end
