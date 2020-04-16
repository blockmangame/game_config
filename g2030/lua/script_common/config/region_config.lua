---@class RegionConfig
local RegionConfig = T(Config, "RegionConfig")

local settings = {}

function RegionConfig:init(config)
    for _, vConfig in pairs(config) do
        local data = {}
        data.regionId = tonumber(vConfig.n_regionId) or 0 --n_regionId
        data.regionKey = vConfig.s_regionKey or "" --s_regionKey
        data.regionName = vConfig.s_regionName or "" --s_regionName
        data.regionType = tonumber(vConfig.n_regionType) or 0 --n_regionType
        data.regionFunctionType = tonumber(vConfig.n_regionFunctionType) or 0 --n_regionFunctionType
        table.insert(settings, data)
    end
end

function RegionConfig:getRegionConfig(regionKey)
    for _, v in pairs(settings) do
        if v.regionKey == regionKey then
            return v
        end
    end
    return nil
end

return RegionConfig
