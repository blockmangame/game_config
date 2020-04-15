---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/4/7 12:30
---
local class = require"common.class"
local ProcessBase = class()
ProcessBase.entityList = {}
ProcessBase.playerCount = 0
ProcessBase.curState = Define.ProcessState.Init

function ProcessBase:ctor(config)
    if config then
        for k, v in pairs(config) do
            self[k] = v
        end
    end
    return self
end

function ProcessBase:onTick()
    self.curTick = (self.curTick or 0) + 1

    if self.curState == Define.ProcessState.Waiting then
        self:waitPlayerOnTick()
    end

    if self.curState == Define.ProcessState.Prepare then
        self:prepareOnTick()
    end

    if self.curState == Define.ProcessState.ProcessStart then
        self:processOnTick()
    end

    if self.curState == Define.ProcessState.ProcessOver then
        self:processOverOnTick()
    end

    if self.curState == Define.ProcessState.WaitClose then
        self:waitCloseOnTick()
    end
end

function ProcessBase:setState(state)
    self.curState = state
end

function ProcessBase:getState()
    return self.curState
end

function ProcessBase:getPlayersInProcess()
    return self.curPlayers
end

function ProcessBase:onWaiting()
    self:initProcess()
    self:setState(Define.ProcessState.Waiting)
end

function ProcessBase:initProcess()

end

function ProcessBase:waitPlayerOnTick()
    local seconds = (self.waitPlayerTime - self.curTick) % self.waitPlayerTime
    if seconds <= 0 or self:needKeepWaiting() then
        self:waitingEnd()
        return
    end
end

function ProcessBase:needKeepWaiting()
    return false
end

function ProcessBase:waitingEnd()
    self.waitingEndTick = self.curTick
    self:setState(Define.ProcessState.Prepare)
    self:onWaitingEnd()
end

function ProcessBase:onWaitingEnd()

end

function ProcessBase:prepareOnTick()
    local seconds = self.prepareTime - (self.curTick - self.waitingEndTick)
    if seconds <= 0 then
        self:prepareEnd()
    end
end

function ProcessBase:prepareEnd()
    self.prepareEndTick = self.curTick
    self:setState(Define.ProcessState.ProcessStart)
    self:onStart()
end

function ProcessBase:onStart()

end

function ProcessBase:processOnTick()
    local seconds = self.gameTime - (self.curTick - self.prepareEndTick)
    if seconds <= 0 then
        self:processOver()
    else
        self:doJudge()
    end
end

function ProcessBase:processOver()
    self.processOverTick = self.curTick
    self:setState(Define.ProcessState.ProcessOver)
    self:onProcessOver()
end

function ProcessBase:onProcessOver()

end

function ProcessBase:processOverOnTick()
    local seconds = self.gameOverTime - (self.curTick - self.processOverTick)
    if seconds <= 0 then
        self:closeServer()
    end
end

function ProcessBase:closeServer()
    self.processOverEndTick = self.curTick
    if self.needCloseServer then
        self:setState(Define.ProcessState.WaitClose)
    else
        self:removeProcess()
    end
    self:onProcessOverEnd()
end

function ProcessBase:onProcessOverEnd()

end

function ProcessBase:waitCloseOnTick()
    local seconds = self.waitCloseTime - (self.curTick - self.processOverEndTick)
    if seconds <= 0 then
        self:removeProcess()
        Game.StopServer()
    end
end

function ProcessBase:removeProcess()
    Game.RemoveProcess(self.key)
end

function ProcessBase:canJoin()
    if self.curState < Define.ProcessState.ProcessStart then
        return self.playerCount < self.maxPlayers or self.maxPlayers < 0
    else
        return self.alwaysCanJoin
    end
end

function ProcessBase:entityJoin(entity)
    if not self:canJoin() then
        return false
    end
    local objID = entity.objID
    self.entityList[objID] = entity
    if entity.isPlayer then
        self.playerCount = self.playerCount + 1
    end
    self:onEntityJoin(objID)
    return true
end

function ProcessBase:onEntityJoin(objID)

end

function ProcessBase:entityOut(entity)
    local objID = entity.objID
    if self.entityList[objID] == nil then
        return
    end
    self.entityList[objID] = nil
    if entity.isPlayer then
        self.playerCount = self.playerCount - 1
    end
    self:onEntityOut(objID)
end

function ProcessBase:onEntityOut(objID)

end

function ProcessBase:isEntityInProcess(objID)
    if self.entityList[objID] == nil then
        return false
    end
    return false
end

function ProcessBase:doJudge()

end

return ProcessBase