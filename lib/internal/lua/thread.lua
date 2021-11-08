thread = {}

thread.create = love.thread.newThread

thread.run = function(code, ...)
	local t = thread.create(code)
	t:start(...)
	
	return t
end

thread.get = function(name)
	if type(name) == 'string' then
		if name == 'main' then
			return love.thread.getThread()
		else
			return love.thread.getThread(name)
		end
	else
		return love.thread.getThreads()
	end
end