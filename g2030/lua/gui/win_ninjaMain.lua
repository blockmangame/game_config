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

    self:initEvent()
    UIMgr:new_widget("topValBar"):invoke("initViewByType",HP_VAL ,{11,53},self._root)
    UIMgr:new_widget("topValBar"):invoke("initViewByType", EXP_VAL,{11,93},self._root)
    UIMgr:new_widget("TopSpVal"):invoke("initViewByType",SKILL_VAL ,{15,149},self._root)
    UIMgr:new_widget("TopSpVal"):invoke("initViewByType", TEAM_VAL,{151,149},self._root)
    self:initExtraWnd()
end

--预加载界面，用于在显示之前初始化数据
function M:initExtraWnd()
    UI:getWnd("itemShop")
end

function M:initEvent()
    self:subscribe(self.btnSell, UIEvent.EventButtonClick, function()
        Me:sellExp()
    end)
    self:subscribe(self.btnExchangeCtr, UIEvent.EventButtonClick, function()
        self:exchangeABBtn()
    end)
    self:subscribe(self.btnVip, UIEvent.EventButtonClick, function()
        self:openPayShop()
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
        A_Btn:SetImage("set:ninja_main.json image:btn_atk_s")
        B_Btn:SetImage("set:ninja_main.json image:btn_jump")
    else
        print("-------------out")
        exchangeMac = true
        A_Btn:SetImage("set:ninja_main.json image:btn_atk")
        B_Btn:SetImage("set:ninja_main.json image:btn_jump_s")

    end

end

---右侧技能按钮排版切换
function M:openPayShop()
    local itemShop = UI:getWnd("itemShop"):onShow(true)
end

function M:onOpen()
end