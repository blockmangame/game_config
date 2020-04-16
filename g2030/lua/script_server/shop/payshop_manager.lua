local PayShop = T(Store, "PayShop")
local prop =  require "script_server.shop.shop_prop"
local resource =  require "script_server.shop.shop_resource"
local skin =  require "script_server.shop.shop_skin"
local privilege =  require "script_server.shop.shop_privilege"
--local TabType = T(Define, "TabType")
local M = {}
local TabType = {
    Prop = Define.TabType.Prop,
    Resource = Define.TabType.Resource,
    Skin = Define.TabType.Skin,
    Privilege = Define.TabType.Privilege,
}

local Prop = {}
local Resource = {}
local Skin = {}
local Privilege = {}

function M:init()
    Prop = Lib.derive(prop)
    Resource = Lib.derive(resource)
    Skin = Lib.derive(skin)
    Privilege = Lib.derive(privilege)
end

function PayShop:operationByType(player, tabId, itemId)
    print(string.format("<PayShop:operationByType> TypeId: %s  ItemId: %s", tostring(tabId), tostring(itemId)))
    if tabId == TabType.Prop then
        Prop:operation(player, itemId)
    elseif tabId == TabType.Resource then
        Resource:operation(player, itemId)
    elseif tabId == TabType.Skin then
        Skin:operation(player, itemId)
    elseif tabId == TabType.Privilege then
        Privilege:operation(player, itemId)
    end
end

function PayShop:initAllItem(player)
    print("=== PayShop:initAllItem(player) ===")
    Prop:initItem(player)
    Resource:initItem(player)
    Skin:initItem(player)
    Privilege:initItem(player)
    --self:PayShopRegion(player, false)
end

function PayShop:PayShopRegion(player, isShow)
    print(string.format("payShopRegion:> isShow: %s", tostring(isShow)))
    local packet = {
        pid = "payShopRegion",
        isShow = isShow,
    }
    player:sendPacket(packet)
end

M:init()

return M