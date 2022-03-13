local Episode = {}

function Episode.open(name)
	local path, location = File.resolve('worlds/' .. name .. '/world.wld')

	episodePath(path)
end

return Episode