require "common.gm"
local GMItem = GM:createGMItem()

GMItem["g2020/好友界面"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_FRIEND, true)
end
return GMItem