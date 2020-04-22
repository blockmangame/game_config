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
GMItem["g2030Pet/检查是否存在宠物实体"] = function(self)
    print("==============================================")
    for k, v in pairs(Player.CurPlayer.equipPetList) do
        print("ridePos:", k, "entity Info:", Player.CurPlayer:getPet(v.objID))
    end
end
-----------------------------------Pet Model Test End-------------------------------

GMItem["g2030技能/击退技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_beatback")
end
GMItem["g2030技能/击飞技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_hitfly")
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
    Skill.Cast("myplugin/player_range_skill_indicator_sub_12")
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
