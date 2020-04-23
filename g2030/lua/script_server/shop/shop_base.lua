local ItemShop = T(Store, "ItemShop")
local BuyStatus = T(Define, "BuyStatus")
local M = {}

function M:init(type, config, extraConfig)
    self.type = type
    self.config = config
    self.extraConfig = extraConfig or nil
end

function M:operation(player, itemId)
    local buyInfo = self:getPlayerBuyInfo(player)
    print("operation self.type  :", tostring(self.type).." itemId :  "..tostring(itemId).. Lib.v2s(buyInfo, 3))
    for ids, status in pairs(buyInfo) do
        if ids == tostring(itemId) then
            if status == BuyStatus.Unlock then
                self:onBuy(player, itemId)
            elseif status == BuyStatus.Buy then
                self:onUsed(player,  itemId)
            elseif status == BuyStatus.Used then
                self:onUnload(player,  itemId)
            end
        end
    end
end

function M:BuyAll(player)
    local buyInfo = self:getPlayerBuyInfo(player)
    print("BuyAll self.type  :", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    --local totalPrice = 0
    local preItemId = {}
    local isFind = false
    for _, item in ipairs((self.config:getAllItemByPay(false))) do
        --print("000 BuyAll self.type  :", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
        if isFind == true then
            break
        end
        local isLock = true
        for ids, status in pairs(buyInfo) do
            if tostring(item.id) == ids then
                isLock = false
                if player:getIslandLv() >= item.islandLv and status == BuyStatus.Unlock then
                    local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
                    --print("11111 checkMoney "..tostring(checkMoney))
                    if checkMoney then
                        table.insert(preItemId, item.id)
                    else
                        --print("888888888 "..tostring(isFind))
                        isFind = true
                        break
                    end
                end
            end
        end
        if isLock then
            if player:getIslandLv() >= item.islandLv then
                local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
                --print("22222 checkMoney "..tostring(checkMoney))
                if checkMoney then
                    table.insert(preItemId, item.id)
                else
                    isFind = true
                    --print("99999 "..tostring(isFind))
                    break
                end
            end
        end
    end
    if next(preItemId) then
        local isUsePay = false
        for ids, status in pairs(buyInfo) do
            if self.config:getItemById(tonumber(ids)).isPay then
                if status == BuyStatus.Used then
                    isUsePay = true
                end
            end
        end
        --print("isUsePay "..tostring(isUsePay))
        for i=#preItemId, 1, -1 do
            local status = BuyStatus.Buy
            if i==#preItemId then
                local item = self.config:getItemById(preItemId[i])
                if not isUsePay then
                    --other Used to Buy
                    for ids, status1 in pairs(buyInfo) do
                        if status1 == BuyStatus.Used then
                            buyInfo[ids] = BuyStatus.Buy
                        end
                    end
                    status = BuyStatus.Used
                    self:onPlayerUseItem(player, item)
                end
                --Lock to Unlock
                local nextItem = self.config:getNextItemByPay(item.id, false)
                if nextItem then
                    if player:getIslandLv() >= nextItem.islandLv then
                        buyInfo[tostring(nextItem.id)] = BuyStatus.Unlock
                    end
                end
            end
            buyInfo[tostring(preItemId[i])] = status
        end
        self:setPlayerBuyInfo(player, buyInfo)
        self:onExtraBuySuccess(player, self.config:getItemById(preItemId[#preItemId]))
        print("BuyAll  self.type  buyInfo :", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    end
end

function M:onBuy(player, itemId)
    local item = self.config:getItemById(itemId)
    print("Equip:onBuy(player, itemId)"..tostring(item.id))
    if item then
        if item.isPay then
            player:consumeDiamonds("gDiamonds", item.price, function(ret)
                if ret then
                    self:onBuySuccess(player, item)
                    return true
                end
            end)
        else
            if player:getIslandLv() >= item.islandLv then
                local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
                if checkMoney then
                    self:onBuySuccess(player, item)
                    return true
                end
            end
        end
    end
    return false
end

function M:onBuySuccess(player, item)
    local buyInfo = self:getPlayerBuyInfo(player)
    print("购买前 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    --other Used to Buy
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            buyInfo[ids] = BuyStatus.Buy
        end
    end
    buyInfo[tostring(item.id)] = BuyStatus.Used
    self:onPlayerUseItem(player, item)
    --Lock to Unlock
    local nextItem = self.config:getNextItemByPay(item.id, false)
    if nextItem then
        if player:getIslandLv() >= nextItem.islandLv then
            buyInfo[tostring(nextItem.id)] = BuyStatus.Unlock
        end
    end
    print("购买后 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    self:onExtraBuySuccess(player, item)
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:getPlayerBuyInfo(player)

end

function M:setPlayerBuyInfo(player)

end

function M:onPlayerUseDefaultItem(player)

end

function M:onPlayerUseItem(player, item)

end

function M:onExtraBuySuccess(player, item)

end

function M:onUsed(player, itemId)
    local item = self.config:getItemById(itemId)
    local buyInfo = self:getPlayerBuyInfo(player)
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            buyInfo[ids] = BuyStatus.Buy
            self:onPlayerUseItem(player, item)
        end
    end
    buyInfo[tostring(item.id)] = BuyStatus.Used
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:onUnload(player, itemId)
    print("玩家 : "..tostring(player.name).." 卸载id ："..tostring(self.config:getItemById(itemId).id))
end

function M:initItem(player)
    --Lib.log_1(buyInfo, "Equip:initItem(player, itemId) 000000000000000000000" )
    local buyInfo = self:getPlayerBuyInfo(player)
    if not next(buyInfo) then
         print(" if not next(buyInfo) then self.type : "..tostring(self.type))
        local item1 = self.config:getItemBySort(1)
        local item2 = self.config:getItemBySort(2)
        if item1 then
            buyInfo[tostring(item1.id)] = BuyStatus.Used
            self:onPlayerUseItem(player, item1)
        end
        if item2 then
            buyInfo[tostring(item2.id)] = BuyStatus.Unlock
        end
    end
    --local isDefault = true
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            local item = self.config:getItemById(tonumber(ids))
            if item then
                self:onPlayerUseItem(player, item)
            end
            --isDefault = false
        end
    end
    --if isDefault then
    --    self:onPlayerUseDefaultItem(player)
    --end
    self:setPlayerBuyInfo(player, buyInfo)
    self:islandAndAdvanceToUnlockPay(player)
end

function M:islandAndAdvanceToUnlockPay(player)
    local changeInfo = {}
    local buyInfo = self:getPlayerBuyInfo(player)
    print("islandAndAdvanceToUnlockPay self.type : "..tostring(self.type).." buyInfo  1:", Lib.v2s(buyInfo, 3))
    for _, item in ipairs((self.config:getAllItemByPay(true))) do
        if player:getIslandLv() >= item.islandLv then
            local isUnLock = true
            if self.extraConfig then
                local payItem = self.extraConfig:getItemById(item.id)
                assert(payItem, "invalid payItem : "..tostring(item.id))
                print("islandAndAdvanceToUnlockPay payItem.unlockAdvancedLevel : "..tostring(payItem.unlockAdvancedLevel))
                isUnLock = player:getCurLevel() >= payItem.unlockAdvancedLevel
            end
            if isUnLock then
                if (not buyInfo[tostring(item.id)]) or buyInfo[tostring(item.id)] == BuyStatus.Lock then
                    buyInfo[tostring(item.id)] = BuyStatus.Unlock
                    changeInfo[item.id] = BuyStatus.Unlock
                end
            end
        end
    end
    self:setPlayerBuyInfo(player, buyInfo)
    print("islandAndAdvanceToUnlockPay self.type : "..tostring(self.type).." buyInfo :", Lib.v2s(buyInfo, 3))
end

function M:islandToUnlockNotPay(player)
    local buyInfo = self:getPlayerBuyInfo(player)
    print("islandToUnlockNotPay self.type : "..tostring(self.type).." buyInfo  1:", Lib.v2s(buyInfo, 3))
    print("player:getIslandLv() "..tostring(player:getIslandLv()))
    for _, item in ipairs((self.config:getAllItemByPay(false))) do
        local isLock = true
        local isFind = false
        for ids, status in pairs(buyInfo) do
            if tostring(item.id) == ids then
                isLock = false
                if status == BuyStatus.Unlock then
                    isFind = true
                    break
                end
            end
        end
        if isFind then
            print("isFind : "..tostring(isFind))
            break
        end
        if isLock then
            if player:getIslandLv() >= item.islandLv then
                buyInfo[tostring(item.id)] = BuyStatus.Unlock
                print(" 66666666 item.id "..tostring(item.id))
                break
            else
                print("player:getIslandLv() "..tonumber(player:getIslandLv()))
                print("item.islandLv "..tonumber(item.islandLv))
            end
        end
    end
    self:setPlayerBuyInfo(player, buyInfo)
    print("islandToUnlockNotPay self.type : "..tostring(self.type).." buyInfo  2:", Lib.v2s(buyInfo, 3))
end

function M:initAdvanceItem(player)
    local buyInfo = self:getPlayerBuyInfo(player)
    local isUsePay = false
    for ids, status in pairs(buyInfo) do
        if self.config:getItemById(tonumber(ids)).isPay then
            if status == BuyStatus.Used then
                isUsePay = true
            end
        end
    end
    for sort, item in ipairs(self.config:getAllItemByPay(false)) do
        if sort == 1 then
            local status = BuyStatus.Buy
            if not isUsePay then
                status = BuyStatus.Used
                self:onPlayerUseItem(player, item)
            end
            buyInfo[tostring(item.id)] = status
        elseif sort == 2 then
            local status = BuyStatus.Unlock
            buyInfo[tostring(item.id)] = BuyStatus.Unlock
        else
            buyInfo[tostring(item.id)] = nil
        end
    end
    self:setPlayerBuyInfo(player, buyInfo)
    self:islandAndAdvanceToUnlockPay(player)
end

return M