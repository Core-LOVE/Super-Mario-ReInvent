nfs = require 'nativefs'

do
	love.graphics.clear()
	
	love.graphics.draw(love.graphics.newImage 'graphics/ui/LoadCoin.png', 800 - 48, 600 - 48)
	
	love.graphics.present()
end

_PATH = love.filesystem.getSourceBaseDirectory():gsub([[\]], '/') .. '/'
debug = true

--[[loading important libs]]
require 'scripts/base/engine/level/level'
require 'scripts/base/require'

--[[lua stuff]]
require 'scripts/base/lua/table'
require 'scripts/base/lua/math'
require 'scripts/base/lua/io'

--[[loading parsers]]
ini = require 'parser/ini'
txt = require 'parser/txt'

--[[game parsers...]]
levelParser = require 'parser/levelParser'

--[[less important...]]
require 'objectify'
require 'configuration'
require 'print'
inspect = require 'inspect'
require 'version'

--[[mods loading]]
require 'game/mods'

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
blockManager = require 'manager/blockManager'
npcManager = require 'manager/npcManager'

--[[global classes]]
require 'game/effect'

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

-- function love.load()
	-- for i = 1, 8 do
		-- Sound.play(1)
	-- end
-- end

do
	local code = [[
	
		local file = io.read("*line")
	]]
	
	thread = love.thread.newThread(code)
	thread:start()
end

function love.load()
	Level.load('D:/MyGames/Super-Mario-ReInvent/tl/a couple blocks.lvlx')
	
	Camera.type = 1
end

function love.update()
	if Keys.pressed.delay > 0 then
		Keys.pressed.delay = Keys.pressed.delay - 1
	end
	
	camera2.x = camera.x
	camera2.y = camera.y
	
	EventManager.callEvent("onTick")
	
	NPC.update()
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

function love.keypressed(key, scan, rep)
	if Keys.pressed.delay > 0 then return end
	
	Keys.pressed.key = key
	Keys.pressed.scancode = scan
	Keys.pressed.isrepeat = rep
end