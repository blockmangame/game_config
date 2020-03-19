local imageSet = L("imageSet", {})
local path = "set:g2020_bag.json image:"

local g2020ItemLevelDesc = {
    [1] = "g2020-item-level-1",
    [2] = "g2020-item-level-2",
    [3] = "g2020-item-level-3",
    [4] = "g2020-item-level-4",
    [5] = "g2020-item-level-5",
}

imageSet.bg         = path .. "bg.png"
imageSet.titleBg    = path .. "titleBg.png"
imageSet.titleIcon  = path .. "titleIcon.png"
imageSet.boomIcon   = path .. "boomIcon.png"
imageSet.closeBtn   = path .. "closeBtn.png"
imageSet.not_tabItem_bg   = path .. "not_tabItem_bg.png"
imageSet.tabItem_bg   = path .. "tabItem_bg.png"


imageSet.item_bg   = path .. "item_bg.png"
imageSet.add   = path .. "add.png"
imageSet.sub   = path .. "sub.png"
imageSet.equip_level_1   = "image/equip_level_5.png"
imageSet.equip_level_2   = path .. "equip_level_3.png"
imageSet.equip_level_3   = path .. "equip_level_2.png"
imageSet.equip_level_4   = path .. "equip_level_4.png"
imageSet.equip_level_5   = path .. "equip_level_1.png"

imageSet.cancel_bg   = path .. "cancel_bg.png"



local BAG_TRAY_TYPE = {
    Define.TRAY_TYPE.EXTEND_BAG_1,  --五个页签背包
    Define.TRAY_TYPE.EXTEND_BAG_2,  --五个页签背包
    Define.TRAY_TYPE.EXTEND_BAG_3,  --五个页签背包
    Define.TRAY_TYPE.EXTEND_BAG_4,  --五个页签背包
    Define.TRAY_TYPE.EXTEND_BAG_5,  --五个页签背包
}

local EQUIP_TRAY_TYPE = {
    Define.TRAY_TYPE.EQUIP_2,
    Define.TRAY_TYPE.EQUIP_1,

}

function M:initData()
    self.leftDatas = {
        {
            ["icon"] = "baby_car",
            ["name"] = "g2020-baby-bed",
        },
        {
            ["icon"] = "food",
            ["name"] = "g2020-food",
        },
        {
            ["icon"] = "car",
            ["name"] = "g2020-car",
        },
        {
            ["icon"] = "toy",
            ["name"] = "g2020-toy",
        },
        {
            ["icon"] = "task",
            ["name"] = "g2020-task-item",
        },
    }
    self.transferData = {}
    if World.cfg.transferData then
        self.transferData = World.cfg.transferData
    end
    self.tabItemList = {}
    self.curDelStatus = false
    self.isOpen = false
	self.toplevel = self:root():GetLevel()
	self.fetchItemTimer = {}
end


local function Merge(...)
    local arrays = { ... }
    local result = {}
    for _,array in ipairs(arrays) do
        for _, v in ipairs(array) do
            table.insert(result, v)
        end
    end
    return result
end

function M:init()
    WinBase.init(self, "g2020_bag_ui.json")
    self:initData()
    self:initUIName()
    self:initUIStyle()
    self:initLeftTab()
    self:registerEvent()
end

function M:initUIName()
    self.closeBtn = self:child("root-close")
    self.leftTabList = self:child("root-left_list")
    self.bg = self:child("root-bg")
    self.itemsGrid = self:child("root-right_gridview")
    self.titleBg = self:child("root-title-layout")
    self.titleIcon = self:child("root-titleIcon")
    self.boomIcon = self:child("root-right-boom-icon")
    self.titleName = self:child("root-titleName")
    self.tabList = self:child("root-left_list")
    self.descBg = self:child("root-desc-bg")
    self.descLayout = self:child("root-desc")
    self.itemName = self:child("root-name")
    self.itemLevel = self:child("root-level")
end

function M:initUIStyle()
    self.bg:SetImage(imageSet.bg)
    self.titleBg:SetImage(imageSet.titleBg)
    self.titleIcon:SetImage(imageSet.titleIcon)
    self.boomIcon:SetImage(imageSet.boomIcon)
    self.closeBtn:SetNormalImage(imageSet.closeBtn)
    self.closeBtn:SetPushedImage(imageSet.closeBtn)
    self.titleName:SetText(Lang:toText("g2020-bag"))
end

local canEquipCarTimeEnd
local function unifyProc(self, btn, proc)
    self:subscribe(btn, UIEvent.EventButtonClick, function()
        self:unsubscribe(btn)
        World.Timer(5, function()
            if not btn then
                return
            end
            unifyProc(self, btn, proc)
        end)
        if proc then
            proc()
        end
    end)
end

function M:newBagItemUI()
    local itemUI = GUIWindowManager.instance:LoadWindowFromJSON("g2020_bag_item.json")
    local delBtn = itemUI:child("root-del_0")
    itemUI:child("root-bg"):SetTouchPierce(true)
    itemUI:child("root-tip-text"):SetText(Lang:toText("g2020-equiping"))

    local function func()
		local msg = {"gui_you_want_del"}
		local item = itemUI:data("item")
		if not item then
			return
		end
		local function dialogBackFunc (selectedLeft)
			if UI:isOpen(self) and not selectedLeft then
				--Me:setItemUse(item:tid(), item:slot(), false)
				self.items = nil
				Me:sendPacket({ pid = "DeleteItem", objID = Me.objID, bag = item:tid(), slot = item:slot() }, function()
						self.itemsGrid:RemoveItem(itemUI)
				end)
			end
		end
		UILib.openChoiceDialog({msgText = msg}, dialogBackFunc)
    end
    unifyProc(self, delBtn, func)
    itemUI:setEnableLongTouch(true)
    return itemUI
end

function M:newAddItemUI(addData, typeIndex)
    local itemUI = self:newBagItemUI()
    itemUI:child("root-icon"):SetImage(imageSet.add)
    self:subscribe(itemUI, UIEvent.EventButtonClick, function()
        Me:sendPacket({ pid = "TransferPoint", id = tostring(typeIndex)})
    end)
    return itemUI
end

function M:newSubItemUI()
    local itemUI = self:newBagItemUI()
    local iconUI = itemUI:child("root-icon")
    iconUI:SetImage(imageSet.sub)
    itemUI:child("root-cancel-bg"):SetImage(imageSet.cancel_bg)
    iconUI:SetWidth({0, 52})
    iconUI:SetHeight({0, 12})
    self:subscribe(itemUI, UIEvent.EventButtonClick, function()
        self:changeStatus(itemUI)
    end)
    return itemUI
end

function M:newCancelItemUI()
    local itemUI = self:newBagItemUI()
    local cancelBg = itemUI:child("root-cancel-bg")
    cancelBg:SetVisible(true)
    itemUI:child("root-bg"):SetVisible(false)
    return itemUI
end

function M:changeStatus(subItem)
    self.curDelStatus = not self.curDelStatus
    local grid = self.itemsGrid
    local typeIndex = self.typeIndex
    local addData = self.transferData[tostring(typeIndex)]
    subItem:child("root-cancel-bg"):SetVisible(self.curDelStatus)
    subItem:child("root-bg"):SetVisible(not self.curDelStatus)
	subItem:child("root-cannel-text"):SetText(Lang:toText("bag_item_cannel"))
    if self.curDelStatus then
        -- 删除状态
        if addData then
            grid:RemoveItem(grid:GetItem(0))
        end
        for i = 0, grid:GetItemCount() - 2 do
            local itemUI = grid:GetItem(i)
            itemUI:child("root-right-top"):SetVisible(false)
            itemUI:child("root-tip-bg"):SetVisible(false)
            itemUI:child("root-del_0"):SetVisible(true)
        end
    else
        -- 普通状态
        local beginIndex = 0
        if addData then
            grid:AddItem1(self:newAddItemUI(addData, typeIndex), 0)
            beginIndex = 1
        end
        for i = beginIndex, grid:GetItemCount() - 2 do
            local itemUI = grid:GetItem(i)

            local isEquip =  self:isItemEquip(itemUI:data("item"))
            itemUI:child("root-tip-bg"):SetVisible(isEquip)
            itemUI:child("root-del_0"):SetVisible(false)
            itemUI:child("root-right-top"):SetVisible(true)
        end
    end
end

function M:setBagEquip(curEquipItemUI)
    local grid = self.itemsGrid
    for i = 0, grid:GetItemCount() - 1 do
        local itemUI = grid:GetItem(i)
        itemUI:child("root-tip-bg"):SetVisible(false)
    end
    if curEquipItemUI then
        curEquipItemUI:child("root-tip-bg"):SetVisible(true)
    end
end

function M:isItemEquip(item)
	return Me:isItemUse(item)
end

function M:isItemTrade(item)
	return Me:isTradeItem(item)
end

local function isTrading()
	return Me:data("trade").tradeID
end

function M:setBagItemUI(itemUI, item)
    itemUI:child("root-icon"):SetImage(item:icon())
    itemUI:setData("item", item)
    local quality = item:cfg().quality
    if quality then
        local qualityUI = itemUI:child("root-right-top")--imageSet.equip_level_4
        qualityUI:SetVisible(true)
        qualityUI:SetImage(imageSet["equip_level_" .. quality])
    end
	local isEquip =  self:isItemEquip(item)
	if isEquip then
		self.equipUI = itemUI:child("root-tip-bg")
	end
    local isTrade = self:isItemTrade(item)
    itemUI:child("root-tip-bg"):SetVisible(isEquip or isTrade)
	local text = isTrade and "gui.item.trading" or "g2020-equiping"
	itemUI:child("root-tip-text"):SetText(Lang:toText(text))
end

function M:setItemDescUI(isShow, item, itemUI)
    if not isShow then
        self.descLayout:SetVisible(false)
        return
    end
    self.descLayout:SetVisible(true)
    local x = itemUI:GetXPosition()[2] + 305 - 45
    local y = itemUI:GetYPosition()[2]

    self.descBg:SetXPosition({0, x})
    self.descBg:SetYPosition({0, y})

    self.itemName:SetText(Lang:toText(item:cfg().itemname or "item_name"))
    self.itemLevel:SetText(Lang:toText(g2020ItemLevelDesc[item:cfg().quality or 1]))
end

function M:clearFetchItemTimer()
	for index, timer in pairs(self.fetchItemTimer or {}) do
		timer()
		self.fetchItemTimer[index] = nil
	end
end

function M:fetchAllBagItem()
	if not self.isOpen then
		return
	end
    local grid = self.itemsGrid
    local typeIndex = self.typeIndex
    grid:InitConfig(5, 5, 4)
	grid:HasItemHidden(false)
	self:clearFetchItemTimer()
    grid:RemoveAllItems()
    local itemUI
    local addItemData = self.transferData[tostring(typeIndex)]
    if addItemData and not self.isDelStatus then
        -- 加载加号
        itemUI = self:newAddItemUI(addItemData, typeIndex)
        grid:AddItem(itemUI)
    end
	self.equipUI = nil
    --加载装备 
    local filterTrays = Merge({BAG_TRAY_TYPE[typeIndex]}, EQUIP_TRAY_TYPE)
	self.items = self.items or self:filterTray(filterTrays, typeIndex)
	for index, item in ipairs(self.items) do
		self.fetchItemTimer[#self.fetchItemTimer + 1] = World.Timer(math.ceil(index / 2), function()
			if not item or item.isDel then
				goto continue
			end
			local itemUI = self:newBagItemUI()
			itemUI:setEnableLongTouch(true)
			self:subscribe(itemUI, UIEvent.EventWindowLongTouchStart, function(ui)
				self:setItemDescUI(true, item, ui)
			end)
			self:subscribe(itemUI, UIEvent.EventWindowLongTouchEnd, function()
				self:setItemDescUI(false, item)
			end)
			self:subscribe(itemUI, UIEvent.EventButtonClick, function(ui)
				if not item.tray_type then
					return
				end
				--trade
				if isTrading() then
					if item:cfg().canTrade == false then
						Client.ShowTip(1, Lang:toText("gui.item.cantTrade"), 20)
						return
					end
					Me:addTradeItem(item, not self:isItemTrade(item))
					UI:closeWnd(self)
					return
				end
				-- 3-5 begin giveAway 
				local giveAwayStatusTable = Me.giveAwayStatusTable
				if giveAwayStatusTable and giveAwayStatusTable.status then
					if item:cfg().typeIndex and BAG_TRAY_TYPE[item:cfg().typeIndex] == Define.TRAY_TYPE.EXTEND_BAG_5 then
						Client.ShowTip(1, Lang:toText("cant_give_away_task_item"), 20)
						return
					end
					UILib.openChoiceDialog({msgText = {"ui_sure_giveaway_something_to_anybody", item:cfg().itemname or ""}}, function(isTrue)
                        if not isTrue then
                            Me:sendPacket({pid = "CheckTargetTrayIsFull", objID = giveAwayStatusTable.targetObjID, tid = BAG_TRAY_TYPE[item:cfg().typeIndex]}, function(isFree)
                                if isFree then
                                    item.isDel = true
                                    if self:isItemEquip(item) then
                                        Me:setItemUse(item:tid(), item:slot(), false)
                                    end
                                    Me:sendPacket({ pid = "DeleteItem", objID = Me.objID, bag = item:tid(), slot = item:slot() }, function()
                                        grid:RemoveItem(ui)
                                    end)
                                    Me:sendPacket({ pid = "GiveAwayToTarget", objID = giveAwayStatusTable.targetObjID, cfg = item:cfg().fullName, count = 1 })
                                else
                                    Me:sendPacket({ pid = "GiveAwayToTarget", objID = giveAwayStatusTable.targetObjID, targetBagNotFree = true })
                                end
                            end)
						end
					end) 
				else
				-- 3-5 end giveAway
					local canEquipStatus = self:canEquip(item)
					if canEquipStatus == 1 then
						-- 提示不能装备要下车
						Client.ShowTip(1, Lang:toText("please_takeoff_your_car"), 20)
						return
					elseif canEquipStatus == 2 then
						return
					end
					if self.equipUI then
						self.equipUI:SetVisible(false)
					end
					Me:setItemUse(item:tid(), item:slot(), not self:isItemEquip(item))
					self:setBagItemUI(itemUI, item)
					--self:setBagItemUI(itemUI, item)
				end
			end)
			self:setBagItemUI(itemUI, item)
			grid:AddItem(itemUI)
			::continue::
		end)
	end
	if #self.items > 0 and not isTrading() then
		self.fetchItemTimer[#self.fetchItemTimer + 1]  = World.Timer(#self.items, function()
			itemUI = self:newSubItemUI()
			grid:AddItem(itemUI)
		end)
    end
end

function M:canEquip(item)
	local isEquip = self:isItemEquip(item)
	if isEquip then
		return 0
	end
    local world = Me.world
	if Me.rideOnId then
		local old = world:getEntity(Me.rideOnId)
		if old and old:cfg().carMove and item and item:cfg().typeIndex ~= 3 then
			return 1
		end
	end
	if item:cfg().typeIndex == 3 or item:cfg().typeIndex == 1 then
		local now = World.Now()
		if canEquipCarTimeEnd and now < canEquipCarTimeEnd then
			return 2 
		else
			canEquipCarTimeEnd = now + 15
		end
	end
	return 0
end

function M:filterTray(trays, typeIndex)
    local result = {}
    local trayArray = Me:tray():query_trays(trays)
    for _, element in pairs(trayArray) do
        local tray = element.tray
        local items = tray and tray:query_items(function(item)
            if item:cfg().typeIndex == typeIndex then
                return true
            end
            return false
        end)
        for _, item in pairs(items) do
            table.insert(result, item)
        end
    end

    table.sort(result, function(item1, item2)
        local isEquip1 = self:isItemEquip(item1)
        local isEquip2 = self:isItemEquip(item2)
		if isEquip1 == isEquip2 then
			local quality1 = item1:cfg().quality or 1
			local quality2 = item2:cfg().quality or 1
            return quality1 > quality2
        else 
            return isEquip1
        end
    end)
    return result
end

function M:setLeftTabItem(item, index, isSelect)
    local data = self.leftDatas[index]
    if not data then
        return
    end
    local textUI = item:child("root-name")
    textUI:SetText(Lang:toText(data.name))
    if isSelect then
        local icon =  data.icon
        item:child("root-icon"):SetImage(path .. icon .. ".png")
        textUI:SetTextColor({0.8, 0.28, 0, 1})
        textUI:SetTextBoader({ 0.98, 0.97, 0.5, 1 })
        item:child("root-bg"):SetImage(imageSet.tabItem_bg)
    else
        local icon = "not_" .. data.icon
        item:child("root-icon"):SetImage(path .. icon .. ".png")
        textUI:SetTextColor({ 0.078, 0.317, 0.568, 1 })
        textUI:SetTextBoader({ 0.62, 0.874, 0.96, 1 })
        item:child("root-bg"):SetImage(imageSet.not_tabItem_bg)
    end
end

function M:selectLeftTabItem(index)
    self.curDelStatus = false
    self.typeIndex = index
    for key, item in pairs(self.tabItemList or {}) do
        self:setLeftTabItem(item, key, tostring(key) == tostring(index))
    end
	self.items = nil
    self:fetchAllBagItem()
end

function M:newLeftTabItem()
    local item = GUIWindowManager.instance:LoadWindowFromJSON("g2020_bag_leftTab.json")
    item:child("root-bg"):SetImage(imageSet.not_tabItem_bg )
    return item
end

function M:initLeftTab()
    self.tabList:SetInterval(7)
    for index , itemData in ipairs(self.leftDatas) do
        local item = self:newLeftTabItem(itemData)
        self:setLeftTabItem(item, index, index == 1)
        self.tabList:AddItem(item)
        self.tabItemList[index] = item
    end
end

function M:registerEvent()
    self:subscribe(self.closeBtn, UIEvent.EventButtonClick, function()
        UI:closeWnd("bag_g2020")
    end)

    for index, item in pairs(self.tabItemList or {}) do
        self:subscribe(item, UIEvent.EventButtonClick, function()
            self:selectLeftTabItem(index)
        end)
    end

    self:subscribe(self.descLayout, UIEvent.EventWindowTouchUp, function()
        self:setItemDescUI(false)
    end)

	Lib.subscribeEvent(Event.EVENT_HAND_ITEM_CHANGE, function()
		if not self.curDelStatus then
			--self:fetchAllBagItem()
		end
    end)
    
    Lib.subscribeEvent(Event.EVENT_TRADE_CHANGE_ITEM, function()
		if not self.curDelStatus then
			self:fetchAllBagItem()
		end
	end)
end

function M:onOpen()
	self.isOpen = true
    self:selectLeftTabItem(self.typeIndex or 1)
end

function M:onClose()
    self.isOpen = false
    Me:updateGiveAwayStatus(false, nil) -- 3-5
    self:root():SetAlwaysOnTop(false)
    self:root():SetLevel(self.toplevel)
end


return M