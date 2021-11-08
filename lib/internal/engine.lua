local Engine = {}
Engine.FPS = 65

Engine.widescreen = false
Engine.resolution = {width = 800, height = 600}

function Engine.setFPS(num)
	Engine.FPS = num
end

function Engine.getFPS()
	return Engine.FPS
end

Engine.getRealFPS = love.timer.getFPS
Engine.getTime = love.timer.getTime
Engine.sleep = love.timer.sleep
Engine.getDelta = love.timer.getDelta

function Engine.setWindowSize(nw, nh, nf)
	local w,h,flags = love.window.getMode()

	return love.window.setMode(nw or w, nh or h, nf or flags)
end

function Engine.getResolution()
	return Engine.resolution.width, Engine.resolution.height
end

return Engine