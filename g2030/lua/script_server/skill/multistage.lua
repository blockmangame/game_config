
local SkillBase = Skill.GetType("Base")
local MultiStageSkill = Skill.GetType("MultiStage")

MultiStageSkill.broadcast = false

local function getStageCfg(self, from)
	local lastStage = from:data("skill").multiStageData
	local index = 1
	if lastStage and lastStage.skill == self.fullName and lastStage.waitEnd >= World.Now() then
		index = lastStage.nextStage
	end
	return self.stages[index], index
end

function MultiStageSkill:canCast(packet, from)
	if not SkillBase.canCast(self, packet, from) then
		return false
	elseif not getStageCfg(self, from) then
		return false
	end
	return true
end

function MultiStageSkill:cast(packet, from)
	if not self:canCast(packet, from) then
		return
	end

	if packet.reset then
		from:data("skill").multiStageData = nil
	end

	packet.needPre = true
	SkillBase.cast(self, packet, from)
	local cfg, index = getStageCfg(self, from)
	Skill.Cast(cfg.skill, packet, from)

	local nextStage = index + 1
	local data = nil
	local cdTime = self.cdTime
	if nextStage <= #self.stages then
		data = {
			skill = self.fullName,
			waitEnd = World.Now() + cfg.castTime + cfg.waitTime,
			nextStage = nextStage,
		}
		cdTime = cfg.castTime
	end
	if self.cdKey then
		packet.cdTime = cdTime
		from:setCD(self.cdKey, cdTime)
	end
	from:data("skill").multiStageData = data
end
