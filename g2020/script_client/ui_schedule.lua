--先废弃/

local setting = require "common.setting"

Lib.subscribeEvent(Event.EVENT_SHOW_HOME_GUIDE, function(pos)
	local cfg = setting:fetch("customizable_ui", "myplugin/homeView") or {}
	if lastShowTimer then
		lastShowTimer()
		lastShowTimer = nil
	end
	if not container then
		local item = UIMgr:new_widget("button", "widget_button")
		item:invoke("imageSize",cfg.imageSize)
		item:invoke("enable", false)
		item:invoke("text", cfg.text or "")
		item:invoke("image", cfg.image)
		container = GUIWindowManager.instance:LoadWindowFromJSON("InteractionLayout.json")
		container:AddChildWindow(item)
		local ui = UI:getWnd("interactionContainer")
		ui._root:AddChildWindow(container)
	end
	pos = pos or { x = 0, y = 0, z = 0}
	pos.y = pos.y + 1
    lastShowTimer = rangeShowUIOnVPos(pos, container, cfg.minDis, cfg.maxDis)
end)