local setting = require "common.setting"
local function getCfg(cfg, name)
	return cfg[name]
end

function M:init()
	WinBase.init(self, "DressStore.json", true)

	self.curItem = nil
	self.appSkin = nil
	self.curPartId = -1
	self.playerInfo = nil
	self.curActorSkin = nil

	self.itemPool = {}
	self.partItemPool = {}

	self.storeIds = World.cfg.dressStoreIds or nil
	self.actorScale = UI:getRemoterData("win_dressArchiveScale") or 1

	self:initMain()
	self:initDressParts()
end

function M:onOpen(id, playerInfo, curActorSkin, appSkin)
	self.appSkin = appSkin
	self.playerInfo = playerInfo
	self.curActorSkin = curActorSkin
	self.isUpdateItemsAgain = false

	self:updateActor()
	self:updateActorScale()
	self.clothParts:ResetScroll()

	if self.partItemPool[id].view:IsSelected() then
		self.isUpdateItemsAgain = true
		self.partItemPool[id].view:SetSelected(false)
	end
	self.partItemPool[id].view:SetSelected(true)
end

function M:initMain()
	self.actor = self:child("DressStore-Actor")
	self.clothParts = self:child("DressStore-Parts")

	self:child("DressStore-Text"):SetText(Lang:toText("ui_dress_store_title"))

	self:subscribe(self:child("DressStore-Close"), UIEvent.EventButtonClick, function()
        self:onClickCloseBtn()
    end)

	self:subscribe(self:child("DressStore-Unload-Part"), UIEvent.EventButtonClick, function()
        self:onUnloadPart()
    end)

    Lib.subscribeEvent(Event.EVENT_UPDATE_STORE_ITEM, function(storeId, itemIndex)
		if UI:isOpen(self) and storeId == self.curPartId then
			if self.curPartId > 0 then
				self:updateCurItem(self.itemPool[itemIndex].item)
			end		
		end
	end)

	Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
		if UIName == "win_dressArchiveScale" then
			self.actorScale = UI:getRemoterData("win_dressArchiveScale") or 1
			if UI:isOpen(self) then
				self:updateActorScale()
			end
		end
	end)
end

function M:onClickCloseBtn()
    UI:closeWnd(self)
    self:modPlayerSkin()
	Lib.emitEvent(Event.EVENT_OPEN_DRESS_ARCHIVE, true)
end

function M:updateActor()
	self.actor:UpdateSelf(1)
	self.actor:SetActor1(self.playerInfo.actor, "idle")
	for k, v in pairs(self.curActorSkin) do
		if k ~= "gun" then
			self.actor:UseBodyPart(k, tostring(v))
		end
	end
end

function M:updateActorScale()
	self.actor:SetActorScale(self.actorScale)
end

function M:initDressParts()
	local clothParts = self.clothParts
	clothParts:SetInterval(5)
	clothParts:ClearAllItem()

	self.partItemPool = {}

	for i, id in ipairs(self.storeIds) do
		local radioItem = GUIWindowManager.instance:CreateGUIWindow1("RadioButton", "")
		local store = Store:getStoreById(id)
		local normalImage = store.icon
		local pushedImage = store.icon .. "_choose"
		radioItem:SetNormalImage(normalImage)
		radioItem:SetPushedImage(pushedImage)
		radioItem:SetArea({0, 0}, {0, 0}, {0, 85}, {1, 0})
		self.partItemPool[id] = {id = id, view = radioItem}
		self:subscribe(radioItem, UIEvent.EventRadioStateChanged, function()
			self:onRadioChange(id)
    	end)
    	clothParts:AddItem(radioItem, false)
	end
end

function M:onRadioChange(id)
	if self.curPartId == id and not self.isUpdateItemsAgain then
		return
	end

	self.isUpdateItemsAgain = false

	if self.curPartId > 0 then
		self.partItemPool[self.curPartId].view:SetSelected(false)
	end
	
	if id > 0 then
		self.curPartId = id
		local store = Store:getStoreById(id)
		self:updateItems(store.items)
	end
end

function M:updateItems(items)
	local lvItems = self:child("DressStore-Items")
	lvItems:ClearAllItem()
	lvItems:SetInterval(15)

	self.itemPool = {}
	local curDressItem = nil
	self:child("DressStore-Cur-Part"):SetImageUrl("http111")
	self:child("DressStore-Cur-Part"):SetImage("")

    for i, v in ipairs(items) do
        local key = i % 3
		if key == 0 then
			key = 3
		end
		if key == 1 then
			local chunkView = GUIWindowManager.instance:LoadWindowFromJSON("DressStoreItem.json")
			chunkView:SetArea({ 0, 0}, { 0, 0 }, { 1, 0 }, { 0, 124 })
			for j = 1, 3 do
				local chunkItemView = chunkView:child("DressStoreItem-Items"):GetChildByIndex(j - 1)
				chunkItemView:SetVisible(false)
			end
			lvItems:AddItem(chunkView)
		end

		local num = math.ceil(i / 3) - 1
		local itemView = lvItems:GetChildByIndex(0):GetChildByIndex(num):child("DressStoreItem-Items"):GetChildByIndex(key - 1)
		itemView:SetVisible(true)

		self:updateItemInfo(v, itemView)

		local dressItemCfg = setting:fetch("dress", v.itemName)
		local dressItemId = getCfg(dressItemCfg, "itemId")
		if dressItemId == self.curActorSkin[v.itemType] then
			curDressItem = v
		end
    end

	self:updateCurItem(curDressItem)
end

function M:updateItemInfo(item, view)
	self.itemPool[item.index] = {item = item, view = view}

	local buyView = view:GetChildByIndex(1)
	self:setCoinIcon(buyView:GetChildByIndex(0), item.coinId)
	buyView:GetChildByIndex(1):SetText(item.price)
	buyView:SetVisible(item.status == Store.itemStatus.NOT_BUY)

	local dressItemCfg = setting:fetch("dress", item.itemName)
	local pic = getCfg(dressItemCfg, "icon")

	if pic:find("http:") or pic:find("https:") then
		view:GetChildByIndex(0):SetImage("")
		view:GetChildByIndex(0):SetImageUrl(pic)
	else
		view:GetChildByIndex(0):SetImageUrl("xx")
		view:GetChildByIndex(0):SetImage(pic)
	end

	self:unsubscribe(view, UIEvent.EventButtonClick)
	self:subscribe(view, UIEvent.EventButtonClick, function()
		if item.status == Store.itemStatus.NOT_BUY then
			Me:sendTrigger(Me, "SHOW_OPERATE_DRESS_STORE_ITEM", Me, nil, { storeId = self.curPartId, itemIndex = item.index, targetIndex = 0 })
		else
			self:updateCurItem(item)
		end
    end)
end

function M:updateCurItem(item, isUnloadPart)
	self.curItem = item
	local isShowCurPart = false

	for _, v in ipairs(self.itemPool) do
		if item and item.index == v.item.index then
			v.view:SetNormalImage("set:dress.json image:store_item_choose_bg")
			v.view:SetPushedImage("set:dress.json image:store_item_choose_bg")
		else
			v.view:SetNormalImage("set:dress.json image:store_item_bg")
			v.view:SetPushedImage("set:dress.json image:store_item_bg")
		end
	end

	if item then
		local dressItemId = 0
		if isUnloadPart then
			self.actor:UseBodyPart(item.itemType, item.itemName)
			dressItemId = item.itemName
		else
			local dressItemCfg = setting:fetch("dress", item.itemName)
			local picUrl = getCfg(dressItemCfg, "icon")
			dressItemId = getCfg(dressItemCfg, "itemId")
			self.actor:UseBodyPart(item.itemType, dressItemId)
			self:child("DressStore-Cur-Part"):SetImageUrl(picUrl)
		end

		self.curActorSkin[item.itemType] = dressItemId

		if self.itemPool[item.index] then
			local buyView = self.itemPool[item.index].view:GetChildByIndex(1)
			buyView:SetVisible(item.status == Store.itemStatus.NOT_BUY)
		end

		isShowCurPart = true
	end
	self:child("DressStore-Cur-Part-Bg"):SetVisible(isShowCurPart)
end

function M:modPlayerSkin()
	Me:sendPacket({	
		pid = "ModSkin", 
		objID = Me.objID,
		skin = self.curActorSkin
	})
end

function M:onUnloadPart()
	local store = Store:getStoreById(self.curPartId)
	local type = store.items[1].itemType
	local item = {
		index = -1,
		itemType = type,
		itemName = self.appSkin[type]
	}
	if store and type then
		self:updateCurItem(item, true)
	end

	self:child("DressStore-Cur-Part"):SetImage("")
	self:child("DressStore-Cur-Part"):SetImageUrl("http111")
	self:child("DressStore-Cur-Part-Bg"):SetVisible(false)
end

function M:setCoinIcon(view, coinId)
	view:SetImage(Coin:iconByCoinId(coinId))
end