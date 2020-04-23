local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer
local ProcessManager = T(Game, "ProcessManager")
local ProcessTimer = nil
local ProcessList = T(Game, "ProcessList")

function Game.CreateProcess(key, type, config)
    if ProcessList[key] or not Define.ProcessType[type] then
        return false
    end

    local time = World.Now()
    local setting = {
        key = key,

        waitPlayerTime = 10,
        prepareTime = 10,
        gameTime = 10,
        gameOverTime = 10,
        waitCloseTime = 10,

        startPlayers = 1,
        maxPlayers = -1,

        alwaysCanJoin = false,
        needCloseServer = false,

        createTime = time,
    }

    if config then
        for k, v in pairs(config) do
            setting[k] = v
        end
    end

    local process = Define.ProcessType[type]
    ProcessList[key] = process.new(setting)
    ProcessList[key]:onWaiting()
    return true
end

function Game.RemoveProcess(key)
    if not ProcessList[key] then
        return
    end
    ProcessList[key] = nil
end

function Game.GetProcess(key)
    if ProcessList[key] then
        return ProcessList[key]
    end
end

function Game.EntityJoinProcess(key, entity)
    if not ProcessList[key] then
        return false
    end
    return ProcessList[key]:entityJoin(entity)
end

function Game.EntityLeaveProcess(key, entity)
    if not ProcessList[key] then
        return
    end
    ProcessList[key]:entityOut(entity)
end

function ProcessManager:onTick()
    for key, process in pairs(ProcessList) do
        process:onTick()
    end
end

local function initProcessManager()
    ProcessTimer = LuaTimer:scheduleTimer(function ()
        ProcessManager:onTick()
    end, 1000, -1)
end

initProcessManager()