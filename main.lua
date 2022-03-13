--[[local path = love.filesystem.getSaveDirectory( )

function love.draw()
	love.graphics.print(path, 32, 32)
end
if true then return end
]]
File = require 'file'

-- replace maaaybe?
local gPath = File.path[1]

File.path = {
	'',
	'',
	gPath,
}

local function define(k)
	local File = File
	local path = File.path
	
	return function(v)
		if not v then
			return path[k]
		end	

		path[k] = v
	end
end

gamePath = define(3)
episodePath = define(2)
levelPath = define(1)

love.filesystem.setRequirePath("?.lua;?/init.lua;scripts/?.lua;scripts/?/init.lua;scripts/base/?.lua;scripts/base/?/init.lua")

require = function(path)
	if package.preload[path] then
		return package.preload[path]
	end
	
	local lib = File.require(path)
	
	if type(lib) == 'table' and type(lib.onInit) == 'function' then
		lib.onInit()
	end
	
	return lib
end

module = require
dofile = File.doFile
loadfile = File.loadFile

-- turn off...
love.filesystem = nil
love.audio = nil

-- load main file plz
dofile 'scripts/base/init.lua'