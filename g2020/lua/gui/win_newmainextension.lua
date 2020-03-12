function M:init()
	WinBase.init(self, "NewMainExtensionPanel.json",false)

    self.itemList = {}
    self.callback = {}
    self.curBaseXPos = 1

	self:initWnd()
    self:initItemsDetail()
    self:registerMapEvent()

end

function M:initWnd()
    self.base = self:child("NewMainExtensionPanel-Content")
    self.itemsLayout = self:child("NewMainExtensionPanel-Items")

    self.hideBtn = self:child("NewMainExtensionPanel-Hide-Btn")
    self:subscribe(self.hideBtn, UIEvent.EventButtonClick, function()
        self:hideLayout()
    end)

    self.openBtn = self:child("NewMainExtensionPanel-Open-Btn")
    self:subscribe(self.openBtn, UIEvent.EventButtonClick, function()
        self:openLayout()
    end)

    Lib.subscribeEvent(Event.EVENT_UPDATE_EXTENSION_BTN, function (btnList)
        self:refreshBtnShowOrHide(btnList)
    end)
end

function M:onClose()

end

local function updateItemArea(view, i, btnNum)
    local x = math.ceil(i / 2 - 1)
    local y = 0
    if i % 2 == 0 then
        y = 1
    end
    view:SetArea({0, x * (90 + 10)}, {0, y * (110 + 2)}, {0, 90}, {0, 110})
    view:SetVerticalAlignment(0)
    if i == btnNum and (btnNum % 2) == 1 then
        view:SetVerticalAlignment(1)
    end
end

local function updateBtnsShowAndArea(self, showBtnNum)
    local showIndex = 1
    for _, item in ipairs(self.itemList) do
        if item.show then
            item.view:SetVisible(true)
            updateItemArea(item.view, showIndex, showBtnNum)

            showIndex = showIndex + 1
        else
            item.view:SetVisible(false)
        end
    end
end

local function setBtnItemInfo(self, item)
    local view = item.view

    local btn = view:child("NewMainExtensionCell-Btn")
    btn:SetNormalImage(item.iconPath)
    btn:SetPushedImage(item.iconPath)

    local name = view:child("NewMainExtensionCell-Text")
    name:SetText(Lang:toText(item.name))
    name:SetVisible(item.showName)

    local tipText = view:child("NewMainExtensionCell-Tip-Text")
    tipText:SetText(Lang:toText(item.tipWords))

    self:unsubscribe(btn, UIEvent.EventButtonClick)
    self:subscribe(btn, UIEvent.EventButtonClick, function()
        self:doCallback(item.event)
        if item.hideLayout then
            self:hideLayout()
        end
    end)
end

function M:registerMapEvent()
    for k, v in  pairs(self.itemList) do
        self.callback[v.event] = function()
            if v.callbackType == 1 then
                UI:Open(v.callbackEvent)
            elseif v.callbackType == 2 then
                Me:sendTrigger(Me, v.callbackEvent, Me)
            elseif v.callbackType == 3 then
                Lib.emitEvent(Event[v.callbackEvent], true)
            end
        end
    end
end

function M:doCallback(key)
    if self.callback[key] then
        self.callback[key]()
    end
end

function M:initItemsDetail()
    local content = World.cfg.uiExtension
    if not content then
        return
    end
    self.base:SetVisible(true)
    self.hideBtn:SetTouchable(true)
    self.hideBtn:SetVisible(false)
    self.openBtn:SetTouchable(true)
    self.itemsLayout:SetXPosition({1, 0})

    if content.hideBtnIcon then
        self.hideBtn:SetNormalImage(content.hideBtnIcon)
        self.hideBtn:SetPushedImage(content.hideBtnIcon)
    end
    if content.openBtnIcon then
        self.openBtn:SetNormalImage(content.openBtnIcon)
        self.openBtn:SetPushedImage(content.openBtnIcon)
    end

    if content.btnList then
        local btnList = content.btnList
        local showBtnNum = 0
        for _, btn in ipairs(btnList) do
            local btnView = GUIWindowManager.instance:LoadWindowFromJSON("NewMainExtensionCell.json")
            self.itemsLayout:AddChildWindow(btnView)

            btn.show = btn.show == nil and true or btn.show
            btn.showName = btn.showName == nil and true or btn.showName
            btn.hideLayout = btn.hideLayout or false

            local _tb = {
                view = btnView,
                show = btn.show,
                iconPath = btn.iconPath or "",
                name = btn.name or "",
                showName = btn.showName,
                tipWords = btn.tipWords or "",
                event = btn.event or "",
                callbackType = btn.callbackType or 0,
                callbackEvent = btn.callbackEvent or "",
                hideLayout = btn.hideLayout
            }

            setBtnItemInfo(self, _tb)

            table.insert(self.itemList, _tb)

            if _tb.show then
                showBtnNum = showBtnNum + 1
            end
        end

        local colNum = math.ceil(showBtnNum / 2)
        local baseWidth = 90 * colNum + 10 * (colNum - 1)
        local baseHeight = 110 * 2 + 2
        self.base:SetWidth({0, baseWidth})
        self.base:SetHeight({0, baseHeight})

        updateBtnsShowAndArea(self, showBtnNum)
    end
end

function M:openLayout()
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

function M:refreshBtnShowOrHide(btnList)
    for _, changeItem in pairs(btnList) do
        for _, item in ipairs(self.itemList) do
            if changeItem.name == item.name then
                item.show = changeItem.show
            end
        end
    end

    local showBtnNum = 0
    for _, item in pairs(self.itemList) do
        if item.show then
            showBtnNum = showBtnNum + 1
        end
    end

    local colNum = math.ceil(showBtnNum / 2)
    local baseWidth = 90 * colNum + 10 * (colNum - 1)
    self.base:SetWidth({0, baseWidth})

    updateBtnsShowAndArea(self, showBtnNum)
end