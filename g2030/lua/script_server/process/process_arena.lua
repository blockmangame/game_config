---
--- 竞技场状态流转
---
local class = require"common.class"
local ProcessArena = class("ProcessArena", require"script_server.process.process_base")
local teamCountList = {}
local teamPosList = {}
local worldCfg = World.cfg

function ProcessArena:ctor(config)
    if config then
        for k, v in pairs(config) do
            self[k] = v
        end
    end
    return self
end

function ProcessArena:initProcess()
    if not worldCfg.arena then
        self:processOver()
        return
    end
    for _, info in pairs(worldCfg.team) do
        if info.id ~= Define.Team.Neutrality and not teamCountList[info.id] then
            teamCountList[info.id] = 0
        end
    end
    --发送邀请提示
     Lib.subscribeEvent(Event.EVENT_LEVEL_CHANGE, function (player)
        if  player>1 then
            self.state = "OPEN"
        end
    end)
end

-- function ProcessTeam:onWaitingEnd()
--     WorldServer.BroadcastPacket({
--         pid = "ShowGauntlet",
--         isShow = false
--     })
-- end

-- function ProcessTeam:needKeepWaiting()
--     return self.playerCount == Game.GetAllPlayersCount()
-- end

-- function ProcessTeam:doJudge()
--     local surviveTeam = 0
--     for id, count in pairs(teamCountList) do
--         if count > 0 then
--             surviveTeam = surviveTeam + 1
--             winner = id
--         end
--     end
--     if surviveTeam == 1 then
--         self:processOver()
--     end
-- end

-- function ProcessTeam:onEntityJoin(objID)
--     local player = self.entityList[objID]
--     if not player then
--         return
--     end
--     local teamId = player:getTeamId()
--     if not teamCountList[teamId] then
--         teamCountList[teamId] = 0
--     end
--     teamCountList[teamId] = teamCountList[teamId] + 1
--     self:transferIn(objID)
-- end

-- function ProcessTeam:transferIn(objID)
--     local player = self.entityList[objID]
--     if not player then
--         return
--     end
--     --传送，记录坐标
--     if not teamPosList[objID] then
--         teamPosList[objID] = worldCfg.initPos
--     end
--     teamPosList[objID] = player:getPosition()
-- end

-- function ProcessTeam:onEntityOut(objID)
--     local player = self.entityList[objID]
--     if not player then
--         return
--     end
--     local teamId = player:getTeamId()
--     teamCountList[teamId] = teamCountList[teamId] - 1
--     self:transferOut(objID)
-- end

-- function ProcessTeam:transferOut(objID)
--     local player = World.CurWorld:getEntity(objID)
--     local pos = teamPosList[objID] or worldCfg.initPos
--     teamPosList[objID] =  nil
--     if not player then
--         return
--     end
--     player:setPosition(pos)
-- end

return ProcessArena
