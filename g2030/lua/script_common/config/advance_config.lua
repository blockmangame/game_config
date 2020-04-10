---@class AdvanceConfig
local AdvanceConfig = T(Config, "AdvanceConfig")

local settings = {}

function AdvanceConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Advance.csv", 1)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.name = vConfig.s_name or "" --s_name
        data.icon = vConfig.s_icon or "" --s_icon
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --n_moneyType
        data.price = tonumber(vConfig.n_price) or 0 --n_price
        data.desc = vConfig.s_desc or "" --s_desc
        data.islandLv = tonumber(vConfig.n_islandLv) or 0 --n_islandLv
        data.islandIcon = vConfig.s_islandIcon or "" --s_islandIcon
        data.level = tonumber(vConfig.n_level) or 0 --n_level
        data.attack = tonumber(vConfig.n_attack) or 0 --n_attack
        data.speed = tonumber(vConfig.n_speed) or 0 --n_speed
        data.workout = tonumber(vConfig.n_workout) or 0 --n_workout
        data.status = 1
        if data.moneyType == 0 then
            data.isPay = true
        else
            data.isPay = false
        end
        settings[data.id] = data
    end
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings, "AdvanceConfig:init")
    --Lib.log("jumpConfig:init " .. Lib.v2s(settings))
end

function AdvanceConfig:getSettings()
    return settings
end

local function init()
    AdvanceConfig:init()
end

init()

return AdvanceConfig
