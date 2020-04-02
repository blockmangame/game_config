
local SkillBase = Skill.GetType("Base")
local SceneSkill = Skill.GetType("SceneSkill")

SceneSkill.isSceneSkill = true
SceneSkill.sceneSkillMap = {}

function SceneSkill:canCast(packet, from)
	if not packet.targetPos then
		return false
	end
	return SkillBase.canCast(self, packet, from)
end

function SceneSkill:cast(packet, from)
	if not self:canCast(packet, from) then
		return
	end

	local targetSkill
	if not packet.isTouchPointMove then
		targetSkill = self.sceneSkillMap.touchStaticSkill
	else
		targetSkill = self.sceneSkillMap.touchMoveSkill
	end
	if targetSkill then
		Skill.Cast(targetSkill, packet, from)
	end
end