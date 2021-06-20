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
-- require 'camera'

print(inspect(string))
local img = Graphics.loadImage 'graphics/e.png'

function love.draw()
	Graphics.draw{
		image = img,
		priority = -1
	}
	
	Graphics.draw{
		image = img,
		x = 24,
		priority = -2,
	}
	
	Graphics.internalDraw()
end