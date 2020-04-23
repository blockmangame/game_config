---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/21 10:00
---

local curItemTable = {}
local curPlusPetPageTable = {}
local curEvolutionIconStatus = {}
local plusPetFoldTable = {}
local curPlusPetFold = -1
local plusPetFoldOpen = false

local widthPadding = 15
local heightPadding = 15
local columnNu = 2
local isShow = false

local petType = T(Define, "petType");


function M:init()
    WinBase.init(self, "NinjaPlusPetEvolution.json",false)
    self:initWnd()
    self:initAllText()
    self:initAllEvent()
end

function M:initWnd()
    self.texts = {
        strBtnText = self:child("PetEvolution-StrongText"),
        atkIntensifyNu = self:child("PetEvolution-AddNu"),
        AtkText = self:child("PetEvolution-AddName")
    }
    self.mainView = self:child("PetEvolution-PlusPetItemView")
    self.strBtn = self:child("PetEvolution-Strong")
    self.evolutionTarget = self:child("PetEvolution-Target")
    self.evolutionImg = {
        [1] = self:child("PetEvolution-Material1Img"),
        [2] = self:child("PetEvolution-Material2Img"),
        [3] = self:child("PetEvolution-Material3Img"),
        [4] = self:child("PetEvolution-Material4Img"),
        [5] = self:child("PetEvolution-Material5Img")
    }
    self.mainView:InitConfig(widthPadding, heightPadding, columnNu)
    self.closeBtn = self:child("PetEvolution-close")
    self.foldBtn =  self:child("NinjaPetPackage-PlusPetFoldBtn")
    self.foldSelAllBtn = self:child("NinjaPetPackage-PlusPetFoldSelAllBtn")
    self.foldSelAtkBtn = self:child("NinjaPetPackage-PlusPetFoldSelAtkBtn")
    self.foldSelDefBtn = self:child("NinjaPetPackage-PlusPetFoldSelDefBtn")
    self.foldSelGainBtn = self:child("NinjaPetPackage-PlusPetFoldSelGainBtn")
    self.foldCurText = self:child("NinjaPetPackage-PlusPetFoldAllText")
    self.foldSelAll = self:child("NinjaPetPackage-PlusPetFoldSelAllText")
    self.foldSelAtk = self:child("NinjaPetPackage-PlusPetFoldSelAtkText")
    self.foldSelDef = self:child("NinjaPetPackage-PlusPetFoldSelDefText")
    self.foldSelGain = self:child("NinjaPetPackage-PlusPetFoldSelGainText")
    self.foldBg = self:child("NinjaPetPackage-PlusPetFoldSelBg")
    plusPetFoldTable[0] = {
        text = self.foldSelAll,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldAllSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldAllUnSel")
        }
    }
    plusPetFoldTable[Define.plusPetSkillType.def] = {
        text = self.foldSelDef,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldDefSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldDefUnSel")
        }
    }
    plusPetFoldTable[Define.plusPetSkillType.atk] = {
        text = self.foldSelAtk,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldAtkSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldAtkUnSel")
        }
    }
    plusPetFoldTable[Define.plusPetSkillType.gain] = {
        text = self.foldSelGain,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldGainSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldGainUnSel")
        }
    }
end

function M:showPlusPetEvolution(_curPlusPetPageTable, strIndex)
    UI:openWnd("plusPetEvolution")
    isShow = true
    curPlusPetPageTable = _curPlusPetPageTable
    curPlusPetFold = -1
    curItemTable = {}
    self:clearEvolutionIcon()
    for _, v in pairs(self.evolutionImg) do
        v:SetImage("")
    end
    self:child("PetEvolution-StrButton"):SetVisible(false)
    if strIndex then
        print("=====Do Init ===== PlusEvo")
        curEvolutionIconStatus[1].isSet = true
        curEvolutionIconStatus[1].index = strIndex
        self:setPlusPetIcon(strIndex, 1)
    end
    self:setPlusPetFoldCurFold(0)
    self:refreshInfo()
end
local function turnItemIndex2PlusPetIndex(index)
    if not curItemTable[index] then
        print("Error when get \"Pet Index\" : Can not find item!!  petEvolution@gui", debug.getinfo(1).currentline)
    end
    return curPlusPetPageTable[curItemTable[index].index].index
end

local function turnPlusPetIndex2ItemIndex(index)                --没有时为nil
    for k, v in pairs(curItemTable) do
        if turnItemIndex2PlusPetIndex(k) == index then
            return k
        end
    end
end

function M:doEvolute()
    local packet = {
        pid = "plusPetEvolution",
        materials = {}
    }
    for _, v in pairs(curEvolutionIconStatus) do
        if v.isSet then
            table.insert(packet.materials, v.index)
        end
    end
    Player.CurPlayer:sendPacket(packet)
end

function M:setTargetImg(index)                  --Todo 接入更多的表现特效
    local tempData = Player.CurPlayer:getPetAttr(index)
    self.evolutionTarget:SetImage("set:ninja_pluspet.json image:" .. tostring(tempData.ID))
end

function M:removeTargetImg()
    self.evolutionTarget:SetImage("")
end

function M:evoluteSuccess(newIndex)
    local plusPetTable = UI:getWnd("petPackage").refreshPlayerInfo().plusPetTable
    self:setTargetImg(newIndex)
    self:showPlusPetEvolution(plusPetTable)
end

function M:closePlusPetEvolution()
    UI:closeWnd("plusPetEvolution")
    UI:getWnd("petPackage"):openPetPackage(nil, true)
    isShow = false
end

function M:showPlusPetFoldSel(show)
    if show then
        self:child("NinjaPetPackage-PlusPetFoldBtnDown"):SetVisible(false)
        self:child("NinjaPetPackage-PlusPetFoldBtnUp"):SetVisible(true)
        self.foldBg:SetVisible(true)
        self:child("NinjaPetPackage-PlusPetItemCover"):SetBackgroundColor({0,0,0,0.3})

    else
        self:child("NinjaPetPackage-PlusPetFoldBtnDown"):SetVisible(true)
        self:child("NinjaPetPackage-PlusPetFoldBtnUp"):SetVisible(false)
        self.foldBg:SetVisible(false)
        self:child("NinjaPetPackage-PlusPetItemCover"):SetBackgroundColor({0,0,0,0})
    end
    plusPetFoldOpen = show
end

function M:setPlusPetFoldCurFold(index)
    self:showPlusPetFoldSel(false)
    if index == curPlusPetFold then
        return
    end
    self.foldCurText:SetText(plusPetFoldTable[index].text:GetText())
    if curPlusPetFold ~= -1 then
        plusPetFoldTable[curPlusPetFold].bg.sel:SetVisible(false)
        plusPetFoldTable[curPlusPetFold].bg.unsel:SetVisible(true)
    end
    plusPetFoldTable[index].bg.sel:SetVisible(true)
    plusPetFoldTable[index].bg.unsel:SetVisible(false)
    curPlusPetFold = index
    self:setAllItems()
end

function M:initAllEvent()
    self:subscribe(self.closeBtn, UIEvent.EventButtonClick, function()
        self:closePlusPetEvolution()
    end)
    self:subscribe(self.strBtn, UIEvent.EventButtonClick, function()
        self:doEvolute()
    end)
    self:subscribe(self.foldBtn, UIEvent.EventButtonClick, function()
        self:showPlusPetFoldSel(not plusPetFoldOpen)
    end)
    self:subscribe(self.foldSelAllBtn, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(0)
    end)
    self:subscribe(self.foldSelAtkBtn, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(Define.plusPetSkillType.atk)
    end)
    self:subscribe(self.foldSelDefBtn, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(Define.plusPetSkillType.def)
    end)
    self:subscribe(self.foldSelGainBtn, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(Define.plusPetSkillType.gain)
    end)
end

function M:initAllText()
    self.texts.strBtnText:SetText(Lang:toText("PetEvolution-BeginStr"))
    self.texts.AtkText:SetText("PetEvolution-Atk")
    self.texts.atkIntensifyNu:SetText("")
    self.foldSelAll:SetText(Lang:toText("PetPackage-All"))
    self.foldSelAtk:SetText(Lang:toText("PetPackage-Atk"))
    self.foldSelDef:SetText(Lang:toText("PetPackage-Def"))
    self.foldSelGain:SetText(Lang:toText("PetPackage-Gain"))
end

function M:refreshInfo()
    local atkNu = 0
    local materialNu = 0
    for _, v in pairs(curEvolutionIconStatus) do
        if v.isSet then
            local tempData = Player.CurPlayer:getPetAttr(v.index)
            if tempData.petType == petType.pet then
                print("ERROR!!!!! WRONG PET TYPE!!!! Evolution terminate!!!!!!")        --Todo 改为弹出提示框
                self:closePlusPetEvolution()
                return
            end
            atkNu = tempData.intensifyATK + atkNu
            materialNu = materialNu + 1
        end
    end
    self.texts.atkIntensifyNu:SetText(tostring(materialNu) .. "%")

    if materialNu >= 2 then
        self:child("PetEvolution-StrButton"):SetVisible(true)
    else
        self:child("PetEvolution-StrButton"):SetVisible(false)
    end
end

function M:setPlusPetIcon(index, pos)
    self:removeTargetImg()
    local tempData = Player.CurPlayer:getPetAttr(index)
    self.evolutionImg[pos]:SetImage("set:ninja_pluspet.json image:" .. tostring(tempData.ID))
end

function M:itemOnSel(index)
    local _index = turnItemIndex2PlusPetIndex(index)
    for k, v in pairs(curEvolutionIconStatus) do
        if not v.isSet then
            curItemTable[index].item:invoke("evoSel")
            curItemTable[index].isSet = true
            curEvolutionIconStatus[k].isSet = true
            curEvolutionIconStatus[k].index = turnItemIndex2PlusPetIndex(index)
            self:setPlusPetIcon(_index, k)
            self:refreshInfo()
            return
        end
    end
    -- Todo 弹出强化栏已满的提示
end

function M:itemUnSel(index)
    for k, v in pairs(curEvolutionIconStatus) do
        if v.isSet and turnPlusPetIndex2ItemIndex(v.index) == index then
            curEvolutionIconStatus[k].isSet = false
            curEvolutionIconStatus[k].index = -1
            curItemTable[index].item:invoke("evoUnSel")
            curItemTable[index].isSet = false
            self.evolutionImg[k]:SetImage("")
            self:refreshInfo()
            return
        end
    end
    print("Can not find itemIndex to UnSel Check Plz ....")
end

function M:clearEvolutionIcon()
    curEvolutionIconStatus = {
        [1] = {isSet = false, index = -1},
        [2] = {isSet = false, index = -1},
        [3] = {isSet = false, index = -1},
        [4] = {isSet = false, index = -1},
        [5] = {isSet = false, index = -1}
    }
end

local function isItemSelected(index)
    for _, v in pairs(curEvolutionIconStatus) do
        if v.isSet then
            if v.index == index then
                return true
            end
        end
    end
end

function M:setAllItems()
    curItemTable = {}
    self.mainView:RemoveAllItems()
    local itemWith = (self.mainView:GetPixelSize().x - widthPadding) / columnNu
    for k, v in pairs(curPlusPetPageTable) do
        if curPlusPetFold == 0 or curPlusPetFold == v.data.skillType then
            local item = UIMgr:new_widget("petPackagePetItem")
            item:SetArea({ 0, 0 }, { 0, 0 }, { 0, itemWith }, { 0, itemWith })
            item:invoke("initShow", v.data.ID, v.data.petType, v.data.rank, v.data.level, true)
            table.insert(curItemTable, {item = item, index = k, isSet = isItemSelected(v.index)})
            print("Item Nu:", k, "Is Set?", isItemSelected(v.index))
            self.mainView:AddItem(item)
        end
    end
    for k, v in pairs(curItemTable) do
        if v.isSet then
            v.item:invoke("evoSel")
        end
        if  curPlusPetPageTable[v.index].data.timeLimit == -1 then          --时限式神无点击事件
            self:subscribe(v.item, UIEvent.EventWindowClick, function ()
                if v.isSet then
                    self:itemUnSel(k)
                else
                    self:itemOnSel(k)
                end
            end)
        else
            -- v.item:invoke("")        Todo 时限资源出了之后对widget的相关调用设置
        end
    end
end


return M