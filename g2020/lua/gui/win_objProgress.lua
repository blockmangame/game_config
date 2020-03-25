M.NotDialogWnd = true
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
local function dynamicAdjustUIParams(row, wnd, objID)
    uiFollowObjectParams.offset.y = paramsOffsetY + (row - 1) * 0.1
    UILib.uiFollowObject(wnd, objID, uiFollowObjectParams)
end

function M:onOpen()

end

function M:onClose()

end

function M:init()
    WinBase.init(self, "ProgressContainer.json", true)
    self._root:SetTouchable(false)
    self._root:SetVisible(true)
    self:initEvent()
end

function M:initEvent()
    Lib.subscribeEvent(Event.EVENT_SET_OBJ_PROGRESS_ARGS, function(args)
        if args.isOpen then
            self:createCell(args, args.objID)
        else
            self:removeCell(args.pgName, args.objID)
        end
    end)
end

local function getRate(usedTime, totalTime)
    return (usedTime <= totalTime and {usedTime / totalTime} or {1})[1]
end

local function _stateReleasingAnimationEvent(objID, pgName, isAdd)
    if objID == Me.objID then
        Lib.emitEvent(Event.EVENT_STATE_RELEASING_ANIMATION, pgName, isAdd)
    end
end

function M:createCell(args, objID)
    local pgName = args.pgName
    if not pgName then
        return
    end

    local usedTime = tonumber(args.usedTime or 0)
    local totalTime = tonumber(args.totalTime)
    if not totalTime or totalTime <= 0 then
        return
    end

    if not progressList[objID] then
        local _root = GUIWindowManager.instance:LoadWindowFromJSON("ObjProgress.json")
        progressList[objID] = {
            --progressBar _root
            ["_root"] = _root
        }
        _root:SetTouchable(false)
    end

    if not progressList[objID][pgName] then
        progressList[objID][pgName] = {
            --progressBar ui
            ["pgui"] = GUIWindowManager.instance:CreateGUIWindow1("ProgressBar", "progress"..pgName),
            --staticText ui
            ["stui"] = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "staticText"..pgName),
        }
        local progress = progressList[objID][pgName]

        progress.pgui:SetBackImage(args.pgBackImg or "set:state_detail.json image:pgBackImg")
        progress.pgui:SetProgressImage(args.pgImg or "set:state_detail.json image:pgImg")
        progress.pgui:SetProgress(getRate(usedTime, totalTime))
        progress.pgui:SetArea({0, 0}, {0, 0}, {0, specs.width}, {0, specs.height})
        progress.pgui:SetTouchable(false)
        progress.pgui:SetVisible(true)
        progress.pgui:SetProperty("StretchType", "NineGrid")
        progress.pgui:SetProperty("StretchOffset", "0, 0, 0, 0")

        progress.stui:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
        progress.stui:SetText(Lang:toText(args.pgText or ""))
        progress.stui:SetTextVertAlign(1)
        progress.stui:SetTextHorzAlign(1)
        progress.stui:SetTouchable(false)

        progress.pgui:AddChildWindow(progress.stui)
        progressList[objID]._root:AddChildWindow(progress.pgui)
        self._root:AddChildWindow(progressList[objID]._root)
        self:updateArea(objID)
    end

    local progress = progressList[objID][pgName]
    if progress and progress.cdTimer then
        progress.cdTimer()
        progress.cdTimer = nil
    end

    progress.cdTimer = World.Timer(10, function ()
        usedTime = usedTime + 10
        local rate = getRate(usedTime, totalTime)
        progress.pgui:SetProgress(rate)
        _stateReleasingAnimationEvent(objID, pgName, true)
        if rate == 1 or not World.CurWorld:getEntity(objID) then
            self:removeCell(pgName, objID)
            return false
        end
        return true
    end)
end

function M:removeCell(pgName, objID)
    _stateReleasingAnimationEvent(objID, pgName, false)
    if not progressList[objID] or not progressList[objID][pgName] then
        return
    end
    local progress =progressList[objID][pgName]
    local cdTimer = progress.cdTimer
    if cdTimer then
        cdTimer()
        cdTimer = nil
    end
    progress.pgui:RemoveChildWindow1(progress.stui)
    progressList[objID]._root:RemoveChildWindow1(progress.pgui)
    progressList[objID][pgName] = nil
    self:updateArea(objID)
end

function M:updateArea(objID)
    local progress = progressList[objID]
    if not progress then
        return
    end

    local i = 0
    for key, v in pairs(progress) do
        if key ~= "_root" then
            v.pgui:SetXPosition({0, 0})
            v.pgui:SetYPosition({0, i * (specs.lineSpace + v.pgui:GetHeight()[2])})
            i = i + 1
        end
    end
    if i > 0 then
        local totalHeight = i * (specs.height + specs.lineSpace) - specs.lineSpace
        progress._root:SetArea({0, 0}, {0, 0}, {0, specs.width}, {0, totalHeight})
        progress._root:SetVisible(true)
        dynamicAdjustUIParams(i, progress._root, objID)
    end
end

return M
