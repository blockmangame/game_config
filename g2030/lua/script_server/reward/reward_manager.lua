local rewardManager = T(Game, "rewardManager")
local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer

local rewardType = {
    prop = 1,
    box = 2,
}

local allRewardBox = {}

function rewardManager:remarkAllBox(object)
    --print("=== allBox[boxId] : ",1111111)
    --if type == rewardType.box then
    if not object  then
        return
    end
    local boxId = object:cfg().boxId
    --if boxId == 2 then
    --    return
    --end
    if not allRewardBox[boxId] then
        allRewardBox[boxId] = object
    end
    print("=== rewardManager:remarkAllBox : ", Lib.v2s(allRewardBox))
    --local entity = World.CurWorld:getEntity(packet.objID)
    --assert(entity)
end

function rewardManager:initAllBoxByPlayer(player)
    --local boxId = object:cfg().boxId
    --local isNotFree = object:cfg().isNotFree
    local allBox = player:getBoxData()
    print("=== initAllBoxByPlayer[boxId] 111 allBox: ", Lib.v2s(allBox))
    for nId, box in pairs(allRewardBox) do
        local isFind = false
        local reTime = 0
        local useTime = os.time()
        for sId, info in pairs(allBox) do
            if tonumber(sId) == nId  then
                isFind = true
                if info.useTime > useTime then
                    useTime = info.useTime
                    player:refreshBoxGet(nId, info.useTime)
                else
                    info.isGet = false
                    info.useTime = os.time()
                end
            end
        end
        if not isFind then
            allBox[tostring(nId)] = {
                isGet = false,
                useTime = os.time(),
                payTime = os.time(),
            }
        end
        self:refreshBoxByUseTime(player, nId, useTime)
        print("=== initAllBoxByPlayer[boxId] isFind : ", isFind)
        print("=== initAllBoxByPlayer[boxId] reTime : ", reTime)
    end
    player:setBoxData(allBox)
    --print("=== initAllBoxByPlayer[boxId]allRewardBox : ", Lib.v2s(allRewardBox))
    --print("=== initAllBoxByPlayer[boxId] 222 allBox: ", Lib.v2s(allBox))
end

function rewardManager:doRewardByType(type, object, player)
    if type == rewardType.prop then
        self:doRewardProp(object, player)
    elseif type == rewardType.box then
        self:doRewardBox(object, player)
    end
end

function rewardManager:doRewardProp(object, player)
    --local rewar = object:cfg().rewar
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
    print("player.platformUserId : "..tostring(player.platformUserId))
    player:doReward(object:cfg().rewar.type, object:cfg().rewar.num, "rewardBox")
end

function rewardManager:doRewardBox(object, player)
    local boxId = object:cfg().boxId
    local isNotFree = object:cfg().isNotFree
    local allBox = player:getBoxData()
    local boxData = allBox[tostring(boxId)]
    if not boxData then
        return
    end
    if boxData.isGet == true then
        print("player.platformUserId : "..tostring(player.platformUserId).. "boxData.isGet : "..tostring(boxData.isGet))
        return
    end
    if isNotFree then
        if os.time() >= boxData.payTime then
            print("onPlayerUseItem 玩家 : "..tostring(player.name).. "提示付费 boxId "..tostring(boxId))
            return
        end
    end
    if os.time() >= boxData.useTime and boxData.isGet == false then
        boxData.useTime = os.time() + object:cfg().cd
        boxData.isGet = true
        player:refreshBoxGet(boxId, boxData.useTime)
        player:doReward(object:cfg().rewar.type, object:cfg().rewar.num, "rewardBox")
        self:refreshBoxByUseTime(player, boxId, boxData.useTime)
    end
    player:setBoxData(allBox)
end

function rewardManager:refreshBoxByUseTime(player, boxId, useTime)
    local object = allRewardBox[boxId]
    if not player or not object then
        return
    end
    --SceneUIManager.RemoveEntityHeadUI(object.objID)
    --LuaTimer:scheduleTimer(function()
    print("====bject:cfg().boxId :  "..tostring(object:cfg().boxId))
    print("==== packet.time :  "..tostring(useTime))
    print("==== os.time() :  "..tostring( os.time()))
        player:sendPacket({
            pid = "HeadCountDown",
            objID = object.objID,
            time = {
                num = object:cfg().rewar.num,
                type = object:cfg().rewar.type,
                time = useTime,
                otime = os.time()
            }
        })
    --end, 1000, 1)
end

return rewardManager





