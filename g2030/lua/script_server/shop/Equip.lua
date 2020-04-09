local ItemShop = T(Store, "ItemShop")
local itemConfig = T(Config, "EquipConfig"):getSettings()
local PayEquipConfig = T(Config, "PayEquipConfig"):getSettings()
local BuyStatus = T(Define, "BuyStatus")
local Equip = {}
Equip.tabType = T(Define, "TabType").Equip
function Equip:operation(player, itemId)
    print(string.format("<Equip:operation> ItemId: %s status: %s", tostring(itemId), tostring(itemConfig[itemId].status)))
    for id, value in pairs((itemConfig)) do
        if id == itemId then
            if value.status == BuyStatus.Unlock then
                self:onBuy(player, itemId)
            elseif value.status == BuyStatus.Buy then
                self:onUsed(player, itemId)
            elseif value.status == BuyStatus.Used then
                self:onUnload(player, itemId)
            end
        end
    end
end

function Equip:BuyAll(player)
    print(string.format("<Equip:BuyAll> "))
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

function Equip:onBuy(player, itemId)
    print("Equip:onBuy(player, itemId)"..tostring(itemId))
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

function Equip:onBuySuccess(player, itemId)
    print("Equip:onBuySuccess(player, itemId)"..tostring(itemId))
    local changeInfo = {}
    local buyInfo = player:getEquip()
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
        self:exchangeItem(player, itemConfig[itemId].equipName)
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

function Equip:onUsed(player, itemId)
    if itemConfig[itemId] then
        local buyInfo = player:getEquip()
        local changeInfo = {}
        for i, v in pairs(buyInfo) do
            if v == BuyStatus.Used then
                buyInfo[i] = BuyStatus.Buy
                self:exchangeItem(player, itemConfig[itemId].equipName)
                itemConfig[tonumber(i)].status = BuyStatus.Buy
                changeInfo[tonumber(i)] = BuyStatus.Buy
            end
        end
        buyInfo[tostring(itemId)] = BuyStatus.Used
        itemConfig[itemId].status = BuyStatus.Used
        changeInfo[itemId] = BuyStatus.Used
        --Lib.log_1(player:getEquip(), "onUsed 2")
        ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
    end
end

function Equip:exchangeItem(player, itemName)
    local fullName = string.format("myplugin/%s", itemName)
    print("Equip:exchangeItem : "..tostring(fullName))
    player:exchangeEquip(fullName)
end

function Equip:initItem(player)
    Lib.log_1(player:getEquip(), "Equip:initItem(player, itemId) 000000000000000000000" )
    local buyInfo = player:getEquip()
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
                    self:exchangeItem(player, itemConfig[tonumber(i)].equipName)
                end
            end
        end
    end
    self:islandAndAdvanceToUnlockPay(player)
    Lib.log_1(player:getEquip(), "Equip:initItem(player, itemId) 111111111111111111111" )
end

function Equip:islandAndAdvanceToUnlockPay(player)
    local changeInfo = {}
    local buyInfo = player:getEquip()
    for id, value in pairs((itemConfig)) do
        if value.isPay then
            if player:getIslandLv() >= value.islandLv then
                if player:getCurLevel() >= PayEquipConfig[tostring(value.id)].unlockAdvancedLevel then
                    if value.status == BuyStatus.Lock then
                        value.status = BuyStatus.Unlock
                        buyInfo[tostring(value.id)] = BuyStatus.Unlock
                        itemConfig[value.id].status = BuyStatus.Unlock
                        changeInfo[value.id] = BuyStatus.Unlock
                    end
                end
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
end

function Equip:getNextNotPayId(curId)
    local key = #itemConfig
    if curId == key then
        return curId
    end
    for i = curId + 1, key do
        if  not itemConfig[i].isPay then
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
                    self:exchangeItem(player, itemConfig[tonumber(id)].equipName)
                end
                buyInfo[tostring(id)] = status
                itemConfig[tonumber(id)].status = status
                changeInfo[tonumber(id)] = status
            elseif tonumber(id) == 2 then
                local status = BuyStatus.Unlock
                buyInfo[tostring(id)] = BuyStatus.Unlock
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

return Equip