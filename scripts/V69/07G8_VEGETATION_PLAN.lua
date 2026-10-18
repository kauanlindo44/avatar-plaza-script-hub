-- 07G8_VEGETATION_PLAN | ModuleScript | ReplicatedStorage | V69 (NOVO)
-- Composição por agrupamentos escolhidos; clareiras e corredores preservados.
local M={Version='V69',ClearRadius=48,Spacing=15}
local plans={
 ORIGINAL={{-88,-46,3},{-110,68,4},{76,112,3},{149,-58,3}},
 PLAIN={{-176,62,2},{184,-90,2}},
 ANIME={{-96,-76,4},{104,92,4},{-145,118,3},{184,-36,2}},
 FOREST={{-82,98,4},{-143,-64,4},{117,131,4},{191,-42,3}},
 COAST={{-130,-72,4},{121,-115,3},{-205,86,3}},
 HALLOWEEN={{-92,62,4},{103,104,4},{-157,-92,3},{188,-49,2}},
 CLOUD={{-158,68,3},{177,-96,3},{115,189,2}},
 ADVENTURE={{-131,-113,5},{-221,-61,4},{-257,142,4},{-104,242,5},{98,208,5},{199,148,5},{252,-59,4},{142,-167,5}}}
function M.Groups(id)return plans[id]or plans.ORIGINAL end
function M.Build(id)
 local seed=69;for i=1,#id do seed=(seed*31+id:byte(i))%2147483647 end
 local function nextValue()seed=(seed*48271)%2147483647;return seed/2147483647 end
 local out={};local clear=id=='ADVENTURE'and 92 or M.ClearRadius
 for ci,g in ipairs(M.Groups(id))do
  for i=1,g[3]do
   for _=1,16 do
    local a=nextValue()*math.pi*2;local radius=8+nextValue()*27
    local x,z=g[1]+math.cos(a)*radius,g[2]+math.sin(a)*radius
    local valid=x*x+z*z>clear*clear and not(math.abs(x)<22 and z<0)
    for _,old in ipairs(out)do if(x-old.x)^2+(z-old.z)^2<M.Spacing^2 then valid=false;break end end
    if valid then
     out[#out+1]={x=x,z=z,scale=.78+nextValue()*.48,yaw=nextValue()*360,lean=(nextValue()-.5)*7,
      variant=(i+ci)%4+1,tint=math.floor(nextValue()*13)-6,group=ci};break
    end
   end
  end
 end;return out
end
return M
