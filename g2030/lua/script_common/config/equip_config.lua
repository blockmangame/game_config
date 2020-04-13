---@class EquipConfig
local EquipConfig = T(Config, "EquipConfig")

local settings = {}

function EquipConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Equip.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.sortId = tonumber(vConfig.n_sortId) or 0 --n_sortId
        data.name = vConfig.s_name or "" --s_name
        data.icon = vConfig.s_icon or "" --s_icon
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --n_moneyType
        data.price = tonumber(vConfig.n_price) or 0 --n_price
        data.desc = vConfig.s_desc or "" --s_desc
        data.islandLv = tonumber(vConfig.n_islandLv) or 0 --n_islandLv
        data.islandIcon = vConfig.s_islandIcon or "" --s_islandIcon
        data.itemName = vConfig.s_itemName or "" --s_itemName
        data.efficiency = tonumber(vConfig.n_efficiency) or 0 --n_value1
        data.status = Define.BuyStatus.Lock
        if data.moneyType == 0 then
            data.isPay = true
        else
            data.isPay = false
        end
        table.insert(settings, data)
    end
    table.sort(settings, function(a, b)
        return a.sortId < b.sortId
    end)
    --Lib.log_1(settings, "EquipConfig:init")
end

function EquipConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function EquipConfig:getItemBySort(sort)
    if settings[sort] then
        return settings[sort]
    end
    return nil
end

function EquipConfig:getAllItemByPay(isPay)
    local items1 ={}
    local items2 ={}
    for _,v in pairs(settings) do
        if not v.isPay then
            table.insert(items1,v)
        else
            table.insert(items2,v)
        end
    end
    if isPay then
        table.sort(items2, function(a, b)
            return a.sortId < b.sortId
        end)
        return items2
    end
    table.sort(items1, function(a, b)
        return a.sortId < b.sortId
    end)
    return items1
end

function EquipConfig:getNextItemByPay(curId, isPay)
    local items = self:getAllItemByPay(isPay)
    for i=#items, 1, -1 do
        if items[i].id == curId then
            if i==#items then
                return nil
            end
            return items[i+1]
        end
    end
    return nil
end

function EquipConfig:getSettings()
    return settings
end

local function init()
    EquipConfig:init()
end

init()

return EquipConfig
