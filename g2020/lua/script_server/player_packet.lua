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

function handles:InteractWithEntity(packet)
	local entity = World.CurWorld:getEntity(packet.objID)
	if not entity then
		return
	end

	local checkContext = {obj1 = self, canInteract = true,}
	Trigger.CheckTriggers(self:cfg(), "CHECK_CAN_INTERACT", checkContext)
	if not checkContext.canInteract then
		return
	end

	local context = {
		obj1 = entity,
		obj2 = self,
	}
	local cfgKey, cfgIndex, btnType, btnIndex = packet.cfgKey, packet.cfgIndex, packet.btnType, packet.btnIndex
	local cfg = entity:cfg()[cfgKey]
	if cfgIndex then
		cfg = cfg[cfgIndex]
	end
	local btnCfg = cfg[btnType][btnIndex]
	if btnCfg.toOther then
		local target = packet.targetID and World.CurWorld:getEntity(packet.targetID)
		if not target then
			return
		end
		context.obj2 = target
	end
	Trigger.CheckTriggers(entity:cfg(), btnCfg.event, context)
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

function handles:CommentWorks(packet)
	local context = {
		obj1 = self,
		id = packet.id,
		msg = packet.msg
	}

	Trigger.CheckTriggers(self:cfg(), "COMMENT_WORKS", context)
end