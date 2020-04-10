local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.ResetEntityRechargeSkill(data, params, context)
    local rechargeInfo = params.entity.rechargeInfo or {}
    for _,skillInfo in pairs(rechargeInfo) do
        if skillInfo.timer then
            skillInfo.timer()
            skillInfo.timer = nil
        end
        skillInfo.curRechargeCount = skillInfo.maxRechargeCount
    end
    params.entity:sendPacket({pid = "ResetEntityRechargeSkill"})
end

