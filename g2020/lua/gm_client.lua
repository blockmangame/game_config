require "common.gm"
local GMItem = GM:createGMItem()

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

GMItem["g2020/派对设置"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_PARTY_SETTING, true)
end

GMItem["g2020/派对内部设置"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_PARTY_INNER_SETTING, true, {inPartyOwnerId = 18512})
end

GMItem["关闭引导"] = function()
    Me:sendPacket({
        pid = "GMGuide",
        close = true
    })
end

GMItem["重置引导"] = function()
    Me:sendPacket({
        pid = "GMGuide",
        reset = true
    })
end

return GMItem
