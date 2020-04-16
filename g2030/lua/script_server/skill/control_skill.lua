---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by qjc.
--- DateTime: 2020/4/14 20:56
---

local SkillBase = Skill.GetType("Base")
local ControlSkill = Skill.GetType("ControlSkill")
ControlSkill.roundupTimer = nil
ControlSkill.groundedTimer = nil
ControlSkill.dizzinessTimer = nil

ControlSkill.controlHandle = {
    roundup = 1,
    dizziness = 2,
    grounded = 3
}

local function getNearbyEntities(from, range)
    if not from then
        return
    end

    local nearbyEntities = from:getNearbyEntities(range)
    local ret = {}
    for _, entity in pairs(nearbyEntities) do
        if entity.objID ~= from.objID  and entity.isPlayer then
            --todo delete teammate
            ret[#ret + 1] = entity
        end
    end

    return ret
end

local function grounded(pTarget, from)
    if not pTarget then
        return
    end

    if not from then
        return
    end

    local d = Lib.tov3(pTarget:getPosition()) - Lib.tov3(from:getPosition())
    local yaw = math.atan(d.z, d.x)
    pTarget:setRotationYaw(math.deg(yaw) - 90)
    pTarget.forceTargetPos = from:getPosition()
    pTarget.forceTime = 5

    local GroundedData = {
        nearbyEntities = nearbyEntities,
        entityIndex = entityIndex - 1,
    }
    from:data("main").GroundedData = GroundedData
end

local function roundUp(self, from)
    if not from then
        return
    end

    local RoundUpData = from:data("main").RoundUpData
    local entityIndex = RoundUpData.entityIndex
    local nearbyEntities = RoundUpData.nearbyEntities
    if entityIndex > 0 then
        local pTarget = nearbyEntities[entityIndex]
        if pTarget then
            local d = Lib.tov3(pTarget:getPosition()) - Lib.tov3(from:getPosition())
            local yaw = math.atan(d.z, d.x)
            pTarget:setRotationYaw(math.deg(yaw) - 90)

            local pos = from:getPosition()
            pTarget.forceTargetPos = Lib.tov3({x = pos.x + 0.5, y = pos.y, z = pos.z - 0.5})
            pTarget.forceTime = 5
            local RoundUpData = {
                nearbyEntities = nearbyEntities,
                entityIndex = entityIndex - 1,
            }
            from:data("main").RoundUpData = RoundUpData
        end
    else
        from:data("main").RoundUpData = nil
        ControlSkill.roundupTimer = nil
        return false
    end

    return true
end

local function dizziness(self, from)
    if not from then
        return
    end

    local DizzinessData = from:data("main").DizzinessData
    local entityIndex = DizzinessData.entityIndex
    local nearbyEntities = DizzinessData.nearbyEntities
    if entityIndex > 0 then
        local pTarget = nearbyEntities[entityIndex]
        if pTarget then
            if self.dizzinessCfg ~= nil then
                pTarget:addBuff(self.dizzinessCfg.buffCfg, self.dizzinessCfg.buffTime)
            end
            local DizzinessData = {
                nearbyEntities = nearbyEntities,
                entityIndex = entityIndex - 1,
            }
            from:data("main").DizzinessData = DizzinessData
        end
    else
        from:data("main").DizzinessData = nil
        ControlSkill.dizzinessTimer = nil
        return false
    end

    return true
end

local function grounded(self, from)
    if not from then
        return
    end

    local GroundedData = from:data("main").GroundedData
    local entityIndex = GroundedData.entityIndex
    local nearbyEntities = GroundedData.nearbyEntities
    if entityIndex > 0 then
        local pTarget = nearbyEntities[entityIndex]
        if pTarget then
            if self.groundedCfg ~= nil then
                pTarget:addBuff(self.groundedCfg.buffCfg, self.groundedCfg.buffTime)
            end
            local GroundedData = {
                nearbyEntities = nearbyEntities,
                entityIndex = entityIndex - 1,
            }
            from:data("main").GroundedData = GroundedData
        end
    else
        from:data("main").GroundedData = nil
        ControlSkill.groundedTimer = nil
        return false
    end

    return true
end

function ControlSkill:cast(packet, from)
    if not self:canCast(packet, from) then
        return
    end

    if self.dizzinessCfg ~= nil then
        local nearbyEntities = getNearbyEntities(from, self.dizzinessCfg.range)
        local DizzinessData = {
            nearbyEntities = nearbyEntities,
            entityIndex = #nearbyEntities,
        }

        from:data("main").DizzinessData = DizzinessData
        ControlSkill.dizzinessTimer = from:timer(1, dizziness, self, from)
    end

    if self.RoundUpRange ~= nil then
        local nearbyEntities = getNearbyEntities(from, self.RoundUpRange)
        local RoundUpData = {
            nearbyEntities = nearbyEntities,
            entityIndex = #nearbyEntities,
        }

        from:data("main").RoundUpData = RoundUpData
        ControlSkill.roundupTimer = from:timer(1, roundUp, self, from)
    end

    if self.groundedCfg ~= nil then
        local nearbyEntities = getNearbyEntities(from, self.groundedCfg.range)
        local GroundedData = {
            nearbyEntities = nearbyEntities,
            entityIndex = #nearbyEntities,
        }

        from:data("main").GroundedData = GroundedData
        ControlSkill.groundedTimer = from:timer(1, grounded, self, from)
    end

    SkillBase.cast(self, packet, from)
end

function ControlSkill:canCast(packet, from)
    return SkillBase.canCast(self, packet, from)
end