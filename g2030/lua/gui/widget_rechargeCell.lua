local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

function M:init()
    widget_base.init(self, "widget_recharge_cell.json")

    self.timer_cell = self:child("widget_recharge_cell-timer_cell")
    self.image_cell = self:child("widget_recharge_cell-image_cell")
    self.count_cell = self:child("widget_recharge_cell-count_cell")
    self.count_text = self:child("widget_recharge_cell-count_text")
    self.count_text:SetText("")
end

function M:IMAGE(imagePath)
    self.image_cell:SetImage(imagePath or "")
end

function M:COUNT(count)
    self.count_text:SetText(count)
end

local function updateMask(cell, startTime, updateTime, stopTime)
    local mask = 0
	local upMask = 1 / (stopTime - startTime)
	local temp = (updateTime or 0) - startTime
	if temp > 0 then
		mask = temp * upMask
	end
	cell:setMask(mask)
    local function tick()
        if not cell then
            return false
        end
        mask = mask + upMask
        if mask >= 1 then
            cell:setMask(0, 0.5,0.5)
            return false
        end
        cell:setMask(1 - mask, 0.5,0.5)
        return true
    end
    return World.Timer(1, tick)
end

function M:RECHARGE(startTime, updateTime, stopTime)
    self:RESET_RECHARGE()
    self.timer = updateMask(self.timer_cell, startTime, updateTime, stopTime)
    return self.timer
end

function M:RESET_RECHARGE()
    if self.timer then
        self.timer()
        self.timer = nil
    end
    self.timer_cell:setMask(0)
end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M

