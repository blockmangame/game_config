---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/1 10:09
---

local handles = T(Player, "PackageHandlers")

function handles:itemShopRegion(packet)
    print(string.format("itemShopRegion:> TypeId: %s", tostring(packet.isShow)))
    --print("packet.itemDate is : ")
    --print(type(packet.itemDate))
    --Lib.log_1(packet.itemDate)
    ----Store.ItemShop:updateItemShopByTab(packet.tabId, packet.itemDate)
    ----Lib.emitEvent(Event.EVENT_UPDATE_ITEMSHOP, packet.tabId, packet.itemDate)
    local itemShop = UI:getWnd("itemShop")
    if itemShop then
        itemShop:onShow(packet.isShow)
    end
end

function handles:initItemShopData(packet)
    print(string.format("handles:initItemShopData(packet)"))
    print("packet.packet is : ")
    --Lib.log_1(packet)
    --Store.ItemShop:updateItemShopByTab(packet.tabId, packet.itemDate)
    --Lib.emitEvent(Event.EVENT_UPDATE_ITEMSHOP, packet.tabId, packet.itemDate)
    local itemShop = UI:getWnd("itemShop")
    if itemShop then
        itemShop:initItemShop(packet.data)
    end
end

function handles:updateItemShopDataByTab(packet)
    print(string.format("handles:updateItemShopDataByTab(packet):> TypeId: %s", tostring(packet.tabId)))
    print("packet.itemDate is : ")
    print(type(packet.itemDate))
    --Lib.log_1(packet.itemDate)
    --Store.ItemShop:updateItemShopByTab(packet.tabId, packet.itemDate)
    --Lib.emitEvent(Event.EVENT_UPDATE_ITEMSHOP, packet.tabId, packet.itemDate)
    local itemShop = UI:getWnd("itemShop")
    if itemShop then
        itemShop:updateItemShopByTab(packet.tabId, packet.itemDate)
    end
end

