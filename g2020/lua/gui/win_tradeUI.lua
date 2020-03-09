
local item_manager = require "item.item_manager"
local TCfg = World.cfg.tradeCfg or {}
local MaxTradeNum = TCfg.MaxTradeNum or 4
local GridConfig = TCfg.GridConfig or {hInterval = 5, vInterval = 5, rowSize = 2}

local path = "set:g2020_bag.json image:"
local imageSet = {}
imageSet.equip_level_1   = "image/equip_level_5.png"
imageSet.equip_level_2   = path .. "equip_level_3.png"
imageSet.equip_level_3   = path .. "equip_level_2.png"
imageSet.equip_level_4   = path .. "equip_level_4.png"
imageSet.equip_level_5   = path .. "equip_level_1.png"

local Tipdata = {
	showTypeTop = 2,
	showTime = 40
}

function M:init()
	WinBase.init(self, "partyTradeUI.json")

	self.leftGrid = self:child("partyTradeUI-leftGridView")
	self.rightGrid = self:child("partyTradeUI-rightGridView")
	self.confirmBtn = self:child("partyTradeUI-rightButton")

	self.leftGrid:InitConfig(5, 5, 2)
	self.rightGrid:InitConfig(5, 5, 2)
	
	--规则按钮
	self:subscribe(self:child("partyTradeUI-ruleBtn"), UIEvent.EventButtonClick, function()
		Lib.emitEvent(Event.SHOW_TRADE_HINT)
	end)

	local closeTradeF = function()
		Me:sendPacket({pid = "BreakTrade", tradeID = self.tradeID, breakTrade = true})
		Me:clearTrade()
		UI:closeWnd(self)
	end
	--关闭按钮
	self:subscribe(self:child("partyTradeUI-closeBtn"), UIEvent.EventButtonClick, closeTradeF)
	--玩家关闭，取消交易
	self:subscribe(self:child("partyTradeUI-leftButton"), UIEvent.EventButtonClick, closeTradeF)

	--对方选择改变
	Lib.subscribeEvent(Event.EVENT_TRADE_ITEM_CHANGE, function(tradeID, operation, data)
		if tradeID ~= self.tradeID or not UI:isOpen(self) then
			return
		end
		self:changGoods(operation, data)
	end)

	--玩家选择item：通过player进行通知， 在背包里进行添加， 自己ui里进行删除， player进行桥接通知
	Lib.subscribeEvent(Event.EVENT_TRADE_CHANGE_ITEM, function(item, add)
		if add then
			self:addSelected(item)
		elseif item and not item:null() then
			local tid = item:tid()
			local slot = item:slot()
			local index = self:getSelectIndex(tid, slot)
			self:delSelected(index)
		end
		self:refreshSelected()
	end)

	--玩家确认
	self:subscribe(self:child("partyTradeUI-rightButton"), UIEvent.EventButtonClick, function()
		if not self.canConfirm then
			return
		end
		local TempConfrim = self.isConfirm
		self.isConfirm = not self.isConfirm
		self:child("partyTradeUI-leftConfrim"):SetVisible(self.isConfirm)
		Me:sendPacket({
			pid = "ConfirmTrade",
			tradeID = self.tradeID,
			isConfirm = self.isConfirm
		})
		local text = self.isConfirm and "cancel" or "sure"
		self.confirmBtn:SetText(text)
	end)

	--对方确认
	Lib.subscribeEvent(Event.EVENT_TRADE_CONFIRM, function(isConfirm, tradeID)
		if not UI:isOpen(self) or self.tradeID ~= tradeID then
			return
		end
		self:child("partyTradeUI-rightConfrim"):SetVisible(isConfirm)
	end)

	--交易成功
	Lib.subscribeEvent(Event.EVENT_TRADE_SUCCEED, function(tradeID)
		if self.tradeID == tradeID then
			UI:closeWnd(self)
		end
	end)
end

--任意玩家添加一个物品后任意玩家添加一个物品后，双方的接受按钮都会变灰双方的接受按钮都会变灰，
--并且后面加上倒计时并且后面加上倒计时10秒，倒计时结束后才可以接受倒计时结束后才可以接受
function M:updateCanConfim()
	local temp = self.canConfirm
	self.canConfirm = self.lastIndex > 0
	if temp or temp ~= self.canConfirm then
		return
	end

end

function M:getSelectIndex(tid, slot)
	local tb = self.itemMap
	local temp = tb[tid]
	if not temp then
		return
	end
	return temp[slot]
end

function M:setSelectIndex(tid, slot, index)
	local tb = self.itemMap
	local temp = tb[tid]
	if not temp then
		temp = {}
		tb[tid] = temp
	end
	temp[slot] = index
end

function M:initLeftContainer()
	self.leftCells = {}
	self.leftGrid:RemoveAllItems()
	for index = 1, MaxTradeNum do
		self:newLeftCell(index)
	end
end

function M:newLeftCell(index)
	local cell = GUIWindowManager.instance:LoadWindowFromJSON("partyTradeItem.json")
	self.leftCells[index] = cell
	self.leftGrid:AddItem(cell)
	cell:setData("index", index)
	cell:setData("itemIndex", nil)
	self:setTradeCell(index, nil)
	self:subscribe(cell, UIEvent.EventWindowLongTouchStart, function()
		--self:setItemDescUI(true, item, ui)
	end)
	self:subscribe(cell, UIEvent.EventWindowLongTouchEnd, function()
		--self:setItemDescUI(false, item)
	end)
	self:subscribe(cell, UIEvent.EventButtonClick, function()
		local index = cell:data("index")
		local itemIndex = cell:data("itemIndex")
		print("itemIndex: ", itemIndex)
		if self.lastIndex + 1 == index then
			self:openBagAddItem() --打开背包，在背包中选择item并添加
		elseif itemIndex then
			Me:addTradeItem(self.selected[itemIndex], false) --调用玩家接口，删除item
		end
	end)
	return cell
end

function M:openBagAddItem()
	 World.Timer(10, function()
        UI:openWnd("bag_g2020")
    end)
end

function M:delSelected(index)
	local item = index and self.selected[index]
	if not item or item:null() then
		return
	end
	local idx = index
	local len = self.lastIndex 
	while idx <= len do
		self.selected[idx] = self.selected[idx + 1]
		idx = idx  + 1
	end
	self.lastIndex = self.lastIndex - 1
	self:setSelectIndex(item:tid(), item:slot(), nil)
	self:refreshSelected()
	--self:updateCanConfim()
end

function M:addSelected(item)
	local list = self.selected
	local index = #list + 1
	list[index] = item
	self.lastIndex = self.lastIndex + 1
	self:setSelectIndex(item:tid(), item:slot(), index)
	self:updateCanConfim()
end

function M:refreshSelected()
	local idx = 1
	for index, item in ipairs(self.selected) do
		self:setSelectIndex(item:tid(), item:slot(), index)
		self:setTradeCell(index, item)
		idx = idx + 1
	end
	while idx <= MaxTradeNum do
		self:setTradeCell(idx, nil)
		idx = idx + 1
	end
end

function M:setTradeCell(index, item)
	local cell = self.leftCells[index]
	if not cell then
		return
	end
	cell:setData("index", index)
	local Null = (not item) or item:null()
	cell:setData("itemIndex",(not Null) and index or nil)
	local iconUi = cell:child("partyTradeItem-itemIcon")
	iconUi:SetVisible(not Null)
	local showadd = self.lastIndex + 1 == index
	cell:child("partyTradeItem-addButton"):SetVisible(showadd)
	--通过item，加载cell的样式
	iconUi:SetImage((not Null) and item:icon())
end

function M:setItemDescUI(ui)
	local index = ui:data("index")
	if not index then
		return
	end
end

--右边对方板块
function M:initRightContainer()
	self.goods = {}
	self.rightCells = {}
	self.rightGrid:RemoveAllItems()
	for index = 1, MaxTradeNum do
		self:newRightCell(index)
	end
end

function M:newRightCell(index)
	local cell = GUIWindowManager.instance:LoadWindowFromJSON("partyTradeItem.json")
	self.rightCells[index] = cell
	self.rightGrid:AddItem(cell)
	self:setGoodCell(index, nil)
	return cell
end

function M:changGoods(operation, data)
	local tid, slot, itemData = data.tid, data.slot, data.itemData
	local tb = self.goods[tid]
	if operation == "add" then
		if not tb then
			tb = {}
			self.goods[tid] = tb
		end
		tb[slot] = itemData and Item.DeseriItem(itemData)
		self:updateCanConfim()
	elseif tb and tb[slot] then
		tb[slot] = nil
	end
	self:updateCanConfim()
	self:refreshGoods()
end

function M:refreshGoods()
	local index = 1
	for tid, temp in pairs(self.goods) do
		for slot, item in pairs(temp) do
			self:setGoodCell(index, item)
			index = index +1
		end
	end
	while index <= MaxTradeNum do
		self:setGoodCell(index, nil)
		index = index + 1
	end
end

function M:setGoodCell(index, item)
	local cell = self.rightCells[index]
	if not cell then
		return
	end
	--通过item，加载cell的样式
	cell:setData("index", index)
	local Null = (not item) or item:null()
	cell:setData("itemIndex",(not Null) and index or nil)
	local iconUi = cell:child("partyTradeItem-itemIcon")
	iconUi:SetVisible(not Null)
	--通过item，加载cell的样式
	iconUi:SetImage((not Null) and item:icon())
	cell:child("partyTradeItem-addButton"):SetVisible(false)
end

function M:onOpen()
	
end

function M:startTrade(tradeID, targetUid)
	UI:closeWnd("bag_g2020")
	self.lastIndex = 0
	self.canConfirm = false
	self.isConfirm = false
	self.itemMap = {}
	self.selected = {}
	self.goods = {}
	self.tradeID = tradeID
	self:setStyle(targetUid)
	self:initLeftContainer()
	self:initRightContainer()
end

function M:setStyle(targetUid)
	self:child("partyTradeUI-leftConfrim"):SetVisible(false)
	self:child("partyTradeUI-rightConfrim"):SetVisible(false)
	self.confirmBtn:SetText("trade.cool")

	local mapid = {Me.platformUserId, targetUid}
	UserInfoCache.LoadCacheByUserIds(mapid, function()
		if UI:isOpen(self) then
			local cache = UserInfoCache.GetCache(targetUid)
			self:child("partyTradeUI-rightName"):SetText(cache and cache.nickName or "")
			cache = UserInfoCache.GetCache(Me.platformUserId)
			self:child("partyTradeUI-leftName"):SetText(cache and cache.nickName or "")
		end
	end)	
end

function M:onClose()
	self.tradeID = nil
end

return M