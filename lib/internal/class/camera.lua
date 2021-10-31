local Camera = {}

CAMTYPE = {
	DEFAULT = 0,
	HORZ1 = 1,
	VERT1 = 2,
	HORZ2 = 3,
	VERT2 = 4,
}

Camera.type = CAMTYPE.DEFAULT
Camera.drawDividingLines = true

function Camera.spawn(x, y, w, h)
	local v = {}
	
	v.x = 0
	v.y = 0
	v.renderX = x or 0
	v.renderY = y or 0
	v.width = w or 800
	v.height = h or 600
	
	v.scale = 1
	
	v.isHidden = false
	
	v.canvas = love.graphics.newCanvas(v.width, v.height)
	
	setmetatable(v, {__index = Camera})
	Camera[#Camera + 1] = v
	return v
end

local function update(v)
	local target = v.target
	
	if not target then return end
	
	v.x = (target.x - (v.width * 0.5)) + (target.width * 0.5)
	v.y = (target.y - (v.height * 0.5)) + (target.height * 0.5)
end

local checkCameraType

do
	local types = {}

	local function setPS(c, x, y, w, h)
		c.renderX = x
		c.renderY = y
		c.width = w
		c.height = h
	end
	
	types[CAMTYPE.DEFAULT] = function(c, c2)
		setPS(c, 0, 0, 800, 600)
		
		c2.isHidden = true
	end
	
	types[CAMTYPE.HORZ1] = function(c, c2)
		setPS(c, 0, 0, 400, 600)
		
		c2.isHidden = false
		setPS(c2, 400, 0, 400, 600)
	end
	
	types[CAMTYPE.VERT1] = function(c, c2)
		setPS(c, 0, 0, 800, 300)
		
		c2.isHidden = false
		setPS(c2, 0, 300, 800, 300)
	end
	
	types[CAMTYPE.HORZ2] = function(c, c2)
		c2.isHidden = false
		return types[CAMTYPE.HORZ1](c2, c)
	end

	types[CAMTYPE.VERT2] = function(c, c2)
		c2.isHidden = false
		return types[CAMTYPE.VERT1](c2, c)
	end
	
	checkCameraType = function()
		local c = Camera[1]
		local c2 = Camera[2]
		
		if not c or not c2 then return end

		if types[Camera.type] then
			return types[Camera.type](c, c2)
		end
	end
end

function Camera.onTick()
	checkCameraType()
	
	for k,v in ipairs(Camera) do
		update(v)
	end
end

function Camera.onDraw()
	if not Camera.drawDividingLines then return end
	
	local c = Camera[1]
	local c2 = Camera[2]
	
	if not c or not c2 then return end

	
end

function Camera.onInit()
	registerFunction(camera, 'onTick')
	registerFunction(camera, 'onDraw')
end

camera = Camera.spawn()
camera2 = Camera.spawn(400)

setmetatable(Camera, {__call = function(self, key)
	return Camera[key]
end})

return Camera