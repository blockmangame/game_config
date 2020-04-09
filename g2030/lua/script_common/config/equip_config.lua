---@class EquipConfig
local EquipConfig = T(Config, "EquipConfig")

local settings = {}

function EquipConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Equip.csv", 1)
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
        data.equipName = vConfig.s_equipName or "" --s_equipName
        data.efficiency = tonumber(vConfig.n_efficiency) or 0 --n_value1
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
    --Lib.log_1(settings, "EquipConfig:init")
    --Lib.log("jumpConfig:init " .. Lib.v2s(settings))
end

function EquipConfig:getSettings()
    return settings
end

local function init()
    EquipConfig:init()
end

init()

return EquipConfig
