local EQUIP_TRAY_TYPE = {
    Define.TRAY_TYPE.EXTEND_BAG_1, 
    Define.TRAY_TYPE.EXTEND_BAG_2, 
    Define.TRAY_TYPE.EXTEND_BAG_3, 
    Define.TRAY_TYPE.EXTEND_BAG_4, 
    Define.TRAY_TYPE.EXTEND_BAG_5, 
}

local function unifyProc(self, btn, proc)
    self:subscribe(btn, UIEvent.EventButtonClick, function()
        self:unsubscribe(btn)
        World.Timer(20, function()
            if btn then
                unifyProc(self, btn, proc)
            end
        end)
        if proc then
            proc()
        end
    end)
end

local function interactionWithDriverButton(targetObjID, interactionType, interactionName)
    local packet = {
        pid = "InteractionWithMovementEvent",
        objID = Me.objID,
        params = {
            interactionType = interactionType,
            interactionName = interactionName,
            targetObjId = targetObjID
        }
	}
	Me:sendPacket(packet)
end

function M:init()
    WinBase.init(self, "g2020_main_tray.json")
    self:initUIName()
    self:refreshUI()
    Lib.subscribeEvent(Event.EVENT_HAND_ITEM_CHANGE, function()
        self:refreshUI()
    end)
	Lib.subscribeEvent(Event.EVENT_RIDE, function(entity, mount)
        self:refreshUI()
	end)

    unifyProc(self, self.bagBtn, function()
        World.Timer(10, function()
            UI:openWnd("bag_g2020")
        end)
    end)

    local useItem = function()
        World.Timer(5, function()
            local item = self.equipItem
            if not item or item:null() then
                return
            end
            if not item:can_use() then
                Client.ShowTip(2, Lang:toText(item:cfg().cantUseTip or "gui.cantUseTip"), 40)
                return
            end
            local fastUse = item:cfg().fastUse
            if fastUse then
                Skill.Cast("/useitem", { slot = item:slot(), tid = item:tid()})
                return
            end
            local packet = {
                pid = "UseItemEquipSkill",
                slot = item:slot(),
                tid = item:tid(),
            }
            Me:sendPacket(packet)
        end)
    end
    unifyProc(self, self.handItemUI, useItem)
	if World.cfg.clickScreenUse then
		Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function()
			if self.clickUse then
				return
			end
			self.clickUse = World.Timer(5, useItem)
		end)
		Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_MOVE, function()
			if self.clickUse then
				self.clickUse()
				self.clickUse = nil
			end
		end)
	end
    
    unifyProc(self, self.handItemClosBtn, function()
        World.Timer(10, function()
            local item = self.equipItem
            if not item or item:null() then
                return
            end
			if item:cfg().typeIndex == 3 then
				interactionWithDriverButton(Me.objID, UIEvent.EventWindowTouchUp, "debark")
				return
			end
            if not item or item:null() then
                return
            end
			Me:setItemUse(item:tid(), item:slot(), false)
        end)
    end)
end

function M:getEquipItem()
    local trayArray = Me:tray():query_trays(EQUIP_TRAY_TYPE)
    for _, element in pairs(trayArray) do
        local tray = element.tray
        local items = tray and tray:query_items(function(item)
			return true
        end)
		local result = {}
		for _, item in pairs(items or {}) do
			if Me:isItemUse(item) then
				result[#result + 1] = item
			end
		end
        for _, item in pairs(result) do
			if item:cfg().typeIndex == 3 then
				local rideEntity = Me.rideOnId and Me.world:getEntity(Me.rideOnId)
				if rideEntity and item:cfg().carName == rideEntity:cfg().fullName then
					return item
				end
			else
				return item
			end
        end
    end
end

function M:getRideItem()
	local rideEntity = Me.rideOnId and Me.world:getEntity(Me.rideOnId)
	if rideEntity then
		local rideItem = rideEntity:cfg().rideItem
		if rideItem then
			return Item.CreateItem(rideItem, 1)
		end
	end
	return nil
end

function M:refreshUI()
	local equipItem = self:getEquipItem()
	if not equipItem then
		equipItem = self:getRideItem()
	end
	self.equipItem = equipItem
    if equipItem then
        self.bagBtn:SetArea({-0.6, 0}, {0, 0}, {0, 80}, {0, 80})
        self.handItemUI:SetVisible(true)
        self.handItemUI:SetHorizontalAlignment(0)
        self.handItemUI:SetArea({0, 0}, {0, 0}, {0,110}, {0, 110})
        self.handItemIcon:SetImage(equipItem:icon())
        self.handItemName:SetText(Lang:toText(equipItem:cfg().itemname))
    else
        self.bagBtn:SetArea({0, 0}, {0, 0}, {0, 110}, {0, 110})
        self.handItemUI:SetVisible(false)
    end
end

function M:initUIName()
    self.bagName = self:child("g2020-main-bag-name")
    self.bagBtn = self:child("g2020-main-bag")
    self.handItemUI = self:child("g2020-main-hand-item")
    self.handItemIcon = self:child("g2020-main-hand-item-icon")
    self.handItemName = self:child("g2020-main-hand-item-name")
    self.handItemClosBtn = self:child("g2020-main-hand-item-close")
	self.bagName:SetText(Lang:toText("mian_ui_bag"))
end


return M