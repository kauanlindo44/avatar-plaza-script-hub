-- 07G7_ADVENTURE_WORLD | ModuleScript | ReplicatedStorage | V75 (SUBSTITUIR)
-- Bosque de composição assimétrica; clareira central, horizonte e lago fora do caminho.
local Plan=require(game:GetService('ReplicatedStorage'):WaitForChild('07G8_VEGETATION_PLAN'))
local M={Version='V75',Budget=80,ClearRadius=92}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Build(center,part,alive)
 local count=0
 local function p(name,x,y,z,w,h,d,c,shape,rotation,material)
  if count>=M.Budget or alive and not alive()then return end;count=count+1
  if count%24==0 then task.wait();if alive and not alive()then return end end
  local o=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),c,shape,material or Enum.Material.Grass)
  o.CastShadow=false;if rotation then o.Orientation=rotation end;return o
 end
 for _,v in ipairs({{-350,60,165,34},{-290,310,210,45},{170,380,180,38},{390,145,240,40},{320,-295,190,34}})do
  p('AdventureHill',v[1],-8,v[2],v[3],v[4],v[3]*.7,rgb(127,171,121),Enum.PartType.Ball)
 end
 for _,t in ipairs(Plan.Build('ADVENTURE'))do
  local x,z,s=t.x,t.z,t.scale;local h=(t.variant==1 and 22 or 17)*s
  local o=p('AdventureTrunk',x,h/2,z,1.7*s,h,1.7*s,rgb(137,110,84),nil,Vector3.new(t.lean,t.yaw,0),Enum.Material.Wood)
  if o then o:SetAttribute('TreeGroup',t.group);o:SetAttribute('TreeVariant',t.variant)end
  for j=1,1 do
   local a=math.rad(t.yaw+j*113);local pine=t.variant==1;local size=(pine and 16-j*3 or 11)*s
   p(pine and'AdventurePine'or'AdventureCanopy',x+(pine and 0 or math.cos(a)*3*s),h+(pine and j*3*s or j%2*2*s),z+(pine and 0 or math.sin(a)*3*s),size,7*s,size,rgb(110+t.tint+j*2,161+t.tint,110+j*3),Enum.PartType.Ball,Vector3.new(0,t.yaw,0))
  end
 end
 p('AdventureLake',-210,.08,118,88,.14,66,rgb(119,189,205),Enum.PartType.Ball,nil,Enum.Material.SmoothPlastic)
 for _,v in ipairs({{-253,119,10},{-248,96,7},{-229,86,9},{-194,88,8},{-173,102,6},{-177,144,10},{-231,146,7}})do
  p('AdventureShoreRock',v[1],.6,v[2],v[3],2.2,v[3]*.65,rgb(182,190,177),Enum.PartType.Ball,nil,Enum.Material.Slate)
 end
 for i,t in ipairs(Plan.Build('ADVENTURE'))do if i%5==0 then
  p('AdventureBush',t.x+6,1,t.z-5,4,2.1,3,rgb(126+t.tint,171,108),Enum.PartType.Ball)
  p('AdventureFlower',t.x+5,1.6,t.z-5,.65,.4,.65,rgb(230,176,193),Enum.PartType.Ball,nil,Enum.Material.SmoothPlastic)
 end end
 return count
end
return M
