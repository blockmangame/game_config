local setting = require "common.setting"
local handles = Player.PackageHandlers

local GuideHome = require "script_client.guideHome"

function handles:RefreshNumberBoardText(packet)
	local wnd = UI._windows[packet.wndKey]
	if not wnd then
		return
	end
	wnd:updateText(packet.text)
end

function handles:RefreshBlackBoardText(packet)
	local wnd = UI._windows[packet.wndKey]
	if not wnd then
		return
	end
	wnd:updateText(packet.text)
end

function handles:ShowHomeGuide(packet)
	GuideHome.showHomeUI(packet.pos)
end

function handles:UpdateEntityDate(packet)
    local obj = World.CurWorld:getObject(packet.objId)
    if obj then
        obj[packet.key] = packet.value
    end
end

function handles:SyncItemUse(packet)
	self:setItemUse(packet.tid, packet.slot, packet.isUse, true)

end