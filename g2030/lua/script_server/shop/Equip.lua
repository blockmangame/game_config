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

function Equip:BuyAll(player, itemId)
    print(string.format("<Equip:BuyAll> ItemId: %s status: %s", tostring(itemId), tostring(itemConfig[itemId].status)))
    for id, value in pairs((itemConfig)) do
        if value.status == ItemShop.BuyStatus.Lock or value.status == ItemShop.BuyStatus.Unlock then
            if  "gDiamonds" ~= Coin:coinNameByCoinId(value.moneyType) then
                if not self:onBuy(player, id) then
                    break
                end
            end
        end
    end
end

function Equip:onBuy(player, itemId)
    print("Equip:onBuy(player, itemId)"..tostring(itemId))
    local item = itemConfig[itemId]
    local checkMoney = false
    if "gDiamonds" == Coin:coinNameByCoinId(item.moneyType) then
        player:consumeDiamonds("gDiamonds", item.price, function(ret)
            if ret then
                self:onBuySuccess(player, itemId)
                print("consumeDiamonds 1"..tostring(ret))
                return true
            else
                print("consumeDiamonds 2"..tostring("购买失败"))
            end
        end)
    else
        checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
    end
    if checkMoney then
        self:onBuySuccess(player, itemId)
        return true
    else
        print("Equip:onBuy(player, itemId)"..tostring("购买失败"))
    end
    return false
end

function Equip:onBuySuccess(player, itemId)
    print("Equip:onBuySuccess(player, itemId)"..tostring(itemId))
    local changeInfo = {}
    local buyInfo = player:getEquip()
    --to Used
    if itemConfig[itemId] then
        for i, v in pairs(buyInfo) do
            if v == ItemShop.BuyStatus.Used then
                buyInfo[i] = ItemShop.BuyStatus.Buy
                itemConfig[tonumber(i)].status = ItemShop.BuyStatus.Buy
                changeInfo[tonumber(i)] = ItemShop.BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = ItemShop.BuyStatus.Used
        itemConfig[itemId].status = ItemShop.BuyStatus.Used
        changeInfo[itemId] = ItemShop.BuyStatus.Used
    end
    --Lock to Unlock
    if "gDiamonds" ~= Coin:coinNameByCoinId(itemConfig[itemId].moneyType) then
        local nextId = self:getNextNotPayId(itemId)
        if nextId > itemId and itemConfig[nextId] and itemConfig[nextId].status ~= ItemShop.BuyStatus.Unlock then
            buyInfo[tostring(nextId)] = ItemShop.BuyStatus.Unlock
            itemConfig[nextId].status = ItemShop.BuyStatus.Unlock
            changeInfo[nextId] = ItemShop.BuyStatus.Unlock
        end
    end
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
end

function Equip:onUsed(player, itemId)
    if itemConfig[itemId] then
        local buyInfo = player:getEquip()
        local changeInfo = {}
        for i, v in pairs(buyInfo) do
            if v == ItemShop.BuyStatus.Used then
                buyInfo[i] = ItemShop.BuyStatus.Buy
                itemConfig[tonumber(i)].status = ItemShop.BuyStatus.Buy
                changeInfo[tonumber(i)] = ItemShop.BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = ItemShop.BuyStatus.Used
        itemConfig[itemId].status = ItemShop.BuyStatus.Used
        changeInfo[itemId] = ItemShop.BuyStatus.Used
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
        end
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
                if player:getCurLevel() >= ItemShop.PayEquipConfig[tostring(value.id)].unlockAdvancedLevel then
                    if value.status == ItemShop.BuyStatus.Lock then
                        value.status = ItemShop.BuyStatus.Unlock
                        buyInfo[tostring(value.id)] = ItemShop.BuyStatus.Unlock
                        itemConfig[value.id].status = ItemShop.BuyStatus.Unlock
                        changeInfo[value.id] = ItemShop.BuyStatus.Unlock
                    end
                end
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
end

function Equip:getNextNotPayId(curId)
    local key = #itemConfig
    if curId == key then
        return curId
    end
    for i = curId + 1, key do
        if  "gDiamonds" ~= Coin:coinNameByCoinId(itemConfig[i].moneyType) then
            return itemConfig[i].id
        end
    end
    return curId
end

function Equip:initAdvanceItem(player)
    local changeInfo = {}
    local buyInfo = player:getEquip()
    local isUsePay = false
    for id, item in pairs(itemConfig) do
        if "gDiamonds" == Coin:coinNameByCoinId(itemConfig[tonumber(id)].moneyType) then
            if item.status == ItemShop.BuyStatus.Used then
                isUsePay = true
            end
        end
    end
    for id, item in pairs(itemConfig) do
        if "gDiamonds" ~= Coin:coinNameByCoinId(itemConfig[tonumber(id)].moneyType) then
            if tonumber(id) == 1 then
                local status = ItemShop.BuyStatus.Buy
                if not isUsePay then
                    status = ItemShop.BuyStatus.Used
                end
                buyInfo[tostring(id)] = status
                itemConfig[tonumber(id)].status = status
                changeInfo[tonumber(id)] = status
            elseif tonumber(id) == 2 then
                local status = ItemShop.BuyStatus.Unlock
                --if not isUsePay then
                --    status = ItemShop.BuyStatus.Unlock
                buyInfo[tostring(id)] = ItemShop.BuyStatus.Unlock
                --else
                --    buyInfo[tostring(id)] = nil
                --end
                itemConfig[tonumber(id)].status = status
                changeInfo[tonumber(id)] = status
            else
                itemConfig[tonumber(id)].status = ItemShop.BuyStatus.Lock
                changeInfo[tonumber(id)] = ItemShop.BuyStatus.Lock
                buyInfo[tostring(id)] = nil
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, ItemShop.TabType.Equip, changeInfo)
    self:islandAndAdvanceToUnlockPay(player)
end

return Equip