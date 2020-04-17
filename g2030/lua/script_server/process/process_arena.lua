---
--- 竞技场状态流转
---
local class = require"common.class"
local ProcessArena = class("ProcessArena", require"script_server.process.process_base")
local posList = {}
local playerPosList= {}
local arenaMap = nil
local worldCfg = World.cfg

function ProcessArena:ctor(config)
    if config then
        for k, v in pairs(config) do
            self[k] = v
        end
    end
    return self
end
function ProcessBase:onWaiting()
    self:initProcess()
    
end
function ProcessArena:initProcess()
    if not worldCfg.arena then
        self:processOver()
        return
    end
     Lib.subscribeEvent(Event.EVENT_ENTER_ARENA, function (player)
        Game.EntityJoinProcess(self.key, player)
    end)
end
function ProcessArena:onEntityJoin(objID)
    local player = self.entityList[objID]
    if not player then
        return
    end
    if not arenaMap then
        arenaMap = World.CurWorld:createDynamicMap("map_002", true)  
        if not arenaMap then
            self:processOver()
            print("the map can be find!!!")
            return
        end
          for _, pos in pairs(arenaMap.cfg.initPosList) do
            table.insert(posList, pos)
        end
        
    end
    playerPosList[objID] = posList[1]
    table.remove(posList,1)
    player:setMapPos(arenaMap, playerPosList[objID])
    player:setInvincible()
    player:resetArenaScore()
    if self.playerCount >= self.startPlayers and self.curState < Define.ProcessState.Waiting then 
        self:setState(Define.ProcessState.Waiting)
        WorldServer.BroadcastPacket({
            pid = "ArenaTimeCount"
        })
    end
    if self.playerCount == self.maxPlayers then
        self:waitingEnd()
    end

    -- if self.playerCount >= self.startPlayers and not lastTimer then
    --     lastTimer = LuaTimer:scheduleTimer(function()
    --         sendReadyArena()
    --     end, self.waitPlayerTime*1000, 1)
    -- end
    
    
end
function ProcessTeam:onEntityOut(objID)
    local player = self.entityList[objID]
    if not player then
        return
    end
    player:setMapPos(worldCfg.defaultMap,worldCfg.initPos)--TODO 判断当前服务器是否满人
end
function ProcessBase:onWaitingEnd()
    sendReadyArena()
    --TODO 拉取所有用户到对应位置
    self.entityList[objID]
    for id, player in pairs(self.entityList) do
        player:setMapPos(arenaMap, playerPosList[id])
    end
    
end
local function sendReadyArena()
    LuaTimer:cancel(lastTimer)
    WorldServer.BroadcastPacket({
        pid = "ArenaReady"
    })
    function ProcessTeam:needKeepWaiting()
        return self.playerCount == Game.GetAllPlayersCount()
    end
end
function ProcessBase:onStart()
    for id, player in pairs(self.entityList) do
        player:setUninvincible()
    end
end
function ProcessBase:doJudge()
    if self.playerCount<2 then
        self:processOver()
    end
end
function ProcessBase:onProcessOver()
    for id, player in pairs(self.entityList) do
        player:setMapPos(worldCfg.defaultMap,worldCfg.initPos)--TODO 判断此时
    end
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
