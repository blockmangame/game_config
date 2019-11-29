require "common.gm"
local GMItem = GM:createGMItem()

GMItem["g2020/好友界面"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_FRIEND, true)
end

GMItem["g2020/特权商店"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_PRI_SHOP, true)
end

GMItem["g2020/金币商店"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_GOLD_SHOP, true)
end

return GMItem
