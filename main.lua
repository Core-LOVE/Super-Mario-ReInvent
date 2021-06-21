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

--[[level classes]]
require 'level/camera'
require 'level/block'

Block.spawn(1, 0, 0)

function love.load()
	for i = 1, 8 do
		Sound.play(1)
	end
end

function love.draw()
	Block.internalDraw()
	
	Graphics.internalDraw()
end