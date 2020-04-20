
local Region = World.Region
local RegionCamera = require "world.region.region_camera"
local RegionShop = require "script_client.world.region.region_shop"
local eventRegionMap = {
	["camera"] = RegionCamera,
	["shop"] = RegionShop,
	["sell"] = nil,
	["safe"] = nil,
}

function Region:findTargetTypeRegion()
	local cfg = self.cfg
	local type = cfg.type
	if not type then
		return
	end
	return eventRegionMap[type]
end

function Region:onEntityEnter(entity)
	local targetRegion = self:findTargetTypeRegion()
	if not targetRegion then
		return
	end

	if not entity.isPlayer then
		return
	end

	if entity.objID ~= Me.objID then
		return
	end

	targetRegion:onEntityEnter(entity, self.cfg)
end

function Region:onEntityLeave(entity)
	local targetRegion = self:findTargetTypeRegion()
	if not targetRegion then
		return
	end

	if not entity.isPlayer then
		return
	end

	if entity.objID ~= Me.objID then
		return
	end

	local targetRegion = self:findTargetTypeRegion()
	targetRegion:onEntityLeave(entity, self.cfg)
end

