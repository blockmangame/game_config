local setting = require "common.setting"
local handles = Player.PackageHandlers

function handles:ShowHomeGuide(packet)
    local ui = UI:openWnd("directionUI")
    if ui then
        ui:updateHomeUI(packet.pos)
    end
end

function handles:SendInteractionEnd(packet)
    self:setInteractingPlayer()
end

function handles:SendInteractionBegin(packet)
    self:setInteractingPlayer(packet.targetID, packet.skillName)
end

function handles:UpdateEntityDate(packet)
    local obj = World.CurWorld:getObject(packet.objId)
    if obj then
        obj[packet.key] = packet.value
    end
end

function handles:SyncItemUse(packet)
	self:setItemUse(packet.tid, packet.slot, packet.isUse, true, packet.mustUpdateBag)
end

function handles:ShowSingleTeamUI(packet)
    Lib.emitEvent(Event.EVENT_SHOW_SINGLE_TEAM, packet.show, packet.info)
end

function handles:ShowTeamUI(packet)
    Lib.emitEvent(Event.EVENT_SHOW_TEAM, packet.show, packet.info)
end

function handles:ShowProgressFollowObj(packet)
    local obj = World.CurWorld:getObject(packet.objID)
    if obj then
        Lib.emitEvent(Event.EVENT_SHOW_PROGRESS_FOLLOW_OBJ, packet)
    end
end

function handles:ShowDetails(packet)
    Lib.emitEvent(Event.EVENT_SHOW_DETAILS, packet)
end

function handles:SetLoadSectionMaxInterval(packet)
    if packet.value and packet.value > 0 then
        Blockman.instance.gameSettings:setAsynLoadSectionMaxInterval(packet.value)
    end
end

function handles:ShopItemDetail(packet)
    UILib.openShopBuy(packet.hintImage, function(selectedLeft)
        if not selectedLeft then
            Me:doCallBack("ItemDetail", "no", packet.regId)
            return
        end
        Me:doCallBack("ItemDetail", "sure", packet.regId)
    end, packet.coinId, packet.price, packet.desc, packet.tip)
end

function handles:UpdateUIData(packet)
    UI:setRemoterData(packet.ui, packet.data)
    Lib.emitEvent(Event.EVENT_UPDATE_UI_DATA, packet.ui, packet.data or {})
end

function handles:WorksWallsOperation(packet)
    Lib.emitEvent(Event.EVENT_WORKS_WALLS_OPERATION, packet.isOpen)
end

function handles:SetWorksArchiveNum(packet)
    Me:data("main").worksArchiveNum = packet.num
end

function handles:ShowDialogTip(packet)
    local args = packet.args
    Lib.emitEvent(Event.EVENT_SHOW_DIALOG_TIP, packet.tipType, packet.dialogContinuedTime, 
        packet.regId, packet.modName, table.unpack(args))
end

function handles:ShowInviteTipByScript(packet)
    Lib.emitEvent(Event.EVENT_SHOW_INVITE_TIP_BY_SCRIPT, packet)
end

function handles:SyncStatesData(packet)
    Lib.emitEvent(Event.EVENT_SYNC_STATES_DATA, packet)
end

--TRADE
function handles:RequestTrade(packet) --接到请求交易
    local showArgs = {
        titleText = "TRADE",
	    msgText = {"gui_request_trade", packet.playerName}
    }
    local callback = function(sure)
        if not sure then
            return
        end
        UILib.openChoiceDialog(showArgs, function(isLeft)
            if not isLeft then
                Me:sendPacket({pid = "AcceptTrade", sessionId = packet.sessionId})
            else 
                Me:sendPacket({pid = "RefuseTrade", sessionId = packet.sessionId})
            end
        end)
    end
    UI:openWnd("tradeHint", {text = "gui.trade.risk.hint"}, callback)
end

local showTop = 1
function handles:TradeRefused(packet)--对方拒绝
	Client.ShowTip(showTop, "gui_trade_refuse", 50)
end

function handles:TradeSucceed(packet) -- 交易成功提示
    Client.ShowTip(showTop, "gui_request_accomplish", 50)
    self:clearTrade()
    Lib.emitEvent(Event.EVENT_TRADE_SUCCEED, packet.tradeID)
end

function handles:StartTrade(packet)--交易开始：
	self:StartTrade(packet)
end

function handles:TradeClose(packet) --一些非正常关闭
    local showType = {
		showCenter = 2,
		keepTime = 40,
		textKey = "gui.trade." .. packet.reason
	}
    Client.ShowTip(showType.showCenter, showType.textKey, showType.keepTime)
    self:clearTrade()
end

--function handles:TradePlayerConfirm(packet) --对方确认, 不需要重写

--function handles:TradeItemChange(packet) --对方选择改变， 不需要重写

function handles:TradePlayerCancel(packet) --对方中途取消
    Client.ShowTip(1, "gui.trade.close", 40)
    self:clearTrade()
    UI:closeWnd("tradeUI")
end

function handles:ShowRewardDialog(packet)
    Lib.emitEvent(Event.EVENT_SHOW_REWARD_DIALOG, packet)
end

function handles:ShowWarmPrompt(packet)
    local callback = function(sure)
        local type = sure and "sure" or "no"
        Me:doCallBack("ShowWarmPrompt", type, packet.regId)
    end
    local ui = UI:openWnd("tradeHint", {text = packet.text, btnText = packet.btnText, disableClose = packet.disableClose}, callback)
    ui:root():SetAlwaysOnTop(true)
	ui:root():SetLevel(0)
end

function handles:ShowGuidePop(packet)
    local callback = function(sure)
        Me:doCallBack("ShowGuidePop", "sure", packet.regId)
    end
    local ui = UI:openWnd("guidePop", {texts = packet.texts, btnText = packet.btnText}, callback)
end

function handles:OpenMainExtension(packet)
    local ui = UI:getWnd("mainExtension")
    if packet.open then
        ui:openLayout()
    else
        ui:hideLayout()
    end
end

function handles:HideCloseGPS(packet)
    local ui = UI:getWnd("workTask")
    ui.forceClose = packet.hide  
    if ui and packet.hide then
        ui.closeGpsBtn:SetVisible(not packet.hide)
    end
end

function handles:ShowWhiteScreen(packet)
    UI:openWnd("whiteScreen")
    Lib.emitEvent(Event.EVENT_SHOW_WHITE_SCREEN, packet)
end

function handles:ShowRewardCD(packet)
    Lib.emitEvent(Event.EVENT_SHOW_REWARD_CD, packet.time)
end

function handles:ShowStateUI(packet)
    Lib.emitEvent(Event.EVENT_SET_UI_INVISIBLE)
end

function handles:UseDressArchive(packet)
    Lib.emitEvent(Event.EVENT_USE_DRESS_ARCHIVE, packet.index)
end

function handles:UpdateEntityEditContainer2(packet)
	Lib.emitEvent(Event.EVENT_UI_EDIT_UPDATE_EDIT_CONTAINER_2, packet.objID, packet.show)
end

function handles:setGuidePosition(packet)
    self:setGuidePosition(packet.pos)
	Lib.emitEvent(Event.EVENT_GUIDE_POSITION_CHANGE, packet.pos)
end

function handles:setGuideTarget(packet)
    self:setGuideTarget(packet.pos, packet.guideTexture or "guide_arrow.png", packet.guideSpeed or 1)
    Lib.emitEvent(Event.EVENT_GUIDE_POSITION_CHANGE, packet.pos)
end

function handles:ShowBubbleMsg(packet)
    local entity = World.CurWorld:getEntity(packet.objID)
    if not entity then
        return
    end
    Lib.emitEvent(Event.EVENT_SHOW_BUBBLE_MSG, packet)
end

function handles:ToggleBloom(packet)
    Blockman.instance.gameSettings:setEnableBloom(packet.bloomOpen)
end

local function isSamePos(p1, p2)
    return p1.x == p2.x and p1.y == p2.y and p1.z == p2.z
end

local function renderWall(map, childRegionKey, childRegionArr, destBlock)
    if not destBlock or destBlock == "" then
        return
    end
    if #childRegionArr == 0 then
        return
    end
    local regions = childRegionArr
    local regionArea = 99
    local min, max, x,y,z
    for _, region in ipairs(regions) do
        min = region.min
        max = region.max
        x = max.x - min.x
        y = max.y - min.y
        z = max.z - min.z
        regionArea = regionArea + (x * x + y * y + z * z) * 2
    end
    local replaceTb = Block.GetNameCfg(destBlock).destBlockMatrix or {}
    if not replaceTb or #replaceTb == 0 then
        replaceTb[1] = {destBlock}
    end
    local filter = Block.GetNameCfg(destBlock).filter or {}
    local firstRegion = regions[1]
    for _,re in ipairs(regions) do -- 解决菠萝房区域选择问题
        if firstRegion.min.x >= re.min.x and firstRegion.min.y >= re.min.y and firstRegion.min.z >= re.min.z then
            firstRegion = re
        end
    end
    if not firstRegion then
        return
    end

    local firstRegionMin = firstRegion.min
    local firstRegionMax = firstRegion.max
    local maxHeight = firstRegionMax.y

    local matrixWidth = #(replaceTb[1])
    local matrixHeight = #replaceTb
    local widthCount = 0
    local heightCount = 0

    local directionMap = {
        {x = 1, y = 0, z = 0},
        {x = 0, y = 0, z = 1},
        {x = -1, y = 0, z = 0},
        {x = 0, y = 0, z = -1}
    }
    local directionIndex = 1

    local firstBlockPos = firstRegionMin
    local curBlockPos = firstRegionMin
    local lastBlockPos = firstRegionMin

    -- if true then ------------- TODO DEL
    --     return
    -- end

    for index = 1,firstRegionMax.x - firstRegionMin.x + firstRegionMax.z - firstRegionMin.z do
        local firstSourceBlockCfg = map:getBlock(firstBlockPos)
        local firstNeedReplace = true
        for i,v in pairs(filter) do
            if not firstSourceBlockCfg[i] or firstSourceBlockCfg[i] ~= v then
                firstNeedReplace = false
                break
            end
        end
        if firstNeedReplace then
            curBlockPos = firstBlockPos
            lastBlockPos = firstBlockPos
            break
        end
        firstBlockPos = Lib.v3add(directionMap[directionIndex], firstBlockPos)
    end

    for index = 1, regionArea do
        local sourceBlockCfg = map:getBlock(curBlockPos)
        local needReplace = true
        for i,v in pairs(filter) do
            if not sourceBlockCfg[i] or sourceBlockCfg[i] ~= v then
                needReplace = false
                break
            end
        end
        if needReplace then
            local destBlockCfg = replaceTb[heightCount % matrixHeight + 1][widthCount % matrixWidth + 1]
            map:removeBlock(curBlockPos)
            map:createBlock(curBlockPos, destBlockCfg)
        end

        local nextBlockPos = nil
        for tindex = 1, 4 do
            local imcV3 = directionMap[tindex]
            local tempPos = Lib.v3add(curBlockPos, imcV3)
            local tempPosInRegion = false
            for _, re in ipairs(regions) do
                if Lib.isPosInRegion(re, tempPos) then
                    tempPosInRegion = true
                    break
                end
            end
            if tempPosInRegion then
                local tempPosBlockCfg = map:getBlock(tempPos)
                local tempPosNeedReplace = true
                if not isSamePos(tempPos, lastBlockPos) then
                    for i,v in pairs(filter) do
                        if not tempPosBlockCfg[i] or tempPosBlockCfg[i] ~= v then
                            tempPosNeedReplace = false
                            break
                        end
                    end
                    if tempPosNeedReplace then
                        nextBlockPos = tempPos
                        directionIndex = tindex
                        break
                    end
                end
            end
        end
        if not nextBlockPos then
            nextBlockPos = Lib.v3add(directionMap[directionIndex], curBlockPos)
            local nextBlockPosInRegion = false
            for _,re in ipairs(regions) do
                if Lib.isPosInRegion(re, nextBlockPos) then
                    nextBlockPosInRegion = true
                    break
                end
            end
            if not nextBlockPosInRegion then
                for tindex = 1, 4 do
                    local imcV3 = directionMap[tindex]
                    local tempPos = Lib.v3add(curBlockPos, imcV3)
                    local tempPosInRegion = false
                    for _,re in ipairs(regions) do
                        if Lib.isPosInRegion(re, tempPos) then
                            tempPosInRegion = true
                            break
                        end
                    end
                    if tempPosInRegion then
                        if not isSamePos(tempPos, lastBlockPos) then
                            nextBlockPos = tempPos
                            directionIndex = tindex
                            break
                        end
                    end
                end
            end
        end
        if isSamePos(nextBlockPos, firstBlockPos) then
            local tempPos = Lib.v3add(firstBlockPos, {x = 0, y = 1, z = 0})
            if tempPos.y > maxHeight then
                break
            end
            heightCount = heightCount + 1
            widthCount = 0
            firstBlockPos = Lib.copy(tempPos)
            curBlockPos = Lib.copy(tempPos)
            lastBlockPos = Lib.copy(tempPos)
        else
            lastBlockPos = Lib.copy(curBlockPos)
            curBlockPos = Lib.copy(nextBlockPos)
            widthCount = widthCount + 1
        end
    end
end

local function renderFloor(map, childRegionKey, childRegionArr, destBlock)
    if not destBlock or destBlock == "" then
        return
    end
    if #childRegionArr == 0 then
        return
    end
    local regions = childRegionArr
    local replaceTb = Block.GetNameCfg(destBlock).destBlockMatrix or {}
    if not replaceTb or #replaceTb == 0 then
        replaceTb[1] = {destBlock}
    end
    local filter = Block.GetNameCfg(destBlock).filter or {}
    local lastRegion = nil
    local matrixWidth = #(replaceTb[1])
    local matrixHeight = #replaceTb
    local widthCount = 0
    local heightCount = 0
    for _, region in ipairs(regions) do
        local min = region.min
        local max = region.max
        local minX, minY, minZ, maxX, maxY, maxZ = min.x, min.y, min.z, max.x, max.y, max.z
        if lastRegion and minX == lastRegion.min.x then
            heightCount = (lastRegion.max.z - lastRegion.min.z) % matrixHeight
        elseif lastRegion and minZ == lastRegion.min.z then
            widthCount = (lastRegion.max.x - lastRegion.min.x) % matrixWidth
        end
        for i = minX, maxX do
            for j = minZ, maxZ do
                local destBlockCfg = replaceTb[matrixHeight - (j - minZ + heightCount) % matrixHeight][(i - minX + widthCount) % matrixWidth + 1]
                local pos = {x = i, y = minY, z = j}
                local tempBlock = map:getBlock(pos)
                for i,v in pairs(filter) do
                    if not tempBlock[i] or tempBlock[i] ~= v then
                        goto CONTINUE
                    end
                end
                map:removeBlock(pos)
                map:createBlock(pos, destBlockCfg)
                ::CONTINUE::
            end
        end
    end
end

function handles:RenderBlock(packet)
    local mapID = packet.mapID
    local childRegionKey = packet.childRegionKey
    local childRegionArr = packet.childRegionArr
    local destBlock = packet.destBlock
    if Me.map.id ~= mapID then
        return
    end
    if childRegionKey == "wallRegion" then
        renderWall(Me.map, childRegionKey, childRegionArr, destBlock)
    elseif childRegionKey == "floorRegion" then
        renderFloor(Me.map, childRegionKey, childRegionArr, destBlock)
    end
end

function handles:EntityAutoChangeSkin(packet)
    local entity = World.CurWorld:getEntity(packet.objID)
    if entity then
        if not Me.carpetActor then
            Me.carpetActor = GUIWindowManager.instance:CreateGUIWindow1("ActorWindow", "CarpetActor")
            Me.carpetActor:SetActor1(entity:cfg().actorName, "idle")
            for i = 1, 20 do
                Me.carpetActor:UseBodyPart("a" .. tostring(i) , tostring(i))
            end
        end
        entity:startAutoChangeSkin()
    end
end