
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