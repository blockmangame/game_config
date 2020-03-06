
Lib.subscribeEvent(Event.EVENT_SHOW_PRI_SHOP, function(show)
	if show then
		Me:uiBehaviorLog("priShop",string.format("%s open privateShop", Me.name), "")
	end
end)

Lib.subscribeEvent(Event.EVENT_SHOW_GOLD_SHOP, function(show)
	if show then
		Me:uiBehaviorLog("goldShop", string.format("%s open goldShop", Me.name), "")
	end
end)

Lib.subscribeEvent(Event.EVENT_SHOW_SINGLE_TEAM, function(show, ...)
    local window = UI:getWnd("singleTeam", true)
    if show then
        UI:openWnd("singleTeam", ...)
    else
        UI:closeWnd("singleTeam")
    end
end)

Lib.subscribeEvent(Event.EVENT_SHOW_TEAM, function(show, ...)
    local window = UI:getWnd("team", true)
    if show then
        if window and UI:isOpen(window) then
            window:onOpen(...)
            return
        end
        UI:openWnd("team", ...)
    else
        UI:closeWnd("team")
    end
end)

Lib.subscribeEvent(Event.EVENT_SHOW_PROGRESS_FOLLOW_OBJ, function(packet)
    UI:openWnd("objProgress")
    Lib.emitEvent(Event.EVENT_SET_OBJ_PROGRESS_ARGS, packet)
end)

Lib.subscribeEvent(Event.EVENT_SHOW_DETAILS, function(packet)
    if packet.isOpen then
        UI:openWnd("showDetails", packet)
    else
        UI:closeWnd("showDetails")
    end
end)

Lib.subscribeEvent(Event.EVENT_OPEN_BAG_BY_GIVEAWAY, function(objID)
    local player = World.CurWorld:getObject(objID) -- 目标
    if not player then
        return
    end
    assert(player.isPlayer)
    UI:openWnd("bag_g2020")
    Player.CurPlayer:updateGiveAwayStatus(true, objID)
end)

Lib.subscribeEvent(Event.EVENT_SHOW_DIALOG_TIP, function(tipType,  ...)
    if tipType then
        UI:openWnd("tipDialog", tipType, ...)
    end
end)