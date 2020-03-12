local setting = require "common.setting"

local GuideHome = {}
local self = GuideHome

GuideHome.mapDoor = {}
GuideHome.mapDoorTimer = {}
GuideHome.homeDoor = nil
GuideHome.homeTimer = nil
local pluginCfg = setting:fetch("ui_config", "myplugin/homeView") or {}
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
function GuideHome.MakeMapDoor()
	for name, cfg in pairs(uicfg) do
		if name ~= "home" and not self.mapDoor[name] then
			local ui = getItem(cfg)
			self.mapDoor[name] = ui
			self.mapDoorTimer[name] = rangeShowUIOnVPos(cfg.pos, ui, cfg.minDis, cfg.maxDis)
		end
	end
end

--homedoor
function GuideHome.showHomeUI(pos)
	if self.homeTimer then
		self.homeTimer()
		self.homeTimer = nil
	end
	if not self.homeDoor then
		self.homeDoor = getItem(uicfg["home"])
	else
		self.homeDoor:SetVisible(false)
	end
	pos = pos or { x = 0, y = 0, z = 0}
	pos.y = pos.y + 1
	local cfg = uicfg["home"]
	self.homeTimer = rangeShowUIOnVPos(pos, self.homeDoor, cfg.minDis, cfg.maxDis)
end

function GuideHome.resetDoor(pos)
	if self.homeTimer then
		self.homeTimer()
		self.homeTimer = nil
	end
	if self.homeDoor then
		self.homeDoor:SetVisible(false)
		self.homeDoor = nil
	end
	for _, ui in pairs(self.mapDoor) do
		ui:SetVisible(false)
	end
	for _, timer in pairs(self.mapDoorTimer) do
		timer()
	end
	self.mapDoor = {}
	self.mapDoorTimer = {}
	if pos then
		self.MakeMapDoor()
		self.showHomeUI(pos)
	end
end

return GuideHome