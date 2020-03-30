-- 自动同步属性定义
local ValueDef		= T(Entity, "ValueDef")
-- key				= {isCpp,	client,	toSelf,	toOther,	init,	saveDB}
ValueDef.jumpCount	= {false,	false,	false,	false,      1,		false}

---获得跳跃次数
function Entity:getJumpCount()
    return self:getValue("jumpCount") or 1
end

---获得最大跳跃次数
function Entity:getMaxJumpCount()
    --TODO
    return 6
end