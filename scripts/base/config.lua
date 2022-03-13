local Config = {}
local txt = require 'parser/txt'

function Config.new(name, default)
	local cfg = {}
	local default = default

	setmetatable(cfg, {__index = function(self, id)
		local t = {}
		local path = (name .. '-'  .. id .. '.txt')
		local defaultFile = txt.open(path)
		
		if not defaultFile then
			defaultFile = txt.open('config/' .. name .. '/' .. path)
		end
		
		defaultFile = defaultFile or {}
		setmetatable(defaultFile, {__index = default})
		
		setmetatable(t, {__index = defaultFile})
		rawset(self, id, t)
		return rawget(self, id)
	end})
	return cfg
end

return Config