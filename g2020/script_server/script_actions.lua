local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.ShowHomeGuide(data, params, context)
	local entity = params.entity
	local pos = entity:getPosition()
	local mapName = entity.map.name
	pos.map = mapName
	local player = params.player
	player:sendPacket({
		pid = "ShowHomeGuide",
		pos = pos
	})
end