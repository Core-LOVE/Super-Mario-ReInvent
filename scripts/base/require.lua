rawRequire = require

do
	local check = function(path)
		local success = pcall(function()
			return rawRequire(path)
		end)
		
		if success then
			return path
		end
	end
	
	local req = function(path)
		local name = check('scripts/' .. path) or check('scripts/base/' .. path) or check('scripts/base/lua/' .. path) or check('scripts/base/engine/' .. path)
		assert(name ~= nil,"Module '".. path.. "' not found.")
		
		local lib = rawRequire(name)
		
		if type(lib) == 'table' then
			if type(lib.onInitAPI) == 'function' then
				lib.onInitAPI()
			end
		end
		
		return lib
	end
	
	require = function(path)
		return req(path)
	end
end