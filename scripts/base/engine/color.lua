local Color = {}

local mt = {}

function mt.__concat(self, alpha)
	self[4] = alpha
	return self
end

function Color.add(t)
	local t = t or {1,1,1,1}
	t[4] = t[4] or 1
	
	setmetatable(t, mt)
	return t
end

Color.white = Color.add()
Color.gray = Color.add{0.5, 0.5, 0.5}
Color.black = Color.add{0,0,0}

_G.Color = Color