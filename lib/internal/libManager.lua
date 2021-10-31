local libManager = {}

local eventList = {}

function libManager.registerEvent(lib, eventname, fname, isEarly)
	local early = (isEarly == nil and true) or isEarly
	
	eventList[early] = eventList[early] or {}
	eventList[early][fname or eventname] = eventList[early][fname or eventname] or {}
	
	table.insert(eventList[early][fname or eventname], 
		{
			library = lib, 
			call = lib[fname or eventname]
		}
	)
end

function libManager.defineRegistering(tab, typ, n)
	return function(typ_num, lib, eventname, fname, isEarly)
		local name = fname or eventname
		
		if string.find(name, n) then
			name = name:gsub(n, "")
		else
			return
		end
		
		local early = (isEarly == nil and true) or isEarly
		
		eventList[early] = eventList[early] or {}
		eventList[early][name] = eventList[early][name] or {}
		
		table.insert(eventList[early][name], 
			{
				library = lib, 
				call = lib[fname or eventname],
				object = {tab, typ, typ_num},
			}
		)	
	end
end

do
	local function call(t, ...)
		for k,v in ipairs(t) do
			local obj = v.object
	
			if obj then
				for k,n in ipairs(obj[1]) do
					if n[obj[2]] == obj[3] then
						v.call(n, ...)
					end
				end
			else
				v.call(...)
			end
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