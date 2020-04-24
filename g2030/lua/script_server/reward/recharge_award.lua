
local rechargeAwardConfig = T(Config, "rechargeAwardConfig")
local skillShopConfig = T(Config, "skillShopConfig")

local rewardType = {
    weapon = 1,
    skin = 2,
    pet = 3,
    skill = 4,
    belt = 5,
}

local rechargeAward = {}
function rechargeAward:onButtonClick(player, awardType, AwardStatus)
    print("!!!!!config--..........................")

    local items,condition = rechargeAwardConfig:getRewardTypeItems(awardType)
    if not condition then
        print("!!!!!config--nil")
        return
    end
    self:onReceiveAward(player,items)
end

function rechargeAward:onReceiveAward(player,items, AwardStatus)
    for _, item in pairs(items or {}) do
        if item.goodsType == rewardType.weapon then
        elseif item.goodsType == rewardType.skin then
        elseif item.goodsType == rewardType.pet then
        elseif item.goodsType == rewardType.skill then
        elseif item.goodsType == rewardType.belt then
        end
    end
    player:setRechargeAwardStatus(AwardStatus + 1)
end
