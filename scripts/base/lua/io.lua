io.rawOpen = io.open

do
	local function checkPath(path, mode)
		if io.rawOpen(path) ~= nil then
			return path
		end
	end

	io.open = function(path, mode)
		local c = Level.current
		local path = checkPath(c.levelFolder .. path, mode) or checkPath(c.fileFolder .. path, mode) or checkPath(_PATH .. path, mode) or checkPath(path, mode)
		
		return io.rawOpen(path, mode)
	end
end