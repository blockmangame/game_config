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
    local changeInfo = {}
    print("BuyAll self.type  :", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    --local totalPrice = 0
    local preItemId = {}
    local isFind = false
    --local checkTotalMoney = function(player, item, total)
    --    local currency = player:getCurrency(Coin:coinNameByCoinId(item.moneyType), false)
    --    print("currency.count "..tostring(currency.count))
    --    print("total "..tostring(total))
    --    if currency.count >= total then
    --        return true
    --    end
    --    return false
    --end
    for _, item in ipairs((self.config:getAllItemByPay(false))) do
        print("000 BuyAll self.type  :", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
        if isFind == true then
            break
        end
        local isLock = true
        for ids, status in pairs(buyInfo) do
            if tostring(item.id) == ids then
                isLock = false
                if player:getIslandLv() >= item.islandLv and status == BuyStatus.Unlock then
                    local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
                    print("11111 checkMoney "..tostring(checkMoney))
                    if checkMoney then
                        table.insert(preItemId, item.id)
                    else
                        print("888888888 "..tostring(isFind))
                        isFind = true
                        break
                    end
                end
            end
        end
        if isLock then
            if player:getIslandLv() >= item.islandLv then
                local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
                print("22222 checkMoney "..tostring(checkMoney))
                if checkMoney then
                    table.insert(preItemId, item.id)
                else
                    isFind = true
                    print("99999 "..tostring(isFind))
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
        print("isUsePay "..tostring(isUsePay))
        for i=#preItemId, 1, -1 do
            local status = BuyStatus.Buy
            if i==#preItemId then
                local item = self.config:getItemById(preItemId[i])
                if not isUsePay then
                    --other Used to Buy
                    for ids, status1 in pairs(buyInfo) do
                        if status1 == BuyStatus.Used then
                            buyInfo[ids] = BuyStatus.Buy
                            changeInfo[tonumber(ids)] = BuyStatus.Buy
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
                        changeInfo[nextItem.id] = BuyStatus.Unlock
                    end
                end
            end
            buyInfo[tostring(preItemId[i])] = status
            changeInfo[preItemId[i]] = status
        end
        self:setPlayerBuyInfo(player, buyInfo)
        self:onExtraBuySuccess(player, self.config:getItemById(preItemId[#preItemId]))
        ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
        print("BuyAll  self.type  buyInfo :", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
        print("BuyAll  self.type  changeInfo :", tostring(self.type).."  ".. Lib.v2s(changeInfo, 3))
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
    local changeInfo = {}
    print("购买前 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    --other Used to Buy
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            buyInfo[ids] = BuyStatus.Buy
            changeInfo[tonumber(ids)] = BuyStatus.Buy
        end
    end
    buyInfo[tostring(item.id)] = BuyStatus.Used
    changeInfo[item.id] = BuyStatus.Used
    self:onPlayerUseItem(player, item)
    --Lock to Unlock
    local nextItem = self.config:getNextItemByPay(item.id, false)
    if nextItem then
        if player:getIslandLv() >= nextItem.islandLv then
            buyInfo[tostring(nextItem.id)] = BuyStatus.Unlock
            changeInfo[nextItem.id] = BuyStatus.Unlock
        end
    end
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    print("购买后 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    self:onExtraBuySuccess(player, item)
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:getPlayerBuyInfo(player)

end

function M:setPlayerBuyInfo(player)

end

function M:onPlayerUseItem(player, item)

end

function M:onExtraBuySuccess(player, item)

end

function M:onUsed(player, itemId)
    local item = self.config:getItemById(itemId)
    local buyInfo = self:getPlayerBuyInfo(player)
    local changeInfo = {}
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            buyInfo[ids] = BuyStatus.Buy
            self:onPlayerUseItem(player, item)
            changeInfo[tonumber(ids)] = BuyStatus.Buy
        end
    end
    buyInfo[tostring(item.id)] = BuyStatus.Used
    changeInfo[item.id] = BuyStatus.Used
    --Lib.log_1(buyInfo, "onUsed 2")
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:onUnload(player, itemId)
    print("玩家 : "..tostring(player.name).." 卸载id ："..tostring(self.config:getItemById(itemId).id))
end

function M:initItem(player)
    --Lib.log_1(buyInfo, "Equip:initItem(player, itemId) 000000000000000000000" )
    local buyInfo = self:getPlayerBuyInfo(player)
    if not next(buyInfo) then
        print(" if not next(buyInfo) then")
        local item = self.config:getItemBySort(1)
        if self.config:getItemBySort(1) then
            buyInfo[tostring(item.id)] = BuyStatus.Unlock
        end
    end
    local isDefault = true
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            isDefault = false
            local item = self.config:getItemById(tonumber(ids))
            if item then
                self:onPlayerUseItem(player, item.id)
            end
        end
    end
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
    --Lib.log_1(changeInfo, "islandAndAdvanceToUnlockPay" )
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    print(" islandAndAdvanceToUnlockPay 222")
end

function M:islandToUnlockNotPay(player)
    local changeInfo = {}
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
            for ids, status in pairs(buyInfo) do
                changeInfo[tonumber(ids)] = status
            end
            break
        end
        if isLock then
            if player:getIslandLv() >= item.islandLv then
                buyInfo[tostring(item.id)] = BuyStatus.Unlock
                changeInfo[item.id] = BuyStatus.Unlock
                print(" 66666666 item.id "..tostring(item.id))
                break
            else
                print("player:getIslandLv() "..tonumber(player:getIslandLv()))
                print("item.islandLv "..tonumber(item.islandLv))
            end
        end
    end
    self:setPlayerBuyInfo(player, buyInfo)
    --Lib.log_1(changeInfo, "islandToUnlockNotPay" )
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    print("islandToUnlockNotPay changeInfo self.type : "..tostring(self.type).." buyInfo  2:", Lib.v2s(changeInfo, 3))
end

function M:initAdvanceItem(player)
    local buyInfo = self:getPlayerBuyInfo(player)
    local changeInfo = {}
    local isUsePay = false
    --Lib.log_1(buyInfo, "1 self.type "..tostring(buyInfo))
    for ids, status in pairs(buyInfo) do
        if self.config:getItemById(tonumber(ids)).isPay then
            if status == BuyStatus.Used then
                isUsePay = true
            end
        end
    end
    for id, item in ipairs(self.config:getSettings()) do
        if not item.isPay then
            if id == 1 then
                local status = BuyStatus.Buy
                if not isUsePay then
                    status = BuyStatus.Used
                    self:onPlayerUseItem(player, item)
                end
                buyInfo[tostring(id)] = status
                changeInfo[id] = status
            elseif id == 2 then
                local status = BuyStatus.Unlock
                buyInfo[tostring(id)] = BuyStatus.Unlock
                changeInfo[id] = status
            else
                changeInfo[id] = BuyStatus.Lock
                buyInfo[tostring(id)] = nil
            end
        end
    end
    self:setPlayerBuyInfo(player, buyInfo)
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    self:islandAndAdvanceToUnlockPay(player)
end

return M