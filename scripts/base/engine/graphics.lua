local Graphics = {}
Graphics.drawingQueue = {}

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
	
	table.insert(Graphics.drawingQueue, arg)
	return arg
end

function Graphics.drawImage(img, x, y, sourceX, sourceY, width, height, opacity, rotation)
	local opacity = opacity
	local color = nil
	
	if sourceX == nil then
		opacity = sourceX
	end
	
	if type(opacity) == 'table' then
		color = opacity
		opacity = nil
	end
	
	return Graphics.draw{
		image = img,
		x = x, y = y,
		sourceX = sourceX, sourceY = sourceY,
		sourceWidth = width, sourceHeight = height,
		opacity = opacity, color = color,
		rotation = rotation
	}
end

function Graphics.drawImageWP(img, x, y, sourceX, sourceY, width, height, opacity, priority, rotation)
	local opacity = opacity
	local color = nil
	
	if sourceY == nil then -- texture,x,y,priority
		priority = sourceX
	elseif sourceWidth == nil then -- texture,x,y,opacity,priority
		opacity = sourceX
		priority = sourceY
	elseif priority == nil then -- texture,x,y,sourceX,sourceY,sourceWidth,sourceHeight,priority
		priority = opacity
		opacity = nil
	end
	
	if type(opacity) == 'table' then
		color = opacity
		opacity = nil
	end
	
	return Graphics.draw{
		image = img,
		x = x, y = y,
		sourceX = sourceX, sourceY = sourceY,
		sourceWidth = width, sourceHeight = height,
		opacity = opacity, color = color,
		rotation = rotation
	}
end

do
	local function sort()
		table.sort(Graphics.drawingQueue, function(a,b)
			return (a.priority < b.priority)
		end)
	end

	local function internalDraw(cam)
		for k = 1, #Graphics.drawingQueue do
			local v = Graphics.drawingQueue[k]
			
			if v then
				local x = 0
				local y = 0
				
				if v.isSceneCoordinates then
					x = cam.x
					y = cam.y
				end
				
				love.graphics.draw(v.image, v.x - x, v.y - y)
				table.remove(Graphics.drawingQueue, k)
			end
		end
	end

	function Graphics.internalDraw()
		sort()
		
		-- for k,v in ipairs(Camera) do
			-- print(v.isHidden)
			-- if not v.isHidden then
				internalDraw()
			-- end
		-- end
	end
end

Graphics.sprites = {}
setmetatable(Graphics.sprites, {
	__index = function(self, key)
	
	end
})

_G.Graphics = Graphics