
local Region = World.Region

function Region:init()
	self.vars = Vars.MakeVars("region", self.cfg)
end

function Region:isOwner(entity)
	local regionOwner = entity.regionOwner
	if regionOwner and regionOwner[self] then
		return true
	end
	local team = entity:getTeam()
	regionOwner = team and team.regionOwner
	return regionOwner and regionOwner[self]
end

-- obj: entity or team
function Region:setOwner(obj)
	-- 放在对象上而不是region上，省去对象销毁时的处理
	local regionOwner = obj.regionOwner
	if not regionOwner then
		regionOwner = {}
		obj.regionOwner = regionOwner
	end
	-- 利用region的table作为key，region销毁不处理也问题不大
	regionOwner[self] = true
end

-- obj: entity or team
function Region:removeOwner(obj)
	local regionOwner = obj.regionOwner
	if regionOwner then
		regionOwner[self] = nil
	end
end

function Region:onEntityEnter(entity)
	local buffCfg = self.cfg.ownerBuffCfg
	if not buffCfg or not self:isOwner(entity) then
		buffCfg = self.cfg.buffCfg
	end
	if buffCfg then
		local regionBuff = entity:data("regionBuff")
		assert(not regionBuff[self.key], self.cfg.fullName)
		regionBuff[self.key] = entity:addBuff(buffCfg)
	end
	Trigger.CheckTriggers(self.cfg, "REGION_ENTER", {obj1=entity, region=self, map=self.map, inRegionKey = self.key})
    if entity.isPlayer then
        entity:addTarget("FindRegion", self.cfg.fullName)
    end
end

function Region:onEntityLeave(entity)
	local regionBuff = entity:data("regionBuff")
	local buff = regionBuff[self.key]
	if buff then
		regionBuff[self.key] = nil
		entity:removeBuff(buff)
	end
	Trigger.CheckTriggers(self.cfg, "REGION_LEAVE", {obj1=entity, region=self, map=self.map, inRegionKey = self.key})
end
