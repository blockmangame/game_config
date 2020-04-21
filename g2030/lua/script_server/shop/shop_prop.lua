local shopbase = require "script_server.shop.shop_base"

local M = Lib.derive(shopbase)

local ItemShop = T(Store, "PayShop")
local BuyStatus = T(Define, "BuyStatus")

function M:init()
    local config1 = T(Config, "PropConfig")
    shopbase.init(self, Define.TabType.Prop, config1)
end

function M:operation(player, itemId)
    local buyInfo = self:getPlayerBuyInfo(player)
    print("operation self.type  :", tostring(self.type).." itemId :  "..tostring(itemId).. Lib.v2s(buyInfo))
    local isBuy = false
    for ids, status in pairs(buyInfo) do
        if ids == tostring(itemId) then
            isBuy = true
            if status == BuyStatus.Unlock then
                self:onBuy(player, itemId)
            elseif status == BuyStatus.Buy then
                self:onUsed(player,  itemId)
            elseif status == BuyStatus.Used then
                self:onUnload(player,  itemId)
            end
        end
    end
    if not isBuy then
        local item = self.config:getItemById(itemId)
        if item then
            self:onBuy(player, itemId)
        end
    end
end
--
--function M:BuyAll(player)
--
--end
--
--
function M:onBuy(player, itemId)
    local item = self.config:getItemById(itemId)
    print("Prop:onBuy(player, itemId)"..tostring(item.id))
    if item then
        player:consumeDiamonds("gDiamonds", item.price, function(ret)
            if ret then
                self:onBuySuccess(player, item)
                return true
            end
        end)
    end
    return false
end

function M:onBuySuccess(player, item)
    local buyInfo = self:getPlayerBuyInfo(player)
    print("购买前 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    buyInfo[tostring(item.id)] = BuyStatus.Used
    self:onPlayerUseItem(player, item)
    print("购买后 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    self:onExtraBuySuccess(player, item)
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:getPlayerBuyInfo(player)
    return player:getProp()
end

function M:setPlayerBuyInfo(player, buyInfo)
    player:setProp(buyInfo)
end

function M:onPlayerUseItem(player, item)
    if item.bagCapacity then
        --player:getValue("petPageNu") = player:getValue("petPageNu") + item.bagCapacity
        print("onPlayerUseItem 玩家 : "..tostring(player.name).. "宠物扩容 item.bagCapacity "..tostring(item.bagCapacity).." item.id : "..tostring(item.id))
        return
    elseif item.petType then
        if item.petType == Define.petType.pet then
            player:getNewPet(item.petId)
            print("onPlayerUseItem 玩家 : "..tostring(player.name).. "增加宠物 item.petId "..tostring(item.petId))
        elseif item.petType == Define.petType.plusPet then
            player:getNewPlusPet(item.petId)
            print("onPlayerUseItem 玩家 : "..tostring(player.name).. "增加式神 item.petId "..tostring(item.petId))
        end
        return
    elseif item.islandNotForever then
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."岛屿解锁非永久")
        return
    elseif item.islandForever then
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."岛屿解锁永久")
        return
    end
end

function M:onExtraBuySuccess(player, item)

end

function M:onUsed(player, itemId)

end

function M:onUnload(player, itemId)

end

function M:initItem(player)
    local buyInfo = self:getPlayerBuyInfo(player)
    if not next(buyInfo) then
        print(" if not next(buyInfo) then self.type : "..tostring(self.type))
        return
    end
    for ids, status in pairs(buyInfo) do
        if status == BuyStatus.Used then
            local item = self.config:getItemById(tonumber(ids))
            if item then
                self:onPlayerUseItem(player, item)
            end
        end
    end
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:islandAndAdvanceToUnlockPay(player)

end

function M:islandToUnlockNotPay(player)

end

function M:initAdvanceItem(player)

end

local function init()
    M:init()
end

init()

return M