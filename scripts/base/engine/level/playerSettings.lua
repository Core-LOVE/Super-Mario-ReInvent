PlayerSettings = {}

MAX_POWERUPS = 7

local function convIndexCoorToSpriteIndex(x, y)
    return (y + 10 * x) - 49;
end

function PlayerSettings.load(character)
	if not PlayerSettings[character] then
		PlayerSettings[character] = {}
		
		PlayerSettings[character].FrameX = {}
		PlayerSettings[character].FrameY = {}	
		
		for i = 1, MAX_POWERUPS do
			local file = ini.load('config/' .. character .. '/' .. character .. '-' .. i .. '.ini')
			
			PlayerSettings[character][i] = {}
			
			for k,v in pairs(file) do
				if k ~= 'common' then
					local x = k:sub(7,7)
					local y = k:sub(9,9)
					
					PlayerSettings[character].FrameX[convIndexCoorToSpriteIndex(x,y) + i * 100] = v.offsetX
					PlayerSettings[character].FrameY[convIndexCoorToSpriteIndex(x,y) + i * 100] = v.offsetY
				else
					PlayerSettings[character][i].width = v.width
					PlayerSettings[character][i].height = v.height
					PlayerSettings[character][i].duckHeight = v['height-duck']
					PlayerSettings[character][i].grab_offsetX = v['grab-offset-x']
					PlayerSettings[character][i].grab_offsetY = v['grab-offset-y']
				end
			end
		end
	end
	
	return PlayerSettings[character]
end