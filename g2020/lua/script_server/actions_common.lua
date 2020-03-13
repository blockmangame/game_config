local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.ShowHomeGuide(data, params, context)
    local entity = params.entity
    local pos
    if entity then
        pos = entity:getPosition()
        pos.map = entity.map.name
    end
	local player = params.player
	player:sendPacket({
		pid = "ShowHomeGuide",
		pos = pos
	})
end

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
		local old = entity.world:getEntity(entity.rideOnId)
		if old and old:cfg().carMove then
			return true
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

function Actions.ShowSingleTeamUI(data, params, context)
    local entity = params.entity
    if not entity then
        return
    end

    entity:sendPacket({
        pid = "ShowSingleTeamUI",
        info = params.info,
        show = params.show
    })

end

function Actions.ShowTeamUI(data, params, context)
    params.entity:sendPacket({
        pid = "ShowTeamUI",
        show = params.show == nil and true or params.show,
        info = params.info
    })
end

function Actions.ShowProgressFollowObj(data, params, context)
    local player = params.entity
    if not player then
        return
    end
    player:sendPacket({
        pid = "ShowProgressFollowObj",
        isOpen = params.isOpen,
        pgImg = params.pgImg,
        pgBackImg = params.pgBackImg,
        pgName = params.pgName,
        usedTime = params.usedTime,
        totalTime = params.totalTime,
        pgText = params.pgText,
    })
end

local _getStateReleaseData = function(player, state, stateBase)
    if not player or not player:isValid() or not player.isPlayer then
        return nil
    end
    local objVar = player.vars or {}
    if not objVar[state.."got"] then
        return nil
    end
    local isReleasing = objVar["releasing"..state] or false
    local sTime = objVar[state.."STime"]
    local usedTime = objVar[state.."UsedTime"] or 0
    if sTime and usedTime >= 0 then
        usedTime = os.time() - sTime + usedTime
    end
    return usedTime, isReleasing
end
function Actions.ShowDetails(data, params, content)
    local player = params.player
    if not player or not player:isValid() or not player.isPlayer then
        return
    end
    local _getObjVar = function(obj, key)
        return obj and key and obj.vars[key]
    end
    local _getSkillVar = function(skillName, key)
        local skill = Skill.Cfg(skillName)
        return (skill and {skill[key]} or {nil})[1]
    end
    local detailsUI = _getObjVar(player, "detailsUI")
    local state = params.state or detailsUI
    if not state or detailsUI ~= state then
        return
    end
    local skillName = "myplugin/skill_state_"..state
    local duration = _getSkillVar(skillName, "duration") or 0
    local packet = {
        pid = "ShowDetails",
        isOpen = false
    }
    local subtitle = {}
    for _, v in ipairs({player, params.partner}) do
        local usedTime, isReleasing = _getStateReleaseData(v, state)
        if usedTime ~= nil then
            packet.isOpen = true
            subtitle[v.objID] = { usedTime = usedTime*20, duration = duration*20, isReleasing = isReleasing }
        end
        ::next::
    end
    if packet.isOpen then
        packet.fullName = "myplugin/"..state.."Detail"
        packet.contents = {
            subtitle = subtitle,
            commentsVal = _getSkillVar(skillName, "rewardSelf"),
            commentsCurrencyIcon = _getSkillVar(skillName, "rewardType")
        }
    end
    player:sendPacket(packet)
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

function Actions.UpdateUIData(data, params, content)
	params.player:sendPacket({pid = "UpdateUIData", ui = params.ui, data = params.data})
end

function Actions.WorksWallsOperation(data, params, context)
	params.player:sendPacket({pid = "WorksWallsOperation", isOpen = params.isOpen})
end

function Actions.SetWorksArchiveNum(data, params, context)
	params.player:sendPacket({ pid = "SetWorksArchiveNum", num = params.num })
end

function Actions.ShowDialogTip(data, params, context)
    local arg = {}
    local num = 1
    while params["p" .. num] ~= nil do
        table.insert(arg, params["p" .. num])
        num = num + 1
    end
    params.entity:showDialogTip(params.tipType, params.event, arg, params.context, params.dialogContinuedTime)
end

function Actions.ShowInviteTipByScript(data, params, context)
    local player = params.player
    local modName = "ShowInviteTip" .. (params.pic or "") .. (params.fullName or "") .. World.Now() .. os.time() .. math.random(0, 99999)
    local regId = player:regCallBack(modName, params.eventMap, true, true, params.context)
    player:sendPacket({
        pid = "ShowInviteTipByScript",
        regId = regId,
        pic = params.pic,
        titleText = params.titleText,
        content = params.content,
        buttonInfo = params.buttonInfo,
        fullName = params.fullName,
        time = params.showTime,
        modName = modName
	})
end

function Actions.SyncStatesData(data, params, context)
    local player = params.player
    if not player or not player:isValid() or not player.isPlayer then
        return
    end

    player:sendPacket({
        pid = "SyncStatesData",
        isClose = params.isClose,
        data = {
			isAdd = params.isAdd,
			states = params.states,
			targetID = (params.target and {params.target.objID} or {player.objID})[1]
		},
    })
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
    local playerRegion = object.map:getRegionValue(curPlayerPos) -- object.map:getRegionValue(entityPos)
    local region = not playerRegion and object.map:getRegionValue(entityPos) or playerRegion
    local vectorAxis = Lib.v3cut(region and Lib.getRegionCenter(region) or curPlayerPos, entityPos)
    -- vectorAxis = Lib.v3add(boundBoxSize, vectorAxis)
    local kSize = math.max(math.abs(vectorAxis.x / 0.01), math.abs(vectorAxis.y / 0.01), math.abs(vectorAxis.z / 0.01))
    local normalizeV3 = Lib.v3(
        (lastSideNormal.x == 0 and vectorAxis.x or 0) / kSize,
        (lastSideNormal.y == 0 and vectorAxis.y or 0) / kSize,
        (lastSideNormal.z == 0 and vectorAxis.z or 0) / kSize
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

function Actions.ShowRewardDialog(data, params, context)
    local player = params.player
    if not player then
        return
    end

    local regId = nil
    if params.event then
        regId = player:regCallBack("rewardTipDialog", { rewardTip = params.event}, true, true)
    end

    player:sendPacket({
        pid = "ShowRewardDialog",
        regId = regId,
    })

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