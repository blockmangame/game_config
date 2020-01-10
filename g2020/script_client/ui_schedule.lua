local setting = require "common.setting"

local function rangeShowUIOnVPos(pos, ui, minDis, maxDis)
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

Lib.subscribeEvent(Event.EVENT_SHOW_HOME_GUIDE, function(packet)
    local item = UIMgr:new_widget("button", "widget_button")
    local cfg = setting:fetch("customizable_ui", "myplugin/homeView") or {}
    item:invoke("imageSize",cfg.imageSize)
    item:invoke("enable", false)
    item:invoke("text", cfg.text or "")
    item:invoke("image", cfg.image)
    local container = GUIWindowManager.instance:LoadWindowFromJSON("InteractionLayout.json")
    container:AddChildWindow(item)
    local ui = UI:getWnd("interactionContainer")
    ui._root:AddChildWindow(container)
    local pos = packet.pos or { x = 0, y = 0, z = 0}
    pos.y = pos.y + 1
    rangeShowUIOnVPos(pos, container, 0, 1000)
end)