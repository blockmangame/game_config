local GMItem = GM:createGMItem()

GMItem["g2030/回主城"] = function(self)
    local targetMap = World.CurWorld:staticMap("map001")
    self:setMapPos(targetMap, targetMap.cfg.initPos)
end
GMItem["test/清空当前修炼值"] = function(self)
    self:resetExp()
end
GMItem["g2030/addBuff"] = function(self)
    self:addBuff("myplugin/example", -1)
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
return GMItem