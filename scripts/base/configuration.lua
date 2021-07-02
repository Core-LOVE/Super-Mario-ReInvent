Configuration = {}

Configuration.create = function(name, t)
	local t = t or {}
	
	setmetatable(t, {__index = function(self, k)
		local path = 'config/' .. name .. '/' .. name .. '-' .. k .. '.txt'
		local custom = {}
		
		if love.filesystem.getInfo(path) then
			custom = txt.load(path)
		end
		
		setmetatable(custom, {__index = function(_, key)
			return t[key]
		end})
		
		rawset(self, k, custom)
		return rawget(self, k)
	end})
	
	return t
end