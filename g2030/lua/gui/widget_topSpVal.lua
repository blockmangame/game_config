---
---通用进度条数值显示控件
---zhuyayi 20200325
---
local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

function M:init()
    widget_base.init(self, "TopSpVal.json")

    self:initWnd()
end
function M:initWnd()
    self.imgValType = self:child("TopSpVal-Icon")
    self.txtVal = self:child("TopSpVal-Text")
end
---
---desc：根据type类型初始化进度条值
---type = 0：阵营货币
---type = 1：待定
function M:initViewByType(type,pos,root)
    if type == 0 then
        self:initView("set:ninja_main.json image:material_skill",
                Event.EVENT_CHANGE_CURRENCY,
                function ()
                   self.txtVal:SetText(Coin:countByCoinName(Me, Coin:GetCoinCfg()[4].coinName))
                end,
                Coin:countByCoinName(Me, Coin:GetCoinCfg()[4].coinName))
    elseif type == 1 then
        self:initView("set:ninja_main.json image:material_"..self:getIconSrc(),
                Event.EVENT_CHANGE_CURRENCY,
                function ()
                    self.txtVal:SetText(Coin:countByCoinName(Me, Coin:GetCoinCfg()[4].coinName))
                end,
                Coin:countByCoinName(Me, Coin:GetCoinCfg()[4].coinName))
    end
    self._root:SetXPosition({0,pos[1]})
    self._root:SetYPosition({0,pos[2]})
    root:AddChildWindow(self._root)
end
function M:getIconSrc()
    local teamId = Me:getTeamId()
    if teamId == 0 then
        return "neutral"
    elseif teamId == 1 then
        return "kind"
    else
        return "badness"
    end
end
---desc：初始化进度条值
---icon 标题图标
---event 监听事件
---func 监听回调
---cur 初始当前值
function M:initView(icon,event,func,cur)
    self.imgValType:SetImage(icon or "");
    self.txtVal:SetText(cur)
    Lib.subscribeEvent(event, function ()
        func()
    end)
end
function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M