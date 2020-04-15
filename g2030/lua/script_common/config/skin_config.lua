---@class SkinConfig
local SkinConfig = T(Config, "SkinConfig")

local settings = {}

function SkinConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Skin.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.sortId = tonumber(vConfig.n_sortId) or 0 --n_sortId
        data.name = vConfig.s_name or "" --名字
        data.icon = vConfig.s_icon or "" --图片
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --货币
        data.price = tonumber(vConfig.n_price) or 0 --价格
        data.actor = vConfig.s_actor or 0 --模型
        data.sex = tonumber(vConfig.n_sex) or 0 --性别(1:男，2:女)
        data.status = Define.BuyStatus.Unlock
        table.insert(settings, data)
    end
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings, "SkinConfig:init")
    --Lib.log_1(settings[#settings], "SkinConfig:init")
end

function SkinConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function SkinConfig:getSettings()
    return settings
end

local function init()
    SkinConfig:init()
end

init()

return SkinConfig
