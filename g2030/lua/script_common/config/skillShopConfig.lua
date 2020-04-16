--- Created by lxm.

local skillShopConfig = T(Config, "skillShopConfig")

local Items = {}
function skillShopConfig:initConfig()
    local temp = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/skillShopItems.csv", 3) or {}
    for _, config in pairs(temp) do
        local data = {
            id = tonumber(config.n_index),
            skillId = tonumber(config.n_goodsId),
            tabId = tonumber(config.n_tabId),
            type = tonumber(config.n_type),
            muscle = tostring(config.n_muscle),
            camp = config.n_camp,
            name = tostring(config.s_name),
            desc = tostring(config.s_desc),
            icon = tostring(config.s_icon),
            moneyType = tonumber(config.n_moneyType),
            price = tonumber(config.n_price) or 0,
            status = Define.SkillStatus.NoStudy
        }
        data.placeId = 1
        if data.moneyType == 0 then
            data.isPay = true
        else
            data.isPay = false
        end
        table.insert(Items, data)
    end
    table.sort(Items, function(a, b)
        return a.skillId < b.skillId
    end)
end

function skillShopConfig:getItemByItemId(itemId)
    for i, item in pairs(Items) do
        if item.skillId == itemId then
            return item
        end
    end
end

function skillShopConfig:getItems()
    return Items
end

function skillShopConfig:getAllItemByPay(isPay)
    local items1 ={}
    local items2 ={}
    for _,v in pairs(Items) do
        if not v.isPay then
            table.insert(items1,v)
        else
            table.insert(items2,v)
        end
    end
    if isPay then
        table.sort(items2, function(a, b)
            return a.skillId < b.skillId
        end)
        return items2
    end
    table.sort(items1, function(a, b)
        return a.skillId < b.skillId
    end)
    return items1
end

return skillShopConfig