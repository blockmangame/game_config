local setting = require "common.setting"
local pluginCfg = setting:fetch("ui_config", "myplugin/homeView") or {}
local uicfg = pluginCfg["settingCfg"]

function M:init()
    WinBase.init(self, "directionUI.json", true)
    self.mapDoor = {}
    self.mapDoorTimer = {}
    self:initMapUI()
end

function M:getItem(cfg)
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
	local container = GUIWindowManager.instance:LoadWindowFromJSON("directionItem.json")
	container:AddChildWindow(item)
	self:root():AddChildWindow(container)
	return container
end

function M:rangeShowUIOnVPos(pos, ui, minDis, maxDis, uiSize)
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
    local stopFollowFunc = World.Timer(0, function()
        UILib.showUIOnVector3Pos(ui, {
            x = pos.x,
            y = pos.y,
            z = pos.z
        }, {
            uiSize = {width = {0, uiSize.width}, height = {0, uiSize.height}}, 
            autoScale = false,
            anchorX = 0.5,
            anchorY = 0.5
        })
        return true
    end)
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

function M:initMapUI()
    for name, cfg in pairs(uicfg) do
		if name ~= "home" and not self.mapDoor[name] then
			local ui = self:getItem(cfg)
			self.mapDoor[name] = ui
			self.mapDoorTimer[name] = self:rangeShowUIOnVPos(cfg.pos, ui, cfg.minDis, cfg.maxDis, cfg.imageSize)
		end
	end
end

function M:updateHomeUI(pos)
    if self.homeTimer then
		self.homeTimer()
		self.homeTimer = nil
	end
	if self.homeDoor then
        self.homeDoor:SetVisible(false)
        self.homeDoor = nil
    end
    if not pos then
        return
    end
    self.homeDoor = self:getItem(uicfg["home"])
	pos = pos or { x = 0, y = 0, z = 0}
	pos.y = pos.y + 1
	local cfg = uicfg["home"]
	self.homeTimer = self:rangeShowUIOnVPos(pos, self.homeDoor, cfg.minDis, cfg.maxDis, cfg.imageSize)
end

return M