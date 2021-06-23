local cam = {}

cam.type = 0
cam.isSplit = (cam.type > 0)
local old_type = cam.type

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

function cam.update()
	local c1 = camera
	local c2 = camera2
	
	if cam.type == 0 then
		c1.height = 600
		c1.width = 800
		
		c2.isHidden = true
	elseif cam.type == 1 then
		c1.width = 400
		c2.width = c1.width
		c1.height = 600
		c2.height = c1.height
		
		c2.renderX = c1.width
		
		c2.isHidden = false
	elseif cam.type == 2 then
		c1.height = 300
		c2.height = c1.height
		c1.width = 800
		c2.width = c1.width
		
		c2.renderX = 0
		c2.renderY = c1.height
		
		c2.isHidden = false
	end
	
	if old_type ~= cam.type then
		c1.canvas = love.graphics.newCanvas(c1.width, c1.height)
		c2.canvas = love.graphics.newCanvas(c2.width, c2.height)
		
		old_type = cam.type
	end
	
	cam.isSplit = (cam.type > 0)
end

_G.Camera = Objectify(cam)
camera = Camera.spawn(0, 0)
camera2 = Camera.spawn(400, 0)