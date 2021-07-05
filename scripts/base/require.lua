local function checkPath(path)
	if nfs.read(path) ~= nil then
		return path
	end
end

local open = function(path)
	local c = Level.current
	local path = checkPath(c.levelFolder .. path) or checkPath(c.fileFolder .. path) or checkPath(_PATH .. path) or checkPath(path)
	
	return path
end

do
	rawLoadfile = loadfile
	
	loadfile = function(filename)
		return nfs.load(open(filename))
	end
end

dofile = function(filename)
    local f = loadfile(filename)
	return f()
end

rawRequire = function(path)
	return dofile(path .. '.lua')
end

do
	local check = function(path)
		local success = nfs.getInfo(path .. '.lua')

		if success then
			return path
		end
	end
	
	local req = function(path, noerror)
		local c = Level.current
		
		local name = check(c.levelFolder .. path) or check(c.fileFolder .. path)
		
		if not name then
			name = check(_PATH .. 'scripts/' .. path) or check(_PATH .. 'scripts/base/' .. path) or check(_PATH .. 'scripts/base/lua/' .. path) or 
			check(_PATH .. 'scripts/base/engine/' .. path) or check(_PATH .. 'scripts/base/game/' .. path) or check(_PATH .. path)
		end
		
		if not noerror then
			assert(name ~= nil,"Module '".. path.. "' not found.")
		else
			if not name then
				return nil
			end
		end
		
		local lib = rawRequire(name)
		
		if type(lib) == 'table' then
			if type(lib.onInitAPI) == 'function' then
				lib.onInitAPI()
			end
		end
		
		return lib
	end
	
	require = req
end