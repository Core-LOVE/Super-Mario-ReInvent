local Graphics = {}
local drawingQueue = {}

function Graphics.loadImage(path)
	local img = love.graphics.newImage(path)
	local mt = getmetatable(img)
	
	mt.width = img:getWidth()
	mt.height = img:getHeight()
	
	return img
end

RTYPE_TEXT = "text"
RTYPE_IMAGE = "image"

function Graphics.draw(arg)
	local arg = arg or {}
	
	arg.x = arg.x or 0
	arg.y = arg.y or 0
	arg.type = arg.type or RTYPE_IMAGE
	arg.isSceneCoordinates = arg.isSceneCoordinates or false
	arg.priority = arg.priority or 1
	arg.rotation = arg.rotation or 0
	arg.opacity = arg.opacity or 1
	arg.color = arg.color
	
	table.insert(drawingQueue, arg)
	return arg
end

-- (img, x, y, sourceX, sourceY, width, height, priority) and etc...
-- (img, x, y, priority, opacity, sceneCoords, rotation)
-- (img, x, y, priority, opacity, sceneCoords)
-- (img, x, y, priority, opacity)
-- (img, x, y, priority)
function Graphics.basicDraw(...)
	local arg = {...}
	
	local img
	local x, y
	local sourceX, sourceY
	local width, height
	local opacity
	local priority
	local rotation
	local sceneCoords
	
	img = arg[1]
	x = arg[2]
	y = arg[3]
	
	if #arg ~= 8 then
		priority = arg[4]
		opacity = arg[5]
		sceneCoords = arg[6]
		rotation = arg[7]
	else
		sourceX = arg[4]
		sourceY = arg[5]
		width = arg[6]
		height = arg[7]
		
		priority = arg[8]
		opacity = arg[9]
		sceneCoords = arg[10]
		rotation = arg[11]
	end
	
	Graphics.draw{
		image = img,
		x = x, y = y,
		sourceX = sourceX, sourceY = sourceY,
		sourceWidth = width, sourceHeight = height,
		opacity = opacity, 
		priority = priority,
		rotation = rotation, 
		isSceneCoordinates = sceneCoords,
	}
end

do
	local function draw(v, x, y)
		love.graphics.draw(v.image, v.x + (x or 0), v.y + (y or 0), v.rotation)
	end
	
	local function canvas(v, c)
		local x, y = 0, 0
		if v.isSceneCoordinates then
			x = -c.x
			y = -c.y
		end
		
		draw(v, x, y)
	end
	
	local function internalDraw(v)
		for i,c in ipairs(Camera) do
			if not c.isHidden then
				love.graphics.setCanvas(c.canvas)
				canvas(v, c)
				love.graphics.setCanvas()
				
				love.graphics.draw(c.canvas, c.renderX, c.renderY)
			end
		end
	end
	
	function Graphics.internalDraw()
		table.sort(drawingQueue, function(a,b)
			return (a.priority < b.priority)
		end)
		
		for k = 1, #drawingQueue do
			local v = drawingQueue[k]
			
			if v then
				if v.isSceneCoordinates then
					internalDraw(v)
				else
					draw(v)
				end
				
				table.remove(drawingQueue, k)
			end
		end
	end
end

Graphics.sprites = {
	block = {}
}

for k,v in pairs(Graphics.sprites) do
	setmetatable(v, {__index = function(self, key)
		local img = Graphics.loadImage('graphics/' .. k .. '/' .. k .. '-' .. key .. '.png')
		
		self[key] = {}
		self[key].img = img

		return rawget(self, key)
	end})
end

RENDER_PRIORITY = {
	LEVEL_BG = -100,
	
	FAR_BGO = -95,
	BGO = -85,
	SPECIAL_BGO = -80,
	FOREGROUND_BGO = -20,
	
	SIZEABLE = -90,
	FOREGROUND_BLOCK = -10,
	BLOCK = -65,
	
	BG_NPC = -75,
	FROZEN_NPC = -50,
	NPC = -45,
	HELD_NPC = -30,
	FOREGROUND_NPC = -15,
	SPECIAL_NPC = -55,
	
	WARPING_PLAYER = -70,
	CLOWN_CAR = -35,
	PLAYER = -25,
	
	BG_EFFECT = -60,
	FOREGROUND_EFFECT = -5,
	
	DEFAULT = 1,
	TEXT = 3,
	MESSAGE_ICON = -40,
	HUD = 5,
}

_G.Graphics = Graphics