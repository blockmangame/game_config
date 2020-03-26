function M:init()
    WinBase.init(self, "FamilyIdentity.json", false)
    self:initProp()
end

function M:initProp()
    self:root():SetVisible(false)
    self.pic = self:child("FamilyIdentity-pic")
    self.text = self:child("FamilyIdentity-text")

    local cfg = Me._cfg
    local x = cfg.familyIdentityOffsetX
    local y = cfg.familyIdentityOffsetY

    self._root:SetXPosition({0, x})
    self._root:SetYPosition({0, y})
end

function M:onOpen(pic, text)
    self:setPic(pic)
    self:setText(text)
    self._root:SetHorizontalAlignment(1)
    self._root:SetVerticalAlignment(1)
end

function M:setPic(pic)
    self.pic:SetImage(pic)
end

function M:setText(text)
    self.text:SetText(Lang:toText(text))
end