local cam = {}

cam.type = 0
cam.isSplit = (cam.type > 0)

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

function cam.getIntersecting(x1,y1, x2,y2)
	if (type(x1) ~= "number") or (type(y1) ~= "number") or (type(x2) ~= "number") or (type(y2) ~= "number") then
		error("Invalid parameters to getIntersecting")
	end
	
	local ret = {}

	for _,v in ipairs(camera) do
		if x2 > v.x and
		y2 > v.y and
		v.x + v.width > x1 and
		v.y + v.height > y1 then
			ret[#ret + 1] = v
		end
	end
	
	return ret
end

local function cameraUpdate()
	for i = 1, 2 do
		local p = Player[i]
		local v = cam[i]
		
		v.x = (p.x - (v.width * 0.5)) + (p.width * 0.5) * 2
		v.y = (p.y - (v.height * 0.5)) + (p.height * 0.5) * 2
		
		local s = Section[2].boundary

		v.x = math.clamp(v.x, s.left, s.right - v.width)
		v.y = math.clamp(v.y, s.top, s.bottom - v.height)
	end
end

function cam.update()
	local c1 = camera
	local c2 = camera2
	
	if cam.type == 0 then
		c1.height = Game.height
		c1.width = Game.width
		
		c2.isHidden = true
	elseif cam.type == 1 then
		c1.width = Game.width / 2
		c2.width = c1.width
		c1.height = Game.height
		c2.height = c1.height
		
		c2.renderX = c1.width
		
		c2.isHidden = false
	elseif cam.type == 2 then
		c1.height = Game.height / 2
		c2.height = c1.height
		c1.width = Game.width
		c2.width = c1.width
		
		c2.renderX = 0
		c2.renderY = c1.height
		
		c2.isHidden = false
	end
	
	for k,v in ipairs(cam) do
		local c = v.canvas
		
		if c:getWidth() ~= v.width or c:getHeight() ~= v.height then
			v.canvas = love.graphics.newCanvas(v.width, v.height)
		end
	end
	
	cam.isSplit = (cam.type > 0)
	
	cameraUpdate()
end

_G.Camera = Objectify(cam)
camera = Camera.spawn(0, 0)
camera2 = Camera.spawn(400, 0)