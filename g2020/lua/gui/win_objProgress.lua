local progressList = {}
local paramsOffsetY = 1.95
local specs = {
    width = 192,
    height = 28,
    lineSpace = 0.5,
}
local uiFollowObjectParams = {
    rateTime = 1,
    autoScale = false,
    anchor = { x = 0.5, y = 0.5 },
    offset = { x = 0, y = paramsOffsetY, z = 0 },
}
local function dynamicAdjustUIParams(self, row)
    uiFollowObjectParams.offset.y = paramsOffsetY + (row - 1) * 0.1
    UILib.uiFollowObject(self._root, Me.objID, uiFollowObjectParams)
end

function M:init()
    WinBase.init(self, "ObjProgress.json", true)
    self._root:SetTouchable(false)
    self._root:SetVisible(false)
    self:initEvent()
    UILib.uiFollowObject(self._root, Me.objID, uiFollowObjectParams)
end

function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_SET_OBJ_PROGRESS_ARGS, function(args)
        if args.isOpen then
            self:createCell(args)
        else
            self:removeCell(args.pgName)
        end
    end)
end

local function getRate(usedTime, totalTime)
    return (usedTime <= totalTime and {usedTime / totalTime} or {1})[1]
end

function M:createCell(args)
    local pgName = args.pgName
    if not pgName then
        return
    end

    local usedTime = tonumber(args.usedTime or 0)
    local totalTime = tonumber(args.totalTime)
    if not totalTime or totalTime <= 0 then
        return
    end

    if not progressList[pgName] then
        progressList[pgName] = {
            --progressBar ui
            ["pgui"] = GUIWindowManager.instance:CreateGUIWindow1("ProgressBar", "progress"..pgName),
            --staticText ui
            ["stui"] = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "staticText"..pgName),
        }
    end

    local progress = progressList[pgName]
    if progress.cdTimer then
        progress.cdTimer()
        progress.cdTimer = nil
    end

    progress.pgui:SetBackImage(args.pgBackImg or "set:state_detail.json image:pgBackImg")
    progress.pgui:SetProgressImage(args.pgImg or "set:state_detail.json image:pgImg")
    progress.pgui:SetWidth({1, 0})
    progress.pgui:SetProgress(getRate(usedTime, totalTime))
    progress.pgui:SetHeight({0, specs.height})
    progress.pgui:SetTouchable(false)
    progress.pgui:SetVisible(true)
    progress.pgui:SetProperty("StretchType", "NineGrid")
    progress.pgui:SetProperty("StretchOffset", "0, 0, 0, 0")

    progress.pgui:AddChildWindow(progress.stui)
    progress.stui:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
    progress.stui:SetText(Lang:toText(args.pgText or ""))
    progress.stui:SetTextVertAlign(1)
    progress.stui:SetTextHorzAlign(1)
    progress.stui:SetTouchable(false)

    self._root:AddChildWindow(progress.pgui)
    self:updateArea()

    progress.cdTimer = World.Timer(20, function ()
        usedTime = usedTime + 20
        local rate = getRate(usedTime, totalTime)
        progress.pgui:SetProgress(rate)
        Lib.emitEvent(Event.EVENT_UPDATE_DETAILS, pgName, math.floor(rate * 100).."%")
        if rate == 1 then
            self:removeCell(pgName)
            return false
        end

        return true
    end)
end

function M:removeCell(pgName)
    if not pgName then
        return
    end
    local progress =progressList[pgName]
    if not progress then
        return
    end
    local cdTimer = progress.cdTimer
    if cdTimer then
        cdTimer()
        cdTimer = nil
    end
    self._root:RemoveChildWindow1(progress.pgui)
    self._root:RemoveChildWindow1(progress.stui)
    progressList[pgName] = nil
    self:updateArea()
end

function M:updateArea()
    local i = 0
    for _, v in pairs(progressList) do
        v.pgui:SetXPosition({0, 0})
        v.pgui:SetYPosition({0, i * (specs.lineSpace + v.pgui:GetHeight()[2])})
        i = i + 1
    end
    if i > 0 then
        local totalHeight = i * (specs.height + specs.lineSpace) - specs.lineSpace
        self._root:SetArea({0, 0}, {0, 0}, {0, specs.width}, {0, totalHeight})
        dynamicAdjustUIParams(self, i)
        self._root:SetVisible(true)
    end
end

function M:onOpen()

end

function M:onClose()

end

return M
