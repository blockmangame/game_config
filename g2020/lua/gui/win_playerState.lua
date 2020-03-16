local main = {}
local states = {}
local close = {}
local imgPath = "set:state_detail.json image:"
local skillPath = "myplugin/skill_state_"
local isOdd = true
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

function M:onOpen()
end

function M:onClose()
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
        self:showMain(false)
        self:dynamicCalculateStatesArea()
    end)
end

function M:initStates()
    states = { UI = { root = self:child("States"), cell = {} }, data = {}, selectIdx = 1 }
end

function M:initClose()
    close = { UI = { root = self:child("Close") } }
    self:subscribe(close.UI.root, UIEvent.EventButtonClick, function()
        UI:closeWnd("showDetails")
        self:showMain(true)
    end)
end

function M:operateStateCell(isAdd, state, stateIndex)
    local stateData = states.data[stateIndex] or {}
    local cell = states.UI.cell[state]

    if not main.visible and isAdd and not cell then
        local btn = GUIWindowManager.instance:CreateGUIWindow1("RadioButton", state)
        btn:SetNormalImage(imgPath..state)
        btn:SetPushedImage(imgPath..state.."_chosen")
        btn:SetTouchable(true)
        self:subscribe(btn, UIEvent.EventWindowTouchUp, function()
            local otherID = nil
            for _, v in ipairs(stateData.userID) do
                if v ~= Me.objID then
                    otherID = v
                    break ---目前最多仅有两围玩家交互，所以暂时先这么做
                end
            end
            Skill.Cast(skillPath..state, {targetID = otherID})
        end)
        local txt = GUIWindowManager.instance:CreateGUIWindow1("StaticText", state.."Sum")
        txt:SetArea({0, 0}, {0, 0}, {0, specs.itemWidth / 3}, {0, specs.itemHeight / 3})
        txt:SetVerticalAlignment(2)
        txt:SetHorizontalAlignment(2)
        txt:SetTextVertAlign(1)
        txt:SetTextHorzAlign(1)
        txt:SetTouchable(true)
        btn:AddChildWindow(txt)
        states.UI.root:AddChildWindow(btn)
        cell = { btn = btn, txt = txt }
    end

    if stateData.stateUsersCount <= 0 then
        table.remove(states.data, stateIndex)
        if cell then
            cell.btn:RemoveChildWindow1(cell.txt)
            states.UI.root:RemoveChildWindow1(cell.btn)
            cell = nil
        end
    end

    if cell then
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
    states.UI.root:SetBackgroundColor({1, 0, 0, 100/255})
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

function M:showMain(visible)
    main.visible = visible
    main.UI.root:SetVisible(visible)
    states.UI.root:SetVisible(not visible)
    close.UI.root:SetVisible(not visible)
    self._root:SetTouchable(not visible)
    self:dynamicCalculateStatesArea()
    ToggleMainUI(visible)
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
    Lib.subscribeEvent(Event.EVENT_SET_UI_VISIBLE, function(visible)
        self:showMain(visible)
    end)
    Lib.subscribeEvent(Event.EVENT_STATE_RELEASING_ANIMATION, function(state)
        self:stateReleasingAnimation(state)
    end)
end

function M:stateReleasingAnimation(state)
    local UI = states.UI
    local img = isOdd and imgPath..state or imgPath..state.."_chosen"
    if main.visible then
        main.UI.img:SetImage(img)
    elseif UI.cell[state] then
        local btn = UI.cell[state].btn
        if btn:IsSelected() then
            btn:SetPushedImage(img)
        else
            btn:SetNormalImage(img)
        end
    end
    isOdd = not isOdd
end

return M