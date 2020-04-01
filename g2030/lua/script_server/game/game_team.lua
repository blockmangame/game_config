local TeamBase = T(Game, "TeamBase")

function TeamBase:joinEntity(entity)
    local time = World.Now()
	entity:setTeamId(self.id)
    entity:setValue("joinTeamTime", time)
	if entity.isPlayer then
		for _, pet in pairs(entity:data("pet")) do
			pet:setValue("teamId", 0)	-- ǿ�ƿͻ���ˢ��Ѫ����ɫ, ����teamId��ԶΪ0
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
		entity:setHeadText(-1, 1, self.vars["nameHeadText"])
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
			pet:setValue("teamId", 0)	-- ǿ�ƿͻ���ˢ��Ѫ����ɫ, ����teamId��ԶΪ0
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