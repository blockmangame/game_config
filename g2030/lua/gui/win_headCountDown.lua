
function M:init()
    WinBase.init(self, "headCountDown.json")
	self.countdown = self:child("headCountDown-text")
	self.countdown1 = self:child("headCountDown-text1")
	self.countdown:SetProperty("Font", "HT30")
	self.countdown:SetVisible(false)
	self.countdown1:SetProperty("Font", "HT30")
end

function M:onOpen(packet, textColor, backColor)
	--if self:show() then
	--	return
	--end
	--window:onOpen(...)
	print("M:onOpen(packet, textColor, backColor) "..tostring(55555555))
	print("==== packet.otime :  "..tostring(packet.otime))
	print("==== packet.time :  "..tostring(packet.time))
	print(" ====  os.time() :  "..tostring( os.time()))
	local time = packet.time - os.time()
	local num = packet.num
	local type = packet.type
	self.countdown1:SetText("+ "..tostring(BigInteger.Create(num))..tostring(Lang:toText(Coin:coinNameByCoinId(type))))
	if not self:isvisible() then
        self:show()
    end
	if not time or time <= 0 then
		return
	end
	local closeTimer = self.closeTimer
   if closeTimer then
		closeTimer()
		self.closeTimer = nil
   end
   local hours, min, second = Lib.timeFormatting(time)
   self.countdown:SetText(string.format("%02d:%02d", min, second))
   local function tick()
		time = time - 1
		if UI:getWnd("headCountDown") and time >0 then
			local hours, min, second = Lib.timeFormatting(time)
			self.countdown:SetVisible(true)
			self.countdown:SetText(string.format("%02d:%02d", min, second))
		end
		if UI:getWnd("headCountDown") and time <= 0 then
			--self:hide()
			self.countdown:SetVisible(false)
			return false
		end
		return time > 0
   end
    self.closeTimer = World.Timer(20, tick)
end

function M:onClose()
	local closeTimer = self.closeTimer
	if closeTimer then
		closeTimer()
		self.closeTimer = nil
	end
end

return M