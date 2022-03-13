-- libs
Engine = require 'engine'
libManager = require 'libManager'
Keys = require 'keys'
SaveData, GameData = require 'data'
Graphics = require 'graphics/graphics'
Collision = require 'collision/collision'
Defines = require 'defines'

-- parsers
txt = require 'parser/txt'
ini = require 'parser/ini'

-- classes
Effect = require 'class/effect'
Section = require 'class/section'
BGO = require 'class/bgo'
Block = require 'class/block'
NPC = require 'class/npc'
Player = require 'class/player'
Camera = require 'class/camera'
-- Camera.type = CAMTYPE.HORZ

-- other
Episode = require 'episode'
Level = require 'level'

Level.open('intro.lvlx')
-- Episode.open('the invasion 2')

function love.update()
	-- for k,p in ipairs(Player) do
		-- if love.keyboard.isDown 'down' then
			-- p.y = p.y + 8 * Engine.speed
		-- end
		-- if love.keyboard.isDown 'up' then
			-- p.y = p.y - 8 * Engine.speed
		-- end
		-- if love.keyboard.isDown 'left' then
			-- p.x = p.x - 8 * Engine.speed
		-- end
		-- if love.keyboard.isDown 'right' then
			-- p.x = p.x + 8 * Engine.speed
		-- end
	-- end
	
	libManager.callEvent('onLoop')
	
	libManager.callEvent('onInputUpdateInternal')
	libManager.callEvent('onInputUpdate')
	
	libManager.callEvent('onTick')
	libManager.callEvent('onTickInternal')
	libManager.callEvent('onTickEnd')
end
-- camera2.x = camera.x
-- camera2.y = camera.y

function love.draw()
	libManager.callEvent('onDraw')
	
	for k = 1, #Camera do
		local c = Camera[k]
		
		if not c.isHidden then
			libManager.callEvent('onCameraDraw', c)
			libManager.callEvent('onHUDDraw', c)
			libManager.callEvent('onDrawInternal', c)
		end
	end
	
	libManager.callEvent('onDrawEnd')
end

function love.keypressed(key, scancode, isrepeat)
	libManager.callEvent('onKeyPressed', key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
	libManager.callEvent('onKeyReleased', key, scancode)
end

-- local str = [[cool = 0
-- beep = 0
-- ]]

-- for key, val in string.gmatch(str, '(%w+)%s*=%s*(%w+)') do
	-- print(key, val)
-- end