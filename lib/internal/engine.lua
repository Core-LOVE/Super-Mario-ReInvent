local Engine = {}
Engine.FPS = 65
Engine.buffer = 0

function Engine.setFPS(num)
	Engine.FPS = num
end

function Engine.getFPS()
	return Engine.FPS
end

return Engine