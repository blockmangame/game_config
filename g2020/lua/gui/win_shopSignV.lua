local setting = require "common.setting"

function M:init()
    WinBase.init(self, "randomTable.json", true)
end

local function getCfgColor(cfg)
	local color = Lib.copy(cfg)
	for i, k in ipairs(color or {}) do
		local pr = tonumber(color[i])
		color[i] = pr < 1 and pr or pr / 255
	end
	return color
end

function M:onOpen(cfgKey)
    local cfg = setting:fetch("ui_config", cfgKey) or {}
	local array = cfg.data or {}
	for index, data in pairs(array) do
		local itemName = "randomTable-item" .. index
		local textName = "randomTable-desc_"..index
		local item = self:child(itemName)
		local text = self:child(textName)
		if item and text then
			item:SetBackgroundColor(getCfgColor(data.backColor))
			text:SetText(Lang:toText(data.name))
			text:SetFontSize(data.textSize or "HT12")
			if data.borderColor then
				text:SetTextBoader(getCfgColor(data.borderColor))
			end

			if cfg.openWin then
				text:SetEnabled(true)
				text:SetTouchable(true)
				self:subscribe(text, UIEvent.EventWindowTouchUp, function()
					UI:openWnd(cfg.openWin.winName, cfg.openWin)
				end)
			end

		end
	end


end

return M


