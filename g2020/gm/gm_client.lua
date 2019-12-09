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

GMItem["g2020/打工按钮"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_WORK_DETAILS, true)
end

GMItem["g2020/签到"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_NEW_SIGIN_IN, true)
end

return GMItem
