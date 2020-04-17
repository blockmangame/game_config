local GMItem = GM:createGMItem()

GMItem["g2030/LOADING_PAGE"] = function()
    Lib.emitEvent(Event.EVENT_LOADING_PAGE, true)
end

GMItem["g2030/CAST_SKILL"] = function()
    local player = Player.CurPlayer
    local playerCfg = player:cfg()
    Skill.Cast(playerCfg.twiceJumpSkill)
end
GMItem["g2030/上腰带"] = function(self)
    self:exchangeEquip("myplugin/sash_simple")
end
GMItem["g2030/上腰带2"] = function(self)
    self:exchangeEquip("myplugin/sash_simple1")
end
GMItem["g2030/上武器"] = function(self)
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

GMItem["g2030技能/1号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/2号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/3号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/4号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/5号技能"] = function(self)
    Skill.Cast("myplugin/player_defense_skill_05")
end
GMItem["g2030技能/6号技能"] = function(self)
    Skill.Cast("myplugin/player_defense_skill_06")
end
GMItem["g2030技能/7号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/8号技能"] = function(self)
    Skill.Cast("myplugin/player_remote_skill_shuriken_08")
end
GMItem["g2030技能/9号技能"] = function(self)
    Skill.Cast("myplugin/palyer_range_skill_bomb_09")
end
GMItem["g2030技能/10号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/11号技能"] = function(self)
    Skill.Cast("myplugin/palyer_range_skill_thunderclap_11")
end
GMItem["g2030技能/12号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_triple_attack")
end
GMItem["g2030技能/13号技能"] = function(self)
    Skill.Cast("myplugin/player_range_skill_magic_circle_13")
end
GMItem["g2030技能/14号技能"] = function(self)
    Skill.Cast("myplugin/player_range_skill_dragon_wave_14")
end
GMItem["g2030技能/15号技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_15")
end
GMItem["g2030技能/16号技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_16")
end
GMItem["g2030技能/17号技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_17")
end
GMItem["g2030技能/18号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_self_recover_18")
end
GMItem["g2030技能/19号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_team_recover_19")
end
GMItem["g2030技能/20号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_team_recover_20")
end
GMItem["g2030技能/眩晕技能"] = function(self)
    Skill.Cast("myplugin/player_dizziness_skill")
end
return GMItem
