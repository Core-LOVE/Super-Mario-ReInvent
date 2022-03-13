local Keys = {}

local keyCache = {}

KEY_UP = nil
KEY_DOWN = true
KEY_PRESSED = 1
KEY_RELEASED = 0

function Keys.onTickEnd()
	for key,val in pairs(keyCache) do
		if val == KEY_RELEASED then
			keyCache[key] = nil
		elseif val == KEY_PRESSED then
			keyCache[key] = KEY_DOWN
		end
	end
end

function Keys.onKeyPressed(key)
	keyCache[key] = KEY_PRESSED
end

function Keys.onKeyReleased(key)
	keyCache[key] = KEY_RELEASED
end

function Keys.get(name)
	local key = keyCache[name]
	
	return (key == nil and KEY_UP) or key
end

function Keys.onInit()
	registerEvent(Keys, 'onTickEnd')
	registerEvent(Keys, 'onKeyReleased')
	registerEvent(Keys, 'onKeyPressed')
end

return Keys