local M = UI:getWnd("rewardItemEffect")

function M:showIcon(fullName, count, time)
	local icon = Coin:iconByCoinName(fullName)
	Me:addClientBuff("myplugin/test_momey_buff", nil, 200)
	self:showUI(icon, count or 1, time)
end