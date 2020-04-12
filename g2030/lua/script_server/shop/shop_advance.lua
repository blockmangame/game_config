local shopbase = require "script_server.shop.shop_base"
local ItemShop = T(Store, "ItemShop")
local M = Lib.derive(shopbase)

function M:init()
    local config1 = T(Config, "AdvanceConfig")
    shopbase.init(self, Define.TabType.Advance, config1)
end

function M:getPlayerBuyInfo(player)
    local buyInfo = {}--player:getCurLevel()
    local curLevel = player:getCurLevel()
    local curId = 1
    local maxLevel = curLevel
    for _, value in ipairs((self.config:getSettings())) do
        if curLevel >= value.level then
            buyInfo[tostring(value.id)] = Define.BuyStatus.Buy
            curId = value.id
            maxLevel = value.level
        end
    end
    buyInfo[tostring(curId)] = Define.BuyStatus.Used
    curLevel = maxLevel
    local nextItem = self.config:getNextItemByPay(curId, false)
    --print("nextItem.id "..tostring(nextItem.id))
    if nextItem then
        buyInfo[tostring(nextItem.id)] = Define.BuyStatus.Unlock
    end
    --Lib.log_1(buyInfo, "getPlayerBuyInfo Advance 1 :"..tostring(player.name))
    return buyInfo
end

function M:setPlayerBuyInfo(player, buyInfo)
    ----player:setCurLevel(lv)
    ----local data = {}
    --local key ={}
    --for i , v in pairs(buyInfo) do
    --    table.insert(key,i)
    --end
    --table.sort(key,function(a,b)return (tonumber(a) <  tonumber(b)) end)
    --for i=#key, 1, -1 do
    --    print("etPlayerBuyInfo Advance -1 : "..tostring(buyInfo[key[i]]))
    --    if buyInfo[key[i]] == Define.BuyStatus.Used then
    --        local useItem = self.config:getItemById(tonumber(key[i]))
    --        player:setCurLevel(useItem.level)
    --        return
    --        --local unLockItem self.config:getNextItemByPay(tonumber(key[i]), false)
    --        --print("etPlayerBuyInfo Advance -111 : "..tonumber(key[i]))
    --        --if unLockItem then
    --        --    player:setCurLevel(unLockItem.level)
    --        --    print("etPlayerBuyInfo Advance 0 : "..tostring(unLockItem.level))
    --        --    return
    --        --end
    --    end
    --end
    print("setPlayerBuyInfo Advance  :", Lib.v2s(buyInfo, 3))
    --Lib.log_1(buyInfo, "setPlayerBuyInfo Advance 1 :"..tostring(player.name))
end

function M:onPlayerUseItem(player, item)
    if item.level and item.level > 1 then
        print("玩家 : "..tostring(player.name).." 进阶到 lv ："..tostring(item.level))
        player:setCurLevel(item.level)
    end
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

function M:islandAndAdvanceToUnlockPay(player)
--覆盖
end

function M:initItem(player)
    local curLevel = player:getCurLevel()
    for _, value in pairs((self.config:getSettings())) do
        if curLevel >= value.level then
            curLevel = value.level
        end
    end
    player:setCurLevel(curLevel)
end

local function init()
    M:init()
end

init()

return M