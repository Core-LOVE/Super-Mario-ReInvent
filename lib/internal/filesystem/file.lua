local File = {}

File.levelPath = ""
File.episodePath = ""
File.gamePath = love.filesystem.getSourceBaseDirectory()

if not love.filesystem.isFused() then
    File.gamePath = File.gamePath .. '/SMR/'
end

do
	local function exists(name)
		return fs:isFile(name)
	end
	
	function File.exists(name, userplaces)
		local places = {
			File.levelPath,
			File.episodePath,
			File.gamePath,
		}
		
		if userplaces then
			for k,v in ipairs(userplaces) do
				places[#places + 1] = places[1] .. v
				places[#places + 1] = places[2] .. v
				places[#places + 1] = places[3] .. v
			end
		end
		
		local filename
		
		for k,v in ipairs(places) do
			local s = exists(v .. name)
			
			if s then
				filename = v .. name
			end
		end
		
		return filename
	end
end

function File.open(name, mode)
	local name = File.exists(name)

	return io.open(name, mode or "r")
end

function File.loadImage(name, paths)
	local name = File.exists(name, paths)

	return fs:loadImage(name)
end

function File.read(name, mode)
	local file = File.open(name, "r")
	local content = file:read(mode or "*a")
	
	file:close()
	return content
end

function File.lines(name)
	local name = File.exists(name)
	
	return io.lines(name)
end

function File.load(name, mode)
	local content = File.read(name, mode)
	
	return loadstring(content)
end

function File.dofile(name, mode)
	local f = assert(File.load(name, mode))
	
	return f()
end

do
	File.requirePaths = {
		'lib/',
		'lib/internal/',
		'lib/base/',
	}

	function File.require(name)
		if not package.loaded[name] then
			local n = File.exists(name .. '.lua', File.requirePaths)
			local lib = File.dofile(n)
			
			if type(lib) == 'table' and type(lib.onInit) == 'function' then
				lib.onInit()
			end
			
			package.loaded[name] = lib
		end
		
		return package.loaded[name]
	end
end

rawrequire = require
require = File.require
module = require
dofile = File.dofile
load = File.load
loadfile = load

return File