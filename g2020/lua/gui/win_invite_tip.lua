local setting = require "common.setting"
local ISOPEN = false

local function getCfg(cfg, name)
    return cfg[name]
end

function M:init()
    WinBase.init(self, "InviteTip.json", true)
    self:initHeadPic()
    self:initTitle()
    self:initContent()
    self:initBtns()
    self.cfg = nil
end

function M:onOpen(packet)
    ISOPEN = true
    self.pushInTextTimerBtn = {}
    self.cfg = setting:fetch("ui_config", packet.fullName)
    self:updateBgImage()
    self:updateHeadPic(packet.pic)
    self:updateTitle(packet.titleText)
    self:updateContent(packet.content)
    self:updateBtns(packet.buttonInfo)
    self:autoCloseUI(packet.showTime)
    self.regId = packet.regId
    self.modName = packet.modName
end

function M:onClose(eventKey)
    if self.closeTimer then
        self.closeTimer()
        self.closeTimer = nil
    end
    if eventKey and self.regId then
        Me:doCallBack(self.modName, eventKey, self.regId)
    end
    self.regId = nil
    ISOPEN = false
    self.pushInTextTimerBtn = {}
    if self.updateBtnTextTimer then
        self.updateBtnTextTimer()
        self.updateBtnTextTimer = nil
    end
    local ret = Lib.PopStack(Player.CurPlayer, "invite_tip")
    if ret then
        ret.func()
    end
end

function M:initHeadPic()
    self.headPic = self:child("InviteTip-Pic")
end

function M:initTitle()
    self.title = self:child("InviteTip-Title")
    self.titleText = self:child("InviteTip-Title-Text")
    self.titleIcon = self:child("InviteTip-Title-Icon")
end

function M:initContent()
    self.content = self:child("InviteTip-Content")
end

function M:initBtns()
    self.btnLayout = self:child("InviteTip-Buttons")
end

local function _updateArea(self, view, params)
    local area = getCfg(self.cfg, params)
    if area ~= nil then
        view:SetArea(
            {area[1][1], area[1][2]},
            {area[2][1], area[2][2]},
            {area[3][1], area[3][2]},
            {area[4][1], area[4][2]}
        )
    end
end

local function _updateBgImage(self)
    local bgImage = getCfg(self.cfg, "bgImage")
    self._root:SetBackImage(bgImage or "set:invite_tip.json image:bg2")
end

local function _updateBgStretchType(self)
    local bgStretchType = getCfg(self.cfg, "bgStretchType")
    if bgStretchType ~= nil then
        self._root:SetProperty("StretchType", bgStretchType)
    end
end

local function _updateBgStretchOffset(self)
    local bgStretchOffset = getCfg(self.cfg, "bgStretchOffset")
    if bgStretchOffset ~= nil then
        self._root:SetProperty("StretchOffset", bgStretchOffset)
    end
end

function M:updateBgImage()
    _updateBgImage(self)
    _updateArea(self, self._root, "bgArea")
    _updateBgStretchType(self)
    _updateBgStretchOffset(self)
end

local function _updateHeadPicImage(self, pic)
    local isPicUrl = getCfg(self.cfg, "isPicUrl")
    if isPicUrl then
        if pic and #pic > 0 then
            self.headPic:SetImageUrl(pic)
        else
            self.headPic:SetImage("set:default_icon.json image:header_icon")
        end
    else
        self.headPic:SetImage(pic or "")
    end
end

local function _updateHeadPicVAlign(self)
    local HeadPicVAlign = getCfg(self.cfg, "HeadPicVAlign")
    self.headPic:SetVerticalAlignment(HeadPicVAlign or 0)
end

local function _updateHeadPicHAlign(self)
    local HeadPicHAlign = getCfg(self.cfg, "HeadPicHAlign")
    self.headPic:SetHorizontalAlignment(HeadPicHAlign or 0)
end

function M:updateHeadPic(pic)
    local showHeadPic = getCfg(self.cfg, "showHeadPic")
    if showHeadPic then
        _updateHeadPicImage(self, pic)
        _updateArea(self, self.headPic, "picArea")
        _updateHeadPicVAlign(self)
        _updateHeadPicHAlign(self)
    else
        self.headPic:SetImage("")
    end
end

local function _updateTitleIcon(self)
    local titleIcon = getCfg(self.cfg, "titleIcon")
    self.titleIcon:SetImage(titleIcon or "")
end

local function _updateTitleText(self, titleText)
    local defaultTitleText = getCfg(self.cfg, "defaultTitleText")
    local text = titleText or defaultTitleText or ""
    self.titleText:SetText(Lang:toText(text))
end

local function _updateTitleFontSize(self)
    local titleFontSize = getCfg(self.cfg, "titleFontSize")
    if titleFontSize ~= nil then
        self.titleText:SetProperty("Font", "HT" .. titleFontSize)
    end
end

function M:updateTitle(titleText)
    _updateArea(self, self.title, "titleArea")
    _updateTitleIcon(self)
    _updateArea(self, self.titleIcon, "titleIconArea")
    _updateTitleText(self, titleText)
    _updateArea(self, self.titleText, "titleTextArea")
    _updateTitleFontSize(self)
end

local function _updateContentText(self, content)
    local msg = ""
    if content then
        if content.msg and content.args then
            msg = {content.msg, table.unpack(content.args)}
        else
            msg = content
        end
    end
    self.content:SetText(Lang:toText(msg))
end

local function _updateContentFontSize(self)
    local contentFontSize = getCfg(self.cfg, "contentFontSize")
    if contentFontSize ~= nil then
        self.content:SetProperty("Font", "HT" .. contentFontSize)
    end
end

local function _updateContentHAlign(self)
    local contentHAlign = getCfg(self.cfg, "contentHAlign")
    if contentHAlign ~= nil then
        self.content:SetHorizontalAlignment(contentHAlign)
    end
end

local function _updateContentVAlign(self)
    local contentVAlign = getCfg(self.cfg, "contentVAlign")
    if contentVAlign ~= nil then
        self.content:SetVerticalAlignment(contentVAlign)
    end
end

function M:updateContent(content)
    _updateArea(self, self.content, "contentArea")
    _updateContentText(self, content)
    _updateContentFontSize(self)
    _updateContentHAlign(self)
    _updateContentVAlign(self)
end

local function _updateBtnLayoutArea(self, btnNum)
    self.btnLayout:SetArea({0, 0}, {0, -10}, {0, btnNum * 145 + (btnNum - 1) * 10}, {0.35, 0})
end

local function _updateBtnArea(btn, index)
    btn:SetArea({0, (index - 1) * 155}, {0, 0}, {0, 145}, {1, 0})
end

local function _updateBtnImage(btn, btnInfo)
    btn:SetNormalImage(btnInfo.normalImage or "set:invite_tip.json image:green_btn")
    btn:SetPushedImage(btnInfo.pushedImage or "set:invite_tip.json image:green_btn")
end

local function _updateBtnText(self, btn, btnInfo)
    btn:SetText(Lang:toText(btnInfo.text) or "")
    if btnInfo.pushInTextTimer then
        self.pushInTextTimerBtn[#self.pushInTextTimerBtn + 1] = {btn = btn, text = Lang:toText(btnInfo.text) or ""}
    end
end

local function _updateBtnEvent(btn, index)
    M:subscribe(btn, UIEvent.EventButtonClick, function()
        UI:closeWnd("invite_tip", "button" .. index)
    end)
end

local function _updateBtnStretchType(self, btn)
    local btnStretchType = getCfg(self.cfg, "btnStretchType")
    if btnStretchType ~= nil then
        btn:SetProperty("StretchType", btnStretchType)
    end
end

local function _updateBtnStretchOffset(self, btn)
    local btnStretchOffset = getCfg(self.cfg, "btnStretchOffset")
    if btnStretchOffset ~= nil then
        btn:SetProperty("StretchOffset", btnStretchOffset)
    end
end

function M:updateBtns(buttonInfo)
    self.btnLayout:CleanupChildren()
    if not buttonInfo then
        return
    end
    _updateBtnLayoutArea(self, #buttonInfo)
    for i, btnInfo in pairs(buttonInfo) do
        local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "InviteTip-Buttons" .. i)
        _updateBtnArea(btn, i)
        _updateBtnImage(btn, btnInfo)
        _updateBtnText(self, btn, btnInfo)
        _updateBtnEvent(btn, i)
        _updateBtnStretchType(self, btn)
        _updateBtnStretchOffset(self, btn)
        self.btnLayout:AddChildWindow(btn)
    end
end

local function updateBtnText(self, showTime)
    for _, tb in pairs(self.pushInTextTimerBtn) do
        if tb.btn:IsVisible() then
            local lessTime = (showTime - World.Now() + self.openTime) // 20
            tb.btn:SetText(tb.text .. " ( " .. lessTime .. " )")
        end
    end
end

function M:autoCloseUI(showTime)
    if not showTime then
        return
    end
    self.openTime = World.Now()
    if self.updateBtnTextTimer then
        self.updateBtnTextTimer()
        self.updateBtnTextTimer = nil
    end
    self.updateBtnTextTimer = World.Timer(20, function()
        if ISOPEN then
            updateBtnText(self, showTime)
            return true
        end
        return false
    end)
    self.closeTimer = World.Timer(showTime, function ()
        if UI:isOpen(self) then
            UI:closeWnd(self, "autoClose")
        end
    end)
end

function M:onReload(packet)
    if self.reloadTimer then
        self.reloadTimer()
    end
    self._root:SetVisible(false)
    self.reloadTimer = World.Timer(2, function()
        self._root:SetVisible(true)
        self:onOpen(packet)
		self.reloadTimer = nil
    end)
end

return M