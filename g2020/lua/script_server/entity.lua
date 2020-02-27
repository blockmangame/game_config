local setting = require "common.setting"

function EntityServer:getUseItemList()
    return self:data("main").useItemList
end

function EntityServer:checkUseItemClear()
    local useItemList = self:getUseItemList() or {}
    for tid, tidUseItemList in pairs(useItemList) do
        for slot, useItem in pairs(tidUseItemList) do
            if useItem:null() then
                self:setItemUse(tid, slot, false)
            end
        end
    end
end

function EntityServer:syncItemUse(tid, slot, isUse)
    local packet = {
		pid = "SyncItemUse",
        tid = tid,
        slot = slot,
        isUse = isUse
    }
    self:sendPacket(packet)
end

function EntityServer:clearItemUseByKey(key, valueArray)
    local cmpFunc = function(useItem, key, valueArray)
        if useItem:null() then
            return true
        end
        for _, value in pairs(valueArray) do
            if useItem:cfg()[key] == value then
                return true
            end
        end
        return false
    end
    local useItemList = self:getUseItemList() or {}
    for tid, tidUseItemList in pairs(useItemList) do
        for slot, useItem in pairs(tidUseItemList) do
            if cmpFunc(useItem, key, valueArray) then
                self:setItemUse(tid, slot, false)
            end 
        end
    end
end

function EntityServer:setItemUse(tid, slot, isUse)
    if not tid or not slot then
        return
    end
    local useItemList = self:data("main").useItemList
    if not useItemList then
        useItemList = {}
        self:data("main").useItemList = useItemList
	end
    local tidUseItemList = useItemList[tid]
    local useFlag = tidUseItemList and tidUseItemList[slot] and true or false
    isUse = isUse and true or false
    if useFlag == isUse then
        return 
	end
	
    local item = Item.CreateSlotItem(self, tid, slot)
    useItemList[tid] = useItemList[tid] or {}
    local lastItem = useItemList[tid][slot] or item 
    local checkContext = {
        obj1 = self,
        item = lastItem,
        result = true
    }
    if isUse then
        Trigger.CheckTriggers(self:cfg(), "CHECK_CAN_USE_ITEM", checkContext)
        if not checkContext.result then
            return
        end
    end
    if lastItem and not lastItem:null() then
    	Trigger.CheckTriggers(self:cfg(), "SET_ITEM_USE", {obj1 = self,isUse = isUse , item = lastItem})
    end
	useItemList[tid][slot] = isUse and item or nil
	self:removeTypeBuff("type", "HandBuff")
	if isUse and item and not item:null() then
		local buffName = item:cfg().equip_buff
		if buffName then
            self:addBuff(buffName)
            
		end
    end
    self:syncItemUse(tid, slot, isUse)
end