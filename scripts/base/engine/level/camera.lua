local cam = {}

cam.fields = function()
	return {
		x = 0,
		y = 0,
		renderX = 0,
		renderY = 0,
		width = 800,
		height = 600,
		
		isHidden = false,
	}
end

function cam.spawn(rx,ry)
	local v = Camera.new{
		renderX = rx,
		renderY = ry,
	}
	v.idx = #cam + 1
	v.canvas = love.graphics.newCanvas(v.width, v.height)
	
	cam[v.idx] = v
	return v
end

function cam:inside(v)
	return Game.isColliding(v, self)
end

function cam.getIntersecting(x, y, w, h)
	local ret = {}
	
	for k = 1, #cam do
		local v = cam[k]
		
		if v then
			if v:inside{x = x, y = y, width = w, height = h} then
				ret[#ret + 1] = v
			end
		end
	end
	
	return ret
end

_G.Camera = Objectify(cam)
camera = Camera.spawn(0, 0)
camera2 = Camera.spawn(400, 0)
camera2.isHidden = true