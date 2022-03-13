local Level = {}

local levelParser = require("parser/levelParser")

function Level.open(name)
	local path = File.resolve(name)
	
	local levelFolder = path:gsub('.' .. File.getExtension(path), "") .. '/'
	local episodeFolder = path:gsub(File.getNameExtension(path), '')
	
	episodePath(episodeFolder)
	levelPath(levelFolder)
	
	levelParser.parse(path)
	-- print(episodePath(), levelPath())
	-- print( gamePath())
end

function Level.fileName()

end

return Level