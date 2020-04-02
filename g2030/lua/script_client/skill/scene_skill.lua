
local SkillBase = Skill.GetType("Base")
local SceneSkill = Skill.GetType("SceneSkill")

SceneSkill.isSceneSkill = true
 
function SceneSkill:canCast(packet, from)
	if not packet.targetPos then
		return false
	end
	return SkillBase.canCast(self, packet, from)
end