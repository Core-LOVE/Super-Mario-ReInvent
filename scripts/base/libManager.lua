local libManager = {}

local events = {}

function libManager.callEvent(name, ...)
	local t = events[name]
	
	if t == nil or #t == 0 then return end
	
	for k = #t, 1, -1 do
		local event = t[k]
		local call = event.lib[event.name]
		local iterator = event.iterator
		
		if call then
			if type(iterator) == 'function' then
				for k,v in iterator(event.id) do
					call(v, ...)
				end
			elseif type(iterator) == 'table' then
				for k,v in ipairs(iterator) do
					if v.id == event.id then
						call(v, ...)
					end
				end
			else
				call(...)
			end
		end
	end
end

do
	local table = table
	local tableSort = table.sort
	local tableInsert = table.insert
	
	local function sort(a, b)
		return (a.isEarly)
	end
	
	function libManager.rawRegisterEvent(lib, trueName, early)
		local ev = {
			lib = lib,
			name = trueName,
			isEarly = early,
		}
		
		return ev
	end
	
	local rawRegisterEvent = libManager.rawRegisterEvent
	
	function libManager.registerEvent(lib, name, name2, early)
		local trueName = (name2 or name)
		events[trueName] = events[trueName] or {}
		
		local ev = rawRegisterEvent(lib, trueName, early)

		tableInsert(events[trueName], ev)
		tableSort(events[trueName], sort)
		return ev
	end
	
	function libManager.registerCustomEvent(iterator, className)
		return function(id, lib, name, name2, ...)
			local trueName = (name2 or name)
			local realName = trueName:gsub(className .. '$', '')

			local ev = rawRegisterEvent(lib, trueName, ...)

			ev.iterator = iterator
			ev.id = id

			events[realName] = events[realName] or {}
			tableInsert(events[realName], ev)
			tableSort(events[realName], sort)
			return ev
		end
	end
end

registerEvent = libManager.registerEvent
return libManager