local SkillBase = Skill.GetType("Base")
local RechargeSkill = Skill.GetType("RechargeSkill")

RechargeSkill.isRechargeSkill = true
RechargeSkill.maxRechargeCount = 1
RechargeSkill.rechargeTime = 0

function RechargeSkill:preCast(packet, from)
    if not packet.needPre then
        return false
    end
    SkillBase.preCast(self, packet, from)
end

function RechargeSkill:cast(packet, from)
    if Me.objID == from.objID then
        Lib.emitEvent(Event.EVENT_RECHARGE_SKILL_CAST, packet)
    end
    SkillBase.cast(self, packet, from)
end
