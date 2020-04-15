---@class ResourceConfig
local ResourceConfig = T(Config, "ResourceConfig")

local settings = {}

function ResourceConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Resource.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.sortId = tonumber(vConfig.n_sortId) or 0 --n_sortId
        data.name = vConfig.s_name or "" --名字
        data.icon = vConfig.s_icon or "" --图片
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --货币
        data.price = tonumber(vConfig.n_price) or 0 --价格
        data.currencyType = tonumber(vConfig.n_currencyType) or 0 --买到的货币类型
        data.currencyNum = tonumber(vConfig.n_currencyNum) or 0 --买到的货币数量
        data.status = Define.BuyStatus.Unlock
        table.insert(settings, data)
    end
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings, "ResourceConfig:init")
    --Lib.log_1(settings[#settings], "ResourceConfig:init")
end



function ResourceConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function ResourceConfig:getSettings()
    return settings
end

local function init()
    ResourceConfig:init()
end

init()

return ResourceConfig
