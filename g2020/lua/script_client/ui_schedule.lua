
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