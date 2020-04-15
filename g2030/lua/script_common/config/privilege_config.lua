---@class PrivilegeConfig
local PrivilegeConfig = T(Config, "PrivilegeConfig")

local settings = {}

function PrivilegeConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Privilege.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.sortId = tonumber(vConfig.n_sortId) or 0 --n_sortId
        data.name = vConfig.s_name or "" --名字
        data.icon = vConfig.s_icon or "" --图片
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --货币
        data.price = tonumber(vConfig.n_price) or 0 --价格
        if vConfig.n_boxCard ~= "#" then
            data.boxCard = tonumber(vConfig.n_boxCard) or 0 --月卡宝箱id
        end
        if vConfig.n_boxDuration ~= "#" then
            data.boxDuration = tonumber(vConfig.n_boxDuration) or 0 --月卡宝箱时长(天）
        end
        if vConfig.n_autoWorkDuration ~= "#" then
            data.autoWorkDuration = tonumber(vConfig.n_autoWorkDuration) or 0 --自动锻炼（分钟）
        end
        if vConfig.n_autoSellDuration ~= "#" then
            data.autoSellDuration = tonumber(vConfig.n_autoSellDuration) or 0 --自动售卖（分钟）
        end
        if vConfig.n_privilegeType ~= "#" then
            data.privilegeType = tonumber(vConfig.n_privilegeType) or 0 --自动售卖（分钟）
        end
        --if vConfig.n_privilegeDouble ~= "#" then
        --    data.privilegeDouble = tonumber(vConfig.n_privilegeDouble) or 0 --自动售卖（分钟）
        --end
        data.status = Define.BuyStatus.Unlock
        table.insert(settings, data)
    end
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings, "Privilege:init")
    --Lib.log_1(settings[#settings], "Privilege:init")
end

function PrivilegeConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function PrivilegeConfig:getSettings()
    return settings
end

local function init()
    PrivilegeConfig:init()
end

init()

return PrivilegeConfig
