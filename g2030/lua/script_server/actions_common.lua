---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by JY-032.
--- DateTime: 2020/4/9 18:16
---

local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.PortalUIData(data, params, context)
    params.player:sendPacket({ pid = "PortalUIData", pos = params.pos, toIsland = params.toIsland })
end