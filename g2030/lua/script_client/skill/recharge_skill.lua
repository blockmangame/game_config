local SkillBase = Skill.GetType("Base")
local RechargeSkill = Skill.GetType("RechargeSkill")

RechargeSkill.isRechargeSkill = true
RechargeSkill.maxRechargeCount = 1
RechargeSkill.rechargeTime = 0

function RechargeSkill:cast(packet, from)
    Lib.emitEvent(Event.EVENT_RECHARGE_SKILL_CAST, packet.name)
    SkillBase.cast(self, packet, from)
end
