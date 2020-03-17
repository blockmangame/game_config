
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
    view:setMaterial(5)
    view:SetImage(texture:getTextureName())
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
            if not string.match(name, "*head_") then
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