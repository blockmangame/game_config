---@class PropConfig
local PropConfig = T(Config, "PropConfig")

local settings = {}

function PropConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Prop.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.sortId = tonumber(vConfig.n_sortId) or 0 --n_sortId
        data.name = vConfig.s_name or "" --名字
        data.icon = vConfig.s_icon or "" --图片
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --货币
        data.price = tonumber(vConfig.n_price) or 0 --价格
        if vConfig.n_islandNotForever ~= "#" then
            data.islandNotForever = tonumber(vConfig.n_islandNotForever) or 0 --n_islandNotForever
        end
        if vConfig.n_islandForever ~= "#" then
            data.islandForever = tonumber(vConfig.n_islandForever) or 0 --n_islandForever
        end
        if vConfig.n_bagCapacity ~= "#" then
            data.bagCapacity = tonumber(vConfig.n_bagCapacity) or 0 --n_bagCapacity
        end
        if vConfig.n_petType ~= "#" then
            data.petType = tonumber(vConfig.n_petType) or 0 --n_islandNotForever
        end
        if vConfig.n_petId ~= "#" then
            data.petId = tonumber(vConfig.n_petId) or 0 --n_petId
        end
        --data.islandForever = tonumber(vConfig.n_islandForever) or 0 --n_islandForever
        --data.bagCapacity = tonumber(vConfig.n_bagCapacity) or 0 --n_bagCapacity
        --data.petType = tonumber(vConfig.n_petType) or 0 --n_petType
        --data.petId = tonumber(vConfig.n_petId) or 0 --n_petId
        data.status = Define.BuyStatus.Unlock
        table.insert(settings, data)
    end
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings, "PropConfig:init")
    --Lib.log_1(settings[#settings], "PropConfig:init")
end

function PropConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function PropConfig:getSettings()
    return settings
end

local function init()
    PropConfig:init()
end

init()

return PropConfig
