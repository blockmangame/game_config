local SkillBase = Skill.GetType("Base")
local SkillTimeLine = Skill.GetType("TimeLine")

require "common.skill.timeLine"
local handleTarget = SkillTimeLine.handleTarget or {}
local behavior = SkillTimeLine.behavior or {}

local function hasPos(self, time)
    for _, line in pairs(self.timerLine) do
        if line.time > time and line.behavior == "Pos" then
            return line
        end
    end
end

function handleTarget:None(packet, from)
    local yaw = (360 - from:getRotationYaw() + 90) % 360
    local pos = Lib.tov3(Lib.copy(packet.linePos.value))
    local new_off_x, new_off_y = pos.x, pos.z
    local arc1 = math.atan(new_off_y, -new_off_x)
    local deg1 = math.deg(arc1)
    local deg2 = yaw - (360 - deg1 + 90) % 360
    local arc2 = math.rad(deg2)
    local len = (new_off_x ^ 2 + new_off_y ^ 2) ^ 0.5
    local offx = len * math.cos(arc2)
    local offy = len * math.sin(arc2)
    pos.x = -offx
    pos.z = offy
    packet.targetDir = from:getPosition() + pos
    return true
end

function handleTarget:Target(packet, from)
    local vals = Lib.copy(packet.linePos)
    local targetId = from:data("targetId")
    if not tonumber(targetId) then
        return false
    end
    local target = World.CurWorld:getEntity(targetId)
    if not target then
        return false
    end
    local distance = from:distance(target)
    if vals.range < distance then
        return false
    end
    local d = Lib.tov3(target:getPosition()) - from:getPosition()
    local yaw = math.atan(d.z, d.x)
    from:setRotationYaw(math.deg(yaw) - 90)
    return true
end

function behavior:Pos(packet, from, vals)
    local timerLineData = from:data("skill").timerLineData
    if not packet.linePos then
        packet.linePos = hasPos(self, timerLineData.time)
        return
    end
    local func = assert(handleTarget[self.targetType], self.targetType)
    if not func(self, packet, from) then
        handleTarget.None(self, packet, from)
    end
    --todo 进行位移控制
    from.forceTargetPos = packet.targetDir
    from.forceTime = vals.time - (packet.lastLinePos and packet.lastLinePos.time or 0)
    packet.lastLinePos = vals
end

function SkillTimeLine:endRun(packet, from)
    if self.skillName then
        Skill.Cast(self.skillName, { needPre = true }, from)
    end
end