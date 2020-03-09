function M:init()
    WinBase.init(self, "Team.json", true)
    self:initTitle()
    self:initContent()
    self:initBottom()
    self:initCloseButton()

    self.waitForRequest = {}
end

function M:onOpen(info)
    self:updateTitle(info.title)
    self:updateContent()
    self:updateBottom(info.buttons)
    self:updateCloseBtn(info.closeBtn)
end

function M:initTitle()
    self.team_title = self:child("Team-Main-Title")
    self.team_title_text = self:child("Team-Main-Title-Name")
    self.team_title_button = self:child("Team-Main-Title-Button")
    self:subscribe(self.team_title_button, UIEvent.EventButtonClick, function()
        self:showChangeTeamNameUI()
    end)


    Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
		if UI:isOpen(self) and UIName == "win_team_name" then
			local name = UI:getRemoterData("win_team_name") or ""
			self.team_title_text:SetText(name)
		end
	end)

end

function M:initContent()
    self.team_content_list = self:child("Team-Main-Content-List")
    Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
        if UI:isOpen(self) and UIName == "win_team" then
            local data = UI:getRemoterData("win_team")
            if not (data and data.close) then
                self:updateContent()
            else
                -- 关闭当前的UI、切换到单人的UI
                self:closeWindow()
                
                -- todo: 内容要修改
                local info = {
                    text = "ui_family_find_member",
                    image = "set:single_family.json image:icon",
                    
                    buttons = {
                        {
                            event = "SHOW_FAMILY_ALBUM",
                            normalImage = "set:single_family.json image:greenBtn",
                            pushedImage = "set:single_family.json image:greenBtn",
                            name = "ui_family_album"
                        },
                        {
                            event = "SHOW_QUIT_FAMILY_UI",
                            normalImage = "set:single_family.json image:blueBtn",
                            pushedImage = "set:single_family.json image:blueBtn",
                            name = "ui_family_quit"
                        }
                    },

                    closeBtn = {
                        disableClose = false,
                    },
                }

                Lib.emitEvent(Event.EVENT_SHOW_SINGLE_TEAM, true, info)
            end
        end
    end)
end

function M:initBottom()
    self.team_bottom = self:child("Team-Main-Bottom")
end

function M:initCloseButton()
    self.team_closed_button = self:child("Team-Main-Close-Btn")
    self:subscribe(self.team_closed_button, UIEvent.EventButtonClick, function()
        self:closeWindow()
    end)
end

function M:updateTitle(title)
    if not title then
        return
    end
    if title.bgPic then
        self.team_title:SetImage(title.bgPic)
    end
    if title.name then
        self.team_title_text:SetText(Lang:toText(title.name))
    end
end

function M:updateContent()
    if next(self.waitForRequest) then
        return
    end
    
    self.team_content_list:ClearAllItem()
    self.team_content_list:SetInterval(2)
    local teamID = Me:getValue("teamId")
    if not teamID or teamID == 0 then
        return
    end

    local teamInfo = Game.GetAllTeamsInfo()[teamID]
    if not teamInfo then
        return
    end

    local func = function(userInfo, viewInfo)
        
        local item = GUIWindowManager.instance:LoadWindowFromJSON("TeamItems.json")
        item:SetArea({0, 0}, {0, 0}, {1, 0}, {0, 90})

        item:child("TeamItems-Name-Text"):SetText(userInfo.nickName)
        item:child("TeamItems-Teleport-Btn-Text"):SetText(Lang:toText("gui_family_teleport"))

        if userInfo.sex == 1 then
            item:child("TeamItems-gender"):SetImage("set:team.json image:boy")
        else
            item:child("TeamItems-gender"):SetImage("set:team.json image:girl")
        end

        if userInfo.picUrl and #userInfo.picUrl > 0 then
            item:child("TeamItems-Head-Pic"):SetImageUrl(userInfo.picUrl)
        end

        self:subscribe(item:child("TeamItems-Teleport-Btn"), UIEvent.EventButtonClick, function()
            Me:sendPlayerVisit(userInfo.userId, "", false)
            self:closeWindow()
        end)

        if viewInfo.values[1] == 1 then
            item:child("TeamItems-Scale"):SetImage("set:team.json image:child")
        elseif viewInfo.values[1] == 2 then
            item:child("TeamItems-Scale"):SetImage("set:team.json image:adult")
        end

        if userInfo.userId == Me.platformUserId then
            item:SetBackImage("set:team.json image:own_bg")
            item:child("TeamItems-Teleport-Btn"):SetVisible(false)
        end


        self.team_content_list:AddItem(item)

        self.waitForRequest[userInfo.objID] = nil
    end

    local playersInfo = Game.GetAllPlayersInfo()
    for objID in pairs(teamInfo.playerList) do
        local playerInfo = playersInfo[objID]
        local userInfo = UserInfoCache.GetCache(playerInfo.userId)
        if userInfo then
            userInfo.userId = playerInfo.userId
            userInfo.objID = playerInfo.objID
            self.waitForRequest[userInfo.objID] = true
            Me:sendPacket({
                pid = "QuerySimpleView",
                objID = userInfo.objID
            }, function(viewInfo)
                if viewInfo then
                    func(userInfo, viewInfo)
                end
            end)
        end
    end
end

function M:updateBottom(buttons)
    if #buttons > 0 then
        self.team_content_list:SetHeight({0.7, 0})
    else
        self.team_content_list:SetHeight({0.85, 0})
    end

    self.team_bottom:CleanupChildren()
    self.team_bottom:SetWidth({0, 228 * #buttons + 40 * (#buttons - 1)})

    for i, btn in pairs(buttons or {}) do
        local button = GUIWindowManager.instance:CreateGUIWindow1("Button", "Team-Main-Bottom-Button-" .. i)
        button:SetNormalImage(btn.normalImage or "set:team.json image:blue_btn")
        button:SetPushedImage(btn.pushedImage or "set:team.json image:blue_btn")
        button:SetVerticalAlignment(1)
        button:SetProperty("StretchType", "NineGrid")
        button:SetProperty("StretchOffset", "16 20 0 0")
        button:SetArea({ 0, (228 + 40) * (i - 1) }, { 0, 0 }, { 0, 228 }, { 0, 80 })
        self:subscribe(button, UIEvent.EventButtonClick, function()
            if btn.event then
                Me:sendTrigger(Me, btn.event, Me)
            end
        end)

        local btnText = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "Team-Main-Bottom-Button-Text-" .. i)
        btnText:SetText(Lang:toText(btn.name))
        btnText:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
        btnText:SetVerticalAlignment(1)
        btnText:SetHorizontalAlignment(1)
        btnText:SetTextHorzAlign(1)
        btnText:SetTextVertAlign(1)
        button:AddChildWindow(btnText)

        self.team_bottom:AddChildWindow(button)
    end
end

function M:updateCloseBtn(closeBtn)
    if not closeBtn then
        return
    end

    if closeBtn.disableClose then
        self.team_closed_button:SetVisible(false)
    end

    if closeBtn.normalImage then
        self.team_closed_button:SetNormalImage(closeBtn.normalImage)
    end

    if closeBtn.pushedImage then
        self.team_closed_button:SetPushedImage(closeBtn.pushedImage)
    end
end

function M:closeWindow()
    Lib.emitEvent(Event.EVENT_SHOW_TEAM, false)
end

function M:showChangeTeamNameUI()
     local packet = {
         pid = "showChangeTeamName",
         name = self.team_title_text:GetText()
     }
     Me:sendPacket(packet)
end