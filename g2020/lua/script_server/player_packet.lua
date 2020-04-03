local setting = require "common.setting"
local handles = Player.PackageHandlers

function handles:UseItemEquipSkill(packet)
	local item = Item.CreateSlotItem(self, packet.tid, packet.slot)
	Trigger.CheckTriggers(item:cfg(), "USE_ITEM", {obj1 = self, itemName = item:cfg().fullName, sloter = item})
end

function handles:SetItemUse(packet)
    local tid = packet.tid
	local slot = packet.slot
	local isUse = packet.isUse
	self:setItemUse(tid, slot, isUse)
end

function handles:RideOnFurnitureByIndex(packet)
	local entity = World.CurWorld:getEntity(packet.objID)
	if not entity then
		return
	end
	local target = World.CurWorld:getEntity(packet.targetID)
	if not target then
		return
	end
	local checkContext = {
		obj1 = target,
		canInteract = true,
		interactTarget = entity,
	}
	Trigger.CheckTriggers(target:cfg(), "CHECK_CAN_INTERACT", checkContext)
	if not checkContext.canInteract then
		return
	end
	local context = {
		obj1 = entity,
		obj2 = target,
		ridePosIndex = packet.ridePosIndex,
	}
	Trigger.CheckTriggers(entity:cfg(), "RIDE_ON_FURNITURE_BY_INDEX", context)
end

function handles:showChangeTeamName(packet)
    local name = packet.name

    Trigger.CheckTriggers(self:cfg(), "SHOW_EDIT_FAMILY_NAME_UI", {obj1 = self, name = name})
end

function handles:GiveAwayToTarget(packet)
    local objID = packet.objID
	local object = World.CurWorld:getObject(objID)
    Trigger.CheckTriggers(object and object:cfg(), "GIVE_AWAY", {
		obj1 = object, 
		obj2 = self, 
		cfg = packet.cfg, 
		count = packet.count or 1, 
		targetBagNotFree = packet.targetBagNotFree
	})
end

function handles:CheckTargetTrayIsFull(packet)
    local objID = packet.objID
	local object = World.CurWorld:getObject(objID)
	local ret = object:tray():query_trays(packet.tid)
	for _, element in pairs(ret) do
		local _tray = element.tray
		if _tray:find_free() then
			return true
		end
	end
    return false
end

function handles:CommentWorks(packet)
	local context = {
		obj1 = self,
		id = packet.id,
		msg = packet.msg
	}

	Trigger.CheckTriggers(self:cfg(), "COMMENT_WORKS", context)
end

function handles:ToggleMainUI(packet)
	Trigger.CheckTriggers(self:cfg(), "TOGGLE_MAIN_UI", {obj1 = self, show = packet.show})
end

function handles:CloseDress(packet)
	local context = {
		obj1 = self
	}
	Trigger.CheckTriggers(self:cfg(), "CLOSE_DRESS", context)
end

function handles:CloseNewSignIn(packet)
	local context = {
		obj1 = self
	}
	Trigger.CheckTriggers(self:cfg(), "CLOSE_SIGN_IN", context)
end

function handles:UpdateGuideRedPoint(packet)
	Trigger.CheckTriggers(self:cfg(), "GUIDE_RED_POINT", {obj1 = self, hideParty = packet.hideParty, hideWork = packet.hideWork})
end

function handles:GMGuide(packet)
	Trigger.CheckTriggers(nil, "GM_CLOSE_GUIDE", {obj1 = self, reset = packet.reset, close = packet.close})
end

function handles:Dismount(packet)
    self:rideOn()
end

function handles:ModSkin(packet)
	self:changeSkin(packet.skin)
end