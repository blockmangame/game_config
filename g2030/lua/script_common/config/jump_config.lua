---@class JumpConfig
local JumpConfig = T(Config, "JumpConfig")

local settings = {}

function JumpConfig:init(config)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --id
        data.jumpSpeed = tonumber(vConfig.n_jumpSpeed) or 0 --跳跃速度
        data.jumpHeight = tonumber(vConfig.n_jumpHeight) or 10 --跳跃高度
        data.gravity = tonumber(vConfig.n_gravity) or 0.08 --重力
        data.fallGravity = tonumber(vConfig.n_fallGravity) or 0
        data.moveSpeed = tonumber(vConfig.n_moveSpeed) or 0 --移动速度
        data.rotationPitch = tonumber(vConfig.n_rotationPitch) or 0
        data.glidingSpeed = tonumber(vConfig.n_glidingSpeed) or 0
        data.jumpMoveEndFallDistance = tonumber(vConfig.n_jumpMoveEndFallDistance) or 1
        table.insert(settings, data)
    end
    --Lib.log("JumpConfig:init " .. Lib.v2s(settings))
end

function JumpConfig:getJumpConfig(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    Lib.log(string.format("JumpConfig:getJumpConfig %s nil", tostring(id)))
    return settings[#settings]
end

function JumpConfig:getGlidingConfig()
    return self:getJumpConfig(-1)
end

function JumpConfig:getFreeFallConfig()
    return self:getJumpConfig(0)
end

return JumpConfig
