function M:init()
    WinBase.init(self, "tradeRiskHint.json", false)
	
	self.sureButton = self:child("tradeRiskHint-sureBtn")
	self.callBack = nil

	self:subscribe(self:child("tradeRiskHint-close"), UIEvent.EventButtonClick, function()
		UI:closeWnd(self)
		if self.callBack then
			self.callBack(false)
			self.callBack = nil
		end
	end)

	self:subscribe(self.sureButton, UIEvent.EventButtonClick, function()
		UI:closeWnd(self)
		if self.callBack then
			self.callBack(true)
			self.callBack = nil
		end
	end)
end

function M:onOpen(showArg, callBack)
	self.callBack = callBack
	self:child("tradeRiskHint-hintText"):SetText(Lang:toText(showArg.text or "gui.trade.risk.hint"))
	self.sureButton:SetText(Lang:toText(showArg.btnText or "ui_sure"))
	local disableClose = showArg.disableClose
	if disableClose ~= nil then
		self:child("tradeRiskHint-close"):SetVisible(not disableClose)
	else
		self:child("tradeRiskHint-close"):SetVisible(true)
	end
end

return M