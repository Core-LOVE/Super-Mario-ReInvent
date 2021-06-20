rawRequire = require

do
	local check = function(path)
		print('...')
		print(path)
		local success = pcall(function()
			return rawRequire(path)
		end)
		
		print(success)
		if success then
			return path
		end
	end
	
	local req = function(path)
		local name = check('scripts/' .. path) or check('scripts/base/' .. path) or check('scripts/base/lua/' .. path) or check('scripts/base/engine/' .. path)
		assert(name ~= nil,"Module '".. path.. "' not found.")
		
		local lib = rawRequire(name)
		
		return lib
	end
	
	require = function(path)
		return req(path)
	end
end