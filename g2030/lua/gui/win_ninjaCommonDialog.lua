---
---忍者项目通用弹窗UI
---zhuyayi 20200325
---
function M:init()
    WinBase.init(self, "NinjaCommonDialog.json",false)
    self:initWnd()
end
---
---content 内容
---contentCenter 内容是否居中(默认靠左)
---imgTitle 图片标题
---txtTitle 文字标题
---hideClose 是否隐藏右上角关闭按钮
---leftTxt，leftCb，左按钮文字和回调
---rightTxt，rightCb，右按钮文字和回调
---特别的：当leftCb，rightCb有任意一个不传入时，该侧按钮不显示，另一个居中显示
function M:initView(args)
    if args.content then
        self.txtContent:SetText(args.content)
    end
    if args.contentCenter then
        self.txtContent:SetTextHorzAlign(1)
        self.txtContent:SetTextVertAlign(1)
    end
    if args.imgTitle then
        self.txtTitle:SetVisible(false)
        self.imgTitle:SetVisible(true)
        self.imgTitle:SetImage(args.imgTitle)
    elseif args.txtTitle then
        self.txtTitle:SetVisible(true)
        self.imgTitle:SetVisible(false)
        self.txtTitle:SetText(args.txtTitle)
    end
    if args.hideClose then
        self.btnClose:SetVisible(false)
    end
    if args.leftTxt then
        self.btnLeft:SetText(args.leftTxt or Lang:toText("gui_cancel"))
    end
    if args.rightTxt then
        self.btnRight:SetText(args.rightTxt or Lang:toText("gui_sure"))
    end
    if args.leftCb then
        self.leftCb = args.leftCb
    else
        self.btnLeft:SetVisible(false)
        self.btnRight:SetXPosition({0,0})
    end
    if args.rightCb then
        self.rightCb = args.rightCb
    else
        self.btnRight:SetVisible(false)
        self.btnLeft:SetXPosition({0,0})
    end
end
function M:initWnd()
    self.txtTitle = self:child("NinjaCommonDialog-TextTitle")
    self.imgTitle = self:child("NinjaCommonDialog-ImgTitle")
    self.txtContent = self:child("NinjaCommonDialog-Content")
    self.btnClose = self:child("NinjaCommonDialog-Close")
    self.btnLeft = self:child("NinjaCommonDialog-Left")
    self.btnRight = self:child("NinjaCommonDialog-Right")
    self:initEvent()
end

function M:initEvent()
    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        UI:closeWnd(self)
    end)
    self:subscribe(self.btnLeft, UIEvent.EventButtonClick, function()
        self:doCallBack("left")
    end)
    self:subscribe(self.btnRight, UIEvent.EventButtonClick, function()
        self:doCallBack("right")
    end)
end
function M:doCallBack(key)
    if key == "left" and self.leftCb then
        self.leftCb()
    elseif key == "right" and self.rightCb then
        self.rightCb()
    end
    UI:closeWnd(self)
end

function M:onOpen()
end