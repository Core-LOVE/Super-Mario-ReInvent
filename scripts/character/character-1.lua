local character = {}
local id = CHARACTER

local aX = 0
local aY = 0

function character.onTickPlayer(v)
	if Keys.isDown 'left' then
		aX = aX - 0.1
		v.x = v.x - aX
	end
	
	if Keys.isDown 'right' then
		aX = aX + 0.1
		v.x = v.x + aX
	end
end

function character.onInitAPI()
	playerManager.registerEvent(id, character, 'onTickPlayer')
end

return character