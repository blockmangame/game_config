local setting = require "common.setting"

function Player:setItemUse(tid, slot, isUse, disSendSer)
	local function updateHandItem(self, tid, slot)
		local handItem = self:data("main").handItem
		if not handItem or handItem:null() then
			self:data("main").handItem = nil
		end 
        local item = Item.CreateSlotItem(self, tid, slot)
        if item and not item:null() then
			local buffName = item:cfg().equip_buff
			if isUse and buffName then
				self:data("main").handItem = item
            elseif not isUse then
                local handItem =  self:data("main").handItem
                if handItem and not handItem:null() and handItem:cfg().fullName == item:cfg().fullName then
                    self:data("main").handItem = nil
                end
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

local customCheckFuncs = {}


customCheckFuncs.checkCanShowInviteFamily = function (entity, checkCond, targetObjID)
    -- 邀请
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if entity == target then
        return false
    end

    local id1 = entity:getValue("teamId")
    local id2 = target:getValue("teamId")

    if id1 == 0 then
        return id2 == 0
    else
        return id1 ~= id2
    end
end

customCheckFuncs.checkCanShowApplyFamily = function (entity, checkCond, targetObjID)
    -- 申请
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if entity == target then
        return false
    end

    local id1 = entity:getValue("teamId")
    local id2 = target:getValue("teamId")

    if id2 == 0 then
        return false
    else
        return id1 ~= id2
    end
end

local function isAdult(entity)
    local scale = entity:data("actorScale")
    return scale.x == 1 and scale.y == 1 and scale.z == 1
end


local function isSameTeamID(entity1, entity2)
    local id1 = entity1:getValue("teamId")
    local id2 = entity2:getValue("teamId")
    return id1 == id2
end

customCheckFuncs.checkCanAdultPickBaby = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if not isSameTeamID(entity, target) then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return role1 and (not role2) and entity:prop("onTrolley") ~= 1
end

customCheckFuncs.checkCanAdultCarryBaby = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if not isSameTeamID(entity, target) then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return role2 and (not role1) and target:prop("onTrolley") ~= 1
end

customCheckFuncs.checkCanAdultPutBabyIntoTrolley = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if not isSameTeamID(entity, target) then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return role1 and (not role2) and entity:prop("onTrolley") == 1
end

customCheckFuncs.checkCanSitInTrolley = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if not isSameTeamID(entity, target) then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return role2 and (not role1) and target:prop("onTrolley") == 1
end

customCheckFuncs.checkCanBabyHandInHand = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    if not isSameTeamID(entity, target) then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return (not role1) and (not role2)
end

customCheckFuncs.checkCanHideInteract = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return true
    end
    if not isSameTeamID(entity, target) then
        return true
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return role2 and (not role1) and target:prop("onTrolley") == 1
end

customCheckFuncs.checkCanClap = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return (not role2) and (not role1)
end

customCheckFuncs.checkCanTouchHead = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return (not role2) and role1
end

customCheckFuncs.checkCanShakeHand = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return role2 and role1
end

customCheckFuncs.checkCanHideHug = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return true
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return (not role2) and role1
end

customCheckFuncs.checkCanBabyRideAdult = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return (not role1) and role2
end

customCheckFuncs.checkCanAdultRaiseBaby = function (entity, checkCond, targetObjID)
    local target = World.CurWorld:getObject(targetObjID)
    if not target then
        return false
    end
    local role1, role2 = isAdult(entity), isAdult(target)
    return (not role2) and role1
end

function Player:customCheckCond(checkCond, ...)
    local func = customCheckFuncs[checkCond.funcName]
    if not func then
        print("not definded custom check function! ", checkCond.funcName)
        return false
    end
    return func(self, checkCond, ...)
end

local skillList = {
    ["myplugin/action_piggyback"] = true,
    ["myplugin/action_handinhand"] = true,
    ["myplugin/action_ride"] = true,
    ["myplugin/action_pickup"] = true,
}

function Player:setInteractingPlayer(targetID, skillName)
    if not targetID then
        self.interactingPlayer = nil
        return
    end
    if skillList[skillName] then
        self.interactingPlayer = targetID
    end
end

function Player:updateGiveAwayStatus(status, targetObjID)
    self.giveAwayStatusTable = {
        status = status,
        targetObjID = targetObjID
    }
end

function Player:commentWorks(id, msg)
    self:sendPacket({pid = "CommentWorks", id = id, msg = msg})
end

function Player:setWorksArchiveNum(num)
    self:data("main").worksArchiveNum = num
end

function Player:getWorksArchiveNum()
    return self:data("main").worksArchiveNum or 3
end