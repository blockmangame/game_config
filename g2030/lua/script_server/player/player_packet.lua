---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/1 10:10
---
-- 调用具体看  handle_packet@player.player_packet
-- 此处packet使用只需要在sendPacket的pid字段传入想要调用的函数名即可，方法内的self是发包的player。

local handles = T(Player, "PackageHandlers")

function handles:createPetEntity(packet)

end

function handles:SyncItemShopOperation(packet)
    print(string.format("<events:SyncItemShopOperation(packet):> TypeId: %s  ItemId: %s", tostring(packet.tabId), tostring(packet.itemId)))
    Store.ItemShop:operationByType(self, packet.tabId, packet.itemId)
end