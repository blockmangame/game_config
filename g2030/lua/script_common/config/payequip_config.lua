---@class PayEquipConfig
local PayEquipConfig = T(Config, "PayEquipConfig")

local settings = {}

function PayEquipConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/PayEquip.csv", 1)
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
        settings[tostring(data.id)] = data
    end
    --Lib.log_1(settings, "PayEquipConfig:init")
    --Lib.log("jumpConfig:init " .. Lib.v2s(settings))
end

function PayEquipConfig:getItemById(id)
    --print("type(id) : "..type(id))
    --print("islandAndAdvanceToUnlockPay id : "..tostring(id).." buyInfo  1:", Lib.v2s(settings, 3))
    for ids, setting in pairs(settings) do
        if ids == tostring(id) then
            return setting
        end
    end
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
