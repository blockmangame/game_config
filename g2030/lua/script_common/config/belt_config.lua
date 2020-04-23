---@class BeltConfig
local BeltConfig = T(Config, "BeltConfig")

local settings = {}

function BeltConfig:init()
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/Belt.csv", 3)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.sortId = tonumber(vConfig.n_sortId) or 0 --n_sortId
        data.name = vConfig.s_name or "" --s_name
        data.icon = vConfig.s_icon or "" --s_icon
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --n_moneyType
        local sprice = Lib.split(vConfig.s_price, ",")
        if data.moneyType ~= 0 then
            data.price = BigInteger.Create(tonumber(sprice[1]),tonumber(sprice[2])) or 0 --s_price
        else
            data.price = tonumber(sprice[1]) or 0 --n_price
        end
        data.desc = vConfig.s_desc or "" --s_desc
        data.islandLv = tonumber(vConfig.n_islandLv) or 0 --n_islandLv
        data.islandIcon = vConfig.s_islandIcon or "" --s_islandIcon
        data.itemName = vConfig.s_itemName or "" --s_itemName
        data.workoutUp = tonumber(vConfig.n_workoutUp) or 0 --n_workoutUp
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
    --Lib.log_1(settings, "BeltConfig:init")
end

function BeltConfig:getItemById(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function BeltConfig:getItemBySort(sort)
    if settings[sort] then
        return settings[sort]
    end
    return nil
end

function BeltConfig:getAllItemByPay(isPay)
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

function BeltConfig:getNextItemByPay(curId, isPay)
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

function BeltConfig:getSettings()
    return settings
end

local function init()
    BeltConfig:init()
end

init()

return BeltConfig
