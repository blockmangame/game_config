local ItemShop = T(Store, "ItemShop")

ItemShop.TabType = {
    Equip = 1,
    Belt = 2,
    Advance = 3,
}

ItemShop.BuyStatus = {
    Lock = 1, --未解锁
    Unlock = 2, --解锁
    Buy = 3, --购买
    Used = 4, --使用
}

function ItemShop:getMoneyIconByMoneyType(moneyType)
    local coinName = Coin:coinNameByCoinId(moneyType)
    assert(coinName, "Coin:coinNameByCoinId(moneyType) ：" .. tostring(moneyType).. " is not a exit")
    return Coin:iconByCoinName(coinName)
end

local function loadConfig(configPath)
    local settings = {}
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/"..tostring(configPath), 1)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --n_id
        data.name = vConfig.s_name or "" --s_name
        data.icon = vConfig.s_icon or "" --s_icon
        data.moneyType = tonumber(vConfig.n_moneyType) or 0 --n_moneyType
        data.price = tonumber(vConfig.n_price) or 0 --n_price
        data.desc = vConfig.s_desc or "" --s_desc
        data.islandLv = tonumber(vConfig.n_islandLv) or 0 --n_islandLv
        data.islandIcon = vConfig.s_islandIcon or "" --s_islandIcon
        data.value1 = tonumber(vConfig.n_value1) or 0 --n_value1
        data.value2 = tonumber(vConfig.n_value2) or 0 --n_value2
        data.value3 = tonumber(vConfig.n_value3) or 0 --n_value3
        data.status = ItemShop.BuyStatus.Lock
        settings[data.id] = data
    end
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings)
    return settings
end

local function loadPayConfig(configPath)
    local settings = {}
    local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/"..tostring(configPath), 1)
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
    table.sort(settings, function(a, b)
        return a.id < b.id
    end)
    --Lib.log_1(settings)
    return settings
end

function ItemShop:initConfig()
    ItemShop.EquipConfig =  loadConfig("Equip.csv")
    ItemShop.PayEquipConfig =  loadPayConfig("PayEquip.csv")
    ItemShop.BeltConfig =  loadConfig("Belt.csv")
    ItemShop.AdvanceConfig =  loadConfig("Advance.csv")
    print("000000000000000000000")
    --Lib.log_1(Coin:GetCoinCfg())
    print(Coin:coinNameByCoinId(0))
    --print(Coin:coinNameByCoinId(1))
    print(Coin:coinNameByCoinId(2))
    print(Coin:coinNameByCoinId(3))
    print(Coin:coinNameByCoinId(4))
    print(Coin:coinNameByCoinId(5))
end

local function init()
    ItemShop:initConfig()
end

init()

return ItemShop