
local worksTextures = {}

function UI:getViewTexture(key)
    return worksTextures[key]
end

function UI:setViewTexture(key, view)
    local texture = worksTextures[key]
    if not texture then
        texture = Lib.derive(require 'special.block_color_texture')
        texture:initFromWin(key)
        texture:loadColorInfoFromUrl(key)
        worksTextures[key] = texture
    end
    view:setMaterial(5)
    view:SetImage(texture:getTextureName())
end