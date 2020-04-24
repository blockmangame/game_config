local setting = require "common.setting"
local function getCfgColor(cfg)
    local color = Lib.copy(cfg)
    for i, k in ipairs(color or {}) do
        local pr = tonumber(color[i])
        color[i] = pr < 1 and pr or pr / 255
    end
    return color
end


function M:init()
    WinBase.init(self, "LotteryInfo.json", true)
    self:initMain()
end

function M:onOpen(data)
    local ivIcon = self:child("LotteryInfo-Icon")
    local tvName = self:child("LotteryInfo-Name")
    local item = Item.CreateItem(data.item)
    tvName:SetText(Lang:toText({"lottery_prize_title",  Lang:getMessage(item:cfg().itemname)}))
    ivIcon:SetImage(item:icon())
    self:initItems(data.rewardInfo)
end

function M:initMain()

    self:subscribe(self:child("LotteryInfo-Close"), UIEvent.EventButtonClick, function()
        UI:closeWnd(self)
    end)

    self:initTitle()
    self:initPrizeTitle()
    self:initItems()
end


function M:initTitle()
    local ivIconBg = self:child("LotteryInfo-IconBg")

end

function M:initPrizeTitle()
    local tvPrizeNameText = self:child("LotteryInfo-PrizeNameText")
    local tvPrizeQualityText = self:child("LotteryInfo-PrizeQualityText")
    local tvPrizeProbabilityText = self:child("LotteryInfo-PrizeProbabilityText")
    tvPrizeNameText:SetText(Lang:toText("lottery_prize_name_text"))
    tvPrizeQualityText:SetText(Lang:toText("lottery_prize_quality_text"))
    tvPrizeProbabilityText:SetText(Lang:toText("lottery_prize_probability_text"))
end



function M:initItems(info)
    local lvList = self:child("LotteryInfo-Items")
    lvList:SetInterval(3)
    lvList:ClearAllItem()

    local cfg = setting:fetch("reward", info)
    table.sort(cfg, function (a , b)
        local a1 = Item.CreateItem(a.name):cfg()
        local b1 = Item.CreateItem(b.name):cfg()
        return a1.quality > b1.quality
    end)

    for _, v in ipairs(cfg) do
        lvList:AddItem(self:createItem(v), false)
    end
end

local QualityColor = {
    {156, 156, 156, 255},
    {148, 225, 131, 255},
    {147, 180, 235, 255},
    {211, 147, 235, 255},
    {248, 222, 077, 255},

}

local QualityText = {
    "lottery_quality_1",
    "lottery_quality_2",
    "lottery_quality_3",
    "lottery_quality_4",
    "lottery_quality_5",
}

local QualityTextColor = {
    {094, 094, 094, 255},
    {000, 136, 026, 255},
    {000, 108, 235, 191},
    {159, 000, 189, 255},
    {181, 111, 000, 255},

}

local QualityIconBack = {
    "set:lottery_info.json image:1",
    "set:lottery_info.json image:2",
    "set:lottery_info.json image:3",
    "set:lottery_info.json image:4",
    "set:lottery_info.json image:5",
}



function M:createItem(item)

    local prize = Item.CreateItem(item.name)
    local info = prize:cfg()

    local itemView = GUIWindowManager.instance:LoadWindowFromJSON("LotteryInfoItem.json")

    local itemQuality = itemView:child("LotteryInfoItem-PrizeQuality")

    itemQuality:SetBackgroundColor(getCfgColor(QualityColor[info.quality]))
    itemQuality:SetTextColor(getCfgColor(QualityTextColor[info.quality]))
    itemQuality:SetText(Lang:getMessage(QualityText[info.quality]))
    itemQuality:SetProperty("Font", "HT18")


    local tvName = itemView:child("LotteryInfoItem-PrizeName")
    tvName:SetBackgroundColor(getCfgColor(QualityColor[info.quality]))
    tvName:SetTextColor(getCfgColor(QualityTextColor[info.quality]))
    tvName:SetText(Lang:getMessage(info.itemname))
    tvName:SetProperty("Font", "HT18")


    local ivBack = itemView:child("LotteryInfoItem-IconBack")
    ivBack:SetImage(QualityIconBack[info.quality])

    local ivIcon = itemView:child("LotteryInfoItem-Icon")
    ivIcon:SetImage(prize:icon())

    local tvProbability = itemView:child("LotteryInfoItem-PrizeProbability")
    tvProbability:SetBackgroundColor(getCfgColor(QualityColor[info.quality]))
    tvProbability:SetTextColor(getCfgColor(QualityTextColor[info.quality]))
    tvProbability:SetText(tostring(item.weight) .. "%")
    tvProbability:SetProperty("Font", "HT18")

    itemView:SetArea({ 0, 0 }, { 0, 9 }, { 1, 0 }, { 0, 86})

    return itemView
end




return M