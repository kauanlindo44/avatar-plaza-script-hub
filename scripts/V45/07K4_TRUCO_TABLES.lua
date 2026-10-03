-- 07K4_TRUCO_TABLES | ModuleScript | ServerScriptService | V44
local T={};local tables={}
local function part(parent,name,size,cf,color,class)
 local v=Instance.new(class or"Part");v.Name=name;v.Size=size;v.CFrame=cf;v.Color=color;v.Anchored=true
 v.Material=Enum.Material.SmoothPlastic;v.TopSurface=Enum.SurfaceType.Smooth;v.BottomSurface=Enum.SurfaceType.Smooth;v.Parent=parent;return v
end
function T.Build(district)
 local old=district:FindFirstChild("Truco");if old then old:Destroy()end
 local zone=Instance.new("Folder");zone.Name="Truco";zone.Parent=district
 for n=1,10 do
  local model=Instance.new("Model");model.Name="Truco_"..n;model:SetAttribute("GameType","Truco");model.Parent=zone
  local center=Vector3.new(4360+((n-1)%5)*34,3,4520+math.floor((n-1)/5)*34)
  part(model,"Floor",Vector3.new(30,1,30),CFrame.new(center-Vector3.new(0,3,0)),Color3.fromRGB(48,56,65))
  local top=part(model,"TableTop",Vector3.new(14,.7,14),CFrame.new(center),Color3.fromRGB(23,75,63));model.PrimaryPart=top
  part(model,"TableEdge",Vector3.new(14.8,.5,14.8),CFrame.new(center-Vector3.new(0,.55,0)),Color3.fromRGB(96,73,48))
  for seat=1,4 do
   local a=(seat-1)*math.pi/2;local pos=center+Vector3.new(math.sin(a)*11,-1.1,math.cos(a)*11)
   local s=part(model,"Seat"..seat,Vector3.new(3,1,3),CFrame.lookAt(pos,Vector3.new(center.X,pos.Y,center.Z)),Color3.fromRGB(34,39,49),"Seat")
   s:SetAttribute("TrucoSeat",seat)
   local anchor=part(model,"CardAnchor"..seat,Vector3.new(2.4,.06,3.5),CFrame.new(center+Vector3.new(math.sin(a)*4,.45,math.cos(a)*4))*CFrame.Angles(0,a,0),Color3.new(1,1,1))
   anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false
  end
  local deck=part(model,"DeckAnchor",Vector3.new(2.4,.25,3.5),CFrame.new(center+Vector3.new(3,.6,0)),Color3.fromRGB(40,51,72));deck.CanCollide=false
  tables[n]=model
 end
 return tables
end
function T.FindFree()for _,t in ipairs(tables)do if not t:GetAttribute("ACP_TrucoRoom")then return t end end end
function T.Seat(room,pl,seat)
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local s=room.table:FindFirstChild("Seat"..seat)
 if not hum or hum.Health<=0 or not s then return false end
 char:PivotTo(s.CFrame*CFrame.new(0,3,0));task.delay(.2,function()if pl.Parent and char.Parent and not room.closing and pl:GetAttribute("ACP_TrucoRoom")==room.code and room.players[seat]==pl then s:Sit(hum)end end);return true
end
function T.Release(room,pl)
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
 if hum then hum.Sit=false end
 if pl:GetAttribute("ACP_GameType")=="Truco"then pl:SetAttribute("ACP_InGameRoom",nil);pl:SetAttribute("ACP_GameType",nil)end
 pl:SetAttribute("ACP_TrucoRoom",nil);pl:SetAttribute("ACP_TrucoSeat",nil);pl:SetAttribute("ACP_Competitive",nil)
 if char and char.Parent then
  local spawn=workspace:FindFirstChildWhichIsA("SpawnLocation",true)
  if spawn then char:PivotTo(spawn.CFrame*CFrame.new(0,4,0))end
 end
end
return T
