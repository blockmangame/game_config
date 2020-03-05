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
		count = packet.count or 1
	})
end