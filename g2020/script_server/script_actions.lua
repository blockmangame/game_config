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

function Actions.CheckUseItemClear(data, params, context)
	local entity = params.entity
	entity:checkUseItemClear()
end

function Actions.UpdateEntityDateToClient(data, params, context)
	local entity = params.entity
    local key = params.key
	if not entity or not key then
		return
    end
    entity:sendPacket({
        pid = "UpdateEntityDate",
	    objId = entity.objID,
	    key = key,
        value = params.value
    })
end

function Actions.IsDrive(data, params, context)
	local entity = params.entity
	if entity and entity.rideOnId then
		local old = entity.world:getEntity(entity.rideOnId)
		if old and old:cfg().carMove then
			return true
		end
	end
	return false
end

function Actions.SetItemUse(data, params, context)
	local entity = params.entity
	local item = params.item
	if not item then
		return
	end 
	entity:setItemUse(item:tid(), item:slot(), params.isUse)
end

function Actions.ClearItemUseByKey(data, params, context)
	local entity = params.entity
	entity:clearItemUseByKey(params.key, params.valueArray)
end

function Actions.UploadPrivilege(data, params, context)
	if params.player then
		AsyncProcess.UploadPrivilege(params.player.platformUserId)
	end
end 