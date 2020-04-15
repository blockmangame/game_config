
function M:init()
    WinBase.init(self, "NinjaGauntlet.json",false)
    self:initWnd()
end
---
---text 内容
---btnYes 确认按钮
---btnNo  取消按钮
---
function M:initWnd()
    self.processKey = ""
    self.text = self:child("NinjaGauntlet-Text")
    self.btnYes = self:child("NinjaGauntlet-Yes")
    self.btnNo = self:child("NinjaGauntlet-No")

    self.text:SetText(Lang:toText("gauntlet_text"))
    self.btnYes:SetText(Lang:toText("confirm_text"))
    self.btnNo:SetText(Lang:toText("cancel_text"))
    self:initEvent()
end

function M:initEvent()
    self:subscribe(self.btnNo, UIEvent.EventButtonClick, function()
        UI:closeWnd(self)
    end)
    self:subscribe(self.btnYes, UIEvent.EventButtonClick, function()
        self:onConfirm()
    end)
end
function M:onConfirm()
    local key = self.processKey
    Me:sendPacket({
        pid = "ConfirmGauntlet",
        objId = Me.objID,
        key = key
    })
    UI:closeWnd(self)
end

function M:onOpen(key)
    self.processKey = key
end