---
--- 竞技场状态流转
---
local class = require"common.class"
local ProcessArena = class("ProcessArena", require"script_server.process.process_base")
local posList = {}
local playerPosList= {}
-- local arenaMap = nil
local worldCfg = World.cfg

function ProcessArena:ctor(config)
    if config then
        for k, v in pairs(config) do
            self[k] = v
        end
    end
    return self
end

function ProcessArena:resetPlayerPos(player)
    if player.isPlayer then
        player:setMapPos(self.arenaMap, self.playerPosList[player.objID])
    end
end

function ProcessArena:onWaiting()
    self:initProcess()
    
end
function ProcessArena:initProcess()
    if not worldCfg.arena then
        self:processOver()
        return
    end
    self.playerPosList = {}
    self.arenaMap = nil
     Lib.subscribeEvent(Event.EVENT_ENTER_ARENA, function (player)
        Game.EntityJoinProcess(self.key, player)
    end)
end
function ProcessArena:onEntityJoin(objID)
    local player = self.entityList[objID]
    if not player then
        return
    end
    if not self.arenaMap then
        self.arenaMap = World.CurWorld:createDynamicMap("map002", true)
        if not self.arenaMap then
            self:processOver()
            print("the map can be find!!!")
            return
        end
          for _, pos in pairs(self.arenaMap.cfg.initPosList) do
            table.insert(posList, pos)
        end
        
    end
    self.playerPosList[objID] = posList[1]
    table.remove(posList,1)
    player:setMapPos(self.arenaMap, self.arenaMap.cfg.centerPos)

    player:intoArenaWorld()
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
function ProcessArena:onEntityOut(objID)
    local player = self.entityList[objID]
    if not player then
        return
    end
    player:setMapPos(worldCfg.defaultMap,worldCfg.initPos)--TODO 判断当前服务器是否满人
end
function ProcessArena:onWaitingEnd()
    sendReadyArena()
    --TODO 拉取所有用户到对应位置
    -- self.entityList[objID]
    for id, player in pairs(self.entityList) do
        player:setMapPos(self.arenaMap, self.playerPosList[id])
    end
    
end
local function sendReadyArena()
    LuaTimer:cancel(lastTimer)
    WorldServer.BroadcastPacket({
        pid = "ArenaReady"
    })
end
function ProcessArena:onStart()
    for id, player in pairs(self.entityList) do
        player:setUninvincible()
    end
end
function ProcessArena:doJudge()
    if self.playerCount<2 then
        self:processOver()
    end
end
function ProcessArena:onProcessOver()
    for id, player in pairs(self.entityList) do
        player:setMapPos(worldCfg.defaultMap,worldCfg.initPos)--TODO 判断此时
    end
end
return ProcessArena
