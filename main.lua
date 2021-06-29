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
require 'level/npc'
require 'level/bgo'
require 'level/background'
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
	camera2.x = camera.x
	camera2.y = camera.y
	
	EventManager.callEvent("onTick")
	Camera.update()
	EventManager.callEvent("onCameraUpdate")
	EventManager.callEvent("onTickEnd")
end

local function scale()

end

function love.draw()
	scale()
	
	EventManager.callEvent("onDraw")
	
	Background.render{
		section = 2,
		
		layers = {
			['BG'] = {
				img=1,
				alignY=BOTTOM,
				parallaxX=0.5,
				parallaxY=1,
				repeatX=true,
			},
						
			['Clouds'] = {
				img=2,
				parallaxX=0.25,
				parallaxY=1,
				alignY=BOTTOM,
				y=-500,
				repeatX=true,
			}
		}
	}
	
	Block.internalDraw()
	NPC.internalDraw()
	Player.internalDraw()
	LevelHUD.internalDraw()
	Game.drawMenu()
	
	EventManager.callEvent("onDrawEnd")
	
	Graphics.internalDraw()
	
	EventManager.callEvent("onCameraDraw")
end

function love.resize(w, h)
	if Game.widescreen then
		Game.width = w
		Game.height = h
	end
end