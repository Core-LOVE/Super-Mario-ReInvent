local Camera = {}
Camera.__type = "Camera"

CAMTYPE = {
	DEFAULT = 0,
	HORZ1 = 1,
	VERT1 = 2,
	HORZ2 = 3,
	VERT2 = 4,
}
CAMTYPE.HORZ = CAMTYPE.HORZ1
CAMTYPE.VERT = CAMTYPE.VERT1

Camera.type = CAMTYPE.DEFAULT
local previousType = CAMTYPE.DEFAULT

Camera.drawDividingLines = true
Camera.division = true

function Camera.spawn(x, y, w, h)
	local v = {}
	
	v.idx = #Camera + 1

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

local function clamp(n, low, high) return math.min(math.max(n, low), high) end

local function update(v)
	local p = Player(1)
	
	if v.idx == 2 then
		p = Player(2)
	end
	
	local target = v.target or p
	
	if not target then return end
	
	if not target.width or not target.height then
		v.x = target.x - v.width * 0.5
		v.y = target.y - v.height * 0.5
		return
	end
	
	v.x = (target.x - (v.width * 0.5)) + (target.width * 0.5)
	v.y = (target.y - (v.height * 0.5)) + (target.height * 0.5)
	
	local s = target.section

	if s and Section(s) then
		local s = Section(s)
		
		if v.x < s.x then
			v.x = s.x
		elseif v.x + v.width > s.x + s.width then
			v.x = (s.x + v.width) - v.width
		end
		
		if v.y + v.height > s.y + s.height then
			v.y = (s.y + s.height) - v.height
		end
		
		if v.y < s.y then
			v.y = s.y
		end
	end
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
			types[Camera.type](c, c2)
		end
		
		if previousType ~= Camera.type then
			c.canvas = love.graphics.newCanvas(c.width, c.height)
			c2.canvas = love.graphics.newCanvas(c2.width, c2.height)
			previousType = Camera.type
		end
	end
end

function Camera.onTick(dt)
	checkCameraType()
	
	for k,v in ipairs(Camera) do
		update(v)
	end
end

function Camera.onDraw()
	-- if not Camera.drawDividingLines then return end
	
	-- local c = Camera[1]
	-- local c2 = Camera[2]
	
	-- if not c or not c2 then return end

	-- if Camera.type == CAMTYPE.HORZ1 or Camera.type == CAMTYPE.HORZ2 then
		-- Graphics.box{
			-- 400,0,2,600,
			
			-- priority = 6,
			-- color = Color.black,
		-- }
	-- else
		-- if Camera.type == CAMTYPE.DEFAULT then return end
		
		-- Graphics.box{
			-- 0, 300, 800, 2,
			
			-- priority = 6,
			-- color = Color.black,
		-- }
	-- end
end

function Camera.onInit()
	registerEvent(camera, 'onTick')
	registerEvent(camera, 'onDraw')
end

camera = Camera.spawn()
camera2 = Camera.spawn()
camera2.isHidden = true

setmetatable(Camera, {__call = function(self, key)
	return self[key]
end})

return Camera