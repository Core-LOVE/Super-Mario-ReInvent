debug = true

--[[loading important libs]]
require 'scripts/base/require'
require 'objectify'
require 'print'
inspect = require 'inspect'

--[[loading parsers]]
ini = require 'parser/ini'

--[[lua stuff]]
require 'table'
require 'math'

--[[engine stuff]]
require 'color'
require 'graphics'
require 'sound'
-- require 'audio'

--[[eventmanager and etc]]
require 'eventManager'

--[[level classes]]
require 'level/camera'
require 'level/block'

for i = 0, 16 do
	Block.spawn(1, i * 32, i * 32)
end

-- function love.load()
	-- for i = 1, 8 do
		-- Sound.play(1)
	-- end
-- end


function love.update()
	if love.keyboard.isDown 'left' then
		camera.x = camera.x - 1
	elseif love.keyboard.isDown 'right' then
		camera.x = camera.x + 1
	end
	
	EventManager.callEvent("onTick")
	EventManager.callEvent("onTickEnd")
end

function love.draw()
	EventManager.callEvent("onDraw")
	Block.internalDraw()
	EventManager.callEvent("onDrawEnd")
	
	Graphics.internalDraw()
end