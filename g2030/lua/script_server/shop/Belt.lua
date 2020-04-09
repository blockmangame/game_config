local ItemShop = T(Store, "ItemShop")
local itemConfig = T(Config, "BeltConfig"):getSettings()
local BuyStatus = T(Define, "BuyStatus")
local Belt = {}
Belt.tabType = T(Define, "TabType").Belt
function Belt:operation(player, itemId)
    print(string.format("<Belt:operation> ItemId: %s status: %s", tostring(itemId), tostring(itemConfig[itemId].status)))
    for id, value in pairs((itemConfig)) do
        if id == itemId then
            if value.status == BuyStatus.Unlock then
                self:onBuy(player, itemId)
            elseif value.status == BuyStatus.Buy then
                self:onUsed(player, itemId)
            end
        end
    end
end

function Belt:BuyAll(player)
    print(string.format("<Advance:BuyAll> "))
    for id, value in pairs((itemConfig)) do
        if value.status == BuyStatus.Lock or value.status == BuyStatus.Unlock then
            if  not value.isPay then
                if not self:onBuy(player, id) then
                    return
                end
            end
        end
    end
end

function Belt:onBuy(player, itemId)
    print("Belt:onBuy(player, itemId)"..tostring(itemId))
    local item = itemConfig[itemId]
    local checkMoney = false
    if item.isPay then
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
        if player:getIslandLv() >= item.islandLv then
            checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
        end
    end
    if checkMoney then
        self:onBuySuccess(player, itemId)
        return true
    else
        print("Equip:onBuy(player, itemId)"..tostring("购买失败"))
    end
    return false
end

function Belt:onBuySuccess(player, itemId)
    print("Belt:onBuySuccess(player, itemId)"..tostring(itemId))
    local changeInfo = {}
    local buyInfo = player:getBelt()
    --to Used
    if itemConfig[itemId] then
        for i, v in pairs(buyInfo) do
            if v == BuyStatus.Used then
                buyInfo[i] = BuyStatus.Buy
                itemConfig[tonumber(i)].status = BuyStatus.Buy
                changeInfo[tonumber(i)] = BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = BuyStatus.Used
        itemConfig[itemId].status = BuyStatus.Used
        changeInfo[itemId] = BuyStatus.Used
        self:exchangeItem(player, itemConfig[itemId].beltName)
    end
    --Lock to Unlock
    if not itemConfig[itemId].isPay then
        local nextId = self:getNextNotPayId(itemId)
        if nextId > itemId and itemConfig[nextId] and itemConfig[nextId].status ~= BuyStatus.Unlock then
            if player:getIslandLv() >= itemConfig[nextId].islandLv then
                buyInfo[tostring(nextId)] = BuyStatus.Unlock
                itemConfig[nextId].status = BuyStatus.Unlock
                changeInfo[nextId] = BuyStatus.Unlock
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
end

function Belt:onUsed(player, itemId)
    if itemConfig[itemId] then
        local buyInfo = player:getBelt()
        local changeInfo = {}
        for i, v in pairs(buyInfo) do
            if v == BuyStatus.Used then
                buyInfo[i] = BuyStatus.Buy
                itemConfig[tonumber(i)].status = BuyStatus.Buy
                changeInfo[tonumber(i)] = BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = BuyStatus.Used
        itemConfig[itemId].status = BuyStatus.Used
        self:exchangeItem(player, itemConfig[itemId].beltName)
        changeInfo[itemId] = BuyStatus.Used
        --Lib.log_1(player:getBelt(), "onUsed 2")
        ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
    end
end

function Belt:exchangeItem(player, itemName)
    local fullName = string.format("myplugin/%s", itemName)
    print("Belt:exchangeEquip : "..tostring(fullName))
    player:exchangeEquip(fullName)
end

function Belt:initItem(player)
    --Lib.log_1(player:getBelt(), "Belt:initItem(player, itemId) 000000000000000000000" )
    local buyInfo = player:getBelt()
    if not next(buyInfo) then
        print(" if not next(buyInfo) then")
        if itemConfig[1] then
            itemConfig[1].status = BuyStatus.Unlock
            buyInfo[tostring(itemConfig[1].id)] = BuyStatus.Unlock
        end
    end

    for i, status in pairs(buyInfo) do
        for id, value in pairs((itemConfig)) do
            if tonumber(i) == id then
                value.status = status
                if status == BuyStatus.Used then
                    self:exchangeItem(player, itemConfig[tonumber(i)].beltName)
                end
            end
        end
    end
    self:islandAndAdvanceToUnlockPay(player)
    --Lib.log_1(player:getBelt(), "Belt:initItem(player, itemId) 111111111111111111111" )
end

function Belt:islandAndAdvanceToUnlockPay(player)
    local changeInfo = {}
    local buyInfo = player:getBelt()
    for id, value in pairs((itemConfig)) do
        if value.isPay then
            if player:getIslandLv() >= value.islandLv then
                --if player:getCurLevel() >= ItemShop.PayEquipConfig[value.id].unlockAdvancedLevel then
                    if value.status == BuyStatus.Lock then
                        value.status = BuyStatus.Unlock
                        buyInfo[tostring(value.id)] = BuyStatus.Unlock
                        itemConfig[value.id].status = BuyStatus.Unlock
                        changeInfo[value.id] = BuyStatus.Unlock
                    end
                --end
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
end

function Belt:getNextNotPayId(curId)
    local key = #itemConfig
    if curId == key then
        return curId
    end
    for i = curId + 1, key do
        if  not itemConfig[i].isPay then
            return itemConfig[i].id
        end
    end
    return curId + 1
end

function Belt:initAdvanceItem(player)
    local changeInfo = {}
    local buyInfo = player:getBelt()
    local isUsePay = false
    for id, item in pairs(itemConfig) do
        if itemConfig[tonumber(id)].isPay then
            if item.status == BuyStatus.Used then
                isUsePay = true
            end
        end
    end
    for id, item in pairs(itemConfig) do
        if not itemConfig[tonumber(id)].isPay then
            if tonumber(id) == 1 then
                local status = BuyStatus.Buy
                if not isUsePay then
                    status = BuyStatus.Used
                    self:exchangeItem(player, itemConfig[tonumber(id)].beltName)
                end
                buyInfo[tostring(id)] = status
                itemConfig[tonumber(id)].status = status
                changeInfo[tonumber(id)] = status
            elseif tonumber(id) == 2 then
                local status = BuyStatus.Unlock
                --if not isUsePay then
                --    status = BuyStatus.Unlock
                    buyInfo[tostring(id)] = BuyStatus.Unlock
                --else
                --    buyInfo[tostring(id)] = nil
                --end
                itemConfig[tonumber(id)].status = status
                changeInfo[tonumber(id)] = status
            else
                itemConfig[tonumber(id)].status = BuyStatus.Lock
                changeInfo[tonumber(id)] = BuyStatus.Lock
                buyInfo[tostring(id)] = nil
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
    self:islandAndAdvanceToUnlockPay(player)
end

return Belt