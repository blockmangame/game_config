local shopbase = require "script_server.shop.shop_base"

local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "BeltConfig")
    shopbase.init(self, Define.TabType.Belt, config1)
end

function M:getPlayerBuyInfo(player)
    return player:getBelt()
end

function M:setPlayerBuyInfo(player, buyInfo)
    player:setBelt(buyInfo)
end

function M:onPlayerUseItem(player, item)
    local fullName = string.format("myplugin/%s",  item.itemName)
    print("玩家 : "..tostring(player.name).." 切换腰带 ："..tostring(fullName))
    player:exchangeEquip(fullName)
end

local function init()
    M:init()
end

init()

return M