local ItemShop = T(Store, "ItemShop")
local BuyStatus = T(Define, "BuyStatus")
local M = {}

function M:init(type, config, extraConfig)
    self.type = type
    self.config = config
    self.extraConfig = extraConfig or nil
    self.buyInfo = {}
end

function M:operation(player, itemId)
    --print(string.format("<Equip:operation> ItemId: %s status: %s", tostring(itemId), tostring(itemConfig[itemId].status)))
    --local buyInfo = self.buyInfo
    self.buyInfo = self:getPlayerBuyInfo(player)
    --Lib.log_1(self.buyInfo, "operation self.type :"..tostring(self.type))
    for ids, status in pairs(self.buyInfo) do
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
    self.buyInfo = self:getPlayerBuyInfo(player)
    print(string.format("<Equip:BuyAll> "))
    for idn, item in pairs((self.config)) do
        if  not item.isPay then
            local isLock = true
            for ids, status in pairs(self.buyInfo) do
                if tostring(idn) == ids then
                    if status == BuyStatus.Unlock then
                        isLock = false
                        if not self:onBuy(player, item.id) then
                            return
                        end
                    end
                end
            end
            if isLock then
                if not self:onBuy(player, item.id) then
                    return
                end
            end
        end
    end
end

function M:onBuy(player, itemId)
    local item = self.config[itemId]
    --print("Equip:onBuy(player, itemId)"..tostring(item.id))
    local checkMoney = false
    if item.isPay then
        player:consumeDiamonds("gDiamonds", item.price, function(ret)
            if ret then
                self:onBuySuccess(player, item)
                return true
            end
        end)
    else
        if player:getIslandLv() >= item.islandLv then
            checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "ItemShop")
        end
    end
    if checkMoney then
        self:onBuySuccess(player, item)
        return true
    end
    return false
end

function M:onExtraBuySuccess(player, item)

end

function M:onBuySuccess(player, item)
    self.buyInfo = self:getPlayerBuyInfo(player)
    local changeInfo = {}
    print("Equip:onBuySuccess(player, itemId)"..tostring(item.id))
    --Lib.log_1( self.buyInfo,"购买前 1 " )
    --to Used
    for ids, status in pairs(self.buyInfo) do
        if status == BuyStatus.Used then
            self.buyInfo[ids] = BuyStatus.Buy
            changeInfo[tonumber(ids)] = BuyStatus.Buy
        end
    end
    self.buyInfo[tostring(item.id)] = BuyStatus.Used
    changeInfo[item.id] = BuyStatus.Used
    self:onPlayerUseItem(player, item)
    --Lock to Unlock
    if not item.isPay then
        local nextId = self:getNextNotPayId(item.id)
        if nextId > item.id and self.config[nextId] then
            if player:getIslandLv() >= self.config[nextId].islandLv then
                self.buyInfo[tostring(nextId)] = BuyStatus.Unlock
                changeInfo[nextId] = BuyStatus.Unlock
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    print("self.objID : "..tostring(player.objID))
    --Lib.log_1( self.buyInfo,"购买后 2 " )
    self:onExtraBuySuccess(player, item)
end

function M:onUsed(player, itemId)
    local item = self.config[itemId]
    self.buyInfo = self:getPlayerBuyInfo(player)
    local changeInfo = {}
    for ids, status in pairs(self.buyInfo) do
        if status == BuyStatus.Used then
            self.buyInfo[ids] = BuyStatus.Buy
            self:onPlayerUseItem(player, item)
            changeInfo[tonumber(ids)] = BuyStatus.Buy
        end
    end
    self.buyInfo[tostring(item.id)] = BuyStatus.Used
    changeInfo[item.id] = BuyStatus.Used
    --Lib.log_1(self.buyInfo, "onUsed 2")
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
end

function M:onUnload(player, itemId)
    print("M:onUnload(player, itemId)"..tostring(itemId))
end

function M:onPlayerUseItem(player, item)
    local fullName = string.format("myplugin/%s",  item.itemName)
    --print("player.userId : "..tostring(player.userId).." Equip:playerUseItem : "..tostring(fullName))
    print("player.name : "..tostring(player.name).." Equip:playerUseItem : "..tostring(fullName))
    --print("player.objID : "..tostring(player.objID).." Equip:playerUseItem : "..tostring(fullName))
    player:exchangeEquip(fullName)
end

function M:getPlayerBuyInfo(player)

end

function M:initItem(player)
    --Lib.log_1(self.buyInfo, "Equip:initItem(player, itemId) 000000000000000000000" )
    self.buyInfo = self:getPlayerBuyInfo(player)
    if not next(self.buyInfo) then
        print(" if not next(buyInfo) then")
        if self.config[1] then
            self.buyInfo[tostring(self.config[1].id)] = BuyStatus.Unlock
        end
    end
    local isDefault = true
    for ids, status in pairs(self.buyInfo) do
        if status == BuyStatus.Used then
            isDefault = false
            self:onPlayerUseItem(player, self.config[tonumber(ids)])
        end
    end
    self:islandAndAdvanceToUnlockPay(player)
end

function M:islandAndAdvanceToUnlockPay(player)
    local changeInfo = {}
    self.buyInfo = self:getPlayerBuyInfo(player)
    for idn, item in pairs((self.config)) do
        if item.isPay then
            if player:getIslandLv() >= item.islandLv then
                local isUnLock = true
                if self.extraConfig then
                    isUnLock = player:getCurLevel() >= self.extraConfig[tostring(item.id)].unlockAdvancedLevel
                end
                if isUnLock then
                    if not self.buyInfo[tostring(item.id)] then
                        self.buyInfo[tostring(item.id)] = BuyStatus.Unlock
                        changeInfo[item.id] = BuyStatus.Unlock
                    end
                end
            end
        end
    end
    --Lib.log_1(changeInfo, "islandAndAdvanceToUnlockPay" )
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
end

function M:getNextNotPayId(curId)
    local key = #self.config
    if curId == key then
        return curId
    end
    for i = curId + 1, key do
        if  not self.config[i].isPay then
            return self.config[i].id
        end
    end
    return curId
end

function M:initAdvanceItem(player)
    self.buyInfo = self:getPlayerBuyInfo(player)
    local changeInfo = {}
    local isUsePay = false
    --Lib.log_1(buyInfo, "1 self.type "..tostring(buyInfo))
    for ids, status in pairs(self.buyInfo) do
        if self.config[tonumber(ids)].isPay then
            if status == BuyStatus.Used then
                isUsePay = true
            end
        end
    end
    for id, item in pairs(self.config) do
        if not item.isPay then
            if tonumber(id) == 1 then
                local status = BuyStatus.Buy
                if not isUsePay then
                    status = BuyStatus.Used
                    self:onPlayerUseItem(player, item)
                end
                self.buyInfo[tostring(id)] = status
                changeInfo[tonumber(id)] = status
            elseif tonumber(id) == 2 then
                local status = BuyStatus.Unlock
                self.buyInfo[tostring(id)] = BuyStatus.Unlock
                changeInfo[tonumber(id)] = status
            else
                changeInfo[tonumber(id)] = BuyStatus.Lock
                self.buyInfo[tostring(id)] = nil
            end
        end
    end
    ItemShop:sendChangeItemByTab(player, self.type, changeInfo)
    self:islandAndAdvanceToUnlockPay(player)
end

return M