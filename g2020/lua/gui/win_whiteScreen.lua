function M:init()
    WinBase.init(self, "WhiteScreen.json", true)
    self:initEvent()
end

function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_SHOW_WHITE_SCREEN, function(args)
        self._root:SetBackgroundColor({1, 1, 1, 1})
        World.Timer(60, function()
            self._root:SetBackgroundColor({1, 1, 1, 0})
        end)
    end)
end

function M:onOpen()

end