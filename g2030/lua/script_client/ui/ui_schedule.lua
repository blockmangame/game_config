Lib.subscribeEvent(Event.EVENT_EXP_CHANGE, function()
    if not Me:isExpFull() then
        return
    end
    UI:openWnd("ninjaCommonDialog"):initView(
            {
                content = Lang:toText("gui_sell_exp_notice"),
                contentCenter = true,
                txtTitle = Lang:toText("gui_tip"),
                hideClose = false,
                leftTxt = Lang:toText("gui_no"),
                rightTxt = Lang:toText("gui_go"),
                leftCb = function() end,
                rightCb = function() Me:sellExp() end
    ---content 内容
    ---contentCenter 内容是否居中(默认靠左)
    ---imgTitle 图片标题
    ---txtTitle 文字标题
    ---hideClose 是否隐藏右上角关闭按钮
    ---leftTxt，leftCb，左按钮文字和回调
    ---rightTxt，rightCb，右按钮文字和回调
    }
    )
    end)