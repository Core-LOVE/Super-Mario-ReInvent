local Engine = {}
Engine.FPSCap = 65

Engine.speed = 1

Engine.widescreen = false
Engine.resolution = {width = 800, height = 600}

function Engine.setFPSCap(num)
	Engine.FPSCap = num
end

function Engine.getFPSCap()
	return Engine.FPSCap
end

Engine.getRealFPS = love.timer.getFPS
Engine.getTime = love.timer.getTime
Engine.sleep = love.timer.sleep

function Engine.getDelta()
	return (love.timer.getDelta() * Engine.FPSCap) * Engine.speed 
end

return Engine