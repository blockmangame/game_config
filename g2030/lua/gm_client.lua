local GMItem = GM:createGMItem()

GMItem["g2030/LOADING_PAGE"] = function()
    Lib.emitEvent(Event.EVENT_LOADING_PAGE, true)
end

GMItem["g2030/CAST_SKILL"] = function()
    local player = Player.CurPlayer
    local playerCfg = player:cfg()
    Skill.Cast(playerCfg.twiceJumpSkill)
end
GMItem["g2030/替换装备"] = function(self)
    self:exchangeEquip("myplugin/weapon_simple")
end

-----------------------------------Pet Model Test----------------------------------
local Entity
GMItem["g2030/创建一个跟随宠物"] = function(self)

    local entity = EntityServer.Create({cfgName = "myplugin/pet_1_1_1", pos = self:getPosition()})
    --table.insert(EntityList, entity)
    Entity = entity
    local control = entity:getAIControl()
    control:setFollowTarget(self)
end

GMItem["g2030/一个抽奖点"] = function(self)
    local entity = EntityServer.Create({cfgName = "myplugin/roller1", pos = self:getPosition()})
    table.insert(EntityList, entity)
end

GMItem["g2030/删除上一个宠物"] = function(self)
    Entity:destroy()
    --table.remove(EntityList,#EntityList)
end

GMItem["g2030/释放宠物技能"] = function(self)
    Skill.Cast("myplugin/pet_1_1_1_attack", {targetID=self.objID}, Entity)
end
-----------------------------------Pet Model Test End-------------------------------
return GMItem
