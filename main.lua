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
require 'text'
-- require 'audio'

--[[eventmanager and etc]]
require 'eventManager'
playerManager = require 'manager/playerManager'

--[[level classes]]
require 'level/camera'
require 'level/block'
require 'level/bgo'
require 'level/section'
require 'level/playerSettings'
require 'level/player'
require 'level/levelHud'

levelParser.load('tl/a couple blocks.lvlx')

-- function love.load()
	-- for i = 1, 8 do
		-- Sound.play(1)
	-- end
-- end

function love.load()
	Camera.type = 0
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
	
	EventManager.callEvent("onTick")
	Camera.update()
	EventManager.callEvent("onCameraUpdate")
	EventManager.callEvent("onTickEnd")
end

function love.draw()
	EventManager.callEvent("onDraw")
	Block.internalDraw()
	Player.internalDraw()
	LevelHUD.internalDraw()
	EventManager.callEvent("onDrawEnd")
	
	Graphics.internalDraw()
	
	EventManager.callEvent("onCameraDraw")
end