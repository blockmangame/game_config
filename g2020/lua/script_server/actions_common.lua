local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.SendInteractionEnd(data, params, context)
	params.player:sendPacket({
		pid = "SendInteractionEnd",
	})
end

function Actions.SendInteractionBegin(data, params, context)
	params.player:sendPacket({
		pid = "SendInteractionBegin",
		targetID = params.target.objID,
		skillName = params.skillName
	})
end

function Actions.CheckUseItemClear(data, params, context)
	local entity = params.entity
	entity:checkUseItemClear()
end

function Actions.UpdateEntityDateToClient(data, params, context)
	local entity = params.entity
    local key = params.key
	if not entity or not key then
		return
    end
    entity:sendPacket({
        pid = "UpdateEntityDate",
	    objId = entity.objID,
	    key = key,
        value = params.value
    })
end

function Actions.IsDrive(data, params, context)
	local entity = params.entity
	if entity and entity.rideOnId then
		local rideEntity = entity.world:getEntity(entity.rideOnId)
		local rideCfg = rideEntity and rideEntity:cfg()
		if rideCfg and rideCfg.carMove then
			return true
		end
		local rideItem = rideCfg and rideCfg.rideItem
		if rideItem then
			local item = Item.CreateItem(rideItem, 1)
			if item and item:cfg().typeIndex == 3 then
				return true
			end
		end
	end
	return false
end

function Actions.SetItemUse(data, params, context)
	local entity = params.entity
	local item = params.item
	if not item then
		return
	end 
	entity:setItemUse(item:tid(), item:slot(), params.isUse)
end

function Actions.IsItemUse(data, params, context)
	local entity = params.entity
	local list = entity:getUseItemList()
	local item = params.item
	local temp = list[item:tid()]
	if not temp then
		return false
	end
	return temp[item:slot()]
end

function Actions.ClearItemUseByKey(data, params, context)
	local entity = params.entity
	entity:clearItemUseByKey(params.key, params.valueArray)
end

function Actions.GetShopItemIndex(data, params, context)
	for _, item in pairs(Shop.shops) do
		if item.itemName == params.itemName then
			return item.index
		end
	end
end

function Actions.SetLoadSectionMaxInterval(data, params, context)
	params.entity:sendPacket({
		pid = "SetLoadSectionMaxInterval",
		value = params.value,
	})
end

function Actions.ShowShopItemDetail(data, params, context)
	local player = params.player
	local eventMap = {
		["sure"] = params.eventSure or params.event or false,
		["no"] = params.eventNo or false
	}
	local regId = player:regCallBack("ItemDetail", eventMap, true, true, params.context)
	player:sendPacket({
		pid = "ShopItemDetail",
		hintImage = params.hintImage,
		regId = regId,
		price = params.price,
		tip = params.tip,
		desc = params.desc,
		coinId = params.coinId or 0
	})
end

function Actions.WorksWallsOperation(data, params, context)
	params.player:sendPacket({pid = "WorksWallsOperation", isOpen = params.isOpen})
end

function Actions.SetWorksArchiveNum(data, params, context)
	params.player:sendPacket({ pid = "SetWorksArchiveNum", num = params.num })
end

local mfloor = math.floor
local mceil = math.ceil
local kCollision = 0.05
local kCollisionMargin = 0.01

local calcBoundingBoxTouchBlock
local function clacPushOutWithBlock(object, player)
    if not object or not object:isValid() then
        return
    end
    local entityPos = object:getPosition()
    local tempEntityPos = entityPos
    local lastSideNormal = object.lastSideNormal or {x = 0, y = 1, z = 0}
    -- first check, is touch block ?
    local cachePos, isCanMoveTo, touchBlockList = calcBoundingBoxTouchBlock(entityPos, object, lastSideNormal)
    if isCanMoveTo or #touchBlockList == 0 then
        return
    end
    local boundingBox = object:getBoundingBox()
    local boundBoxSize = Lib.v3cut(boundingBox[3], boundingBox[2])
    local curPlayerPos = player:getPosition()
    -- local playerRegion = object.map:getRegionValue(curPlayerPos) -- object.map:getRegionValue(entityPos)
    -- local region = not playerRegion and object.map:getRegionValue(entityPos) or playerRegion
    local map = object.map
    local function checkIsInRegion(region, pos)
        local min = region.min
        local max = region.max
        return min.x <= pos.x and max.x >= (pos.x - 1) and  min.y <= pos.y and max.y >= (pos.y - 1) and min.z <= pos.z and max.z >= (pos.z - 1) or false 
    end
    local function getRegion(map, pos)
        for _, re in pairs(map:getAllRegion()) do
            if re.cfg.isInsideRegion and checkIsInRegion(re, pos) then
                return re
            end
        end
    end
    local region = getRegion(map, entityPos) or getRegion(map, curPlayerPos)
    local vectorAxis = Lib.v3cut(region and Lib.getRegionCenter(region) or curPlayerPos, entityPos)
    -- vectorAxis = Lib.v3add(boundBoxSize, vectorAxis)
    local kSize = math.max(math.abs(vectorAxis.x / 0.01), math.abs(vectorAxis.y / 0.01), math.abs(vectorAxis.z / 0.01))
    local normalizeV3 = Lib.v3(
        vectorAxis.x / kSize,
        vectorAxis.y / kSize,
        vectorAxis.z / kSize
    )
    local isCanPushOut = false
    for i=0,kSize do
        tempEntityPos = Lib.v3add(tempEntityPos, normalizeV3)
        cachePos, isCanMoveTo, touchBlockList = calcBoundingBoxTouchBlock(tempEntityPos, object, lastSideNormal)
        if isCanMoveTo or #touchBlockList == 0 then
            isCanPushOut = true
            break
        end
    end
    if not isCanPushOut then
        return entityPos
    end
    local tempEntityPosXAxis = {x = entityPos.x, y = tempEntityPos.y, z = tempEntityPos.z}
    local tempEntityPosYAxis = {y = entityPos.y, x = tempEntityPos.x, z = tempEntityPos.z}
    local tempEntityPosZAxis = {z = entityPos.z, x = tempEntityPos.x, y = tempEntityPos.y}
    cachePos, isCanMoveTo, touchBlockList = calcBoundingBoxTouchBlock(tempEntityPosXAxis, object, lastSideNormal)
    if isCanMoveTo or #touchBlockList == 0 then
        tempEntityPos.x = entityPos.x
    end
    cachePos, isCanMoveTo, touchBlockList = calcBoundingBoxTouchBlock(tempEntityPosYAxis, object, lastSideNormal)
    if isCanMoveTo or #touchBlockList == 0 then
        tempEntityPos.y = entityPos.y
    end
    cachePos, isCanMoveTo, touchBlockList = calcBoundingBoxTouchBlock(tempEntityPosZAxis, object, lastSideNormal)
    if isCanMoveTo or #touchBlockList == 0 then
        tempEntityPos.z = entityPos.z
    end
    return tempEntityPos
end

calcBoundingBoxTouchBlock = function(worldPos, entity, sideNormal)
    local boundingBox = entity:getBoundingBox()
    local retTouchBlockPos = {}
    local boundBoxSize = Lib.v3cut(boundingBox[3], boundingBox[2])
    boundBoxSize = {x = boundBoxSize.x * boundingBox[1], y = boundBoxSize.y * boundingBox[1], z = boundBoxSize.z * boundingBox[1]}
    local sideNormalX,sideNormalY,sideNormalZ = sideNormal.x, sideNormal.y, sideNormal.z

    local comV3X = (sideNormalX == 0 and boundBoxSize.x or 0) / 2
    local comV3Y = (sideNormalY == 0 and boundBoxSize.y or 0) / 2
    local comV3Z = (sideNormalZ == 0 and boundBoxSize.z or 0) / 2

    local minPosX = mfloor(worldPos.x - comV3X + sideNormalX * kCollisionMargin)
    local minPosY = mfloor(worldPos.y - comV3Y + sideNormalY * kCollisionMargin)
    local minPosZ = mfloor(worldPos.z - comV3Z + sideNormalZ * kCollisionMargin)

    local maxPosX = mfloor(worldPos.x + comV3X + sideNormalX * kCollisionMargin)
    local maxPosY = mfloor(worldPos.y + comV3Y + sideNormalY * kCollisionMargin)
    local maxPosZ = mfloor(worldPos.z + comV3Z + sideNormalZ * kCollisionMargin)

    local editExcludeBlock = entity:cfg().editExcludeBlock or {}
    local map = entity.map
    for i = minPosX, maxPosX do
        for j = minPosY, maxPosY do
            for k = minPosZ, maxPosZ do
                local pos = {
                    x = i + sideNormalX * kCollisionMargin,
                    y = j + sideNormalY * kCollisionMargin,
                    z = k + sideNormalZ * kCollisionMargin
                }
                local blockPos = Lib.tov3(pos):blockPos()
                local block = map:getBlock(blockPos)

                if block.fullName ~= "/air" then
                    for key, value in pairs(editExcludeBlock) do
                        if block[key] == value then
                            goto CONTINUE
                        end
                    end
                    retTouchBlockPos[#retTouchBlockPos + 1] = blockPos
                    -- return entity:getPosition(), false
                end
                ::CONTINUE::
            end
        end
    end
    if #retTouchBlockPos ~= 0 then
        return entity:getPosition(), false, retTouchBlockPos
    end
    return worldPos, true, {}
end

function Actions.ClacEntityPushOutBlock(data, params, context)
	params.entity:setPosition(clacPushOutWithBlock(params.entity, params.player) or params.entity:getPosition())
end

function Actions.DeleteItem(data, params, context)
	local player = params.player
	local item = params.item
	if not player or not item or item:null() then
		return false
	end
	local my_tray = player:data("tray")
    local bag = my_tray:fetch_tray(item:tid())
    local item = bag:remove_item(item:slot())
	return true
end

function Actions.ShowWarmPrompt(data, params, context)
    local player = params.player
    if not player then
        return
    end
    local regId = player:regCallBack("ShowWarmPrompt", {["sure"] = params.sureEvent or false, ["no"] = params.noEvent or false}, true, true, params.context)
    player:sendPacket({
        pid = "ShowWarmPrompt",
        regId = regId,
        text = params.text,
        btnText = params.btnText,
        disableClose = params.disableClose
    })
end

function Actions.UpdateEntityEditContainer2(data, params, context)
    local player = params.player
    local entityId = params.entityId
    if not entityId or not player then
        return
    end
    player:sendPacket({
        pid = "UpdateEntityEditContainer2",
        objID = entityId,
        show = params.show
    })
end

function Actions.ClearPassengers(data, params, context)
    for idx, objID in pairs(params.entity:data("passengers")) do
        local entity = params.entity.world:getEntity(objID)
        if entity then
            entity:clearRide()
        end
    end
end

function Actions.GetMapID(data, params, context)
    return params.map.id
end

function Actions.RenderBlock(data, params, context)
    params.player:sendPacket({
        pid = "RenderBlock",
        mapID = params.mapID,
        childRegionKey = params.childRegionKey,
        childRegionArr = params.childRegionArr,
        destBlock = params.destBlock
    })
end

function Actions.ToggleBloom(data, params, context)
    local player = params.player
    if not player then
        return
    end
    player:sendPacket({
        pid = "ToggleBloom",
        bloomOpen = params.bloomOpen
    })
end

function Actions.SetBlockEmissionColorStrength(data, params, context)
    local player = params.player
    if not player then
        return
    end
    player:sendPacket({
        pid = "SetBlockEmissionColorStrength",
        strength = params.strength
    })
end

function Actions.GetWorldTime(data, params, context)
    return World.CurWorld:getWorldTime()
end

function Actions.SyncWorldTime(data, params, context)
    local worldTime = World.CurWorld:getWorldTime()
    params.player:sendPacket({
        pid = "SyncWorldTime",
        worldTime = worldTime
    })
end

function Actions.IsClimbing(data, params, context)
    local pos = Lib.tov3(params.entity:isClimbing())
    return not pos:isZero()
end

function Actions.CheckCanBuyLotteryNum(data, params, context)
    local lotteryInfo = params.player.vars.lottery
    local yearDay = Lib.getYearDayStr(os.time())
    local limitNum = World.cfg.limitBuyLotteryNum or 30
    return lotteryInfo.day ~= yearDay or lotteryInfo.num < limitNum
end

function Actions.AddBuyLotteryNum(data, params, context)
    local lotteryInfo = params.player.vars.lottery
    local yearDay = Lib.getYearDayStr(os.time())
    if lotteryInfo.day ~= yearDay then
        lotteryInfo.day = yearDay
        lotteryInfo.num = 1
    else
        lotteryInfo.num = lotteryInfo.num + 1
    end
end