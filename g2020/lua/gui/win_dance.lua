function M:init()
	WinBase.init(self, "Dance.json", true)
	self.remoteData = UI:getRemoterData("win_dance") or {}
	self:initMain()
end

function M:onOpen(data)
	WinBase.onOpen(self)
	self.curStoreId = World.cfg.danceStoreId or 1
	self.selectDanceViewItem = nil

	self.selectMain = nil
	self.selectDanceToMainView = nil

	self.viewPool = {}
	self.mainItemPool = {}
	self:initItems()
	self:initMainItems()
	self:initActor()
end

local function onClickSounder()
	local clickSounderSound = Player.CurPlayer:cfg().clickWinDanceSounderSound
	if clickSounderSound and clickSounderSound.path then
		TdAudioEngine.Instance():play2dSound(clickSounderSound.path, clickSounderSound.loop or false)
	end
end

function M:initMain()
	self:child("Dance-Flash-Lamp"):PlayEffect()
	self:child("Dance-Sounder-Left"):PlayEffect()
	self:subscribe(self:child("Dance-Sounder-Left-Layout"), UIEvent.EventWindowClick, function()
        onClickSounder()
    end)
	self:child("Dance-Sounder-Right"):PlayEffect()
	self:subscribe(self:child("Dance-Sounder-Right-Layout"), UIEvent.EventWindowClick, function()
        onClickSounder()
    end)
	self:child("Dance-Text"):SetText(Lang:toText("ui_dance_shop"))

    self:subscribe(self:child("Dance-Close"), UIEvent.EventButtonClick, function()
        self:onClickCloseBtn()
    end)

	Lib.subscribeEvent(Event.EVENT_UPDATE_STORE, function()
		if UI:isOpen(self) then
			--TODO
			self:initItems()
			self:initMainItems()
			if self.selectMain then
				self:clickMainItem(self.mainItemPool[self.selectMain.index])
			end
		end
	end)

	Lib.subscribeEvent(Event.EVENT_UPDATE_STORE_ITEM, function(storeId, itemIndex)
		if UI:isOpen(self) and self.curStoreId == storeId then
			--TODO
			self:initItems()
			self:initMainItems()
			if self.selectMain then
				self:clickMainItem(self.mainItemPool[self.selectMain.index])
			end
		end
	end)

	Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function (UIName)
		if UIName == "win_dance" then
			self:update(UI:getRemoterData("win_dance"))
		end
	end)

end

function M:onClickCloseBtn()
    UI:closeWnd(self)
end

function M:initActor()
	self.actor = self:child("Dance-Actor")
	local function setInfo(info)
		self.actor:UpdateSelf(1)
		self.actor:SetActor1(info.actor, "idle")
		for k, v in pairs(info.skin) do
			if k ~= "gun" then
				self.actor:UseBodyPart(k, tostring(v))
			end
		end
	end

	Me:sendPacket({
		pid = "QueryEntityViewInfo",
		objID = assert(Me.objID),
		entityType = Define.ENTITY_INTO_TYPE_PLAYER,
	}, setInfo)
end

--======================================================================================================================

function M:initItems()
	self.lvItems = self:child("Dance-Items")
	self.lvItems:InitConfig(5, 1, 3)
	local store = Store:getStoreById(self.curStoreId)
	local num = self.lvItems:GetItemCount()
	local itemX = (self.lvItems:GetPixelSize().x - 5 * 2) / 3
	local itemY = (155 * itemX) / 157
	self.viewPool = {}
	if num ~= #store.items then
		self.lvItems:RemoveAllItems()
		for i, v in ipairs(store.items) do
			local itemView = GUIWindowManager.instance:LoadWindowFromJSON("DanceItem.json")
			itemView:SetArea({ 0, 0}, { 0, 0 }, { 0, itemX }, { 0, itemY })
			self:updateItem(itemView, v, i)
			self.lvItems:AddItem(itemView)
		end
	else
		for i = 1, num do
			local itemView = self.lvItems:GetItem(i - 1)
			itemView:SetVisible(true)
			itemView:SetArea({0, 0}, { 0, 0 }, { 0, itemX }, { 0, itemY })
			self:updateItem(itemView, store.items[i], i)
		end
	end
end

function M:updateItem(view, data, index)
	view:SetBackImage("")
	view:child("DanceItem-Item"):SetVisible(true)
	view:child("DanceItem-Equip-Item"):SetVisible(false)
	view:child("DanceItem-Item-Btn"):SetVisible(false)
	local equipSign = view:child("DanceItem-Item-Equip-Sign")
	local backImg = ""

	if data.status <= Store.itemStatus.NOT_BUY then
		backImg = "set:dance.json image:not_have_bg"
	elseif data.status == Store.itemStatus.NOT_USE then
		backImg = "set:dance.json image:have_bg"
	else
		backImg = "set:dance.json image:have_bg"
	end

	equipSign:SetVisible(data.status == Store.itemStatus.IN_USE)
	view:child("DanceItem-Item"):SetBackImage(backImg)

    local skillItem = Skill.Cfg(data.itemName)
    if skillItem and skillItem.icon then
        view:child("DanceItem-Item-Action"):SetImage(skillItem:getIcon() .. "_ui")
    else
        view:child("DanceItem-Item-Action"):SetImage("")
    end

	self.viewPool[index] = { view = view, data = data}
	self:unsubscribe(view, UIEvent.EventWindowTouchDown)
	self:subscribe(view, UIEvent.EventWindowTouchDown, function()
		self:onItemClick(self.viewPool[index])
		self:playAction(data.itemName)
    end)

	self:unsubscribe(view:child("DanceItem-Item-Btn"), UIEvent.EventButtonClick)
    self:subscribe(view:child("DanceItem-Item-Btn"), UIEvent.EventButtonClick, function()
    	self:onItemOperation(data, view)
    end)

end

function M:onItemClick(viewItem)
	if viewItem.view == self.selectDanceViewItem then
		return
	else
		self:updateSelectItem(viewItem)
	end
end

function M:updateSelectItem(viewItem)
	local img = ""
	local btnImg = ""
	self.selectDanceViewItem = viewItem.view
	for _, item in pairs(self.viewPool) do
		if item.data.status <= Store.itemStatus.NOT_BUY then
			btnImg = "set:dance.json image:buy_btn"
		else
			btnImg = "set:dance.json image:equip_btn"
		end
		if item.view == viewItem.view then
			img = "set:dance.json image:choose_bg"
			if self.selectDanceToMainView  == item.view then
				btnImg = "set:dance.json image:choose_btn"
			end
		else
			if item.data.status <= Store.itemStatus.NOT_BUY then
				img = "set:dance.json image:not_have_bg"
			else
				img = "set:dance.json image:have_bg"
			end
		end
		item.view:child("DanceItem-Item"):SetBackImage(img)
		item.view:child("DanceItem-Item-Btn"):SetNormalImage(btnImg)
		item.view:child("DanceItem-Item-Btn"):SetPushedImage(btnImg)
	end
end

--======================================================================================================================

function M:update(data)
	self.remoteData = data
end

function M:getUseItems()
	local items = {}
	for _, v in ipairs(self.remoteData) do
		local item = Store:getStoreItem(self.curStoreId, v)
		table.insert(items, item)
	end
	return items
end

function M:initMainItems()
	self.mainItems = self:child("Dance-Main-Items")
	local num = self.mainItems:GetChildCount()
	local mainItemX = (self.mainItems:GetPixelSize().y * 99) / 94
	local itemInterval = (self.mainItems:GetPixelSize().x - mainItemX * 4) / 3
	local items = self:getUseItems();
	self.mainItemPool = {}
	if num ~= #items then
		self.mainItems:CleanupChildren()
		for i = 1, #items do
			local itemView = GUIWindowManager.instance:LoadWindowFromJSON("DanceItem.json")
			itemView:SetArea({0, (mainItemX + itemInterval) * (i - 1) }, { 0, 0 }, { 0, mainItemX }, { 1, 0 })
			self:setMainItem(itemView, items[i], i)
			self.mainItems:AddChildWindow(itemView)
		end
	else
		for i = 1, num do
			local itemView = self.mainItems:GetChildByIndex(i - 1)
			itemView:SetVisible(true)
			itemView:SetArea({ 0, (mainItemX + itemInterval) * (i - 1) }, { 0, 0 }, { 0, mainItemX }, { 1, 0 })
			self:setMainItem(itemView, items[i], i)
		end
	end
end

function M:setMainItem(view, data, index)
	view:child("DanceItem-Item"):SetVisible(false)
	view:child("DanceItem-Equip-Item"):SetVisible(true)
	view:child("DanceItem-Equip-Item"):SetImage("set:dance.json image:equip")

    local mainItem = {}
	mainItem.view = view
	mainItem.index = index
	self.mainItemPool[index] = mainItem


    local skillItem = Skill.Cfg(data.itemName)
    if skillItem and skillItem.icon then
        view:child("DanceItem-Equip-Item-Img"):SetImage(skillItem:getIcon() .. "_ui")
    else
        view:child("DanceItem-Equip-Item-Img"):SetImage("")
    end

	self:unsubscribe(view, UIEvent.EventWindowTouchUp)
	self:subscribe(view, UIEvent.EventWindowTouchUp, function()
		self:playAction(data.itemName)
		if self.selectMain and self.selectMain.index == index then
			return
		end
		self:clickMainItem(mainItem)
    end)
end

function M:clickMainItem(itemView)
	self:setSelectMainItem(itemView)
	self:showDanceItemInfo()
end

function M:setSelectMainItem(selectItem)
	self.selectMain = selectItem
	for _, main_item in pairs(self.mainItemPool) do
		if main_item.index == selectItem.index then
			main_item.view:child("DanceItem-Equip-Item"):SetImage("set:dance.json image:equip_choose")
		else
			main_item.view:child("DanceItem-Equip-Item"):SetImage("set:dance.json image:equip")
		end
	end
end

function M:showDanceItemInfo()
	for _, viewItem in pairs(self.viewPool) do
		local view = viewItem.view
		local data = viewItem.data
		if view then
			local items = self:getUseItems()
			local btn = view:child("DanceItem-Item-Btn")
			btn:SetVisible(true)
			local btnImg = ""
			if items[self.selectMain.index] == data then
				self.selectDanceToMainView = view
				btn:SetText("")
				btnImg = "set:dance.json image:cur_equip_btn"
				btn:child("DanceItem-Item-Btn-Choose"):SetVisible(true)
				btn:child("DanceItem-Item-Money-Buy"):SetVisible(false)
			else
				btn:child("DanceItem-Item-Btn-Choose"):SetVisible(false)
				if data.status >= 1 then
					btn:SetText("equip")
					btnImg = "set:dance.json image:equip_btn"
					btn:child("DanceItem-Item-Money-Buy"):SetVisible(false)
				else
					btn:SetText("")
					btnImg = "set:dance.json image:buy_btn"
					btn:child("DanceItem-Item-Money-Buy"):SetVisible(true)
					if data.status == Store.itemStatus.PRIVILEGE then
						btn:SetText(Lang:toText("dance_privilege_buy"))
						btn:child("DanceItem-Item-Money-Buy"):SetVisible(false)
					else
						self:setCoinIcon(btn:child("DanceItem-Item-Currency"), data.coinId)
						btn:child("DanceItem-Item-Price"):SetText(data.price)
					end
				end
			end
			btn:SetNormalImage(btnImg)
			btn:SetPushedImage(btnImg)
		end
	end
end
--======================================================================================================================
function M:onItemOperation(data, view)
	if not self.selectMain or view:child("DanceItem-Item-Btn-Choose"):IsVisible() then
		return
	end
	if data.status >= Store.itemStatus.NOT_USE then
		self:playAction(data.itemName)
		local item = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "")

        local skillItem = Skill.Cfg(data.itemName)
        if skillItem and skillItem.icon then
            item:SetImage(skillItem:getIcon() .. "_ui")
        else
            item:SetImage("set:dance.json image:action_img")
        end

		item:SetArea({0.458515, view:GetXPosition()[2]}, {0.083752, view:GetYPosition()[2]}, {0, view:GetWidth()[2]}, {0, view:GetHeight()[2]})
		self:child("Dance-Content"):AddChildWindow(item)
		Lib.uiTween(item, {
			X = {0.012009, self.selectMain.view:GetXPosition()[2]},
			Y = {0.795644, 0},
			Alpha = 1.0,
			Width = {0, self.selectMain.view:GetWidth()[2]},
			Hight = {0, self.selectMain.view:GetWidth()[2]},
		}, 13, function()
			self:child("Dance-Content"):RemoveChildWindow1(item)
		end)
		Me:SyncStoreOperation(self.curStoreId, data.index, self.selectMain.index)
	else
		Me:SyncStoreOperation(self.curStoreId, data.index, self.selectMain.index)
	end
end

function M:playAction(skillName)
	local skill = Skill.Cfg(skillName)
	if skill and skill.castAction then
		self.actor:SetSkillName(skill.castAction)
	end
end

function M:setCoinIcon(view, coinId)
	view:SetImage(Coin:iconByCoinId(coinId))
end