local ItemShop = Store.ItemShop
local Equip =  require "script_server.shop.Equip"
local Belt =  require "script_server.shop.Belt"
local itemConfig = ItemShop.AdvanceConfig
local Advance = {}

function Advance:operation(player, itemId)
    print(string.format("<Equip:operation> ItemId: %s status: %s", tostring(itemId), tostring(itemConfig[itemId].status)))
    for id, value in pairs((itemConfig)) do
        if id == itemId then
            if value.status == ItemShop.BuyStatus.Unlock then
                self:onBuy(player, itemId)
            elseif value.status == ItemShop.BuyStatus.Buy then
                self:onUsed(player, itemId)
            elseif value.status == ItemShop.BuyStatus.Used then
                self:onUnload(player, itemId)
            end
        end
    end
end

function Advance:onBuy(player, itemId)
    print("Equip:onBuy(player, itemId)"..tostring(itemId))
    local item = itemConfig[itemId]
    local price = 0
    if "gDiamonds" == Coin:coinNameByCoinId(item.moneyType) then
        price = item.price
    end
    --if Coin:consumeCoin(Coin:coinNameByCoinId(0), player, price) then
    if true then
        self:onBuySuccess(player, itemId)
    else
        print("Equip:onBuy(player, itemId)"..tostring("购买失败"))
    end
end

function Advance:onBuySuccess(player, itemId)
    print("Equip:onBuySuccess(player, itemId)"..tostring(itemId))
    local changeInfo = {}
    --to Used
    if itemConfig[itemId] then
        local buyInfo = player:getEquip()
        --Lib.log_1(player:getEquip(), "onBuySuccess 1")
        buyInfo[tostring(itemId)] = ItemShop.BuyStatus.Used
        itemConfig[itemId].status = ItemShop.BuyStatus.Used
        changeInfo[itemId] = ItemShop.BuyStatus.Used
        player:setEquip(buyInfo)
        --Lib.log_1(player:getEquip(), "onBuySuccess 2")
    end
    --Lock to Unlock
    local nextId = self:getNextNotPayId(itemId)
    if nextId > itemId and itemConfig[nextId] then
        local buyInfo = player:getEquip()
        --Lib.log_1(player:getEquip(), "onBuySuccess 3")
        buyInfo[tostring(nextId)] = ItemShop.BuyStatus.Unlock
        itemConfig[nextId].status = ItemShop.BuyStatus.Unlock
        changeInfo[nextId] = ItemShop.BuyStatus.Unlock
        player:setEquip(buyInfo)
        --Lib.log_1(player:getEquip(), "onBuySuccess 4")
    end
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Advance, changeInfo)
end

function Advance:onUsed(player, itemId)
    print("Equip:onUsed(player, itemId)"..tostring(itemId))
end

function Advance:onUnload(player, itemId)
    print("Equip:onUnload(player, itemId)"..tostring(itemId))
end

function Advance:initItem(player)
    --Lib.log_1(player:getEquip(), "Equip:initItem(player, itemId) 000000000000000000000" )
    local curLevel = player:getCurLevel()
    local changeInfo = {}
    local buyInfo = {}
    local unlockId = 1
    for id, value in pairs((itemConfig)) do
        if curLevel >= value.value1 then
            buyInfo[tostring(id)] = ItemShop.BuyStatus.Used
            value.status = ItemShop.BuyStatus.Used
            changeInfo[id] = ItemShop.BuyStatus.Used
            unlockId = id
        end
    end
    if unlockId > 1 and itemConfig[unlockId] then
        buyInfo[tostring(unlockId)] = ItemShop.BuyStatus.Unlock
        itemConfig[unlockId].status = ItemShop.BuyStatus.Unlock
        changeInfo[unlockId] = ItemShop.BuyStatus.Unlock
    end
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Advance, changeInfo)
    --Lib.log_1(player:getEquip(), "Equip:initItem(player, itemId) 111111111111111111111" )
end

function Advance:getNextNotPayId(curId)
    --local key = #itemConfig
    --if curId == key then
    --    return curId
    --end
    --for i = curId + 1, key do
    --    if  "gDiamonds" ~= Coin:coinNameByCoinId(itemConfig[i].moneyType) then
    --        return itemConfig[i].id
    --    end
    --end
    return curId + 1
end

function Advance:onFinishAdvanced(player)
    Equip:initAdvanceItem(player)
    Belt:initAdvanceItem(player)
end

return Advance