
local _worksTextures = {}
local _remoterData = {}


function UI:setRemoterData(ui, data)
    _remoterData[ui] = data
end

function UI:getRemoterData(key)
    return _remoterData[key]
end

function UI:getViewTexture(key)
    return _worksTextures[key]
end

function UI:setViewTexture(key, view)
    local texture = _worksTextures[key]
    if not texture then
        texture = Lib.derive(require 'special.block_color_texture')
        texture:initFromWin(key)
        texture:loadColorInfoFromUrl(key)
        _worksTextures[key] = texture
    end
    view:SetImage(texture:getTextureName())
end

function UI:openHeadWnd(objID, name, width, height, ...)
    local window = assert(UIMgr:new_wnd(name))
	if not window then
		return nil
	end
	local key = "*head_" .. objID
    local wnd = self._windows[key]
	if wnd then
		self:closeHeadWnd(objID)
	end
    self._windows[key] = window
    self._windows[key].identityName = name
	GUISystem.instance:CreateHeadWindow(objID,window:root(), width, height)
    window:show()
    window:onOpen(...)
    return window
end

function UI:hideOpenedWnd(excluded)
    local wnds = {}
    excluded = excluded or ""
    local excludedMap = {}
    if type(excluded) == "table" then
        for _, excludedName in pairs(excluded) do
            excludedMap[excludedName] = true
        end
    end
    excludedMap[excluded] = true
    for name, wnd in pairs(UI._windows) do
        if not excludedMap[name] and wnd:isvisible() then
            wnd:hide()
            if wnd.identityName ~= "bubbleMsg" then
                wnds[#wnds + 1] = wnd
            end
        end
    end
    return function ()
        for _, wnd in ipairs(wnds) do
            wnd:show()
        end
        wnds = {}
    end
end

function UI:closeHeadWnd(objID)
	local key = "*head_" .. objID

	local window
	if type(key) == "string" then
		window = self._windows[key]
	end

    if not window then
        return
    end

	self._windows[key]:onClose()
	self._windows[key] = nil
    GUISystem.instance:RemoveHeadWindow(objID)

    local entity = World.CurWorld:getEntity(objID)
    if entity then
        entity:updateFamilyIdentity()
    end
end

Lib.subscribeEvent(Event.EVENT_OPEN_DRESS_ARCHIVE, function(isUpdateData)
    UI:openWnd("dressArchive", isUpdateData)
end)

Lib.subscribeEvent(Event.EVENT_SHOW_DRESS_STORE, function(index, actorInfo, curActorSkin, appSkin)
    if index then
        UI:openWnd("dressStore", index, actorInfo, curActorSkin, appSkin)
    end
end)

Lib.subscribeEvent(Event.EVENT_SHOW_WORK_DETAILS, function(show)
    if show then
        if UI:isOpen("workTask") then
            local uiTask = UI:getWnd("workTask")
            uiTask:showTaskGps(true)
        else
            UI:openWnd("workTask")
        end
    else
        UI:closeWnd("workTask")
    end
end)

Lib.subscribeEvent(Event.EVENT_GUIDE_GM, function(packet)
    Me:sendPacket(packet)
end)

Lib.subscribeEvent(Event.EVENT_SHOW_BUBBLE_MSG, function(packet)
    if packet.hide then
        UI:closeHeadWnd(packet.objID)
    else
        UI:openHeadWnd(packet.objID, "bubbleMsg", 5, 5, packet)
    end
end)
