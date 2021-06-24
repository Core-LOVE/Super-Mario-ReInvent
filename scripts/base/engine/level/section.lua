local section = {}

section.fields = function()
	return {
		boundary = {
			left = 0,
			top = 0,
			right = 800,
			bottom = 600,
		},
		
		musicID = 0,
		musicPath = "",
		wrapH = false,
		wrapV = false,
		hasOffscreenExit = false,
		backgroundID = 0,
		background = nil,
		origBackgroundID = 0,
		noTurnBack = false,
		isUnderwater = false,
	}
end

function section.spawn(ID, bound, musID, musPath, bgID)
	local v = section.new{
		boundary = bound,
		
		musID = musID or 0,
		musPath = musPath or "",
		bgID = bgID or 0,
	}
	v.idx = ID
	
	section[ID] = v
	return v
end

function section.getIntersecting(x1,y1,x2,y2)
	local ret = {}
	
	for _,v in ipairs(section) do
		local b = v.boundary
		
		if b.left <= x2 and b.top <= y2 and b.right >= x1 and b.bottom >= y1 then
			ret[#ret + 1] = v
		end
	end

	return ret
end

_G.Section = Objectify(section)