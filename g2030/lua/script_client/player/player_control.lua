local bm			 = Blockman.Instance()
local slideJumpFlag	 = L("slideJumpFlag", false)

local nextJumpTime = 0
local jumpBeginTime = 0
local jumpEndTime = 0
local onGround = true
local lockKeyJump = false

local function showJumpCountMessage(jumpCount, maxJumpCount)
    local message = string.format(Lang:toText("gui_jump_count_message"), jumpCount, maxJumpCount)
    if jumpCount <= 0 then
        message = "▢FFFF0000" .. message
    else
        message = "▢FFFFFFFF" .. message
    end
    Lib.emitEvent("EVENT_SHOW_BOTTOM_MESSAGE", message)
end

local function doJumpStateChange(control, player)
    if player.isGliding then
        player:setEntityProp("antiGravity", tostring(player.EntityProp.antiGravity))
        player:setEntityProp("moveAcc", tostring(player.EntityProp.moveAcc))
        player.motion = Lib.v3(0, 0, 0)
        --player:setValue("isKeepAhead", false)

        if player.isJumpMoveEnd then
            player:setEntityProp("moveSpeed", tostring(0.0))
        end
        Skill.Cast(Me:cfg().freeFallSkill)
    else
        player:setEntityProp("antiGravity", tostring(player:getEntityProp("gravity")))
        player:setEntityProp("moveAcc", tostring(0.0))

        ---@type JumpConfig
        local JumpConfig = T(Config, "JumpConfig")
        local config = JumpConfig:getGlidingConfig()
        local rotationYaw = player:getRotationYaw()
        local rotationPitch = config.rotationPitch
        local DEG2RAD = 0.01745329
        local motionX = -(math.sin(rotationYaw * DEG2RAD) * math.cos(rotationPitch * DEG2RAD))
        local motionZ = math.cos(rotationYaw * DEG2RAD) * math.cos(rotationPitch * DEG2RAD)
        local motionY = -(math.sin(rotationPitch * DEG2RAD))
        player.motion = Lib.v3(motionX * config.glidingSpeed,
                motionY * config.glidingSpeed, motionZ * config.glidingSpeed)
        --print("player.motion ", motionX, motionY, motionZ)
        --player:setValue("isKeepAhead", true)

        player:setEntityProp("moveSpeed", tostring(999999.0))
        Skill.Cast(Me:cfg().glidingSkill)
    end
    player.isGliding = (not player.isGliding)
end

---@param player EntityClientMainPlayer
local function jump_impl(control, player)
    local jumpCount = player:getJumpCount()
    local maxJumpCount = player:getMaxJumpCount()

    showJumpCountMessage(math.max(jumpCount - 1, 0), maxJumpCount)

    if jumpCount <= 0 then
        doJumpStateChange(control, player)
        return
    end

    ---@type JumpConfig
    local JumpConfig = T(Config, "JumpConfig")
    local config = JumpConfig:getJumpConfig(maxJumpCount - jumpCount + 1)
    if config then
        player:setEntityProp("jumpSpeed", tostring(config.jumpSpeed))
        player:setEntityProp("gravity", tostring(config.gravity))
        player:setEntityProp("moveSpeed", tostring(config.moveSpeed))
    end

    local playerCfg = player:cfg()
    local packet = {}
    packet.reset = (jumpCount == maxJumpCount)
    Skill.Cast(playerCfg.jumpSkill, packet)

    control:jump()

    player:decJumpCount()
end

---@param control PlayerControl
---@param player EntityClientMainPlayer
local function checkJump(control, player)
    local playerCfg = player:cfg()
    local worldCfg = World.cfg
    local nowTime = World.Now()
    if onGround ~= player.onGround then  -- aerial landing
        onGround = player.onGround
        if onGround then
            nextJumpTime = nowTime + (playerCfg.jumpInterval or 2)
            if worldCfg.jumpProgressIcon then
                Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStop = true})
            end
            player.twiceJump = nil
            player.takeoff = false
            jumpBeginTime = 0
        end
    end

    if bm:getVerticalSlide() > 0 then
        bm:setVerticalSlide(0)
        slideJumpFlag = true
    end
    if not bm:isKeyPressing("key.jump") then
        lockKeyJump = false
    end
    if not lockKeyJump and (bm:isKeyPressing("key.jump") or slideJumpFlag) then
        local canJump = player.onGround or player:isSwimming()
        local id = player.rideOnId
        local pet
        if id > 0 and not player:isCameraMode() then
            pet = player.world:getEntity(id)
            canJump = pet.onGround or pet:isSwimming()
        end
        local jumpCount = player:getJumpCount()
        canJump = canJump or true
        if canJump then
            jumpBeginTime = nowTime
            jumpEndTime = nowTime + (playerCfg.maxPressJumpTime or 0)
            if worldCfg.jumpProgressIcon then
                Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStart = true, jumpBeginTime = jumpBeginTime, jumpEndTime = jumpEndTime})
            end
        end
        if worldCfg.enableTwiceJump and 0 == jumpEndTime and not player.twiceJump then -- twice jump
            player.twiceJump = true
            if playerCfg.twiceJumpSkill and (nowTime - jumpBeginTime >= (playerCfg.twiceJumpTouchTime or 0) ) then
                Skill.Cast(playerCfg.twiceJumpSkill)
            end
        end
        if nowTime > jumpEndTime or nowTime < nextJumpTime then
            if slideJumpFlag then slideJumpFlag = false end
            return
        end

        jump_impl(control, player)
        lockKeyJump = true
    else
        if worldCfg.jumpProgressIcon then
            Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStop = true})
        end
        jumpEndTime = 0
    end
end

function PlayerControl.checkJump_impl(control, player)
    checkJump(control, player)
end