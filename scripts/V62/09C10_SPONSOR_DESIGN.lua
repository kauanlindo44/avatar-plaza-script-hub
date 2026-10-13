-- 09C10_SPONSOR_DESIGN | ModuleScript | ReplicatedStorage | V62 (NOVO)
-- Uma definição para busca, exemplos e categorias; arrays de params são somente leitura.
local D=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_DESIGN_SYSTEM'));local M={Version='V62'}
M.Groups={'Todos','Roupas 2D','Roupas 3D','Acessórios','Corpo','Emotes','Favoritos'}
M.Types={['Roupas 2D']={'TShirt','Shirt','Pants'},['Roupas 3D']={'TShirtAccessory','ShirtAccessory','PantsAccessory','JacketAccessory','SweaterAccessory','ShortsAccessory','DressSkirtAccessory','LeftShoeAccessory','RightShoeAccessory'},['Acessórios']={'Hat','HairAccessory','FaceAccessory','NeckAccessory','ShoulderAccessory','FrontAccessory','BackAccessory','WaistAccessory'},['Emotes']={'EmoteAnimation'}}
function M.Params(group,text)
 local p=CatalogSearchParams.new();p.SearchKeyword=tostring(text or''):sub(1,80);p.MinPrice=1;p.IncludeOffSale=false;p.Limit=60;p.SortType=Enum.CatalogSortType.Relevance
 local types=M.Types[group]or{'Shirt','Pants','Hat','HairAccessory','ShirtAccessory','PantsAccessory','BackAccessory'};local list={}
 for _,name in ipairs(types)do local ok,value=pcall(function()return Enum.AvatarAssetType[name]end);if ok and value then list[#list+1]=value end end
 if group=='Corpo'then p.BundleTypes={Enum.BundleType.BodyParts};p.AssetTypes={}else p.AssetTypes=list;p.BundleTypes={}end
 return p
end
function M.Paid(A,item)local price=A.Price(item);return price and price>0 and not item.unavailable end
function M.Accent(button,color)
 D.Round(button,12);D.Stroke(button,color,.42,1);local grad=Instance.new('UIGradient');grad.Color=ColorSequence.new(button.BackgroundColor3:Lerp(Color3.new(1,1,1),.08),button.BackgroundColor3);grad.Rotation=90;grad.Parent=button
end
return M
