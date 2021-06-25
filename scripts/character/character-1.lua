local character = {}
local id = CHARACTER

function character.onTickPlayer(v)
	v.x = v.x + 1
end

function character.onInitAPI()
	playerManager.registerEvent(id, character, 'onTickPlayer')
end

return character