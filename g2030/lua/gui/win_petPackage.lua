---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/14 11:01
---
-- Todo 更安全的数据检查，。。。。
local petType = T(Define, "petType");

local curPetPageTable = {}
local curPlusPetPageTable = {}
local curPage = 1       --1 PetPage 2 PlusPetPage
local curPetPage = 1

--  ====================== 每次显示背包都需要还原的值
local curPlusPetSelItemIndex = -1
local curPetSelItemIndex = -1
local curPlusPetUsingItem = -1
local curPetUsingItem = {}
local curPetItemTable = {}
local plusPetFoldTable = {}
local plusPetHadID = {} --记录当前玩家打开背包时所拥有的式神（主式神ID）
local curPlusPetItemTable = {}

local curPlusPetFold = -1--0 All 1 Atk 2 Def 3 Gain  Define.plusPetSkillType
local plusPetFoldOpen = false

local player = nil
function M:visible()
    return self.isVisible;
end

function M:init()
    WinBase.init(self, "NinjaPetPackage.json", false)
    self:initWnd()
end

function M:showPlusPetFoldSel(show)
    if show then
        self:child("NinjaPetPackage-PlusPetFoldBtnDown"):SetVisible(false)
        self:child("NinjaPetPackage-PlusPetFoldBtnUp"):SetVisible(true)
        self.plusPetLayout.plusPetFoldBg:SetVisible(true)
        self:child("NinjaPetPackage-PlusPetItemCover"):SetBackgroundColor({0,0,0,0.3})

    else
        self:child("NinjaPetPackage-PlusPetFoldBtnDown"):SetVisible(true)
        self:child("NinjaPetPackage-PlusPetFoldBtnUp"):SetVisible(false)
        self.plusPetLayout.plusPetFoldBg:SetVisible(false)
        self:child("NinjaPetPackage-PlusPetItemCover"):SetBackgroundColor({0,0,0,0})
    end
    plusPetFoldOpen = show
end

function M:showPetInterface(index)
    curPetItemTable = {}
    curPetUsingItem = {}
    curPetSelItemIndex = -1
    self.selSwitchImage.petSel:SetVisible(true)
    self.selSwitchImage.petUnSel:SetVisible(false)
    self.selSwitchImage.pPetUnSel:SetVisible(true)
    self.selSwitchImage.pPetSel:SetVisible(false)

    self.mainLayout.petLayout:SetVisible(true)
    self.mainLayout.plusPetLayout:SetVisible(false)
    curPage = 1
    self:setPetItem(index)
    self:refreshPageInfo()
    self:refreshPetLeftDetailInfo()
end

function M:showPlusPetInterface()
    curPlusPetItemTable = {}
    curPetSelItemIndex = -1
    curPlusPetUsingItem = -1
    curPlusPetFold = -1
    self.selSwitchImage.petSel:SetVisible(false)
    self.selSwitchImage.petUnSel:SetVisible(true)
    self.selSwitchImage.pPetUnSel:SetVisible(false)
    self.selSwitchImage.pPetSel:SetVisible(true)
    self:setPlusPetFoldCurFold(0)
    self.mainLayout.petLayout:SetVisible(false)
    self.mainLayout.plusPetLayout:SetVisible(true)

    curPage = 2
end

function M:setPlusPetFoldCurFold(index)
    curPlusPetSelItemIndex = -1
    self:showPlusPetFoldSel(false)
    if index == curPlusPetFold then
        return
    end
    self.plusPetLayoutText.plusPetFoldCur:SetText(plusPetFoldTable[index].text:GetText())
    if curPlusPetFold ~= -1 then
        plusPetFoldTable[curPlusPetFold].bg.sel:SetVisible(false)
        plusPetFoldTable[curPlusPetFold].bg.unsel:SetVisible(true)
    end
    plusPetFoldTable[index].bg.sel:SetVisible(true)
    plusPetFoldTable[index].bg.unsel:SetVisible(false)
    curPlusPetFold = index
    self:setPlusPetItem()
    self:setPlusPetItemSel(1)
end

function M:setPlusPetDetail(index, using)
    local tempData = curPlusPetItemTable[index]
    local plusPetData;
    if tempData.had == false then
        plusPetData = Player.getPetCfg(petType.plusPet, tempData.index)
        if not plusPetData then
            print("================get plus pet data wrong!!! =================")
            return
        end
        self.plusPetLayoutText.plusPetLevelNu:SetText("Lv.???")
        self.plusPetLayoutText.plusPetDefNu:SetText("???")
        self:child("NinjaPetPackage-PlusPetInfoBtns"):SetVisible(false)
        self:child("NinjaPetPackage-PlusPetAccess"):SetVisible(true)
    else
        plusPetData = Player.CurPlayer:getPetAttr(curPlusPetPageTable[tempData.index].index)
        if not plusPetData then
            print("================get plus pet data wrong!!! =================")
            return
        end
        self.plusPetLayoutText.plusPetLevelNu:SetText("Lv." .. tostring(plusPetData.level))
        self.plusPetLayoutText.plusPetDefNu:SetText(tostring(plusPetData.reductionInjury * 100) .. "%")
        self:child("NinjaPetPackage-PlusPetInfoBtns"):SetVisible(true)
        self:child("NinjaPetPackage-PlusPetAccess"):SetVisible(false)
        if using then
            self.plusPetLayoutText.plusPetEquipBtn:SetText(Lang:toText("PetPackage-deEquip"))
        else
            self.plusPetLayoutText.plusPetEquipBtn:SetText(Lang:toText("PetPackage-Equip"))
        end
    end

    self.plusPetLayout.plusPetActor:SetActor1(plusPetData.actorName)
    self.plusPetLayoutText.plusPetName:SetText(plusPetData.multiLang)
    self.plusPetLayout.plusPetQuality:SetImage("set:ninja_pet.json image:quality-" .. tostring(plusPetData.rank))
    self.plusPetLayout.plusPetSkillTypeIcon:SetImage("set:ninja_pluspet.json image:skilltype-" .. tostring(plusPetData.skillType))
    self.plusPetLayoutText.plusPetSkillInfo:SetText(plusPetData.skillInfo)
    self.plusPetLayoutText.plusPetAtkNu:SetText(tostring(plusPetData.atkBuffNum * 100) .. "%")
end

local function plusPetIndex2ItemIndex(index)
    for k, v in pairs(curPlusPetItemTable) do
        if curPlusPetPageTable[v.index] and curPlusPetPageTable[v.index].index == index then
            return k
        end
    end
end

local function plusPetItemIndex2Index(itemIndex)
    if not curPlusPetItemTable[itemIndex] then
        print("Error When Equip Plus Pet @ win_petPackage@gui", debug.getinfo(1).currentline)
        return
    end
    local localDataIndex = curPlusPetItemTable[curPlusPetSelItemIndex].index
    if not curPlusPetPageTable[localDataIndex] then
        print("Error When Get Local Data @ win_petPackage@gui", debug.getinfo(1).currentline)
        return
    end
    return curPlusPetPageTable[localDataIndex].index
end

function M:setPlusPetItemSel(index)
    if index == curPlusPetSelItemIndex then
        return
    end
    if curPlusPetSelItemIndex ~= -1 then
        curPlusPetItemTable[curPlusPetSelItemIndex].item:invoke("unsel")
    end
    curPlusPetItemTable[index].item:invoke("sel")
    self:setPlusPetDetail(index, index == curPlusPetUsingItem)
    curPlusPetSelItemIndex = index
end

-- Todo 显示PlusPetPage时，在设置完item后检测装备情况

function M:setPlusPetItemDeEquip(_index)
    local index = plusPetIndex2ItemIndex(_index)
    if not index then
        print("Get Index Fail", debug.getinfo(1).currentline)
        print(Lib.v2s())
        return
    end
    curPlusPetItemTable[_index].item:invoke("unUsing")
    Player.CurPlayer:recallPet(index)
    self.plusPetLayoutText.plusPetEquipBtn:SetText(Lang:toText("PetPackage-Equip"))
end

function M:setPlusPetItemEquip()
    local index = plusPetItemIndex2Index(curPlusPetSelItemIndex)
    if curPlusPetUsingItem ~= -1 then
        self:setPlusPetItemDeEquip(curPlusPetUsingItem)
    end
    curPlusPetUsingItem = curPlusPetSelItemIndex
    if not index then
        print("Get Index Fail", debug.getinfo(1).currentline)
        return
    end
    curPlusPetItemTable[curPlusPetSelItemIndex].item:invoke("using")
    Player.CurPlayer:callPet(index, 3)
    self.plusPetLayoutText.plusPetEquipBtn:SetText(Lang:toText("PetPackage-deEquip"))
end

function M:_setPlusPetItem(had, v, equipped)
    local itemBroadInfo = {
        width = (self.plusPetLayout.plusPetItem:GetPixelSize().x - 10) / 2
    }
    itemBroadInfo.height = itemBroadInfo.width
    local plusPetIcon = UIMgr:new_widget("petPackagePetItem")
    plusPetIcon:SetArea({ 0, 0 }, { 0, 0 }, { 0, itemBroadInfo.width }, { 0, itemBroadInfo.height })
    plusPetIcon:invoke("initShow", v.ID, v.petType ,v.rank, v.level, had)
    if equipped then
        plusPetIcon:invoke("using")
    end
    table.insert(curPlusPetItemTable,{index = v.k, had = had, item = plusPetIcon})      -- index为式神index，和式神主id（当had为false时）
    self.plusPetLayout.plusPetItem:AddItem(plusPetIcon)
end

function M:setUnlockPlusPetItem()
    for k, v in pairs(curPlusPetPageTable) do
        if curPlusPetFold == 0 or curPlusPetFold == v.data.skillType then
            if  Player.CurPlayer.equipPetList[3] and Player.CurPlayer.equipPetList[3].index == v.index then
                self:_setPlusPetItem(true, {ID = v.data.ID, petType = v.data.petType, rank = v.data.rank, level = v.data.level, k = k}, true)
                curPlusPetUsingItem = k
            else
                self:_setPlusPetItem(true, {ID = v.data.ID, petType = v.data.petType, rank = v.data.rank, level = v.data.level, k = k})
            end
        end
    end
end

function M:setLockPlusPetItem(model)
    for i = 1,Define.plusPetNu do
        if plusPetHadID[i].had == false then
            local cfg = Entity.GetCfg(Player.turnID2Plugin(Define.petType.plusPet, plusPetHadID[i].ID, 0))
            if curPlusPetFold == 0 or curPlusPetFold == cfg.skillType then
                self:_setPlusPetItem(false, {ID = plusPetHadID[i].ID, petType = cfg.petType, rank = cfg.rank, level = 0, k = plusPetHadID[i].ID, })
            end
        end
    end
end

function M:setPlusPetItem()
    curPlusPetItemTable = {}
    self.plusPetLayout.plusPetItem:SetMoveAble(true)
    self.plusPetLayout.plusPetItem:RemoveAllItems()
    self:setUnlockPlusPetItem()
    self:setLockPlusPetItem()
    for k, v in pairs(curPlusPetItemTable) do
        self:subscribe(v.item, UIEvent.EventWindowClick, function()
            self:setPlusPetItemSel(k)
        end)
    end
end

function M:refreshPetLeftDetailInfo()
    local slotsNu = 0
    local totalCoinRate = 0
    local totalFuRate = 0
    local totalChiRate = 0
    for k,v in pairs(Player.CurPlayer.equipPetList) do
        if k == 3 then
            break
        end
        slotsNu = slotsNu + 1
        local tempData = Player.CurPlayer:getPetAttr(v.index)
        if not tempData then
            print("Set Pet Left Detail Page ERROR!! INFO: GET NIL PET DETAIL INFO INDEX:", v.index)
            return
        end
        totalCoinRate = tempData.coinTransRatio + totalCoinRate
        totalChiRate = tempData.exerciseRatio + totalChiRate
        totalFuRate = tempData.chiTransRatio + totalFuRate
    end

    self.petLayoutText.slotsText:SetText(Lang:toText("PetPackage-Slots").. ":" .. tostring(slotsNu) .. "/" .. tostring(2))
    self.petLayoutText.petInfo.petTotalChi:SetText("x" .. tostring(totalChiRate))
    self.petLayoutText.petInfo.petTotalCoin:SetText("x" .. tostring(totalCoinRate))
    self.petLayoutText.petInfo.petTotalFu:SetText("x" .. tostring(totalFuRate))
end

function M:setPetPage(page, curSelIndex)
    print("SET PAGE !!!!:", page, curSelIndex)
    curPetUsingItem = {}    --每次加载页面这个表就回被刷新，当页面不同时为空
    curPetItemTable = {}
    curPetSelItemIndex = -1
    self.petLayout.petItems:RemoveAllItems()
    local itemBroadInfo = {
        width = (self.petLayout.petItems:GetPixelSize().x - 20 * 3) / 4
    }
    itemBroadInfo.height = itemBroadInfo.width
    for i = (page == 1 and 1 or (12 * (page - 1) + 1)), 12 * page do
        if curPetPageTable[i] then
            local petIcon = UIMgr:new_widget("petPackagePetItem")
            petIcon:SetArea({ 0, 0 }, { 0, 0 }, { 0, itemBroadInfo.width }, { 0, itemBroadInfo.height })
            petIcon:invoke("initShow", curPetPageTable[i].data.ID, curPetPageTable[i].data.petType, curPetPageTable[i].data.rank, curPetPageTable[i].data.level)
            if Player.CurPlayer.equipPetList[1] and Player.CurPlayer.equipPetList[1].index == curPetPageTable[i].index then
                petIcon:invoke("using")
                table.insert(curPetUsingItem, (page == 1 and i or i - (12 * (page - 1))))       --更正index为<=12的值(修正页面记数所带来的索引误差)
            end
            if Player.CurPlayer.equipPetList[2] and Player.CurPlayer.equipPetList[2].index == curPetPageTable[i].index then
                petIcon:invoke("using")
                table.insert(curPetUsingItem, (page == 1 and i or i - (12 * (page - 1))))
            end
            table.insert(curPetItemTable, {index = curPetPageTable[i].index, item = petIcon})
            self.petLayout.petItems:AddItem(petIcon)
        else
            break
        end
    end
    curPetPage = page
    for k,v in pairs(curPetItemTable) do
        self:subscribe(v.item, UIEvent.EventWindowClick, function ()
            self:setPetItemSel(k)
        end)
    end
    self:setPetItemSel(curSelIndex or 1)
    self:refreshPageInfo()
end

local function petItemIndex2Index(itemIndex)
    if not curPetItemTable[itemIndex] then
        print("Error When Equip Pet @ win_petPackage@gui", debug.getinfo(1).currentline)
    end
    return curPetItemTable[itemIndex].index
end

local function petIndex2ItemIndex(index)
    if not index then
        return
    end
    for k,v in pairs(curPetItemTable) do
        if v.index == index then
            return k
        end
    end
end

function M:petPageDetailEmpty()
    self.petLayoutText.petInfo.petLevel:SetText("")
    self.petLayoutText.petInfo.petName:SetText("")
    self.petLayoutText.petInfo.petAddFuText:SetText("")
    self.petLayoutText.petInfo.petAddCoinText:SetText("")
    self.petLayoutText.petInfo.petAddChiText:SetText("")
    self.petLayout.petImage:SetImage("")
    self:child("NinjaPetPackage-PetUpGradeBtn"):SetVisible(false)
    self:child("NinjaPetPackage-PetSellBtn"):SetVisible(false)
    self:child("NinjaPetPackage-PetDetailEquip"):SetVisible(false)
    self.petLayout.petQuality:SetVisible(false)

end

function M:setPetItemSel(index)
    if index == curPetSelItemIndex then
        return
    end
    if curPetSelItemIndex ~= -1 then
        curPetItemTable[curPetSelItemIndex].item:invoke("unsel")
    end
    if not curPetItemTable[index] then
        print("Pet  No Such  INDEX EXIST===========\n Maybe user don't have any pet.....")
        self:petPageDetailEmpty()
        return
    end
    self:child("NinjaPetPackage-PetUpGradeBtn"):SetVisible(true)
    self:child("NinjaPetPackage-PetSellBtn"):SetVisible(true)
    self:child("NinjaPetPackage-PetDetailEquip"):SetVisible(true)
    curPetItemTable[index].item:invoke("sel")
    curPetSelItemIndex = index
    local tempData = Player.CurPlayer.equipPetList[1]
    if tempData then
        if petIndex2ItemIndex(tempData.index) == index then
            self:setPetDetail(index, true)
            return
        end
    end
    tempData = Player.CurPlayer.equipPetList[2]
    if tempData then
        if petIndex2ItemIndex(tempData.index) == index then
            self:setPetDetail(index, true)
            return
        end
    end
    self:setPetDetail(index)
end

function M:setPetItem(index)
    self.petLayout.petItems:SetMoveAble(false)
    if not index then
        self:setPetPage(1)
    else
        local curIndex = nil
        for k, v in pairs(curPetPageTable) do
            if v.index == index then
                curIndex = k
                break
            end
        end
        local curPage = 1
        local curSelItemIndex = 1
        if not curIndex then
            print("Specify Index fail do default")
        else
            if curIndex > 12 then
                curPage = math.floor(curIndex / 12) + 1
            else
                curPage = 1
            end
            curSelItemIndex = curIndex % 12
        end
        self:setPetPage(curPage, curSelItemIndex)
    end
end

function M:setPetDetail(index, equipped)              --通过index拿到所有配置信息
    local tempData = Player.CurPlayer:getPetAttr(petItemIndex2Index(index))
    if not tempData then
        print("Fail to get pet Info win_petPackage@gui", debug.getinfo(1).currentline)
    end
    self.petLayoutText.petInfo.petLevel:SetText(tostring(tempData.level))
    self.petLayoutText.petInfo.petName:SetText(Lang:toText(tempData.multiLang))
    if equipped then
        self.petLayoutText.petInfo.petEquipText:SetText(Lang:toText("PetPackage-deEquip"))
    else
        self.petLayoutText.petInfo.petEquipText:SetText(Lang:toText("PetPackage-Equip"))
    end
    self.petLayout.petImage:SetImage("set:ninja_pet.json image:" .. tostring(tempData.ID))
    self.petLayout.petQuality:SetVisible(true)
    self.petLayout.petQuality:SetImage("set:ninja_pet.json image:quality-" .. tostring(tempData.rank))
    self.petLayoutText.petInfo.petAddChiText:SetText("x" .. tostring(tempData.exerciseRatio) .. Lang:toText("PetChiText"))
    self.petLayoutText.petInfo.petAddCoinText:SetText("x" .. tostring(tempData.coinTransRatio) .. Lang:toText("PetCoinText"))
    self.petLayoutText.petInfo.petAddFuText:SetText("x" .. tostring(tempData.chiTransRatio) .. Lang:toText("PetFuText"))

end

function M:refreshPageInfo()
    self.petLayoutText.petPageText:SetText(Lang:toText("PetPage") .. ": " .. tostring(curPetPage) .. "/" .. tostring(Player.CurPlayer:getValue("petPageNu")))
end

function M:setPetDeEquip(index)
    local tempIndex = petItemIndex2Index(index)
    if not tempIndex then
        print("Get Pet Index Fail!!! @", debug.getinfo(1).currentline)
        return
    end
    Player.CurPlayer:recallPet(tempIndex)
    curPetItemTable[index].item:invoke("unUsing")
    self.petLayoutText.petInfo.petEquipText:SetText(Lang:toText("PetPackage-Equip"))
    for k, v in pairs(curPetUsingItem) do
        if v == index then
            curPetUsingItem[k] = nil
            break
        end
    end
end

function M:setPetEquip(index)
    local tempIndex = petItemIndex2Index(index)
    if not tempIndex then
        print("Get Pet Index Fail!!! @", debug.getinfo(1).currentline)
        return
    end
    table.insert(curPetUsingItem, index)
    if not Player.CurPlayer.equipPetList[1] then
        Player.CurPlayer:callPet(tempIndex, 1)
        goto SetSuccess
    end
    if not Player.CurPlayer.equipPetList[2] then
        Player.CurPlayer:callPet(tempIndex, 2)
        goto SetSuccess
    end
    -- Todo 显示提醒装备栏以满，要求卸载后再装备
    do
        return
    end
    ::SetSuccess::
    curPetItemTable[index].item:invoke("using")
    self.petLayoutText.petInfo.petEquipText:SetText(Lang:toText("PetPackage-deEquip"))
end

local function petListSort(_itemA, _itemB)
    local itemA = _itemA.data
    local itemB = _itemB.data
    if itemA.rank > itemB.rank then             --品质越高的越靠前
        return true
    end
    if itemA.rank < itemB.rank then
        return false
    end
    if itemA.level > itemB.level then           --等级越高的越靠前
        return true
    end
    if itemA.level < itemB.level then
        return false
    end
    if itemA.orderWeight > itemB.orderWeight then --顺序值越高的越靠前
        return true
    end
    return false
end

local function plusPetLockSort(itemA, itemB)
    local cfgA = Player.getPetCfg(petType.plusPet, itemA.ID)
    local cfgB = Player.getPetCfg(petType.plusPet, itemB.ID)
    if cfgA.rank > cfgB.rank then             --品质越高的越靠前
        return true
    end
    if cfgA.rank < cfgB.rank then
        return false
    end
    if cfgA.orderWeight > cfgB.orderWeight then --顺序值越高的越靠前
        return true
    end
    return false
end

local function getPlayerInfo()
    plusPetHadID = {}
    curPlusPetPageTable = {}
    curPetPageTable = {}
    for i = 1, Define.plusPetNu do
        table.insert(plusPetHadID, {ID = i, had = false})
    end

    if player == nil then
        player = Player.CurPlayer
    end
    for k, v in pairs(player:getValue("allPetAttr")) do
        local tempData = player:getPetAttr(k)
        if v.petType == petType.pet then
            table.insert(curPetPageTable, {data = tempData, index = k})
        else
            table.insert(curPlusPetPageTable, {data = tempData, index = k})
            if plusPetHadID[tempData.ID].had == false then
                plusPetHadID[tempData.ID].had = true
            end
        end
    end
    table.sort(curPetPageTable, petListSort)
    table.sort(curPlusPetPageTable, petListSort)
    table.sort(plusPetHadID, plusPetLockSort)
end

function M.refreshPlayerInfo()
    getPlayerInfo()
    return {petTable = curPetPageTable, plusPetTable = curPlusPetPageTable}
end

function M:_openPetPackage(index, isPlusPet)
    getPlayerInfo()
    if isPlusPet then
        self:showPlusPetInterface()
    else
        self:showPetInterface(index)
    end

end

function M:openPetPackage(index, isPlusPet)
    UI:openWnd("petPackage")
    self.isVisible = true
    self:_openPetPackage(index, isPlusPet)
end


function M:setPetAllText()
    self.selSwitchText.petSel:SetText(Lang:toText("PetPackage-Pet"))
    self.selSwitchText.petUnSel:SetText(Lang:toText("PetPackage-Pet"))
    self.selSwitchText.plusPetSel:SetText(Lang:toText("PetPackage-PlusPet"))
    self.selSwitchText.plusPetUnSel:SetText(Lang:toText("PetPackage-PlusPet"))

    self.petLayoutText.petTittleText:SetText(Lang:toText("PetPackage-PetPageTittle"))
    self.petLayoutText.petPageText:SetText(Lang:toText("PetPackage-PetPageInfo"))
    self.petLayoutText.addChiText:SetText(Lang:toText("PetPackage-Total"))
    self.petLayoutText.addCoinText:SetText(Lang:toText("PetPackage-Total"))
    self.petLayoutText.addFuText:SetText(Lang:toText("PetPackage-Total"))

    self.petLayoutText.petInfo.petEvolutionText:SetText(Lang:toText("PetPackage-Evolution"))
    self.petLayoutText.petInfo.petSellText:SetText(Lang:toText("PetPackage-Sell"))

    self.petLayoutText.petInfo.petEquipText:SetText(Lang:toText("PetPackage-Equip"))

    self.plusPetLayoutText.plusPetFoldSelAll:SetText(Lang:toText("PetPackage-All"))
    self.plusPetLayoutText.plusPetFoldSelGain:SetText(Lang:toText("PetPackage-Gain"))
    self.plusPetLayoutText.plusPetFoldSelAtk:SetText(Lang:toText("PetPackage-Atk"))
    self.plusPetLayoutText.plusPetFoldSelDef:SetText(Lang:toText("PetPackage-Def"))

    self.plusPetLayoutText.plusPetAccess:SetText(Lang:toText("PetPackage-Access"))
    self.plusPetLayoutText.plusPetQuality:SetText(Lang:toText("PetPackage-PetQuality"))
    self.plusPetLayoutText.plusPetAtk:SetText(Lang:toText("PetPackage-PetAtk"))
    self.plusPetLayoutText.plusPetDef:SetText(Lang:toText("PetPackage-PetDef"))
    self.plusPetLayoutText.plusPetLevel:SetText(Lang:toText("PetPackage-PetLevel"))
    self.plusPetLayoutText.plusPetEquipBtn:SetText(Lang:toText("PetPackage-Equip"))
    self.plusPetLayoutText.plusPetStrBtn:SetText(Lang:toText("PetPackage-PlusStr"))
    --self.plusPetLayoutText.plusPetStrBtn:SetText(Lang:toText("PetPackage-PlusStr"))

end

function M:closePetPackage()
    UI:closeWnd("petPackage")
    self.isVisible = false
end

function M:initPetAllEvent()
    self:subscribe(self.closeBtn, UIEvent.EventButtonClick, function()
        self:closePetPackage()
    end)
    self:subscribe(self.selSwitchBtn.petBtn, UIEvent.EventButtonClick, function()
        if curPage ~= 1 then
            self:showPetInterface()
        end
    end)
    self:subscribe(self.selSwitchBtn.pPetBtn, UIEvent.EventButtonClick, function()
        if curPage ~= 2 then
            self:showPlusPetInterface()
        end
    end)
    self:subscribe(self.plusPetBtn.plusPetFoldBtn, UIEvent.EventButtonClick, function()
        self:showPlusPetFoldSel(not plusPetFoldOpen)
    end)
    self:subscribe(self.plusPetBtn.plusPetFoldSelAll, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(0)
    end)
    self:subscribe(self.plusPetBtn.plusPetFoldSelAtk, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(Define.plusPetSkillType.atk)
    end)
    self:subscribe(self.plusPetBtn.plusPetFoldSelDef, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(Define.plusPetSkillType.def)
    end)
    self:subscribe(self.plusPetBtn.plusPetFoldSelGain, UIEvent.EventButtonClick, function()
        self:setPlusPetFoldCurFold(Define.plusPetSkillType.gain)
    end)
    self:subscribe(self.plusPetBtn.plusPetEquip, UIEvent.EventButtonClick, function()
        if Player.CurPlayer.equipPetList[3] and plusPetIndex2ItemIndex(Player.CurPlayer.equipPetList[3].index) == curPlusPetSelItemIndex then
            self:setPlusPetItemDeEquip(curPlusPetSelItemIndex)
        else
            self:setPlusPetItemEquip()
        end
    end)

    self:subscribe(self.petBtn.petEquip, UIEvent.EventButtonClick, function()
        for _, v in pairs(curPetUsingItem) do
            if v == curPetSelItemIndex then
                goto DEEQUIP
            end
        end
        print("Equip")
        self:setPetEquip(curPetSelItemIndex)
        do
            return
        end
        ::DEEQUIP::
        print("De Equip!")
        self:setPetDeEquip(curPetSelItemIndex)
    end)

    self:subscribe(self.petBtn.petPagePrev, UIEvent.EventButtonClick, function()
        if curPetPage > 1 then
            self:setPetPage(curPetPage - 1)
        end
    end)

    self:subscribe(self.petBtn.petPageNext, UIEvent.EventButtonClick, function ()
        if curPetPage < Player.CurPlayer:getValue("petPageNu") then
            self:setPetPage(curPetPage + 1)
        end
    end)

    self:subscribe(self.petBtn.petEvolution, UIEvent.EventButtonClick, function()
        self:closePetPackage()
        UI:getWnd("petEvolution"):showPetEvolution(curPetPageTable, petItemIndex2Index(curPetSelItemIndex))
    end)

    self:subscribe(self.plusPetBtn.plusPetStr, UIEvent.EventButtonClick, function()
        self:closePetPackage()
        UI:getWnd("plusPetEvolution"):showPlusPetEvolution(curPlusPetPageTable, plusPetItemIndex2Index(curPlusPetSelItemIndex))
    end)
end

function M:initWnd()
    self.closeBtn = self:child("NinjaPetPackage-CloseBtnBt")
    self.selSwitchText = {
        petUnSel = self:child("NinjaPetPackage-PetUSelText"),
        petSel = self:child("NinjaPetPackage-PetSelText"),
        plusPetUnSel = self:child("NinjaPetPackage-PPetUSelText"),
        plusPetSel = self:child("NinjaPetPackage-PPetSelText")
    }
    self.selSwitchBtn = {
        petBtn = self:child("NinjaPetPackage-PetSelBtn"),
        pPetBtn = self:child("NinjaPetPackage-PPetSelBtn")
    }
    self.selSwitchImage = {
        petUnSel = self:child("NinjaPetPackage-PUSel"),
        petSel = self:child("NinjaPetPackage-PSel"),
        pPetUnSel = self:child("NinjaPetPackage-PPUSel"),
        pPetSel = self:child("NinjaPetPackage-PPSel")
    }
    self.mainLayout = {
        petLayout = self:child("NinjaPetPackage-NinjaPetInfoLayout"),
        plusPetLayout = self:child("NinjaPetPackage-NinjaPlusPetInfoLayout")
    }


    self.petLayoutText = {
        slotsText = self:child("NinjaPetPackage-PetSlotsInfo"),
        addCoinText = self:child("NinjaPetPackage-PetAddInfoCoinText"),
        addFuText = self:child("NinjaPetPackage-PetAddInfoFuText"),
        addChiText = self:child("NinjaPetPackage-PetAddInfoChiText"),
        petTittleText = self:child("NinjaPetPackage-PetPageTittleText"),
        petPageText = self:child("NinjaPetPackage-PetPageBottomText"),
        petInfo = {
            petLevel = self:child("NinjaPetPackage-PetDetailLevel"),
            petName = self:child("NinjaPetPackage-PetDetailName"),
            petEvolutionText = self:child("NinjaPetPackage-PetUpGradeText"),
            petSellText = self:child("NinjaPetPackage-PetSellText"),
            petAddCoinText = self:child("NinjaPetPackage-PetDetailCoinText"),
            petAddFuText = self:child("NinjaPetPackage-PetDetailFuText"),
            petAddChiText = self:child("NinjaPetPackage-PetDetailChiText"),
            petEquipText = self:child("NinjaPetPackage-PetDetailEquipText"),
            petTotalCoin = self:child("NinjaPetPackage-PetAddInfoCoinNu"),
            petTotalChi = self:child("NinjaPetPackage-PetAddInfoChiNu"),
            petTotalFu = self:child("NinjaPetPackage-PetAddInfoFuNu")
        }
    }
    self.plusPetLayoutText = {
        plusPetFoldCur = self:child("NinjaPetPackage-PlusPetFoldAllText"),
        plusPetFoldSelAll = self:child("NinjaPetPackage-PlusPetFoldSelAllText"),
        plusPetFoldSelAtk = self:child("NinjaPetPackage-PlusPetFoldSelAtkText"),
        plusPetFoldSelDef = self:child("NinjaPetPackage-PlusPetFoldSelDefText"),
        plusPetFoldSelGain = self:child("NinjaPetPackage-PlusPetFoldSelGainText"),
        plusPetAccess = self:child("NinjaPetPackage-PlusPetAccessText"),
        plusPetName = self:child("NinjaPetPackage-PlusPetName"),
        plusPetQuality = self:child("NinjaPetPackage-PlusPetQuaText"),
        plusPetLevel = self:child("NinjaPetPackage-PlusPetInfoLevelTextTimes"),
        plusPetLevelNu = self:child("NinjaPetPackage-PlusPetInfoLevelTextTimesNu"),
        plusPetAtk = self:child("NinjaPetPackage-PlusPetInfoLevelTextAtk"),
        plusPetAtkNu = self:child("NinjaPetPackage-PlusPetInfoLevelTextAtkNu"),
        plusPetDef = self:child("NinjaPetPackage-PlusPetInfoLevelTextDef"),
        plusPetDefNu = self:child("NinjaPetPackage-PlusPetInfoLevelTextDefNu"),
        plusPetSkillInfo = self:child("NinjaPetPackage-PlusPetSkillInfo"),
        plusPetEquipBtn = self:child("NinjaPetPackage-PlusPetInfoEquipBtnText"),
        plusPetStrBtn = self:child("NinjaPetPackage-PlusPetInfoStrBtnText")
    }

    self.petBtn = {
        petPagePrev = self:child("NinjaPetPackage-PetPagePrev"),
        petPageNext = self:child("NinjaPetPackage-PetPageNext"),
        petPageAdd = self:child("NinjaPetPackage-PetPageAddPage"),
        petEvolution = self:child("NinjaPetPackage-PetUpGradeBtnIns"),
        petSell = self:child("NinjaPetPackage-PetSellBtnIns"),
        petEquip = self:child("NinjaPetPackage-PetDetailEquipBtn")
    }
    self.plusPetBtn = {
        plusPetFoldBtn = self:child("NinjaPetPackage-PlusPetFoldBtn"),
        plusPetFoldSelAll = self:child("NinjaPetPackage-PlusPetFoldSelAllBtn"),
        plusPetFoldSelAtk = self:child("NinjaPetPackage-PlusPetFoldSelAtkBtn"),
        plusPetFoldSelDef = self:child("NinjaPetPackage-PlusPetFoldSelDefBtn"),
        plusPetFoldSelGain = self:child("NinjaPetPackage-PlusPetFoldSelGainBtn"),
        plusPetAccess = self:child("NinjaPetPackage-PlusPetAccessBtn"),
        plusPetEquip = self:child("NinjaPetPackage-PlusPetInfoEquipBtnBt"),
        plusPetStr = self:child("NinjaPetPackage-PlusPetInfoStrBtnBt")
    }

    self.petLayout = {
        petItems = self:child("NinjaPetPackage-PetPageMainView"),
        petImage = self:child("NinjaPetPackage-PetDetailImg"),
        petQuality = self:child("NinjaPetPackage-PetDetailQuality")
    }
    self.petLayout.petItems:InitConfig(20, 20, 4)       --item 110 * 110
    self.plusPetLayout = {
        plusPetFoldBg = self:child("NinjaPetPackage-PlusPetFoldSelBg"),
        plusPetItem = self:child("NinjaPetPackage-PlusPetItemGrid"),
        plusPetActor = self:child("NinjaPetPackage-PlusPetExhibition"),
        plusPetSkillTypeIcon = self:child("NinjaPetPackage-PlusPetSkillTypeImg"),
        plusPetQuality = self:child("NinjaPetPackage-PlusPetQuaImage")
    }
    self.plusPetLayout.plusPetItem:InitConfig(10, 10, 2) --item 77 * 77
    plusPetFoldTable[0] = {
        text = self.plusPetLayoutText.plusPetFoldSelAll,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldAllSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldAllUnSel")
        }
    }
    plusPetFoldTable[Define.plusPetSkillType.def] = {
        text = self.plusPetLayoutText.plusPetFoldSelDef,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldDefSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldDefUnSel")
        }
    }
    plusPetFoldTable[Define.plusPetSkillType.atk] = {
        text = self.plusPetLayoutText.plusPetFoldSelAtk,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldAtkSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldAtkUnSel")
        }
    }
    plusPetFoldTable[Define.plusPetSkillType.gain] = {
        text = self.plusPetLayoutText.plusPetFoldSelGain,
        bg = {
            sel = self:child("NinjaPetPackage-PlusPetFoldGainSel"),
            unsel = self:child("NinjaPetPackage-PlusPetFoldGainUnSel")
        }
    }
    self:setPetAllText()
    self:initPetAllEvent()
end

return M