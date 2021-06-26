local Graphics = {}
local drawingQueue = {}

function Graphics.loadImage(path)
	local img = love.graphics.newImage(path)
	local mt = getmetatable(img)
	
	mt.width = img:getWidth()
	mt.height = img:getHeight()
	
	return img
end

local function defaultArg(arg)
	arg.x = arg.x or 0
	arg.y = arg.y or 0
	arg.isSceneCoordinates = arg.isSceneCoordinates or false
	arg.priority = arg.priority or 1
	arg.camera = arg.camera or 0
end

function Graphics.rect(arg)
	local arg = arg or {}
	
	defaultArg(arg)
	arg.width = arg.width or 32
	arg.height = arg.height or 32
	arg.opacity = arg.opacity or 1
	arg.color = arg.color
	arg.form = 'rect'
	arg.mode = arg.mode or 'fill'
	
	table.insert(drawingQueue, arg)
	return arg
end

function Graphics.draw(arg)
	local arg = arg or {}
	
	defaultArg(arg)
	arg.rotation = arg.rotation or 0
	arg.opacity = arg.opacity or 1
	arg.color = arg.color
	arg.sourceX = arg.sourceX or 0
	arg.sourceY = arg.sourceY or 0
	arg.sourceWidth = arg.sourceWidth or 0
	arg.sourceHeight = arg.sourceHeight or 0
	
	if arg.sourceHeight ~= 0 or arg.sourceWidth ~= 0 then
		arg.quad = love.graphics.newQuad(arg.sourceX, arg.sourceY, arg.sourceWidth, arg.sourceHeight, arg.image:getDimensions())
	end
	
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
	local function clear()
		for k = 1, #drawingQueue do
			local v = drawingQueue[k]
			
			if v then
				table.remove(drawingQueue, k)
			end
		end
	end
	
	local function draw(v, x, y)
		col = v.color
		if not col then
			col = Color.white .. v.opacity
		end
		
		love.graphics.setColor(col)
		
		if not v.form then
			if not v.quad then
				love.graphics.draw(v.image, v.x + (x or 0), v.y + (y or 0), v.rotation)
			else
				love.graphics.draw(v.image, v.quad, v.x + (x or 0), v.y + (y or 0), v.rotation)	
			end
		else
			if v.form == "rect" then
				love.graphics.rectangle(v.mode, v.x + .5, v.y + .5, v.width, v.height)
			end
		end
		love.graphics.setColor(Color.white)
	end
	
	local function canvas(v, c)
		local x, y = 0, 0
		if v.isSceneCoordinates then
			x = -c.x
			y = -c.y
		end
		
		draw(v, x, y)
	end
	
	local function internalDraw2(v)
		if v.camera == 0 then
			for _,c in ipairs(Camera) do
				if not c.isHidden then
					love.graphics.setCanvas(c.canvas)
					love.graphics.clear()
					
					canvas(v, c)
					
					love.graphics.setCanvas()
					
					love.graphics.draw(c.canvas, c.renderX, c.renderY)					
				end						
			end
		elseif v.camera > 0 then
			local c = Camera[v.camera]
			
			if not c.isHidden then
				love.graphics.setCanvas(c.canvas)
				love.graphics.clear()
					
				canvas(v, c)
					
				love.graphics.setCanvas()
				love.graphics.draw(c.canvas, c.renderX, c.renderY)					
			end	
		elseif v.camera == -1 then
			canvas(v)
		end
	end
	
	local function internalDraw()
		for k = 1, #drawingQueue do
			local v = drawingQueue[k]
					
			if v then
				internalDraw2(v)
			end
		end
		
		clear()
	end
	
	function Graphics.internalDraw()
		table.sort(drawingQueue, function(a,b)
			return (a.priority < b.priority)
		end)
		
		internalDraw()
	end
end

Graphics.sprites = {
	block = {},
	npc = {},
	mario = {},
	ui = {},
}

for k,v in pairs(Graphics.sprites) do
	setmetatable(v, {__index = function(self, key)
		if k ~= 'ui' then
			local img = Graphics.loadImage('graphics/' .. k .. '/' .. k .. '-' .. key .. '.png')
			
			self[key] = {}
			self[key].img = img

			return rawget(self, key)
		else
			local img = Graphics.loadImage('graphics/' .. k .. '/' .. key .. '.png')
			
			self[key] = {}
			self[key].img = img

			return rawget(self, key)
		end
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