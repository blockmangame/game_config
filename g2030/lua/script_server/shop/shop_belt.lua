local shopbase = require "script_server.shop.shop_base"

local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "BeltConfig"):getSettings()
    shopbase.init(self, Define.TabType.Belt, config1)
end

function M:getPlayerBuyInfo(player)
    local buyInfo = player:getBelt()
    return buyInfo
end

return M