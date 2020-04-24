--- Created by lxm.

local rechargeAwardConfig = T(Config, "rechargeAwardConfig")

function M:init()
    WinBase.init(self, "topUpAward.json",false)
    self.isInitData = false
    self.isStart = true
    self.isGotSum = false
    self.status = false
    self.items = {}
    self:onLoad()
end

function M:onLoad()
    self:initUI()
end

function M:initUI()

    self.btnClose = self:child("topUpAward-closeBtn")
    self.btnRecharge = self:child("topUpAward-rechargeBtn")
    self.btnReceive = self:child("topUpAward-receiveBtn")
    
    
    self.pbRechargeAward = self:child("topUpAward-progressBarImg")
    
    self.stRechargeSum = self:child("topUpAward-progressText")
    self.stDetails = self:child("topUpAward-detailsText")
    self.stDetails:SetText("Super strong 3-star pets \nfight with you \nDamage increased by tons")

    self.siItemIcons = {}
    self.siItemHighlights = {}
    self.stCounts = {}
    for i = 1, 4 do
        local str = string.format("topUpAward-itemIcon_%d",i)
        print("-------topUpAward------- " .. str)
        self.siItemIcons[i] = self:child(str)
        str = string.format("topUpAward-itemHighlight_%d",i)
        self.siItemHighlights[i] = self:child(str)
        str = string.format("topUpAward-count_%d",i)
        self.stCounts[i] = self:child(str)
    end

    self:initEvent()
end

function M:initEvent()

    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        self:onHide()
    end)

    self:subscribe(self.btnRecharge, UIEvent.EventButtonClick, function()
        --show充值界面
        local rechargeSum = Me:getRechargeSum()
        rechargeSum = rechargeSum + 100
        Me:setRechargeSum(rechargeSum)
    end)

    self:subscribe(self.btnReceive, UIEvent.EventButtonClick, function()
        self.status = self.status + 1
        Me:setRechargeAwardStatus(self.status)
    end)

    Lib.subscribeEvent(Event.EVENT_PLAYER_RECHARGE_SUM, function()
        self.isGotSum = true
        self:upDataWinInfo(self.status)
    end)

end

function M:upDataWinInfo(status)
    self.status = status
    if self.status and self.isGotSum then
        local rechargeSum = Me:getRechargeSum()
        local rewardType = self.status + 1
        print("--------condition-----------"..rewardType)
        local items,condition = rechargeAwardConfig:getRewardTypeItems(rewardType)
        if not condition then            
            self.btnReceive:SetVisible(false)
            return 
        end 
        self.items = items
        local Progress = 0
        local showSum = 0
        if rechargeSum/condition >= 1 then
            Progress = 1
            showSum = condition.."/"..condition
            self.btnRecharge:SetVisible(false)
            self.btnReceive:SetVisible(true)
        else
            Progress = rechargeSum/condition
            showSum = rechargeSum.."/"..condition
            self.btnRecharge:SetVisible(true)
            self.btnReceive:SetVisible(false)
        end
        self.stRechargeSum:SetText(showSum)
        self.pbRechargeAward:SetProgress(Progress)
        self.isInitData = true
        if self.isStart then
            self:onShow(true)
            self.isStart = false
        end
        self:upDataItemInfo()
    end
end

function M:upDataItemInfo()
    -- self.widgets
    -- self.items
    local i = 1
    for _, item in pairs(self.items or {}) do
        self.siItemIcons[i]:SetImage(item.icon)
        self.siItemHighlights[i]:SetVisible(false)
        self.stCounts[i]:SetText("X"..item.count)
        i = i + 1
    end

end

function M:onHide()
    UI:closeWnd("rechargeAward")
end

function M:onShow(isShow)
    if isShow and self.isInitData then
        if not UI:isOpen(self) then
            UI:openWnd("rechargeAward")
        end
    else
        self:onHide()
    end
end

function M:onOpen()

end



return M