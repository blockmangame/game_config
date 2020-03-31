local SkillMissile = Skill.GetType("Missile")--Base
local NormalAtk = Skill.GetType("NormalAtk")
NormalAtk.targetType = "Any"
--[[
    @desc: 执行锻炼
    author:zhuyayi
    time:2020-03-21 21:08:09
    @return:
]]
local function doExp(from)
    from:addExp()
end
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