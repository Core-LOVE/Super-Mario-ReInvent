local PlayerSettings = {}
local ini = require 'parser/ini'

PlayerSettings.charList = {
	[1] = 'mario',
}

PlayerSettings.maxPowerup = 7

function PlayerSettings.get(character, powerup)
	PlayerSettings[character] = PlayerSettings[character] or {}
	
	if PlayerSettings[character][powerup] then
		return PlayerSettings[character][powerup]
	end
	
	local settiings = {}
	local charName = PlayerSettings.charList[character]
	local path = (charName .. '-'  .. powerup .. '.ini')

	local file = ini.open(path)
	
	if not file then
		file = ini.open('config/' .. charName .. '/' .. path)
		assert(file ~= nil, 'No ini file for ' .. charName .. '!')
	end
	
	settiings.hitboxWidth = file.width
	settiings.hitboxHeight = file.height
	settiings.hitboxDuckHeight = file['height-duck']
	settiings.grabOffsetX = file['grab-offset-x']
	settiings.grabOffsetY = file['grab-offset-y']
	
	local function define(y)
		local n = (y == nil and 'X') or 'Y'
		local offset = 'offset' .. n
		
		settiings['getSpriteOffset' .. n] = function(self, indexX, indexY)
			local frame = file['frame-' .. indexX .. '-' .. indexY]
			
			if not frame then return 0 end
			
			return file['frame-' .. indexX .. '-' .. indexY][offset]
		end
		
		settiings['setSpriteOffset' .. n] = function(self, indexX, indexY, val)
			file['frame-' .. indexX .. '-' .. indexY][offset] = val
		end	
	end
	
	define()
	define(true)
	
	PlayerSettings[character][powerup] = settiings
	return settiings
end

do
	for character = 1, #PlayerSettings.charList do
		for powerup = 1, PlayerSettings.maxPowerup do
			PlayerSettings.get(character, powerup)
		end
	end
end

return PlayerSettings