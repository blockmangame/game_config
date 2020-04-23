local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer
local ActivityConfig = T(Config, "ActivityConfig") ---@type ActivityConfig
local settings = {}

local function initActivities()
    settings = ActivityConfig:getSettings()
    for id, activity in pairs(settings) do
        if activity.freshTime > 0 then
            LuaTimer:schedule(function(key, type, config)
                if not Game.CreateProcess(key, type, config) then
                    return
                end
            end, activity.freshTime * 1000, nil, activity.key, activity.type, activity.config)
        end
    end
end

function Game.onActivityFinish(id)
    local setting = ActivityConfig:getSettingById(id)
    if setting and setting.freshTime > 0 then
        LuaTimer:schedule(function(key, type, config)
            if not Game.CreateProcess(key, type, config) then
                return
            end
        end, setting.freshTime * 1000, nil, setting.key, setting.type, setting.config)
    end
end

initActivities()