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
	local function sort()
		table.sort(drawingQueue, function(a,b)
			return (a.priority < b.priority)
		end)
	end

	local function internalDraw(cam)
		for k = 1, #drawingQueue do
			local v = drawingQueue[k]
			
			if v then
				local x = 0
				local y = 0
				
				if v.isSceneCoordinates then
					x = -cam.x
					y = -cam.y
				end
				
				love.graphics.draw(v.image, v.x + x, v.y + y, v.rotation)
				
				table.remove(drawingQueue, k)
			end
		end
	end

	function Graphics.internalDraw()
		sort()
		
		for k,v in ipairs(Camera) do
			if not v.isHidden then
				love.graphics.setCanvas(v.canvas)
				internalDraw(v)
				love.graphics.setCanvas()
				
				love.graphics.draw(v.canvas, v.renderX, v.renderY)
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

		print(self)
		return rawget(self, key)
	end})
end

_G.Graphics = Graphics