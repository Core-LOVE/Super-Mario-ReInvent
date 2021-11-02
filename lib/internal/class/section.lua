local Section = {}

function Section.spawn(x, y, w, h)
	local v = {}
	
	v.x = x
	v.y = y
	v.width = w or 800
	v.height = h or 600
	v.renderBackground = true
	v.background = 1
	
	setmetatable(v, {__index = Section})
	Section[#Section + 1] = v
	return v
end

function Section.onCameraDraw(cam)
	for k,v in ipairs(Section) do
		if v.renderBackground then
			local bg = Background(v.background)
			bg:render(v, cam)
		end
	end
end

function Section.onInit()
	registerFunction(Section, 'onCameraDraw')
end

return Section