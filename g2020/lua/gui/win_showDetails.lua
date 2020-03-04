local setting = require "common.setting"

local trigger
local cfg = {}
local contents = {}
local widgets ={
    "title",
    "subtitle",
    "contents",
    "comments"
}

local function getCfg(name)
    return contents[name] or cfg[name]
end

function M:init()
    WinBase.init(self, "ShowDetails.json", false)
    self:initProp()
    self:initEvent()
end

function M:initProp()
    self.child = {
        titleText = self:child("Details-Title-Text"),
        titleIcon = self:child("Details-Title-Icon"),

        subtitleText = self:child("Details-Subtitle-Text"),
        subtitleVal = self:child("Details-Subtitle-Val"),

        contentsText = self:child("Details-Contents-Text"),

        commentsText = self:child("Details-Comments-Text"),
        commentsIcon = self:child("Details-Comments-Icon"),
        commentsVal = self:child("Details-Comments-Val"),

        btn = self:child("Details-Btn")
    }
end

function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_UPDATE_DETAILS, function(updateName, val)
        self:updateSubtitleVal(updateName, val)
    end)

    self:subscribe(self.child.btn, UIEvent.EventButtonClick, function()
        Me:sendTrigger(Me, trigger, Me, nil, {
            rtVal = getCfg("btnRtVal")
        })
        UI:closeWnd(self)
    end)

    self:subscribe(self._root, UIEvent.EventWindowClick, function()
        UI:closeWnd(self)
    end)
end

function M:onOpen(packet)
    cfg = setting:fetch("ui_config", packet.fullName)
    contents = packet.contents
    self:setBtn()
    self:setRootUIArea(packet.uiArea)
    for _, typeName in pairs(widgets) do
        self:setWidgetArgs(typeName)
    end
end

function M:onClose()

end

function M:setRootUIArea(info)
    if not info or not next(info) then
        return
    end

    self._root:SetArea(
        {info[1][1], info[1][2]},
        {info[2][1], info[2][2]},
        {info[3][1], info[3][2]},
        {info[4][1], info[4][2]}
    )
end

function M:setBtn()
    local btn = self.child.btn

    local text = getCfg("btnText")
    if text then
        btn:SetText(Lang:toText(text))
    end

    local event = getCfg("btnEvent")
    if event then
        trigger = event
    end

    local pushedImg = getCfg("btnPushedImg")
    if pushedImg then
        btn:SetPushedImage(pushedImg)
    end

    local normalImg = getCfg("btnNormalImg")
    if normalImg then
        btn:SetNormalImage(normalImg)
    end
end

function M:setWidgetFontSize(widget, name)
    local fontSize = getCfg(name.."FontSize")
    if widget and fontSize then
        widget:SetProperty("Font", "HT"..fontSize)
    end
end

function M:setWidgetArgs(typeName)
    local name = typeName.."Text"
    local widget = self.child[name]
    if widget then
        local text = getCfg(name)
        if text then
            self:setWidgetFontSize(widget, name)
            widget:SetText(Lang:toText(text))
        end
    end

    name = typeName.."Icon"
    widget = self.child[name]
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
    widget = self.child[name]
    if widget then
        local val = getCfg(name)
        widget:SetText(val or 0)
        self:setWidgetFontSize(widget, name)
    end
end

function M:updateSubtitleVal(updateName, val)
    local isNeedUpdate = getCfg("isNeedUpdate")
    if UI:isOpen(self) and updateName == isNeedUpdate then
        self.child["subtitleVal"]:SetText(val)
    end
end

return M