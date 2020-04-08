local SkillMissile = Skill.GetType("Missile")--Base
local NormalAtk = Skill.GetType("NormalAtk")
NormalAtk.targetType = "Any"
function NormalAtk:getStartPos(from)
    return SkillMissile:getStartPos(from)
end
function NormalAtk:cast(packet, from)

    --if packet.targetID then
    --    local target = World.CurWorld:getEntity(packet.targetID)
    --    if target and from:canAttack(target) then
    --        doAtk(self,target,from)
    --    end
    --end
    from:addExp()
    SkillMissile.cast(self, packet, from)
end