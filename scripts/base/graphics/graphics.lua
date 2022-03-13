local Graphics = {}

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

local lg = love.graphics
lg.setDefaultFilter("nearest", "nearest")
local lg_draw = lg.draw
local lg_push = lg.push
local lg_pop = lg.pop
local lg_setCanvas = lg.setCanvas
local lg_translate = lg.translate
local lg_clear = lg.clear
local lg_newCanvas = lg.newCanvas
local lg_newShader = lg.newShader
local lg_newImage = lg.newImage
local lg_setColor = lg.setColor
local lg_rect = lg.rectangle
local lg_newQuad = lg.newQuad

local zOrder = {}
local table = table
local tablesort = table.sort
local floor = math.floor

do
	local function sort(a, b)
		return (a.priority < b.priority)
	end
	
	local types = {}
	
	types['image'] = function(v, x, y)
		local x = floor(v.x)
		local y = floor(v.y)
		
		if v.quad then
			lg_draw(v.texture, v.quad, x, y)
		else
			lg_draw(v.texture, x, y)
		end
	end
	
	types['rect'] = function(v, x, y)
		lg_rect(v.mode or 'fill', v.x, v.y, v.width, v.height)
	end
	
	local function renderToCamera(c, v)
		if not c.isHidden then
			lg_setCanvas(c.canvas)
			lg_clear()
			
			lg_push()
				lg_translate(-c.x, -c.y)
				types[v.type](v, -c.x, -c.y)	
			lg_pop()		
			
			lg_setCanvas()
				
			love.graphics.draw(c.canvas, c.renderX, c.renderY)
		end
	end
	
	function Graphics.onDrawInternal()
		if not Camera then return end
					
		tablesort(zOrder, sort)
		
		for k = #zOrder, 1, -1 do
			local v = zOrder[k]
			
			lg_push()
				if v.color then
					lg_setColor(v.color)
				end
				-- love.graphics.setBlendMode(v.blendMode, v.alphaMode)
				
				if not v.scene then
					types[v.type](v, 0, 0)
				else
					if v.targetCamera == nil or v.targetCamera == 0 then
						for _,c in ipairs(Camera) do
							renderToCamera(c, v)
						end
					else
						local c = Camera[v.targetCamera]
						
						renderToCamera(c, v)
					end
				end
			lg_pop()
			lg_setColor(1, 1, 1, 1)
			
			zOrder[k] = nil
		end
	end
end

function Graphics.drawLine(args)
	local args = args
	
	args.type = 'line'
	args.priority = args.priority or 0
	args.scene = args.scene or args.sceneCoords
	zOrder[#zOrder + 1] = args
end

function Graphics.drawRect(args)
	local args = args
	
	args.type = 'rect'
	args.priority = args.priority or 0
	args.scene = args.scene or args.sceneCoords
	zOrder[#zOrder + 1] = args
end

function Graphics.draw(args)
	local args = args
	args.texture = args.texture or args.image or args.img
	assert(args.texture ~= nil, 'Must specify texture!')
	
	if args.sourceX or args.sourceY or args.sourceWidth or args.sourceHeight then
		args.quad = lg_newQuad(args.sourceX or 0, args.sourceY or 0, args.sourceWidth or args.texture:getWidth(), args.sourceHeight or args.texture:getHeight(), args.texture:getDimensions())
	end
	
	args.type = 'image'
	args.priority = args.priority or 0
	args.scene = args.scene or args.sceneCoords
	zOrder[#zOrder + 1] = args
end

Graphics.push = lg_push
Graphics.pop = lg_pop
Graphics.clear = lg_clear

Graphics.newShader = lg_newShader
Graphics.newCanvas = lg_newCanvas

Graphics.newImage = function(path, settings)
	local img = File.newImage(path, settings)
	img:setWrap('clampzero', 'clampzero')
	
	return img
end
Graphics.newImageData = File.newImageData

Graphics.newImageMasked = function(path, mpath, settings)
	local main = Graphics.newImageData(path)
	local mask = Graphics.newImageData(mpath)
	
	local function maskMain(x, y, r, g, b, a)
	   local maskR, maskG, maskB = mask:getPixel(x,y)
	   
	   if maskR == maskG and maskG == maskB then
			a = (1 - maskR)
	   end
	   
	   return r,g,b,a
	end
	
	main:mapPixel(maskMain)
	return lg_newImage(main)
end

do
	Graphics.sprites = {}
	
	local newImage = File.newImage
	
	local formats = {
		'.png',
		'.gif',
	}
	
	setmetatable(Graphics.sprites, {__index = function(s, key)
		local sprite = {}
		
		setmetatable(sprite, {__index = function(self, id)
			if key == 'ui' then
				return
			end
			
			local imgPath
			local maskPath
			
			for k = 1, #formats do
				local format = formats[k]
				local path = (key .. '-' .. id .. format)
				
				imgPath = File.resolve(path)
				
				if not imgPath then
					imgPath = File.resolve('graphics/' .. key .. '/' .. path)
				end
				
				if imgPath then
					if format == 'gif' then
						local path = (key .. '-' .. id .. 'm' .. format)
						
						maskPath = File.resolve(path)
						
						if not maskPath then
							maskPath = File.resolve('graphics/' .. key .. '/' .. path)
						end
					end
					
					break
				end
			end
			
			if imgPath then
				local img
				
				if not maskPath then
					img = newImage(imgPath)
				else
					img = Graphics.newImageMasked(imgPath, maskPath)
				end
				
				rawset(self, id, newImage(imgPath))
				return rawget(self, id)
			else
				rawset(self, id, false)
				return false
			end
		end})
		
		rawset(s, key, sprite)
		return rawget(s, key)
	end})
end

function Graphics.onInit()
	registerEvent(Graphics, 'onDrawInternal')
end

return Graphics