local SkillBase = Skill.GetType("Base")
local RechargeSkill = Skill.GetType("RechargeSkill")

RechargeSkill.isRechargeSkill = true
RechargeSkill.maxRechargeCount = 1
RechargeSkill.rechargeTime = 0

local function calcRechargeCount(skillInfo)
    local addCount = (World.Now() - skillInfo.beginRechargeTime) // skillInfo.rechargeTime
    local curRechargeCount = skillInfo.curRechargeCount
    local maxRechargeCount = skillInfo.maxRechargeCount
    if addCount > 0 and curRechargeCount < maxRechargeCount then
        skillInfo.curRechargeCount = math.min(addCount + curRechargeCount, maxRechargeCount)
    end
end

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
        skillInfo = {
            curRechargeCount = maxRechargeCount,
            maxRechargeCount = maxRechargeCount,
            rechargeTime = cfg.rechargeTime or 1,
            beginRechargeTime = World.Now()
        }
        rechargeInfo[fullName] = skillInfo
    end
    calcRechargeCount(skillInfo)
    if skillInfo.curRechargeCount <= 0 then
        return false
    end
	return SkillBase.canCast(self, packet, from)
end

local function calcBeginRechargeTime(skillInfo)
    local now = World.Now()
    local beginRechargeTime = skillInfo.beginRechargeTime
    if beginRechargeTime == -1 then
        skillInfo.beginRechargeTime = now
    else
        local lessTime = (now - beginRechargeTime) % skillInfo.rechargeTime
        skillInfo.beginRechargeTime = now - lessTime
    end
end

function RechargeSkill:cast(packet, from)
    local rechargeInfo = from.rechargeInfo
    local skillInfo = rechargeInfo[packet.name]
    skillInfo.curRechargeCount = skillInfo.curRechargeCount - 1
    calcBeginRechargeTime(skillInfo)
    packet.needPre = true

    SkillBase.cast(self, packet, from)
    
    local skill = self.skillCfg
    if skill ~= nil then
        Skill.Cast(skill, packet, from)
    end
end
