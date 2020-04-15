local walletPool = {}
local TCfg = World.cfg.toolBarSetting  or {}

-- pick out ：plareList , teamInfo .
-- optimize in the future : tipGameCountdown, QualitySlider,initCountDownTip
function M:init()
    WinBase.init(self, "ToolBar.json")

    self.rightStartPoint = -220
    self.settingCheckBox = self:child("ToolBar-Setting")
    self.redPoint = self.settingCheckBox:child("ToolBar-Setting-Red")
    self.chatCheckBox = self:child("ToolBar-Chat")
    self.perspective = self:child("ToolBar-Perspece")
    self.btnEmoji = self:child("ToolBar-Emoji")
    self.btnInfo = self:child("ToolBar-Info")
    self.btnShop = self:child("ToolBar-Shop")


    self.gametime = self:child("ToolBar-GameTime-Info")
    self.currency = self:child("ToolBar-Currency-Money")
    self.goldDiamond = self:child("ToolBar-Gold-Diamond")
    self.redPoint:SetVisible(false)
    self.currency:SetVisible(false)

    self:initCountDownTip()

    self.countDownTimer = nil
    self:updatePerspeceIcon()
    self:subscribe(self.settingCheckBox, UIEvent.EventCheckStateChanged, function()
        self:onCheckSettingChanged()
    end)
    self:subscribe(self.chatCheckBox, UIEvent.EventCheckStateChanged, function()
        Lib.emitEvent(Event.EVENT_OPEN_CHATBTN, self.chatCheckBox:GetChecked())
    end)
    self:subscribe(self.perspective, UIEvent.EventButtonClick, function()
        self:onPerspeceChanged()
    end)
    self:subscribe(self.btnEmoji, UIEvent.EventButtonClick, function()
        --TODO
    end)
    self:subscribe(self.btnInfo, UIEvent.EventButtonClick, function()
        --TODO
    end)
    self:subscribe(self.btnShop, UIEvent.EventButtonClick, function()
        --TODO
    end)

    Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
        self:changeCurrency()
    end)
    Lib.subscribeEvent(Event.EVENT_CHANGE_PERSONVIEW, function()
        self:updatePerspeceIcon()
    end)
    Lib.subscribeEvent(Event.EVENT_SHOW_RED_POINT, function()
        self.redPoint:SetVisible(true)
    end)

    Lib.subscribeEvent(Event.EVENT_SHOW_RECHARGE, function()
        CGame.instance:getShellInterface():onRecharge(1)
    end)

    local btnRecharge = self:child("ToolBar-Gold-Diamond-Add")
    if btnRecharge then
        self:subscribe(btnRecharge, UIEvent.EventButtonClick, function()
            if World.cfg.pauseWhenCharge then
                Lib.emitEvent(Event.EVENT_PAUSE_BY_CLIENT)
            end
            Lib.emitEvent(Event.EVENT_SHOW_RECHARGE)
        end)
        Lib.subscribeEvent(Event.EVENT_HIDE_RECHARGE, function(hide)
            btnRecharge:SetVisible(not hide)
        end)
    end

    Lib.subscribeEvent(Event.EVENT_UPDATE_COUNT_DOWN_TIP, function(msg, icon)
        self:updateCountDownTip(msg, icon)
    end)

    Lib.subscribeEvent(Event.EVENT_SHOW_TOOLBAR_BTN, function(name, show)
        if UI:isOpen(self) then
            self:refreshAlignItem(name, show)
        end
    end)

   -- self:initAlignList()

end
--
--function M:initAlignList()
--    self.alignList = {}
--    local defaultMap = {
--        setBox = self.settingCheckBox,
--        chatBox = self.chatCheckBox,
--        perspective = self.perspective
--    }
--    local defaultIdx = {
--        setBox = 1,
--        chatBox = 2,
--        perspective = 3,
--    }
--    self:insertAlignList("setBox", self.settingCheckBox)
--    self:insertAlignList("chatBox", self.chatCheckBox)
--    self:insertAlignList("perspective", self.perspective)
--    local addBtnList = TCfg.addBtnList or {}
--    for index, name in ipairs(addBtnList) do
--        if defaultMap[name] then
--            self:insertAlignList(name, defaultMap[name],defaultIdx[name])
--        else
--            --to do createbtn
--        end
--    end
--    local btnCfg = TCfg.buttonCfg or {}
--    for index, item in pairs(self.alignList or {}) do
--        local name = item.name
--        local cfg = btnCfg[name]
--        if cfg then
--            self:setItemDetails(cfg, name, item.template)
--        end
--    end
--    self:refreshAlignList()
--end
--function M:setItemDetails(cfg, name, template)
--    if cfg.show ~= nil then
--        template:SetVisible(cfg.show)
--    end
--    if cfg.icon ~=nil then
--        template:SetNormalImage(cfg.icon)
--        template:SetPushedImage(cfg.iconPush or cfg.icon)
--    end
--    if cfg.size ~=nil then
--        template:SetWidth({0, cfg.size.w})
--        template:SetHeight({0, cfg.size.h})
--    end
--    if cfg.serverEvent then
--        self:subscribe(template, UIEvent.EventButtonClick, function()
--            Me:sendPacket({pid = "ToolBarBtnClickEvent", key = name})
--        end)
--    end
--end
--
--function M:insertAlignList(name, template, index)
--    local alignList = self.alignList
--    if alignList[index] then
--        return
--    end
--    index = (index and index) or (#alignList + 1)
--    print("------------index---------",index)
--    local idx = #alignList + 1
--    while idx > index do
--        alignList[idx] = alignList[idx - 1]
--        idx = idx - 1
--    end
--    alignList[index] = {name = name, template = template}
--end
--
--function M:refreshAlignItem(name, show)
--    for index, data in pairs(self.alignList or {}) do
--        if data.name == name and data.template then
--            data.template:SetVisible(show)
--        end
--    end
--    self:refreshAlignList()
--end
--
--function M:refreshAlignList() --On the left
--    local x = 10
--    for _, item in ipairs(self.alignList or {}) do
--        local template = item.template
--        if template then
--            local visible = template:IsVisible()
--            if visible then
--                template:SetXPosition({0, x})
--                x = x + template:GetPixelSize().x + 10
--            end
--        end
--    end
--end


local function fetchItem(msg, iconPath)
    local box = GUIWindowManager.instance:CreateGUIWindow1("Layout")
    box:SetHorizontalAlignment(1)
    box:SetVerticalAlignment(0)
    box:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 0, 30 })
    local text = GUIWindowManager.instance:CreateGUIWindow1("StaticText")
    text:SetTouchable(false)
    text:SetHorizontalAlignment(2)
    text:SetVerticalAlignment(1)
    text:SetTextScale(1)
    text:SetWordWrap(true)
    text:SetArea({ 0, 0 }, { 0, 0 }, { 1, -50 }, { 1, 0 })
    text:SetSelfAdaptionArea(true)
    text:SetText(msg)

    local icon = GUIWindowManager.instance:CreateGUIWindow1("StaticImage")
    icon:SetTouchable(false)
    icon:SetHorizontalAlignment(0)
    icon:SetVerticalAlignment(1)
    icon:SetArea({ 0, 10 }, { 0, 0 }, { 0, 30 }, { 0, 30 })
    icon:SetImage(iconPath or "")
    box:AddChildWindow(icon)
    box:AddChildWindow(text)
    return box
end

function M:initCountDownTip()
    local countDownTipItem = fetchItem("")
    countDownTipItem:SetVisible(false)
    self:child("ToolBar-Count-Down-Tip"):AddChildWindow(countDownTipItem)
    self.countDownTipItem = countDownTipItem
end

function M:updateCountDownTip(msg, icon)
    local countDownTipItem =  self.countDownTipItem
    if msg == "-1" then
        countDownTipItem:SetVisible(false)
        return
    end
    countDownTipItem:SetVisible(true)
    countDownTipItem:GetChildByIndex(0):SetText(msg)
    countDownTipItem:GetChildByIndex(1):SetImage(icon or "")
end

function M:onCheckSettingChanged()
    local check = self.settingCheckBox:GetChecked()
    Lib.emitEvent(Event.EVENT_CHECKED_MENU, check)
    if check then
        self.redPoint:SetVisible(false)
    end
end

function M:setChatOpened(isOpened)
    self.chatCheckBox:SetChecked(isOpened)
end

function M:onPerspeceChanged()
    Blockman.instance:switchPersonView()
    PlayerControl.UpdatePersonView()

    local view = Blockman.Instance():getCurrPersonView()
    if view==0 then
        Lib.emitEvent(Event.FRONTSIGHT_SHOW, 2)
    else
        Lib.emitEvent(Event.FRONTSIGHT_NOT_SHOW, 2)
    end
end

function M:updatePerspeceIcon()
    if World.cfg.hidePerSpec then
        self.perspective:SetVisible(false)
        return
    end

    local view = Blockman.instance:getCurrPersonView()
    local imageRes
    if view == 1 then
        imageRes = "set:ninja_main.json image:tool_camera1"
    elseif view == 2 then
        imageRes = "set:ninja_main.json image:tool_camera2"
    else
        imageRes = "set:ninja_main.json image:tool_camera3"
    end
    self.perspective:SetNormalImage(imageRes)
    self.perspective:SetPushedImage(imageRes)
    Me:sendPacket({
        pid = "SyncViewInfo",
        view = Blockman.instance:getCurrPersonView()
    })

    if view==0 then
        Lib.emitEvent(Event.FRONTSIGHT_SHOW, 2)
    else
        Lib.emitEvent(Event.FRONTSIGHT_NOT_SHOW, 2)
    end
end

function M:getCurrencyWindow(window, coinName, cfg, index)
    if walletPool[coinName] then
        return walletPool[coinName]
    end
    --local coinViewCfg = TCfg.coinBarCfg
    local wnd = GUIWindowManager.instance:CloneWindow("CloneWindow-" .. coinName, window)
    local addBtn = cfg.addButton
    local broad = addBtn and -156 or -135
    local start = self.rightStartPoint + (addBtn and -21 or 0)
    local x = start + index * broad + (index > 0 and -2 or 0)
    wnd:SetXPosition({ 0, x})
    wnd:SetVisible(true)
    wnd:GetChildByIndex(0):SetImage(Coin:iconByCoinName(coinName))
    --if coinViewCfg.coinBgImg then
    --    wnd:SetBackImage(coinViewCfg.coinBgImg)
    --end
    --if coinViewCfg.coinAddImg and wnd:GetChildByIndex(2) then
    --    local coinAdd = wnd:GetChildByIndex(2)
    --    coinAdd:SetNormalImage(coinViewCfg.coinAddImg)
    --    coinAdd:SetPushedImage(coinViewCfg.coinAddImg)
    --end
    self:root():AddChildWindow(wnd)
    if cfg.addButton and cfg.buttonEvent then
        local addButton = wnd:GetChildByIndex(2)
        if addButton then
            self:subscribe(addButton, UIEvent.EventButtonClick, function()
                Lib.emitEvent(Event[cfg.buttonEvent], table.unpack(cfg.eventArgs or {}))
            end)
        end
    end
    walletPool[coinName] = wnd
    return wnd
end
function M:changeCurrency()
    local wallet = Me:data("wallet")
    local coinCfg = Coin:GetCoinCfg()
    if not World.cfg.noShowCoin then
        if wallet["gDiamonds"] then
            self.goldDiamond:GetChildByIndex(1):SetText(wallet["gDiamonds"].count or 0)
        end
        local index = 0
        for _, cfg in pairs(coinCfg) do
            if cfg.showUi ~= false then
                local coinName = cfg.coinName
                local addBtn = cfg.addButton
                local iconWnd = self:getCurrencyWindow(addBtn and self.goldDiamond or self.currency, coinName, cfg, index)
                local count = Coin:countByCoinName(Me, coinName)
                iconWnd:GetChildByIndex(1):SetText(tostring(count) or 0)
                index = index + 1
            end
        end
    else
        self.goldDiamond:SetVisible(false)
        self.currency:SetVisible(false)
    end
end

local function insertTable(t, ins_t)
    local res = Lib.copy(t)
    if ins_t.var then
        table.insert(res, (ins_t.insert or 1) + 1, ins_t.var)
    end
    return res
end

function M:tipGameCountdown(keepTime, vars, regId, textArgs, isTip)
    if self.countDownTimer then
        self.countDownTimer()
        self.countDownTimer = nil
    end
    local kTime = keepTime and keepTime / 20  or 2
    local always = kTime < 0
    local tVar, tVars, timing = nil, textArgs, nil
    if vars then
        timing = vars.timing and vars.timing / 20 or -1
        tVar = vars.var / 20
        vars.var = timing > 0 and 1 or tVar
        tVars = insertTable(textArgs, vars)
    end
    local msg = Lang:toText(tVars)
    self.gametime:SetText(tostring(msg))
    self.gametime:SetVisible(kTime > 0 or always)
    local function tick()
        kTime = kTime - 1
        local time = kTime > 0 and (kTime * 20) or keepTime
        self.reloadArg = table.pack(self.countDownTimer, time, vars, regId, textArgs, isTip)
        if tVar then
            vars.var = vars.var + timing
            tVars = insertTable(textArgs, vars)
        end
        msg = Lang:toText(tVars)
        self.gametime:SetText(tostring(msg))
        self.gametime:SetVisible(kTime > 0 or always or (tVar and vars.var > 0 and vars.var <= tVar))
        if not (vars and vars.var > 0 and vars.var <= tVar) and regId then
            Me:doCallBack("SendTip5", "key", regId)
        end
        if tVar and (vars.var > 0 and vars.var <= tVar) then
            return true
        end
        if kTime <= 0 then
            self.reloadArg = table.pack(self.countDownTimer, time, vars, regId, textArgs, false)
            return false
        end
        return true
    end
    self.countDownTimer = World.Timer(20, tick)
end

function M:setChecked(checked)
    self.settingCheckBox:SetChecked(checked)
end


function M:onOpen()
    self.settingCheckBox:SetChecked(false)
    self.chatCheckBox:SetChecked(false)
    if World.cfg.hideSetting then
        self.settingCheckBox:SetVisible(false)
    end
    if World.cfg.hideChatBox then
        self.chatCheckBox:SetVisible(false)
    end
end

function M:onReload(reloadArg)
    local countDownTimer, keepTime, vars, _event, textArgs, isTip = table.unpack(reloadArg or {}, 1, reloadArg and reloadArg.n)
    if countDownTimer then
        countDownTimer()
        countDownTimer = nil
    end
    if isTip and vars then
        vars.var = vars.var * 20
        self:tipGameCountdown(keepTime, vars, _event, textArgs)
    end
end

return M

