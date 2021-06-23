debug = true

--[[loading important libs]]
require 'scripts/base/require'
require 'objectify'
require 'print'
inspect = require 'inspect'

--[[loading parsers]]
ini = require 'parser/ini'
levelParser = require 'parser/levelParser'

--[[lua stuff]]
require 'table'
require 'math'

--[[engine stuff]]
require 'game'
require 'keys'
require 'color'
require 'graphics'
require 'sound'
-- require 'audio'

--[[eventmanager and etc]]
require 'eventManager'

--[[level classes]]
require 'level/camera'
require 'level/block'
require 'level/bgo'
require 'level/section'
require 'level/player'

levelParser.load('tl/a couple blocks.lvlx')

-- function love.load()
	-- for i = 1, 8 do
		-- Sound.play(1)
	-- end
-- end

function love.load()

end

function love.update()
	if Keys.isDown 'left' then
		camera.x = camera.x - 16
	elseif Keys.isDown 'right' then
		camera.x = camera.x + 16
	end
	
	if Keys.isDown 'up' then
		camera.y = camera.y - 16
	elseif Keys.isDown 'down' then
		camera.y = camera.y + 16
	end
	
	if Keys.isDown 'jump' then
		Player.spawn(1, camera.x + 100, camera.y + 100)
	end
	
	EventManager.callEvent("onTick")
	EventManager.callEvent("onTickEnd")
end

function love.draw()
	EventManager.callEvent("onDraw")
	Block.internalDraw()
	Player.internalDraw()
	EventManager.callEvent("onDrawEnd")
	
	Graphics.internalDraw()
end