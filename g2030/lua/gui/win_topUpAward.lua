--- Created by lxm.


function M:init()
    -- WinBase.init(self, "skillControl.json",false)
    -- self.isInitData = false
    -- self:onLoad()
end

function M:onLoad()
    self:initUI()
end

function M:initUI()





    self:initEvent()
end

function M:initEvent()

    Lib.subscribeEvent(Event.EVENT_PLAYER_PROCEED_RECHARGE, function()

    end)

end

function M:onHide()
    UI:closeWnd("topUpAward")
end

function M:onShow(isShow)
    if isShow and self.isInitData then
        if not UI:isOpen(self) then
            UI:openWnd("topUpAward")
            else
                self:onHide()
        end
    else
        self:onHide()
    end
end

function M:onOpen()

end



return M