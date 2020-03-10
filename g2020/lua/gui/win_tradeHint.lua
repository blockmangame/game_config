function M:init()
    WinBase.init(self, "tradeRiskHint.json", false)
	
	self.sureButton = self:child("tradeRiskHint-sureBtn")
	self.callBack = nil

	self:subscribe(self:child("tradeRiskHint-close"), UIEvent.EventButtonClick, function()
		UI:closeWnd(self)
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
end

return M