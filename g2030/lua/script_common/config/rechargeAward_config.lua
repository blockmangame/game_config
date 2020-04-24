--- Created by lxm.

local rechargeAwardConfig = T(Config, "rechargeAwardConfig")

local Items = {}
function rechargeAwardConfig:initConfig()
    local temp = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/rechargeAward.csv", 3) or {}
    for _, config in pairs(temp) do
        local data = {
            id = tonumber(config.n_id),
            type = tonumber(config.n_type),
            goodsType = tonumber(config.n_goodsType),
            goodsId = tonumber(config.n_goodsId),
            icon = tostring(config.s_icon),
            specialName = tostring(config.s_specialName),
            count = tonumber(config.n_count),
            condition = tonumber(config.n_condition),
        }
        table.insert(Items, data)
    end
    table.sort(Items, function(a, b)
        return a.id < b.id
    end)
end

function rechargeAwardConfig:getItemByItemId(itemId)
    for i, item in pairs(Items) do
        if item.id == itemId then
            return item
        end
    end
end

function rechargeAwardConfig:getItems()
    return Items
end


function rechargeAwardConfig:getRewardTypeItems(awardType)
    local Items1 = {}
    local condition = nil
    for i, item in pairs(Items) do
        if item.type == awardType then
            table.insert(Items1, item)
            condition = item.condition
        end
    end
    return Items1,condition
end

return rechargeAwardConfig