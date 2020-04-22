local bm			 = Blockman.Instance()
local slideJumpFlag	 = L("slideJumpFlag", false)

local nextJumpTime = 0
local jumpBeginTime = 0
local jumpEndTime = 0
local onGround = true
local lockKeyJump = false

local function showJumpCountMessage(jumpCount, maxJumpCount)
    local message = string.format(Lang:toText("gui_jump_count_message"),
            jumpCount > 0 and jumpCount or 0, maxJumpCount)
    Lib.emitEvent("EVENT_SHOW_BOTTOM_MESSAGE", message, { jumpCount = jumpCount })
end

local function doJumpStateChange(control, player)
    player:setEntityProp("gravity", tostring(player.EntityProp.gravity))

    if player.isGliding then
        player:playFreeFallSkill()
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
        player:setEntityProp("moveSpeed", tostring(config.glidingSpeed))
        player.motion = Lib.v3(motionX * config.glidingSpeed,
                motionY * config.glidingSpeed, motionZ * config.glidingSpeed)
        --print("player.motion ", motionX, motionY, motionZ)
        --player:setValue("isKeepAhead", true)

        Skill.Cast(Me:cfg().glidingSkill)
    end
    player.isGliding = (not player.isGliding)
    Lib.emitEvent("EVENT_PLAY_GLIDING_EFFECT", player.isGliding)
end

---@param player EntityClientMainPlayer
local function jump_impl(control, player)
    local jumpCount = player:getJumpCount()
    local maxJumpCount = player:getMaxJumpCount()

    showJumpCountMessage(jumpCount - 1, maxJumpCount)

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
        --player:setEntityProp("antiGravity", tostring(player:getEntityProp("gravity")))
        player:setEntityProp("moveSpeed", tostring(config.moveSpeed))
        player.JumpMoveEndFallDistance = config.jumpMoveEndFallDistance
        player.jumpHeight = config.jumpHeight
        player.jumpEnd = false
    end

    local playerCfg = player:cfg()
    local packet = {}
    packet.reset = (jumpCount == maxJumpCount)
    Skill.Cast(playerCfg.jumpSkill, packet)

    player.lastJumpHeight = player:curBlockPos().y
    control:jump()

    player:decJumpCount()
end

local function processJumpEvent(player)
    --Lib.log(string.format("gravity:%s antiGravity:%s player:curBlockPos().y:%s lastJumpHeight:%s \
    --motion:%s %s %s JumpMoveEndFallDistance:%s",
    --        tostring(player:getEntityProp("gravity")), tostring(player:getEntityProp("antiGravity")),
    --        tostring(player:curBlockPos().y), tostring(player.lastJumpHeight),
    --        tostring(player.motion.x), tostring(player.motion.y), tostring(player.motion.z),
    --        tostring(player.JumpMoveEndFallDistance)))

    --if (not player.onGround and player.motion.y > 0
    --        and player:curBlockPos().y - player.lastJumpHeight >= player.jumpHeight)
    --        or (not player.onGround and player.motion.y == 0) then
    --    player:eventJumpEnd()
    --end

    if not player.onGround and player.lastMotionY > 0 and player.motion.y <= 0 then
        player:eventJumpEnd()
    end
    player.lastMotionY = player.motion.y

    if (not player.onGround and player.motion.y <= 0
            and player.beginFallHeight - player:curBlockPos().y >= player.JumpMoveEndFallDistance) then
        player:eventJumpMoveEnd()
    end
end

---@param control PlayerControl
---@param player EntityClientMainPlayer
local function checkJump(control, player)
    if tonumber(player:getEntityProp("jumpSpeed")) <= 0 then
        return
    end

    processJumpEvent(player)

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
        --if worldCfg.enableTwiceJump and 0 == jumpEndTime and not player.twiceJump then -- twice jump
        --    player.twiceJump = true
        --    if playerCfg.twiceJumpSkill and (nowTime - jumpBeginTime >= (playerCfg.twiceJumpTouchTime or 0) ) then
        --        Skill.Cast(playerCfg.twiceJumpSkill)
        --    end
        --end
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