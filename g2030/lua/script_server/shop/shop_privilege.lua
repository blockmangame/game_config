local shopbase = require "script_server.shop.shop_base"

local M = Lib.derive(shopbase)

local ItemShop = T(Store, "PayShop")
local BuyStatus = T(Define, "BuyStatus")
local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer
function M:init()
    local config1 = T(Config, "PrivilegeConfig")
    shopbase.init(self, Define.TabType.Privilege, config1)
end

local privilegeType = {
    gold2Plus = 1,    --双倍金币
    hpMaxPlus = 2,    --双倍血量
    perExpPlu = 3,    --双倍肌肉
    movePlus = 4, --移速加成特权
    openRealDmg = 5, --神圣伤害
    InfiniteExp = 6, --锻炼值无上限特权
}

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
    print("Equip:onBuy(player, itemId)"..tostring(item.id))
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
    if item.autoSellDuration then
        local autoSellTime =  player:getAutoSellTime()
        if os.time() >= autoSellTime then
            autoSellTime = os.time()
        end
        autoSellTime = autoSellTime + item.autoSellDuration
        player:setAutoSellTime(autoSellTime)
        print("onBuySuccess 玩家 : "..tostring(player.name).. "自动售卖 item.autoWorkDuration "..tostring(item.autoSellDuration))
    end
    self:onPlayerUseItem(player, item)
    print("购买后 玩家 : "..tostring(player.name).. "self.type ：", tostring(self.type).."  ".. Lib.v2s(buyInfo, 3))
    self:onExtraBuySuccess(player, item)
    self:setPlayerBuyInfo(player, buyInfo)
end

function M:getPlayerBuyInfo(player)
    return player:getPrivilege()
end

function M:setPlayerBuyInfo(player, buyInfo)
    player:setPrivilege(buyInfo)
end

function M:onPlayerUseItem(player, item)
    if item.boxCard and item.boxDuration then
        self:onPlayerUseBoxCard(player, item)
    elseif item.autoSellDuration then
        self:onPlayerUseAutoSell(player, item)
    elseif item.privilegeType then
        self:onPlayerUsePrivilege(player, item)
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

function M:onPlayerUseBoxCard(player, item)
    print("onPlayerUseItem 玩家 : "..tostring(player.name).. "月卡 item.boxCard "..tostring(item.boxCard).. " item.boxDuration "..tostring(item.boxDuration))
    local allBox = player:getBoxData()
    local boxData = allBox[tostring(item.boxCard)]
    if not boxData or not boxData.payTime then
        return
    end
    if boxData.payTime <= os.time() then
        boxData.payTime = os.time()
    end
    boxData.payTime = boxData.payTime + item.boxDuration*86400--一天86400s
    player:setBoxData(allBox)
    player:refreshBoxCard(item.boxCard, boxData.payTime)
end

function M:onPlayerUseAutoSell(player, item)
    local buyInfo = self:getPlayerBuyInfo(player)
    local autoSellTime =  player:getAutoSellTime()
    print("onPlayerUseItem 玩家 : "..tostring(player.name).. "自动售卖 item.autoWorkDuration "..tostring(item.autoSellDuration))
    local time = autoSellTime - os.time()
    if time <= 0 then
        buyInfo[tostring(item.id)] = BuyStatus.Unlock
        autoSellTime = os.time()
    else
        autoSellTime = autoSellTime + item.autoSellDuration*60
    end
    if time > 0 then
        local function refreshLock()
            local reTime = os.time() - autoSellTime
            print("reTime : "..tostring(reTime))
            if reTime >= 0 then
                local buyInfo1 = self:getPlayerBuyInfo(player)
                local autoSellTime1 =  player:getAutoSellTime()
                print("buyInfo1 ", Lib.v2s(buyInfo1))
                for _, id in pairs(self.config:getAllAutoSellId()) do
                    print("v.id "..tostring(id))
                    buyInfo1[tostring(id)] = BuyStatus.Unlock
                    autoSellTime1 = os.time()
                end
                self:setPlayerBuyInfo(player, buyInfo1)
                player:setAutoSellTime(autoSellTime1)
                LuaTimer:cancel(player.autoSell)
            end
        end
        LuaTimer:cancel(player.autoSell)
        player.autoSell = LuaTimer:scheduleTimer(function()
            refreshLock()
        end, 1000, -1)
    else
        LuaTimer:cancel(player.autoSell)
    end
    self:setPlayerBuyInfo(player, buyInfo)
    player:setAutoSellTime(autoSellTime)
    --更新UI time
    --return
end

function M:onPlayerUsePrivilege(player, item)
    if privilegeType.gold2Plus == item.privilegeType then
        player:openGold2Plus()
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."特权金币 item.privilegeType "..tostring(item.privilegeType))
    elseif privilegeType.hpMaxPlus == item.privilegeType then
        player:openHpMaxPlus()
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."特权血量 item.privilegeType "..tostring(item.privilegeType))
    elseif privilegeType.perExpPlu == item.privilegeType then
        player:openPerExpPlus()
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."特权经验 item.privilegeType "..tostring(item.privilegeType))
    elseif privilegeType.movePlus == item.privilegeType then
        player:setMovePlus()
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."特权移速 item.privilegeType "..tostring(item.privilegeType))
    elseif privilegeType.openRealDmg == item.privilegeType then
        player:setOpenRealDmg()
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."特权伤害 item.privilegeType "..tostring(item.privilegeType))
    elseif privilegeType.InfiniteExp == item.privilegeType then
        player:setInfiniteExp()
        print("onPlayerUseItem 玩家 : "..tostring(player.name).."无限肌肉 item.privilegeType "..tostring(item.privilegeType))
    end
end

local function init()
    M:init()
end

init()

return M