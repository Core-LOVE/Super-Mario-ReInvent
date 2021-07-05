Level = {}

Level.current = {
	pathName = "",
	
	fileFolder = "",
	levelFolder = "",
	
	name = "",
	content = "",
}

function Level.getName()
	return Level.current.name
end

function Level.filename()
	return Level.current.pathName
end

function Level.load(path)
	return levelParser.load(path)
end

do
	local function remove(name)
		local class = _G[name]
		
		for k = 1, #class do
			class[k] = nil
		end
	end

	function Level.unload()
		remove 'Block'
		remove 'NPC'
		remove 'BGO'
		
		Level.current = {
			pathName = "",
			name = "",
			content = "",
		}
	end
end