function M:init()
    WinBase.init(self, "MainExtensionReward.json")

    self.text = self:child("MainExtensionReward-CD-text")

    Lib.subscribeEvent(Event.EVENT_SHOW_REWARD_CD, function(time)
        self:showRewardCD(time)
    end)

    self:subscribe(self:child("MainExtensionReward-CD"), UIEvent.EventWindowClick , function()
        Lib.emitEvent(Event.EVENT_SHOW_GOLD_SHOP, true)
    end)

end

function M:showRewardCD(time)
    if self.rewardCDTimer then
        self.rewardCDTimer()
        self.rewardCDTimer = nil
    end

    local function timeFormat(tickTime)
        local totalTime = math.modf(tickTime / 20)
        local hours = string.format("%02d", math.modf(totalTime / 3600))
        local minutes = string.format("%02d", math.modf(totalTime % 3600 /60))
        local seconds = string.format("%02d", math.modf(totalTime % 60))
        return string.format("%s:%s:%s", hours, minutes, seconds)
    end

    self.text:SetText(timeFormat(time))
    local function tick()
        time = time - 20
        if time < 0 then
            time = 0
        end
        self.text:SetText(timeFormat(time))
        return true
    end
    self.rewardCDTimer = World.Timer(20, tick)
end