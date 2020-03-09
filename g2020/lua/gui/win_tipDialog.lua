local m_regIds = {}
local m_consumeName
local m_consumeCost

local ViewId = {
    BTN_SURE = 0,
    BTN_CANCEL = 1,
    BTN_PAY_LEFT = 2,
    BTN_PAY_RIGHT = 3,
    BTN_CLOSE = 4
}

local TipType = {
    HINT = 0,
    REVIVE = 1,
    COMMON = 2,
    CONSUME = 3,
    REWARD = 4,
    PAY = 5
}

local ISOPEN = false

local function resetBtnTextTimer(self, dialogContinuedTime)
    if self.updateBtnTextTimer then
        self.updateBtnTextTimer()
    end
    local function updatePayDialogRightText()
        if self.m_payRightBtn:IsVisible() then
            local lessTime = (dialogContinuedTime - World.Now() + self.openTime) // 20
            self.m_payRightBtn:SetText(self.m_payRightBtnShowText .. " ( " .. lessTime .. " )")
        end
    end
    self.updateBtnTextTimer = dialogContinuedTime and World.Timer(20, function()
        if ISOPEN then
            updatePayDialogRightText()
            -- todo ext
            return true
        end
        return false
    end) or nil
end

local function resetDialogContinuedTimer(self, dialogContinuedTime)
    if self.dialogContinuedTimer then
        self.dialogContinuedTimer()
    end
    self.dialogContinuedTimer = dialogContinuedTime and World.Timer(dialogContinuedTime, function()
        if self.ui_timer then
            self.ui_timer()
            self.ui_timer = nil
        end
        if self.m_rewardTipTimer then
            self.m_rewardTipTimer()
            self.m_rewardTipTimer = nil
        end
        if ISOPEN then
            UI:closeWnd(self)
        end
    end) or nil
end

function M:init()
    WinBase.init(self, "TipDialog.json", false)

    self.ui_timer = nil
    self.m_rewardTipTimer = nil

    self.m_showTipType = 0
    self.m_countDown = 0
    self.m_coinCost = 0
    self.m_coinName = ""
    self.m_payLeftCost = 0
    self.m_payLeftCoinName = ""
    self.m_payRightCost = 0
    self.m_payRightCoinName = ""

    self.m_tipDialogPanel = self:child("TipDialog-Panel")
    self.m_tipDialogReward = self:child("TipDialog-Reward-Panel")
    self.m_rewardTitleName = self:child("TipDialog-Reward-Panel-Title-Name")
    self.m_rewardContent = self:child("TipDialog-Reward-Content")
    self.m_rewardCloseBtn = self:child("TipDialog-Reward-Close")
    self.m_rewardTipBtn = self:child("TipDialog-Reward-Tip-Button")
    self.m_rewardTipBtn:SetVisible(false)
    self.m_titleText = self:child("TipDialog-Title-Name")
    self.m_titleCloseBtn = self:child("TipDialog-Title-Btn-Close")
    self.m_messageText = self:child("TipDialog-Content-Vehicle-Message")
    self.m_valueText = self:child("TipDialog-Content-Currency-Value")
    self.m_otherMsgText = self:child("TipDialog-Content-Other-Message")
    self.m_iconImage = self:child("TipDialog-Content-Currency-Icon")
    self.m_cancelBtn = self:child("TipDialog-Btn-Cancel")
    self.m_sureBtn = self:child("TipDialog-Btn-Sure")
    self.m_contentWindow = self:child("TipDialog-Content-Vehicle")
    self.m_otherContentWindow = self:child("TipDialog-Content-Other")
    self.m_payLeftBtn = self:child("TipDialog-Btn-Pay-Left")
    self.m_payRightBtn = self:child("TipDialog-Btn-Pay-Right")

    self.hint = self:child("Hint")
    self.hint:SetVisible(false)
    self.hint_btn = self:child("Hint-Button-Yes")
    self.hint_btn:SetText(Lang:toText("gui.hint.btn"))
    self:subscribe(self.hint_btn, UIEvent.EventButtonClick, function()
        self:onBtnClick(ViewId.BTN_SURE)
    end)

    self:subscribe(self.m_cancelBtn, UIEvent.EventButtonClick, function()
        self:onBtnClick(ViewId.BTN_CANCEL)
    end)
    self:subscribe(self.m_sureBtn, UIEvent.EventButtonClick, function()
        self:onBtnClick(ViewId.BTN_SURE)
    end)
    self:subscribe(self.m_titleCloseBtn, UIEvent.EventButtonClick, function()
        self:onBtnClick(ViewId.BTN_CLOSE)
    end)
    self:subscribe(self.m_rewardCloseBtn, UIEvent.EventButtonClick, function()
        self:onBtnClose()
    end)
    self:subscribe(self.m_payLeftBtn, UIEvent.EventButtonClick, function()
        self:onBtnClick(ViewId.BTN_PAY_LEFT)
    end)
    self:subscribe(self.m_payRightBtn, UIEvent.EventButtonClick, function()
        self:onBtnClick(ViewId.BTN_PAY_RIGHT)
    end)
end

function M:onOpen(dialogContinuedTime, tipType, regId, modName, ...)
    ISOPEN = true
    self.modName = modName
    self.openTime = World.Now()
    resetBtnTextTimer(self, dialogContinuedTime)
    resetDialogContinuedTimer(self, dialogContinuedTime)
    m_regIds[tipType] = regId
    if tipType == TipType.HINT then
        self:showHint(...)
    elseif tipType == TipType.REVIVE then
        self:showRevive(...)
    elseif tipType == TipType.COMMON then
        self:showCommon(...)
    elseif tipType == TipType.CONSUME then
        self:showConsume(...)
    elseif tipType == TipType.REWARD then
        self:showReward(...)
    elseif tipType == TipType.PAY then
        self:showPay(...)
    end
    self.reloadArg = table.pack(dialogContinuedTime, tipType, regId, modName, ...)
end

function M:onUpdateMsg(msg, countDown)
    if self.ui_timer then
        self.ui_timer()
        self.ui_timer = nil
    end

    countDown = countDown or 100
    if self.m_showTipType == TipType.REVIVE then
        local function tick()
            self.m_messageText:SetText(string.format(Lang:toText(msg), math.ceil(countDown / 20)))
            countDown = countDown - 1
            if countDown <= 0 then
                self:onBtnClose()
                return false
            end
            return true
        end
        self.ui_timer = World.Timer(1, tick)
    end
end

function M:showHint(title, desc, btn)
    self.m_showTipType = TipType.HINT
    self:child("Hint-TitleName"):SetText(Lang:toText(title or "gui.hint.title.name"))
    self:child("Hint-Desc"):SetText(Lang:toText(desc or "gui.hint.desc"))
    self.hint_btn:SetText(Lang:toText(btn or "gui.hint.btn"))
    self:refreshHintUI()
end

function M:refreshHintUI()
    self.m_cancelBtn:SetVisible(true)
    self.m_sureBtn:SetVisible(true)
    self.m_tipDialogPanel:SetVisible(false)
    self.m_tipDialogReward:SetVisible(false)
    self.hint:SetVisible(true)
    self.m_payLeftBtn:SetVisible(false)
    self.m_payRightBtn:SetVisible(false)
    self:unsubscribe(self.m_rewardTipBtn)
    self.m_rewardTipTimer = World.Timer(0, function()
        self.m_rewardTipBtn:SetVisible(true)
        self:subscribe(self.m_rewardTipBtn, UIEvent.EventButtonClick, function()
            self:onBtnClose()
        end)
    end)
end

function M:showRevive(coinId, coinCost, countDown, title, sure, cancel, msg, newReviveUI)
    self.m_countDown = countDown
    self.m_coinCost = coinCost
    self.m_coinName = ""
    self.m_showTipType = TipType.REVIVE
    self:show()
    self:refreshReviveUI(title, sure, cancel, msg, newReviveUI)
    local wallet = Me:data("wallet")
    self.m_coinName = Coin:coinNameByCoinId(coinId)
    self.m_iconImage:SetImage(Coin:iconByCoinId(coinId))
    self.m_valueText:SetText(tostring(coinCost))
    local money = wallet and wallet[self.m_coinName] and wallet[self.m_coinName].count or 0
    self.m_sureBtn:SetEnabled(money >= coinCost)
end

function M:refreshReviveUI(title, sure, cancel, msg, newReviveUI)
    msg = msg or "gui_dialog_tip_revive_msg"
    if newReviveUI then 
        self.m_tipDialogPanel:SetBackImage("set:tip_dialog2.json image:bg.png")
        self.m_tipDialogPanel:SetArea({0, 0},{0, 0},{0, 447}, {0, 294})
        self:child("TipDialog-Panel-Btn-Bg"):SetBackImage("set:tip_dialog2.json image:bg2.png")
        self:child("TipDialog-Panel-Btn-Bg"):SetWidth({1,0})
        self.m_cancelBtn:SetPushedImage("set:new_frame_common.json image:btn_green.png")
        self.m_cancelBtn:SetNormalImage("set:new_frame_common.json image:btn_green.png")
        self.m_sureBtn:SetPushedImage("set:new_frame_common.json image:btn_yellow.png")
        self.m_sureBtn:SetNormalImage("set:new_frame_common.json image:btn_yellow.png")
        self.m_titleCloseBtn:SetPushedImage("set:tip_dialog2.json image:close.png")
        self.m_titleCloseBtn:SetNormalImage("set:tip_dialog2.json image:close.png")
        self.m_titleCloseBtn:SetArea({ 0, -30 }, { 0, 10 }, { 0, 27 }, { 0, 24 })
        self.m_valueText:SetTextColor({151/255, 81/255, 74/255})
    end
    self.m_cancelBtn:SetVisible(true)
    self.m_sureBtn:SetVisible(true)
    self.m_tipDialogReward:SetVisible(false)
    self.hint:SetVisible(false)
    self.m_tipDialogPanel:SetVisible(true)
    self.m_rewardTipBtn:SetVisible(true)
    self.m_payLeftBtn:SetVisible(false)
    self.m_payRightBtn:SetVisible(false)
    self.m_titleText:SetText(Lang:toText(title or "gui_dialog_tip_title_tip"))
    self.m_cancelBtn:SetText(Lang:toText(cancel or "gui_dialog_tip_revive_cancel"))
    self.m_sureBtn:SetText(Lang:toText(sure or "gui_dialog_tip_revive_sure"))
    self.m_contentWindow:SetVisible(true)
    self.m_otherContentWindow:SetVisible(false)
    msg = string.format(Lang:toText(msg), self.m_countDown / 20)
    self.m_messageText:SetText(msg)
    self:onUpdateMsg(msg, self.m_countDown)
end

function M:showCommon(contentArgs)
    self.m_showTipType = TipType.COMMON
    self.m_otherMsgText:SetText(Lang:toText(contentArgs))
    self:refreshCommonUI()
end

function M:refreshCommonUI()
    self.m_cancelBtn:SetVisible(true)
    self.m_sureBtn:SetVisible(true)
    self.m_tipDialogReward:SetVisible(false)
    self.hint:SetVisible(false)
    self.m_tipDialogPanel:SetVisible(true)
    self.m_rewardTipBtn:SetVisible(true)
    self.m_payLeftBtn:SetVisible(false)
    self.m_payRightBtn:SetVisible(false)
    self.m_titleText:SetText(Lang:toText("gui_dialog_common_tip"))
    self.m_cancelBtn:SetText(Lang:toText("gui_dialog_tip_common_cancel"))
    self.m_sureBtn:SetText(Lang:toText("gui_dialog_tip_common_sure"))
    self.m_contentWindow:SetVisible(false)
    self.m_otherContentWindow:SetVisible(true)
end

function M:showConsume(contentKey, contentArgs, consumeName, consumeCost)
    self.m_showTipType = TipType.CONSUME
    self.m_messageText:SetText(Lang:toText({ contentKey, table.unpack(contentArgs) }))
    m_consumeName = consumeName
    m_consumeCost = consumeCost
    self.m_coinName = Coin:coinNameByCoinId(m_consumeName)
    self.m_iconImage:SetImage(Coin:iconByCoinId(m_consumeName))
    self.m_valueText:SetText(tostring(consumeCost))
    self:refreshConsumeUI()
end

function M:refreshConsumeUI()
    self.m_cancelBtn:SetVisible(true)
    self.m_sureBtn:SetVisible(true)
    self.m_tipDialogReward:SetVisible(false)
    self.hint:SetVisible(false)
    self.m_tipDialogPanel:SetVisible(true)
    self.m_rewardTipBtn:SetVisible(true)
    self.m_payLeftBtn:SetVisible(false)
    self.m_payRightBtn:SetVisible(false)
    self.m_titleText:SetText(Lang:toText("gui_dialog_consume_tip"))
    self.m_cancelBtn:SetText(Lang:toText("gui_dialog_tip_consume_cancel"))
    self.m_sureBtn:SetText(Lang:toText("gui_dialog_tip_consume_sure"))
    self.m_contentWindow:SetVisible(true)
    self.m_otherContentWindow:SetVisible(false)
end

function M:showReward(reward, time)
    if self.ui_timer then
        self.ui_timer()
        self.ui_timer = nil
    end

    local grid = self.m_rewardContent
    grid:RemoveAllItems()
    grid:InitConfig(60, 15, 5)

    self.m_showTipType = TipType.REWARD
    local index = 0
    local x = #reward * 120
    local y = (#reward // 5 + 1) * 45 + (#reward // 5) * 15
    x = (x <= 575 and x or 575)
    y = (y <= 225 and y or 225)
    grid:SetArea({0, 0}, {0, 20}, {0, x}, {0, y})
    grid:SetMoveAble(#reward > 20 and true or false)

    for i, r in ipairs(reward) do
        local str = "reward-item-" .. index
        local layout_str = str .. "-image"
        local itemLayout = GUIWindowManager.instance:CreateGUIWindow1("Layout", layout_str)
        itemLayout:SetArea({ 0, 0 }, { 0, 0 }, { 0, 45 }, { 0, 45 })
        index = index + 1
        local image_str = str .. "-image"
        local itemImage = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", image_str)
        local icon_path = r.icon
        local type = r.data.type
        local fullName = r.data.name
        local icon = icon_path or ResLoader:getIcon(type, fullName) or "set:ranch_main.json image:ranch_task_help"

        itemImage:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
        itemImage:SetImage(icon)
        itemLayout:AddChildWindow(itemImage)

        local count_str = str .. "-count"
        local itemCount = GUIWindowManager.instance:CreateGUIWindow1("StaticText", count_str)
        itemCount:SetArea({ 1, 10 }, { 0, 0 }, { 0, 20 }, { 0, 20 })
        itemCount:SetVerticalAlignment(1)
        if r.count then
            itemCount:SetText("x" .. r.count)
            itemCount:SetProperty("Font", "HT20")
        elseif r.countRange then
            local range = r.countRange
            itemCount:SetText("x" .. range[1] .. "~" .. range[2])
        end
        itemCount:SetProperty("TextBorder", "true")
        itemCount:SetProperty("AllShowOneLine", "true")

        itemLayout:AddChildWindow(itemCount)
        grid:AddItem(itemLayout)
    end
    if time then
        self.ui_timer = World.Timer(time, self.onBtnClose, self)
    end
    self:refreshRewardUI()
end

function M:refreshRewardUI()
    self.m_cancelBtn:SetVisible(true)
    self.m_sureBtn:SetVisible(true)
    self.m_tipDialogPanel:SetVisible(false)
    self.hint:SetVisible(false)
    self.m_tipDialogReward:SetVisible(true)
    self.m_rewardTitleName:SetText(Lang:toText("gui_dialog_reward_title_name"))
    if self.m_rewardTipTimer then
        self.m_rewardTipTimer()
        self.m_rewardTipTimer = nil
    end
    self:unsubscribe(self.m_rewardTipBtn)
    self.m_rewardTipTimer = World.Timer(0, function()
        self.m_rewardTipBtn:SetVisible(true)
        self:subscribe(self.m_rewardTipBtn, UIEvent.EventButtonClick, function()
            self:onBtnClose()
        end)
    end)
end

function M:showPay(title, content, buttonInfo)
    self.m_showTipType = TipType.PAY
    self.m_titleText:SetText(Lang:toText(title or "gui_dialog_tip_title_tip"))

    local msg = ""
    if content then
        if content.msg and content.args then
            msg = {content.msg, table.unpack(content.args)}
        else
            msg = content
        end
    end
    self.m_otherMsgText:SetText(Lang:toText(msg))

    if buttonInfo then
        local leftCoinId = buttonInfo.leftCoinId or nil
        local leftContent = buttonInfo.leftContent or nil
        local rightCoinId = buttonInfo.rightCoinId or nil
        local rightContent = buttonInfo.rightContent or nil

        if type(leftCoinId) == "number" then
            self.m_payLeftCost = leftContent
            self.m_payLeftBtn:SetText("")
            self.m_payLeftCoinName = Coin:coinNameByCoinId(leftCoinId)
            self:child("TipDialog-Btn-Pay-Left-Currency-Icon"):SetImage(Coin:iconByCoinId(leftCoinId))
            self:child("TipDialog-Btn-Pay-Left-Currency-Value"):SetText(tostring(leftContent))
            self:child("TipDialog-Btn-Pay-Left-Currency"):SetVisible(true)
        else
            self:child("TipDialog-Btn-Pay-Left-Currency"):SetVisible(false)
            self.m_payLeftBtn:SetText(Lang:toText(leftContent or "gui_dialog_tip_pay_left"))
            self.m_payLeftBtn:SetTextColor({ 1, 1, 1, 1 })
            self.m_payLeftBtn:SetProperty("TextShadow", "true")
        end

        if type(rightCoinId) == "number" then
            self.m_payRightCost = rightContent
            self.m_payRightBtn:SetText("")
            self.m_payRightCoinName = Coin:coinNameByCoinId(rightCoinId)
            self:child("TipDialog-Btn-Pay-Right-Currency-Icon"):SetImage(Coin:iconByCoinId(rightCoinId))
            self:child("TipDialog-Btn-Pay-Right-Currency-Value"):SetText(tostring(rightContent))
            self:child("TipDialog-Btn-Pay-Right-Currency"):SetVisible(true)
        else
            self:child("TipDialog-Btn-Pay-Right-Currency"):SetVisible(false)
            self.m_payRightBtnShowText = Lang:toText(rightContent or "gui_dialog_tip_pay_right")
            self.m_payRightBtn:SetText(self.m_payRightBtnShowText)
            self.m_payRightBtn:SetTextColor({ 1, 1, 1, 1 })
            self.m_payRightBtn:SetProperty("TextShadow", "true")
        end
    end

    self:refreshPayUI()
end

function M:refreshPayUI()
    self.m_cancelBtn:SetVisible(false)
    self.m_sureBtn:SetVisible(false)
	self.m_tipDialogReward:SetVisible(false)
    self.m_tipDialogPanel:SetVisible(true)
    self.m_payLeftBtn:SetVisible(true)
    self.m_payRightBtn:SetVisible(true)
    self.m_rewardTipBtn:SetVisible(true)
    self.hint:SetVisible(false)
end

function M:sendResult(result, viewId)
    local regId = m_regIds[self.m_showTipType]
    m_regIds[self.m_showTipType] = nil
    if self.m_showTipType == TipType.HINT then
        Me:doCallBack(self.modName or "dialogTip", tostring(self.m_showTipType), regId, {result=result})
    elseif self.m_showTipType == TipType.REVIVE then
        Me:doCallBack(self.modName or "buyRevive", tostring(self.m_showTipType), regId, {result=result,coinName=self.m_coinName,cost=self.m_coinCost})
    elseif self.m_showTipType == TipType.COMMON then
        Me:doCallBack(self.modName or "dialogTip", tostring(self.m_showTipType), regId, {result=result})
    elseif self.m_showTipType == TipType.CONSUME then
        Me:doCallBack(self.modName or "dialogTip", tostring(self.m_showTipType), regId, {result=result,coinName=self.m_coinName,cost=m_consumeCost})
    elseif self.m_showTipType == TipType.PAY then
        if viewId == ViewId.BTN_PAY_LEFT then
            Me:doCallBack(self.modName or "dialogTip", tostring(self.m_showTipType), regId, {result=result,coinName=self.m_payLeftCoinName,cost=self.m_payLeftCost, button = "left"})
        elseif viewId == ViewId.BTN_PAY_RIGHT then
            Me:doCallBack(self.modName or "dialogTip", tostring(self.m_showTipType), regId, {result=result,coinName=self.m_payRightCoinName,cost=self.m_payRightCost, button = "right"})
        elseif viewId == ViewId.BTN_CLOSE then
            Me:doCallBack(self.modName or "dialogTip", tostring(self.m_showTipType), regId, {result = result, button = "close"})
        end
    end
end

function M:onBtnClick(viewId)
    if viewId == ViewId.BTN_SURE then
        self:sendResult(true)
    elseif viewId == ViewId.BTN_CANCEL then
        self:sendResult(false)
    elseif viewId == ViewId.BTN_PAY_LEFT or viewId == ViewId.BTN_PAY_RIGHT then
        self:sendResult(true, viewId)
    elseif viewId == ViewId.BTN_CLOSE then
        self:sendResult(false, viewId)
    end
    if self.ui_timer then
        self.ui_timer()
        self.ui_timer = nil
    end
    if self.m_rewardTipTimer then
        self.m_rewardTipTimer()
        self.m_rewardTipTimer = nil
    end
    UI:closeWnd(self)
end

function M:onBtnClose()
    if self.ui_timer then
        self.ui_timer()
        self.ui_timer = nil
    end
    if self.m_rewardTipTimer then
        self.m_rewardTipTimer()
        self.m_rewardTipTimer = nil
    end
    self.m_countDown = 0
    self:sendResult(false)
    UI:closeWnd(self)
end

-- function M:onReload(reloadArg)
--     self:onOpen(table.unpack(reloadArg))
-- end
function M:onReload(reloadArg)
    if self.reloadTimer then
        self.reloadTimer()
    end
    self._root:SetVisible(false)
    self.reloadTimer = World.Timer(2, function()
        self._root:SetVisible(true)
        self:onOpen(table.unpack(reloadArg))
		self.reloadTimer = nil
    end)
end

function M:onClose()
    ISOPEN = false
    resetBtnTextTimer(self, nil)
    resetDialogContinuedTimer(self, nil)
    local ret = Lib.PopStack(Player.CurPlayer, "tipDialog")
    if ret then
        ret.func()
    end
end

return M