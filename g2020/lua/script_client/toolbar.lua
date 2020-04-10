local toolBar = UI:getWnd("toolbar")
local self = toolBar

local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "expression")
btn:SetArea({ 0, 0 }, { 0, 3 }, { 0, 52  }, { 0, 45 })
btn:SetProperty("StretchType", "NineGrid")
btn:SetProperty("StretchOffset", "5 5 5 5")
btn:SetNormalImage("set:appActions.json image:appAction.png")
btn:SetPushedImage("set:appActions.json image:appActioned.png")

toolBar:root():AddChildWindow(btn)
toolBar:insertAlignList("expression", btn, 3)

toolBar:subscribe(btn, UIEvent.EventButtonClick,function()
    Lib.emitEvent(Event.EVENT_SHOW_ANIMOJI)
end)


local shop = GUIWindowManager.instance:CreateGUIWindow1("Button", "shop")
shop:SetArea({ 1, -90 }, { 0, 3 }, { 0, 73  }, { 0, 47 })
shop:SetProperty("StretchType", "NineGrid")
shop:SetProperty("StretchOffset", "5 5 5 5")
shop:SetNormalImage("set:partyTool.json image:newSHop.png")
shop:SetPushedImage("set:partyTool.json image:newSHop.png")

toolBar:root():AddChildWindow(shop)
toolBar:subscribe(shop, UIEvent.EventButtonClick,function()
    Lib.emitEvent(Event.EVENT_SHOW_PRI_SHOP, true)
end)

--重新布局 toolbar
local temx = self.goldDiamond:GetXPosition()
self.goldDiamond:SetXPosition({0, temx[2] - 100})
self.rightStartPoint = self.rightStartPoint - 100