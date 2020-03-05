local setting = require "common.setting"

function UILib.openShopBuy(fullName, callback, coinId, price, desc, tip)
    local cfg = setting:fetch("item", fullName)
    local args = {}
	args.btnText = "gui.go.buy"
	args.msgText = desc or cfg.hintDesc
    args.mainImage = cfg.hintImage
	args.hitIcon =  Coin:iconByCoinId(coinId)
	args.titleText = tip or cfg.itemname
	args.hitText = price or cfg.hintPrice
	UI:openWnd("alternativeUI",args, callback)
end