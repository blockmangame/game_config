---
---通用进度条数值显示控件
---zhuyayi 20200325
---
local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

function M:init()
    widget_base.init(self, "TopValBar.json")

    self:initWnd()
end
function M:initWnd()
    --self.base = self:child("MainScreen-Content")
    self.pgsVal = self:child("TopValBar-Progress")
    self.imgValType = self:child("TopValBar-Icon")
    self.txtVal = self:child("TopValBar-Text")
end
---
---desc：根据type类型初始化进度条值
---type = 0：肌肉值
---type = 1：血量
function M:initViewByType(type,pos,root)
    if type == 0 then
        self:initView("set:ninja_main.json image:bar_mp_icon",
                    "set:ninja_main.json image:bar_mp",
                    Event.EVENT_EXP_CHANGE,
                    function ()
                        self.txtVal:SetText(Me:getCurExp().."/"..Me:getMaxExp())
                        self.pgsVal:SetProgress(Me:getCurExp() / Me:getMaxExp())
                    end,
                    Me:getCurExp(),
                    Me:getMaxExp()
                )
    elseif type == 1 then
        self:initView("set:ninja_main.json image:bar_hp_icon",
                    "set:ninja_main.json image:bar_hp",
                    Event.EVENT_HP_CHANGE,
                    function ()
                    
                        self.txtVal:SetText(Me:getCurHp().."/"..Me:getMaxHp())
                        self.pgsVal:SetProgress(Me:getCurHp() / Me:getMaxHp())
                    end,
                    Me:getCurHp(),
                    Me:getMaxHp()
                )
    end
    self._root:SetXPosition({0,pos[1]})
    self._root:SetYPosition({0,pos[2]})
    root:AddChildWindow(self._root)
end
---desc：初始化进度条值
---icon 标题图标
---barImg 进度条图片
---event 监听事件
---func 监听回调
---cur 初始当前值
---max 初始最大值
function M:initView(icon,barImg,event,func,cur,max)
    local str = cur.."/"..max
    print("-------------cur-------------",cur)
    print("--------------max------------",max)
    print("------------ret--------------",str)
    print("------------ret-val-------------",cur/max)
    self.imgValType:SetImage(icon or "");
    self.pgsVal:SetProgressImage(barImg or "")
    self.txtVal:SetText(cur.."/"..max)
    self.pgsVal:SetProgress(cur/ max)
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