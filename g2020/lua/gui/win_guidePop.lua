function M:init()
    WinBase.init(self, "guidePop.json", false)
	
	self.sureButton = self:child("guidePop-sureBtn")
	self.context = self:child("guidePop-hintText")
	self.context:SetFontSize("HT20")
	self.callBack = nil

	self:subscribe(self.sureButton, UIEvent.EventButtonClick, function()
		self:update()
	end)
end

function M:update()
	if self.index == self.count then
		self:child("guidePop-context"):SetVisible(false)
		self.closeTimer = World.Timer(30, function()
			UI:closeWnd(self)
			self.closeTimer = nil
		end)
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
	if self.closeTimer then
		self.closeTimer()
	end
	self:child("guidePop-context"):SetVisible(true)
	self.callBack = callBack
	self.index = 0
	self.texts = showArg.texts or {}
	self.btnText = showArg.btnText or {}
	self.count = #self.texts
	self:update()
end

M.NotDialogWnd = true

return M