-- Deterministic additional engine signals; these do not simulate native rendering.
local oldInstance54=Instance.new
Instance.new=function(class)
 local o=oldInstance54(class)
 if o:IsA('GuiButton')then o.MouseButton1Down=Signal();o.MouseButton1Up=Signal()end
 return o
end
function game:BindToClose(fn)CloseCallbacks=CloseCallbacks or{};CloseCallbacks[#CloseCallbacks+1]=fn end
