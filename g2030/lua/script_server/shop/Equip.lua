local ItemShop = Store.ItemShop
local itemConfig = ItemShop.EquipConfig
local Equip = {}
function Equip:operation(player, itemId)
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

function Equip:onBuy(player, itemId)
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

function Equip:onBuySuccess(player, itemId)
    print("Equip:onBuySuccess(player, itemId)"..tostring(itemId))
    local changeInfo = {}
    --to Used
    if itemConfig[itemId] then
        local buyInfo = player:getEquip()
        for i, v in pairs(buyInfo) do
            if v == ItemShop.BuyStatus.Used then
                v = ItemShop.BuyStatus.Buy
                itemConfig[tonumber(i)].status = ItemShop.BuyStatus.Buy
                changeInfo[tonumber(i)] = ItemShop.BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = ItemShop.BuyStatus.Used
        itemConfig[itemId].status = ItemShop.BuyStatus.Used
        changeInfo[itemId] = ItemShop.BuyStatus.Used
        --Lib.log_1(player:getEquip(), "onBuySuccess 1")
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
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
end

function Equip:onUsed(player, itemId)
    if itemConfig[itemId] then
        local buyInfo = player:getEquip()
        --Lib.log_1(player:getEquip(), "onUsed 1")
        local changeInfo = {}
        for i, v in pairs(buyInfo) do
            if v == ItemShop.BuyStatus.Used then
                v = ItemShop.BuyStatus.Buy
                itemConfig[tonumber(i)].status = ItemShop.BuyStatus.Buy
                changeInfo[tonumber(i)] = ItemShop.BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = ItemShop.BuyStatus.Used
        itemConfig[itemId].status = ItemShop.BuyStatus.Used
        changeInfo[itemId] = ItemShop.BuyStatus.Used
        player:setEquip(buyInfo)
        --Lib.log_1(player:getEquip(), "onUsed 2")
        ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
    end
end

function Equip:onUnload(player, itemId)
    print("Equip:onUnload(player, itemId)"..tostring(itemId))
end

function Equip:initItem(player)
    --Lib.log_1(player:getEquip(), "Equip:initItem(player, itemId) 000000000000000000000" )
    local buyInfo = player:getEquip()
    if not next(buyInfo) then
        print(" if not next(buyInfo) then")
        if itemConfig[1] then
            itemConfig[1].status = ItemShop.BuyStatus.Unlock
            buyInfo[tostring(itemConfig[1].id)] = ItemShop.BuyStatus.Unlock
            print(buyInfo[tostring(itemConfig[1].id)])
            print(ItemShop.BuyStatus.Unlock)
        end
        player:setEquip(buyInfo)
    end

    for i, status in pairs(buyInfo) do
        for id, value in pairs((itemConfig)) do
            if tonumber(i) == id then
                value.status = status
            end
        end
    end
    self:islandAndAdvanceToUnlockPay(player)
    --Lib.log_1(player:getEquip(), "Equip:initItem(player, itemId) 111111111111111111111" )
end

function Equip:islandAndAdvanceToUnlockPay(player)
    local changeInfo = {}
    local buyInfo = player:getEquip()
    for id, value in pairs((itemConfig)) do
        if "gDiamonds" == Coin:coinNameByCoinId(value.moneyType) then
            if player:getIslandLv() >= value.islandLv then
                if player:getCurLevel() >= ItemShop.PayEquipConfig[value.id].unlockAdvancedLevel then
                    if value.status == ItemShop.BuyStatus.Lock then
                        value.status = ItemShop.BuyStatus.Unlock
                        buyInfo[tostring(value.id)] = ItemShop.BuyStatus.Unlock
                        itemConfig[value.id].status = ItemShop.BuyStatus.Used
                        changeInfo[value.id] = ItemShop.BuyStatus.Used
                    end
                end
            end
        end
    end
    player:setEquip(buyInfo)
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
end

function Equip:getNextNotPayId(curId)
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

function Equip:initAdvanceItem(player)
    local changeInfo = {}
    local buyInfo = player:getEquip()
    for id, status in pairs(buyInfo) do
        if "gDiamonds" ~= Coin:coinNameByCoinId(itemConfig[tonumber(id)].moneyType) then
            status = ItemShop.BuyStatus.lock
            itemConfig[tonumber(id)].status = ItemShop.BuyStatus.Lock
            changeInfo[tonumber(id)].status = ItemShop.BuyStatus.Lock
        end
    end
    player:setEquip(buyInfo)
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
end

return Equip