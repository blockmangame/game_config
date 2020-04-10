local shopbase = require "script_server.shop.shop_base"
local ItemShop = T(Store, "ItemShop")
local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "AdvanceConfig"):getSettings()
    shopbase.init(self, Define.TabType.Advance, config1)
end

function M:initBuy(player)
    self.buyInfo = {}--player:getCurLevel()
end

function M:exchangeItem(player, itemName)
    local fullName = string.format("myplugin/%s", itemName)
    print("player.objID Advance : "..tostring(player.objID).." Equip:exchangeItem : "..tostring(fullName))
end

function M:onExtraBuySuccess(player)
    self:onFinishAdvanced(player)
end

function M:onFinishAdvanced(player)
    ItemShop:initAdvanceItem(player)
end

function M:initAdvanceItem(player)

end

function M:initItem(player)
    print("self.type"..tostring(self.type))
    local curLevel = player:getCurLevel()
    local changeInfo = {}
    local buyInfo = {}
    local unlockId = 1
    for id, value in pairs((self.config)) do
        if curLevel > value.level then
            buyInfo[tostring(id)] = Define.BuyStatus.Used
            changeInfo[id] = Define.BuyStatus.Used
            unlockId = id + 1
            curLevel = value.level
        end
    end
    if self.config[unlockId] then
        player:setCurLevel(curLevel)
        buyInfo[tostring(unlockId)] = Define.BuyStatus.Unlock
        changeInfo[unlockId] = Define.BuyStatus.Unlock
    end
    --Lib.log_1(buyInfo, "Advance:initItem(player, itemId) 111111111111111111111" )
    --ItemShop:sendChangeItemByTab(player, self.tabType, changeInfo)
    --self:onFinishAdvanced(player)
    --Lib.log_1( Advance:initItem(player), "Equip:initItem(player, itemId) 111111111111111111111" )
    self.buyInfo = buyInfo
    return buyInfo
end

return M