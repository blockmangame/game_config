local ItemShop = Store.ItemShop
local Equip =  require "script_server.shop.Equip"
local Belt =  require "script_server.shop.Belt"
local Advance =  require "script_server.shop.Advance"

function ItemShop:operationByType(player, tabId, itemId)
    print(string.format("<ItemShop:operationByType> TypeId: %s  ItemId: %s", tostring(tabId), tostring(itemId)))
    if tabId == ItemShop.TabType.Equip then
        Equip:operation(player, itemId)
    elseif tabId == ItemShop.TabType.Belt then
        Belt:operation(player, itemId)
    elseif tabId == ItemShop.TabType.Advance then
        Advance:operation(player, itemId)
    end
end

function ItemShop:BuyAll(player, tabId, itemId)
    print(string.format("<ItemShop:operationByType> TypeId: %s  ItemId: %s", tostring(tabId), tostring(itemId)))
    if tabId == ItemShop.TabType.Equip then
        Equip:BuyAll(player, itemId)
    elseif tabId == ItemShop.TabType.Belt then
        Belt:BuyAll(player, itemId)
    elseif tabId == ItemShop.TabType.Advance then
        Advance:BuyAll(player, itemId)
    end
end

function ItemShop:initAllItem(player)
    print("ItemShop:initAllItem(player)" )
    Equip:initItem(player)
    Belt:initItem(player)
    Advance:initItem(player)
    self:sendInitAllItem(player)
end

function ItemShop:showOrHide(isShow)
    print(string.format("showOrHide:> isShow: %s", tostring(isShow)))
    local packet = {
        pid = "itemShopRegion",
        isShow = isShow,
    }
end

function ItemShop:sendInitAllItem(player)
    local buyInfo = {}
    for _, tabType in pairs(ItemShop.TabType) do
        if tabType == ItemShop.TabType.Equip then
            buyInfo[tabType] = player:getEquip()
        elseif tabType == ItemShop.TabType.Belt then
            buyInfo[tabType] = player:getBelt()
        elseif tabType == ItemShop.TabType.Advance then
            --buyInfo[tabType] = {player:getCurLevel()}
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

function ItemShop:checkMoney(player, moneyType, price)
    local checkMoney = false
    if "gDiamonds" == Coin:coinNameByCoinId(moneyType) then
        player:consumeDiamonds("gDiamonds", price, function(ret)
            if ret then
                checkMoney = true
                print("consumeDiamonds 1"..tostring(ret))
                --return  true
            else
                print("consumeDiamonds 2"..tostring(ret))
            end
        end)
    else
        checkMoney = player:payCurrency(Coin:coinNameByCoinId(moneyType), price, false, false, "ItemShop")
    end
    return checkMoney
end