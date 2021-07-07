Configuration = {}

local function checkPath(path)
	if nfs.getInfo(path) ~= nil then
		return path
	end
end

local open = function(path)
	local c = Level.current
	local path = checkPath(c.levelFolder .. path) or checkPath(c.fileFolder .. path) or checkPath(_PATH .. path)
	
	return path
end

Configuration.create = function(name, t)
	local t = t or {}
	
	setmetatable(t, {__index = function(self, k)
		local path = open(name .. '-' .. k .. '.txt')
		
		if not path then
			path = open('config/' .. name .. '/' .. name .. '-' .. k .. '.txt')
		end
		
		local custom = {}
		
		for k,v in pairs(t) do
			custom[k] = v
		end
		
		if path then
			local fields = txt.load(path)
			
			for k,v in pairs(fields) do
				custom[k] = v
			end
		end
		
		rawset(self, k, custom)
		return rawget(self, k)
	end})
	
	return t
end