require "common.gm"
local GMItem = GM:createGMItem()

GMItem["g2020/特权商店"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_PRI_SHOP, true)
end

GMItem["g2020/金币商店"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_GOLD_SHOP, true)
end

GMItem["g2020/打工按钮"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_WORK_DETAILS, true)
end

GMItem["g2020/签到"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_NEW_SIGIN_IN, true)
end

GMItem["g2020/派对设置"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_PARTY_SETTING, true)
end

GMItem["g2020/派对内部设置"] = function()
    Lib.emitEvent(Event.EVENT_SHOW_PARTY_INNER_SETTING, true, {inPartyOwnerId = 18512})
end

GMItem["g2020/关闭引导"] = function()
    local packet ={
        pid = "GMGuide",
        close = true
    }
    Lib.emitEvent(Event.EVENT_GUIDE_GM, packet)
end

GMItem["g2020/重置引导"] = function()
    local packet = {
        pid = "GMGuide",
        reset = true
    }
    Lib.emitEvent(Event.EVENT_GUIDE_GM, packet)
end

GMItem["g2020/派对列表"] = function()
    UI:openWnd("party_list")
end

local function dumpCSV(fileName, data)
    local misc = require "misc"
    local csv_encode = misc.csv_encode
    local header = { "id", "areaId", "x", "y", "z", "blockId"}
    local list = { csv_encode(header) }
    local index = 0
    for k , items in pairs(data) do
        for id, poss in pairs(items) do
            for _, pos in pairs(poss) do
                index = index + 1
                table.insert(list, csv_encode({index, k, pos.x, pos.y, pos.z, id }))
            end
        end
    end
    return misc.write_utf16(fileName, table.concat(list, "\n"))
end

GMItem["g2020/导出坐标"] = function()

    local config = {}
    local files = Lib.readGameCsv("export_block_config.csv") or {}
    for _ , item in ipairs(files) do
        local newItem = {}
        newItem.min = {x = tonumber(item.minX), y = tonumber(item.minY), z = tonumber(item.minZ) }
        newItem.max = {x = tonumber(item.maxX), y = tonumber(item.maxY), z = tonumber(item.maxZ) }
        newItem.areaId = item.areaId
        newItem.blocks = Lib.splitIncludeEmptyString(item.blocks, "," )
        table.insert(config, newItem)
    end

    local items = {}
    local mapping = Lib.readGameJson("id_mappings.json") or {}

    for _, v in pairs(config) do
        local min = v.min
        local max = v.max
        local blocks = v.blocks or {}
        if v.mapName == Me.map.name or not v.mapName then

            for x = min.x, max.x do
                for y = min.y, max.y do
                    for z = min.z, max.z do
                        local blockName = Me.map:getBlock({x = x, y = y, z = z}).fullName
                        for _, block in pairs(blocks) do
                            if mapping.block[tostring(block)] == blockName then
                                local area = items[tostring(v.areaId)]
                                if not area  then
                                    area = {}
                                    items[tostring(v.areaId)] = {}
                                end
                                local poss = area[tostring(block)] or {}
                                table.insert(poss, {x= x, y = y, z =z})
                                items[tostring(v.areaId)][tostring(block)] = poss
                                break
                            end
                        end
                    end
                end
            end

        end
    end
    local path2 = Root.Instance():getGamePath() .. Me.map.name .. "_export_block_pos.csv"
    dumpCSV(path2, items)
end


local function dumpCSV2(fileName, data)
    local misc = require "misc"
    local csv_encode = misc.csv_encode
    local header = { "id", "areaId", "x", "y", "z", "blockId"}
    local list = { csv_encode(header) }
    for k , item in pairs(data) do
        table.insert(list, csv_encode({k, item.areaId, item.x, item.y, item.z, item.id }))
    end
    return misc.write_utf16(fileName, table.concat(list, "\n"))
end

GMItem["g2020/导出方块ID"] = function()

    local config = {}
    local files = Lib.readGameCsv("export_block_config.csv") or {}
    for _ , item in ipairs(files) do
        local newItem = {}
        newItem.min = {x = tonumber(item.minX), y = tonumber(item.minY), z = tonumber(item.minZ) }
        newItem.max = {x = tonumber(item.maxX), y = tonumber(item.maxY), z = tonumber(item.maxZ) }
        newItem.areaId = item.areaId
        table.insert(config, newItem)
    end

    local items = {}

    for _, v in pairs(config) do
        local min = v.min
        local max = v.max
        if v.mapName == Me.map.name or not v.mapName then
            for x = min.x, max.x do
                for y = min.y, max.y do
                    for z = min.z, max.z do
                        local block = {}
                        block.id = Me.map:getBlockConfigId({x = x, y = y, z = z})
                        block.x = x
                        block.y = y
                        block.z = z
                        block.areaId = v.areaId
                        table.insert(items, block)
                    end
                end
            end

        end
    end
    local path2 = Root.Instance():getGamePath() .. Me.map.name .. "_export_block_id.csv"
    dumpCSV2(path2, items)
end

return GMItem
