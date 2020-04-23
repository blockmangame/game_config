---
---忍者项目主界面根UI
---包含底部功能入口，操控切换键，式神技能键，血量，锻炼值，阵营货币，蓝量
---zhuyayi 20200325
---
local EXP_VAL,SKILL_VAL = 0,0
local HP_VAL, TEAM_VAL=1,1
local A_Btn
local B_Btn
local exchangeMac = true
function M:init()
    WinBase.init(self, "NinjaMain.json",false)
    self:initWnd()
end

function M:initWnd()
    self.btnGodSkill = self:child("NinjaMain-GodSkill")
    self.btnVip = self:child("NinjaMain-VipBtn")
    self.btnTrade = self:child("NinjaMain-TradeBtn")
    self.btnSell = self:child("NinjaMain-SellBtn")
    self.btnPet = self:child("NinjaMain-PetBtn")
    self.btnExchangeCtr = self:child("NinjaMain-Exchange")
    self.effect = self:child("NinjaMain-Effect")
    self.textBottomMessage = self:child("NinjaMain-BottomMessage")
    ------竞技场状态显示------------
    self.lytArenaRank = self:child("NinjaMain-ArenaRank")
    self.grdRankList = self:child("NinjaMain-List")
    self.lytArenaRank:SetVisible(false)

    self.lytArenaCountTime = self:child("NinjaMain-ArenaCountTime")
    self.txtCountTime = self:child("NinjaMain-CountTimeVal")
    self.lytArenaCountTime:SetVisible(false)


    self.textBottomMessage:SetText("")

    self:initEvent()
    UIMgr:new_widget("topValBar"):invoke("initViewByType",HP_VAL ,{11,53},self._root)
    UIMgr:new_widget("topValBar"):invoke("initViewByType", EXP_VAL,{11,93},self._root)
    UIMgr:new_widget("TopSpVal"):invoke("initViewByType",SKILL_VAL ,{15,149},self._root)
    UIMgr:new_widget("TopSpVal"):invoke("initViewByType", TEAM_VAL,{151,149},self._root)
    self:initExtraWnd()
end

--预加载界面，用于在显示之前初始化数据
function M:initExtraWnd()
    UI:getWnd("itemShop"):initData()
    UI:getWnd("payShop"):initData()
    UI:getWnd("skillControl")
end

function M:initEvent()
    self:subscribe(self.btnSell, UIEvent.EventButtonClick, function()
        Me:sellExp(true)
        UI:openWnd("ninjaArena")
    end)
    self:subscribe(self.btnExchangeCtr, UIEvent.EventButtonClick, function()
        self:exchangeABBtn()
    end)
    self:subscribe(self.btnVip, UIEvent.EventButtonClick, function()
        self:openPayShop()
    end)

    self:subscribe(self.btnPet, UIEvent.EventButtonClick, function()
        UI:getWnd("petPackage"):openPetPackage()
    end)

    self:subscribe(self.btnTrade, UIEvent.EventButtonClick, function()
        self:openSkillControl()
    end)


    local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer
    Lib.subscribeEvent("EVENT_SHOW_BOTTOM_MESSAGE", function(message, param)
        self.textBottomMessage:SetVisible(true)
        self.textBottomMessage:SetText(message)

        if param and param.jumpCount then
            if param.jumpCount < 0 then
                local UIAnimationManager = T(UILib, "UIAnimationManager") ---@type UIAnimationManager
                UIAnimationManager:play(self.textBottomMessage, "TextColorFlicker")
            elseif param.jumpCount == 0 then
                self.textBottomMessage:SetTextColor({ 1.0,0.0,0.0,1.0 })
            else
                self.textBottomMessage:SetTextColor({ 1.0,1.0,1.0,1.0 })
            end
        end

        LuaTimer:cancel(self.hideBottomMessageTimer)
        self.hideBottomMessageTimer = LuaTimer:scheduleTimer(function()
            self.textBottomMessage:SetVisible(false)
        end, 2000, 1)
    end)

    Lib.subscribeEvent("EVENT_PLAY_GLIDING_EFFECT", function(isPlay)
        self.effect:SetVisible(isPlay)
    end)

    Lib.subscribeEvent(Event.EVENT_ARENA_UI_STATE, function()
        self:initArenaView()
    end)
end

---右侧技能按钮排版切换
function M:exchangeABBtn()
    local controlView = UI:getWnd("skills")
    A_Btn = controlView:getBtnA()
    B_Btn = controlView:getBtnB()
    local x = A_Btn:GetXPosition()
    local y = A_Btn:GetYPosition()
    local w = A_Btn:GetWidth()
    local h = A_Btn:GetHeight()
    A_Btn:SetArea(B_Btn:GetXPosition(), B_Btn:GetYPosition(), B_Btn:GetWidth(), B_Btn:GetHeight())
    B_Btn:SetArea(x,y,w,h)
    if exchangeMac then
        print("-------------in")
        exchangeMac = false
        A_Btn:SetImage("set:ninja_main.json image:btn_jump_s")
        B_Btn:SetImage("set:ninja_main.json image:btn_atk")
    else
        print("-------------out")
        exchangeMac = true
        A_Btn:SetImage("set:ninja_main.json image:btn_jump")
        B_Btn:SetImage("set:ninja_main.json image:btn_atk_s")

    end

end

---右侧技能按钮排版切换
function M:openPayShop()
    UI:getWnd("itemShop"):onShow(true)
end

function M:openSkillControl()
    UI:getWnd("skillControl"):onShow(true)
end

function M:initArenaView()
    self.btnVip:SetVisible(false)
    self.btnTrade:SetVisible(false)
    self.btnSell:SetVisible(false)
    self.btnPet:SetVisible(false)

    self.lytArenaRank:SetVisible(true)
    self.lytArenaCountTime:SetVisible(true)
    self.testData = {
        {
            rank = 1,
            name = "aaaaaa",
            kill =1234,
            score = 2234222,
            level = 4
        },
        {
            rank = 1,
            name = "aaaaaa",
            kill =1234,
            score = 2234222,
            level = 4
        },
        {
            rank = 1,
            name = "aaaaaa",
            kill =1234,
            score = 2234222,
            level = 4
        },
        {
            rank = 1,
            name = "aaaaaa",
            kill =1234,
            score = 2234222,
            level = 4
        },
        {
            rank = 1,
            name = "aaaaaa",
            kill =1234,
            score = 2234222,
            level = 4
        },
        {
            rank = 1,
            name = "aaaaaa",
            kill =1234,
            score = 2234222,
            level = 4
        },
    }
    local i = 1
    for _, data in pairs(self.testData) do
        local item = UIMgr:new_widget("itemArenaRankMainUI")
            -- local contentWidth = self.llContentGrid:GetPixelSize().x
            -- local contentHeight = self.llContentGrid:GetPixelSize().y
            -- local itemWidth = (contentWidth - 172) / 4
            -- local itemHeight = (contentHeight - 44) / 2.2
         --   self.allItems[i] = item
        item:invoke("setItemData", data.rank, data.name, data.kill)
        self.grdRankList:AddItem(item)
        i = i + 1
    end

    self.txtCountTime:SetText(Lang:toText("arena_wait_more") )
end

function M:onOpen()
end