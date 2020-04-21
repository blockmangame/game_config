---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangpq.
--- DateTime: 2020/3/23 10:35
---
function Player:initPlayer()
    Lib.log("Player:initPlayer")

    self.isGliding = false
    self.isJumpMoveEnd = false
    self.jumpEnd = false

    self.lastJumpHeight = 0
    self.JumpMoveEndFallDistance = 0
    self.jumpHeight = 0
    self.beginFallHeight = 0

    self:initData()
    Blockman.Instance():setLockVisionState(World.cfg.lockVision and World.cfg.lockVision.open or false)
end

function Player:sellExp()
    local packet = {
        pid = "SellExp",
        objID = self.objID,
    }
    self:sendPacket(packet)
    --print(string.format("Player:setValue %s %s", tostring(key), Lib.v2s(value, 1)))
end
function Player:exchangeEquip(fullname)
    local packet = {
        pid = "ExchangeEquip",
        objID = self.objID,
        fullName = fullname,
    }
    self:sendPacket(packet)
end

--function Player:saveJumpProp()
--    --TODO
--end

function Player:playFreeFallSkill()
    ---@type JumpConfig
    local JumpConfig = T(Config, "JumpConfig")
    local config = JumpConfig:getFreeFallConfig()
    if config then
        self:setEntityProp("gravity", tostring(config.fallGravity))
    end

    self:setEntityProp("antiGravity", tostring(self.EntityProp.antiGravity))
    self:setEntityProp("moveAcc", tostring(self.EntityProp.moveAcc))
    self.motion = Lib.v3(0, 0, 0)
    --player:setValue("isKeepAhead", false)

    if self.isJumpMoveEnd then
        self:setEntityProp("moveSpeed", tostring(0.0))
    end
    Skill.Cast(self:cfg().freeFallSkill)
end

function Player:recoverJumpProp()
    self:recoverEntityProp("jumpSpeed")
    self:recoverEntityProp("gravity")
    self:recoverEntityProp("antiGravity")
    self:recoverEntityProp("moveSpeed")
    self:recoverEntityProp("moveAcc")

    self:setValue("jumpCount", self:getMaxJumpCount())

    self.isGliding = false
    self.isJumpMoveEnd = false
    self.jumpEnd = false

    Lib.emitEvent("EVENT_PLAY_GLIDING_EFFECT", self.isGliding)
    Blockman.instance.gameSettings:setEnableRadialBlur(false)
end
function Player:matchArena()
    self:sendPacket({
        pid = "MatchArena",
        objId = Me.objID,
        key = "ArenaCompetition"
    })
end

function Player:setEntityProp(prop, value)
    self:recoverEntityProp(prop)
    local curValue = tonumber(self:getEntityProp(prop))
    self:deltaEntityProp(prop, -curValue + tonumber(value))
end


function Player:eventJumpMoveEnd()
    if self.isJumpMoveEnd then
        return
    end

    print("jumpMoveEnd")

    self.isJumpMoveEnd = true

    if self.isGliding then
        return
    end

    self:playFreeFallSkill()
end

function Player:eventJumpEnd()
    if self.jumpEnd then
        return
    end

    print("jumpEnd")

    self.jumpEnd = true

    self:setEntityProp("antiGravity", tostring(self.EntityProp.antiGravity))
    self.motion = Lib.v3(0, 0, 0)
end