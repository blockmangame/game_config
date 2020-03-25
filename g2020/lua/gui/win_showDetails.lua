M.NotDialogWnd = true
local setting = require "common.setting"
local trigger
local cfg = {}
local contents = {}
local subtitleSpecs = {
    lineSpace = 2,
    font = 20,
    txtVAlign = 1,
    txtHAlign = 2,
    vAlign = 0,
    hAlign = 2,
    nameXPos = {0, -72},
    nameWidth = 130,
    nameHeight = 47,
    percent = {{0.52, 0}, {0, 0}, {0, 70}, {1, 0}}
}
local widgets ={ "title", "contents", "comments" }

local function getCfg(name)
    return contents[name] or cfg[name]
end

local _getRate = function(usedTime, duration)
    return (duration <= 0 and {0} or {math.floor(100 * usedTime / duration)})[1]
end

function M:init()
    WinBase.init(self, "ShowDetails.json", false)
    self:initProp()
    self:initEvent()
end

function M:initProp()
    self._root:SetTouchable(false)
    self.detailsPanel = self:child("Details-Panel") --Layout
    self.detailsMain = self:child("Details-Main")   --Layout
    self.headLine = self:child("Details-HeadLine")  --Layout
    self.mainBody = self:child("Details-MainBody")  --Layout
    self.subtitle = {}
    self.subtitleHadLines = 0
    self.Child = {
        titleText = self:child("Details-Title-Text"),
        titleIcon = self:child("Details-Title-Icon"),
        contentsText = self:child("Details-Contents-Text"),
        commentsText = self:child("Details-Comments-Text"),
        commentsIcon = self:child("Details-Comments-Icon"),
        commentsVal = self:child("Details-Comments-Val"),
        btn = self:child("Details-Btn")
    }
end

function M:calculatePanelArea(isReset)
    local hadLines = self.subtitleHadLines
    if isReset then
        self.subtitleHadLines = 0
    end
    if hadLines <= 1 then
        return
    end
    local multiplier = isReset and -1 or 1
    local panelAddedLine = hadLines - 1
    local heightAdded = panelAddedLine * (subtitleSpecs.nameHeight + subtitleSpecs.lineSpace) - subtitleSpecs.lineSpace
    local mainBodyY = self.mainBody:GetYPosition()
    mainBodyY[2] = mainBodyY[2] + heightAdded * multiplier
    self.mainBody:SetYPosition(mainBodyY)
    for _, v in pairs({self.headLine, self.detailsMain, self.detailsPanel}) do
        local height = v:GetHeight()
        height[2] = height[2] + heightAdded * multiplier
        v:SetHeight(height)
    end
end

function M:setSubtitleArgs()
    local subtitleData = getCfg("subtitle")
    for _, data in pairs(subtitleData) do
        local objID = tonumber(data.objID)
        local entity = World.CurWorld:getEntity(objID)
        if not entity then
            goto continue
        end
        if not self.subtitle[objID] then
            local name = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "")
            local percent = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "")
            name:AddChildWindow(percent)
            self.headLine:AddChildWindow(name)
            name:SetArea(
                    subtitleSpecs.nameXPos,
                    {0, self.subtitleHadLines * (subtitleSpecs.nameHeight + subtitleSpecs.lineSpace)},
                    {0, subtitleSpecs.nameWidth},
                    {0, subtitleSpecs.nameHeight}
            )
            percent:SetArea(table.unpack(subtitleSpecs.percent))
            for _, v in pairs({name, percent}) do
                v:SetVerticalAlignment(subtitleSpecs.vAlign)
                v:SetHorizontalAlignment(subtitleSpecs.hAlign)
                v:SetTextVertAlign(subtitleSpecs.txtVAlign)
                v:SetTextHorzAlign(subtitleSpecs.txtHAlign)
                v:SetProperty("Font", "HT"..subtitleSpecs.font)
            end
            self.subtitleHadLines = self.subtitleHadLines + 1
            self.subtitle[objID] = {name = name, percent = percent}
        end
        local subtitle = self.subtitle[objID]
        local usedTime = data.usedTime
        local duration = data.duration
        if subtitle.cdTimer then
            subtitle.cdTimer()
        end
        subtitle.name:SetText(entity.name)
        subtitle.percent:SetText(_getRate(usedTime, duration).."%")
        subtitle.cdTimer = (not data.isReleasing and {nil} or {World.Timer(20, function ()
            usedTime = usedTime + 20
            subtitle.percent:SetText(_getRate(usedTime, duration).."%")
            return usedTime < duration
        end)})[1]
        ::continue::
    end
    self:calculatePanelArea()
end

function M:removeSubtitleCell()
    for _, v in pairs(self.subtitle) do
        v.name:RemoveChildWindow1(v.percent)
        self.headLine:RemoveChildWindow1(v.name)
        if v.cdTimer then v.cdTimer() end
        v.name, v.percent, v.cdTimer  = nil, nil, nil
    end
    self.subtitle = {}
end

function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_SET_DETAILS, function(packet)
        cfg = setting:fetch("ui_config", packet.fullName)
        contents = packet.contents
        self:removeSubtitleCell()
        self:calculatePanelArea(true)
        self:setSubtitleArgs()
        self:setBtn()
        for _, typeName in pairs(widgets) do
            self:setWidgetArgs(typeName)
        end
    end)

    self:subscribe(self.Child.btn, UIEvent.EventButtonClick, function()
        Me:sendTrigger(Me, trigger, Me, nil, {
            rtVal = getCfg("btnRtVal")
        })
        Lib.emitEvent(Event.EVENT_SET_UI_VISIBLE)
        UI:closeWnd(self)
    end)
end

function M:onOpen()

end

function M:onClose()
    local closeTrigger = getCfg("closeEvent")
    if closeTrigger then
        Me:sendTrigger(Me, closeTrigger, Me, nil, {uiName = getCfg("btnRtVal")})
    end
end

function M:setBtn()
    local btn = self.Child.btn

    local text = getCfg("btnText")
    if text then btn:SetText(Lang:toText(text)) end

    local event = getCfg("btnEvent")
    if event then trigger = event end

    local pushedImg = getCfg("btnPushedImg")
    if pushedImg then btn:SetPushedImage(pushedImg) end

    local normalImg = getCfg("btnNormalImg")
    if normalImg then btn:SetNormalImage(normalImg) end
end

function M:setWidgetFontSize(widget, name)
    local fontSize = getCfg(name.."FontSize")
    if widget and fontSize then
        widget:SetProperty("Font", "HT"..fontSize)
    end
end

function M:setWidgetArgs(typeName)
    local name = typeName.."Text"
    local widget = self.Child[name]
    if widget then
        local text = getCfg(name)
        if text then
            self:setWidgetFontSize(widget, name)
            widget:SetText(Lang:toText(text))
        end
    end

    name = typeName.."Icon"
    widget = self.Child[name]
    if widget then
        local icon = getCfg(name)
        if icon then
            widget:SetImage(icon)
        else
            local coinName = getCfg(typeName.."CurrencyIcon")
            if coinName then
                widget:SetImage(Coin:iconByCoinName(coinName))
            end
        end
    end

    name = typeName.."Val"
    widget = self.Child[name]
    if widget then
        local val = getCfg(name)
        widget:SetText(val or 0)
        self:setWidgetFontSize(widget, name)
    end
end

return M