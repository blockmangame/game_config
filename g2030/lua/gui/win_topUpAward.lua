--- Created by lxm.


function M:init()
    WinBase.init(self, "topUpAward.json",false)
    self.isInitData = false
    self:onLoad()
end

function M:onLoad()
    self:initUI()
end

function M:initUI()

    self.btnClose = self:child("topUpAward-closeBtn")
    



    self:initEvent()
end

function M:initEvent()

    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        self:onHide()
    end)


    Lib.subscribeEvent(Event.EVENT_PLAYER_TOP_UP_INFO, function()
        self.isInitData = true
        -- self:onShow(true)
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