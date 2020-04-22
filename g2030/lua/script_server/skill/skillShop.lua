
--- Created by lxm.


local skillShopConfig = T(Config, "skillShopConfig")

local ItemStatus = {
    Buy = 1, --购买
    Used = 2, --已购买   装备
    Using = 3, --使用中   卸载
}

local skillShop = {}
function skillShop:onButtonClick(player, itemId, status, placeId)
    print("!!!!!config--..........................")

    local config = skillShopConfig:getItemByItemId(itemId)
    if not config then
        print("!!!!!config--nil")
        return
    end
    if status == ItemStatus.Buy then
        self:onSkillShopItemBuy(player, itemId, status)
    elseif status == ItemStatus.Used then
        self:onSkillShopEquip(player, itemId, status, placeId)
    elseif status == ItemStatus.Using then
        self:onSkillShopUnEquip(player, itemId, status)
    end
end

function skillShop:syncSkillMap(player)
    local EquipSkills = self:getEquipSkillInfo(player)
    local data = {}
    for _, value in pairs(EquipSkills or {}) do
        data[value.itemName] = value.placeId
    end
    player:data("skill").addSkill = data
    player:syncSkillMap()
    -- print("-----------itemName------------  ".. Lib.v2s(player:data("skill")))
    -- Lib.emitEvent(Event.EVENT_SHOW_SKILL, {}, false)
end

---卸载
function skillShop:onSkillShopUnEquip(player, id, status)
    self:updateSkillShopEquip(player, id, status)
end

----使用
function skillShop:onSkillShopEquip(player, id, status, placeId)
    self:updateSkillShopEquip(player, id, status, placeId)
end

---购买
function skillShop:onSkillShopItemBuy(player, id, status)
    -- print("onSkillShopItemBuy---------------")
    if not player then
        return 
    end
    local item = skillShopConfig:getItemByItemId(id)
    if not item then
        return 
    end

    local StudySkills = self:getStudySkillInfo(player)
    local isExist = false
    for id, value in pairs(StudySkills or {}) do
        if tostring(item.id) == id then
            isExist = true
        end
    end
    --todo 扣钱操作
    if not isExist then
        if item.moneyType == 0 then
            player:consumeDiamonds("gDiamonds", item.price, function(ret)
                if ret then
                    -- self:onBuyItemSuccess(player, id, status)
                    self:syncStudySkillMap(player,item,StudySkills)
                    return true
                end
            end)
        else
            local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.moneyType), item.price, false, false, "skillControl")
            if checkMoney then
                self:syncStudySkillMap(player,item,StudySkills)
                return true
            end
        end
    end
end

function skillShop:syncStudySkillMap(player,item,StudySkills)
    item.status = Define.SkillStatus.Study
    StudySkills[tostring(item.id)] = item
    -- print("----------------" .. tostring(item.status))
    self:setStudySkillInfo(player,StudySkills)
end

function skillShop:getStudySkillInfo(player)
    return player:getStudySkill()
end

function skillShop:setStudySkillInfo(player, buyInfo)
    player:setStudySkill(buyInfo)
end

function skillShop:getEquipSkillInfo(player)
    return player:getEquipSkill()
end

function skillShop:setEquipSkillInfo(player, buyInfo)
    player:setEquipSkill(buyInfo)
end

function skillShop:updateSkillShopEquip(player, id, status, placeId)
    local item = skillShopConfig:getItemByItemId(id)

    local EquipSkills = self:getEquipSkillInfo(player)
    if status == ItemStatus.Used then

        item.status = ItemStatus.Using
        item.placeId = placeId
        EquipSkills[tostring(item.id)] = item
        -- print("------skillShopConfig----------" .. Lib.v2s(EquipSkills)..tostring(item.placeId))

        self:setEquipSkillInfo(player,EquipSkills)
    elseif status == ItemStatus.Using then
        -- print("------skillShopConfig----------" .. tostring(item.status))
        local eid = false
        item.status = ItemStatus.Used
        for key, value in pairs(EquipSkills) do
            if tostring(item.id) == key then
                eid = key
            end
        end
        if eid then
            EquipSkills[eid] = nil
        end
        self:setEquipSkillInfo(player,EquipSkills)
    end
    -- player:addSkill("myplugin/player_range_skill_indicator_12")
    -- player:addSkill("myplugin/player_displace_skill_sabrecut_indicator_2")
end

return skillShop