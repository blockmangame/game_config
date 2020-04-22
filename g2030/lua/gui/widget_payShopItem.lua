local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)
local BuyStatus = T(Define, "BuyStatus")
local TabType = {
    Prop  = 4,
    Resource = 5,
    Skin = 6,
    Privilege = 7,
}
local SelectStatus = {
    NotSelect = 1,
    Select = 2,
}

local function getMoneyIconByMoneyType(moneyType)
    local coinName = Coin:coinNameByCoinId(moneyType)
    assert(coinName, "Coin:coinNameByCoinId(moneyType) ：" .. tostring(moneyType).. " is not a exit")
    return Coin:iconByCoinName(coinName)
end

function M:init()
    widget_base.init(self, "NinjaLegendsPayShopItem.json")
    self:initWnd()
end

function M:initWnd()
    self.siItemBg = self:child("NinjaLegendsPayShopItem-Item-Bg")
    self.stItemTitle = self:child("NinjaLegendsPayShopItem-Item-Title")
    self.siItemIcon = self:child("NinjaLegendsPayShopItem-Item-Icon")
    self.stItemMoneyNum = self:child("NinjaLegendsPayShopItem-Item-Btn-Text")
    self.siItemMoneyIcon = self:child("NinjaLegendsPayShopItem-Item-Btn-Gold")
    self.siItemSelectIcon =  self:child("NinjaLegendsPayShop-Item-Select")
    self.btnBuy =  self:child("NinjaLegendsPayShopItem-Item-Btn")
    self.siItemSelectIcon:SetVisible(false)
    self.btnBuy:SetEnabled(true)
    self.siItemIcon:SetVisible(true)
    self:initEvent()
end

function M:initEvent()
    --self:subscribe(self._root, UIEvent.EventWindowClick, function()
    --    self:onClickItem()
    --end)
    --self:subscribe(self.btnBuy, UIEvent.EventButtonClick, function()
    --    self:onClickButtonItem()
    --end)
end

function M:initItem(tabKind, Value)
    self.tabId = tabKind --不同类型大小等处理
    self.itemId = Value.id
    self.stItemTitle:SetText(Lang:toText(Value.name))
    self.stItemMoneyNum:SetText(tostring(Value.price))
    local moneyIcon = getMoneyIconByMoneyType(Value.moneyType)
    self.siItemMoneyIcon:SetImage(moneyIcon)
    self.siItemIcon:SetImage(Value.icon)
    self.status = Value.status
    self.selectStatus = SelectStatus.NotSelect
    self:changeSelectStatus()
    self:setItemStatus()
end

function M:setItemStatus()
    if self.status == BuyStatus.Unlock then
        self.stItemMoneyNum:SetVisible(true)
        self.siItemMoneyIcon:SetVisible(true)
        self.stItemMoneyNum:SetArea({ 0, 13 }, { 0, -1 }, { 0, 62}, { 0, 24})
    end
    if self.status == BuyStatus.Buy then
        self.stItemMoneyNum:SetArea({ 0, 0 }, { 0, -1 }, { 0, 100}, { 0, 24})
        self.siItemMoneyIcon:SetVisible(false)
        self.stItemMoneyNum:SetVisible(true)
        if self.tabId == TabType.Skin then
            self.stItemMoneyNum:SetText(Lang:toText("gui_use"))
            self.btnBuy:SetEnabled(true)
        else
            self.stItemMoneyNum:SetText(Lang:toText("gui_have"))
            self.btnBuy:SetEnabled(false)
        end
    end
    if self.status == BuyStatus.Used then
        self.siItemMoneyIcon:SetVisible(false)
        self.stItemMoneyNum:SetArea({ 0, 0 }, { 0, -1 }, { 0, 100}, { 0, 24})
        if self.tabId == TabType.Skin then
            self.stItemMoneyNum:SetText(Lang:toText("gui_unload"))
            self.btnBuy:SetEnabled(true)
        else
            self.stItemMoneyNum:SetText(Lang:toText("gui_using"))
            self.siItemMoneyIcon:SetVisible(false)
            self.btnBuy:SetEnabled(false)
        end
    end
end

--function M:onClickButtonItem()
--    print(" M:onClickButtonItem()")
--    self:onClickItem()
--    if self:checkCanSend() then
--        self:senderClickItemBuy()
--    end
--end

--function M:onClickItem()
--    print(" M:onClickItem()")
--    UI:getWnd("payShop"):onClickItem(self.itemId)
--end

function M:onCheckClick(itemId)
    if self.itemId == itemId then
        self.selectStatus = SelectStatus.Select
    else
        self.selectStatus = SelectStatus.NotSelect
    end
    self:changeSelectStatus()
end

function M:changeSelectStatus()
    if self.selectStatus == SelectStatus.Select then
        self.siItemSelectIcon:SetVisible(true)
    else
        self.siItemSelectIcon:SetVisible(false)
    end
end

--function M:checkCanSend()
--    if self.status == BuyStatus.Used and self.tabId ~= TabType.Skin then
--        return false
--    end
--    self:senderClickItemBuy()
--    return true
--end
--
--function M:senderClickItemBuy()
--    print(string.format("<M:senderClickItemBuy:> TypeId: %s  ItemId: %s", tostring(self.tabId), tostring(self.itemId)))
--    --if not self:checkCanSend() then
--    --    return
--    --end
--    local packet = {
--        pid = "SyncPayShopOperation",
--        tabId =  self.tabId,
--        itemId = self.itemId,
--    }
--    Me:sendPacket(packet)
--end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M

