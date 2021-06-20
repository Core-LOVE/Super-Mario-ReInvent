debug = true

--[[loading important libs]]
require 'scripts/base/require'
require 'objectify'
require 'print'

inspect = require 'inspect'

--[[lua stuff]]
require 'table'
require 'math'

--[[engine stuff]]
require 'color'
require 'graphics'

--[[level classes]]
require 'level/camera'
require 'level/block'

local img = Graphics.loadImage 'graphics/e.png'
local img2 = Graphics.loadImage 'graphics/b.png'

function love.draw()
	if love.keyboard.isDown 'right' then
		camera2.renderX = camera2.renderX + 1
	end
	
	if love.keyboard.isDown 'left' then
		camera2.renderX = camera2.renderX - 1
	end
	
	Graphics.draw{
		image = img,
		priority = -1,
		isSceneCoords = true
	}
	
	Graphics.draw{
		image = img,
		x = 24,
		priority = 2,
		isSceneCoords = true
	}
	
	Graphics.draw{
		image = img2,
		x = 800,
		priority = 2,
		isSceneCoords = true
	}
	
	Graphics.internalDraw()
end