local TeamBase = T(Game, "TeamBase")

function TeamBase:joinEntity(entity)
    local time = World.Now()
	entity:setTeamId(self.id)
    entity:setValue("joinTeamTime", time)
	if entity.isPlayer then
		for _, pet in pairs(entity:data("pet")) do
			pet:setValue("teamId", 0)	-- 强制客户端刷新血条颜色, 宠物teamId永远为0
		end
        self.leaderId = self.leaderId or entity.objID
		self.playerCount = self.playerCount + 1
	end
	local objID = entity.objID
	self.entityList[objID] = entity
	for id, buff in pairs(self.buffList) do
		buff.addList[objID] = entity:addBuff(buff.name)
	end
	if entity.isPlayer then
		entity:setHeadText(0, -1, self.vars["nameHeadText"])
		WorldServer.BroadcastPacket({
			pid = "SetPlayerTeam",
			objId = entity.objID,
			teamId = self.id,
            joinTeamTime = time,
            leaderId = self.leaderId
		})
	end
end

function TeamBase:leaveEntity(entity, canLeave)
	if not canLeave then
		return
	end
	local objID = entity.objID
	if self.entityList[objID] == nil then
		return
	end

	local oldTeamId = entity:getValue("teamId")
	assert(oldTeamId==self.id, tostring(oldTeamId))
	entity:setValue("teamId", 0)
	entity:setValue("joinTeamTime", 0)
	self.entityList[objID] = nil
	if entity.isPlayer then
		for _, pet in pairs(entity:data("pet")) do
			pet:setValue("teamId", 0)	-- 强制客户端刷新血条颜色, 宠物teamId永远为0
		end
		self.playerCount = self.playerCount - 1
		if self.leaderId == entity.objID then
			local firstPlayer = self:getFirstPlayer()
			self.leaderId = firstPlayer and firstPlayer.objID or nil
		end
	end
	for id, buff in pairs(self.buffList) do
		local eb = buff.addList[objID]
		if eb then
			entity:removeBuff(eb)
			buff.addList[objID] = nil
		end
	end

	if entity.isPlayer then
		WorldServer.BroadcastPacket({
			pid = "SetPlayerTeam",
			objId = entity.objID,
			teamId = 0,
			leaderId = self.leaderId
		})
	end
	Trigger.CheckTriggers(entity:cfg(), "LEAVE_TEAM", {obj1 = entity, teamId = self.id})
	if self.playerCount == 0 and World.cfg.destroyTeamWhenEmpty then
		self:dismiss()
	end
end

function TeamBase:initBuff()
    for _, name in ipairs(self.teamBuff) do
        self:addBuff(name, 100000)
    end
end

function TeamBase:addLevelCfg(cfg)
	if cfg.level then
		self.levelCfg[tonumber(cfg.level)] = cfg
	end
end

function TeamBase:getLevelCfg(level, key)
	if not level then
		return self.levelCfg
	end
	if not key then
		return self.levelCfg[tonumber(level)]
	end
	if self.levelCfg[tonumber(level)] then
		return self.levelCfg[tonumber(level)][key]
	end
end

function TeamBase:addTeamKills(num)
	if not self.kills then
		return
	end
	self.kills = self.kills + num
	self:updateLevel()
end

function TeamBase:updateLevel()
	if not self.kills then
		self.level = 1
		return
	end

	local kills = self.kills
	local old = self.level
	self.level = #self.levelCfg
	for i = old, #self.levelCfg do
		if self.levelCfg[i] and tonumber(self.levelCfg[i].upgradeKills) > kills then
			self.level = i
			break
		end
	end
	if old ~= self.level then
		self:onTeamUpgrade()
	end
end

function TeamBase:getLevel()
	return self.level
end

function TeamBase:onTeamUpgrade()
	--更新buff
end