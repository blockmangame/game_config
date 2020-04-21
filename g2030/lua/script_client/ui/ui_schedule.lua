local thisCancel = false
Lib.subscribeEvent(Event.EVENT_EXP_CHANGE, function()
    if thisCancel and Me:getCurExp() == 0 then
        thisCancel = false
    end
    if not Me:isExpFull() or thisCancel then
        return
    end
    ---content 内容
    ---contentCenter 内容是否居中(默认靠左)
    ---imgTitle 图片标题
    ---txtTitle 文字标题
    ---hideClose 是否隐藏右上角关闭按钮
    ---leftTxt，leftCb，左按钮文字和回调
    ---rightTxt，rightCb，右按钮文字和回调
    UI:openWnd("ninjaCommonDialog"):initView(
            {
                content = Lang:toText("gui_sell_exp_notice"),
                contentCenter = true,
                txtTitle = Lang:toText("gui_tip"),
                hideClose = false,
                leftTxt = Lang:toText("gui_no"),
                rightTxt = Lang:toText("gui_go"),
                leftCb = function() thisCancel = true end,
                rightCb = function() Me:sellExp() end

    }
    )
end)

Lib.subscribeEvent(Event.EVENT_NOT_ENOUGH_MONEY, function()
    print("EVENT_NOT_ENOUGH_MONEY")
    UI:openWnd("ninjaCommonDialog"):initView(
            {
                content = Lang:toText("gui_not_enough_money_notice"),
                contentCenter = true,
                txtTitle = Lang:toText("gui_tip"),
                hideClose = false,
                leftTxt = Lang:toText("gui_sure"),
                rightTxt = Lang:toText("gui_cancel"),
                leftCb = function() end,
                rightCb = function() end

            }
    )
end)
Lib.subscribeEvent(Event.EVENT_COMMON_NOTICE,function(content)
    UI:openWnd("ninjaCommonDialog"):initView(
            {
                content = content,
                contentCenter = true,
                txtTitle = Lang:toText("gui_tip"),
                hideClose = true,
            }
    )
end)