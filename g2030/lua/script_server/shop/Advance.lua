local ItemShop = T(Store, "ItemShop")
local itemConfig = T(Config, "AdvanceConfig"):getSettings()
local BuyStatus = T(Define, "BuyStatus")
local Advance = {}
Advance.tabType = T(Define, "TabType").Advance

function Advance:operation(player, itemId)
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

function Advance:BuyAll(player, itemId)
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

function Advance:onBuy(player, itemId)
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

function Advance:onBuySuccess(player, itemId)
    print("Advance:onBuySuccess(player, itemId)"..tostring(itemId))
    print("Advance:onBuySuccess(player:getCurLevel(1))"..tostring(player:getCurLevel()))

    local changeInfo = {}
    local curLevel = player:getCurLevel()
    --to Used
    if itemConfig[itemId] then
        itemConfig[itemId].status = BuyStatus.Used
        changeInfo[itemId] = BuyStatus.Used
        player:setCurLevel(itemConfig[itemId].level)
        player:setIslandLv(itemConfig[itemId].level)
        print("Advance:onBuySuccess(player:setIslandLv(2))"..tostring(player:getIslandLv()))
        print("Advance:onBuySuccess(player:getCurLevel(2))"..tostring(player:getCurLevel()))
        --Lock to Unlock
        if not itemConfig[itemId].isPay then
            local nextId = self:getNextNotPayId(itemId)
            if nextId > itemId and itemConfig[nextId] and itemConfig[nextId].status ~= BuyStatus.Unlock then
                if player:getIslandLv() >= itemConfig[nextId].islandLv then
                    itemConfig[nextId].status = BuyStatus.Unlock
                    changeInfo[nextId] = BuyStatus.Unlock
                end
            end
        end
        ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
        self:onFinishAdvanced(player)
    end
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
    local unlockId = 0
    for id, value in pairs((itemConfig)) do
        if id == 1 or curLevel >= value.level then
            buyInfo[tostring(id)] = BuyStatus.Used
            value.status = BuyStatus.Used
            changeInfo[id] = BuyStatus.Used
            unlockId = id + 1
            curLevel = value.level
        end
    end
    if unlockId > 1 and itemConfig[unlockId] then
        player:setCurLevel(curLevel)
        buyInfo[tostring(unlockId)] = BuyStatus.Unlock
        itemConfig[unlockId].status = BuyStatus.Unlock
        changeInfo[unlockId] = BuyStatus.Unlock
    end
    ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
    --self:onFinishAdvanced(player)
    --Lib.log_1(changeInfo, "Equip:initItem(player, itemId) 111111111111111111111" )
end

function Advance:getNextNotPayId(curId)
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

function Advance:onFinishAdvanced(player)
    ItemShop:initAdvanceItem(player)
end

return Advance