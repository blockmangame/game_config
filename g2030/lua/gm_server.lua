local GMItem = GM:createGMItem()

GMItem["g2030/回主城"] = function(self)
    local targetMap = World.CurWorld:staticMap("map001")
    self:setMapPos(targetMap, targetMap.cfg.initPos)
end
GMItem["g2030/清空当前修炼值"] = function(self)
    self:resetExp()
end
GMItem["g2030/addBuff"] = function(self)
    self:addBuff("myplugin/example", -1)
end
GMItem["g2030/添加回血buff"] = function(self)
    self:addBuff("myplugin/healing_s",40)
end
GMItem["g2030/添加回血加成buff"] = function(self)
    self:addBuff("myplugin/healing_plus",40)
end
GMItem["g2030/添加减伤buff"] = function(self)
    self:addBuff("myplugin/hurtSub_s")
end
GMItem["g2030/濒死"] = function(self)
    self:setValue("curHp", 1)
end

-----------------------------------Pet Model Test----------------------------------
local Entity
GMItem["g2030/发放一个宠物（不创建）"] = function(self)

end
GMItem["g2030/发放一个式神（不创建）"] = function(self)

end
GMItem["g2030/装备一个宠物"] = function(self)

end
GMItem["g2030/装备一个式神"] = function(self)

end
GMItem["sample/释放宠物技能"] = function(self)
    Skill.Cast("myplugin/pet_1_1_1_attack", {targetID=self.objID}, Entity)
end
-----------------------------------Pet Model Test End-------------------------------

---阵营
GMItem["g2030/加入Team_1"] = function(self)
    self:setTeam(1)
end

GMItem["g2030/加入Team_2"] = function(self)
    self:setTeam(2)
end

GMItem["g2030/加入Team_3"] = function(self)
    self:setTeam(3)
end

GMItem["g2030/升级Team_2"] = function(self)
    local team = Game.GetTeam(2)
    team:addTeamKills(10)
    print("阵营等级：" .. team:getLevel())
end

GMItem["g2030/升级Team_3"] = function(self)
    local team = Game.GetTeam(3)
    team:addTeamKills(10)
    print("阵营等级：" .. team:getLevel())
end

GMItem["g2030/玩家伤害减免"] = function(self)
    print("伤害减免：" .. self:getHurtSub())
end

GMItem["g2030/玩家治疗加成"] = function(self)
    print("治疗加成：" .. self:getHealingPlu())
end

return GMItem