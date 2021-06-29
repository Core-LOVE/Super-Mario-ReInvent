local bg = {}

bg.fields = function()
	return {
		id = 0,
		layers = {},
	}
end

function bg.create(id)
	
end

TOP = 'top'
BOTTOM = 'bottom'
LEFT = 'left'
RIGHT = 'right'

local function render(cam_id, cam, v, section)
	if type(v.img) == 'number' then
		v.img = Graphics.sprites.background2[v.img].img
	end
	
	v.priority = v.priority or -100
	
	local bound = Section[section].boundary
	
	local aX = v.alignX or LEFT
	local aY = v.alignY or TOP
	
	local x = bound[aX]
	local y = bound[aY]
	
	if aX == RIGHT then
		x = x - v.img:getWidth()
	end
	
	if aY == BOTTOM then
		y = y - v.img:getHeight()
	end
	
	x = x + (v.x or 0)
	y = y + (v.y or 0)
	
	x = x - cam.x
	y = y - cam.y
	
	local w = (bound.right - bound.left)
	local h = (bound.bottom - bound.top)
	
	if v.img:getHeight() > h then
		h = v.img:getHeight()
	end
	
	if v.img:getWidth() > w then
		h = v.img:getHeight()
	end
	
	local repX = 'clampzero'
	local repY = 'clampzero'
	
	if v.repeatX then
		repX = 'repeat'
	end
	
	if v.repeatY then
		repY = 'repeat'
	end
				
	v.img:setWrap(repX, repY)
	
	local sX = bound.left - cam.x
	local sY = bound.top - cam.y
	
	Graphics.draw{
		image = v.img,
		
		x = x, 
		y = y,
		
		sourceX = sX * (v.parallaxX or 1),
		sourceY = sY * (v.parallaxY or 1),
		sourceWidth = w,
		sourceHeight = h,
		
		priority = v.priority,
		camera = cam_id,
	}
end

function bg:render(arg)
	local v = self or {}
	local arg = arg or {}
	
	arg.section = arg.section or v.section
	
	arg.layers = arg.layers or v.layers
	arg.layers.main = arg.layers.main or {}
	arg.layers.main['fill-color'] = arg.layers.main['fill-color'] or Color.black
	
	Graphics.rect{
		color = arg.layers.main['fill-color'],
		
		x = 0,
		y = 0,
		width = Game.width,
		height = Game.height,
		
		camera = -1,
		priority = RENDER_PRIORITY.BG_COLOR,
	}
	
	for cam_id,cam in ipairs(Camera) do
		for k,l in pairs(arg.layers) do
			if k ~= 'main' then
				render(cam_id, cam, l, arg.section)
			end
		end
	end
end

_G.Background = Objectify(bg)