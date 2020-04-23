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

function events:dead(dead)
    if dead then
        self:recoverJumpProp()
    end
end