local setting = require "common.setting"

function Player:setItemUse(tid, slot, isUse, disSendSer)
	local function updateHandItem(self, tid, slot)
		local handItem = self:data("main").handItem
		if not handItem or handItem:null() then
			self:data("main").handItem = nil
		end 
		local item = Item.CreateSlotItem(self, tid, slot)
		if isUse and item and not item:null() then
			local buffName = item:cfg().equip_buff
			if buffName then
				self:data("main").handItem = item
			end
		end
		Lib.emitEvent(Event.EVENT_HAND_ITEM_CHANGE)
	end

    if not tid or not slot then
        return
    end
    local useItemList = self:data("main").useItemList
    if not useItemList then
        useItemList = {}
        self:data("main").useItemList = useItemList
    end
	local tidUseItemList = useItemList[tid]
    if tidUseItemList and tidUseItemList[slot] == isUse then
		if disSendSer then
			updateHandItem(self, tid, slot)
        end
        return 
    end
    useItemList[tid] = useItemList[tid] or {}
    useItemList[tid][slot] = isUse
	if disSendSer then
		updateHandItem(self, tid, slot)
        return
    end
    local packet = {
		pid = "SetItemUse",
		tid = tid,
        slot = slot,
        isUse = isUse
	}
    self:sendPacket(packet)
end

function Player:isItemUse(item)
    local useItemList = self:data("main").useItemList
    if not useItemList then
        return false
    end
    if not item or item:null() then
        return false
    end
    local tid = item:tid()
    local slot = item:slot()
    local tidUseItemList = useItemList[tid]
    if not tidUseItemList then
        return false
    end
    if not tidUseItemList[slot] then
        return false
    end
    return true
end