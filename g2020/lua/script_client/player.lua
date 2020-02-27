local setting = require "common.setting"

function Player:setItemUse(tid, slot, isUse, disSendSer)
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
            Lib.emitEvent(Event.EVENT_HAND_ITEM_CHANGE)
        end
        return 
    end
    useItemList[tid] = useItemList[tid] or {}
    useItemList[tid][slot] = isUse

    if disSendSer then
        Lib.emitEvent(Event.EVENT_HAND_ITEM_CHANGE)
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