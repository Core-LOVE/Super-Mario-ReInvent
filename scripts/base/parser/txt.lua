local txt = {}

function txt.open(fileName)
	local path = File.resolve(fileName)

	if path == nil then
		return path
	end
	
	local t = {}

	for line in File.lines(fileName) do
		local key, val = line:match('^([%w|_]+)%s-=%s-(.+)$')

		if key ~= nil and val ~= nil then
			local ton = tonumber(val)
			if ton ~= nil then
				val = ton
			end
			
			t[key] = val
		end
	end
	
	return t
end

return txt