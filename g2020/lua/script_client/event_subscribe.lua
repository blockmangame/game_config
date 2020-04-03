
Lib.subscribeEvent(Event.EVENT_PLAYER_BEGIN, function()
    FriendManager.LoadFriendData()
end)

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

Lib.subscribeEvent(Event.EVENT_SHOW_INVITE_TIP_BY_SCRIPT, function(packet)
    local time = packet.time
    if time then
        local pushInStackTime = World.Now()
        Lib.RegStack(Player.CurPlayer, "invite_tip", time, function()
            World.Timer(2, function()
                packet.showTime = 100 + time + pushInStackTime - World.Now()
                UI:openWnd("invite_tip", packet)
            end)
        end)
        packet.showTime = time
        if UI:isOpen("invite_tip") then
            UI:getWnd("invite_tip", true):onReload(packet)
        else
            UI:openWnd("invite_tip", packet)
        end
    else
        UI:openWnd("invite_tip", packet)
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
    local ui = UI:openWnd("rewardTip", info)
    ui:root():SetAlwaysOnTop(true)
	ui:root():SetLevel(0)
end)

Lib.subscribeEvent(Event.EVENT_CHECK_FURNITURE_CLICK_ACTION, function(objID, btnCfg)
    Me:checkFurnitureClickAction(objID, btnCfg)
end)

Lib.subscribeEvent(Event.EVENT_RIDE_ON_FURNITURE_BY_INDEX, function(objID, btnCfg)
    Me:sendRideOnFurnitureByIndex(objID, btnCfg.ridePosIndex, btnCfg.targetID)
end)