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
	
	return v
end

_G.Section = Objectify(section)