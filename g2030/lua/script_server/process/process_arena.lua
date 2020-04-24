---
--- 竞技场状态流转
---
local class = require"common.class"
local ProcessArena = class("ProcessArena", require"script_server.process.process_base")
local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer
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

    -- LuaTimer:schedule(function()
    --     local allEntity = World.CurWorld:getAllEntity()
    --     for _, ent in pairs(allEntity) do
    --         if ent._cfg.delayMove then
    --             local pos = ent:getPosition()
    --             ent.forceTargetPos = Lib.tov3({x = pos.x+ent._cfg.delayMove.x , y = pos.y + ent._cfg.delayMove.y, z = pos.z+ent._cfg.delayMove.z })
    --             ent.forceTime = 20*ent._cfg.delayMove.time
    --             ent:entityForceTargetPos( {x=ent._cfg.delayMove.x,y=ent._cfg.delayMove.y,z=ent._cfg.delayMove.z }, true)
    --         end
    --     end
    -- end, 10 * 1000, nil)


    player:intoArenaWorld()
    if (self.playerCount >= self.startPlayers or true) and self.curState < Define.ProcessState.Waiting then --TEST
        self:setState(Define.ProcessState.Waiting)
        self:sendArenaStateChange(self.waitPlayerTime)
        -- WorldServer.BroadcastPacket({
        --     pid = "ArenaTimeCount",
        --     time = self.waitPlayerTime
        -- })
    end
    if self.playerCount == self.maxPlayers then
        self:waitingEnd()
    end
    
end
function ProcessArena:onEntityOut(objID)
    local player = self.entityList[objID]
    if not player then
        return
    end
    player:setMapPos(worldCfg.defaultMap,worldCfg.initPos)--TODO 判断当前服务器是否满人
end
function ProcessArena:onWaitingEnd()
    --sendReadyArena()
    self:sendArenaStateChange(self.prepareTime)
    --TODO 拉取所有用户到对应位置
    -- self.entityList[objID]
    for id, player in pairs(self.entityList) do
        player:setMapPos(self.arenaMap, self.playerPosList[id])
    end
    
end
local function sendReadyArena()
    WorldServer.BroadcastPacket({
        pid = "ArenaReady",
        time = self.prepareTime
    })
end
local function openAllDoor()
    local allEntity = World.CurWorld:getAllEntity()
        for _, ent in pairs(allEntity) do
            if ent._cfg.delayMove then
                local pos = ent:getPosition()
                ent.forceTargetPos = Lib.tov3({x = pos.x+ent._cfg.delayMove.x , y = pos.y + ent._cfg.delayMove.y, z = pos.z+ent._cfg.delayMove.z })
                ent.forceTime = 20*ent._cfg.delayMove.time
                ent:entityForceTargetPos( {x=ent._cfg.delayMove.x,y=ent._cfg.delayMove.y,z=ent._cfg.delayMove.z }, true)
            end
        end
end
local function sendFightArena(self)
    WorldServer.BroadcastPacket({--广播比赛倒计时到前端
        pid = "ArenaFight",
        time = self.gameTime
    })
    openAllDoor()--打开笼门
end
function ProcessArena:onStart()
    --sendFightArena(self)
    self:sendArenaStateChange(self.prepareTime)
    openAllDoor()
    for id, player in pairs(self.entityList) do--解除无敌
        player:setUninvincible()
    end

end
function ProcessArena:doJudge()
    if self.playerCount<2 then
        self:processOver()
    end
end
function ProcessArena:onProcessOver()
    self:sendArenaStateChange(self.gameOverTime)
    -- WorldServer.BroadcastPacket({--广播竞技场关闭
    --     pid = "ArenaWillClose",
    --     time = self.gameOverTime
    -- })
    
    
end
function ProcessArena:onProcessOverEnd()
    for id, player in pairs(self.entityList) do
        player:setMapPos(worldCfg.defaultMap,worldCfg.initPos)--TODO 判断此时
    end
end

function ProcessArena:sendArenaStateChange(time)
    WorldServer.BroadcastPacket({--广播竞技场关闭
        pid = "ArenaStateChange",
        state = self.curState,
        time = time
    })
end
return ProcessArena
