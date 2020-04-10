local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

local SelectStatus = {
    NotSelect = 1,
    Select = 2,
}
local TabType = T(Define, "TabType")

function M:init()
    widget_base.init(self, "NinjaLegendsItemShopTab.json")
    self:initWnd()
end

function M:initWnd()
    self.loTabsBg = self:child("NinjaLegendsItemShop-Tab")
    self.siTabsIcon = self.loTabsBg:GetChildByIndex(1)
    self.stTabsText = self.loTabsBg:GetChildByIndex(2)
end

function M:initTabByType(TabType, area)
    self.type = TabType
    self:setTabConfig()
    self.selectStatus = SelectStatus.NotSelect
    self:changeSelectStatus()
    self._root:SetArea(area.x,area.y,area.w,area.h)
end

function M:setTabConfig()
    if self.type == TabType.Equip then
        self.notSelectIcon = "set:ninja_legends_itemshop.json image:tab_sword_1"
        self.selectIcon = "set:ninja_legends_itemshop.json image:tab_sword_2"
        self.stTabsText:SetText(Lang:toText("item_shop_tab_name1"))
    elseif self.type == TabType.Belt then
        self.notSelectIcon = "set:ninja_legends_itemshop.json image:tab_belt_1"
        self.selectIcon = "set:ninja_legends_itemshop.json image:tab_belt_2"
        self.stTabsText:SetText(Lang:toText("item_shop_tab_name2"))
    elseif self.type == TabType.Advance then
        self.notSelectIcon = "set:ninja_legends_itemshop.json image:tab_advance_1"
        self.selectIcon = "set:ninja_legends_itemshop.json image:tab_advance_2"
        self.stTabsText:SetText(Lang:toText("item_shop_tab_name3"))
    end
end

function M:onCheckClick(type)
    print("M:onCheckClick(type) :"..tostring(type).." self.type : "..tostring(self.type))
    if self.type == type then
        self.selectStatus = SelectStatus.Select
    else
        self.selectStatus = SelectStatus.NotSelect
    end
    self:changeSelectStatus()
end

function M:changeSelectStatus()
    if self.selectStatus == SelectStatus.Select then
        self.siTabsIcon:SetImage(self.selectIcon)
        self.stTabsText:SetTextColor({255/255, 181/255, 54/255, 1})
    else
        self.siTabsIcon:SetImage(self.notSelectIcon)
        self.stTabsText:SetTextColor({220/255, 220/255, 220/255, 1})
    end
end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M
