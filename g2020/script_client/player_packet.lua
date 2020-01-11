local setting = require "common.setting"
local handles = Player.PackageHandlers

local GuideHome = require "script_client.guideHome"

function handles:ShowHomeGuide(packet)
	GuideHome.showHomeUI(packet.pos)
end