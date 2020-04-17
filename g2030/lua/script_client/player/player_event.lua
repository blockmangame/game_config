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

function events:beginFall()
    print("beginFall")

    local jumpCount = self:getJumpCount()
    local maxJumpCount = self:getMaxJumpCount()

    ---@type JumpConfig
    local JumpConfig = T(Config, "JumpConfig")
    if jumpCount > 0 then
        local config = JumpConfig:getJumpConfig(maxJumpCount - jumpCount + 1)
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
    self.isJumpMoveEnd = true

    if self.isGliding then
        return
    end

    self:setEntityProp("moveSpeed", tostring(0.0))
    Skill.Cast(Me:cfg().freeFallSkill)
end

function events:dead(dead)
    if dead then
        self:recoverJumpProp()
    end
end