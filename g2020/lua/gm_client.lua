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

GMItem["g2020/关闭引导"] = function()
    local packet ={
        pid = "GMGuide",
        close = true
    }
    Lib.emitEvent(Event.EVENT_GUIDE_GM, packet)
end

GMItem["g2020/重置引导"] = function()
    local packet = {
        pid = "GMGuide",
        reset = true
    }
    Lib.emitEvent(Event.EVENT_GUIDE_GM, packet)
end

GMItem["g2020/派对列表"] = function()
    UI:openWnd("party_list")
end

return GMItem
