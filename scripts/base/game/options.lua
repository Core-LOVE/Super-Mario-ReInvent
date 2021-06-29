local options = {}

function options.new()
	local v = {}
	
	v.cursor = 0
	
	setmetatable(v, {__index = options})
	return v
end

function options:add(name, )

end

function options
return options