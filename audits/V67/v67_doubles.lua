-- Native image culling contract: the V66 offscreen fully transparent probe never becomes ready.
local preload67=Services.ContentProvider.PreloadAsync
function Services.ContentProvider:PreloadAsync(list,callback)
 local first=list[1]
 if type(first)=='table'and first.ClassName=='ImageLabel'then
  local visible=first.Visible~=false and first.ImageTransparency<1 and first.AbsoluteSize.X>0 and first.AbsoluteSize.Y>0
  local pos=first.AbsolutePosition;visible=visible and pos.X>=0 and pos.Y>=0 and pos.X<SCREEN_W and pos.Y<SCREEN_H
  local p=first.Parent;while p do if p.Visible==false or p.Enabled==false then visible=false end;p=p.Parent end
  first.IsLoaded=visible and not ImageDenied67
  if callback then callback(first.Image,first.IsLoaded and Enum.AssetFetchStatus.Success or Enum.AssetFetchStatus.Failure)end
  return
 end
 return preload67(self,list,callback)
end
