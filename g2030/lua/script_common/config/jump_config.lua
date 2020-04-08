---@class JumpConfig
local JumpConfig = T(Config, "JumpConfig")

local settings = {}

function JumpConfig:init(config)
    for _, vConfig in pairs(config) do
        local data = {}
        data.id = tonumber(vConfig.n_id) or 0 --id
        data.jumpSpeed = tonumber(vConfig.n_jumpSpeed) or 0 --跳跃速度
        data.gravity = tonumber(vConfig.n_gravity) or 0 --重力
        data.moveSpeed = tonumber(vConfig.n_moveSpeed) or 0 --移动速度
        data.motionVertical = tonumber(vConfig.n_motionVertical) or 0
        data.motionHorizontal = tonumber(vConfig.n_motionHorizontal) or 0
        table.insert(settings, data)
    end
    Lib.log("JumpConfig:init " .. Lib.v2s(settings))
end

function JumpConfig:getJumpConfig(id)
    for _, setting in pairs(settings) do
        if setting.id == id then
            return setting
        end
    end
    return nil
end

function JumpConfig:getGlidingConfig()
    return self:getJumpConfig(-1)
end

return JumpConfig
