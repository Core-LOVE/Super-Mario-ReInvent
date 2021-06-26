local character = {}
local id = CHARACTER

function character.onTickPlayer(v)

end

function character.onInitAPI()
	playerManager.registerEvent(id, character, 'onTickPlayer')
end

return character