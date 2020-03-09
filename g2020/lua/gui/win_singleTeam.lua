function M:init()
    WinBase.init(self, "SingleTeam.json", false)
    self:initTextLayout()
    self:initImage()
    self:initBottom()
    self:initCloseBtn()
end

function M:onOpen(info)
    self:updateText(info.text)
    self:updateImage(info.image)
    self:updateBottom(info.buttons)
    self:updateCloseBtn(info.closeBtn)
end

function M:initTextLayout()
    self.text = self:child("SingleTeam-Main-TextLayout-Text")

    Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
        if UI:isOpen(self) and UIName == "win_single_team" then
            local data = UI:getRemoterData("win_single_team")
            if data and data.close then
                -- 关闭当前的UI、切换到多人的组队UI
                self:onBtnClose()
                
                local title = data.title or "gui_my_family"

                local buttons = {
                    {
                        event = "SHOW_FAMILY_ALBUM",
                        normalImage = "set:team.json image:blue_btn",
                        pushedImage = "set:team.json image:blue_btn",
                        name = "ui_family_album"
                    },
                    {
                        event = "SHOW_QUIT_FAMILY_UI",
                        normalImage = "set:team.json image:green_btn",
                        pushedImage = "set:team.json image:green_btn",
                        name = "ui_family_quit"
                    }
                }

                local closeBtn = {
                    disableClose = false
                }
        
                local info = {
                    title = title,
                    buttons = buttons,
                    closeBtn = closeBtn
                }
            
                Lib.emitEvent(Event.EVENT_SHOW_TEAM, true, info)

            end
        end
    end)

end

function M:initImage()
    self.image = self:child("SingleTeam-Main-Image")
end

function M:initBottom()
    self.bottom = self:child("SingleTeam-Main-Bottom")
end

function M:initCloseBtn()
    self.closeBtn = self:child("SingleTeam-CloseBtn")
    self:subscribe(self.closeBtn, UIEvent.EventButtonClick, function()
        self:onBtnClose()
    end)
end

function M:onBtnClose()
    Lib.emitEvent(Event.EVENT_SHOW_SINGLE_TEAM, false)
end

function M:updateText(text)
    if not text then
        return
    end

    self.text:SetText(Lang:toText(text))
end


function M:updateImage(image)
    if not image then
        return
    end

    self.image:SetImage(image)
end


function M:updateBottom(buttons)
    if not buttons or #buttons <= 0 then
        return
    end

    self.bottom:CleanupChildren()
    self.bottom:SetWidth({0, 228 * #buttons + 40 * (#buttons - 1)})

    for i, btn in pairs(buttons or {}) do
        local button = GUIWindowManager.instance:CreateGUIWindow1("Button", "Team-Main-Bottom-Button-" .. i)
        button:SetNormalImage(btn.normalImage or "set:single_family.json image:greenBtn")
        button:SetPushedImage(btn.pushedImage or "set:single_family.json image:greenBtn")
        button:SetVerticalAlignment(1)
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

        self.bottom:AddChildWindow(button)
    end
end

function M:updateCloseBtn(closeBtn)
    if not closeBtn then
        return
    end

    if closeBtn.disableClose then
        self.closeBtn:SetVisible(false)
    end

    if closeBtn.normalImage then
        self.closeBtn:SetNormalImage(closeBtn.normalImage)
    end

    if closeBtn.pushedImage then
        self.closeBtn:SetPushedImage(closeBtn.pushedImage)
    end
end