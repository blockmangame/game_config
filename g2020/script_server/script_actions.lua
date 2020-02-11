local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.RefreshNumberBoardText(data, params, context)
	params.player:sendPacket({
		pid = "RefreshNumberBoardText",
		wndKey = params.wndKey,
		text = params.text,
	})
end

function Actions.RefreshBlackBoardText(data, params, context)
	params.player:sendPacket({
		pid = "RefreshBlackBoardText",
		wndKey = params.wndKey,
		text = params.text,
	})
end

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

function Actions.EquipItem(data, params, content)
	local item = params.item
	local entity = params.entity
	if not item or not entity then
        return 
    end
	local tray = entity:tray()
	local curTid = item:tid()
	local curSlot = item:slot()
	local function canEquipTrayTid(item, tid)
	    if not item then
			return 
		end
		local curTid = tid or item:tid()
		local types = item:tray_type()
		for tid, _ in pairs(types) do
			local ret = tray:query_trays(tid)
			for _, element in pairs(ret) do
				local _tid, _tray = element.tid, element.tray
				local slot = _tray:find_free()
				if curTid ~= _tid then
					return _tid, slot or 1
				end
			end
		end
	end

	local function takeoffItem(tid, slot)
		local sloter = tray:fetch_tray(tid):fetch_item(slot)
		if sloter then
			local equipTid, equipSlot = canEquipTrayTid(sloter, tid)
			local entityTrays = entity:tray()
			local tray_1 = entityTrays:fetch_tray(tid)
			local tray_2 = entityTrays:fetch_tray(equipTid)
			print(tid, slot, equipTid, equipSlot)
			Tray:switch(tray_1, slot, tray_2, equipSlot)
		end
	end
	local dstTid, dstSlot = canEquipTrayTid(item)
	if not dstTid then
		return
	end
	local entityTrays = entity:tray()
	local tray_1 = entityTrays:fetch_tray(curTid)
	local tray_2 = entityTrays:fetch_tray(dstTid)
	takeoffItem(dstTid, dstSlot)
	if not Tray:check_switch(tray_1, item:slot(), tray_2, dstSlot) then
		return
	end

	Tray:switch(tray_1, curSlot, tray_2, dstSlot) 
	entity:syncSkillMap()
end