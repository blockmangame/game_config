M.NotDialogWnd = true
function M:init()
    WinBase.init(self, "RewardTip.json", true)
    self:initName()
    self:initButton()
    self:initContent()
    self.isVip = false
end

function M:initName()
    self.name = self:child("RewardTip-name")
end

function M:initButton()
    self.button = self:child("RewardTip-btn")
    self:child("RewardTip-btn-text"):SetText(Lang:toText("gui.reward.get.money"))
end

function M:initContent()
    self.moneyText = self:child("RewardTip-number")
    self.dollarText = self:child("RewardTip-dollar-text")
end

function M:onOpen(info)
    local func = function(goodInfo)
        if goodInfo[1] >= 1 then
            self.isVip = true
            self.dollarText:SetText("40")
            self.moneyText:SetText("forty")
        end

        self:updateNickName()
        if info.regId then
            self:updateButton(info.regId)
        end
    end

    if not self.isVip then
        Me:sendPacket({pid = "GetGoodsInfo", indexs ={1}}, func)
    else
        self.dollarText:SetText("40")
        self.moneyText:SetText("forty")
        self:updateNickName()
        if info.regId then
            self:updateButton(info.regId)
        end
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