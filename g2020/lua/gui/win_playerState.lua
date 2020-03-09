local main = {}
local states = {}
local close = {}
local imgPath = "set:state_detail.json image:"
local skillPath = "myplugin/skill_state_"
local specs = {
    width = 60,
    height = 60,
    space = 15,
    xAbs = 0,
    yAbs = 150,
}

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
    self:showMain(true)
end

function M:onClose()
    UI:closeWnd("ShowDetails")
end

function M:initMain()
    main = {
        UI = {
            root = self:child("Main"),
            img = self:child("StateImg"),
            txt = self:child("StateTxt"),
        },
        img = "",
        count = 0,
        visible = false
    }
    local ui = main.UI
    ui.txt:SetTextHorzAlign(1)
    ui.txt:SetTextVertAlign(1)
    self:subscribe(main.UI.root, UIEvent.EventWindowTouchUp, function()
        self:showMain(false)
        self:recalculateStatesArea()
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

function M:operateStateCell(isAdd, state, index)
    local data = states.data[index] or {}
    local count = _getSize(data.UserID)
    local cell = states.UI.cell[state]

    if not main.visible and isAdd and not cell then
        local btn = GUIWindowManager.instance:CreateGUIWindow1("RadioButton", state)
        btn:SetNormalImage(imgPath..state)
        btn:SetPushedImage(imgPath..state.."_chosen")
        btn:SetTouchable(true)
        self:subscribe(btn, UIEvent.EventWindowTouchUp, function()
            Skill.Cast(skillPath..state)
        end)
        local txt = GUIWindowManager.instance:CreateGUIWindow1("StaticText", state.."Sum")
        txt:SetArea({0, 0}, {0, 0}, {0, specs.width / 3}, {0, specs.height / 3})
        txt:SetVerticalAlignment(2)
        txt:SetHorizontalAlignment(2)
        txt:SetTextVertAlign(1)
        txt:SetTextHorzAlign(1)
        txt:SetTouchable(true)
        btn:AddChildWindow(txt)
        states.UI.root:AddChildWindow(btn)
        cell = { btn = btn, txt = txt }
    end

    if cell then
        local x = (index - 1) * (specs.width + specs.space)
        cell.btn:SetArea({0, x}, {0, 0}, {0, specs.width}, {0, specs.height})
        cell.txt:SetText(count)
        if count <= 0 then
            table.remove(states.data, index)
            cell.btn:RemoveChildWindow1(cell.txt)
            states.UI.root:RemoveChildWindow1(cell.btn)
            cell = nil
        end
    end
    states.UI.cell[state] = cell
end

function M:recalculateStatesArea()
    if main.count <= 0 then
        UI:closeWnd(self)
        return
    end

    if main.visible then
        local size = _getSize(states.data)
        local img = states.data[size] and states.data[size].Name
        main.UI.txt:SetText(main.count)
        main.UI.img:SetImage(imgPath..img)
        return
    end

    local i = 0
    for _, v in ipairs(states.data) do
        i = i + 1
        self:operateStateCell(true, v.Name, i)
    end
    local width = i * (specs.width + specs.space) - specs.space
    states.UI.root:SetArea({0, specs.xAbs}, {0, specs.yAbs}, {0, width}, {0, specs.height})
    states.UI.root:SetHorizontalAlignment(1)
    states.UI.root:SetVerticalAlignment(0)
    states.UI.root:SetBackgroundColor({1, 0, 0, 100/255})
end

function M:syncData(packet)
    local isAdd, userID = packet.isAdd, packet.userID
    for _, v in pairs(packet.states) do
        local data = states.data
        local i = _getIndexByValueKey(data, v, "Name")
        local usersInData = (i == nil and {{}} or {data[i].UserID})[1]
        local idx = _getIndexByValueKey(usersInData, userID)
        if isAdd and i == nil then
            table.insert(data, {["Name"] = v, ["UserID"] = {userID}})
        elseif isAdd and idx == nil then
            table.insert(data[i].UserID, userID)
        elseif not isAdd and i ~= nil and idx ~= nil then
            table.remove(data[i].UserID, idx)
        else
            goto continue
        end

        states.data = data
        main.count = main.count + (isAdd and {1} or {-1})[1]
        self:operateStateCell(isAdd, v, i or _getSize(data))
        ::continue::
    end
    self:recalculateStatesArea()
end

function M:showMain(visible)
    main.visible = visible
    main.UI.root:SetVisible(visible)
    states.UI.root:SetVisible(not visible)
    close.UI.root:SetVisible(not visible)
    self._root:SetTouchable(not visible)
    self:recalculateStatesArea()
end

function M:init()
    WinBase.init(self, "PlayerState.json", false)
    self:initMain()
    self:initStates()
    self:initClose()

    Lib.subscribeEvent(Event.EVENT_SYNC_DATA, function(packet)
        self:syncData(packet)
    end)
    Lib.subscribeEvent(Event.EVENT_SET_UI_VISIBLE, function(visible)
        self:showMain(visible)
    end)
end

return M
