---@param name string
---@param func fun(param:cfg, param:context):nil
function Lib.registerTriggerHandler(name, func)
	Lib.subscribeEvent(Event.EVENT_CHECK_TRIGGERS, function(cfg, event_name, context)
		if event_name == name then
			func(cfg, context)
		end
	end)
end

---@param str string
---@param reps string
---@param keep_blank boolean
---@param to_number boolean
function Lib.split(str, reps, keep_blank, to_number)
	local result = {}
	if str == nil or reps == nil then
		return result
	end

	keep_blank = keep_blank or false
	if keep_blank then
		local startIndex = 1
		while true do
			local lastIndex = string.find(str, reps, startIndex)
			if not lastIndex then
				table.insert(result, string.sub(str, startIndex, string.len(str)))
				break
			end
			table.insert(result, string.sub(str, startIndex, lastIndex - 1))
			startIndex = lastIndex + string.len(reps)
		end
	else
		string.gsub(str, '[^' .. reps .. ']+', function(w)
			table.insert(result, w)
		end)
	end

	to_number = to_number or false
	if to_number then
		for i = 1, #result do
			result[i] = tonumber(result[i])
		end
	end

	return result
end