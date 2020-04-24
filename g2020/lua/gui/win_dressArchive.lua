function M:init()
	WinBase.init(self, "DressArchive.json", true)
	self.itemPool = {}
    self.appSkin = nil
    self.playerInfo = nil
	self.curActorSkin = {}
	self.selectArchiveIndex = nil
	self.dressStoreIds = World.cfg.dressStoreIds or nil
	self.actorScale = UI:getRemoterData("win_dressArchiveScale") or 1

	self:initMain()
	self:initDressParts()
	self:updateDressArchive()
end

function M:onOpen(isUpdateData)
	WinBase.onOpen(self)
	self:updateActor()
	self:updateNickName()
	self:updateActorScale()
	if isUpdateData then
		self:updateDressArchive()
	end
end

function M:initMain()
	self:child("DressArchive-Title"):SetText(Lang:toText("ui_dress_archive_title"))

	self.actor = self:child("DressArchive-Player-Actor")
	self.archiveItemsList = self:child("DressArchive-Item-List")

	self.modPlayerScaleBtn = self:child("DressArchive-Player-Scale-Btn")
    self.modPlayerScaleBtn:SetText(Lang:toText("ui_dress_archive_mod_scale"))
    self:subscribe(self.modPlayerScaleBtn, UIEvent.EventButtonClick, function()
        self:onModPlayerScale()
    end)

	self.addArchiveBtn = self:child("DressArchive-SaveBtn")
	self.addArchiveBtn:SetText(Lang:toText("ui_dress_archive_save"))
	self:subscribe(self.addArchiveBtn, UIEvent.EventButtonClick, function()
		self:onAddArchive()
	end)

	self:subscribe(self:child("DressArchive-Player-Name"), UIEvent.EventButtonClick, function()
		-- todo: 下个版本再打开
		--Me:sendTrigger(Me, "SHOW_CHANGE_NAME_INPUT_DIALOG", Me)
    end)

	self:subscribe(self:child("DressArchive-Close-Btn"), UIEvent.EventButtonClick, function()
        self:onClickCloseBtn()
    end)

	Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
		if UIName == "win_dressArchiveScale" then
			self.actorScale = UI:getRemoterData("win_dressArchiveScale") or 1
			if UI:isOpen(self) then
				self:updateActorScale()
				return
			end
		end

		if UI:isOpen(self) then
			if UIName == "win_dressArchive" then
				self:updateDressArchive()
			elseif UIName == "win_dressArchiveRename" then
				self:updateDressArchiveItemName()
			elseif UIName == "win_dressArchivePlayerName" then
				local name = UI:getRemoterData("win_dressArchivePlayerName") or {}
				self:child("DressArchive-Player-Name-Text"):SetText(name)
			end
		end
	end)
	
	Lib.subscribeEvent(Event.EVENT_USE_DRESS_ARCHIVE, function(index) 
		if not index then
			return
		end

		local itemData = self.itemPool[index].archive
		if self.selectArchiveIndex ~= index then
			self:updateActorDress(itemData.data.vars)
			self.selectArchiveIndex = index
			self:onSelectArchive()
			self:modPlayerSkin()
		end
	end)
end

function M:updateActor()
	local function setInfo(info)
		self.playerInfo = info
		self.actor:UpdateSelf(1)
		self.actor:SetActor1(info.actor, "idle")
		self:updateActorDress(info.skin)
	end

	Me:sendPacket({
		pid = "QueryEntityViewInfo",
		objID = assert(Me.objID),
		entityType = Define.ENTITY_INTO_TYPE_PLAYER,
	}, setInfo)
end

function M:updateNickName()
	self.playerName = Me.name
	self:child("DressArchive-Player-Name-Text"):SetText(self.playerName)
end

function M:updateActorScale()
	self.actor:SetActorScale(self.actorScale)
end

function M:onClickCloseBtn()
	Me:sendPacket({
		pid = "CloseDress"
	})
    UI:closeWnd(self)
    --self:modPlayerSkin()
end

function M:onModPlayerScale()
	Me:sendTrigger(Me, "SHOW_SELECT_ROLE", Me)
end

function M:initDressParts()
	local num = 5
	for i, id in ipairs(self.dressStoreIds) do
		if num > 0 then
			local partView = self:child("DressArchive-Dress-Parts-Bg"):GetChildByIndex(i - 1)
			local store = Store:getStoreById(id)
			partView:SetNormalImage(store.icon)
			partView:SetPushedImage(store.icon)
			self:subscribe(partView, UIEvent.EventButtonClick, function()
				UI:closeWnd(self)
				local actorSkin = {}
				for key, value in pairs(self.curActorSkin) do
					actorSkin[key] = value
				end

				if self.playerInfo then
					Lib.emitEvent(Event.EVENT_SHOW_DRESS_STORE, id, self.playerInfo, actorSkin, self.appSkin)
				end
			end)
		else
			break
		end
		num = num - 1
	end
end

function M:updateDressArchive()
	self.archiveItems = self:child("DressArchive-Info-Items-List")
	self.archiveItems:SetInterval(8)
	self.archiveItems:ClearAllItem()

	self.itemPool = {}
	self.selectArchiveIndex = nil
	local archives = UI:getRemoterData("win_dressArchive") or {}

	for i, archive in ipairs(archives) do
		self:setArchiveItem(i == #archives, archive.vars, i)
		if i == #archives then
			self.appSkin = archive.vars.data.vars
		end
	end
end

function M:setArchiveItem(isAppDress, archive, index)
	local item = GUIWindowManager.instance:CreateGUIWindow1("Layout", "listItem")
	item:SetArea({0, 10}, {0, 0}, {0.8, 0}, {0, 75})
	item:SetBackImage("set:dress.json image:archive_item_bg")
	if isAppDress then
		item:SetArea({0, 10}, {0, 0}, {0.98, 0}, {0, 75})
		item:SetBackImage("set:dress.json image:archive_item_bg2")
	end
	item:SetProperty("StretchType", "NineGrid")
	item:SetProperty("StretchOffset", "25 25 25 25")

	local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "itemBtn")
	btn:SetArea({0.23, 0}, {0, 0}, {0.3, 0}, {1, 0})
	btn:SetNormalImage("set:dress.json image:archive_item_set_bg")
	btn:SetPushedImage("set:dress.json image:archive_item_set_bg")
	btn:SetHorizontalAlignment(2)
	btn:SetVerticalAlignment(1)
	btn:SetVisible(not isAppDress)
	item:AddChildWindow(btn)

	local text = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "itemName")
	text:SetWidth({0.92, 0})
	text:SetHeight({0.8, 0})
	text:SetVerticalAlignment(1)
	text:SetTextHorzAlign(1)
	text:SetTextVertAlign(1)
	text:SetProperty("TextBorder", "true")
	text:SetText(Lang:toText(archive.name))
	text:SetTextColor({ 5 / 255, 67 / 255, 136 / 255, 1 })
	text:SetTextBoader({ 171 / 255, 237 / 255, 255 / 255, 1 })
	item:AddChildWindow(text)
	
	self.archiveItems:AddItem(item, false)

	self:unsubscribe(item, UIEvent.EventWindowTouchDown)
	self:subscribe(item, UIEvent.EventWindowTouchDown, function()
		self:clickArchive(index)
	end)

	self:unsubscribe(btn, UIEvent.EventButtonClick)
	self:subscribe(btn, UIEvent.EventButtonClick, function()
		Me:sendTrigger(Me, "SHOW_OPERATE_DRESS_ARCHIVE_INPUT_DIALOG", Me, nil, { name = archive.name, index = index})
	end)

	self.itemPool[index] = {view = item, archive = archive}
end

function M:clickArchive(index)
	local itemData = self.itemPool[index].archive
	if self.selectArchiveIndex ~= index then
		Me:sendTrigger(Me, "USE_OPERATE_DRESS_ARCHIVE_DIALOG", Me, nil, {index = index, name = itemData.name})
	end
end

function M:updateDressArchiveItemName()
	local itemData = UI:getRemoterData("win_dressArchiveRename") or {}
	local item = self.itemPool[itemData.index]
	if item then
		item.archive.name = itemData.name
		item.view:child("itemName"):SetText(Lang:toText(itemData.name))
	end
end

function M:updateActorDress(data)
	for k, v in pairs(data) do
		if k ~= "gun" then
			self.actor:UseBodyPart(k, tostring(v))
		end
	end
	self.curActorSkin = data
end

function M:onSelectArchive()
	local archives = UI:getRemoterData("win_dressArchive") or {}
	for i, item in pairs(self.itemPool) do
		if self.selectArchiveIndex == i then
			item.view:SetBackImage("set:dress.json image:archive_choose_item_bg")
			item.view:child("itemName"):SetTextColor({ 204 / 255, 72 / 255, 0 / 255, 1 })
			item.view:child("itemName"):SetTextBoader({ 251 / 255, 248 / 255, 130 / 255, 1 })
			item.view:child("itemBtn"):SetNormalImage("set:dress.json image:archive_item_choose_set_bg")
			item.view:child("itemBtn"):SetPushedImage("set:dress.json image:archive_item_choose_set_bg")

			if i == #archives then
				item.view:SetBackImage("set:dress.json image:archive_choose_item_bg2")
			end
		else
			item.view:SetBackImage("set:dress.json image:archive_item_bg")
			item.view:child("itemName"):SetTextColor({ 5 / 255, 67 / 255, 136 / 255, 1 })
			item.view:child("itemName"):SetTextBoader({ 171 / 255, 237 / 255, 255 / 255, 1 })
			item.view:child("itemBtn"):SetNormalImage("set:dress.json image:archive_item_set_bg")
			item.view:child("itemBtn"):SetPushedImage("set:dress.json image:archive_item_set_bg")

			if i == #archives then
				item.view:SetBackImage("set:dress.json image:archive_item_bg2")
			end
		end
	end
end

function M:onAddArchive()
	if (#self.itemPool - 1) < World.cfg.dressArchiveNum then
		Me:sendTrigger(Me, "ADD_DRESS_ARCHIVE_DIALOG", Me)
	else
		Client.ShowTip(2, "ui_dress_archive_can_not_add_more", 60)
	end
end

function M:modPlayerSkin()
	local index = self.selectArchiveIndex

	if index and index > 0 then
		Me:sendPacket({	
			pid = "ModSkin", 
			objID = Me.objID,
			skin = self.curActorSkin
		})
	end
end