local libManager = {}

local eventList = {}

function libManager.registerEvent(lib, eventname, fname, isEarly)
	local early = (isEarly == nil and true) or isEarly
	
	eventList[early] = eventList[early] or {}
	eventList[early][eventname] = eventList[early][eventname] or {}
	
	table.insert(eventList[early][eventname], 
		{
			library = lib, 
			call = lib[fname or eventname]
		}
	)
end

-- function libManager.defineRegistering(tab, type)
	-- return function(id, lib, eventname, fname, isEarly)
		-- local early = (isEarly and 1) or 2

		-- eventList[early] = eventList[early] or {}
		-- eventList[early][eventname] = eventList[early][eventname] or {}
		
		-- local f = function(...)
			-- for k,v in ipairs(tab) do
				-- lib[fname or eventname](v, ...)
			-- end
		-- end
		
		-- table.insert(eventList[early][eventname], 
			-- {
				-- library = lib, 
				-- call = f
			-- }
		-- )
	-- end
-- end

do
	local function call(t, ...)
		for k,v in ipairs(t) do
			v.call()
		end
	end

	function libManager.callEvent(name, ...)
		if eventList[true] and eventList[true][name] then
			call(eventList[true][name], ...)
		end
		
		if eventList[false] and eventList[false][name] then
			call(eventList[true][name], ...)
		end
	end
end

registerFunction = libManager.registerEvent

return libManager