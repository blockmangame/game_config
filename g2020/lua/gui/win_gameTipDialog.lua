M.NotDialogWnd = true

function M:init()
    WinBase.init(self, "GameTipDialog.json", true)

    self.m_tvTitle = self:child("GameTipDialog-Title")
    self.m_msgText = self:child("GameTipDialog-MsgText")
    self.m_btnSure = self:child("GameTipDialog-BtnSure")
    self.m_btnCancel = self:child("GameTipDialog-BtnCancel")
    self.m_btnExit = self:child("GameTipDialog-BtnExit")

    self.m_showType = 1  -- 0 - dead    1 - close game ...

    self:subscribe(self.m_btnSure, UIEvent.EventButtonClick, function()
        self:btnSureClick()
    end)

    self:subscribe(self.m_btnExit, UIEvent.EventButtonClick, function()
        self:btnExitClick()
    end)

    self:subscribe(self.m_btnCancel, UIEvent.EventButtonClick, function()
        self:btnCancelClick()
    end)
    self.m_showAll = nil
end

function M:refreshUi(callback, showType)

    self.m_showType = showType or self.m_showType

    local title = Lang:toText("composition.tip.title")
    local sureTxt = self.m_btnSure:GetText()
    local cancelTxt = self.m_btnCancel:GetText()
    local msgTxt = self.m_msgText:GetText()
    if self.m_showType == 0 then

    elseif self.m_showType == 1 then -- 退出游戏
        sureTxt = Lang:toText("gui_menu_exit_game_sure")
        cancelTxt = Lang:toText("gui_menu_exit_game_cancel")
        msgTxt = Lang:toText("gui_menu_exit_game")

        self.m_btnSure:SetVisible(true)
        self.m_btnCancel:SetVisible(true)
        self.m_btnExit:SetVisible(false)

    elseif self.m_showType == 2 then -- 防沉迷
        sureTxt = Lang:toText("gui_menu_exit_game_sure")
        msgTxt = Lang:toText("anti_addiction_system_msg")
        title = Lang:toText("anti_addiction_system_tip")
        self.m_btnSure:SetVisible(false)
        self.m_btnCancel:SetVisible(false)
        self.m_btnExit:SetVisible(true)
    else

    end

    self.m_msgText:SetText(msgTxt)
    self.m_btnSure:SetText(sureTxt)
    self.m_btnExit:SetText(sureTxt)
    self.m_btnCancel:SetText(cancelTxt)
    self.m_tvTitle:SetText(title)
    self:showAllHide(callback)
    self.reloadArg = table.pack(callback)

end

function M:btnSureClick()
    if self.m_showType == 0 then

    elseif self.m_showType == 1 then
        CGame.instance:exitGame()
    else

    end
end


function M:btnExitClick()
    CGame.instance:exitGame()
end

function M:btnCancelClick()
    if self.m_showType == 0 then

    elseif self.m_showType == 1 then
        if self.m_showAll then
            self.m_showAll()
        end
        UI:closeWnd(self)
    else

    end
end

function M:showAllHide(callback)
    self.m_showAll = callback
end

function M:onReload(reloadArg)
    local callback = table.unpack(reloadArg or {}, 1, reloadArg and reloadArg.n)
    self:refreshUi(callback)
end

return M