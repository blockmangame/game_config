local main = {}
local states = {}
local close = {}
local imgPath = "set:state_detail.json image:"
local skillPath = "myplugin/skill_state_"
local specs = World.cfg.stateSpecs or {
    itemWidth = 80,
    itemHeight = 80,
    itemSpace = 15,
    itemXAbs = 0,
    itemYAbs = 150,
    mainHAlign = 2,
    mainVAlign = 2,
    mainArea = {{0, -260}, {0, -50}, {0, 110}, {0, 110}}
}


local function ToggleMainUI(show)
    local packet = {
        pid = "ToggleMainUI",
        show = show,
	}
	Me:sendPacket(packet)
end

local function _getIndexByValueKey(tab, val, key)
    for i, v in ipairs(tab or {}) do
        if (key and val == v[key]) or (not key and val == v) then
            return i
        end
    end
    return nil
end

local function _getSize(tab)
    local i = 0
    for _, _ in pairs(tab or {}) do
        i = i + 1
    end
    return i
end

local function _resetUI(self, visible)
    main.visible = visible
    main.UI.root:SetVisible(visible)
    states.UI.root:SetVisible(not visible)
    close.UI.root:SetVisible(not visible)
    self._root:SetTouchable(not visible)
    self._root:SetBackgroundColor({192/255, 192/255, 192/255, (visible and {0} or {150/255})[1]})
end

local function _removeMainAnimationTimer()
    if main.animationCdTimer then
        main.animationCdTimer()
        main.animationCdTimer = nil
    end
end

local function _resetMainAnimationData()
    main.animationList = nil
    _removeMainAnimationTimer()
end

function M:onOpen()
    _resetUI(self, true)
end

function M:onClose()
    ToggleMainUI(true)
    UI:closeWnd("showDetails")
end

function M:initMain()
    main = {
        UI = {
            root = self:child("Main"),
            img = self:child("StateImg"),
            txt = self:child("StateTxt"),
        },
        img = "",
        --isOdd = true,
        animationList = {},
        animationCdTimer = nil,
        visible = true,
        totalUsersCount = 0,
    }
    local ui = main.UI
    ui.root:SetVisible(true)
    ui.txt:SetTextHorzAlign(1)
    ui.txt:SetTextVertAlign(1)
    ui.root:SetArea(table.unpack(specs.mainArea))
    ui.root:SetVerticalAlignment(specs.mainVAlign)
    ui.root:SetHorizontalAlignment(specs.mainHAlign)
    self:subscribe(main.UI.root, UIEvent.EventWindowTouchUp, function()
        self:hideMain()
    end)
end

function M:initStates()
    states = { UI = { root = self:child("States"), cell = {} }, data = {}, selectBtn = nil }
end

function M:initClose()
    close = { UI = { root = self:child("Close") } }
    self:subscribe(close.UI.root, UIEvent.EventButtonClick, function()
        UI:closeWnd("showDetails")
        self:showMain()
    end)
end

local _radioButtonTouchUpEvent = function(btn, state, stateData)
    if not btn or (btn:IsSelected() and states.selectBtn == btn) then
        return
    end
    states.selectBtn = btn
    local otherID = nil
    for _, v in ipairs(stateData.userID) do
        if v ~= Me.objID then
            otherID = v
            break ---目前最多仅有两围玩家交互，所以暂时先这么做
        end
    end
    Skill.Cast(skillPath..state, {targetID = otherID})
end

local _toggleSelectBtn = function(isMainUIVisible)
    if isMainUIVisible and states.selectBtn then
        states.selectBtn:SetSelected(false)
        states.selectBtn = nil
    elseif not isMainUIVisible then
        local stateData = states.data and states.data[1] or {}
        local state = stateData.name
        local btn = state and states.UI.cell[state] and states.UI.cell[state].btn
        if btn then
            btn:SetSelected(true)
            _radioButtonTouchUpEvent(btn, state, stateData)
        end
    end
end

function M:operateStateCell(isAdd, state, stateIndex)
    local stateData = states.data[stateIndex] or {}
    local cell = states.UI.cell[state]

    if not main.visible and isAdd and not cell then
        local btn = GUIWindowManager.instance:CreateGUIWindow1("RadioButton", state)
        btn:SetTouchable(true)
        self:subscribe(btn, UIEvent.EventWindowTouchUp, function()
            _radioButtonTouchUpEvent(btn, state, stateData)
        end)
        local txtLv = GUIWindowManager.instance:CreateGUIWindow1("Layout", state.."txtLv")
        txtLv:SetArea({0, 0}, {0, -6}, {0, specs.itemWidth / 3}, {0, specs.itemHeight / 3})
        txtLv:SetProperty("StretchType", "NineGrid")
        txtLv:SetVerticalAlignment(2)
        txtLv:SetHorizontalAlignment(2)
        txtLv:SetBackImage(imgPath.."number_background")
        local txt = GUIWindowManager.instance:CreateGUIWindow1("StaticText", state.."Sum")
        txt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
        txt:SetTextVertAlign(1)
        txt:SetTextHorzAlign(1)
        txt:SetTextColor({0, 0, 0, 1})
        txt:SetTouchable(true)
        txtLv:AddChildWindow(txt)
        btn:AddChildWindow(txtLv)
        states.UI.root:AddChildWindow(btn)
        btn:SetName("skill_"..state)
        cell = { btn = btn, txtLv = txtLv, txt = txt, isOdd = true }
    end

    if stateData.stateUsersCount <= 0 then
        table.remove(states.data, stateIndex)
        if cell then
            cell.txtLv:RemoveChildWindow1(cell.txt)
            cell.btn:RemoveChildWindow1(cell.txtLv)
            states.UI.root:RemoveChildWindow1(cell.btn)
            cell = nil
        end
    end

    if cell then
        cell.btn:SetNormalImage(imgPath..state)
        cell.btn:SetPushedImage(imgPath..state.."_chosen")
        local x = (stateIndex - 1) * (specs.itemWidth + specs.itemSpace)
        cell.btn:SetArea({0, x}, {0, 0}, {0, specs.itemWidth}, {0, specs.itemHeight})
        cell.txt:SetText(stateData.stateUsersCount)
    end

    states.UI.cell[state] = cell
end

function M:dynamicCalculateStatesArea()
    if main.totalUsersCount <= 0 then
        UI:closeWnd(self)
        return
    end

    if main.visible then
        UI:closeWnd("showDetails")
        main.UI.txt:SetText(main.totalUsersCount)
        main.UI.img:SetImage(imgPath..main.img)
        return
    end

    local i = 0
    for _, v in ipairs(states.data) do
        i = i + 1
        self:operateStateCell(true, v.name, i)
    end
    local width = i * (specs.itemWidth + specs.itemSpace) - specs.itemSpace
    states.UI.root:SetArea({0, specs.itemXAbs}, {0, specs.itemYAbs}, {0, width}, {0, specs.itemHeight})
    states.UI.root:SetHorizontalAlignment(1)
    states.UI.root:SetVerticalAlignment(0)
end

function M:syncData(packet)
    local isAdd, userID = packet.isAdd, packet.targetID
    local data = states.data
    for _, v in pairs(packet.states) do
        local i = _getIndexByValueKey(data, v, "name")
        local idx = _getIndexByValueKey(data[i] and data[i].userID, userID)
        if isAdd and i == nil then
            table.insert(data, {["name"] = v, ["userID"] = {userID}})
        elseif isAdd and idx == nil then
            table.insert(data[i].userID, userID)
        elseif not isAdd and i ~= nil and idx ~= nil then
            table.remove(data[i].userID, idx)
        else
            goto continue
        end

        i = i or _getSize(data)
        local addend = (isAdd and {1} or {-1})[1]
        data[i].stateUsersCount = (data[i].stateUsersCount or 0) + addend
        self:operateStateCell(isAdd, v, i)
        local lastState = data[_getSize(data)]
        main.totalUsersCount = main.totalUsersCount + addend
        main.img = isAdd and v or (lastState and lastState.name)
        ::continue::
    end
    self:dynamicCalculateStatesArea()
end

function M:showMain()
    _resetUI(self, true)
    self:dynamicCalculateStatesArea()
    ToggleMainUI(true)
    _toggleSelectBtn(true)
end

function M:hideMain()
    ToggleMainUI(false)
end

function M:init()
    WinBase.init(self, "PlayerState.json", false)
    self:initMain()
    self:initStates()
    self:initClose()
    self._root:SetTouchable(false)

    Lib.subscribeEvent(Event.EVENT_SYNC_DATA, function(packet)
        self:syncData(packet)
    end)
    Lib.subscribeEvent(Event.EVENT_SET_UI_VISIBLE, function()
        self:showMain()
    end)
    Lib.subscribeEvent(Event.EVENT_STATE_RELEASING_ANIMATION, function(state, isAdd)
        self:stateReleasingAnimation(state, isAdd)
    end)

    Lib.subscribeEvent(Event.EVENT_SET_UI_INVISIBLE, function()
        _resetUI(self, false)
        self:dynamicCalculateStatesArea()
        _toggleSelectBtn(false)
    end)
end

function M:stateReleasingAnimation(state, isAdd)
    local UI = states.UI
    local index = _getIndexByValueKey(main.animationList, state)
    if isAdd and not index then
        _removeMainAnimationTimer()
        table.insert(main.animationList, state)
    elseif not isAdd and index then
        _removeMainAnimationTimer()
        table.remove(main.animationList, index)
    end
    if main.visible then
        local list = main.animationList
        if #list == 0 then
            _removeMainAnimationTimer()
            main.UI.img:SetImage(imgPath..main.img)
            return
        end
        if not main.animationCdTimer then
            local i, j = 1, 1
            main.animationCdTimer = World.Timer(10, function ()
                i = i > #list and 1 or i
                main.UI.img:SetImage(j % 2 == 1 and imgPath..list[i] or imgPath..list[i].."_chosen")
                j = j + 1
                i = i + j % 2
                return true
            end)
        end
    elseif UI.cell[state] then
        local isOdd = UI.cell[state].isOdd
        local btn = UI.cell[state].btn
        local img = isOdd and imgPath..state or imgPath..state.."_chosen"
        if btn:IsSelected() then
            btn:SetPushedImage(img)
        else
            btn:SetNormalImage(img)
        end
        UI.cell[state].isOdd = not isOdd
    end
end

return M