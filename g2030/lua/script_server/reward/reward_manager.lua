local rewardManager = T(Game, "rewardManager")
local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer

local rewardType = {
    prop = 1,
    box = 2,
}
function rewardManager:doReward(type, object, player)
    if type == rewardType.prop then
        self:doRewardProp(object, player)
    elseif type == rewardType.box then
        self:doRewardBox(object, player)
    end
end

function rewardManager:doRewardProp(object, player)
    local rewar = object:cfg().rewar
    local pos = object:getPosition()
    local map = object.map
    local cd = object:cfg().cd
    local cfgName = object:cfg().cfgName
    LuaTimer:scheduleTimer(function()
        local params1 = {
            cfgName = cfgName, pos = pos, map = map
        }
        local entity = EntityServer.Create(params1)
        if entity then
            Trigger.CheckTriggers(entity:cfg(), "ENTITY_ENTER", {obj1=entity})
        end
    end, cd*1000, 1)
    object:kill(player, "ACTIONS_KILL_ENTITY")
    player:addCurrency(Coin:coinNameByCoinId(rewar.type), rewar.num, "rewardProp")
end

function rewardManager:doRewardBox(object, player)
    local boxId = object:cfg().boxId
    local isNotFree = object:cfg().isNotFree
    local allBox = player:getBoxData()
    if not allBox[tostring(boxId)] then
        allBox[tostring(boxId)] = {}
    end
    local boxData = allBox[tostring(boxId)]
    if boxData and boxData.isGet == true then
        print("boxData.isGet : "..tostring(boxData.isGet))
        return
    end
    if isNotFree then
        --local payItem = player:getPaystamp("paystamp")
        --local config1 = T(Config, "PrivilegeConfig")
        --local itemId = config1:getItemIdBoxCard(boxId)
        --assert(itemId, "payshop is not exit boxId : "..tostring(boxId))
        if not boxData.payTime or boxData.payTime <= os.time() then
            print("onPlayerUseItem 玩家 : "..tostring(player.name).. "提示付费 boxId "..tostring(boxId))
            --if not self.isBuyNoticing then
            --    self:noticePlayerBuy(player)
            --    self.isBuyNoticing = true
            --end
            return
        end
    end
    if not boxData or boxData.useTime == nil or boxData.isGet == nil or (boxData.useTime <= os.time() and boxData.isGet == false) then
        local cd = object:cfg().cd
        local rewar = object:cfg().rewar
        boxData.useTime = os.time() + cd
        boxData.isGet = true
        --临时方案
        LuaTimer:scheduleTimer(function()
            player:sendPacket({
                pid = "HeadCountDown",
                objID = object.objID,
                time = cd
            })
        end, 1000, 1)
        player:addCurrency(Coin:coinNameByCoinId(rewar.type), rewar.num, "rewardBox")
        local function refreshIsGet()
            local reTime = os.time() - boxData.useTime
            print("reTime : "..tostring(reTime))
            if reTime >= 0 then
                local allBox1 = player:getBoxData()
                local boxData1 = allBox1[tostring(boxId)]
                --boxData1.useTime = os.time()
                boxData1.isGet = false
                player:setBoxData(allBox1)
                LuaTimer:cancel(player.boxReGet[boxId])
            end
        end
        player.boxReGet = player.boxReGet or {}
        if player.boxReGet[boxId] then
            LuaTimer:cancel(player.boxReGet[boxId])
        end
        player.boxReGet[boxId] = LuaTimer:scheduleTimer(function()
            refreshIsGet()
        end, 1000, -1)
    end
    player:setBoxData(allBox)
end

return rewardManager





