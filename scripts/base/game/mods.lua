Mods = {}
Mods.current = nil

-- function Mods.load(name)
	-- local m = rawRequire('mods/' .. name)
	
	-- return m
-- end

-- do
	-- local conf = ini.load 'config/mod.ini'
	-- Mods.current = conf.main.current
	
	-- Mods.load(Mods.current)
-- end

-- do
	-- local check = function(path)
		-- local success = pcall(function()
			-- return rawRequire(path)
		-- end)
		
		-- if success then
			-- return path
		-- end
	-- end
	
	-- local req = function(path)
		-- local name = check('mods/' .. Mods.current .. '/' .. 'scripts/' .. path) or check('mods/' .. Mods.current .. '/' .. 'scripts/base/' .. path) or 
		-- check('mods/' .. Mods.current .. '/' .. 'scripts/base/lua/' .. path) or check('mods/' .. Mods.current .. '/' .. 'scripts/base/engine/' .. path) or 
		-- check('mods/' .. Mods.current .. '/' .. 'scripts/base/game/' .. path)
		
		-- if not name then
			-- name = check('scripts/' .. path) or check('scripts/base/' .. path) or check('scripts/base/lua/' .. path) or check('scripts/base/engine/' .. path) or check('scripts/base/game/' .. path)
		-- end
		
		-- assert(name ~= nil,"Module '".. path.. "' not found.")
		
		-- local lib = rawRequire(name)
		
		-- if type(lib) == 'table' then
			-- if type(lib.onInitAPI) == 'function' then
				-- lib.onInitAPI()
			-- end
		-- end
		
		-- return lib
	-- end
	
	-- require = function(path)
		-- return req(path)
	-- end
-- end