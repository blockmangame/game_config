---@class ActivityConfig
local ActivityConfig = T(Config, "ActivityConfig")
local settings = {}

function ActivityConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/activityProcess.csv")
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id)
        data.type = vConfig.s_type
        data.key = vConfig.s_key
        data.freshTime = tonumber(vConfig.n_freshTime)
        data.config = {
            waitPlayerTime = tonumber(vConfig.n_waitPlayerTime),
            prepareTime = tonumber(vConfig.n_prepareTime),
            gameTime = tonumber(vConfig.n_gameTime),
            gameOverTime = tonumber(vConfig.n_gameOverTime),
            waitCloseTime = tonumber(vConfig.n_waitCloseTime),

            startPlayers = tonumber(vConfig.n_startPlayers),
            maxPlayers = tonumber(vConfig.n_maxPlayers),

            alwaysCanJoin = tonumber(vConfig.n_alwaysCanJoin) == 1,
            needCloseServer = tonumber(vConfig.n_needCloseServer) == 1
        }
        settings[data.id] = data
    end
end

function ActivityConfig:getSettings()
    return settings
end

function ActivityConfig:getSettingById(id)
    return settings[id]
end

local function init()
    ActivityConfig:init()
end

init()

return ActivityConfig

