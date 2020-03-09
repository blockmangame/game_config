function M:init()
    WinBase.init(self, "RewardTip.json", true)
    self:initName()
    self:initButton()
end

function M:initName()
    self.name = self:child("RewardTip-name")
end

function M:initButton()
    self.button = self:child("RewardTip-btn")
    self:child("RewardTip-btn-text"):SetText(Lang:toText("gui.reward.get.money"))
end

function M:onOpen(info)
    self:updateNickName()
    if info.regId then
        self:updateButton(info.regId)
    end
end

function M:updateNickName()
    local selfInfo = UserInfoCache.GetCache(Me.platformUserId)
    if selfInfo then
        self.name:SetText(selfInfo.nickName)
    end
end

function M:updateButton(regId)
    self:unsubscribe(self.button, UIEvent.EventButtonClick)
    self:subscribe(self.button, UIEvent.EventButtonClick, function()
        Me:doCallBack("rewardTipDialog", "rewardTip", regId)
        UI:closeWnd(self)
    end)
end

function M:onClose()

end