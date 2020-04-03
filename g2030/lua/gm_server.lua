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
GMItem["sample/创建一个跟随宠物"] = function(self)
    local entity = EntityServer.Create({cfgName = "myplugin/pet_1_1_1", pos = self:getPosition()})
    --table.insert(EntityList, entity)
    Entity = entity
    local control = entity:getAIControl()
    control:setFollowTarget(self)
end

GMItem["sample/一个抽奖点"] = function(self)
    local entity = EntityServer.Create({cfgName = "myplugin/roller1", pos = self:getPosition()})
    table.insert(EntityList, entity)
end

GMItem["sample/删除上一个宠物"] = function(self)
    Entity:destroy()
    --table.remove(EntityList,#EntityList)
end

GMItem["sample/释放宠物技能"] = function(self)
    Skill.Cast("myplugin/pet_1_1_1_attack", {targetID=self.objID}, Entity)
end
-----------------------------------Pet Model Test End-------------------------------

---阵营
GMItem["g2030/setTeam_1"] = function(self)
    self:setTeam(1)
end

GMItem["g2030/setTeam_2"] = function(self)
    self:setTeam(2)
end

GMItem["g2030/setTeam_3"] = function(self)
    self:setTeam(3)
end

GMItem["g2030/upgradeTeam_2"] = function(self)
    local team = Game.GetTeam(2)
    team:addTeamKills(30)
end

GMItem["g2030/upgradeTeam_3"] = function(self)
    local team = Game.GetTeam(3)
    team:addTeamKills(30)
end

return GMItem