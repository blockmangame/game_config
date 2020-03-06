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

function Actions.SendInteractionEnd(data, params, context)
	params.player:sendPacket({
		pid = "SendInteractionEnd",
	})
end

function Actions.SendInteractionBegin(data, params, context)
	params.player:sendPacket({
		pid = "SendInteractionBegin",
		targetID = params.target.objID,
		skillName = params.skillName
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

function Actions.GetShopItemIndex(data, params, context)
	for _, item in pairs(Shop.shops) do
		if item.itemName == params.itemName then
			return item.index
		end
	end
end

function Actions.ShowSingleTeamUI(data, params, context)
    local entity = params.entity
    if not entity then
        return
    end

    entity:sendPacket({
        pid = "ShowSingleTeamUI",
        info = params.info,
        show = params.show
    })

end

function Actions.ShowTeamUI(data, params, context)
    params.entity:sendPacket({
        pid = "ShowTeamUI",
        show = params.show == nil and true or params.show,
        info = params.info
    })
end

function Actions.ShowProgressFollowObj(data, params, context)
    local player = params.entity
    if not player then
        return
    end
    player:sendPacket({
        pid = "ShowProgressFollowObj",
        isOpen = params.isOpen,
        pgImg = params.pgImg,
        pgBackImg = params.pgBackImg,
        pgName = params.pgName,
        usedTime = params.usedTime,
        totalTime = params.totalTime,
        pgText = params.pgText,
    })
end

function Actions.ShowDetails(data, params, content)
    local entity = params.entity
    if not entity.isPlayer then
		return
	end
    entity:sendPacket({
        pid = "ShowDetails",
        fullName = params.fullName,
        contents = params.contents,
        uiArea = params.uiArea,
        isOpen = params.isOpen,
    })
end

function Actions.SetLoadSectionMaxInterval(data, params, context)
	params.entity:sendPacket({
		pid = "SetLoadSectionMaxInterval",
		value = params.value,
	})
end

function Actions.ShowShopItemDetail(data, params, context)
	local player = params.player
	local eventMap = {
		["sure"] = params.eventSure or params.event or false,
		["no"] = params.eventNo or false
	}
	local regId = player:regCallBack("ItemDetail", eventMap, true, true, params.context)
	player:sendPacket({
		pid = "ShopItemDetail",
		hintImage = params.hintImage,
		regId = regId,
		price = params.price,
		tip = params.tip,
		desc = params.desc,
		coinId = params.coinId or 0
	})
end

function Actions.WorksWallsOperation(data, params, context)
	params.player:sendPacket({pid = "WorksWallsOperation", isOpen = params.isOpen})
end

function Actions.SetWorksArchiveNum(data, params, context)
	params.player:sendPacket({ pid = "SetWorksArchiveNum", num = params.num })
end