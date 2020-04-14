local shopbase = require "script_server.shop.shop_base"

local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "EquipConfig")
    local config2 = T(Config, "PayEquipConfig")
    shopbase.init(self, Define.TabType.Equip, config1, config2)
end

function M:getPlayerBuyInfo(player)
    return player:getEquip()
end

function M:setPlayerBuyInfo(player, buyInfo)
    player:setEquip(buyInfo)
end

function M:onPlayerUseItem(player, item)
    local fullName = string.format("myplugin/%s",  item.itemName)
    print("玩家 : "..tostring(player.name).." 切换武器 ："..tostring(fullName))
    player:exchangeEquip(fullName)
end

local function init()
    M:init()
end

init()

return M