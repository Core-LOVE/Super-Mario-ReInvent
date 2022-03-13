local Section = {}

function Section.new(x, y, w, h)
	local v = {}
	
	v.idx = (#Section + 1)
	
	v.x = x
	v.y = y
	v.width = w
	v.height = h
	
	Section[#Section + 1] = v
	setmetatable(v, {__index = Section})
	return v
end

setmetatable(Section, {__call = function(self, idx)
	return self[idx]
end})

return Section