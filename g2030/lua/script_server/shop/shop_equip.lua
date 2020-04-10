local shopbase = require "script_server.shop.shop_base"

local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "EquipConfig"):getSettings()
    local config2 = T(Config, "PayEquipConfig"):getSettings()
    shopbase.init(self, Define.TabType.Equip, config1, config2)
end

function M:initBuy(player)
    self.buyInfo = player:getEquip()
end

return M