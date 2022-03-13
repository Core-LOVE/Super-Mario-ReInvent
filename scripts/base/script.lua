local script = {}

function script.load(name, id, constant)
	script[name] = script[name] or {}
	
	if script[name][id] then return end
	
	script[name][id] = true
	
	_G[constant] = id
	
	local path = ('scripts/' .. name .. '/' .. name .. '-' .. id)
	
	if File.resolve(path .. '.lua') then
		require(path)
	else
		local path = name .. '-' .. id
		
		if File.resolve(path .. '.lua') then
			require(path)
		end
	end
	
	_G[constant] = nil
end

return script