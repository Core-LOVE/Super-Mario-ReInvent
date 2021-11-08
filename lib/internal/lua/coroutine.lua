coroutine.run = function(f, ...)
	local c = coroutine.create(f)
	
	c:resume(...)
	return c
end