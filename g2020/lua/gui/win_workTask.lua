local wndEvent = {}

function M:init()
	WinBase.init(self, "CircleProgress.json")

	local closeGpsBtn = self:child("CircleProgress-gpsBtn")
	local closeText = self:child("CircleProgress-btnText")
	
	closeText:SetText(Lang:toText("close_gps"))
	self:root():AddChildWindow(closeGpsBtn)
	self.closeGpsBtn = closeGpsBtn
	self.closeGpsBtn:SetVisible(false)
	self.forceClose = false

	self.context = self:child("CircleProgress-context")
	self.centerBtn = self:child("CircleProgress-centerBtn")
	self.background = self:child("CircleProgress-bg")


	Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function (UIName)
		if UIName == "circleProgress" and UI:isOpen(self) then
			self:updateUI()
		end
	end)

	Lib.subscribeEvent(Event.EVENT_GUIDE_POSITION_CHANGE, function(pos)
		if UI:isOpen(self) and World.cfg.showCloseGpsBtn and not self.forceClose then
			self.closeGpsBtn:SetVisible(pos ~= nil)
		end
	end)

	self:subscribe(self.centerBtn, UIEvent.EventButtonClick, function()
		Me:sendPacket({
			pid = "GuidePositionChange",
			show = true,
			key = "taskWork"
		})
		self.closeGpsBtn:SetVisible(true)
		self.closeGpsBtn:SetArea({ 0, -205 }, { 0, 65 }, { 0, 150}, { 0, 75})
	end)

	self:subscribe(self.closeGpsBtn, UIEvent.EventButtonClick, function()
		Me:setGuidePosition(nil)
		Me:sendPacket({
			pid = "GuidePositionChange",
			show = false
		})
		self.closeGpsBtn:SetVisible(false)
	end)
end

function M:updateUI()
	local data = UI:getRemoterData("circleProgress") or {}
	if self.animation then
		self.animation()
		self.animation = nil
		self.context:SetArea({0, -10},{0,50},{0,200},{0,100})
	end
	if data.BtnText and not data.animation then
		self.centerBtn:SetText(Lang:toText(data.BtnText))
	end
	if data.Progress then
		self.progress = data.Progress
	end
	if data.Progress and not data.animation then
		self.background:setSectorBar(self.progress, 15, 50)
	end
	if data.isTasking then
		self.isTasking = data.isTasking
		self.closeGpsBtn:SetArea({ 0, -205 }, { 0, 65 }, { 0, 150}, { 0, 75})
		self.context:SetVisible(true)
	else
		self.context:SetVisible(false)
		self.closeGpsBtn:SetArea({ 0, 0 }, { 0, 65 }, { 0, 150}, { 0, 75})
	end
	local btnText = data.BtnText
	if data.animation then
		local x = 200
		local time = 0
		local op = -1
		self.context:SetVisible(true)
		if self.animation then
			self.animation()
			self.animation = nil
		end
		self.animation = World.Timer(3, function()
			x = x + 10.5 * op
			time = time + 3
			if UI:isOpen(self) then
				self.context:SetArea({0, x},{0,50},{0,200},{0,100})
			end
			if time >=60 and time <= 80 and UI:isOpen(self) then
				self.background:setSectorBar(self.progress, 15, 50)
				if btnText then
					self.centerBtn:SetText(btnText)
					btnText = nil
				end
				op = 0
			elseif UI:isOpen(self) and time > 80 and time <= 140 then
				op = 1
			end
			if time > 140 and UI:isOpen(self) then
				self.context:SetVisible(false)
				self.context:SetArea({0, -10},{0,50},{0,200},{0,100})
			end
			return time <= 140
		end)
		data.animation = false
	end
	data = {}
end

function M:onOpen()
	self:showTaskGps(false)
end

function M:showTaskGps(show)
	if show then
		self:updateUI()
		Me:sendPacket({
			pid = "GuidePositionChange",
			show = true,
			key = "taskWork"
		})
	end
end

function M:onClose()

end

return M