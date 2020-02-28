
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

Lib.subscribeEvent(Event.EVENT_SHOW_SINGLE_FAMILY, function(show, ...)
    local window = UI:getWnd("singleFamily", true)
    if show then
        UI:openWnd("singleFamily", ...)
    else
        UI:closeWnd("singleFamily")
    end
end)