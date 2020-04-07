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

return GMItem