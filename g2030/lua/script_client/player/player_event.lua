local playerEventEngineHandler = L("playerEventEngineHandler", player_event)

local events = {}

function player_event(player, event, ...)
    playerEventEngineHandler(player, event, ...)
    local func = events[event]
    if func then
        func(player, ...)
    end
end

function events:leaveGround()
    --TODO
end

function events:fallGround(fallDistance)
    print("fall " .. fallDistance)

    local playerCfg = Me:cfg()
    local fallAnimHeight = World.cfg.fallAnimHeight or 0
    if fallDistance >= fallAnimHeight and not self.isGliding then
        Skill.Cast(playerCfg.fallSkill1)
    else
        Skill.Cast(playerCfg.fallSkill2)
    end

    self:recoverJumpProp()
end

function events:beginFall(beginFallHeight)
    print("beginFall")

    self.beginFallHeight = beginFallHeight

    if self.isGliding then
        return
    end

    local jumpCount = self:getJumpCount()
    local maxJumpCount = self:getMaxJumpCount()

    ---@type JumpConfig
    local JumpConfig = T(Config, "JumpConfig")
    if jumpCount >= 0 then
        local config = JumpConfig:getJumpConfig(maxJumpCount - jumpCount)
        if config then
            self:setEntityProp("gravity", tostring(config.fallGravity))
        end
    else
        --local config = self.isGliding and JumpConfig:getGlidingConfig() or JumpConfig:getFreeFallConfig()
        --if config then
        --    self:setEntityProp("gravity", tostring(config.fallGravity))
        --end
    end
end

function events:jumpMoveEnd()
    print("jumpMoveEnd")

    if self.isJumpMoveEnd then
        return
    end

    self.isJumpMoveEnd = true

    if self.isGliding then
        return
    end

    self:playFreeFallSkill()
end

function events:dead(dead)
    if dead then
        self:recoverJumpProp()
    end
end

function events:jumpEnd()
    print("jumpEnd")

    if self.jumpEnd then
        return
    end

    self.jumpEnd = true

    self:setEntityProp("antiGravity", tostring(self.EntityProp.antiGravity))
    self.motion.y = 0
end