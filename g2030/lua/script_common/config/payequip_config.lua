---@class PayEquipConfig
local PayEquipConfig = T(Config, "PayEquipConfig")

local settings = {}

function PayEquipConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/PayEquip.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --id
        data.unlockAdvancedLevel = tonumber(vConfig.n_unlockAdvancedLevel) or 0 --解锁需要的进阶等级
        data.invailedAdvancedLevel = tonumber(vConfig.n_invailedAdvancedLevel) or 0 --失效的进阶等级
        data.efficiencyPercentage = tonumber(vConfig.n_efficiencyPercentage) or 0 --锻炼肌肉量百分比
        data.efficiencyFix = tonumber(vConfig.n_efficiencyFix) or 0 --锻炼肌肉量固定值
        data.efficiencyFixDes  = vConfig.s_efficiencyFixDes or "" --锻炼肌肉量固定值描述
        data.efficiencyFixHuge = tonumber(vConfig.n_efficiencyFixHuge) or 0 --无限肌肉锻炼肌肉量固定值
        data.efficiencyFixHugeDes = vConfig.s_efficiencyFixHugeDes or "" --无限肌肉锻炼肌肉量固定值描述
        table.insert(settings, data)
    end
end

function PayEquipConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    --assert(false, "PayEquipConfig:getItemById(id) ：" .. tostring(id).. " is not a exit")
    return nil
end

function PayEquipConfig:getSettings()
    return settings
end

local function init()
    PayEquipConfig:init()
end

init()

return PayEquipConfig
