-- Strict V64 service doubles. These cannot prove rendering, platform availability or FPS.
Budget64={StandardRead=100,StandardWrite=100,OrderedWrite=100,OrderedList=20};DSCalls64={reads=0,writes=0,lists=0,orderedWrites=0}
function Services.DataStoreService:GetRequestBudgetForRequestType(kind)
 assert(kind and kind.Name);return Budget64[kind.Name]or 100
end
local get64=Services.DataStoreService.GetDataStore
function Services.DataStoreService:GetDataStore(name)
 local s=get64(self,name);local read,write=s.GetAsync,s.UpdateAsync
 function s:GetAsync(key)DSCalls64.reads=DSCalls64.reads+1;return read(self,key)end
 function s:UpdateAsync(key,fn)DSCalls64.writes=DSCalls64.writes+1;return write(self,key,fn)end
 return s
end
local ordered64=Services.DataStoreService.GetOrderedDataStore
function Services.DataStoreService:GetOrderedDataStore(name)
 local s=ordered64(self,name);local read,write=s.GetSortedAsync,s.SetAsync
 function s:GetSortedAsync(...)DSCalls64.lists=DSCalls64.lists+1;return read(self,...)end
 function s:SetAsync(...)DSCalls64.orderedWrites=DSCalls64.orderedWrites+1;return write(self,...)end
 return s
end
NativeCapture64={LocalId='native-screenshot'};CaptureCalls64={shot=0,save=0,share=0};Services.CaptureService={}
Content={fromObject=function(v)assert(v==NativeCapture64);return{Object=v}end}
function Services.CaptureService:TakeScreenshotCaptureAsync(cb,params)
 CaptureCalls64.shot=CaptureCalls64.shot+1;assert(params.UICaptureMode==Enum.UICaptureMode.None)
 if ThrowCapture64 then error('native unavailable')end
 if not HangCapture64 then task.defer(function()cb(FailCapture64 and Enum.ScreenshotCaptureResult.Failure or Enum.ScreenshotCaptureResult.Success,not FailCapture64 and NativeCapture64 or nil)end)end
end
function Services.CaptureService:PromptSaveCapturesToGallery(values,cb)
 assert(#values==1 and values[1]==NativeCapture64);CaptureCalls64.save=CaptureCalls64.save+1;task.defer(function()cb({[NativeCapture64]=not DeclineSave64})end)
end
function Services.CaptureService:PromptShareCapture(content,launch,yes,no)
 assert(content.Object==NativeCapture64);CaptureCalls64.share=CaptureCalls64.share+1;task.defer(DeclineShare64 and no or yes)
end
TransferReceipts64={}
function Services.MarketplaceService:BindReceiptHandler(kind,fn)TransferReceipts64[kind.Name]=fn;return{Disconnect=function()end}end
function Services.MarketplaceService:PromptRobuxTransferAsync(sender,receiver,amount)
 assert(sender==pl and receiver~=sender.UserId and amount>=10 and amount<=500)
 TransferPrompt64={sender=sender.UserId,receiver=receiver,amount=amount};return'native-request'
end
