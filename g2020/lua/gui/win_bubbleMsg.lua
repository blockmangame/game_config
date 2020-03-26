local layout = {
    fontSize = 24,
    scale = 1.0,
    lineWords = 16,
    gapHead = 6,
}

local kerning = {
    word = 3 * layout.scale,
    line = 3 * layout.scale
}

local dynamicLayout = {
    lines = 0,
    fontL = 0,
    fontH = 0,
    maxWidth = 0,
}

local closeTime = 80 --自动关闭时间80ticks

function M:init()
    WinBase.init(self, "BubbleMsg.json", false)
    self:initProp()
end

function M:initProp()
    self._root:SetVisible(false)
    self.lines = {}
    self.stLine = self:child("BubbleMsg-stLine")
    self.stLine:SetProperty("Font", "HT"..layout.fontSize)
    dynamicLayout.fontH = self.stLine:GetFont():GetFontHeight()
    dynamicLayout.fontL = self.stLine:GetFont():GetBaseline()
end

function M:createNewLineLayout()
    local line = dynamicLayout.lines + 1
    local guiLayout = GUIWindowManager.instance:CreateGUIWindow1("Layout", "line"..line)
    guiLayout:SetHorizontalAlignment(1)
    guiLayout:SetVerticalAlignment(0)
    guiLayout:SetArea(
            {0, 0},
            {0, dynamicLayout.fontH * (line - 1) + kerning.line * line},
            {0, 0},
            {0, dynamicLayout.fontH}
    )
    self._root:AddChildWindow(guiLayout)
    self.lines[line] = {
        layout = guiLayout,
        words = 0,
        width = 0,
    }
    dynamicLayout.lines = line
end

function M:SetOldLineLayout()
    local lineData = self.lines[dynamicLayout.lines]
    self.lines[dynamicLayout.lines].layout:SetWidth({0, lineData.width})
end

function M:setImageGather(imageGather)
    if not imageGather then
        return
    end
    local imgWidth = dynamicLayout.fontH
    for i, path in pairs(imageGather) do
        local lineData = self.lines[dynamicLayout.lines]
        if lineData.words + 1 > layout.lineWords then
            self:SetOldLineLayout()
            self:createNewLineLayout()
            lineData = self.lines[dynamicLayout.lines]
        end
        local img = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", dynamicLayout.lines..i)
        img:SetVerticalAlignment(2)
        img:SetHorizontalAlignment(0)
        img:SetImage(path)
        local area = {
            x = {0, lineData.width},
            y = {0, 0},
            width = {0, imgWidth},
            height = {0, imgWidth},
        }
        img:SetArea(area.x, area.y, area.width, area.height)
        lineData.layout:AddChildWindow(img)
        lineData.words = lineData.words + 1
        lineData.width = area.x[2] + imgWidth + kerning.word
        lineData.layout:SetWidth({0, lineData.width})
        self.lines[dynamicLayout.lines] = lineData

        if lineData.width > dynamicLayout.maxWidth then
            dynamicLayout.maxWidth = lineData.width
        end
    end
end

function M:setMsgText(msg)
    if not msg or type(msg) ~= "string" or #msg <= 0 then
        return
    end
    local s = 1
    local str = ""
    local lineData = self.lines[dynamicLayout.lines]
    while s <= #msg do
        if lineData.words + 1 > layout.lineWords then
            self:SetStaticText(str, lineData)
            lineData = self.lines[dynamicLayout.lines]
            str = ""
        end

        local curByte = string.byte(msg, s)
        local byteCount = 1
        if curByte > 239 then       --4字节字符
            byteCount = 4
        elseif curByte > 223 then   --3字节字符
            byteCount = 3
        elseif curByte > 128 then   --双字节字符
            byteCount = 2
        end

        str = str .. string.sub(msg, s, s + byteCount - 1)
        lineData.words = lineData.words + 1
        s = s + byteCount
    end
    self:SetStaticText(str, lineData)
end

function M:SetStaticText(str, lineData)
    if not str or type(str) ~= "string" or #str <= 0 then
        return
    end

    local txt = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "")
    local txtLen = self.stLine:GetFont():GetTextExtent(str, layout.scale)
    local area = {
        x = {0, lineData.width},
        y = {0, 0},
        width = {0, txtLen},
        height = {0, dynamicLayout.fontH},
    }
    txt:SetArea(area.x, area.y, area.width, area.height)
    txt:SetVerticalAlignment(2)
    txt:SetHorizontalAlignment(0)
    txt:SetTextVertAlign(2)
    txt:SetText(str)
    txt:SetProperty("Font", "HT"..layout.fontSize)
    txt:SetTextColor({ 44/255, 172/255, 226/255, 1 })

    lineData.layout:AddChildWindow(txt)
    lineData.width = lineData.width + txtLen + kerning.word
    lineData.layout:SetWidth({0, lineData.width})
    self.lines[dynamicLayout.lines] = lineData
    if lineData.width > dynamicLayout.maxWidth then
        dynamicLayout.maxWidth = lineData.width
    end

    if lineData.words >= layout.lineWords then
        self:SetOldLineLayout()
        self:createNewLineLayout()
    end
end

function M:setRootArea()
    local size = {
        width = {0, dynamicLayout.maxWidth + 2 * kerning.word + 20},
        height = {0, dynamicLayout.lines * (2 * kerning.line + self.lines[1].layout:GetHeight()[2])} --4 是因为图集中的bubbleMsg.png裁剪有误，在这里弥补误差
    }
    local area = {
        x = {0.5, -size.width[2] / 2},
        y = {0.5, -size.height[2] - layout.gapHead}
    }
    self._root:SetArea(area.x, area.y, size.width, size.height)
end

function M:setAutoClose(objID)
    local usedTime = 0
    self.cdTimer = World.Timer(20, function()
        usedTime = usedTime + 20
        if usedTime >= closeTime then
            self.lines = nil
            self._root:SetVisible(false)
            UI:closeHeadWnd(objID)
            return false
        end
        return true
    end)
end

function M:setNilCDTimer()
    if self.cdTimer then
        self.cdTimer()
        self.cdTimer = nil
    end
end

function M:onOpen(packet)
    if not packet.contents then
        return
    end

    local msg = packet.contents.text or ""
    local image1Gather = packet.contents.image1
    local image2Gather = packet.contents.image2
    self.lines = {}

    self:createNewLineLayout()
    self:setImageGather(image1Gather)
    self:setMsgText(Lang:toText(msg))
    self:setImageGather(image2Gather)
    self:setRootArea()
    self:setAutoClose(packet.objID)
end

function M:onClose()
    self:setNilCDTimer()
end

return M
