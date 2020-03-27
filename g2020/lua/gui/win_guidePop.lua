function M:init()
    WinBase.init(self, "tradeRiskHint.json", false)
	
	self.sureButton = self:child("tradeRiskHint-sureBtn")
	self.context = self:child("tradeRiskHint-hintText")
	self:child("tradeRiskHint-close"):SetVisible(false)
	self.context:SetFontSize("HT20")
	self.callBack = nil

	self:subscribe(self.sureButton, UIEvent.EventButtonClick, function()
		self:update()
	end)
end

function M:update()
	if self.index == self.count then
		UI:closeWnd(self)
		if self.callBack then
			self.callBack(true)
			self.callBack = nil
		end
		return
	end
	self.index = self.index + 1
	self.context:SetText(Lang:toText(self.texts[self.index]))
	self.sureButton:SetText(Lang:toText( self.btnText[self.index] or (self.index ~= self.count and "next_page" or "ui_sure") ))
end

function M:onOpen(showArg, callBack)
	self.callBack = callBack
	self.index = 0
	self.texts = showArg.texts or {}
	self.btnText = showArg.btnText or {}
	self.count = #self.texts
	self:update()
end

M.NotDialogWnd = true

return M