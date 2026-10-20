-- Only service doubles for newly used native APIs; production code is unmodified.
Services.UserInputService.TouchPinch=signal()
Services.AvatarEditorService.PromptSaveAvatarCompleted=signal()
Services.AvatarEditorService.PromptCreateOutfitCompleted=signal()
Services.MarketplaceService.PromptPurchaseFinished=signal()
Services.MarketplaceService.PromptBundlePurchaseFinished=signal()
Services.UserInputService.InputChanged=Services.UserInputService.InputChanged or signal()
function Services.UserInputService:GetFocusedTextBox()return nil end
function Services.UserInputService:IsKeyDown()return false end
function Services.AvatarEditorService:PromptCreateOutfit(d,rig)self.LastOutfit={desc=d,rig=rig}end
function Services.AvatarEditorService:PromptSaveAvatar(d,rig)self.LastSave={desc=d,rig=rig}end
for k,v in pairs({ClimbAnimation=48,FallAnimation=50,IdleAnimation=51,JumpAnimation=52,RunAnimation=53,SwimAnimation=54,WalkAnimation=55})do Enum.AvatarAssetType[k].Value=v end
