
local A_Btn
local B_Btn
local worldCfg = World.cfg
local skillJack = worldCfg.skillJack or {}

local Grid = {}

local v_alignment = {LEFT = 0, CENTER = 1, RIGHT = 2, TOP = 0, CENTER = 1, BOTTOM = 2}
local H_alignment = {LEFT = 0, CENTER = 1, RIGHT = 2, TOP = 0, CENTER = 1, BOTTOM = 2}

local function createHolder(holder, area, hAlign, vAlign)
    local img = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "Image")
    img:SetImage(holder or "")
    img:SetArea(table.unpack(area))
    img:SetVerticalAlignment(hAlign or 0)
    img:SetHorizontalAlignment(vAlign or 0)
    return img
end

local function removeHolders(arr)
    for _, image in ipairs(arr or {}) do
        local parent = image:GetParent()
        if parent then
            parent:RemoveChildWindow1(image)
        end
    end
end

local function resetSkillJack(temp)
    local EquipInfo = Me:getEquipSkill()
    for _, item in pairs(EquipInfo or {}) do
        for _, tb in ipairs(temp) do
            if item.itemName == tb.name then
                tb.jack = item.placeId
            end
        end
    end
end

local function getSkillAreaAndNames(self,equipSkills) -- ��̬����װ�����ܵ���ʾλ��
    local equipSkillsNames = {} -- ��Ҫ����λ�õļ���
    for i, skill in pairs(equipSkills or {}) do
        equipSkillsNames[skill] = i
    end
    if next(self.sectorJacks) then
        return self.sectorJacks, equipSkillsNames
    end
    local x = A_Btn:GetXPosition()[2]
    local y = A_Btn:GetYPosition()[2]
    local w = A_Btn:GetWidth()[2]
    local h = A_Btn:GetHeight()[2]
    
    local function calculate(startAngle, endAngle, deltaAngle, count, radius, jackSize, startIndex, holder)
        local arr = UILib.autoLayoutCircle({startAngle = startAngle, endAngle = endAngle, deltaAngle = deltaAngle, count = count, radius = radius})
        for i, v in ipairs(arr) do
            local area = {{0, x - 0.5 * w + jackSize * 0.5 + v.x}, {0, y - 0.5 * h + jackSize * 0.5 + v.y}, {0, jackSize}, {0, jackSize}}
            self.sectorJacks[startIndex + i] = area
            self.sectorHolders[startIndex + i] = createHolder(holder, area, 2, 2)
        end
    end

    local index = 0
    for _, v in ipairs(skillJack.sectorSkills or {}) do
        local jackNum = v.jackNum or 2
        local jackSize = v.jackSize or 60
        local holder = v.holderImage or ""
        calculate(v.startAngle, v.endAngle, v.deltaAngle, jackNum, v.radius, jackSize, index, holder)
        index = index + jackNum
    end
    return self.sectorJacks, equipSkillsNames
end

local function createSkillGrid(self, jackSize, xOff, yOff, hAlign, vAlign)
    local grid = GUIWindowManager.instance:CreateGUIWindow1("GridView", "Grid")
    grid:SetAutoColumnCount(false)
    grid:SetMoveAble(false)
    grid:SetTouchable(false)
    grid:getContainerWindow():SetTouchable(false)
    grid:SetHorizontalAlignment(hAlign)
    grid:SetVerticalAlignment(vAlign)
    grid:SetArea({0, xOff or 0}, {0, yOff or 0}, {0, jackSize or 60}, {0, jackSize or 60})
    grid:SetLevel(0)
    self._root:AddChildWindow(grid)
    return grid
end

function M:onOpen()
    
end

function M:init()
    WinBase.init(self, "Skills.json", true)
    
    self.maskTimer = {}
    self.skillList = {}
    self.lineHolders = {}
    self.sectorJacks = {}
    self.sectorHolders = {}
    self.grids = {}
    Lib.subscribeEvent(Event.EVENT_SHOW_SKILL, function(skill, show, index)
        for i, tb in ipairs(self.skillList) do --ͬ����ͬ�ף�Ҫɾ��
            local fullName = tb.name
            if fullName == skill.fullName or (tb.pos and tb.jack and tb.pos == skill.pos and tb.jack == skill.jack) then
                local maskTimer = self.maskTimer[fullName]
                if maskTimer then
                    maskTimer()
                    self.maskTimer[fullName] = nil
                end
                GUIWindowManager.instance:DestroyGUIWindow(tb.image)
                table.remove(self.skillList, i)
                Lib.emitEvent(Event.EVENT_RECHARGE_SKILL_REMOVE, fullName)
            end
        end
        if show then
            local skillName = skill.fullName
            local area = skillJack.defaultArea or {{ 0, -50 }, { 0, -280 }, { 0, 70 }, { 0, 70 }}
            local image
            if skill.isRechargeSkill then
                image = self:fetchRechargeCell("Skill_" .. skillName,area,nil,skill:getIcon(),true,true,false,"skill:" .. skill.fullName, skill.fullName)
            else
                image = self:fetchImageCell("Skill_" .. skillName,area,nil,skill:getIcon(),true,true,false,"skill:" .. skill.fullName)
            end
            local skillMask = self:fetchImageCell("Mask".. skillName,{{0,0},{0,0},{1,0},{1,0}},nil,Skill.Cfg(skillName).maskIcon or "set:main_page.json image:skill_bg.png",false,false,true,nil)
            skillMask:SetVisible(false)
            image:AddChildWindow(skillMask)

            if skill.name then
                local txt = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "")
                txt:SetArea({0, 0}, {0, 20}, {1, 0}, {0, 30})
                txt:SetVerticalAlignment(2)
                txt:SetTextVertAlign(2)
                txt:SetTextHorzAlign(1)
                txt:SetText(Lang:toText(skill.name))
                if skill.textColor then
                    txt:SetTextColor(skill.textColor)
                end
                if skill.textBorder then
                    txt:SetTextBoader(skill.textBorder)
                end
                image:AddChildWindow(txt)
            end

            local tb = {
                name = skillName,
                image = image,
                mask = skillMask,
                iconArea = skill.iconArea,
                castInterval = skill.castInterval,
                pos = skill.pos,
                jack = skill.jack,
                index = skill.jack or index or 1
            }
            table.insert(self.skillList, tb)
            if skill.isSceneSkill then
                self:subscribe(image, UIEvent.EventWindowTouchDown, function() -- 比click更精确
                    local fullName = tb.name
                    local cfg = Skill.Cfg(fullName)
                    if not Me:checkCD(cfg.cdKey) then
                        UI:openWnd("sceneSkillWnd", {skillName = fullName, skillUnclippedOuterRect = image:GetUnclippedOuterRect()})
                    end
                end)
            end
            if not skill.isTouch then 
                local skillName = tb.name
                if skill.castClickSkill then
                    skillName = skill.castClickSkill
                end
                self:subscribe(image, UIEvent.EventWindowClick, function()
                    Skill.Cast(skillName)
                end)
            end

            if skill.pushImage then
                local normalImage = skill:getIcon()
                local pushImage = ResLoader:loadImage(skill, skill.pushImage)
                self:subscribe(image, UIEvent.EventWindowTouchDown, function()
                    image:SetImage(pushImage)
                end)

                self:subscribe(image, UIEvent.EventMotionRelease, function()
                    image:SetImage(normalImage)
                end)

                self:subscribe(image, UIEvent.EventWindowTouchUp, function()
                    image:SetImage(normalImage)
                end)
            end

            self:subscribe(image, UIEvent.EventWindowLongTouchStart, function()
                local castInterval = skill.castInterval
                local stopLoop
                if castInterval and castInterval>=0 then
                    self:subscribe(image, UIEvent.EventWindowLongTouchEnd, function()
                       stopLoop()
                    end)
                    self:subscribe(image, UIEvent.EventMotionRelease, function()
                       stopLoop()
                    end)
                    local function tick()
                         Skill.Cast(tb.name)
                         return true
                    end
                    stopLoop = World.Timer(castInterval, tick)
                end
                -----------------------------------------------------
                local skillName
                if skill.isTouch then
                    skillName = tb.name
                end
                if skill.castTouchSkill then
                    skillName = skill.castTouchSkill
                end
                if skillName then  
                    local touchSkillCfg = Skill.Cfg(skillName)
                    if touchSkillCfg.progressIcon then -- �������ܽ�����
                        if not tb.progressMask then
                            local progress = touchSkillCfg.progress or 0
                            local area = {{0, 0}, {0, 0}, {1, progress}, {1, progress}}
                            local mask = self:fetchImageCell(skillName,area,image:GetLevel() + 1,touchSkillCfg.progressIcon,false,false,false,skillName)
                            mask:SetTouchable(false)
                            mask:SetVerticalAlignment(1)
                            mask:SetHorizontalAlignment(1)
                            tb.progressMask = mask
                            image:AddChildWindow(mask)
                        end
                        tb.progressMask:SetVisible(true)
                        self:updateMask(0, touchSkillCfg.touchTimeMax, tb.progressMask, skillName, touchSkillCfg.progressShowInEnd or false)
                    end
                    Skill.TouchBegin({name = skillName})
                    local function onTouchEnd()
                        local timer = self.maskTimer[skillName]
                        if timer then
                            timer()
                            self.maskTimer[skillName] = nil
                        end
                        if tb.progressMask then
                            tb.progressMask:setMask(1,0.5,0.5)
                            tb.progressMask:SetVisible(false)
                        end
                        Skill.TouchEnd()
                    end
                    self:subscribe(image, UIEvent.EventWindowLongTouchEnd, function()
                        onTouchEnd()
                    end)
                    self:subscribe(image, UIEvent.EventMotionRelease, function()
                        onTouchEnd()
                    end)
                end
            end)
        end

        local lineSkills = {}
        local sectorSkills = {}
        local areaSkills = {}
        local ABSkills = {}
        local defaultSkills = {}
        for _, tb in ipairs(self.skillList) do
            local pos = tb.pos
            local jack = tb.jack
            if tb.iconArea then
                table.insert(areaSkills, tb)
            elseif pos and type(pos) == "number" then
                local list = lineSkills[pos] or {}
                table.insert(list, tb)
                lineSkills[pos] = list
            elseif jack and (jack == "A" or jack == "B") then
                table.insert(ABSkills, tb)
            elseif skillJack.sectorSkills then
                table.insert(sectorSkills, tb)
            else
                table.insert(defaultSkills, tb)
            end
            local parent = tb.image:GetParent()
            if parent then
                parent:RemoveChildWindow1(tb.image)
            end
        end

        local function createHolders(holder, radius, count)
            local list = {}
            for i = 1, count do
                local image = createHolder(holder, {{0, 0}, {0, 0}, {0, radius or 60}, {0, radius or 60}})
                table.insert(list, image)
            end
            return list
        end

        local function fillSkills(skills, grid, jackSize, jackNum, itemSpace, holders, holderImage, reverse)
            removeHolders(holders)
            local size = jackNum and jackNum > 0 and jackNum or #skills
            local space = itemSpace or 30
            grid:InitConfig(space, 0, size)
            grid:SetWidth({0, (jackSize or 60) * size + space * (size - 1)})
            if jackNum and jackNum > 0 then
                local index = 1
                local function gridAddItem(i)
                    local image
                    for _, tb in ipairs(skills) do
                        if not tb.jack then
                            tb.jack = index
                            index = index + 1
                        end
                        if tb.jack == i then
                            image = tb.image
                            break
                        end
                    end
                    image = image or holders[i]
                    image:SetVerticalAlignment(0)
                    image:SetHorizontalAlignment(0)
                    grid:AddItem(image)
                end
                if reverse then
                    for i = jackNum, 1, -1 do
                        gridAddItem(i)
                    end
                else
                    for i = 1, jackNum do
                        gridAddItem(i)
                    end
                end
            else
                table.sort(skills, function(a, b)
                    return reverse and a.index > b.index or a.index < b.index
                end)
                for _, tb in ipairs(skills) do
                    local image = tb.image
                    image:SetVerticalAlignment(0)
                    image:SetHorizontalAlignment(0)
                    grid:AddItem(image)
                end
            end
        end

        for k, v in pairs(skillJack.lineSkills or {}) do
            local skills = lineSkills[k] or {}
            if next(skills) or (v.jackNum and v.jackNum > 0 and v.holderImage) then
                if v.jackNum and v.jackNum > 0 then
                    local holders = self.lineHolders[k] or createHolders(v.holderImage, v.jackSize, v.jackNum)
                    self.lineHolders[k] = holders
                end
                local grid = self.grids[k] or createSkillGrid(self, v.jackSize, v.xOffset, v.yOffset, v.hAlign, v.vAlign)
                self.grids[k] = grid
                fillSkills(skills, grid, v.jackSize, v.jackNum, v.itemSpace, self.lineHolders[k], v.holderImage, v.reverse)
            end
        end

        for _, tb in ipairs(areaSkills) do
            self._root:AddChildWindow(tb.image)
            self:customWindowArea(tb.image, tb.iconArea)
        end

        for _, tb in ipairs(defaultSkills) do
            self._root:AddChildWindow(tb.image)
        end

        for _, tb in ipairs(ABSkills) do
            if tb.jack == "A" then
                A_Btn:SetVisible(false)
                self.btn_A = tb.image
                tb.image:SetArea(A_Btn:GetXPosition(), A_Btn:GetYPosition(), A_Btn:GetWidth(), A_Btn:GetHeight())
            else
                B_Btn:SetVisible(false)
                self.btn_B = tb.image
                tb.image:SetArea(B_Btn:GetXPosition(), B_Btn:GetYPosition(), B_Btn:GetWidth(), B_Btn:GetHeight())
            end
            self._root:AddChildWindow(tb.image)
        end

        local index = 1
        local studySkillMap = Me:data("skill").studySkillMap or {studySkills = {}, equipSkills = {}}
        local sectorJacks, equipSkillsNames = getSkillAreaAndNames(self, studySkillMap.equipSkills)
        removeHolders(self.sectorHolders)
        local temp = Lib.copy(sectorSkills)
        resetSkillJack(temp)
        for i = 1, #self.sectorHolders do
            local image, jack
            for _, tb in ipairs(temp) do
                if not tb.jack then
                    tb.jack = index
                    index = index + 1
                end
                local jack = equipSkillsNames[tb.name] or tb.jack
                if jack == i then
                    image = tb.image
                    break
                end
            end
            image = image or self.sectorHolders[i]
            if sectorJacks[i] then
                print(" sectorJacks[i] && sectorHolders[i]", Lib.v2s(sectorJacks[i]))
                image:SetArea(table.unpack(sectorJacks[i]))
            end
            self._root:AddChildWindow(image)
        end
    end)

    Lib.subscribeEvent(Event.EVENT_SHOW_CD_MASK,function(skill)
        local tb
        local skillName = skill.name
        for _, v in ipairs(self.skillList) do
            if v.name == skillName then
                tb = v
                break
            end
        end
        if not tb then
            return
        end
        if self.maskTimer[skillName] then
            return
        end
        local skillMask = tb.mask
        skillMask:SetVisible(true)
        local skillBeginCdTime = skill.beginTime
        local skillEndCdTime = skill.endTime
        if skillEndCdTime then
            self:updateMask(skillBeginCdTime, skillEndCdTime, skillMask,skillName)
        end
    end)

    Lib.subscribeEvent(Event.EVENT_UPDATE_SKILL_JACK_AREA, function(info)
        if not info then
            return
        end
        local grid = self.grids[info.pos]
        if not grid then
            return
        end

        grid:SetArea({0, info.xOff or 0}, {0, info.yOff or 0}, grid:GetWidth(), grid:GetHeight())
        grid:SetHorizontalAlignment(info.hAlign or 1)
        grid:SetVerticalAlignment(info.vAlign or 0)
    end)
end

function M:onOpen()
    local controlView = UI:getWnd("actionControl")
    A_Btn = controlView:child("Main-Jump-Controls")
    B_Btn = controlView:child("Main-MoveState")
    Lib.emitEvent(Event.EVENT_SHOW_SKILL, {}, false)
end

function M:customWindowArea(window, area)
    local TB, LR = area.VA or 0, area.HA or 0
    local VA = area.VAlign and v_alignment[area.VAlign] or (TB >= 0 and 0 or 2)
    local HA = area.HAlign and H_alignment[area.HAlign] or (LR >= 0 and 0 or 2)
    TB = VA == v_alignment.BOTTOM and TB > 0 and TB * -1 or TB
    LR = HA == H_alignment.RIGHT and LR > 0 and LR * -1 or LR
    if not window then
        return
    end
    window:SetVerticalAlignment(VA)
    window:SetHorizontalAlignment(HA)
    window:SetArea({ 0, LR }, { 0, TB }, { 0, area.W or area.width or 70 }, { 0, area.H or area.height or 70 })
end

function M:updateMask(beginTime, endTime, iconCell, skillName, showInEnd)
    local mask = 1
    local upMask = 1 / ((endTime - beginTime) / 1)
    local function tick()
        if not iconCell then
            return false
        end
        mask = mask - upMask
        if mask <= 0 then
            iconCell:setMask(showInEnd and 0 or 1,0.5,0.5)
            iconCell:SetVisible(showInEnd or false)
            self.maskTimer[skillName] = nil
            return false
        end
        iconCell:setMask(mask,0.5,0.5)
        return true
    end
    self.maskTimer[skillName] = World.Timer(1, tick)
end

local function updateSkillCellProp(cell, areaTable, level, visable, enableLongTouch, alwaysOnTop, name)
    cell:SetVerticalAlignment(2)
    cell:SetHorizontalAlignment(2)
    cell:SetArea(areaTable[1], areaTable[2], areaTable[3], areaTable[4])
    if level then
        cell:SetLevel(level)
    end
    cell:SetVisible(visable or false)
    cell:setEnableLongTouch(enableLongTouch or false)
    cell:SetAlwaysOnTop(alwaysOnTop or false)
    if name then
        cell:SetName(name)
    end
    return cell
end

function M:fetchImageCell(imageName, areaTable, level, imagePath, visable, enableLongTouch, alwaysOnTop, name)
    local image = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", imageName)
    image:SetImage(imagePath or "")
    updateSkillCellProp(image, areaTable, level, visable, enableLongTouch, alwaysOnTop, name)
    return image
end

function M:fetchRechargeCell(imageName, areaTable, level, imagePath, visable, enableLongTouch, alwaysOnTop, name, fullName)
    local image = UIMgr:new_widget("rechargeCell")
    image:invoke("IMAGE", imagePath)
    print("areaTable----------------------------", Lib.v2s(areaTable))
    updateSkillCellProp(image, areaTable, level, visable, enableLongTouch, alwaysOnTop, name)
    Lib.emitEvent(Event.EVENT_RECHARGE_SKILL_UPDATE, fullName, image)
    return image
end

function M:getBtnA()
    return self.btn_A or A_Btn
end
function M:getBtnB()
    return self.btn_B or B_Btn
end
return M