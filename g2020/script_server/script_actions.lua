local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.RefreshNumberBoardText(data, params, context)
	params.player:sendPacket({
		pid = "RefreshNumberBoardText",
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
    local curTid = item:tid()
	local curSlot = item:slot()
    local types = item:tray_type()
	local dstTid, dstSlot
    for tid, _ in pairs(types) do
        local ret = entity:tray():query_trays(tid)
        for _, element in pairs(ret) do
            local _tid, _tray = element.tid, element.tray
            local slot = _tray:find_free()
            if curTid ~= _tid then
				dstTid = _tid
				dstSlot = slot or 1
            end
        end
    end
	if not dstTid then
		return
	end
	local entityTrays = entity:tray()
	local tray_1 = entityTrays:fetch_tray(curTid)
	local tray_2 = entityTrays:fetch_tray(dstTid)
	
	if not Tray:check_switch(tray_1, curSlot, tray_2, dstSlot) then
		return
	end

	Tray:switch(tray_1, curSlot, tray_2, dstSlot) 
	entity:syncSkillMap()
end