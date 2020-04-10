local ItemShop = T(Store, "ItemShop")
local equip =  require "script_server.shop.shop_equip"
local belt =  require "script_server.shop.shop_belt"
local advance =  require "script_server.shop.shop_advance"
local TabType = T(Define, "TabType")
local M = {}

local Equip = nil
local Belt = nil
local Advance = nil

function M:init()
    Equip = Lib.derive(equip)
    Equip:init()
    Belt = Lib.derive(belt)
    Belt:init()
    Advance = Lib.derive(advance)
    Advance:init()
end

function ItemShop:operationByType(player, tabId, itemId)
    print(string.format("<ItemShop:operationByType> TypeId: %s  ItemId: %s", tostring(tabId), tostring(itemId)))
    if tabId == TabType.Equip then
        Equip:operation(player, itemId)
    elseif tabId == TabType.Belt then
        Belt:operation(player, itemId)
    elseif tabId == TabType.Advance then
        Advance:operation(player, itemId)
    end
end

function ItemShop:BuyAll(player, tabId)
    print(string.format("<ItemShop:operationByType> TypeId: %s", tostring(tabId)))
    if tabId == TabType.Equip then
        Equip:BuyAll(player)
    elseif tabId == TabType.Belt then
        Belt:BuyAll(player)
    elseif tabId == TabType.Advance then
        Advance:BuyAll(player)
    end
end

function ItemShop:initAllItem(player)
    print("ItemShop:initAllItem(player)" )
    Equip:initItem(player)
    Belt:initItem(player)
    Advance:initItem(player)
    self:sendAllItemData(player)
end

function ItemShop:showOrHide(player, isShow)
    print(string.format("showOrHide:> isShow: %s", tostring(isShow)))
    local packet = {
        pid = "itemShopRegion",
        isShow = isShow,
    }
    player:sendPacket(packet)
end

function ItemShop:sendAllItemData(player)
    local buyInfo = {}
    for _, tabType in pairs(TabType) do
        if tabType == TabType.Equip then
            buyInfo[tabType] = Equip:getPlayerBuyInfo(player)
        elseif tabType == TabType.Belt then
            buyInfo[tabType] = Belt:getPlayerBuyInfo(player)
        elseif tabType == TabType.Advance then
            buyInfo[tabType] = Advance:getPlayerBuyInfo(player)
        end
    end
    local data = {}
    for tabId, info in pairs(buyInfo) do
        data[tabId] = {}
        for i, v in pairs(info) do
            data[tabId][tonumber(i)] = v
        end
        local key ={}
        for i in pairs(data[tabId]) do
            table.insert(key,i)
        end
        table.sort(key,function(a,b)return (tonumber(a) <  tonumber(b)) end)
        local result = {}
        for _, v in pairs(key) do
            result[v]= data[tabId][v]
        end
        data[tabId] = result
    end
    local packet = {
        pid = "initItemShopData",
        data = data,
    }
    --Lib.log_1(data, "sendInitAllItem")
    player:sendPacket(packet)
end

function ItemShop:sendChangeItemByTab(player, tabType, changeInfo)
    local data = {}
    local key ={}
    for i in pairs(changeInfo) do
        table.insert(key,i)
    end
    table.sort(key,function(a,b)return (tonumber(a) <  tonumber(b)) end)
    for _, v in pairs(key) do
        data[v]= changeInfo[v]
    end
    local packet = {
        pid = "updateItemShopDataByTab",
        tabId = tabType,
        itemDate = data
    }
    ----Lib.log_1(data,"sendChangeItemByTab" )
    player:sendPacket(packet)
end

function ItemShop:initAdvanceItem(player)
    Equip:initAdvanceItem(player)
    Belt:initAdvanceItem(player)
end

M:init()

return M