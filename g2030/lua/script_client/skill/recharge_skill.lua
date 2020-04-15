local SkillBase = Skill.GetType("Base")
local RechargeSkill = Skill.GetType("RechargeSkill")

RechargeSkill.isRechargeSkill = true
RechargeSkill.maxRechargeCount = 1
RechargeSkill.rechargeTime = 0

function RechargeSkill:cast(packet, from)
    if Me.objID == from.objID then
        Lib.emitEvent(Event.EVENT_RECHARGE_SKILL_CAST, packet.name)
    end
    SkillBase.cast(self, packet, from)
end
