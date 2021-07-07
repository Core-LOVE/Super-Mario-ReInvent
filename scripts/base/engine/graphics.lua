local Graphics = {}
local drawingQueue = {}
local shaders = {}

do
	local function checkPath(path)
		if nfs.read(path) ~= nil then
			return path
		end
	end

	local open = function(path)
		local c = Level.current
		local path = checkPath(c.levelFolder .. path) or checkPath(c.fileFolder .. path) or checkPath(_PATH .. path) or checkPath(path)
		
		if path ~= nil then
			return nfs.newFileData(path)
		end
	end
	
	function Graphics.loadShader(pixel, vertex)
		return love.graphics.newShader(pixel, vertex)
	end
	
	function Graphics.loadImage(path)
		local file = open(path)
		
		if file then
			return love.graphics.newImage(file)
		end
	end
end

local function defaultArg(arg)
	arg.x = arg.x or 0
	arg.y = arg.y or 0
	arg.isSceneCoordinates = arg.isSceneCoordinates or arg.sceneCoords or false
	arg.priority = arg.priority or 1
	arg.camera = arg.camera or 0
	
	arg.shader = arg.shader
	if arg.shader then
		arg.uniforms = arg.uniforms or {}
		
		for k,v in pairs(arg.uniforms) do
			arg.shader:send(k, v)
		end
	end
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
	
	drawingQueue[#drawingQueue + 1] = arg
end

function Graphics.meshDraw(arg)
	local arg = arg or {}

	defaultArg(arg)
	
	arg.texture = arg.texture or {
		0,0,
		1,0,
		1,1,
		0,1
	}
	
	arg.color = arg.color or {
		Color.white,
		Color.white,
		Color.white,
		Color.white,
	}
	
	arg.mode = arg.mode or "fan"
	
	local vertices = {}
	
	vertices[1] = {
		arg.vertex[1], arg.vertex[2],
		arg.texture[1], arg.texture[2],
		arg.color[1], arg.color[2], arg.color[3], arg.color[4]
	}
	
	vertices[2] = {
		arg.vertex[3], arg.vertex[4],
		arg.texture[3], arg.texture[4],
		arg.color[5], arg.color[6], arg.color[7], arg.color[8]
	}
	
	vertices[3] = {
		arg.vertex[5], arg.vertex[6],
		arg.texture[5], arg.texture[6],
		arg.color[9], arg.color[10], arg.color[11], arg.color[12]
	}
	
	vertices[4] = {
		arg.vertex[7], arg.vertex[8],
		arg.texture[7], arg.texture[8],
		arg.color[13], arg.color[14], arg.color[15], arg.color[16]
	}
	
	local img = arg.image
	arg.image = love.graphics.newMesh(vertices, arg.mode)
	
	if img then
		arg.image:setTexture(img)
	end
	
	drawingQueue[#drawingQueue + 1] = arg
end

alignIN = {
	TOP_LEFT = "TOP_LEFT",
	TOP_RIGHT = "TOP_RIGHT",
	TOP = "TOP",
	
	CENTER_LEFT = "CENTER_LEFT",
	CENTER_RIGHT = "CENTER_RIGHT",
	CENTER = "CENTER",
	
	BOTTOM_lEFT = "BOTTOM_lEFT",
	BOTTOM_RIGHT = "BOTTOM_RIGHT",
	BOTTOM = "BOTTOM",
}

local function setAlign(arg)
	local o = arg.align
	local v = arg.image
	
	-- redigitiscool
	
	if o == "TOP_RIGHT" then
		arg.alignX = v:getWidth()
	elseif o == "TOP" then
		arg.alignX = v:getWidth() / 2 
	elseif o == "CENTER_LEFT" then
		arg.alignY = v:getHeight() / 2
	elseif o == "CENTER_RIGHT" then
		arg.alignX = v:getWidth()
		arg.alignY = v:getHeight() / 2
	elseif o == "CENTER" then
		arg.alignX = v:getWidth() / 2
		arg.alignY = v:getHeight() / 2
	elseif o == "BOTTOM_lEFT" then
		arg.alignY = v:getHeight()
	elseif o == "BOTTOM_RIGHT" then
		arg.alignX = v:getWidth()
		arg.alignY = v:getHeight()
	elseif o == "BOTTOM" then
		arg.alignX = v:getWidth() / 2
		arg.alignY = v:getHeight()
	end
end

function Graphics.draw(arg)
	local arg = arg or {}
	
	if arg.image == nil then return end
	
	defaultArg(arg)
	arg.rotation = arg.rotation or 0
	arg.opacity = arg.opacity or 1
	arg.color = arg.color
	arg.sourceX = arg.sourceX or 0
	arg.sourceY = arg.sourceY or 0
	arg.sourceWidth = arg.sourceWidth or 0
	arg.sourceHeight = arg.sourceHeight or 0
	
	arg.scaleX = arg.scaleX or 1
	arg.scaleY = arg.scaleY or 1
	
	arg.alignX = arg.alignX or 0
	arg.alignY = arg.alignY or 0
	setAlign(arg)
	
	arg.shearX = arg.shearX or 0
	arg.shearY = arg.shearY or 0
	
	if arg.sourceHeight ~= 0 or arg.sourceWidth ~= 0 then
		arg.quad = love.graphics.newQuad(arg.sourceX, arg.sourceY, arg.sourceWidth, arg.sourceHeight, arg.image:getDimensions())
	end
	
	drawingQueue[#drawingQueue + 1] = arg
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
		col = v.color
		if not col then
			col = Color.white .. v.opacity
		end
		
		love.graphics.setColor(col)
		
		if not v.form then
			if not v.quad then
				love.graphics.draw(v.image, v.x + (x or 0), v.y + (y or 0), v.rotation, v.scaleX, v.scaleY, v.alignX, v.alignY, v.shearX, v.shearY)
			else
				love.graphics.draw(v.image, v.quad, v.x + (x or 0), v.y + (y or 0), v.rotation, v.scaleX, v.scaleY, v.alignX, v.alignY, v.shearX, v.shearY)	
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
			for i = 1, #Camera do
				local c = Camera[i]
				
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
	end
	
	local function sortQueue(a,b)
		return (a.priority < b.priority)
	end
	
	function Graphics.internalDraw()
		table.sort(drawingQueue, sortQueue)
		
		internalDraw()
		
		drawingQueue = {}
	end
end

Graphics.sprites = {
	block = {},
	background = {},
	background2 = {},
	npc = {},
	mario = {},
	
	ui = {},
}

for k,v in pairs(Graphics.sprites) do
	setmetatable(v, {__index = function(self, key)
		if k ~= 'ui' then
			local img = Graphics.loadImage(k .. '-' .. key .. '.png')
			
			if not img then
				img = Graphics.loadImage('graphics/' .. k .. '/' .. k .. '-' .. key .. '.png')
			end
			
			self[key] = {}
			self[key].img = img

			return rawget(self, key)
		else
			local img = Graphics.loadImage(key .. '.png')
			
			if not img then
				img = Graphics.loadImage('graphics/' .. k .. '/' .. key .. '.png')
			end
			
			self[key] = {}
			self[key].img = img

			return rawget(self, key)
		end
	end})
end

RENDER_PRIORITY = {
	BG_COLOR = -102,
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