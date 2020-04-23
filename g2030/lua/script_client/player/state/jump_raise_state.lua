---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangpq.
--- DateTime: 2020/4/23 14:57
---
local class = require "common.class"

local JumpState = require "script_client.player.state.jump_state"
local JumpRaiseState = class("JumpRaiseState", JumpState)

function JumpRaiseState:enter(owner)
    local jumpCount = owner:getJumpCount()
    local maxJumpCount = owner:getMaxJumpCount()

    ---@type JumpConfig
    local JumpConfig = T(Config, "JumpConfig")
    local config = JumpConfig:getJumpConfig(maxJumpCount - jumpCount + 1)
    if config then
        owner:setEntityProp("jumpSpeed", tostring(config.jumpSpeed))
        owner:setEntityProp("gravity", tostring(config.gravity))
        --owner:setEntityProp("antiGravity", tostring(player:getEntityProp("gravity")))
        owner:setEntityProp("moveSpeed", tostring(config.moveSpeed))
        owner.JumpMoveEndFallDistance = config.jumpMoveEndFallDistance
        owner.jumpHeight = config.jumpHeight
        owner.isJumpMoveEnd = false
        owner.jumpEnd = false
    end

    local playerCfg = owner:cfg()
    local packet = {}
    packet.reset = (jumpCount == maxJumpCount)
    Skill.Cast(playerCfg.jumpSkill, packet)
end

function JumpRaiseState:update(owner)
    --TODO
end

function JumpRaiseState:leave(owner)
    --TODO
end

return JumpRaiseState