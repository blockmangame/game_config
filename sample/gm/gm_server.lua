require "common.gm"
local GMItem = GM:createGMItem()

GMItem["sample/卡牌选项"] = function(self)
    Trigger.CheckTriggers(self:cfg(), "SHOW_CARDOPTIONS", {obj1 = self})
end

return GMItem