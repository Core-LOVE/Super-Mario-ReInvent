local Graphics = {}
local queqe = {}

Color = require 'graphics/color'
-- local push = require 'ext/push'

-- do
	-- local gameWidth, gameHeight = Engine.getResolution() --fixed game resolution
	-- local windowWidth, windowHeight = love.window.getDesktopDimensions()
	-- windowWidth, windowHeight = windowWidth*.7, windowHeight*.7 --make the window a bit smaller than the screen itself

	-- push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})
-- end

PRIORITY = {
	BG_COLOR = -101,
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
	
	DEFAULT = 0,
	TEXT = 3,
	MESSAGE_ICON = -40,
	HUD = 5,
}

Graphics.loadImage = File.loadImage

Graphics.sprites = {}

setmetatable(Graphics.sprites, {__index = function(self, key)
	local t = {}
	
	setmetatable(t, {__index = function(v,index)
		if key ~= 'ui' then
			rawset(v, index, Graphics.loadImage(key .. '-' .. index .. '.png', {
				'graphics/',
				'graphics/' .. key .. '/',
			}))
		else
			rawset(v, index, Graphics.loadImage(key .. '.png', {
				'graphics/',
				'graphics/' .. key .. '/',
			}))
		end
		
		return rawget(v, index)
	end})
	
	rawset(self, key, t)
	return rawget(self, key)
end})

local function addToCache(t)
	local t = t or {}
	
	t.scene = t.scene or t.sceneCoords or false
	t.targetCamera = t.targetCamera or t.camera or 0
	
	t.uniform = t.uniform or t.uniforms
	
	t.blendMode = 'alpha'

	t.priority = t.priority or t.z or t.depth or PRIORITY.DEFAULT
	
	t.color = t.color or t.col or {1,1,1,1}
	t.opacity = t.opacity or t.alpha
	if t.opacity then
		t.color[4] = t.opacity
	end
	
	queqe[#queqe + 1] = t
	return t
end

function Graphics.draw(t)
	local t = addToCache(t)
	
	t.wrapMode = t.wrapMode or t.wrap or t.mode
	
	t.image = t.image or t.texture or t[1]
	t.x = t.x or t[2]
	t.y = t.y or t[3]
	
	t.rotation = t.rotation or t.angle or t.rot or 0
	
	t.scaleX = t.scaleX or t.scale or 1
	t.scaleY = t.scaleY or t.scale or 1
	
	t.alignX = t.alignX or t.aX or t.align or 0
	t.alignY = t.alignY or t.aY or t.align or 0
	
	t.shearX = t.shearX or 0
	t.shearY = t.shearY or 0
	
	if t.sourceX ~= 0 or t.sourceY ~= 0 or t.sourceWidth ~= 0 or t.sourceHeight ~= 0 then
		t.sourceX = t.sourceX or 0
		t.sourceY = t.sourceY or 0
		t.sourceWidth = t.sourceWidth or t.image:getWidth()
		t.sourceHeight = t.sourceHeight or t.image:getHeight()
		
		t.quad = love.graphics.newQuad(t.sourceX, t.sourceY, t.sourceWidth, t.sourceHeight, t.image:getDimensions())
	end
	
	t.type = 'image'
	
	return t
end

function Graphics.rect(t)
	local t = addToCache(t)
	
	t.mode = t.mode or 'fill'
	t.x = t.x or t[1]
	t.y = t.y or t[2]
	t.width = t.width or t.w or t[3]
	t.height = t.height or t.h or t[4]
	
	t.lineWidth = t.lineWidth or 1
	t.smooth = t.smooth or false
	
	t.type = "rect"
	
	return t
end

Graphics.rectangle = Graphics.rect
Graphics.box = Graphics.rect

function Graphics.line(t)
	local t = addToCache(t)
	
	t.width = t.width or 1
	t.smooth = t.smooth or false
	
	t.type = "line"
	
	return t
end

Graphics.lines = Graphics.line

function Graphics.circle(t)
	local t = addToCache(t)

	t.mode = t.mode or 'fill'
	
	t.lineWidth = t.lineWidth or 1
	t.smooth = t.smooth or false
	
	t.x = t.x or t[1]
	t.y = t.y or t[2]
	t.radius = t.radius or t.rad or t[3]
	
	t.type = 'circle'
	
	return t
end

do
	local function sort(a, b)
		return (a.priority < b.priority)
	end
	
	local render = {}
	
	local rad = math.rad
	
	render.image = function(v, x, y)
		local dm
		
		if v.wrapMode then
			dm = v.image:getWrap()
			v.image:setWrap(v.wrapMode)
		end
		
		if v.shader then
			love.graphics.setShader(v.shader)

			if v.uniform then
				for u,k in pairs(v.uniform) do
					v.shader:send(u, k)
				end
			end
		end
	
		if v.quad then
			love.graphics.draw(v.image, v.quad, v.x + x, v.y + y, rad(v.rotation), v.scaleX, v.scaleY, v.alignX, v.alignY, v.shearX, v.shearY)
		else
			love.graphics.draw(v.image, v.x + x, v.y + y, rad(v.rotation), v.scaleX, v.scaleY, v.alignX, v.alignY, v.shearX, v.shearY)
		end
		
		if v.shader then
			love.graphics.setShader()
		end
		
		if dm then
			v.image:setWrap(dm)
		end
	end
	
	render.rect = function(v, x, y)
		love.graphics.setLineStyle((v.smooth and 'smooth') or 'rough')
		love.graphics.setLineWidth(v.lineWidth)
		
		love.graphics.rectangle(v.mode, v.x + x, v.y + y, v.width, v.height)
		
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')
	end
	
	render.circle = function(v, x, y)
		love.graphics.setLineStyle((v.smooth and 'smooth') or 'rough')
		love.graphics.setLineWidth(v.lineWidth)
		
		love.graphics.circle(v.mode, v.x + x, v.y + y, v.radius)
		
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')
	end
	
	render.line = function(v, x, y)
		for amount = 1, #v do
			local num = amount % 3
			local val = v[amount]
			
			if num == 1 then
				val = val + x
			else
				val = val + y
			end
		end
		
		love.graphics.setLineStyle((v.smooth and 'smooth') or 'rough')
		love.graphics.setLineWidth(v.width)
		
		love.graphics.line(v)
		
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')
	end
	
	local function renderToCamera(c, v)
		if not c.isHidden then
			love.graphics.setCanvas(c.canvas)
			love.graphics.clear()
				
			render[v.type](v, -c.x, -c.y)		
			love.graphics.setCanvas()
				
			love.graphics.draw(c.canvas, c.renderX, c.renderY)
		end
	end
	
	local tablesort = table.sort
	local min = math.min
	
	function Graphics.onDraw()
		tablesort(queqe, sort)
		
		-- push:start()
		
		for k = 1, #queqe do
			local v = queqe[k]
			
			love.graphics.setColor(v.color)
			love.graphics.setBlendMode(v.blendMode, v.alphaMode)
			
			if not v.scene then
				render[v.type](v, 0, 0)
			else
				if not Camera then return end
				
				if v.targetCamera == 0 then
					for _,c in ipairs(Camera) do
						renderToCamera(c, v)
					end
				else
					local c = Camera[v.targetCamera]
					
					renderToCamera(c, v)
				end
			end
			
			love.graphics.setBlendMode('alpha')
			love.graphics.setColor(1,1,1,1)
		end
		-- push:finish()
		
		queqe = {}
	end
end

Graphics.newShader = love.graphics.newShader

function Graphics.loadShader(name)
	local name = File.exists(name, {
		'graphics/shaders/',
	})
	
	local code = File.read(name)

	return Graphics.newShader(code)
end

function Graphics.onWindowResize(w, h)
  -- return push:resize(w, h)
end

function Graphics.onInit()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	registerFunction(Graphics, 'onDraw')
	registerFunction(Graphics, 'onWindowResize')
end

return Graphics