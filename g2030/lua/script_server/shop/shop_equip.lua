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

function M:onPlayerUseDefaultItem(player)
    local str = player:cfg().equip_default
    local fullName = string.gsub(str,'myplugin/','')
    print("玩家 : "..tostring(player.name).." 切换默认武器 ："..tostring(fullName))
    player:exchangeEquip(str)
end

function M:onPlayerUseItem(player, item)
    local fullName = string.format("myplugin/%s",  item.itemName)
    print("玩家 : "..tostring(player.name).." 切换武器 ："..tostring(fullName))
    player:exchangeEquip(fullName)
end

function M:sendNextItemId(player, nextId)
    print("onClickNextItem : "..tostring(self.type).." id ："..tostring(nextId))
    local packet = {
        pid = "itemShopSelect",
        tabId = self.type,
        itemId = nextId
    }
    player:sendPacket(packet)
end

local function init()
    M:init()
end

init()

return M