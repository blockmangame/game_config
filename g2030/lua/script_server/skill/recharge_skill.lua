local SkillBase = Skill.GetType("Base")
local RechargeSkill = Skill.GetType("RechargeSkill")

RechargeSkill.isRechargeSkill = true
RechargeSkill.maxRechargeCount = 1
RechargeSkill.rechargeTime = 0

function RechargeSkill:canCast(packet, from)
    local fullName = packet.name
    local cfg = Skill.Cfg(fullName)
    local maxRechargeCount = cfg.maxRechargeCount or 1
    local rechargeInfo = from.rechargeInfo
    if not rechargeInfo then
        rechargeInfo = {}
        from.rechargeInfo = rechargeInfo
    end
    local skillInfo = rechargeInfo[fullName]
    if not skillInfo then
        local now = World.Now()
        skillInfo = {
            curRechargeCount = maxRechargeCount,
            maxRechargeCount = maxRechargeCount,
            rechargeTime = cfg.rechargeTime or 1,
            timer = nil
        }
        rechargeInfo[fullName] = skillInfo
    end
    if skillInfo.curRechargeCount <= 0 then
        return false
    end
	return SkillBase.canCast(self, packet, from)
end

local function recharge(skillInfo)
    skillInfo.timer = World.Timer(skillInfo.rechargeTime, function()
        skillInfo.curRechargeCount = skillInfo.curRechargeCount + 1
        if skillInfo.curRechargeCount < skillInfo.maxRechargeCount then
            recharge(skillInfo)
        else
            skillInfo.timer = nil
        end
    end)
end

function RechargeSkill:cast(packet, from)
    local rechargeInfo = from.rechargeInfo
    local skillInfo = rechargeInfo[packet.name]
    skillInfo.curRechargeCount = skillInfo.curRechargeCount - 1
    if not skillInfo.timer then
        recharge(skillInfo)
    end
    packet.needPre = true
    SkillBase.cast(self, packet, from)
end
