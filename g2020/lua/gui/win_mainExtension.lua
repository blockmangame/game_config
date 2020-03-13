function M:init()
    WinBase.init(self, "MainExtensionPanel.json",false)

    self.curBaseXPos = 1
    self:initWnd()
end

function M:initWnd()
    self.base = self:child("MainExtensionPanel-Content")
    self.itemsLayout = self:child("MainExtensionPanel-Items")
    self:initBtns()
    self:initBtnsEvent()
    self:hideLayout()
end

function M:initBtns()
    self.openBtn = self:child("MainExtensionPanel-Open-Btn")
    self.hideBtn = self:child("MainExtensionPanel-Hide-Btn")

    self.photoBtn = self:child("MainExtensionPanel-Photo-Btn")
    self.shopBtn = self:child("MainExtensionPanel-Shop-Btn")
    self.familyBtn = self:child("MainExtensionPanel-Family-Btn")
    self.orderBtn = self:child("MainExtensionPanel-Order-Btn")
    self.dressBtn = self:child("MainExtensionPanel-Dress-Btn")
    self.partyBtn = self:child("MainExtensionPanel-Party-Btn")
end

function M:initBtnsEvent()

    self:subscribe(self.openBtn, UIEvent.EventButtonClick, function()
        self:openLayout()
    end)

    self:subscribe(self.hideBtn, UIEvent.EventButtonClick, function()
        self:hideLayout()
    end)

    self:subscribe(self.photoBtn, UIEvent.EventButtonClick, function()
        Me:sendTrigger(Me, "START_CAMERA_MODE", Me)
    end)

    self:subscribe(self.shopBtn, UIEvent.EventButtonClick, function()
        Lib.emitEvent(Event.EVENT_SHOW_PRI_SHOP, true)
    end)

    self:subscribe(self.familyBtn, UIEvent.EventButtonClick, function()
        Me:sendTrigger(Me, "SHOW_TEAM_UI", Me)
    end)

    self:subscribe(self.orderBtn, UIEvent.EventButtonClick, function()
        Lib.emitEvent(Event.EVENT_SHOW_WORK_DETAILS, true)
    end)

    self:subscribe(self.dressBtn, UIEvent.EventButtonClick, function()
        Lib.emitEvent(Event.EVENT_OPEN_DRESS_ARCHIVE, true)
    end)

    self:subscribe(self.partyBtn, UIEvent.EventButtonClick, function()
        Lib.emitEvent(Event.EVENT_SHOW_PARTY_LIST, true)
    end)
end

function M:openLayout()
    -- 动画
    self.openBtn:SetVisible(false)
    self.curBaseXPos = 1

    local function callback()
        self.curBaseXPos = self.curBaseXPos - 0.2
        self.itemsLayout:SetXPosition({self.curBaseXPos, 0})
        if self.curBaseXPos > 0 then
            return true
        else
            self.hideBtn:SetVisible(true)
            self.itemsLayout:SetXPosition({0, 0})
            return false
        end
    end

    World.Timer(1, callback)
end

function M:hideLayout()
    -- 动画
    self.hideBtn:SetVisible(false)
    self.curBaseXPos = 0

    local function callback()
        self.curBaseXPos = self.curBaseXPos + 0.2
        self.itemsLayout:SetXPosition({self.curBaseXPos, 0})
        if self.curBaseXPos < 1 then
            return true
        else
            self.openBtn:SetVisible(true)
            self.itemsLayout:SetXPosition({1, 0})
            return false
        end
    end

    World.Timer(1, callback)
end