-- 07G7_ADVENTURE_WORLD | ModuleScript | ReplicatedStorage | V67 (NOVO)
-- Vale estilizado original. Centro livre; relevo cenográfico distante, sem colisões locais.
local M={Version='V67',Budget=620,ClearRadius=92}
local function rgb(r,g,b)return Color3.fromRGB(r,g,b)end
function M.Build(center,part,alive)
 local count=0;local function p(name,x,y,z,w,h,d,color,shape,rotation)
  if count>=M.Budget or alive and not alive()then return end;count=count+1
  if count%24==0 then task.wait();if alive and not alive()then return end end
  local v=part(name,Vector3.new(w,h,d),center+Vector3.new(x,y,z),color,shape,Enum.Material.SmoothPlastic)
  if rotation then v.Orientation=rotation end;v.CastShadow=false;return v
 end
 -- Silhuetas grandes só nas bordas; três passagens deixam o horizonte aberto.
 for i=1,14 do local a=i*2.399963;local r=320+(i%3)*36
  p('AdventureHill',math.cos(a)*r,-4,math.sin(a)*r,100+i%3*26,34+i%4*14,94+i%4*18,rgb(108+i%3*10,154+i%4*8,103),Enum.PartType.Ball)
 end
 local function tree(x,z,s,kind)
  local h=(kind==1 and 22 or 17)*s
  p('AdventureTrunk',x,h/2,z,2*s,h,2*s,rgb(132,102,74))
  if kind==1 then
   for j=1,3 do p('AdventurePine',x,h-2+j*4*s,z,(16-j*3)*s,9*s,(16-j*3)*s,rgb(83+j*9,139+j*7,99),Enum.PartType.Ball)end
  else
   for j=1,3 do local a=j*2.1;p('AdventureCanopy',x+math.cos(a)*3*s,h+j%2*3*s,z+math.sin(a)*3*s,13*s,9*s,12*s,rgb(107+j*9,164+j*7,96+j*5),Enum.PartType.Ball)end
  end
 end
 for i=1,66 do local a=i*2.399963;local r=110+(i*47)%225
  if not(math.abs(math.sin(a))<.11 or math.abs(math.cos(a))<.08)then tree(math.cos(a)*r,math.sin(a)*r,.7+(i%5)*.14,i%3==0 and 1 or 2)end
 end
 -- Lago deslocado para fora da clareira, pedras e margens próprias.
 p('AdventureLake',-215,.08,126,90,.14,70,rgb(103,177,205),Enum.PartType.Ball)
 for i=1,12 do local a=i*math.pi/6;p('AdventureShoreRock',-215+math.cos(a)*47,.5,126+math.sin(a)*37,9,2+i%3,6,rgb(163+i%3*8,169,159),Enum.PartType.Ball)end
 for i=1,4 do local a=i*math.pi/2
  for j=1,9 do local r=95+j*18;p('AdventurePathStone',math.cos(a)*r,.12,math.sin(a)*r,8+j%2*4,.2,6,rgb(198,192,162),Enum.PartType.Ball)end
 end
 for i=1,22 do local a=i*2.399963;local r=100+(i*31)%180;local x,z=math.cos(a)*r,math.sin(a)*r
  p('AdventureBush',x,1.2,z,4,2.4,3,rgb(125,171,105),Enum.PartType.Ball)
  for j=1,3 do p('AdventureFlower',x+j*.7,1.9,z,.7,.5,.7,j==2 and rgb(244,212,137)or rgb(232,178,191),Enum.PartType.Ball)end
 end
 return count
end
return M
