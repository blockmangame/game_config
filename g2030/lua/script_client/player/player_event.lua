local playerEventEngineHandler = L("playerEventEngineHandler", player_event)

local events = {}

function player_event(player, event, ...)
    playerEventEngineHandler(player, event, ...)
    local func = events[event]
    if func then
        func(player, ...)
    end
end

function events:onGroundChanged(lastOnGround, onGround)
    --Lib.log(string.format("onGroundChanged %s->%s", tostring(lastOnGround), tostring(onGround)))

    if lastOnGround == false and onGround == true then
        self:setValue("jumpCount", self:getMaxJumpCount())
        self:recoverJumpProp()
        Blockman.instance.gameSettings:setEnableRadialBlur(false)
    elseif lastOnGround == true and onGround == false then
        --TODO
    end
end

function events:jumpMoveEnd()
    print("jumpMoveEnd")
end