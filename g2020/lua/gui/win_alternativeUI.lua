function M:init()
    WinBase.init(self, "AlternativeUI.json", false)
	
	self.msgLayout = self:child("AlternativeUI-ContentMsgLayout")
	self.msgText = self:child("AlternativeUI-ContentMsg")
	self.tipLayout = self:child("AlternativeUI-TopLayout")
	self.tipText = self:child("AlternativeUI-TopText")
	self.imageLayout = self:child("AlternativeUI-ContentImageLayout")
	self.showImage = self:child("AlternativeUI-ContentImage")
	self.imageHitText = self:child("AlternativeUI-ImageHitText")
	self.imageHitIcon = self:child("AlternativeUI-ImageIcon")
	self.sureBtnLayout = self:child("AlternativeUI-SureBtnLayout")
	self.sureButton = self:child("AlternativeUI-SureButton")
	self.colseButton = self:child("AlternativeUI-CloseButton")
	self.mainImage = self:child("AlternativeUI-ContentBigImage")
	self.callBack = nil

	self:subscribe(self.colseButton, UIEvent.EventButtonClick, function()
		UI:closeWnd(self)
		if self.callBack then
			self.callBack(false)
		end
	end)

	self:subscribe(self.sureButton, UIEvent.EventButtonClick, function()
		UI:closeWnd(self)
		if self.callBack then
			self.callBack(true)
		end
	end)

	self.style = nil
end

function M:onOpen(showArg, callBack)
	if self.style ~= showArg.style then
		self.style = showArg.style
		self:changeStyle(showArg.styleCfg)
	end
	self.callBack = callBack
	if showArg.showImage then
		self.showImage:SetVisible(true)
		self.showImage:SetImage(showArg.showImage)
	else
		self.showImage:SetVisible(false)
	end
	if showArg.hitIcon then
		self.imageHitIcon:SetVisible(true)
		self.imageHitIcon:SetImage(showArg.hitIcon)
	else
		self.imageHitIcon:SetVisible(false)
	end
	if showArg.hitText then
		self.imageHitText:SetVisible(true)
		self.imageHitText:SetText(Lang:toText(showArg.hitText))
	else
		self.imageHitText:SetVisible(false)
	end
	if showArg.mainImage then
		self.mainImage:SetVisible(true)
		self.mainImage:SetImage(showArg.mainImage)
	else
		self.mainImage:SetVisible(false)
	end
	self.tipText:SetText(Lang:toText(showArg.titleText or "ui_tip"))
	self.msgText:SetText(Lang:toText(showArg.msgText or ""))
	self.sureButton:SetText(Lang:toText(showArg.btnText))
end

function M:changeStyle(cfg)
	for name, style in pairs(cfg) do
		local wnd = self[name]
		if wnd then
			wnd:SetProperty(style)
		end
	end
end

return M