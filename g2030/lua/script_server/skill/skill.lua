function Skill.DoCast(cfg, packet, from)
	if cfg.debug then
		print("server Skill.DoCast -", cfg.fullName, from and from.objID)
    end
	if cfg:cast(packet, from) == false then
		return
    end
	local target = nil
	if packet.targetID then
		target = World.CurWorld:getObject(packet.targetID)
    end
	local context = {obj1=from, obj2=target, pos=packet.targetPos, fullName = cfg.fullName}
	if packet.ownerID then
		context.owner = World.CurWorld:getObject(packet.ownerID)
    end
	Trigger.CheckTriggers(cfg, "SKILL_CAST", context)
	if from and cfg.objTrigger then
		Trigger.CheckTriggers(from:cfg(), cfg.objTrigger, context)
	end
	packet.pid = "CastSkill"
	packet.fromID = from and from.objID
	packet.name = cfg.fullName
	if cfg.broadcast~=false then
		if from and from.isEntity then
			from:sendPacketToTracking(packet, true)
		else
			WorldServer.BroadcastPacket(packet)
		end
	elseif from.isPlayer then
        from:sendPacket(packet)
    end
    if from.isPlayer and cfg.strategy then
        from:addBuff("myplugin/skill_strategy_buff",cfg.strategy*20)
    end
	if cfg.castActionTime then
		World.Timer(cfg.castActionTime, function()
			if from:isValid() then
				Trigger.CheckTriggers(from:cfg(), "SKILL_CAST_FINISH", context)
			end
		end)
	end
end