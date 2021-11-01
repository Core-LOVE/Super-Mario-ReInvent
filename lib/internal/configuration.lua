-- for creating object's configuration
return function(name, fields)
	local tab = {}
	
	setmetatable(tab, {__index = function(self, ind)
		local v = {}
		local fields = fields or {}
		
		local filename = File.exists(name .. '-' .. ind .. '.txt', {
			'config/npc/',
		})
		
		if filename then
			local file = txt.load(filename)
		
			v = table.merge(v, file)
		end
		
		setmetatable(v, {__index = function(self, key)
			return fields[key]
		end})

		rawset(self, ind, v)
		return rawget(self, ind)
	end})
	
	return tab
end