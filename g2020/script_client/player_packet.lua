local setting = require "common.setting"
local handles = Player.PackageHandlers

function handles:ShowHomeGuide(packet)
    
	Lib.emitEvent(Event.EVENT_SHOW_HOME_GUIDE, packet)
end