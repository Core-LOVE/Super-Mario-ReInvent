local Color = {}

local mt = {}

function mt.__index(self, index)
	if index == 4 then
		return 1
	end
end

function mt.__concat(a, b)
	a[4] = b
	return a
end

function Color.new(r, g, b, a)
	local args = {}
	
	if type(r) == 'table' then
		args = r
	else
		args = {r, g, b, a or 1}
	end
	
	setmetatable(args, mt)
	return args
end

do
	local tn = function(str, f, s)
		return tonumber('0x' .. str:sub(f, s)) / 255
	end
	
	function Color.hex(str)
		local r = tn(str, 1, 2)
		local g = tn(str, 3, 4)
		local b = tn(str, 5, 6)
		local a = 1
		
		if #str > 6 then
			a = tn(str, 7, 8)
		end
		
		return Color.new(r, g, b, a)
	end
end

local colors = {}

colors.white = function()
	return Color.new(1, 1, 1)
end

colors.gray = function()
	return Color.new(.5, .5, .5)
end

colors.darkgray = function()
	return Color.new(.25, .25, .25)
end

colors.black = function()
	return Color.new(0, 0, 0)
end

colors.red = function()
	return Color.new(1, 0, 0)
end

colors.green = function()
	return Color.new(0, 1, 0)
end

colors.blue = function()
	return Color.new(0, 1, 0)
end

setmetatable(Color, {
	__call = function(self, t)
		if type(t) == 'table' then
			return Color.new(t)
		else
			return Color.hex(t)
		end
	end,
	
	__index = function(self, key)
		if colors[key] then
			return colors[key]()
		end
	end,
})

return Color