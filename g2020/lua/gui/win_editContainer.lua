-- 编辑UI
M.NotDialogWnd = true
local mfloor = math.floor
local mceil = math.ceil
local kCollision = 0.05
local kCollisionMargin = 0.01

local SHOW_UI_WIDGET_ENUM = {
    "widget_store_show",
    "widget_store_show_2",
    "widget_store_show_3",
    "widget_store_show_4"
}

local IS_OPEN = false

local bm = Blockman.instance
local ti = TouchManager:Instance()
local curWorld = World.CurWorld

local function sendEditObject(objID, action, params)
    Me:sendPacket({
        pid = "EditObjectAction",
        objID = objID,
        action = action,
        params = params
	})
end

function M:init()
    WinBase.init(self, "EditContainer.json", true)
    self.base = self:child("EditContainer-Base")

    self:initChild()
    self:initEvent()
end

function M:initChild()
    local touchEndBg = GUIWindowManager.instance:LoadWindowFromJSON("EditContainerClick.json")
    self._root:AddChildWindow(touchEndBg)
    touchEndBg:SetVisible(false)
    touchEndBg:SetAlwaysOnTop(true)
    self.touchEndBg = touchEndBg
    self.isMovingEntity = false
    self.lastSideNormal = Lib.v3(0,0,0)

    self.container = {}
    self.containerCloser = {}
    self.localContext = {}
    self.allCell = {}

    self.touchListenerContent = {}
end

local function stopTouchListener(self, objID)
    if not objID then
        return
    end
    local touchListenerContent = self.touchListenerContent
    local tlco = touchListenerContent[objID]
    for i, v in pairs(tlco or {}) do
        v()
    end
    touchListenerContent[objID] = {}
end

local function startTouchListener(self, objID)
    if not objID then
        return
    end
    stopTouchListener(self, objID)
    local tlco = self.touchListenerContent[objID]
    local touchTick = 0
    tlco.beginTouchEventListener = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function(x, y)
        touchTick = curWorld:getTickCount()
    end)
    tlco.endTouchEventListener = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_END, function(x, y)
        if IS_OPEN and bm:getHitInfo().type ~= "ENTITY" and curWorld:getTickCount() - touchTick <= 2 then
            local objID = self.localContext.objID
            Lib.emitEvent(Event.EVENT_UI_EDIT_UPDATE_EDIT_CONTAINER_2, objID, false)
            sendEditObject(objID, "exit", {})
        end
    end)
end

local function clearMoveStatus(self)
    if self.movingTimer then
        self.movingTimer()
        self.movingTimer = nil
    end
    self.touchEndBg:SetVisible(false)
    self.isMovingEntity = false
    self.lastSideNormal = Lib.v3(0,0,0)
end

local calcBoundingBoxTouchBlock
local function clacPushOutWithBlock(self, object)
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
    local curPlayerPos = Player.CurPlayer:getPosition()
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

local editCd = false
function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_UI_EDIT_UPDATE_EDIT_CONTAINER_2, function(objID, show)
        if self.isMovingEntity then
            return
        end
        self.allCell[objID] = {}
        
        for oid, closer in pairs(self.containerCloser or {}) do 
            if closer then
                closer()
            end
            self.containerCloser[oid] = nil
            local ui = self.container[oid]
            self.container[oid] = nil
            clearMoveStatus(self)
            stopTouchListener(self, oid)
        end

        local object = curWorld:getObject(objID)
        if show and not editCd then    
            editCd = true
            World.Timer(2, function()
                editCd = false
            end)
            self:showInteractionUI(objID)
            self.localContext.objID = objID
            IS_OPEN = true
            startTouchListener(self, objID)
            sendEditObject(objID, "startEdit", {})
        else
            local closer = self.containerCloser[objID]
            self.containerCloser[objID] = nil
            if closer then
                closer()
            end
            local ui = self.container[objID]
            self.container[objID] = nil
            IS_OPEN = false
            clearMoveStatus(self)
            stopTouchListener(self, objID)
            local clacPos = clacPushOutWithBlock(self, object)
            if clacPos then
                object:setPosition(clacPos)
            end
            sendEditObject(objID, "stopEdit", {entityPos = clacPos})
        end
        if not object or not object:isValid() then
            return
        end
        bm:setRenderBoxEnable(not not show)
        object:setRenderBox(not not show)
    end)
end

function M:showInteractionUI(objID)
    local object = curWorld:getObject(objID)
    if not object then
        return
    end
    local editUI = object:cfg().editUI
    if not editUI then
        return
    end

    local container = GUIWindowManager.instance:LoadWindowFromJSON("InteractionLayout.json")
    self._root:AddChildWindow(container)
    self.container[objID] = container

    self.containerCloser[objID] = self:setContainerFollow(container, objID, editUI.followParams or {})

    if editUI.moveWidget then
        self:createMoveWidget(objID, editUI.moveWidget, editUI)
    end

    if editUI.aroundWidget then
        self:createAroundWidget(objID, editUI.aroundWidget, editUI)
    end

    container:SetVisible(true)
end

function M:setContainerFollow(wnd, objID, followParams)
    return UILib.uiFollowObject(wnd, objID, followParams)
end

local function fetchWeightBtn(self, weightInfo)
    local cell = UIMgr:new_widget("cell", SHOW_UI_WIDGET_ENUM[weightInfo.btnType or 4] .. ".json", SHOW_UI_WIDGET_ENUM[weightInfo.btnType or 4])
    cell:invoke("RESET_OUTER_FRAME",false)
    cell:invoke("SET_ICON_BY_PATH", weightInfo.image or "")
    cell:invoke("LD_BOTTOM",Lang:toText(weightInfo.text or ""))
    return cell
end

local function getSideIndex(sideNormal)
	if sideNormal.y == -1 then
        return 1
    elseif sideNormal.y == 1 then
        return 2
    elseif sideNormal.x == 1 then
        return 3
    elseif sideNormal.x == -1 then
        return 4
    elseif sideNormal.z == 1 then
        return 5
    elseif sideNormal.z == -1 then
        return 6
    end
end

local function getRotateCount(sideIndex, moveEntity)
	local yaw = moveEntity:getRotationYaw()
	local pitch = moveEntity:getRotationPitch()
	if sideIndex <= 2 then
		return mfloor(yaw / 90) % 4
	else
		return mfloor(pitch / 90) % 4
	end
end

local function getRotateIndex(sideNormal, moveEntity)
	if getSideIndex(sideNormal) then
		return getSideIndex(sideNormal)
	end
	local yaw = moveEntity:getRotationYaw()
	local pitch = moveEntity:getRotationPitch()
	local roll = moveEntity:getRotationRoll()
	local pitchCont = mfloor(pitch / 90)
	local yawCount = mfloor(yaw / 90)
	local rollCount = mfloor(roll / 90)
	if yawCount == 2 and rollCount == 1 then
		return 3
	elseif yawCount == 0 and rollCount == 1 then
		return 4
	elseif yawCount == -1 and rollCount == 1 then
		return 5
	elseif yawCount == 1 and rollCount == 1 then
		return 6
	elseif pitchCont == 2 then
		return 1
	elseif pitchCont == 0 then
		return 2
	end
end

local function getPitchAndYaw(self, sideNormal, moveEntity) -- 计算旋转
    local pitch = 0
    local yaw = 0
    local roll = 0
    local v3Zero = Lib.v3(0, 0, 0)
	local rotateCountMap = {
		{2,1,0,3},{},{2,1,0,3},{2,1,0,3},{2,1,0,3},{2,1,0,3},
		{},{0,1,2,3},{0,1,2,3 },{0,1,2,3},{0,1,2,3},{0,1,2,3},
		{2,1,0,3},{0, 1,2,3},{0,1,2,3},{},{0,1,2,3},{0,1,2,3},
		{2,1,0,3},{0,1,2,3},{},{0,1,2,3},{0,1,2,3},{0,1,2,3},
		{2,1,0,3},{0,1,2,3},{0,1,2,3},{0,1,2,3},{0,1,2,3},{},
		{2,1,0,3},{0,1,2,3},{0,1,2,3},{0,1,2,3},{},{0,1,2,3},
	}
    if sideNormal == v3Zero and self.lastSideNormal ~= v3Zero then
        sideNormal = self.lastSideNormal
    end
    -- TODO GET ROTATION
	local curIndex = getRotateIndex(sideNormal, moveEntity)
	local lastIndex = getRotateIndex(self.lastSideNormal, moveEntity)
	local lastRotateCount = getRotateCount(lastIndex, moveEntity)
	local curRotateCount = rotateCountMap[(lastIndex - 1) * 6 + curIndex][lastRotateCount + 1]
    if curIndex == 1 then
        pitch = 180
    elseif curIndex == 2 then
        pitch = 0
    elseif curIndex == 3 then
        yaw = 180
        roll = 90
    elseif curIndex == 4 then
        yaw = 0
        roll = 90
    elseif curIndex == 5 then
        yaw = -90
        roll = 90
    elseif curIndex == 6 then
        yaw = 90
        roll = 90
    end
	if curIndex <= 2 then
		yaw = (curRotateCount or 0 )* 90
	else
		pitch = (curRotateCount or 0) * 90
	end
    self.lastSideNormal = sideNormal
    return pitch, yaw, roll
end

calcBoundingBoxTouchBlock = function(worldPos, entity, sideNormal)
    local boundingBox = entity:getBoundingBox()
    local retTouchBlockPos = {}
    --[[ -- boundingBox value : scale, min pos, max pos
        [1] = 1.0,
        [2] = {
            ["z"] = 39.014602661133, 
            ["y"] = 2.0,
            ["x"] = 42.380867004395
        },
        [3] = {
            ["z"] = 41.014602661133,
            ["y"] = 2.2000000476837,
            ["x"] = 44.380867004395
        }
    ]] 
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

local function getEntityPos(mouseHit, objID)
    local pos
    if mouseHit.type=="ENTITY" then
        local entity = curWorld:getObject(mouseHit.objID)
        if entity.objID ~= objID then
            local entityPos = entity:getPosition()
            pos = {x = entityPos.x, y = entity:cfg().supportingForce and entity:getBoundingBox()[3].y or entityPos.y, z = entityPos.z}
        end
    elseif mouseHit.worldPos then
        pos = mouseHit.worldPos
    end
    return pos
end

local function displayMoveEvent(self, objID, cell, moveWidget, editUI)
    local moveEntity = curWorld:getObject(objID)
    local params = {}
    local showFunc
    self:subscribe(cell, UIEvent.EventWindowTouchDown, function()
        if self.isMovingEntity then
            return
        end
        for i, v in pairs(self.allCell[objID] or {}) do
            if cell ~= v then
                v:SetAlpha(0)
            end
        end
        self.isMovingEntity = true
        showFunc = UI:hideOpenedWnd("editContainer")
        self.touchEndBg:SetVisible(true) -- 将长按结束后不知道按在什么位置的长按抬起检测的child设置回来
		self.touchEndBg:SetLevel(1)
        local tempYaw = moveEntity:getRotationYaw()
        local tempPitch = moveEntity:getRotationPitch()
        local tempRoll = moveEntity:getRotationRoll()
        local tempLastSideNormal = moveEntity.lastSideNormal
        if moveWidget.beginMoveAction then
            sendEditObject(objID, "beginMove", params)
        end

        if self.movingTimer then
            self.movingTimer()
        end
        self.movingTimer = World.Timer(moveWidget.moveTick or 1, function()
            if not moveEntity or not moveEntity:isValid() then
                self.movingTimer = nil
                return false
            end

            local touch = ti:getTouch(ti:getActiveTouch())
            local mouseHit = {}
            if touch then
                -- mouseHit = bm:getRayTraceResult2(touch:getTouchPoint(), {objID})
                -- screenPos, rayLenth, isNeedLogicPositinToScreenPosition, getHitEffectRelated, getTrajectoryEffectRelated, ignoreObjIds
                mouseHit = bm:getRayTraceResult(touch:getTouchPoint(), -1, true, false, false, {objID})
            end

            -- local mouseHit = bm:getHitInfo()
            local pitch, yaw, roll = getPitchAndYaw(self, mouseHit.sideNormal or {x = 0, y = 0, z = 0}, moveEntity)
            moveEntity:setRotation(yaw, pitch, roll)
            moveEntity:setBodyYaw(yaw)
            local pos = getEntityPos(mouseHit, objID) or moveEntity:getPosition()
            local moveEntityLastSideNormal = moveEntity.lastSideNormal or {x = 0, y = 1, z = 0}
            local mouseHitSideNormal = mouseHit.sideNormal or moveEntityLastSideNormal
            local moveEntityLastPosition = moveEntity.lastPosition or pos
            if Lib.tov3(mouseHitSideNormal) ~= Lib.tov3(moveEntityLastSideNormal) then
                moveEntity:setPosition(pos)
            else
                local function calcMove(inPos)
                    local newPos, isCanMoveTo = calcBoundingBoxTouchBlock(inPos, moveEntity, mouseHitSideNormal)
                    if isCanMoveTo then
                        moveEntity:setPosition(newPos or pos)
                    end
                end
                if Lib.getPosDistance(moveEntityLastPosition, pos) >= kCollision then
                    local dis = Lib.v3cut(pos, moveEntityLastPosition)
                    local ratio = Lib.getPosDistance(moveEntityLastPosition, pos) / kCollision
                    local addV3 = {x = dis.x / ratio, y = dis.y / ratio, z = dis.z / ratio}
                    for i=1, ratio do
                        calcMove(Lib.v3add(moveEntityLastPosition,{x = addV3.x * i, y = addV3.y * i, z = addV3.z * i}))
                    end
                else
                    calcMove(pos)
                end
            end
            moveEntity.lastSideNormal = mouseHit.sideNormal or moveEntity.lastSideNormal
            moveEntity.lastPosition = moveEntity:getPosition()
            return true
        end)
        self:subscribe(self.touchEndBg, UIEvent.EventWindowTouchUp, function()
            if not self.isMovingEntity then
                return
            end
            for i, v in pairs(self.allCell[objID] or {}) do
                if cell ~= v then
                    v:SetAlpha(1)
                end
            end
            self:unsubscribe(self.touchEndBg)
            moveEntity.lastSideNormal = self.lastSideNormal
            if moveWidget.endMoveAction then
                params.entityPos = moveEntity:getPosition()
                params.entityYaw = moveEntity:getRotationYaw()
                params.entityPitch = moveEntity:getRotationPitch()
                params.entityRoll = moveEntity:getRotationRoll()
                params.lastSideNormal = self.lastSideNormal
                sendEditObject(objID, "endMove", params)
            end
            if showFunc then
                showFunc()
                showFunc = nil
            end
            clearMoveStatus(self)
        end)
    end)
end

function M:createMoveWidget(objID, moveWidget, editUI)
    local container = self.container[objID]
    local cell = fetchWeightBtn(self, moveWidget)
    container:AddChildWindow(cell)
    cell:invoke("POS", moveWidget.pos)
    local objIDAllCell = self.allCell[objID]
    objIDAllCell[#objIDAllCell + 1] = cell
    displayMoveEvent(self, objID, cell, moveWidget, editUI)
end

function M:createAroundWidget(objID, aroundWidget, editUI)
    local container = self.container[objID]
    for index, weight in ipairs(aroundWidget) do
        local cell = fetchWeightBtn(self, weight)
        container:AddChildWindow(cell)
        if weight.action then
            self:subscribe(cell, UIEvent.EventWindowClick, function()
                sendEditObject(objID, weight.action, {})
            end)
        elseif weight.tipContent then
            self:subscribe(cell, UIEvent.EventWindowClick, function()
				local content = weight.tipContent.content or {}
                UILib.openChoiceDialog(content, function(isTrue)
                    if not isTrue then
                        sendEditObject(objID, weight.tipContent.action, {})
                    end
                end) 
            end)
        end
        cell:invoke("POS", weight.pos)
        local objIDAllCell = self.allCell[objID]
        objIDAllCell[#objIDAllCell + 1] = cell
    end
end

function M:onOpen()
end

function M:onClose()
end