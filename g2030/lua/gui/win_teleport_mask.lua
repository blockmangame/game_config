local m_posx, m_posy, m_radius = 0,0,0

function M:init()
	WinBase.init(self, "TeleportMask.json")
	self:root():SetLevel(1)
	self.mask = self:child("Mask-Mask")
	local mask = self.mask
	mask:SetTouchable(true)
	mask:SetAlwaysOnTop(true)
	mask:SetImage("teleport.png")
	mask:setProgram("GUIDEMASK")
end

function M:updateMaskImage(img)
	if img then
		self.mask:SetImage(img)
	end
end

local function setTeleportMask(mask, posx, posy, radius, color)
	if not mask or not posx or not posy then
		return
	end
	local size = mask:GetPixelSize()
	mask:material():iSize(size.x, size.y)
	mask:material():iProgress(1)
	mask:material():iPos(posx, posy, 0, 0)
	mask:material():iRadius(radius)
	mask:material():iColor(color)
end

function M:updateMask(posx, posy, radius, color)
	if m_posx == posx and m_posy == posy and m_radius == radius then
		return
	end
	m_posx, m_posy, m_radius = posx, posy, radius, color
	UI.guideMask = {x = tonumber(posx), y = tonumber(posy), r = tonumber(radius)}
	setTeleportMask(self.mask, posx, posy, radius, color)
end

function M:onClose()
	UI.guideMask = {}
end

return M
