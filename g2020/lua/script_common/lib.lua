

local stackManager = {}
local function getEntityTypeStack(entity, stackType)
	local stackData = entity and entity:data("stackData") or stackManager
	stackData.stack = stackData.stack or {}
	local stack = stackData.stack
	if not stack[stackType] then
		stack[stackType] = {}
	end
	return stack[stackType]
end

function Lib.ResetStack(entity, stackType)
	local typeStack = getEntityTypeStack(entity, stackType or "stack")
	typeStack = {}
end

function Lib.PopStack(entity, stackType)
	local typeStack = getEntityTypeStack(entity, stackType or "stack")
	local now = World.Now()
	typeStack[#typeStack] = nil
	for i=#typeStack, 1, -1 do
		local element = typeStack[i] or {}
		if (element.endTime or 0) < now then
			table.remove(typeStack, i)
		end
	end
	local ret = typeStack[#typeStack]
	return ret
end

function Lib.RegStack(entity, stackType, time, func)
	local typeStack = getEntityTypeStack(entity, stackType or "stack")
	typeStack[#typeStack + 1] = {
		func = func,
		endTime = World.Now() + time or 0
	}
end
