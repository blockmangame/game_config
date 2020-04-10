local shopbase = require "script_server.shop.shop_base"
local ItemShop = T(Store, "ItemShop")
local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "AdvanceConfig"):getSettings()
    shopbase.init(self, Define.TabType.Advance, config1)
end

function M:getPlayerBuyInfo(player)
    local buyInfo = {}--player:getCurLevel()
    local curLevel = player:getCurLevel()
    local unlockId = 1
    for id, value in pairs((self.config)) do
        if curLevel >= value.level then
            buyInfo[tostring(id)] = Define.BuyStatus.Used
            unlockId = id + 1
        end
    end
    if self.config[unlockId] then
        buyInfo[tostring(unlockId)] = Define.BuyStatus.Unlock
    end
    return buyInfo
end

function M:onPlayerUseItem(player, item)
    local fullName = string.format("myplugin/%s", item)
    print("player.objID Advance : "..tostring(player.objID).." Equip:onPlayerUseItem : "..tostring(fullName))
end

function M:onExtraBuySuccess(player)
    self:onFinishAdvanced(player)
end

function M:onFinishAdvanced(player)
    ItemShop:initAdvanceItem(player)
end

function M:initAdvanceItem(player)
--覆盖
end

function M:onPlayerUseItem(player, item)
    print("Advance onPlayerUseItem : "..tostring(item.level))
    if item.level and item.level > 1 then
        player:setCurLevel(item.level)
    end
end

function M:initItem(player)
    self.buyInfo = {}
    local curLevel = player:getCurLevel()
    local unlockId = 1
    for id, value in pairs((self.config)) do
        if curLevel >= value.level then
            self.buyInfo[tostring(id)] = Define.BuyStatus.Used
            self:onPlayerUseItem(player, value)
            unlockId = id + 1
            curLevel = value.level
        end
    end
    player:setCurLevel(curLevel)
    if self.config[unlockId] then
        self.buyInfo[tostring(unlockId)] = Define.BuyStatus.Unlock
    end
end

return M