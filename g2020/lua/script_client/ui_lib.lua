local setting = require "common.setting"

function UILib.openShopBuy(hintImage, callback, coinId, price, desc, tip)
    local args = {}
	args.btnText = "gui.go.buy"
	args.msgText = desc
    args.mainImage = hintImage
	args.hitIcon =  Coin:iconByCoinId(coinId)
	args.titleText = tip
	args.hitText = price
	UI:openWnd("alternativeUI",args, callback)
end