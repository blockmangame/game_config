local setting = require "common.setting"

local GuideHome = {}

local mapDoor = {}
local mapDoorTimer = {}
local homeDoor = nil
local lastShowTimer = nil
local pluginCfg = setting:fetch("customizable_ui", "myplugin/homeView") or {}
local uicfg = pluginCfg["settingCfg"]

local function getItem(cfg)
	local item = UIMgr:new_widget("button", "widget_button")
	item:invoke("imageSize",cfg.imageSize)
	item:invoke("enable", false)
	item:invoke("text", cfg.text or "")
	item:invoke("image", cfg.image)
	item:invoke("textFontSize", cfg.textFontSize or "HT16")
	item:invoke("enableTextBorder", true)
	local buttonImage = item:invoke("child", "widget_button-image")
	if buttonImage then
		buttonImage:SetEnabled(false)
	end
	local button = item:invoke("root")
	if button then
		button:SetEnabled(false)
	end
	local backImage = item:invoke("child", "widget_button-background")
	if backImage then
		backImage:SetEnabled(false)
	end
	local container = GUIWindowManager.instance:LoadWindowFromJSON("InteractionLayout.json")
	container:AddChildWindow(item)
	local ui = UI:getWnd("interactionContainer")
	ui._root:AddChildWindow(container)
	return container
end

local function rangeShowUIOnVPos(pos, ui, minDis, maxDis)
	if not ui then
		return
	end
    if not minDis then
      minDis = 0
    end
    if not maxDis then
      maxDis = math.huge - 1
    end
    local map = pos.map
    local stopFollowFunc = UILib.uiFollowPos(ui, {
      x = pos.x,
      y = pos.y,
      z = pos.z
    }, {
      autoScale = false,
      anchorX = 0.5,
      anchorY = 0.5
    })
    local resultTimer = World.Timer(5, function()
        local visible = true
        if Me.map.name ~= map then
          visible = false
        else
          local p1 = pos
          local p2 = Me:getPosition()
          local dis = Lib.getPosDistanceSqr(p1, p2)
          if minDis < dis and dis < maxDis then
            visible = true
          else
            visible = false
          end
        end
        ui:SetVisible(visible)
        return true
    end)
    return function()
		resultTimer()
		stopFollowFunc()
    end
end

--mapdoor
do
	for name, cfg in pairs(uicfg) do
		if name == "home" or mapDoor[name] then
			goto continue
		end
		local ui = getItem(cfg)
		mapDoor[name] = ui
		mapDoorTimer[name] = rangeShowUIOnVPos(cfg.pos, ui, cfg.minDis, cfg.maxDis)
		:: continue :: 
	end
end

--homedoor
if not homeDoor then
	homeDoor = getItem(uicfg["home"])
end

function GuideHome.showHomeUI(pos)
	if lastShowTimer then
		lastShowTimer()
		lastShowTimer = nil
	end
	pos = pos or { x = 0, y = 0, z = 0}
	pos.y = pos.y + 1
	local cfg = uicfg["home"]
	lastShowTimer = rangeShowUIOnVPos(pos, homeDoor, cfg.minDis, cfg.maxDis)
end

return GuideHome