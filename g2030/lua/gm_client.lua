local GMItem = GM:createGMItem()

GMItem["g2030/LOADING_PAGE"] = function()
    Lib.emitEvent(Event.EVENT_LOADING_PAGE, true)
end

GMItem["g2030/CAST_SKILL"] = function()
    local player = Player.CurPlayer
    local playerCfg = player:cfg()
    Skill.Cast(playerCfg.twiceJumpSkill)
end

return GMItem
