
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
        UI:openWnd("showDetails")
        Lib.emitEvent(Event.EVENT_SET_DETAILS, packet)
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

Lib.subscribeEvent(Event.EVENT_SHOW_DIALOG_TIP, function(tipType, dialogContinuedTime,  ...)
    if tipType then
        local t = {tipType, ...}
        if dialogContinuedTime then
            local pushInStackTime = World.Now()
            Lib.RegStack(Player.CurPlayer, "tipDialog", dialogContinuedTime, function()
                World.Timer(2, function()
                    UI:openWnd("tipDialog", dialogContinuedTime and (100 + dialogContinuedTime + pushInStackTime - World.Now()) or nil, table.unpack(t))
                end)
            end)
            if UI:isOpen("tipDialog") then
                UI:getWnd("tipDialog", true):onReload({dialogContinuedTime, table.unpack(t)})
            else
                UI:openWnd("tipDialog", dialogContinuedTime, table.unpack(t))
            end
        else
            UI:openWnd("tipDialog", dialogContinuedTime, table.unpack(t))
        end
    end
end)

Lib.subscribeEvent(Event.EVENT_SYNC_STATES_DATA, function(packet)
    if packet.isClose then
        UI:closeWnd("playerState")
        return
    end
    UI:openWnd("playerState")
    Lib.emitEvent(Event.EVENT_SYNC_DATA, packet.data)
end)

Lib.subscribeEvent(Event.EVENT_SHOW_REWARD_DIALOG, function(info)
    UI:openWnd("rewardTip", info)
end)