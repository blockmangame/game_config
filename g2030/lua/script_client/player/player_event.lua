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

    self:setValue("jumpCount", self:getMaxJumpCount())
    self:recoverJumpProp()
    Blockman.instance.gameSettings:setEnableRadialBlur(false)
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