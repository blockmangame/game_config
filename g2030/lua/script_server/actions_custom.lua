local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.ResetEntityRechargeSkill(data, params, context)
    local rechargeInfo = params.entity.rechargeInfo or {}
    local now = World.Now()
    for _,skillInfo in pairs(rechargeInfo) do
        skillInfo.curRechargeCount = skillInfo.maxRechargeCount
        skillInfo.beginRechargeTime = now
    end
    params.entity:sendPacket({pid = "ResetEntityRechargeSkill"})
end

function Actions.TeleportBegin(data, params, context)
    params.entity:sendPacket({pid = "TeleportBegin", type = params.type or 1})
end

function Actions.TeleportEnd(data, params, context)
    params.entity:sendPacket({pid = "TeleportEnd", type = params.type or 1})
end

function Actions.rewardActions(data, params, context)
    local rewardManager = T(Game, "rewardManager")
    rewardManager:doRewardByType(params.type, params.object, params.player)
end

function Actions.remarkBoxActions(data, params, context)
    local rewardManager = T(Game, "rewardManager")
    rewardManager:remarkAllBox(params.object)
end