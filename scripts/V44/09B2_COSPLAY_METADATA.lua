-- 09B2_COSPLAY_METADATA | ModuleScript | ServerScriptService
-- V43: referencias pesquisadas em fontes oficiais; nunca classifica pela aparencia.
-- Match exige nomes completos em duas roupas distintas consultadas no Roblox.
local M={}
M.Characters={
 {name="Naruto Uzumaki",aliases={"naruto uzumaki","uzumaki naruto"},source="https://naruto-official.com/en/news/01_1610"},
 {name="Son Goku",aliases={"son goku","goku dragon ball","dragon ball goku"},source="https://en.dragon-ball-official.com/news/01_23.html"},
 {name="Monkey D. Luffy",query="Monkey D Luffy",aliases={"monkey d luffy"},source="https://one-piece.com/character/luffy/index.html"},
 {name="Satoru Gojo",aliases={"satoru gojo","gojo satoru"},source="https://jujutsukaisen.jp/character/index_1st.php"},
 {name="Iron Man (Tony Stark)",query="Tony Stark Iron Man",aliases={"tony stark iron man","iron man tony stark"},source="https://www.marvel.com/characters/iron-man-tony-stark"},
 {name="Spider-Man (Peter Parker)",aliases={"peter parker spider man","spider man peter parker"},source="https://www.marvel.com/characters/spider-man-peter-parker"}
}
local function norm(s)return tostring(s or""):lower():gsub("[%p%c]"," "):gsub("%s+"," ")end
function M.Match(items)
 local found={}
 for _,character in ipairs(M.Characters)do
  local hits,slots={},{}
  for _,item in ipairs(items or{})do
   local slot=tostring(item.slot or"")
   if slot=="Shirt"or slot=="Pants"then
    local name=" "..norm(item.name).." "
    for _,alias in ipairs(character.aliases)do if name:find(" "..alias.." ",1,true)then hits[item.id]=true;slots[slot]=true;break end end
   end
  end
  local count=0;for _ in pairs(hits)do count=count+1 end
  if count>=2 and slots.Shirt and slots.Pants then table.insert(found,{name=character.name,source=character.source,checkedAt=os.time(),basis="Nomes das roupas consultados no Roblox",items=hits})end
 end
 if #found==1 then return found[1]end
 return nil
end
return M
