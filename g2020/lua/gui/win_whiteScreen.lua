function M:init()
    WinBase.init(self, "WhiteScreen.json", true)
    self.colorSign = 1
    self:initEvent()
end

local function setWhiteScreen(self)
    if self.colorSign <= 0 then
        return
    end

    self.colorTimer = World.Timer(5, function()
        self.colorSign = self.colorSign - 0.5
        self._root:SetBackgroundColor({1, 1, 1, self.colorSign})
        setWhiteScreen(self)
    end)
end

function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_SHOW_WHITE_SCREEN, function(args)
        self._root:SetBackgroundColor({1, 1, 1, 1})
        self.colorSign = 1

        World.Timer(60, function()
            setWhiteScreen(self)
        end)
    end)
end

function M:onOpen()

end