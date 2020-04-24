local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)
local BuyStatus = T(Define, "BuyStatus")

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
    widget_base.init(self, "NinjaLegendsItemShopItem.json")
    self:initWnd()
end

function M:initWnd()
    --self.llItem = self:child("NinjaLegendsItemShopItem")
    --self.llItem = self.root:GetChildByIndex(0)
    self.stItemTitle = self:child("NinjaLegendsItemShopItem-Item-Title")
    self.siItemIcon = self:child("NinjaLegendsItemShopItem-Item-Icon")
    self.siItemState = self:child("NinjaLegendsItemShopItem-Item-State")
    self.stItemStateText = self.siItemState:GetChildByIndex(0)
    self.stItemMoneyNum = self:child("NinjaLegendsItemShopItem-Item-MoneyNum")
    self.siItemMoneyIcon = self:child("NinjaLegendsItemShopItem-Item-MoneyIcon")
    self.stItemUsedText = self:child("NinjaLegendsItemShopItem-Item-UsedText")
    self.siItemLockIcon =  self:child("NinjaLegendsItemShopItem-Item-LockIcon")
    self.siItemSelectIcon =  self:child("NinjaLegendsItemShopItem-Item-Select")
    self.siItemSelectIcon:SetVisible(false)
    self.stItemUsedText:SetVisible(false)
    self.siItemLockIcon:SetVisible(false)
end

function M:initItem(tabKind, Value, area, islandLockId)
    self.kind = tabKind --不同类型大小等处理
    self.itemId = Value.id
    self.stItemTitle:SetText(Lang:toText(Value.name))
    self.stItemMoneyNum:SetText(tostring(Value.price))
    local moneyIcon = getMoneyIconByMoneyType(Value.moneyType)
    self.siItemMoneyIcon:SetImage(moneyIcon)
    self.siItemIcon:SetImage(Value.icon)
    self.itemStatus = Value.status
    self.islandLock = islandLockId == self.itemId
    self:setItemStatus()
    self:onCheckIslandLock(Value.islandIcon)
    --self.siItemMoneyIcon:SetArea({ 0, 0 }, { 0, 27 }, { 0, 110}, { 0, 90})
    --Lib.log_1 (area)
    --self._root:SetArea(area.x,area.y,area.w,area.h)
    --self._root:SetArea({ 0, 0 }, { 0, 27 }, { 0, 110}, { 0, 90})
    if Value.isPay then
        self._root:SetBackImage("set:ninja_legends_itemshop.json image:item_cost")
    end
end

function M:onCheckIslandLock(islandIcon)
    if self.islandLock and self.itemStatus == BuyStatus.Lock then
        self.siItemIcon:SetImage(islandIcon)
    end
end

function M:onCheckClick(itemId)
    if self.itemId == itemId and (self.islandLock or self.itemStatus ~= BuyStatus.Lock) then
        self.selectStatus = SelectStatus.Select
    else
        self.selectStatus = SelectStatus.NotSelect
    end
    self:changeSelectStatus(SelectStatus.Select)
end

function M:changeSelectStatus()
    if self.selectStatus == SelectStatus.Select then
        self.siItemSelectIcon:SetVisible(true)
    else
        self.siItemSelectIcon:SetVisible(false)
    end
end

function M:setItemStatus()
    if self.itemStatus == BuyStatus.Lock then
        self.stItemMoneyNum:SetVisible(false)
        self.siItemMoneyIcon:SetVisible(false)
        self.siItemSelectIcon:SetVisible(false)
        self.stItemUsedText:SetVisible(false)
        self.siItemLockIcon:SetVisible(not self.islandLock)
        self.stItemTitle:SetVisible(not self.islandLock)
    end
    if self.itemStatus == BuyStatus.Unlock then
        self.stItemMoneyNum:SetVisible(true)
        self.siItemMoneyIcon:SetVisible(true)
        --self.siItemSelectIcon:SetVisible(false)
        self.stItemUsedText:SetVisible(false)
        self.siItemLockIcon:SetVisible(false)
    end
    if self.itemStatus == BuyStatus.Buy then
        self.stItemMoneyNum:SetVisible(false)
        self.siItemMoneyIcon:SetVisible(false)
        --self.siItemSelectIcon:SetVisible(false)
        self.stItemUsedText:SetVisible(true)
        self.siItemLockIcon:SetVisible(false)
        self.stItemUsedText:SetTextColor({53/255, 177/255, 42/255, 1})
        if self.kind == Define.TabType.Advance then
            self.stItemUsedText:SetTextColor({213/255, 205/255, 47/255, 1})
            self.stItemUsedText:SetText(Lang:toText("gui_has_advancd"))
        else
            self.stItemUsedText:SetText(Lang:toText("gui_have"))
        end
    end
    if self.itemStatus == BuyStatus.Used then
        self.stItemMoneyNum:SetVisible(false)
        self.siItemMoneyIcon:SetVisible(false)
        --self.siItemSelectIcon:SetVisible(false)
        self.stItemUsedText:SetVisible(true)
        self.siItemLockIcon:SetVisible(false)
        self.stItemUsedText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stItemUsedText:SetText(Lang:toText("gui_using"))
    end
end

function M:hideGUIWindow()
    self._root:SetAlpha(0)
end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M

