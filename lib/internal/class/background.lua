local Background = {}

TOP = 0
CENTRE = 0.5
CENTER = CENTRE
BOTTOM = 1

LEFT = 0
RIGHT = 1

do
	local cache = {}
	
	setmetatable(cache, {__index = function(self, name)
		rawset(self, name, Graphics.loadImage(name))
		return rawget(self, name)
	end})
	
	local function renderLayer(section, layer, cam)
		local img
		
		if type(layer.img) == 'number' then
			img = Graphics.sprites.background2[layer.img]
		else
			img = cache[layer.image]
		end
		
		local x = section.x + (section.width - img:getWidth()) * layer.alignX
		local y = section.y + (section.height - img:getHeight()) * layer.alignY
				
		local cx = (cam.x - section.x) * layer.paralX
		local cy = (cam.y - section.y) * layer.paralY
		
		layer.realSX = layer.realSX + layer.speedX
		layer.realSY = layer.realSY + layer.speedY
		
		Graphics.draw{
			image = img,
			
			x = x + layer.x + ((not layer.repeatX and (cx + layer.realSX)) or 0),
			y = y + layer.y + ((not layer.repeatX and (cx + layer.realSY)) or 0),
			
			sourceWidth = (layer.repeatX and section.width),
			sourceHeight = (layer.repeatY and section.height),
			
			wrapMode = layer.wrapMode or 'repeat',
			
			sourceX = layer.repeatX and ((cx + layer.realSX) % img:getWidth()),
			sourceY = layer.repeatY and ((cy + layer.realSY) % img:getHeight()),
			
			targetCamera = cam.idx,
			scene = true,
			priority = layer.priority or PRIORITY.LEVEL_BG,
		}
	end

	function Background:render(section, cam)
		local v = self
		
		for layerName, layer in pairs(v) do
			if layerName == 'main' then
				Graphics.box{
					x = cam.x,
					y = cam.y,
					width = cam.width,
					height = cam.height,
					
					color = Color(layer.fillcolor),
					priority = PRIORITY.BG_COLOR,
				}
			else
				renderLayer(section, layer, cam)
			end
		end
	end
end

function Background.register(n)
	local v = {}
	
	local filename = File.exists('background2-' .. n .. '.txt', {
		'config/background2/',
	})
	
	if filename then
		local file = ini.load(filename)
	
		v = file
	end
		
	for layerName, layer in pairs(v) do
		if layerName ~= 'main' then
			layer.alignX = _G[layer.alignX] or LEFT
			layer.alignY = _G[layer.alignY] or TOP
			layer.paralX = layer.paralX or 0
			layer.paralY = layer.paralY or 0
			layer.x = layer.x or 0
			layer.y = layer.y or 0
			layer.speedX = layer.speedX or 0
			layer.speedY = layer.speedY or 0
			layer.realSX = 0
			layer.realSY = 0
		else
			layer.fillcolor = layer.fillcolor or '000000'
		end
	end
		
	setmetatable(v, {__index = Background})
	Background[n] = v
	return Background[n]
end

setmetatable(Background, {
	__call = function(self, key)
		return self[key]
	end,
	
	__index = function(self, key)
		return Background.register(key)
	end	
})
return Background