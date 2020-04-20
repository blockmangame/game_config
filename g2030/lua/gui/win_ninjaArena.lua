---
---忍者项目竞技场弹窗UI
---zhuyayi 20200420
---
function M:init()
    WinBase.init(self, "NinjaArena.json",false)
    self:initWnd()
end

function M:initWnd()
    self.btnClose = self:child("NinjaArena-Close")
    self.btnStart = self:child("NinjaArena-Start")

    self.txtStageTitle1 = self:child("NinjaArena-StageTitle1")
    self.txtStageTitle2 = self:child("NinjaArena-StageTitle2")

    self.lytBg = self:child("NinjaArena-Bg")
    self.imgInnerBg = self:child("NinjaArena-InnerBg")

    self.lytStageContent = self:child("NinjaArena-StageContent")
    self.lytStageBg = self:child("NinjaArena-StageBg")
    self.imgStageIcon = self:child("NinjaArena-StageIcon")
    self.lytKillBg = self:child("NinjaArena-killBg")
    self.imgKillIcon = self:child("NinjaArena-killIcon")
    self.txtStageKillTit = self:child("NinjaArena-stageKillTit")
    self.lytScoreBg = self:child("NinjaArena-scoreBg")
    self.imgScoreIcon = self:child("NinjaArena-scoreIcon")
    self.txtStageScoreTit = self:child("NinjaArena-stageScoreTit")
    self.lytListHead = self:child("NinjaArena-ListHead")

    self.txtStageKillVal = self:child("NinjaArena-stageKillVal")--本人杀人数
    self.txtStageScoreVal = self:child("NinjaArena-stageScoreVal")--本人分数
    self.txtStageNumber = self:child("NinjaArena-StageNumber")--本人阶数
    self.txtStageTitleNum = self:child("NinjaArena-StageTitleNum")--本人阶数标题

    self.txtRankName[1] = self:child("NinjaArena-firstName")--第一名名称
    self.txtRankKill[1] = self:child("NinjaArena-firstKillVal")--第一名杀人数
    self.txtRankScore[1] = self:child("NinjaArena-firstScoreVal")--第一名分数
    self.txtRankLv[1] = self:child("NinjaArena-firstLvVal")--第一名阶数

    self.txtRankName[2] = self:child("NinjaArena-secName")--第2名名称
    self.txtRankKill[2] = self:child("NinjaArena-secKillVal")--第2名杀人数
    self.txtRankScore[2] = self:child("NinjaArena-secScoreVal")--第2名分数
    self.txtRankLv[2] = self:child("NinjaArena-secLvVal")--第2名阶数

    self.txtRankName[3] = self:child("NinjaArena-3thName")--第3名名称
    self.txtRankKill[3] = self:child("NinjaArena-3thKillVal")--第3名杀人数
    self.txtRankScore[3] = self:child("NinjaArena-3thScoreVal")--第3名分数
    self.txtRankLv[3] = self:child("NinjaArena-3thLvVal")--第3名阶数


    self.grdList = self.child("NinjaArena-List")


    self:initEvent()
    self:initView()
  --  UIMgr:new_widget("topValBar"):invoke("initViewByType",HP_VAL ,{11,53},self._root)
end

function M:initEvent()
    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        self:hide()
    end)
    self:subscribe(self.btnStart, UIEvent.EventButtonClick, function()
        self:hide()
    end)
end
function M:initView()
    local stageId = 2
    self.lytBg:SetBackImage("set:ninja_arena.json image:bg_stage"..stageId.."_1")
    self.imgInnerBg:SetImage("set:ninja_arena.json image:bg_stage"..stageId.."_2")
    self.lytStageContent:SetBackImage("set:ninja_arena.json image:block_stage"..stageId.."_1")
    self.lytStageBg:SetBackImage("set:ninja_arena.json image:pos_bg_stage"..stageId)
    self.imgStageIcon:SetImage("set:ninja_arena.json image:icon_stage"..stageId)
    self.lytKillBg:SetBackImage("set:ninja_arena.json image:block_stage"..stageId.."_2")
    self.imgKillIcon:SetImage("set:ninja_arena.json image:icon_kill_stage"..stageId)
    self.txtStageKillTit:SetTextColor(stageId==1 and {0.58, 0.58, 0.87, 1} or {0.89, 0.71, 0.28, 1})
    self.lytScoreBg:SetBackImage("set:ninja_arena.json image:block_stage"..stageId.."_2")
    self.imgScoreIcon:SetImage("set:ninja_arena.json image:icon_score_stage"..stageId)
    self.txtStageScoreTit:SetTextColor(stageId==1 and {0.58, 0.58, 0.87, 1} or {0.89, 0.71, 0.28, 1})

    self.lytListHead:SetBackImage("set:ninja_arena.json image:block_stage"..stageId.."_3")

    self.btnStart:SetText(Lang:toText("gui_arena_start"))

    self.grdList:InitConfig(0, 11, 1)
    self.grdList:SetMoveAble(true)
    self.grdList:RemoveAllItems()
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
    for i = 1,3 do
        self.txtRankName[i]:SetText(self.testData[i].name)
        self.txtRankKill[i]:SetText(self.testData[i].kill)
        self.txtRankScore[i]:SetText(self.testData[i].score)
        self.txtRankLv[i]:SetText(self.testData[i].lv)
    end
    local i = 1
    for _, data in pairs(self.testData) do
        local item = UIMgr:new_widget("itemArena")
        -- local contentWidth = self.llContentGrid:GetPixelSize().x
        -- local contentHeight = self.llContentGrid:GetPixelSize().y
        -- local itemWidth = (contentWidth - 172) / 4
        -- local itemHeight = (contentHeight - 44) / 2.2
     --   self.allItems[i] = item
        item:invoke("setItemData",2, data.rank, data.name, data.kill, data.score,data.level)
        self.llContentGrid:AddItem(item)
        i = i + 1
    end
end

function M:onOpen()
end